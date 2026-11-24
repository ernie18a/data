Calculation: Qualified volume = volume >= SMA(volume, volume lookback) * volume multiplier AND (expanding volume is not required OR volume strictly increases over the configured expansion sequence).
Calculation: Bull EMA stack = EMA(close, short EMA lookback) > EMA(close, medium EMA lookback) > EMA(close, long EMA lookback).
Calculation: Bear EMA stack = EMA(close, short EMA lookback) < EMA(close, medium EMA lookback) < EMA(close, long EMA lookback).
Calculation: Bull higher-timeframe trend = the short-, medium-, and long-lookback EMAs of close on T3 are stacked bullish; chart bars take these values from the still-forming T3 bar using lookahead off.
Calculation: Bear higher-timeframe trend = the short-, medium-, and long-lookback EMAs of close on T3 are stacked bearish; chart bars take these values from the still-forming T3 bar using lookahead off.
Calculation: Bull trend agreement = at least the trend-agreement threshold of these three conditions: bull EMA stack, close > VWAP(hlc3), and the higher-timeframe filter is disabled or bull higher-timeframe trend.
Calculation: Bear trend agreement = at least the trend-agreement threshold of these three conditions: bear EMA stack, close < VWAP(hlc3), and the higher-timeframe filter is disabled or bear higher-timeframe trend.
Calculation: Bull score = the sum of one point each for bull EMA stack; close > VWAP(hlc3) AND VWAP(hlc3) > its value at the VWAP slope lookback; higher-timeframe filter disabled OR bull higher-timeframe trend; RSI(close, RSI lookback) within the bullish RSI bounds; MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line > signal line AND histogram > its prior-bar value; and qualified volume.
Calculation: Bear score = the sum of one point each for bear EMA stack; close < VWAP(hlc3) AND VWAP(hlc3) < its value at the VWAP slope lookback; higher-timeframe filter disabled OR bear higher-timeframe trend; RSI(close, RSI lookback) within the bearish RSI bounds; MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line < signal line AND histogram < its prior-bar value; and qualified volume.
Calculation: Near level(price, level) = level exists AND level * (1 - level proximity percentage) <= price <= level * (1 + level proximity percentage).
Calculation: Support touched = Near level(low, at least one of the prior completed T1 low, prior completed T1 close, current developing T1 low accumulated from chart bars, EMA(close, medium EMA lookback), VWAP(hlc3), prior completed T2 low, pre-session low, opening-range low, or last confirmed pivot low). Prior T1 and T2 values use their last completed bars on chart bars; pivot confirmation uses the same pivot lookback on each side.
Calculation: Resistance touched = Near level(high, at least one of the prior completed T1 high, prior completed T1 close, current developing T1 high accumulated from chart bars, EMA(close, medium EMA lookback), VWAP(hlc3), prior completed T2 high, pre-session high, opening-range high, or last confirmed pivot high). Prior T1 and T2 values use their last completed bars on chart bars; pivot confirmation uses the same pivot lookback on each side.
Calculation: Bull spring = low < lowest(low[1], Wyckoff lookback) starts a pending spring at that prior-low level; within the spring expiry bars from the sweep, close > that level AND close > open AND qualified volume.
Calculation: Bear upthrust = high > highest(high[1], Wyckoff lookback) starts a pending upthrust at that prior-high level; within the upthrust expiry bars from the sweep, close < that level AND close < open AND qualified volume.
Calculation: Bull pattern = an enabled bullish engulfing (close[1] < open[1], close > open, close > open[1], open <= close[1], and abs(close - open) > abs(close[1] - open[1])); OR an enabled hammer (lower wick > body * hammer wick multiple, upper wick < body * hammer opposite-wick multiple, body/range < hammer maximum body fraction, and close >= open); OR an enabled breakout (close > highest(high[1], breakout lookback), close > open, and body/range > breakout body fraction); OR an enabled bounce (support touched, close > open, body/range > bounce body fraction, and close > (high + low) / 2); OR an enabled bull spring.
Calculation: Bear pattern = an enabled bearish engulfing (close[1] > open[1], close < open, close < open[1], open >= close[1], and abs(close - open) > abs(close[1] - open[1])); OR an enabled shooting star (upper wick > body * hammer wick multiple, lower wick < body * hammer opposite-wick multiple, body/range < hammer maximum body fraction, and close <= open); OR an enabled breakdown (close < lowest(low[1], breakout lookback), close < open, and body/range > breakout body fraction); OR an enabled rejection (resistance touched, close < open, body/range > bounce body fraction, and close < (high + low) / 2); OR an enabled bear upthrust.
Calculation: Good window = time filter disabled OR the chart-bar time in Chicago-local time is outside every enabled blocked trading window.
Calculation: Initial call stop = if ATR stops are enabled, entry price - ATR(ATR lookback) * ATR stop multiplier; otherwise min(low, low[1], EMA(close, medium EMA lookback)) * call stop factor.
Calculation: Initial put stop = if ATR stops are enabled, entry price + ATR(ATR lookback) * ATR stop multiplier; otherwise max(high, high[1], EMA(close, medium EMA lookback)) * put stop factor.
Calculation: Call target 1 = entry price + (entry price - initial call stop) * first target risk multiple.
Calculation: Call target 2 = entry price + (entry price - initial call stop) * second target risk multiple.
Calculation: Put target 1 = entry price - (initial put stop - entry price) * first target risk multiple.
Calculation: Put target 2 = entry price - (initial put stop - entry price) * second target risk multiple.
Calculation: Current call stop = entry price after call target 1 has been reached; otherwise initial call stop.
Calculation: Current put stop = entry price after put target 1 has been reached; otherwise initial put stop.
Calculation: Bull score directional display = Bull score >= the dashboard directional-score threshold.
Calculation: Bear score directional display = Bear score >= the dashboard directional-score threshold.
Long: Bull score directional display.
Short: Bear score directional display.
Long: RSI(close, RSI lookback) < the dashboard oversold threshold.
Short: RSI(close, RSI lookback) > the dashboard overbought threshold.
Long: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line > signal line AND histogram > its prior-bar value.
Short: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line < signal line AND histogram < its prior-bar value.
Long: Bull higher-timeframe trend.
Short: Bear higher-timeframe trend.
Long: Bull pattern.
Short: NOT bull pattern AND bear pattern.
Long: Support touched.
Short: NOT support touched AND resistance touched.
Long: Bull spring.
Short: Bear upthrust.
Option: buy call, chart bar closes AND A signals are enabled AND Bull score equals the full score AND bull pattern AND (strict trend filter is disabled OR bull trend agreement) AND call cooldown has elapsed since the last A or B call signal AND good window AND outside the MOC window.
Option: buy call, chart bar closes AND B signals are enabled AND Bull score >= the B score threshold AND Bull score < the full score AND bull pattern AND (strict trend filter is disabled OR bull trend agreement) AND call cooldown has elapsed since the last A or B call signal AND good window AND outside the MOC window.
Option: buy call, chart bar closes AND MOC signals are enabled AND within the configured MOC window AND Bull score >= the B score threshold AND bull pattern AND (strict trend filter is disabled OR bull trend agreement) AND qualified volume AND (no prior completed T1 high OR close < prior completed T1 high * overhead clearance factor) AND MOC cooldown has elapsed since the last MOC call or put signal.
Option: buy put, chart bar closes AND A signals are enabled AND Bear score equals the full score AND bear pattern AND (strict trend filter is disabled OR bear trend agreement) AND put cooldown has elapsed since the last A or B put signal AND good window AND outside the MOC window.
Option: buy put, chart bar closes AND B signals are enabled AND Bear score >= the B score threshold AND Bear score < the full score AND bear pattern AND (strict trend filter is disabled OR bear trend agreement) AND put cooldown has elapsed since the last A or B put signal AND good window AND outside the MOC window.
Option: buy put, chart bar closes AND MOC signals are enabled AND within the configured MOC window AND Bear score >= the B score threshold AND bear pattern AND (strict trend filter is disabled OR bear trend agreement) AND qualified volume AND (no prior completed T1 low OR close > prior completed T1 low * underfoot clearance factor) AND MOC cooldown has elapsed since the last MOC call or put signal.
Long: no call or put position is open AND a put signal occurred within the recent-signal lookback bars AND Bull score >= the B score threshold AND bull pattern AND bull trend agreement AND good window.
Short: no call or put position is open AND a call signal occurred within the recent-signal lookback bars AND Bear score >= the B score threshold AND bear pattern AND bear trend agreement AND good window.
Exit: long, call position is open AND Bear score >= the B score threshold AND bear pattern AND (close < VWAP(hlc3) OR bear EMA stack).
Exit: short, put position is open AND Bull score >= the B score threshold AND bull pattern AND (close > VWAP(hlc3) OR bull EMA stack).
Option: sell call, call position is open AND high >= call target 1 for the first time.
Option: sell put, put position is open AND low <= put target 1 for the first time.
Option: sell call, call position is open AND (high >= call target 2 OR low <= current call stop OR (bear EMA stack AND close < VWAP(hlc3) AND bear pattern) OR (time stop enabled AND chart bars since call entry >= call time-stop bars)).
Option: sell put, put position is open AND (low <= put target 2 OR high >= current put stop OR (bull EMA stack AND close > VWAP(hlc3) AND bull pattern) OR (time stop enabled AND chart bars since put entry >= put time-stop bars)).