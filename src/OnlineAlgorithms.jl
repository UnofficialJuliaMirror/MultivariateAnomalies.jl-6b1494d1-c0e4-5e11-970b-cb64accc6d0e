# Online Outlier Detection
"""
    Euclidean_distance!{tp}(d::Array{tp, 1}, x::AbstractArray{tp, 2}, i::Int, j::Int, dim::Int = 1)

compute the Euclidean distance between x[i,:] and x[j,:] and write the result to d. Memory efficient. dim is the dimension of i and j.
"""

function Euclidean_distance!{tp}(d::Array{tp, 1}, x::AbstractArray{tp, 2}, i::Int, j::Int, dim::Int = 1)
  d[1] = 0.0
  if dim == 2
    for v = 1:size(x, 1)
      d[1] = d[1] + (x[v, i] - x[v, j]) * (x[v, i] - x[v, j])
    end
  else
    for v = 1:size(x, 2)
      d[1] = d[1] + (x[i, v] - x[j, v]) * (x[i, v] - x[j, v])
    end
  end
  d[1] = sqrt(d[1])
  return d
end

"""
    KDEonline!{tp}(kdescores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, σ::tp, dim::Int = 1)

compute (1.0 - Kernel Density Estimates) from x and write it to kdescores with dim being the dimension of the observations.
"""

function KDEonline!{tp}(k::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, i::Int, σ::tp, dim::Int = 1)
  k[1] = 0.0
  for j = 1:size(x, dim)
    Euclidean_distance!(d, x, i, j, dim)
    innerKDEonline!(k, d, σ)
  end
  finalizeKDEonline!(k, x, dim)
  return k
end

function innerKDEonline!{tp}(k::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, σ::tp)
  k[1] = k[1] + exp(-0.5 * d[1] / σ^2)
  return k
end

function finalizeKDEonline!{tp}(k::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, dim::Int)
  k[1] = 1.0 - (k[1] / size(x, dim))
  return k
end

function KDEonline!{tp}(kdescores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, σ::tp, dim::Int = 1)
  d = zeros(tp, 1)
  k = zeros(tp, 1)
  for i = 1:size(x, dim)
    KDEonline!(k, d, x, i, σ, dim)
    kdescores[i] = k[1]
  end
  return kdescores
end

"""
    REConline!{tp}(recscores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, ɛ::tp, dim::Int = 1)

compute recurrence scores from x and write it to recscores with dim being the dimension of the observations.
"""

function REConline!{tp}(r::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, i::Int, ɛ::tp, dim::Int = 1)
    r[1] = 0.0
    for j = 1:size(x, dim)
      Euclidean_distance!(d, x, i, j, dim)
      innerREConline!(r, d, ɛ)
    end
    finalizeREConline!(r, x, dim)
    return r
end

function innerREConline!{tp}(r::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, ɛ::tp)
  if d[1] <= ɛ
    r[1] = r[1] + 1.0
  end
  return r
end

function finalizeREConline!{tp}(r::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, dim::Int)
  r[1] = 1.0 - (r[1] / size(x, dim))
  return r
end

function REConline!{tp}(recscores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, ɛ::tp, dim::Int = 1)
  d = zeros(tp, 1)
  r = zeros(tp, 1)
  for i = 1:size(x, dim)
    REConline!(r, d, x, i, ɛ, dim)
    recscores[i] = r[1]
  end
  return recscores
end

"""
    KNNonline!{tp}(knnscores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, k::Int, dim::Int = 1)

compute k-nearest neighbor (gamma) scores from x and write it to knnscores with dim being the dimension of the observations.
"""

function KNNonline!{tp}(knn::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, i::Int, k::Int, dim::Int = 1)
  if size(knn, 1) != k+1 error("size knn != k+1") end
  for l = 1:length(knn)
    knn[l] = 1.0e30#typemax(tp)
  end
  for j = 1:size(x, dim)
    Euclidean_distance!(d, x, i, j, dim)
    innerKNNonline!(knn, d, k)
  end
  finalizeKNNonline!(knn, k)
  return knn
end

function KNNonline!{tp}(knnscores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, k::Int, dim::Int = 1)
  d = zeros(tp, 1)
  knn = fill(typemax(tp), k+1)
  for i = 1:size(x, dim)
    KNNonline!(knn, d, x, i, k, dim)
    knnscores[i] = knn[1] #mean(knn[2:k+1]) --> in finalize
  end
  return knnscores
