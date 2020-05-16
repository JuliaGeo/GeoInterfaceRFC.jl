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
function geomtype(geom)
    throw(ErrorException(string("Unknown Geometry type. ",
    "Define GeoInterface.geomtype(::$(typeof(x))) to return the desired type.")))
end

# All types
ncoord(geom) = ncoord(geomtype(geom), geom)
isempty(geom) = ncoord(geom) == 0 # TODO or ngeom?
issimple(geom) = issimple(geomtype(geom), geom)

# Point
getcoord(geom, i::Integer) = getcoord(geomtype(geom), geom, i)

# LineString, MultiPoint
npoint(geom) = npoint(geomtype(geom), geom)
getpoint(geom, i::Integer) = getpoint(geomtype(geom), geom, i)
# LineString
isclosed(geom) = isclosed(geomtype(geom), geom)
isring(geom) = isclosed(geom) && issimple(geom)

# Polygon/Triangle
getexterior(geom) = getexterior(geomtype(geom), geom)
nhole(geom) = nhole(geomtype(geom), geom)  # TODO shouldn't this be interior? doesn't have to be a hole
gethole(geom, i::Integer) = gethole(geomtype(geom), geom, i)

# PolyHedralSurface
npatch(geom) = npatch(geomtype(geom), geom)
getpatch(geom, i::Integer) = getpatch(geomtype(geom), geom, i)

# GeometryCollection
ngeom(geom) = ngeom(geomtype(geom), geom)
getgeom(geom, i::Integer) = getgeom(geomtype(geom), geom, i)

# MultiLineString
nlinestring(geom) = nlinestring(geomtype(geom), geom)
getlinestring(geom, i::Integer) = getlinestring(geomtype(geom), geom, i)

# MultiPolygon
npolygon(geom) = npolygon(geomtype(geom), geom)
getpolygon(geom, i::Integer) = getpolygon(geomtype(geom), geom, i)

# Other methods
crs(geom) = missing  # or conforming to <:CoordinateReferenceSystemFormat in GeoFormatTypes


include("defaults.jl")
include("primitives.jl")
include("box.jl")

end # module
