# All Geometries
function geomtype(geom)
    throw(ErrorException(string("Unknown Geometry type. ",
    "Define GeoInterface.geomtype(::$(typeof(geom))) to return the desired type.")))
end

# All types
"""`ncoord(geom) -> Integer`
Return the number of coordinate dimensions (such as XYZ) for the geometry.````
"""
ncoord(geom) = ncoord(geomtype(geom), geom)

"""Return `true` when the geometry is empty."""
isempty(geom) = ngeom(geom) == 0
"""Return `true` when the geometry doesn't cross itself."""
issimple(geom) = issimple(geomtype(geom), geom)

# Point
getcoord(geom, i::Integer) = getcoord(geomtype(geom), geom, i)

# Curve, LineString, MultiPoint
npoint(geom) = npoint(geomtype(geom), geom)
getpoint(geom, i::Integer) = getpoint(geomtype(geom), geom, i)

# LineString
isclosed(geom) = isclosed(geomtype(geom), geom)
isring(geom) = isclosed(geom) && issimple(geom)
length(geom) = length(geomtype(geom), geom)

# Polygon/Triangle
nring(geom) # TODO If this is more than one, it has interior rings (holes)
getring(geom)

getexterior(geom) = getexterior(geomtype(geom), geom)  # getring(geom, 1)
nhole(geom) = nhole(geomtype(geom), geom)  # nrings - 1
gethole(geom, i::Integer) = gethole(geomtype(geom), geom, i)  # getring + 1

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


# DE-9IM, see https://en.wikipedia.org/wiki/DE-9IM
equals(a, b)::Bool = equals(geomtype(a), geomtype(b), a, b)
disjoint(a, b)::Bool = disjoint(geomtype(a), geomtype(b), a, b)
touches(a, b)::Bool = touches(geomtype(a), geomtype(b), a, b)
within(a, b)::Bool = within(geomtype(a), geomtype(b), a, b)
overlaps(a, b)::Bool = overlaps(geomtype(a), geomtype(b), a, b)
crosses(a, b)::Bool = crosses(geomtype(a), geomtype(b), a, b)
intersects(a, b)::Bool = intersects(geomtype(a), geomtype(b), a, b)
contains(a, b)::Bool = contains(geomtype(a), geomtype(b), a, b)
relate(a, b)::Bool = relate(geomtype(a), geomtype(b), a, b)

# Set theory
boundary(geom)
centroid(geom)
difference(a, b, inverse = false)
intersection(a, b, inverse = false)
