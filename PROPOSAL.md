# GeoInterface v1.0 RFC

* **Title**: An Interface for Geospatial Geometries in Julia
* **Authors**: Martijn Visser (mgvisser@gmail.com) and Yeesian Ng (ngyeesian@gmail.com)
* **Created**: October 2019
* **Status**: **Draft** | In Review | Work In Progress | Completed
* **Review Requested**:
    - [x] evetion
    - [ ] meggart
    - [ ] rafaqz
    - [ ] mkborregaard
    - [ ] SimonDanisch
    - [ ] andyferris
    - [ ] asinghvi17

# Abstract
This document describe a set of traits based on the [Simple Features standard (SF)](https://www.opengeospatial.org/standards/sfa)
for geospatial vector data, including the SQL/MM extension with support for circular geometry. While we try to adhere to SF, there are changes and extensions to make it more Julian.

This package won't support WKB/WKT or spatial operations (DE-9IM) as it aims to interface between existing packages with that functionality.

Intended to replace the existing [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl). 

# Proposal
GeoInterface provides
(a) a set of functions:
```julia
geomtype(geom)

getexterior(geom)
getcoord(geom, i)
getgeom(geom, i)
gethole(geom, i)
getlinestring(geom, i)
getpoint(geom, i)
getpolygon(geom, i)

ncoord(geom)
ngeom(geom)
nhole(geom)
nlinestring(geom)
npoint(geom)
npolygon(geom)

isempty(geom)
issimple(geom)
isclosed(geom)
```

(b) a set of types for dispatching on the functions. The types tells GeoInterface
    how to interpret the input object inside a GeoInterface function.

```julia
abstract Geometry
Point <: Geometry,
LineString <: Geometry,
Polygon <: Geometry,
MultiPoint <: Geometry,
MultiLineString <: Geometry,
MultiPolygon <: Geometry,
GeometryCollection <: Geometry
...
```

> What do we do with the null geometries / missing geometries?
We could define `empty` geometries (no vertices), it is actually in the SF spec, hence the is_empty method.

(c) implementation for AbstractVectors and Tuples

## For developers looking to implement the interface

A geom with "Point"-like traits has to implement the following method:
```julia
GeoInterface.geomtype(geom) = GeoInterface.Point()
GeoInterface.ncoord(geom)::Integer
GeoInterface.getcoord(geom, i)::Real
```
A geom with "LineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(linestring) = GeoInterface.LineString()
GeoInterface.ncoord(linestring)::Integer
GeoInterface.npoint(linestring)::Integer
GeoInterface.getpoint(linestring, i)::"Point"
GeoInterface.isclosed(linestring)::Bool
```
A geom with "Polygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(polygon) = GeoInterface.Polygon()
GeoInterface.ncoord(polygon)::Integer
GeoInterface.getexterior(polygon)::"LineString"
GeoInterface.nhole(polygon)::Integer
GeoInterface.gethole(polygon, i)::"LineString"
```
A geom with "GeometryCollection"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geometrycollection) = GeoInterface.GeometryCollection()
GeoInterface.ncoord(geometrycollection)::Integer
GeoInterface.ngeom(geometrycollection)::Integer
GeoInterface.getgeom(geometrycollection, i)::"Geometry"
```
A geom with "MultiPoint"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(multipoint) = GeoInterface.MultiPoint()
GeoInterface.ncoord(multipoint)::Integer
GeoInterface.npoint(multipoint)::Integer
GeoInterface.getpoint(multipoint, i)::"Point"
```
A geom with "MultiLineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(multilinestring) = GeoInterface.MultiLineString()
GeoInterface.ncoord(multilinestring)::Integer
GeoInterface.nlinestring(multilinestring)::Integer
GeoInterface.getlinestring(multilinestring, i)::"LineString"
```
A geom with "MultiPolygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(multipolygon) = GeoInterface.MultiPolygon()
GeoInterface.ncoord(multipolygon)::Integer
GeoInterface.npolygon(multipolygon)::Integer
GeoInterface.getpolygon(multipolygon, i)::"Polygon"
```

