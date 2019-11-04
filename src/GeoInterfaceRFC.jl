module GeoInterfaceRFC

abstract type AbstractGeometry end
struct Geometry <: AbstractGeometry end

abstract type AbstractPoint <: AbstractGeometry end
struct Point <: AbstractPoint end
abstract type AbstractLineString <: AbstractGeometry end
struct LineString <: AbstractLineString end
abstract type AbstractPolygon <: AbstractGeometry end
struct Polygon <: AbstractPolygon end

abstract type AbstractMultiPoint <: AbstractGeometry end
struct MultiPoint <: AbstractMultiPoint end
abstract type AbstractMultiLineString <: AbstractGeometry end
struct MultiLineString <: AbstractMultiLineString end
abstract type AbstractMultiPolygon <: AbstractGeometry end
struct MultiPolygon <: AbstractMultiPolygon end

abstract type AbstractGeometryCollection <: AbstractGeometry end
struct GeometryCollection <: AbstractGeometryCollection end

# All Geometries
function geomtype(x::Any)
    throw(ErrorException(string("Unknown Geometry type. ",
    "Define GeoInterface.geomtype(::$(typeof(x))) to return the desired type.")))
end
ncoord(geom::Any) = ncoord(geomtype(geom), geom)
# Point
getcoord(geom::Any, i::Integer) = getcoord(geomtype(geom), geom, i)
# LineString, MultiPoint
npoint(geom::Any) = npoint(geomtype(geom), geom)
getpoint(geom::Any, i::Integer) = getpoint(geomtype(geom), geom, i)
isclosed(geom::Any) = isclosed(geomtype(geom), geom)
# Polygon
getexterior(geom::Any) = getexterior(geomtype(geom), geom)
nhole(geom::Any) = nhole(geomtype(geom), geom)
gethole(geom::Any, i::Integer) = gethole(geomtype(geom), geom, i)
# GeometryCollection
ngeom(geom::Any) = ngeom(geomtype(geom), geom)
getgeom(geom::Any, i::Integer) = getgeom(geomtype(geom), geom, i)
# MultiLineString
nlinestring(geom::Any) = nlinestring(geomtype(geom), geom)
getlinestring(geom::Any, i::Integer) = getlinestring(geomtype(geom), geom, i)
# MultiPolygon
npolygon(geom::Any) = npolygon(geomtype(geom), geom)
getpolygon(geom::Any, i::Integer) = getpolygon(geomtype(geom), geom, i)

include("primitives.jl")

end # module
