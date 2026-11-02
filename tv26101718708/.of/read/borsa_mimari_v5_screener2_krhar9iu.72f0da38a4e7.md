Calculation: Bullish SuperTrend = SuperTrend direction is up.
Calculation: High volume = volume > SMA(volume) × volume multiplier.
Calculation: Score = sum of +1 for each true condition and -1 for each false condition: MACD line > MACD signal line; RSI > bullish threshold AND RSI <= overbought threshold; ADX > strength threshold AND +DI > -DI; close > shorter EMA; close > longer EMA; bullish SuperTrend; high volume.
Calculation: Lower zone boundary = longer EMA - ATR × (lower-zone multiplier - zone half-width).
Calculation: Upper zone boundary = shorter EMA + ATR × (upper-zone multiplier - zone half-width).
Calculation: Bottom signal = bullish SuperTrend AND close < lower zone boundary AND MACD line > MACD signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND score >= bottom-score threshold.
Calculation: Strong bottom signal = bullish SuperTrend AND close < lower zone boundary AND MACD line > MACD signal line AND RSI > bullish threshold AND high volume AND score >= strong-bottom-score threshold.
Calculation: Top signal = SuperTrend direction is down AND close > upper zone boundary AND MACD line <= MACD signal line AND RSI <= overbought threshold AND score <= top-score threshold.
Calculation: Strong top signal = SuperTrend direction is down AND close > upper zone boundary AND MACD line <= MACD signal line AND RSI <= bullish threshold AND high volume AND score <= strong-top-score threshold.
Calculation: Full buy signal = bullish SuperTrend AND MACD line > MACD signal line AND RSI > bullish threshold AND RSI <= overbought threshold AND ADX > strength threshold AND +DI > -DI AND close > shorter EMA AND close > longer EMA AND score >= full-buy-score threshold.
Calculation: Full sell signal = SuperTrend direction is down AND MACD line <= MACD signal line AND RSI <= bullish threshold AND ADX > strength threshold AND +DI <= -DI AND close <= shorter EMA AND close <= longer EMA AND score <= full-sell-score threshold.
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi open = previous bar's average of Heikin-Ashi open and close, initialized to (open + close) / 2.
Calculation: Descending resistance = line through the two most recently confirmed pivot highs when the newer is lower; retain the last such line until another qualifying pair replaces it. Each pivot uses equal left and right lookbacks and is available only after its right lookback completes. Evaluate both current and previous bar positions on the current line.
Calculation: Target levels = three levels with increasing ATR multipliers. On a newly true bottom or strong bottom signal, reset all levels to the lowest low over a lookback plus ATR times each multiplier, and mark all unhit. Otherwise, on a newly true full buy signal, reset them to close plus ATR times each multiplier if the first level is absent or already hit. After resetting, mark each unhit level hit when high >= that level; if all three are hit, immediately clear all levels and hit flags.
Calculation: Trailing stop = on a newly true bottom or strong bottom signal, set to current SuperTrend value; then clear it if close < stop; then, on a newly true full buy signal, set it to current SuperTrend value; then, if it exists and SuperTrend is bullish, raise it to the maximum of itself and current SuperTrend value. The stop exit comparison uses the stop after the bottom-signal reset and before the clearing and subsequent updates.
Long: MACD line > MACD signal line.
Short: MACD line <= MACD signal line.
Long: ADX > strength threshold AND +DI > -DI.
Short: ADX > strength threshold AND +DI <= -DI.
Long: Score >= buy-score threshold.
Short: Score < neutral-score threshold.
Long: Bullish SuperTrend.
Long: Previous close < previous lower Bollinger Band AND close >= lower Bollinger Band AND close <= upper Bollinger Band.
Long: Close > descending resistance at current bar AND previous close <= descending resistance at previous bar.
Long: Heikin-Ashi close > Heikin-Ashi open AND previous Heikin-Ashi close <= previous Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND previous Heikin-Ashi close > previous Heikin-Ashi open.
Long: Heikin-Ashi close > Heikin-Ashi open AND low >= Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND high <= Heikin-Ashi open.
Long: Bottom signal OR strong bottom signal.
Short: Top signal OR strong top signal.
Long: Full buy signal AND previous full buy signal is false.
Short: Full sell signal AND previous full sell signal is false.
Long: Bullish SuperTrend AND previous SuperTrend direction is down.
Short: SuperTrend direction is down AND previous SuperTrend is bullish.
Exit: long, close < trailing stop.
Exit: long, high >= an unhit target level AND that level's hit flag was false on the previous bar AND fewer than all three target levels are hit after the current bar's target updates.