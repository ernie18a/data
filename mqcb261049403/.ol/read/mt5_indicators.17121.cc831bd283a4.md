Calculation: Fractal dimension = 1 + ln(2 × sum over adjacent pairs of sqrt((normalized price change)^2 + 1/lookback^2)) / ln(2 × (lookback − 1)); normalize each selected-price value in the lookback window as (value − window low) / (window high − window low).
Calculation: Adaptive period = round(normal period / (2 × (2 − fractal dimension))).
Calculation: Fractal RSI = RSI over the adaptive period, using the selected price series and simple average gains and losses.
Calculation: Fractal MFI = 100 × positive money flow / (positive + negative money flow) over the adaptive period; for each step back, compare consecutive selected prices and add volume × the higher step's price to positive flow or volume × the lower step's price to negative flow. Use tick volume or real volume as selected.
Calculation: Fractal Williams %R = −100 × (highest high − selected price) / (highest high − lowest low) over the adaptive period.
Calculation: Fractal DeMarker = average upward high changes / (average upward high changes + average downward low changes) over the adaptive period.
Calculation: Fractal weighted oscillator = smooth the weighted mean of Fractal RSI, Fractal MFI, Fractal Williams %R + 100, and 100 × Fractal DeMarker; weights are configurable. The chart-timeframe version uses the current chart bar. The higher-timeframe version uses the selected same-or-higher timeframe's bar still forming and carries its value across chart bars.
Long: Fractal weighted oscillator > 50
Short: Fractal weighted oscillator < 50