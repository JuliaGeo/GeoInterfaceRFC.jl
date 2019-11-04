# GeoInterface v1.0 RFC

* Title: An Interface for Geospatial Geometries in Julia
* Author: Yeesian Ng ngyeesian@gmail.com
* Created: October 2019
* Status: **Draft** | In Review | Work In Progress | Completed
* Review Requested
    - [ ] visr
    - [ ] evetion
    - [ ] meggart
    - [ ] rafaqz
    - [ ] mkborregaard
    - [ ] SimonDanisch
    - [ ] andyferris
    - [ ] asinghvi17

# Abstract
This document describe a set of traits based on the [simple features standard](https://www.opengeospatial.org/standards/sfa)
for geospatial vector data.

# Proposal
GeoInterface provides
(a) a set of functions:
```julia
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

wellknowntext(geom)
wellknownbinary(geom)
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
```

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
GeoInterface.getexterior(polygon)::LineString
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

## Dispatching on geomtype()
As there are a wide number of methods (qualified and unqualified), for every
unqualified function call, GeoInterface dispatches to the corresponding qualified
function based on the geomtype() of the input geometry. Therefore, unqualified
function calls for geometries of undefined geomtype() will result in error.

In such cases, its `geomtype()` might be undefined, but knowledge of the data type
itself might be sufficient for the user to know which GeoInterface.jl methods
are supported for the data type. For example, a Vector{Tuple{Int,Int}} can behave
like a Polygon, LineString, or MultiPoint. In such situations, the qualified use
of GeoInterface methods should still be legal.

Here's a mock-up of an implementation:
```julia
# All Geometries
GeoInterface.ncoord(geom::Any) =
    GeoInterface.ncoord(GeoInterface.geomtype(geom), geom)
# Point
GeoInterface.getcoord(geom::Any, i::Integer) =
    GeoInterface.getcoord(GeoInterface.geomtype(geom), geom, i)
# LineString, MultiPoint
GeoInterface.npoint(geom::Any) =
    GeoInterface.npoint(GeoInterface.geomtype(geom), geom)
GeoInterface.getpoint(geom::Any, i::Integer) =
    GeoInterface.getpoint(GeoInterface.geomtype(geom), geom, i)
# Polygon
GeoInterface.getexterior(geom::Any) =
    GeoInterface.getexterior(GeoInterface.geomtype(geom), geom)
GeoInterface.nhole(geom::Any) =
    GeoInterface.nhole(GeoInterface.geomtype(geom), geom)
GeoInterface.gethole(geom::Any, i::Integer) =
    GeoInterface.gethole(GeoInterface.geomtype(geom), geom, i)
# GeometryCollection
GeoInterface.ngeom(geom::Any) =
    GeoInterface.ngeom(GeoInterface.geomtype(geom), geom)
GeoInterface.getgeom(geom::Any, i::Integer) =
    GeoInterface.getgeom(GeoInterface.geomtype(geom), geom, i)
# MultiLineString
GeoInterface.nlinestring(geom::Any) =
    GeoInterface.nlinestring(GeoInterface.geomtype(geom), geom)
GeoInterface.getlinestring(geom::Any, i::Integer) =
    GeoInterface.getlinestring(GeoInterface.geomtype(geom), geom, i)
# MultiPolygon
GeoInterface.npolygon(geom::Any) =
    GeoInterface.npolygon(GeoInterface.geomtype(geom), geom)
GeoInterface.getpolygon(geom::Any, i::Integer) =
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
* **That should implement it**: `Shapefile`, `GeoJSON`, `ArchGDAL`, `GeometryBasics`, `LibGEOS`
* **That might use it**: `GeoMakie`, `Turf` (?), `GeoTables` (?)

# Some Alternatives Considered

## A concrete set of geometries
It has never gained any traction; see the [meeting minutes](https://github.com/JuliaGeometry/meta/wiki/First-Meetup-Minutes) from the first JuliaGeometry Meetup. Some packages never had a say in the representation of their geometries if it came straight from other drivers, or are based on specifications such as GeoJSON or the ESRI Shapefile.

## A Type Hierarchy
The versions of GeoInterface until v0.4. It got some traction, but has reached its limitations. 

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