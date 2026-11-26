Calculation: Trend quality = the selected Efficiency Ratio(source, lookback), clamped 0–1; clamped 2 − Fractal Dimension Index(high, low, lookback); or their average.
Calculation: Volatility-cluster z-score = z-score over its normalization lookback of an intensity updated each bar as prior intensity × exp(−decay) + abs(change(log(close))).
Calculation: Regime = Trend when ADX(lookback) exceeds its trend threshold and trend quality exceeds its trend threshold; otherwise Volatile when volatility-cluster z-score exceeds its threshold; otherwise Range. Trend thresholds are either parameters or the respective rolling percentiles over the calibration lookback.
Calculation: Trend direction = bullish when close > EMA(close, lookback), otherwise bearish.
Calculation: Primary ATR length = fixed ATR lookback when cycle adaptation is off; otherwise select from the ATR-length ladder using the rounded, bounded product of Ehlers dominant cycle period and its length factor.
Calculation: Primary multiplier = clamp(base multiplier × volatility-rank factor × chop factor × path factor, multiplier floor, multiplier cap). The base multiplier is either its parameter or, when online tuning is enabled, the candidate with the best short-lived-reversal score after the minimum flip count; plateau scoring, when enabled, uses neighboring candidate mean minus its penalty times their standard deviation. The volatility-rank factor, when enabled, interpolates between its low and high scales using the percentile rank of ATR over its lookback. The chop factor, when enabled, is 1 + chop strength × (1 − trend quality). The path factor, when enabled, blends 1 with the clamped sum of sqrt(EMA(source change squared, fast lookback) / EMA(source change squared, slow lookback)), the leverage contribution from negative EMA(source change, fast lookback) / primary ATR, and the convexity contribution from positive EMA(source change, fast lookback) / primary ATR.
Calculation: Primary Supertrend = Supertrend(price source, primary multiplier, primary ATR length).
Calculation: Secondary Supertrend = Supertrend(price source, secondary multiplier, secondary ATR length).
Calculation: Higher-timeframe Supertrend directions = Supertrend direction(factor, ATR lookback, T1), Supertrend direction(factor, ATR lookback, T2), and Supertrend direction(factor, ATR lookback, T3), each using the last completed bar and evaluated on chart bars using those values. Higher-timeframe agreement is the counts of bullish and bearish directions among the three.
Calculation: Volume delta per bar = on chart bars, sum the available intrabars from T4 using either volume × (2 × normalCDF(close change / stdev(close change, lookback)) − 1) or volume × sign(close − open); if no intrabars are available, use the same selected formula on chart bars.
Calculation: Volume-delta direction = sign(cumulative volume delta − cumulative volume delta[lookback]).
Calculation: Volume thrust = true when volume data is unavailable; otherwise volume > SMA(volume, lookback) × thrust factor.
Calculation: Volatility-index z-score = (volatility-index level − SMA(level, lookback)) / stdev(level, lookback), or zero when unavailable or stdev is zero.
Calculation: Cross-asset momentum = sign((cross-asset close − cross-asset close[lookback]) × sign parameter), or zero when unavailable.
Calculation: Confirmation breach threshold = the selected percentile of prior confirmed flip breaches, once the minimum sample is available; otherwise the breach threshold parameter. Minimum wait = rounded dominant cycle period × its factor, bounded by its limits, when adaptive mode is enabled; otherwise the minimum-bars parameter.
Calculation: Conviction = round(clamp(100 × weighted mean of regime alignment, higher-timeframe aligned fraction, clamped primary-band clearance / clearance scale, trend quality, volume-delta alignment, and cross-asset alignment, 0, 100)). Regime alignment scores trend-aligned, trend-opposed, Range, and Volatile separately; missing cross-asset data has its own score. Use neutral higher-timeframe and cross-asset scores when those feeds are disabled or unavailable. Each component has its own weight.
Calculation: Flip strength = round(clamp(the weighted sum of clamped confirmed-band breach / primary ATR, ADX / its strength scale, trend quality, higher-timeframe aligned fraction, regime alignment, volume thrust, volume-delta alignment, and secondary-Supertrend alignment, 0, 100)). Each component has its own weight and score factors; disabled higher-timeframe agreement and secondary Supertrend use their configured neutral factors.
Calculation: Effective minimum flip strength = the manual minimum, or, when auto-learning is enabled and its minimum flip count is met, the lowest strength-bin cutoff whose qualifying flips meet the target hold rate. A flip holds when its favorable high or low excursion within the evaluation window reaches the favorable ATR target; the auto cutoff also requires its minimum outcome sample.
Calculation: Flip veto = enabled volatility-index spike veto OR enabled all-higher-timeframes-opposed veto OR enabled Range/Volatile-regime veto OR available cross-asset momentum opposing the flip direction.
Long: Primary Supertrend direction is bullish.
Short: Primary Supertrend direction is bearish.
Long: Primary Supertrend direction changes from bearish to bullish and the flip is not confirmed.
Short: Primary Supertrend direction changes from bullish to bearish and the flip is not confirmed.
Long: Primary Supertrend direction changes from bearish to bullish, close breaches the prior upper band by at least the confirmation breach threshold × primary ATR, bars since the prior confirmed flip meet the minimum wait, and the bar is confirmed when close confirmation is enabled.
Short: Primary Supertrend direction changes from bullish to bearish, close breaches below the prior lower band by at least the confirmation breach threshold × primary ATR, bars since the prior confirmed flip meet the minimum wait, and the bar is confirmed when close confirmation is enabled.
Long: Confirmed bullish primary flip AND conviction ≥ minimum conviction AND NOT flip veto.
Short: Confirmed bearish primary flip AND conviction ≥ minimum conviction AND NOT flip veto.
Long: Confirmed bullish primary flip AND conviction ≥ minimum conviction AND flip strength ≥ effective minimum flip strength AND NOT flip veto.
Short: Confirmed bearish primary flip AND conviction ≥ minimum conviction AND flip strength ≥ effective minimum flip strength AND NOT flip veto.
Long: Regime is Trend AND trend direction is bullish.
Short: Regime is Trend AND trend direction is bearish.
Long: Secondary Supertrend direction is bullish.
Short: Secondary Supertrend direction is bearish.
Long: Secondary Supertrend direction changes from bearish to bullish.
Short: Secondary Supertrend direction changes from bullish to bearish.
Exit: long, Primary Supertrend direction changes from bullish to bearish.
Exit: short, Primary Supertrend direction changes from bearish to bullish.