Calculation: Bull trend = EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback) AND close > EMA(close, trend EMA lookback)
Calculation: Bear trend = EMA(close, fast EMA lookback) < EMA(close, slow EMA lookback) AND close < EMA(close, trend EMA lookback)
Calculation: Range midpoint = (Highest(high, range lookback) + Lowest(low, range lookback)) / 2
Calculation: Latest confirmed pivot high = most recent confirmed Pivot High(high, pivot strength, pivot strength)
Calculation: Latest confirmed pivot low = most recent confirmed Pivot Low(low, pivot strength, pivot strength)
Calculation: Bullish break = crosses above(close, latest confirmed pivot high)
Calculation: Bearish break = crosses below(close, latest confirmed pivot low)
Calculation: High sweep = high > latest confirmed pivot high AND close < latest confirmed pivot high
Calculation: Low sweep = low < latest confirmed pivot low AND close > latest confirmed pivot low
Calculation: Candle body = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Bullish rejection = lower wick > candle body * rejection wick multiple AND close > open
Calculation: Bearish rejection = upper wick > candle body * rejection wick multiple AND close < open
Calculation: Bullish gap = low > high[gap lookback]
Calculation: Bearish gap = high < low[gap lookback]
Calculation: High volume = volume > SMA(volume, shared average lookback) * relative volume multiple
Calculation: Demand zone signal = high volume AND close > open AND lower wick > candle body * demand wick ratio
Calculation: Supply zone signal = high volume AND close < open AND upper wick > candle body * supply wick ratio
Calculation: Bullish order block = bullish break AND the previous bar closes below its open
Calculation: Bearish order block = bearish break AND the previous bar closes above its open
Calculation: Momentum = EMA(close - close[momentum lag], momentum smoothing lookback)
Calculation: Bullish pressure = close > open AND volume > SMA(volume, shared average lookback)
Calculation: Bearish pressure = close < open AND volume > SMA(volume, shared average lookback)
Calculation: Volatility expansion = ATR(ATR lookback) > SMA(ATR(ATR lookback), shared average lookback)
Calculation: Strong trend = ADX(DMI lookback, ADX smoothing lookback) > ADX threshold
Calculation: Strong candle = (high > low AND candle body / (high - low) > strong body fraction) AND high - low > ATR(ATR lookback)
Calculation: Bullish wave = MACD(close, wave fast lookback, wave slow lookback).line > MACD(close, wave fast lookback, wave slow lookback).signal(wave signal lookback) AND MACD(close, wave fast lookback, wave slow lookback).line > wave zero threshold
Calculation: Bearish wave = MACD(close, wave fast lookback, wave slow lookback).line < MACD(close, wave fast lookback, wave slow lookback).signal(wave signal lookback) AND MACD(close, wave fast lookback, wave slow lookback).line < wave zero threshold
Calculation: Equal high = a confirmed Pivot High exists AND a previous confirmed Pivot High exists AND abs(current confirmed Pivot High - previous confirmed Pivot High) <= ATR(ATR lookback) * liquidity tolerance
Calculation: Equal low = a confirmed Pivot Low exists AND a previous confirmed Pivot Low exists AND abs(current confirmed Pivot Low - previous confirmed Pivot Low) <= ATR(ATR lookback) * liquidity tolerance
Calculation: Session overlap = the chart bar is in both configured New York sessions
Calculation: News allowed = news filter is disabled OR the chart bar is outside the configured New York news blackout session
Calculation: T1 bullish bias = EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback), calculated on T1 bars and sampled on chart bars from the still-forming T1 bar (completed T1 bars historically)
Calculation: T1 bearish bias = EMA(close, fast EMA lookback) < EMA(close, slow EMA lookback), calculated on T1 bars and sampled on chart bars from the still-forming T1 bar (completed T1 bars historically)
Calculation: T2 bullish bias = EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback), calculated on T2 bars and sampled on chart bars from the still-forming T2 bar (completed T2 bars historically)
Calculation: T3 bullish bias = EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback), calculated on T3 bars and sampled on chart bars from the still-forming T3 bar (completed T3 bars historically)
Calculation: T4 bullish bias = EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback), calculated on T4 bars and sampled on chart bars from the still-forming T4 bar (completed T4 bars historically)
Calculation: AI score = weightTrendBreak * (1 if bull trend OR bear trend else 0) + weightADXAlignment * (1 if strong trend else 0) + weightADXAlignment * (1 if (T1 bullish bias AND bull trend) OR (T1 bearish bias AND bear trend) else 0) + weight8 * (1 if volatility expansion else 0) + weight8 * (1 if bullish pressure OR bearish pressure else 0) + weight8 * (1 if session overlap else 0) + weightTrendBreak * (1 if bullish break OR bearish break else 0) + weight8 * (1 if high sweep OR low sweep else 0) + weight6 * (1 if bullish gap OR bearish gap else 0) + weight7 * (1 if bullish order block OR bearish order block else 0) + weight6 * (1 if demand zone signal OR supply zone signal else 0) + weight5 * (1 if equal high OR equal low else 0) + weight6 * (1 if (bullish wave AND bull trend) OR (bearish wave AND bear trend) else 0) + weight6 * (1 if (close > Supertrend(supertrend factor, supertrend ATR lookback) AND bull trend) OR (close < Supertrend(supertrend factor, supertrend ATR lookback) AND bear trend) else 0) + weight5 * (1 if strong candle else 0) + (news allowed ? news allowed weight : -news blocked penalty)
Long: bull trend
Short: bear trend
Long: Momentum > momentum zero threshold
Short: Momentum < momentum zero threshold
Long: bullish pressure
Short: bearish pressure
Long: close < range midpoint
Short: close > range midpoint
Long: T2 bullish bias
Short: EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback), calculated on T2 bars and sampled on chart bars from the still-forming T2 bar (completed T2 bars historically)
Long: T3 bullish bias
Short: EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback), calculated on T3 bars and sampled on chart bars from the still-forming T3 bar (completed T3 bars historically)
Long: T4 bullish bias
Short: EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback), calculated on T4 bars and sampled on chart bars from the still-forming T4 bar (completed T4 bars historically)
Long: close > Supertrend(supertrend factor, supertrend ATR lookback)
Short: close < Supertrend(supertrend factor, supertrend ATR lookback)
Long: bullish wave
Short: bearish wave
Long: Momentum > momentum zero threshold AND bullish pressure AND volatility expansion
Short: Momentum < momentum zero threshold AND bearish pressure AND volatility expansion
Long: bullish break
Short: bearish break
Long: low sweep
Short: high sweep
Long: bullish gap
Short: bearish gap
Long: bullish order block
Short: bearish order block
Long: demand zone signal
Short: supply zone signal
Long: bullish rejection
Short: bearish rejection
Long: MACD(close, wave fast lookback, wave slow lookback).line crosses above MACD(close, wave fast lookback, wave slow lookback).signal(wave signal lookback)
Short: MACD(close, wave fast lookback, wave slow lookback).line crosses below MACD(close, wave fast lookback, wave slow lookback).signal(wave signal lookback)
Long: bull trend AND RSI(close, RSI lookback) > RSI long threshold AND close > VWAP(close) AND T1 bullish bias AND strong trend AND close < range midpoint AND close > Supertrend(supertrend factor, supertrend ATR lookback) AND bullish wave AND (bullish break OR low sweep OR bullish rejection OR demand zone signal) AND news allowed AND AI score >= AI entry score threshold
Short: bear trend AND RSI(close, RSI lookback) < RSI short threshold AND close < VWAP(close) AND T1 bearish bias AND strong trend AND close > range midpoint AND close < Supertrend(supertrend factor, supertrend ATR lookback) AND bearish wave AND (bearish break OR high sweep OR bearish rejection OR supply zone signal) AND news allowed AND AI score >= AI entry score threshold