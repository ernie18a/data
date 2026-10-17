# Daubechies D4 Denoising [LB]

- url: https://www.tradingview.com/script/ATIYcEeR/
- type: indicator
- pine_id: PUB;6616b55b917f4f44a5d940cf1c13a6d9
- version: 1.0

## Description

[b]Concept[/b]
The Daubechies D4 Wavelet Denoising indicator applies a multi‑level discrete wavelet transform using the compactly supported Daubechies D4 wavelet (Ingrid Daubechies, 1992) combined with Donoho's universal threshold (Donoho & Johnstone, 1994). It separates price into approximation (trend) and detail (noise) coefficients, attenuates noise via soft thresholding, and reconstructs a denoised price curve that directly overlays the chart.

[b]Mathematical Foundation[/b]
The Daubechies D4 wavelet is defined by four scaling coefficients [i]h[/i] and four wavelet coefficients [i]g[/i], forming quadrature mirror filters that satisfy perfect reconstruction. At each level, the input array [i]a[/i] is circularly convolved with [i]h[/i] and [i]g[/i], then downsampled by two to produce the approximation [i]a'[/i] and detail [i]d'[/i] :

[i]a'[k] = SUM_m h[m] * a[2k - m][/i]
[i]d'[k] = SUM_m g[m] * a[2k - m][/i]

This process is iterated [i]J[/i] times. The universal threshold [i]lambda[/i] is estimated for each detail array independently using the median absolute deviation (MAD) of the coefficients :

[i]sigma = MAD / 0.6745[/i]
[i]lambda = sigma * sqrt(2 * log N)[/i]

Soft thresholding is then applied to each detail coefficient [i]x[/i] :

[i]threshold(x) = sign(x) * max(|x| - lambda, 0)[/i]

Finally, the denoised signal is reconstructed by upsampling, convolution with synthesis filters, and summation of approximation and detail contributions.

[b]What Problem Does It Solve ?[/b]
Classical moving averages and low‑pass filters eliminate noise at the cost of significant lag and do not adapt to the local structure of the data. The Daubechies D4 wavelet denoising preserves sharp transitions (edges) while removing high‑frequency noise, offering a lag‑free, adaptive smoothing that respects the multi‑scale nature of price action.

[b]How To Interpret[/b]
[i]Denoised line above price[/i] – the smoothed trend is stronger than the current raw price; underlying momentum remains positive despite transient dips.
[i]Denoised line below price[/i] – the smoothed trend is weaker; price is correcting within a larger structure.
[i]Denoised line flattening or changing direction[/i] – a regime shift may be underway; the multi‑scale trend is losing or gaining momentum.

[b]Parameters[/b]
[b]Source[/b] – price field to denoise (default close).
[b]Decomposition Levels[/b] – number of wavelet decomposition iterations. Higher levels remove lower‑frequency components, producing a smoother but more slowly reacting line.
[b]Window Length (power of 2)[/b] – analysis window size. Must be a power of two for the dyadic decomposition; the indicator automatically adjusts to the largest valid power of two if an invalid value is entered.

[b]Reference[/b]
Daubechies I., "Ten Lectures on Wavelets", Society for Industrial and Applied Mathematics, 1992.
Donoho D.L. & Johnstone I.M., "Ideal Spatial Adaptation by Wavelet Shrinkage", Biometrika, Vol. 81, No. 3, pp. 425‑455, 1994.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// INDICATOR : Daubechies D4 Wavelet Denoising
// Concept  : Multi‑level Daubechies D4 discrete wavelet transform
//            with soft thresholding of detail coefficients
//            (Donoho universal threshold). Outputs a denoised
//            price curve overlaid on the chart.
// Author   : Luis Barlier
// Style    : Minimalistic – one smoothed line overlaid on price.
// ═══════════════════════════════════════════════════════════════
indicator("Daubechies D4 Denoising [LB]", overlay=true, precision=4)


// ── PARAMETERS ────────────────────────────────────────────
src       = input.source(close, "Source")
numLevels = input.int(3, "Decomposition Levels", minval=1, maxval=5,
              tooltip="Number of wavelet decomposition levels")
winLen    = input.int(64, "Window Length (power of 2)", minval=8, maxval=256,
              tooltip="Must be a power of 2 (e.g., 64, 128)")


// ── POWER OF TWO CHECK & ADJUSTMENT ──────────────────────
isPowerOfTwo(n) =>
    result = false
    if n > 0
        temp = n
        while temp % 2 == 0
            temp := temp / 2
        result := temp == 1
    result


actualWindow = 0
if isPowerOfTwo(winLen)
    actualWindow := winLen
else
    // find the largest power of two <= winLen
    actualWindow := 2
    while actualWindow * 2 <= winLen
        actualWindow := actualWindow * 2


// ── DAUBECHIES D4 COEFFICIENTS ───────────────────────────
h0 = 0.4829629131445341
h1 = 0.8365163037378079
h2 = 0.2241438680420134
h3 = -0.1294095225512604


// Low‑pass (scaling) and high‑pass (wavelet) analysis filters
h = array.new_float(4)
array.set(h, 0, h0)
array.set(h, 1, h1)
array.set(h, 2, h2)
array.set(h, 3, h3)


g = array.new_float(4)
array.set(g, 0,  h3)        //  g0 =  h3
array.set(g, 1, -h2)        //  g1 = -h2
array.set(g, 2,  h1)        //  g2 =  h1
array.set(g, 3, -h0)        //  g3 = -h0


// Synthesis filters (time‑reversed)
hS = array.new_float(4)
array.set(hS, 0, h3)
array.set(hS, 1, h2)
array.set(hS, 2, h1)
array.set(hS, 3, h0)