> Should we distinguish `npolygon`, `nlinestring`, `npoint`, `ngeom`, or collect in `ngeom`? Same for `getpoint`, `getlinestring`, `getpolygon` versus `getgeom`.
>
> Requiring the `getgeom` (and similar) methods seems to imply that these collections must be indexable as opposed to just iterable. Should we require them at least to be iterable, and only optionally indexable?

## Dispatching on geomtype()

As there are a wide number of methods (qualified and unqualified), for every
unqualified function call, GeoInterface dispatches to the corresponding qualified
function based on the `geomtype()` of the input geometry. Therefore, unqualified
function calls for geometries of undefined `geomtype()` will result in error.

In such cases, its `geomtype()` might be undefined, but knowledge of the data type
itself might be sufficient for the user to know which GeoInterface.jl methods
are supported for the data type. For example, a `Vector{Tuple{Int,Int}}` can behave
like a Polygon, LineString, or MultiPoint. In such situations, the qualified use
of GeoInterface methods should still be legal.

Here's a mock-up of an implementation:
```julia
# All Geometries
GeoInterface.ncoord(geom) =
    GeoInterface.ncoord(GeoInterface.geomtype(geom), geom)
# Point
GeoInterface.getcoord(geom, i::Integer) =
    GeoInterface.getcoord(GeoInterface.geomtype(geom), geom, i)
# LineString, MultiPoint
GeoInterface.npoint(geom) =
    GeoInterface.npoint(GeoInterface.geomtype(geom), geom)
GeoInterface.getpoint(geom, i::Integer) =
    GeoInterface.getpoint(GeoInterface.geomtype(geom), geom, i)
# Polygon
GeoInterface.getexterior(geom) =
    GeoInterface.getexterior(GeoInterface.geomtype(geom), geom)
GeoInterface.nhole(geom) =
    GeoInterface.nhole(GeoInterface.geomtype(geom), geom)
GeoInterface.gethole(geom, i::Integer) =
    GeoInterface.gethole(GeoInterface.geomtype(geom), geom, i)
# GeometryCollection
GeoInterface.ngeom(geom) =
    GeoInterface.ngeom(GeoInterface.geomtype(geom), geom)
GeoInterface.getgeom(geom, i::Integer) =
    GeoInterface.getgeom(GeoInterface.geomtype(geom), geom, i)
# MultiLineString
GeoInterface.nlinestring(geom) =
    GeoInterface.nlinestring(GeoInterface.geomtype(geom), geom)
GeoInterface.getlinestring(geom, i::Integer) =
    GeoInterface.getlinestring(GeoInterface.geomtype(geom), geom, i)
# MultiPolygon
GeoInterface.npolygon(geom) =
    GeoInterface.npolygon(GeoInterface.geomtype(geom), geom)
GeoInterface.getpolygon(geom, i::Integer) =
    GeoInterface.getpolygon(GeoInterface.geomtype(geom), geom, i)
```

