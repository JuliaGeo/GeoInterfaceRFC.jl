module GeoInterfaceRFC

include("types.jl")
include("interface.jl")
include("defaults.jl")
include("primitives.jl")

export
Point
LineString
Line
LinearRing
CircularString
CompoundCurve
CurvePolygon
Polygon
Triangle
Rectangle
Quad
Pentagon
Hexagon
PolyHedralSurface
TIN
MultiPoint
MultiCurve
MultiLineString
MultiPolygon
GeometryCollection

end # module
