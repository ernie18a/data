Calculation: bar range = max(high − low, minimum tick)
Calculation: body ratio = abs(close − open) / bar range, clipped to the body-ratio bounds
Calculation: close position = (close − low) / bar range, clipped to the close-position bounds
Calculation: upper wick ratio = max(high − max(open, close), zero) / bar range
Calculation: lower wick ratio = max(min(open, close) − low, zero) / bar range
Calculation: range expansion = bar range / SMA(bar range, normalization lookback), clipped to the expansion bounds
Calculation: phase line = HMA(hlc3, phase lookback)
Calculation: phase slope = phase line − phase line[phase slope lag]
Calculation: safe ATR = max(ATR(ATR lookback), minimum tick)
Calculation: normalized phase slope = phase slope / safe ATR
Calculation: phase distance = (close − phase line) / safe ATR
Calculation: momentum change = (EMA(change(close), momentum lookback) / safe ATR) − (EMA(change(close), momentum lookback) / safe ATR)[previous bar]
Calculation: DI pressure change = current ((+DI − −DI) / max(+DI + −DI, DI-sum floor)) − its previous-bar value; +DI, −DI, and ADX use DMI(DI lookback, ADX smoothing)
Calculation: bullish raw pressure = bullish bar ? body ratio × bullish-body weight : zero, plus close position × close-position weight, plus max(wick pressure, zero) × wick weight, plus max(range expansion − expansion baseline, zero) × expansion weight; wick pressure = (lower wick ratio − upper wick ratio) clipped to wick-pressure bounds
Calculation: bearish raw pressure = bearish bar ? body ratio × bearish-body weight : zero, plus (one − close position) × close-position weight, plus max(−wick pressure, zero) × wick weight, plus max(range expansion − expansion baseline, zero) × expansion weight
Calculation: smoothed pressure = EMA(EMA(bullish raw pressure, pressure lookback) − EMA(bearish raw pressure, pressure lookback), pressure smoothing lookback)
Calculation: pressure index = smoothed pressure / highest(abs(smoothed pressure), normalization lookback), clipped to pressure-index bounds, or zero when the denominator is zero
Calculation: pressure change = pressure index − pressure index[previous bar]
Calculation: relative volume = volume / SMA(volume, volume lookback) when volume and its average are positive, otherwise one
Calculation: volume flow = EMA(volume × (close position mapped from zero-to-one into negative-one-to-one), volume-flow lookback) / SMA(abs(volume × (close position mapped from zero-to-one into negative-one-to-one)), volume lookback), clipped to volume-flow bounds; use zero if volume or the denominator is unavailable
Calculation: effort result = relative volume / max(abs(close − close[previous bar]) / safe ATR, minimum price progress)
Calculation: bullish volume pass = volume participation is disabled, or volume is unavailable, or (relative volume ≥ minimum relative volume and volume flow is positive)
Calculation: bearish volume pass = volume participation is disabled, or volume is unavailable, or (relative volume ≥ minimum relative volume and volume flow is negative)
Calculation: bullish effort pass = volume participation is disabled, or volume is unavailable, or (close > open and volume flow is positive and (effort result ≤ maximum effort or body ratio ≥ strong-body threshold))
Calculation: bearish effort pass = volume participation is disabled, or volume is unavailable, or (close < open and volume flow is negative and (effort result ≤ maximum effort or body ratio ≥ strong-body threshold))
Calculation: body shrinking = body < SMA(body, body lookback)[previous bar], using body when that prior average is unavailable
Calculation: phase fading = abs(normalized phase slope) < phase-fade threshold or abs(normalized phase slope) < abs(normalized phase slope[previous bar])
Calculation: top exhaustion score = count of body shrinking, phase fading, momentum change < zero, DI pressure change < zero, upper wick ratio ≥ wick threshold, and (ADX ≥ ADX threshold and ADX ≤ ADX[previous bar])
Calculation: bottom exhaustion score = count of body shrinking, phase fading, momentum change > zero, DI pressure change > zero, lower wick ratio ≥ wick threshold, and (ADX ≥ ADX threshold and ADX ≤ ADX[previous bar])
Calculation: prior upper extreme = highest(high[previous bar], extreme lookback); prior lower extreme = lowest(low[previous bar], extreme lookback)
Calculation: upper sweep = high > prior upper extreme and close < prior upper extreme; lower sweep = low < prior lower extreme and close > prior lower extreme
Calculation: armed top setup = an active upper-sweep setup, retaining the maximum top exhaustion score since its trigger until setup expiry or signal reset, with that score ≥ setup arming threshold; armed bottom setup is defined analogously using lower sweeps and bottom exhaustion
Calculation: bullish evidence = 1 point for each of close > EMA(close, faster EMA lookback), close > phase line, phase slope > zero, momentum change > zero, DI pressure change > zero, and pressure index > zero; plus the evidence bonus for each of pressure change > zero, bullish volume pass, bullish effort pass, and (close > open and close position ≥ bullish-close threshold)
Calculation: bearish evidence = 1 point for each of close < EMA(close, faster EMA lookback), close < phase line, phase slope < zero, momentum change < zero, DI pressure change < zero, and pressure index < zero; plus the evidence bonus for each of pressure change < zero, bearish volume pass, bearish effort pass, and (close < open and close position ≤ bearish-close threshold)
Calculation: bullish candidate = confirmed bar and (bullish trend condition or bullish reversal condition), where bullish trend condition is (EMA(close, faster EMA lookback) > EMA(close, slower EMA lookback), with faster lookback < slower lookback) and close > phase line and phase slope > zero and phase distance ≥ required phase distance and bullish evidence ≥ trend-entry threshold and bullish evidence > bearish evidence + trend-lead threshold; bullish reversal condition is armed bottom setup and close > open and close > EMA(close, faster EMA lookback) and momentum change > zero and bullish evidence ≥ reversal threshold
Calculation: bearish candidate = confirmed bar and (bearish trend condition or bearish reversal condition), where bearish trend condition is (EMA(close, faster EMA lookback) < EMA(close, slower EMA lookback), with faster lookback < slower lookback) and close < phase line and phase slope < zero and phase distance ≤ negative required phase distance and bearish evidence ≥ trend-entry threshold and bearish evidence > bullish evidence + trend-lead threshold; bearish reversal condition is armed top setup and close < open and close < EMA(close, faster EMA lookback) and momentum change < zero and bearish evidence ≥ reversal threshold
Calculation: prior signal side = neutral until a signal, then the side of the latest signal until the next signal
Long: bullish candidate and not bearish candidate and prior signal side is not long and bullish evidence ≥ bearish evidence + switching threshold
Short: bearish candidate and not bullish candidate and prior signal side is not short and bearish evidence ≥ bullish evidence + switching threshold