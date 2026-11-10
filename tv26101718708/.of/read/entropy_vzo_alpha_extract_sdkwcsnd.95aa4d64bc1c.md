Calculation: Source = a selectable price series derived from the bar fields; the default is (high + low + close) / 3.
Calculation: Pressure-weighted volume oscillator = 100 × EMA(volume × clamp(0.65 × (close − open) / max(high − low, minimum price increment) + 0.35 × sign(source − previous source), −1, 1), volume-flow lookback) / max(EMA(volume, volume-flow lookback), 1). The minimum price increment is a parameter.
Calculation: Directional entropy = −(p_up × ln(p_up) + p_down × ln(p_down)) / ln(2), clamped to [0, 1], where p_up and p_down are the proportions of positive and negative close changes among nonzero close changes over the entropy lookback. A zero proportion contributes zero; if all changes are zero, entropy is 1. Missing changes count as zero.
Calculation: Fractal efficiency = clamp(abs(source − source[efficiency lookback]) / sum(abs(source[i] − source[i+1]), i = 0 to efficiency lookback − 1), 0, 1); use 0 if the denominator is 0 and treat missing changes as 0.
Calculation: Gaussian smoothing = the weighted average of the current and preceding values over its lookback, with weight exp(−0.5 × (i / max(lookback / 3, 1))²) for lag i; replace missing input values with 0.
Calculation: Oscillator = EMA(Gaussian smoothing(maximum level × tanh(clamp(sensitivity × (pressure-weighted volume oscillator − EMA(pressure-weighted volume oscillator, normalization lookback)) / max(population standard deviation of pressure-weighted volume oscillator over the normalization lookback, 0.000001) × (0.65 + clamp(0.55 × (1 − directional entropy) + 0.45 × fractal efficiency, 0.05, 1)), −12, 12)), oscillator smoothing lookback), final smoothing lookback).
Calculation: Signal = EMA(oscillator, signal lookback).
Calculation: Histogram = Gaussian smoothing(oscillator − signal, histogram smoothing lookback).
Long: oscillator > signal AND oscillator > 0
Short: oscillator < signal AND oscillator < 0
Long: histogram >= 0
Short: histogram < 0
Long: oscillator crosses above signal
Short: oscillator crosses below signal
Long: oscillator crosses above 0
Short: oscillator crosses below 0