end

function innerKNNonline!{tp}(knn::AbstractArray{tp, 1}, d::AbstractArray{tp, 1}, k::Int)
    if d[1] <= knn[1]
      for kshift = (k+1):-1:2
        knn[kshift] = knn[kshift-1] # shift old one to k+1
      end
      knn[1] = d[1]   # replace by new distance
    else
      for j = 2:(k+1)
        if d[1] > knn[j-1] && d[1] <= knn[j]
          for kshift = k+1:-1:j
            knn[kshift] = knn[kshift-1] # shift old one to k+1
          end
          knn[j] = d[1]     # replace by new distance
        end
      end
    end
  return knn
end

function finalizeKNNonline!{tp}(knn::AbstractArray{tp, 1}, k::Int)
  knn[1] = 0.0
  for i = 2:(k+1)
    knn[1] = knn[1] + knn[i]
  end
  knn[1] = knn[1] / k
  return knn
end

"""
    KDEonline_withNearDistskipping!{tp}(kdescores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, σ::tp, init_sample::Int = 100, dim::Int = 1)

compute (1.0 - Kernel Density Estimates) from `x` and write it to kdescores with `dim` being the dimension of the observations.
Precomputes distances to `init_sample` randomly sampled points. New distance computation is omitted in cases
when the distance to the precomputed random samples is small. However, in low density regions the distance is always comuted.
Faster performance than KDEonline() for more than 2000 observations.
"""

function KDEonline_withNearDistskipping!{tp}(kdescores::AbstractArray{tp, 1}, x::AbstractArray{tp, 2}, σ::tp, init_sample::Int = 100, dim::Int = 1)
  for n = 1:length(kdescores)
    kdescores[n] = 0.0
  end
  k = zeros(tp, 1)
  d = zeros(tp, 1)
  d_small = fill(typemax(tp), 1)
  scalethres = 1.0/3.0#3.0/10.0
  similardistthres = σ * scalethres
  lowdensitythres = (1- exp(-0.5/σ) ) * 1.05# / scalethres
  initidxs = rand(1:size(x, dim), init_sample)
  # initdists = zeros(Float64, 100)
  # compute some initial scores
  for iinits = 1:size(initidxs, 1)
    idx = initidxs[iinits]
    KDEonline!(k, d, x, idx, σ, dim)
    kdescores[idx] = k[1]
  end
  # skip scores computation if the kde distance to already computed points is small
  for i = 1:size(x, dim)
    d_small[1] = typemax(tp)
    for iinits = 1:size(initidxs, 1)
      #if kdescores[i] == 0.0
        idx = initidxs[iinits]
        Euclidean_distance!(d, x, i, idx, dim)
        if d[1] < similardistthres #&& kdescores[idx] < lowdensitythres
          if d[1] < d_small[1]
            d_small[1] = d[1]
            kdescores[i] = kdescores[idx] # approximately
          end
        end
    end
    # d is never smaller than similardistthres
    if kdescores[i] == 0.0 || kdescores[i] > lowdensitythres
      KDEonline!(k, d, x, i, σ, dim) # kde for all j
      kdescores[i] = k[1]
    end
  end
  return kdescores
end

"""
    SigmaOnline!{tp}(sigma::Array{tp, 1}, x::AbstractArray{tp, 2}, samplesize::Int = 250, dim::Int = 1)

compute `sigma` parameter as mean of the distances of `samplesize` randomly sampled points along `dim`.
"""

function SigmaOnline!{tp}(sigma::Array{tp, 1}, x::AbstractArray{tp, 2}, samplesize::Int = 250, dim::Int = 1)
  sigma[1] = 0.0
  d = zeros(tp, 1)
  trainsample1 = zeros(Int, 1)
  trainsample2 = zeros(Int, 1)
  for i = 1:samplesize
    rand!(trainsample1, 1:size(x, dim))[1]
    for j = 1:samplesize
      if j > i
        Euclidean_distance!(d, x, trainsample1[1], rand!(trainsample2, 1:size(x, dim))[1], dim)
        # sum of distances
        sigma[1] = sigma[1] + d[1]
      end
    end
  end
  # get mean
  sigma[1] = sigma[1] / (samplesize^2 / 2 - samplesize / 2)
  return sigma
end
