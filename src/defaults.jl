"""Defaults for many of the interface functions are defined here as fallback."""

x(geom) = getcoord(geom, 1)
y(geom) = getcoord(geom, 2)
z(geom) = getcoord(geom, 3)

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