## Support for Primitive Types
Here's a mock-up of an implementation:
```julia
# Point
GeoInterface.geomtype(geom::AbstractVector{T}) where {T <: Real} =
    GeoInterface.Point()
GeoInterface.geomtype(geom::Tuple{T,U}) where {T,U <: Real} =
    GeoInterface.Point()
GeoInterface.geomtype(geom::Tuple{T,U,V}) where {T,U,V <: Real} =
    GeoInterface.Point()

# misses the Real eltype requirement, also below
function GeoInterface.ncoord(
        GeoInterface.Point,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom)
end

function GeoInterface.getcoord(
        GeoInterface.Point,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end

# LineString
function GeoInterface.ncoord(
        GeoInterface.LineString,
        geom::Union{AbstractVector, Tuple}
    )
    point = GeoInterface.getpoint(geom, 1)
    return GeoInterface.ncoord(GeoInterface.Point, point)
end

function GeoInterface.npoint(
        GeoInterface.LineString,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom)
end

function GeoInterface.getpoint(
        GeoInterface.LineString,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end

# Polygon
function GeoInterface.ncoord(
        GeoInterface.Polygon,
        geom::Union{AbstractVector, Tuple}
    )
    # does sf also only count exterior points?
    linestring = GeoInterface.getexterior(geom)
    return GeoInterface.ncoord(GeoInterface.LineString, linestring)
end

function GeoInterface.getexterior(
        GeoInterface.Polygon,
        geom::Union{AbstractVector, Tuple}
    )
    return geom[1]
end

function GeoInterface.nhole(
        GeoInterface.Polygon,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom) - 1
end

function GeoInterface.gethole(
        GeoInterface.Polygon,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i+1]
end

# GeometryCollection
function GeoInterface.ncoord(
        GeoInterface.GeometryCollection,
        collection::Union{AbstractVector, Tuple}
    )
    geom = GeoInterface.getgeom(collection, 1)
    return GeoInterface.ncoord(GeoInterface.geomtype(geom), geom)
end

function GeoInterface.ngeom(
        GeoInterface.GeometryCollection,
        collection::Union{AbstractVector, Tuple}
    )
    return length(collection)
end

function GeoInterface.getgeom(
        GeoInterface.GeometryCollection,
        collection::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end

# MultiPoint
function GeoInterface.ncoord(
        GeoInterface.MultiPoint,
        geom::Union{AbstractVector, Tuple}
    )
    point = GeoInterface.getpoint(geom, 1)
    return GeoInterface.ncoord(GeoInterface.Point, point)
end

function GeoInterface.npoint(
        GeoInterface.MultiPoint,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom)
end

function GeoInterface.getpoint(
        GeoInterface.MultiPoint,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end

# MultiLineString
function GeoInterface.ncoord(
        GeoInterface.MultiLineString,
        geom::Union{AbstractVector, Tuple}
    )
    linestring = GeoInterface.getlinestring(geom, 1)
    return GeoInterface.ncoord(GeoInterface.LineString, linestring)
end

function GeoInterface.nlinestring(
        GeoInterface.MultiLineString,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom)
end

function GeoInterface.getlinestring(
        GeoInterface.MultiLineString,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end

# MultiPolygon
function GeoInterface.ncoord(
        GeoInterface.MultiPolygon,
        geom::Union{AbstractVector, Tuple}
    )
    polygon = GeoInterface.getpolygon(geom, 1)
    return GeoInterface.ncoord(GeoInterface.Polygon, polygon)
end

function GeoInterface.npolygon(
        GeoInterface.MultiPolygon,
        geom::Union{AbstractVector, Tuple}
    )
    return length(geom)
end

function GeoInterface.getpolygon(
        GeoInterface.MultiPolygon,
        geom::Union{AbstractVector, Tuple},
        i::Integer
    )
    return geom[i]
end
```

# Questions and Answers

## Q1 Why this approach?
Ultimately, for people who care about the representation of their geometries, a conversion into the desired format will have to happen anyway. For people who are agnostic to the representation, the set of supported methods should (a) be sufficient to provide a way for us to convert it into a common GIS file format (WKB/WKT), and (b) be sufficiently useful for generic programming without being too difficult to adopt.

## Q2: Why are the functions not based on e.g. `Base.getindex(obj, i)`?
That way, the type of the output geometry can be inferred from the method being called. (In some cases, additional methods of disambiguation (e.g. by their type) might be required for inferring the type of the input geometry.)

## Q3: Why `ncoord` and not `ndim`?
The word "dimension" is too overloaded with meaning: in the SFA, there is a "coordinate dimension" (definition 4.4), and a "topological dimension" (see e.g. definition 4.18). So a point with 2 coordinates has (a) a topological dimension of 0, and (b) a coordinate dimension of 2.

## Q4 I really do not like the choice of names in this package. I'll also like to be able to export some of the functions for ease of use. What should I do?
You can write a package that renames the functions, and export the ones you want.