gS = array.new_float(4)
array.set(gS, 0, array.get(g, 3))
array.set(gS, 1, array.get(g, 2))
array.set(gS, 2, array.get(g, 1))
array.set(gS, 3, array.get(g, 0))


// ── CIRCULAR CONVOLUTION WITH DOWNSAMPLING ───────────────
circConvDownsample(arr, filt) =>
    N = array.size(arr)
    L = array.size(filt)
    M = N / 2
    out = array.new_float(M)
    for k = 0 to M - 1
        sum = 0.0
        for m = 0 to L - 1
            idx = (2 * k - m) % N
            if idx < 0
                idx += N
            sum += array.get(filt, m) * array.get(arr, idx)
        array.set(out, k, sum)
    out


// ── UPSAMPLING + CIRCULAR CONVOLUTION (SYNTHESIS) ────────
circConvUpsample(arr, filt) =>
    N = array.size(arr)
    L = array.size(filt)
    M = 2 * N
    up = array.new_float(M)
    for i = 0 to N - 1
        array.set(up, 2 * i, array.get(arr, i))
        array.set(up, 2 * i + 1, 0.0)
    out = array.new_float(M)
    for k = 0 to M - 1
        sum = 0.0
        for m = 0 to L - 1
            idx = (k - m) % M
            if idx < 0
                idx += M
            sum += array.get(filt, m) * array.get(up, idx)
        array.set(out, k, sum)
    out


// ── TYPE FOR DECOMPOSITION RESULTS ───────────────────────
type DWTResult
    array<float> approx
    array<float> d1
    array<float> d2
    array<float> d3
    array<float> d4
    array<float> d5


// ── FORWARD DWT ──────────────────────────────────────────
dwtForward(data, levels) =>
    current = array.copy(data)
    d1 = array.new_float()
    d2 = array.new_float()
    d3 = array.new_float()
    d4 = array.new_float()
    d5 = array.new_float()
    for lev = 1 to levels
        detail = circConvDownsample(current, g)
        approx = circConvDownsample(current, h)
        if lev == 1
            d1 := detail
        else if lev == 2
            d2 := detail
        else if lev == 3
            d3 := detail
        else if lev == 4
            d4 := detail
        else if lev == 5
            d5 := detail
        current := approx
    DWTResult.new(current, d1, d2, d3, d4, d5)


// ── DONOHO UNIVERSAL THRESHOLD ───────────────────────────
donohoThreshold(detailCoeffs) =>
    N = array.size(detailCoeffs)
    float thresh = 0.0
    if N > 0
        absVals = array.new_float(N)
        for i = 0 to N - 1
            array.set(absVals, i, math.abs(array.get(detailCoeffs, i)))
        sorted = array.copy(absVals)
        array.sort(sorted)
        float median = 0.0
        if N % 2 == 1
            median := array.get(sorted, (N - 1) / 2)
        else
            median := (array.get(sorted, N / 2 - 1) + array.get(sorted, N / 2)) / 2.0
        float sigma = median / 0.6745
        thresh := sigma * math.sqrt(2.0 * math.log(N))
    thresh


// ── SOFT THRESHOLDING ────────────────────────────────────
softThreshold(value, thresh) =>
    float result = 0.0
    if math.abs(value) <= thresh
        result := 0.0
    else if value > 0
        result := value - thresh
    else
        result := value + thresh
    result


// ── APPLY THRESHOLD TO AN ARRAY ──────────────────────────
thresholdArray(arr) =>
    if array.size(arr) > 0
        thresh = donohoThreshold(arr)
        for i = 0 to array.size(arr) - 1
            array.set(arr, i, softThreshold(array.get(arr, i), thresh))


// ── INVERSE DWT (RECONSTRUCTION) ─────────────────────────
dwtInverse(result, levels) =>
    current = array.copy(result.approx)
    lev = levels - 1
    while lev >= 0
        array<float> det = array.new_float()
        if lev == 0
            det := result.d1
        else if lev == 1
            det := result.d2
        else if lev == 2
            det := result.d3
        else if lev == 3
            det := result.d4
        else if lev == 4
            det := result.d5
        // Reconstruction: upsample + convolution + sum
        partApprox = circConvUpsample(current, hS)
        partDetail = circConvUpsample(det, gS)
        sumArr = array.new_float(array.size(partApprox))
        for i = 0 to array.size(partApprox) - 1
            array.set(sumArr, i, array.get(partApprox, i) + array.get(partDetail, i))
        current := sumArr
        lev -= 1
    current


// ── MAIN COMPUTATION ─────────────────────────────────────
float denoised = na


if bar_index >= actualWindow - 1
    // Build data array (oldest at index 0)
    data = array.new_float()
    for i = 0 to actualWindow - 1
        array.push(data, src[actualWindow - 1 - i])
    
    // Forward DWT
    dwtRes = dwtForward(data, numLevels)
    
    // Threshold all detail levels
    thresholdArray(dwtRes.d1)
    thresholdArray(dwtRes.d2)
    thresholdArray(dwtRes.d3)
    thresholdArray(dwtRes.d4)
    thresholdArray(dwtRes.d5)
    
    // Inverse DWT
    recon = dwtInverse(dwtRes, numLevels)
    
    // The denoised value for the current bar is the last element
    if array.size(recon) > 0
        denoised := array.get(recon, array.size(recon) - 1)


// ── OUTPUT ───────────────────────────────────────────────
plot(denoised, "Denoised", color=color.new(#00bcd4, 0), linewidth=2)
````
