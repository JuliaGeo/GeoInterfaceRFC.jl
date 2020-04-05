module GeoInterfaceRFC

abstract type AbstractGeometry end
struct Geometry <: AbstractGeometry end

abstract type AbstractPoint <: AbstractGeometry end
struct Point <: AbstractPoint end

abstract type AbstractCurve <: AbstractGeometry end
abstract type AbstractLineString <: AbstractCurve end
struct LineString <: AbstractLineString end
struct Line <: AbstractLineString end  # LineString with just two points
struct LinearRing <: AbstractLineString end  # Closed LineString

abstract type AbstractSurface <: AbstractGeometry end
abstract type AbstractPolygon <: AbstractSurface end
abstract type AbstractPolyHedralSurface <: AbstractSurface end
struct Polygon <: AbstractPolygon end
struct Triangle <: AbstractPolygon end  # Polygon with just three points
struct Box <: AbstractPolygon end  # Polygon with just 4 points
struct PolyHedralSurface <: AbstractPolyHedralSurface end
struct TIN <: AbstractPolyHedralSurface end

abstract type AbstractMultiPoint <: AbstractGeometry end
struct MultiPoint <: AbstractMultiPoint end

abstract type AbstractMultiCurve <: AbstractGeometry end
abstract type AbstractMultiLineString <: AbstractMultiCurve end
struct MultiLineString <: AbstractMultiLineString end

abstract type AbstractMultiSurface <: AbstractGeometry end
abstract type AbstractMultiPolygon <: AbstractMultiSurface end
struct MultiPolygon <: AbstractMultiPolygon end

abstract type AbstractGeometryCollection <: AbstractGeometry end
struct GeometryCollection <: AbstractGeometryCollection end

# All Geometries
function geomtype(x::T) where T
    throw(ErrorException(string("Unknown Geometry type. ",
    "Define GeoInterface.geomtype(::$(typeof(x))) to return the desired type.")))
end

# All types
ncoord(geom::T) where T = ncoord(geomtype(T), geom)
isempty(geom::T) where T = ncoord(geom) == 0 # TODO or ngeom?
issimple(geom::T) where T = issimple(geomtype(T), geom)

# Point
getcoord(geom::T, i::Integer) where T = getcoord(geomtype(T), geom, i)

# LineString, MultiPoint
npoint(geom::T) where T = npoint(geomtype(T), geom)
getpoint(geom::T, i::Integer) where T = getpoint(geomtype(T), geom, i)
# LineString
isclosed(geom::T) where T = isclosed(geomtype(T), geom)
isring(geom::T) where T = isclosed(geom) && issimple(geom)

# Polygon/Triangle
getexterior(geom::T) where T = getexterior(geomtype(T), geom)
nhole(geom::T) where T = nhole(geomtype(T), geom)  # TODO shouldn't this be interior? doesn't have to be a hole
gethole(geom::T, i::Integer) where T = gethole(geomtype(T), geom, i)

# PolyHedralSurface
npatch(geom::T) where T = npatch(geomtype(T), geom)
getpatch(geom::T, i::Integer) where T = getpatch(geomtype(T), geom, i)

# GeometryCollection
ngeom(geom::T) where T = ngeom(geomtype(T), geom)
getgeom(geom::T, i::Integer) where T = getgeom(geomtype(T), geom, i)

# MultiLineString
nlinestring(geom::T) where T = nlinestring(geomtype(T), geom)
getlinestring(geom::T, i::Integer) where T = getlinestring(geomtype(T), geom, i)

# MultiPolygon
npolygon(geom::T) where T = npolygon(geomtype(T), geom)
getpolygon(geom::T, i::Integer) where T = getpolygon(geomtype(T), geom, i)

# Other methods
crs(geom::T) where T = missing  # or conforming to <:CoordinateReferenceSystemFormat in GeoFormatTypes


include("defaults.jl")
include("primitives.jl")
include("box.jl")

end # module
