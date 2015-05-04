#-------------------------------------------------------# Type and Constructors
type QuantileSGD <: OnlineStat
    q::VecF              # Quantile estimates
    τ::VecF                # tau values (which quantiles)
    n::Int64               # number of observations used
    weighting::StochasticWeighting
end

function QuantileSGD(y::VecF,
                     wgt::StochasticWeighting = StochasticWeighting();
                     τ::VecF = [.25, .5, .75],
                     start::VecF = quantile(y, τ))
    o = QuantileSGD(wgt; τ = τ, start = start)
    update!(o, y)
    o
end

function QuantileSGD(y::Float64,
                     wgt::StochasticWeighting = StochasticWeighting();
                     τ::VecF = [.25, .5, .75],
                     start::VecF = zeros(length(τ)))
    QuantileSGD([y], wgt; τ = τ, start = start)
end

function QuantileSGD(wgt::StochasticWeighting = StochasticWeighting();
                     τ::VecF = [.25, .5, .75],
                     start::VecF = zeros(length(τ)))
   QuantileSGD(start, τ, 0, wgt)
end


#-----------------------------------------------------------------------# state
statenames(o::QuantileSGD) = [:quantiles, :τ, :nobs]
state(o::QuantileSGD) = Any[copy(o.q), o.τ, nobs(o)]


#---------------------------------------------------------------------# update!
function update!(o::QuantileSGD, y::Float64)
    o.n += 1
    γ = weight(o)
    for i in 1:length(o.q)
        o.q[i] -= γ * ((y < o.q[i]) - o.τ[i])
    end
    return
end

function updatebatch!(o::QuantileSGD, y::VecF)
    o.n += length(y)
    γ = weight(o)
    for i in 1:length(o.q)
        o.q[i] -= γ * (mean(y < o.q[i]) - o.τ[i])
    end
    return
end


