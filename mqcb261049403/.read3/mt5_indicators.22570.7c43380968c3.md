Calculation: smoothed volume = selected smoother(volume, smoothing method, smoothing length, smoothing phase)
Calculation: volume-weighted oscillator = selected smoother(volume × (100 × U/(U+D) − 50), smoothing method, smoothing length, smoothing phase), where U = Σ(i=0..2) max(aᵢ − aᵢ₊₁, 0), D = Σ(i=0..2) max(aᵢ₊₁ − aᵢ, 0), a₀ = (1 − gamma) × (Bulls Power(period) + Bears Power(period)) + gamma × a₀[1], aᵢ = −gamma × aᵢ₋₁ + aᵢ₋₁[1] + gamma × aᵢ[1] for i=1..3, and U/(U+D) = 0 when U+D = 0
Long: volume-weighted oscillator > upper level 2 × smoothed volume
Long: volume-weighted oscillator ≤ upper level 2 × smoothed volume AND volume-weighted oscillator > upper level 1 × smoothed volume
Short: volume-weighted oscillator < lower level 2 × smoothed volume
Short: volume-weighted oscillator ≥ lower level 2 × smoothed volume AND volume-weighted oscillator < lower level 1 × smoothed volume