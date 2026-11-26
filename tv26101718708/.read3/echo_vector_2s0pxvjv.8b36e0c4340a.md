Calculation: candle body denominator = max(abs(close − open), minimum tick size)
Calculation: upper wick = high − max(open, close)
Calculation: lower wick = min(open, close) − low
Calculation: volume spread = volume × (high − low)
Calculation: blow-off condition = close > open AND volume ≥ SMA(volume, blow-off volume lookback)[1] × blow-off volume multiplier AND close > EMA(close, extension lookback) + StDev(close, extension lookback) × deviation multiplier AND abs(close − open) > SMA(abs(close − open), body lookback) × body multiplier
Calculation: exhaustion condition = close ≤ open AND volume ≥ SMA(volume, blow-off volume lookback)[1] × blow-off volume multiplier AND close < EMA(close, extension lookback) − StDev(close, extension lookback) × deviation multiplier AND abs(close − open) > SMA(abs(close − open), body lookback) × body multiplier
Calculation: bullish peak-volume candle = close > open AND volume ≥ SMA(volume, peak volume lookback)[1] × peak volume multiplier AND NOT blow-off condition
Calculation: bearish peak-volume candle = close ≤ open AND volume ≥ SMA(volume, peak volume lookback)[1] × peak volume multiplier AND NOT exhaustion condition
Calculation: bullish surge candle = close > open AND (volume ≥ SMA(volume, relative-volume lookback)[1] × surge volume multiplier OR volume spread ≥ Highest(volume spread[1], relative-volume lookback)) AND NOT bullish peak-volume candle AND NOT blow-off condition
Calculation: bearish surge candle = close ≤ open AND (volume ≥ SMA(volume, relative-volume lookback)[1] × surge volume multiplier OR volume spread ≥ Highest(volume spread[1], relative-volume lookback)) AND NOT bearish peak-volume candle AND NOT exhaustion condition
Short: blow-off condition
Long: exhaustion condition
Long: bullish peak-volume candle
Short: bearish peak-volume candle
Long: bullish surge candle
Short: bearish surge candle
Long: close > open AND volume ≥ SMA(volume, relative-volume lookback)[1] × pulse volume multiplier AND NOT bullish surge candle AND NOT bullish peak-volume candle AND NOT blow-off condition
Short: close ≤ open AND volume ≥ SMA(volume, relative-volume lookback)[1] × pulse volume multiplier AND NOT bearish surge candle AND NOT bearish peak-volume candle AND NOT exhaustion condition
Long: close > open AND NOT blow-off condition AND NOT bullish peak-volume candle AND NOT bullish surge candle AND NOT (volume ≥ SMA(volume, relative-volume lookback)[1] × pulse volume multiplier)
Short: close ≤ open AND NOT exhaustion condition AND NOT bearish peak-volume candle AND NOT bearish surge candle AND NOT (volume ≥ SMA(volume, relative-volume lookback)[1] × pulse volume multiplier)
Long: close > EMA(close, baseline EMA lookback)
Short: close ≤ EMA(close, baseline EMA lookback)
Long: crossover(RSI(close, RSI lookback), oversold threshold)
Short: crossunder(RSI(close, RSI lookback), overbought threshold)
Long: selected bullish break price (close or high) > latest unbroken confirmed pivot high using major pivot lookback
Short: selected bearish break price (close or low) < latest unbroken confirmed pivot low using major pivot lookback
Long: no major structure break on this bar AND selected bullish break price (close or high) > latest unbroken confirmed pivot high using internal pivot lookback
Short: no major structure break on this bar AND selected bearish break price (close or low) < latest unbroken confirmed pivot low using internal pivot lookback
Long: confirmed pivot low using market-structure pivot lookback
Short: confirmed pivot high using market-structure pivot lookback
Long: confirmed pivot low using Fibonacci pivot lookback
Short: confirmed pivot high using Fibonacci pivot lookback
Long: confirmed pivot low using pivot-zone sensitivity AND volume at the pivot bar > EMA(volume, pivot-zone volume lookback) at the pivot bar × relative-volume multiplier
Short: confirmed pivot high using pivot-zone sensitivity AND volume at the pivot bar > EMA(volume, pivot-zone volume lookback) at the pivot bar × relative-volume multiplier
Long: a confirmed bullish Fair Value Gap where high[n] < low AND low − high[n] ≥ minimum gap size × minimum tick size
Short: a confirmed bearish Fair Value Gap where low[n] > high AND low[n] − high ≥ minimum gap size × minimum tick size
Long: valid selected sweep reference low exists AND low < selected reference low (prior rolling low or latest confirmed major pivot low) AND close > selected reference low AND lower wick / candle body denominator ≥ minimum wick-to-body ratio AND volume > SMA(volume, stop-hunt volume lookback)[1] × volume multiplier AND (ATR filter disabled OR high − low ≥ ATR(ATR lookback)) AND (structure filter disabled OR latest major or internal structure direction is bullish)
Short: valid selected sweep reference high exists AND high > selected reference high (prior rolling high or latest confirmed major pivot high) AND close < selected reference high AND upper wick / candle body denominator ≥ minimum wick-to-body ratio AND volume > SMA(volume, stop-hunt volume lookback)[1] × volume multiplier AND (ATR filter disabled OR high − low ≥ ATR(ATR lookback)) AND (structure filter disabled OR latest major or internal structure direction is bearish)
Long: close < open AND volume > selected stopping-volume reference (SMA(volume, lookback)[1] or Highest(volume, lookback)[1]) × volume multiplier AND lower wick / candle body denominator ≥ minimum wick-to-body ratio AND candle body denominator < ATR(ATR lookback) × maximum body ATR multiplier AND low[1] > low AND more than cooldown bars since the previous bullish condition AND the selected location filter passes: low below prior rolling low, low below VWAP(close), a bullish stop hunt within the selected recency limit, low below the selected range low plus the selected range fraction, or location filter disabled
Short: close > open AND volume > selected stopping-volume reference (SMA(volume, lookback)[1] or Highest(volume, lookback)[1]) × volume multiplier AND upper wick / candle body denominator ≥ minimum wick-to-body ratio AND candle body denominator < ATR(ATR lookback) × maximum body ATR multiplier AND high[1] < high AND more than cooldown bars since the previous bearish condition AND the selected location filter passes: high above prior rolling high, high above VWAP(close), a bearish stop hunt within the selected recency limit, high above the selected range high minus the selected range fraction, or location filter disabled
Long: volume ≥ SMA(volume, displacement volume lookback)[1] × volume multiplier AND close ≥ EMA(close, displacement EMA lookback) × (1 + minimum EMA distance percentage / 100) AND (recent-high filter disabled OR high ≥ Highest(high, recent-extreme lookback)[1])
Short: volume ≥ SMA(volume, displacement volume lookback)[1] × volume multiplier AND close ≤ EMA(close, displacement EMA lookback) × (1 − minimum EMA distance percentage / 100) AND (recent-low filter disabled OR low ≤ Lowest(low, recent-extreme lookback)[1])
Long: abs(close − open) > SMA(abs(close − open), lookback)[1] × body multiplier AND volume > SMA(volume, lookback)[1] × volume multiplier AND low < Lowest(low, lookback)[1] AND close > Lowest(low, lookback)[1] AND close > open
Short: abs(close − open) > SMA(abs(close − open), lookback)[1] × body multiplier AND volume > SMA(volume, lookback)[1] × volume multiplier AND high > Highest(high, lookback)[1] AND close < Highest(high, lookback)[1] AND close < open
Long: lower wick ≤ candle body denominator × small-wick fraction AND lower wick ≥ candle body denominator × wick-to-body ratio AND volume ≥ SMA(volume, wick volume lookback)[1] × volume multiplier AND abs(close − EMA(close, EMA lookback)) ≥ EMA(close, EMA lookback) × minimum EMA distance percentage / 100
Short: lower wick ≤ candle body denominator × small-wick fraction AND upper wick ≥ candle body denominator × wick-to-body ratio AND volume ≥ SMA(volume, wick volume lookback)[1] × volume multiplier AND abs(close − EMA(close, EMA lookback)) ≥ EMA(close, EMA lookback) × minimum EMA distance percentage / 100