## Q5: Why are there no features and featurecollections (and CRS and boundingboxes)?
Those might be more appropriate for potential packages such as "GeoTables.jl" (see [GeoJSONTables.jl](https://github.com/visr/GeoJSONTables.jl) for example), which can associate geometries with properties and metadata such as CRS and boundingboxes.

# Affected Packages
* **That should implement it**: `Shapefile`, `GeoJSON`, `ArchGDAL`, `GeometryBasics`, `LibGEOS`, `GeometryTypes`
* **That might use it**: `GeoMakie`, `Turf` (?), `GeoTables` (?), `MeshCore`, `GeoStats`.

# Some Alternatives Considered

## A concrete set of geometries
It has never gained any traction; see the [meeting minutes](https://github.com/JuliaGeometry/meta/wiki/First-Meetup-Minutes) from the first JuliaGeometry Meetup. Some packages never had a say in the representation of their geometries if it came straight from other drivers, or are based on specifications such as GeoJSON or the ESRI Shapefile.

## A Type Hierarchy
The versions of GeoInterface until v0.4. It got some traction, but has reached its limitations. 

> Would be good to show some of these limitations for people that may not be convinced. Such as, treating an `AbstractVector{<:Real}` as a point is not possible, or in general extending from outside packages, because of single inheritance.

# References
This proposal has been inspired by the [Geo Interface](https://gist.github.com/sgillies/2217756)
in Python (which in turn borrows its design from the [GeoJSON specification](http://geojson.org/)).

This proposal has also been shaped by discussions across:
https://discourse.julialang.org/t/traits-in-julia/17267/2
https://github.com/JuliaGeo/GeoJSON.jl/issues/21
https://github.com/JuliaGeo/GeoInterface.jl/issues/20#issuecomment-458653053
https://github.com/JuliaGeo/GeoInterface.jl/pull/25
https://github.com/JuliaGeometry/meta/wiki
https://github.com/JuliaGeometry/GeometryTypes.jl/pull/166
https://github.com/JuliaGeometry/GeometryTypes.jl/pull/166#issuecomment-460959072
https://github.com/JuliaGeometry/GeometryTypes.jl/pull/166#issuecomment-460484813
https://github.com/JuliaData/DBFTables.jl/pull/9
https://github.com/visr/GeoJSONTables.jl and https://github.com/JuliaGeo/Shapefile.jl/pull/33





# A few more random thougths

From <https://github.com/JuliaGeometry/GeometryTypes.jl/pull/166#issuecomment-460959072>

>  The advantage of abstract interfaces is that it allows you to have different types and still code to them under the same logic. This is extremely useful if you need to have different types. While abstractions are a lot easier to agree on and implement throughout the ecosystem, it also comes at the cost of unclarity. Say I load a shapefile with Shapefiles which is just julia Vectors of Points, and one with GDAL which wraps a pointer to a GDAL object, then uses LibgGEOS to intersect them - what type of Polygon should I then have? Do I end up with a mix of pure-Julia objects and C pointers etc in my workspace? And how many implicit copies happened by conversion in the process? (Let me know if I misunderstand any of the relationships here).

> To be clear what I suggest is having both - i.e. to have an abstract interface, but also attempt to use the same concrete types where possible.

What is our blessed type? WKB, GeometryBasics or something else? Perhaps best to leave out of this RFC, but it may be good to agree on a preferred one.

TODO: Try out passing pointers to Julia WKB struct to GEOS and see if operations work without conversion?

From https://github.com/JuliaGeometry/GeometryTypes.jl/pull/166#issuecomment-461050487

> So packages that are free in their types can use the concrete implementations, and C libraries with weird stuff happening should define the interface & some conversion functions to make interop seamless, but also make it easy to directly work with the c-types (or especially C++).

A possible issue with WKB:

https://github.com/bjornharrtell/flatgeobuf#why-not-use-wkb-geometry-encoding
