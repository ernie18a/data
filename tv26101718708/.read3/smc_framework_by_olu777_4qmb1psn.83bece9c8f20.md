Calculation: Major pivots = use either alternating running-extreme pivots, confirming a high when the candidate high minus current low >= ATR(ATR lookback) x reversal multiple and a low when current high minus candidate low >= the same threshold, resetting the opposite candidate to the confirmation-bar extreme; or PivotHigh/PivotLow with equal left and right major windows
Calculation: Bullish fair value gap = low > high[n] AND previous bar close > high[n] AND low - high[n] >= ATR(ATR lookback) x minimum gap multiple
Calculation: Bearish fair value gap = high < low[n] AND previous bar close < low[n] AND low[n] - high >= ATR(ATR lookback) x minimum gap multiple
Calculation: Active fair value gap zones = bullish gaps span from high[n] to low and bearish gaps from high to low[n]; remove a bullish zone when low < its bottom, a bearish zone when high > its top, or either when its age exceeds the extension parameter; replace overlapping older same-side zones and retain at most the maximum count per side
Calculation: Bullish order block source = among the preceding origin scan window bars, choose the qualifying bearish candle with the lowest low; a qualifying candle has range < ATR(ATR lookback) x range multiple, absolute body / range >= minimum body ratio, and, when the volume filter is enabled, volume >= SMA(volume, volume lookback) x volume multiple
Calculation: Bearish order block source = among the preceding origin scan window bars, choose the qualifying bullish candle with the highest high; a qualifying candle has range < ATR(ATR lookback) x range multiple, absolute body / range >= minimum body ratio, and, when the volume filter is enabled, volume >= SMA(volume, volume lookback) x volume multiple
Calculation: Order block score = min((zone top - zone bottom) / max(ATR(ATR lookback) x size divisor, epsilon), size cap) x size weight + min(abs(close - open) / max(ATR(ATR lookback) x displacement divisor, epsilon), displacement cap) x displacement weight + (volume > SMA(volume, volume lookback) ? high-volume points : low-volume points) + (any active same-side fair value gap overlapping the zone ? overlap points : 0)
Calculation: Minor structure bias = bullish after the latest bullish minor break, bearish after the latest bearish minor break, and neutral before either
Long: close > current pending major pivot high AND previous bar close <= current pending major pivot high
Short: close < current pending major pivot low AND previous bar close >= current pending major pivot low
Long: close > current pending minor pivot high AND previous bar close <= current pending minor pivot high
Short: close < current pending minor pivot low AND previous bar close >= current pending minor pivot low
Long: minor structure bias is bullish
Short: minor structure bias is bearish
Long: low < nearest confirmed minor pivot low among the latest pivot-scan-count minor pivots, with pivot age > minimum pivot age, AND close > that pivot low AND lower wick >= ATR(ATR lookback) x wick multiple AND lower wick / max(high - low, epsilon) >= minimum wick fraction AND bars since previous bullish sweep, initialized at the first bar, > sweep cooldown
Short: high > nearest confirmed minor pivot high among the latest pivot-scan-count minor pivots, with pivot age > minimum pivot age, AND close < that pivot high AND upper wick >= ATR(ATR lookback) x wick multiple AND upper wick / max(high - low, epsilon) >= minimum wick fraction AND bars since previous bearish sweep, initialized at the first bar, > sweep cooldown
Long: Bullish fair value gap
Short: Bearish fair value gap
Long: bullish major break AND bullish order block source exists AND order block score >= score threshold
Short: bearish major break AND bearish order block source exists AND order block score >= score threshold