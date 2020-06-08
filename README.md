# GeoInterfaceRFC
An interface for geospatial vector data in Julia

This Package describe a set of traits based on the [Simple Features standard (SF)](https://www.opengeospatial.org/standards/sfa)
for geospatial vector data, including the SQL/MM extension with support for circular geometry. 

Packages which support the GeoInterfaceRFC.jl interface can be found in [INTEGRATIONS.md](INTEGRATIONS.md).

## Changes with respect to SF
While we try to adhere to SF, there are changes and extensions to make it more Julian.

### Function names
All function names are without the `ST_` prefix and are lowercased. In some cases the names have changed as well, to be inline with common Julia functions. `NumX` becomes `nx` and `Xn` becomes `getX`:
```julia
GeometryType -> geomtype
NumGeometries -> ngeom
GeometryN -> getgeom
NumPatches -> npatch
# etc
```

We also simplified the dimension functions. From the three original (`dimension`, `coordinateDimension`, `spatialDimension`) there's now only the coordinate dimension, so not to overlap with the Julia `ndims`.
```julia
coordinateDimension -> ncoords
```

We've generalized the some functions:
```julia
SRID -> crs
envelope -> extent
```

And added a helper method to clarify the naming of coordinates.
```julia
coordnames = (:X, :Y, :Z, :M)
```

### Coverage
Not all SF functions are implemented, either as a possibly slower fallback or empty descriptor or not at all. The following SF functions are not (yet) available.

```julia
dimension
spatialDimension
asText
asBinary
is3D
isMeasured
boundary

locateAlong
locateBetween

distance
buffer
convexHull
intersection
union
difference
symDifference
```
While the following functions have no implementation:
```julia
equals
disjoint
touches
within
overlaps
crosses
intersects
contains
relate
```


## Implementation
GeoInterface provides a traits interface, not unlike Tables.jl, by 

(a) a set of functions: 
```julia
geomtype(geom)
ncoord(geom)
ngeom(geom)
getgeom(geom, i)
...
```
(b) a set of types for dispatching on said functions.
 The types tells GeoInterface how to interpret the input object inside a GeoInterface function.

```julia
abstract Geometry
Point <: AbstractPoint <: AbstractGeometry
MultiPoint <: AbstractMultiPointGeometry <:AbstractGeometryCollection <: AbstractGeometry
...
```

(c) implementation for AbstractVectors and Tuples

### For developers looking to implement the interface
GeoInterface requires five functions to be defined for a given geom:

```julia
GeoInterface.geomtype(geom)::DataType = GeoInterface.X()
GeoInterface.ncoord(geom)::Integer
GeoInterface.getcoord(geom, i)::Real  # for Points
GeoInterface.ngeom(geom)::Integer
GeoInterface.getgeom(geom, i)  # geomtype -> GeoInterface.Y
```
Where the `getgeom` could be an iterator (without the i) as well. It will return a new geom with the correct `geomtype`.

There are also optional generic methods that could help or speed up operations:
```julia
GeoInterface.crs(geom)::Union{Missing, GeoFormatTypes.CoordinateReferenceSystemFormat}
GeoInterface.extent(geom)  # geomtype -> GeoInterface.Rectangle
```

And lastly, there are many other optional functions for each specific geometry. GeoInterface provides fallback implementations based on the generic functions above, but these are not optimized. These are detailed in the next chapter.

### Examples

A `geom` with "Point"-like traits implements
```julia
GeoInterface.geomtype(geom)::DataType = GeoInterface.Point
GeoInterface.ncoord(GeoInterface.Point, geom)::Integer
GeoInterface.getcoord(GeoInterface.Point, geom, i)::Real

# Defaults
GeoInterface.ngeom(GeoInterface.Point, geom)::Integer = 0
GeoInterface.getgeom(GeoInterface.Point, geom, i) = nothing
```

A `geom` with "LineString"-like traits implements the following methods:
```julia
GeoInterface.geomtype(geom)::DataType = GeoInterface.LineString
GeoInterface.ncoord(GeoInterface.LineString, geom)::Integer
GeoInterface.ngeom(GeoInterface.LineString, geom)::Integer
GeoInterface.getgeom(GeoInterface.LineString, geom, i) # of geomtype Point

# Optional
GeoInterface.isclosed(linestring)::Bool
GeoInterface.issimple(linestring)::Bool
GeoInterface.length(linestring)::Real
```
A geom with "Polygon"-like traits can implement the following methods:
```julia
# 
GeoInterface.getexterior(polygon)::"LineString"
GeoInterface.nhole(polygon)::Integer
GeoInterface.gethole(polygon, i)::"LineString"
GeoInterface.area(polygon)::Real
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

### Testing the interface
GeoInterface provides a Testsuite for a geom type to check whether all functions that have been implemented also work as expected.

```julia
GeoInterface.test_interface_for_geom(geom)
```
