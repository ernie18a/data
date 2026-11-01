Calculation: HLM = apply three successive moving averages, each with its own configurable period and the same configurable smoothing method, to max(high - high[n-1 bars ago], 0) - max(low[n-1 bars ago] - low, 0).
Calculation: HLM signal = a moving average of HLM using the same smoothing method and its own configurable period.
Calculation: HLM and HLM signal are calculated either on the chart timeframe or on a higher timeframe using the bar still forming; comparisons with the previous HLM use the previous bar of the calculation timeframe.
Long: HLM > HLM signal
Short: HLM < HLM signal
Long: HLM > 0 AND HLM != previous HLM
Short: HLM < 0 AND HLM != previous HLM