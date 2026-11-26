Calculation: Candle close-location delta = ((close - low) / max(high - low, minimum price increment) × volume - (high - close) / max(high - low, minimum price increment) × volume) / max(volume, minimum volume divisor)
Calculation: Body percentage = abs(close - open) / max(high - low, minimum price increment), expressed as a percentage
Calculation: Relative volume = volume / SMA(volume, volume average lookback) when SMA(volume, volume average lookback) > 0; otherwise 0
Calculation: Short-term trend average = EMA(hlc3, swing lookback)
Calculation: Long-term trend average = EMA(hlc3, long-term lookback), where long-term lookback is longer than swing lookback
Calculation: Long structural break = close > latest confirmed PivotHigh(high, swing lookback, swing lookback) AND close[1] <= latest confirmed PivotHigh(high, swing lookback, swing lookback) AND close - latest confirmed PivotHigh(high, swing lookback, swing lookback) > ATR(ATR lookback) × displacement multiplier
Calculation: Short structural break = close < latest confirmed PivotLow(low, swing lookback, swing lookback) AND close[1] >= latest confirmed PivotLow(low, swing lookback, swing lookback) AND latest confirmed PivotLow(low, swing lookback, swing lookback) - close > ATR(ATR lookback) × displacement multiplier
Calculation: Higher-timeframe short-term average = EMA(hlc3, swing lookback) on T1 bars, projected onto chart bars using the current T1 bar in real time and completed T1 bars historically
Calculation: Higher-timeframe long-term average = EMA(hlc3, long-term lookback) on T1 bars, projected onto chart bars using the current T1 bar in real time and completed T1 bars historically
Calculation: Higher-timeframe delta average = EMA(candle close-location delta calculated from T1 bars, delta smoothing) on T1 bars, projected onto chart bars using the current T1 bar in real time and completed T1 bars historically
Calculation: Higher-timeframe long bias = higher-timeframe short-term average >= higher-timeframe long-term average AND higher-timeframe delta average >= 0
Calculation: Higher-timeframe short bias = higher-timeframe short-term average <= higher-timeframe long-term average AND higher-timeframe delta average <= 0
Calculation: Long higher-timeframe pass = higher-timeframe filter disabled OR higher-timeframe long bias
Calculation: Short higher-timeframe pass = higher-timeframe filter disabled OR higher-timeframe short bias
Calculation: Long catalyst score = structure score weight when long structural break is true, plus common score weight for each true condition among relative volume >= volume threshold; close > open AND candle close-location delta > 0 AND EMA(candle close-location delta, delta smoothing) > 0; body percentage >= minimum body percentage AND close > short-term trend average; short-term trend average > long-term trend average; and long higher-timeframe pass. Structure score weight > common score weight.
Calculation: Short catalyst score = structure score weight when short structural break is true, plus common score weight for each true condition among relative volume >= volume threshold; close < open AND candle close-location delta < 0 AND EMA(candle close-location delta, delta smoothing) < 0; body percentage >= minimum body percentage AND close < short-term trend average; short-term trend average < long-term trend average; and short higher-timeframe pass. Structure score weight > common score weight.
Calculation: Long prime qualification = long catalyst score >= prime score threshold AND relative volume >= volume threshold × prime volume multiplier AND body percentage >= minimum body percentage + prime body increment
Calculation: Short prime qualification = short catalyst score >= prime score threshold AND relative volume >= volume threshold × prime volume multiplier AND body percentage >= minimum body percentage + prime body increment
Calculation: Structural direction state = bullish after a long structural break; otherwise bearish after a short structural break; otherwise retain the previous state, initially neutral
Long: Structural direction state is bullish
Short: Structural direction state is bearish
Long: Short-term trend average >= long-term trend average
Short: Short-term trend average < long-term trend average
Long: Higher-timeframe short-term average > higher-timeframe long-term average
Short: Higher-timeframe short-term average < higher-timeframe long-term average
Long: EMA(candle close-location delta, delta smoothing) > 0
Short: EMA(candle close-location delta, delta smoothing) < 0
Long: Long structural break AND long higher-timeframe pass AND long catalyst score >= minimum catalyst score AND long prime qualification
Long: Long structural break AND long higher-timeframe pass AND long catalyst score >= minimum catalyst score AND NOT long prime qualification
Short: Short structural break AND short higher-timeframe pass AND short catalyst score >= minimum catalyst score AND short prime qualification
Short: Short structural break AND short higher-timeframe pass AND short catalyst score >= minimum catalyst score AND NOT short prime qualification