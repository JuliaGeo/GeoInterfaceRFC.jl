
"""
    BoundingBox

`BoundingBox`es are, as their name suggests, containers for 
storing the bounds (`extrema`) of a (geographic) multidimensional
vector.

The dimensions are stored in the `Type` as `Symbol`s, which can be 
accessed using the field access syntax, e.g. `bb.x`. This returns
a `NamedTuple` with keys `min` and `max`, which again be accessed
in the same manner.

# Examples
```
julia> bb = BoundingBox{(:x,)}((0,),(1,))
Bounding box in 1 dimensions:
        x: min: 0       max: 1
julia> bb.x
(min = 0, max = 1)
julia> bb.x.min
0
```
"""
struct BoundingBox{N, T, Syms}
    min::NTuple{N, T}
    max::NTuple{N, T}
    BoundingBox{Syms}(min, max) where {N, T, Syms} = new{length(min), eltype(min), Syms}(min, max)
end

@inline ndim(::Type{BoundingBox{N,T,Syms}}) where {N,T,Syms} = N
@inline symnames(::Type{BoundingBox{N,T,Syms}}) where {N,T,Syms} = Syms
@inline Base.eltype(::Type{BoundingBox{N,T,Syms}}) where {N,T,Syms} = T

# Inspiration from LabelledArrays
@inline @generated function Base.getproperty(bb::BoundingBox, ::Val{s}) where s
    idx = findfirst(y->y==s, symnames(bb))
    :($idx === nothing && error("Dimension $s not found in boundingbox."); (min=bb.min[$idx], max=bb.max[$idx])::NamedTuple{(:min, :max),Tuple{eltype(bb),eltype(bb)}})
end

function Base.getproperty(bb::BoundingBox, s::Symbol)
    if s in fieldnames(typeof(bb))
        getfield(bb, s)
    else
        getproperty(bb, Val(s))
    end
end

function Base.show(io::IO, ::MIME"text/plain", bb::BoundingBox)
    println(io, "Bounding box in $(ndim(typeof(bb))) dimensions:")
    for sym in symnames(typeof(bb))
        println(io, "\t$(sym): min:\t$(getproperty(bb, sym).min)\tmax: $(getproperty(bb, sym).max)")
    end
end

# BoundingBox should behave as a Box<:Polygon type
geomtype(geom::BoundingBox{N, T, Syms}) where {N, T, Syms} = Box()
nhole(::AbstractPolygon, geom::BoundingBox{N, T, Syms}) where {N, T, Syms} = 0
ncoord(::AbstractPolygon, geom::BoundingBox{N, T, Syms}) where {N, T, Syms} = T
# getexterior(::AbstractPolygon, geom::BoundingBox{N, T, Syms}) where {N, T, Syms} = ?
