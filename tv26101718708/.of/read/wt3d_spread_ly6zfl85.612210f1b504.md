Calculation: Spread = chart close / reference close, or chart close − reference close
Calculation: Fast oscillator = shorter-lookback dual-pole-filtered tanh of the spread’s two-bar change divided by its rolling quadratic mean; apply fast scaling and offset
Calculation: Normal oscillator = medium-lookback dual-pole-filtered tanh of the spread’s two-bar change divided by its rolling quadratic mean; apply normal scaling and offset
Calculation: Slow oscillator = longer-lookback dual-pole-filtered tanh of the spread’s two-bar change divided by its rolling quadratic mean; apply slow scaling and offset
Calculation: Emphasized oscillator = the selected fast, normal, or slow oscillator
Calculation: Longer-lookback Gaussian kernel estimate = Gaussian kernel estimate of the emphasized oscillator
Calculation: Prior bearish cross value = normal oscillator value at the previous bearish cross
Calculation: Prior bullish cross value = normal oscillator value at the previous bullish cross
Long: Fast oscillator > 0
Long: Fast oscillator crosses above normal oscillator AND normal oscillator < 0
Long: Slow oscillator crosses above 0
Long: Normal oscillator crosses above 0
Long: Fast oscillator crosses above 0
Long: Fast oscillator crosses above normal oscillator AND normal oscillator < 0 AND normal oscillator > prior bullish cross value × the configured wave-size fraction AND a previous bullish cross occurred within the configured divergence distance AND longer-lookback Gaussian kernel estimate > slow oscillator
Short: Fast oscillator < 0
Short: Fast oscillator crosses below normal oscillator AND normal oscillator > 0
Short: Slow oscillator crosses below 0
Short: Normal oscillator crosses below 0
Short: Fast oscillator crosses below 0
Short: Fast oscillator crosses below normal oscillator AND normal oscillator > 0 AND normal oscillator < prior bearish cross value × the configured wave-size fraction AND a previous bearish cross occurred within the configured divergence distance AND longer-lookback Gaussian kernel estimate < slow oscillator