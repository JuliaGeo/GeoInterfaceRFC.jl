"""Defaults for many of the interface functions are defined here as fallback."""

# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M)

coordnames(geom) = default_coord_names[1:ncoord(geom)]

x(geom) = getcoord(geom, findfirst(coordnames(geom), :X))
y(geom) = getcoord(geom, findfirst(coordnames(geom), :Y))
z(geom) = getcoord(geom, findfirst(coordnames(geom), :Z))
m(geom) = getcoord(geom, findfirst(coordnames(geom), :M))

npoint(AbstractCurve, geom) = ngeom(AbstractCurve, geom)
getpoint(AbstractCurve, geom, i) = getgeom(AbstractCurve, geom, i)

nring(AbstractPolygon, geom) = ngeom(AbstractPolygon, geom)
getring(AbstractPolygon, geom, i) = getgeom(AbstractPolygon, geom, i)
getexterior(AbstractPolygon, geom) = getring(AbstractPolygon, geom, 1)
nhole(AbstractPolygon, geom) = nring(AbstractPolygon, geom) - 1
gethole(AbstractPolygon, geom, i) = getring(AbstractPolygon, geom, i + 1)

npoint(::Line, _) = 2
npoint(::Triangle, _) = 3
npoint(::Rectangle, _) = 4
npoint(::Quad, _) = 4
npoint(::Pentagon, _) = 5
npoint(::Hexagon, _) = 6

issimple(::AbstractCurve, geom) = allunique([getpoint(geom, i) for i in 1:npoint(geom) - 1]) && allunique([getpoint(geom, i) for i in 2:npoint(geom)])
isclosed(::AbstractCurve, geom) = getpoint(geom, 1) == getpoint(geom, npoint(geom))
isring(::AbstractCurve, geom) = issimple(::AbstractCurve, geom) && isclosed(::AbstractCurve, geom)

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(::AbstractMultiCurve, geom) = all([issimple(getgeom(geom, i)) for i in 1:ngeom(geom)])
isclosed(::AbstractMultiCurve, geom) = all([isclosed(getgeom(geom, i)) for i in 1:ngeom(geom)])

issimple(::MultiPoint, geom) = allunique([getgeom(geom, i) for i in 1:ngeom(geom)])
