Calculation: Smoothed mean-reversion Z-score = EMA((close − EMA(close, mean lookback)) / max(sqrt(max(v, variance floor)), standard-deviation floor), smoothing lookback), where alpha = 1 − exp(−ln(2) / EWMA half-life); EWMA mean m starts at the first close and then updates as prior m + alpha × (close − prior m); d = close − m; variance v starts at d² and then updates as (1 − alpha) × prior v + alpha × d².
Calculation: Short-period EMA = EMA(selected EMA price source, short EMA lookback)
Calculation: Long-period EMA = EMA(selected EMA price source, long EMA lookback)
Calculation: Long stretch average = MA(close, selected long stretch MA type, long stretch lookback)
Calculation: Short stretch average = MA(close, selected short stretch MA type, short stretch lookback)
Calculation: Long stretch distance (%) = (long stretch average − selected long stretch price) / long stretch average × 100, where the price is close in close mode or low in wick mode.
Calculation: Short stretch distance (%) = (selected short stretch price − short stretch average) / short stretch average × 100, where the price is close in close mode or high in wick mode.
Long: Smoothed mean-reversion Z-score[1] ≤ −long weak Z threshold AND a pivot low of that score at the previous bar is confirmed using the pivot left and right lookbacks
Short: Smoothed mean-reversion Z-score[1] ≥ short weak Z threshold AND a pivot high of that score at the previous bar is confirmed using the pivot left and right lookbacks
Long: Short-period EMA crosses above long-period EMA
Short: Short-period EMA crosses below long-period EMA
Long: Long stretch average > 0 AND long stretch distance ≥ long stretch threshold
Short: Short stretch average > 0 AND short stretch distance ≥ short stretch threshold
Long: Short-period EMA crosses above long-period EMA while a long run is armed by a long mean-reversion trigger when the short-period EMA is below the long-period EMA; each such trigger starts or restarts the run, and this crossover clears it
Short: Short-period EMA crosses below long-period EMA while a short run is armed by a short mean-reversion trigger when the short-period EMA is at or above the long-period EMA; each such trigger starts or restarts the run, and this crossover clears it
Long: Stretch override is enabled AND a long run is armed by a long mean-reversion trigger when the short-period EMA is below the long-period EMA AND no stretch signal has fired in that run AND long stretch average > 0 AND long stretch distance ≥ long stretch threshold
Short: Stretch override is enabled AND a short run is armed by a short mean-reversion trigger when the short-period EMA is at or above the long-period EMA AND no stretch signal has fired in that run AND short stretch average > 0 AND short stretch distance ≥ short stretch threshold
Long: A long run remains armed after its latest long mean-reversion trigger, on a later bar while the short-period EMA is below the long-period EMA; the run clears when the short-period EMA crosses above the long-period EMA
Short: A short run remains armed after its latest short mean-reversion trigger, on a later bar while the short-period EMA is at or above the long-period EMA; the run clears when the short-period EMA crosses below the long-period EMA