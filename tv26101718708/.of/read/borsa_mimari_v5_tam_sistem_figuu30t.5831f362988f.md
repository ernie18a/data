Calculation: Score = sum of seven contributions, each +1 if its condition is true and -1 otherwise: MACD line > MACD signal; RSI > bullish threshold AND RSI <= overbought threshold; ADX > strength threshold AND +DI > -DI; close > shorter EMA; close > longer EMA; SuperTrend direction is up; volume > volume SMA multiplied by a volume factor.
Calculation: Lower zone boundary = longer EMA - ATR multiplied by (lower-zone multiplier - zone half-width).
Calculation: Upper zone boundary = shorter EMA + ATR multiplied by (upper-zone multiplier - zone half-width).
Calculation: Falling resistance = line through the two most recently confirmed pivot highs when the older high is greater than the newer high; retain the last such line until another qualifying pair replaces it. Each pivot uses equal numbers of bars on both sides and becomes available only after the right-side bars complete.
Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized to (open + close) / 2; Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi high = max(high, Heikin-Ashi open, Heikin-Ashi close); Heikin-Ashi low = min(low, Heikin-Ashi open, Heikin-Ashi close).
Calculation: Bottom signal = SuperTrend direction is up AND close < lower zone boundary AND MACD line > MACD signal AND RSI > bullish threshold AND RSI <= overbought threshold AND score >= lower positive threshold.
Calculation: Strong bottom signal = SuperTrend direction is up AND close < lower zone boundary AND MACD line > MACD signal AND RSI > bullish threshold AND volume > volume SMA multiplied by a volume factor AND score >= higher positive threshold.
Calculation: Buy signal = SuperTrend direction is up AND MACD line > MACD signal AND RSI > bullish threshold AND RSI <= overbought threshold AND ADX > strength threshold AND +DI > -DI AND close > shorter EMA AND close > longer EMA AND score >= highest positive threshold.
Calculation: Sell signal = SuperTrend direction is down AND MACD line <= MACD signal AND RSI <= bullish threshold AND ADX > strength threshold AND +DI <= -DI AND close <= shorter EMA AND close <= longer EMA AND score <= lower negative threshold.
Calculation: Targets = three ascending ATR-multiple levels. On a new bottom or strong bottom signal, reset all targets to the lowest low over a lookback plus their respective multiples of current ATR, and clear their hit flags. On a new buy signal, if the first target is unavailable or already hit, reset all targets to close plus their respective multiples of current ATR and clear their hit flags. Mark each unhit target hit when high >= that target; if all three are hit, clear all targets and hit flags immediately.
Calculation: Stop = on a new bottom or strong bottom signal set the stop to the current SuperTrend value; then clear it if close < stop; then on a new buy signal set it to the current SuperTrend value; finally, while the stop exists and SuperTrend direction is up, raise it to the greater of the stop and current SuperTrend value. A new signal means true on the current bar and false on the previous bar.
Long: MACD line > MACD signal.
Short: MACD line <= MACD signal.
Long: ADX > strength threshold AND +DI > -DI.
Short: ADX > strength threshold AND +DI <= -DI.
Long: SuperTrend direction is up.
Long: Score >= positive buy threshold.
Short: Score < neutral threshold.
Long: Close is within the accumulation or deep-bottom zone below the longer EMA, defined by consecutive ATR-width bands.
Short: Close is within the distribution or overbought zone above the shorter EMA, defined by consecutive ATR-width bands; the distribution zone takes precedence at their shared boundary.
Long: Previous close < previous lower Bollinger Band AND current close >= current lower Bollinger Band AND current close <= current upper Bollinger Band.
Long: Close > falling resistance at the current bar AND previous close <= the same falling resistance line at the previous bar.
Long: Heikin-Ashi close > Heikin-Ashi open AND previous Heikin-Ashi close <= previous Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND previous Heikin-Ashi close > previous Heikin-Ashi open.
Long: Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi low = Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi high = Heikin-Ashi open.
Long: Bottom signal OR strong bottom signal.
Short: SuperTrend direction is down AND close > upper zone boundary AND MACD line <= MACD signal AND RSI <= overbought threshold AND score <= higher negative threshold.
Short: SuperTrend direction is down AND close > upper zone boundary AND MACD line <= MACD signal AND RSI <= bullish threshold AND volume > volume SMA multiplied by a volume factor AND score <= lower negative threshold.
Long: Buy signal AND previous buy signal is false.
Short: Sell signal AND previous sell signal is false.
Long: SuperTrend direction is up AND previous SuperTrend direction is down.
Short: SuperTrend direction is down AND previous SuperTrend direction is up.
Exit: long, close < stop before the current bar's stop reset and trailing update.
Exit: long, high >= an unhit target AND its hit flag changes from false to true after target updates and the all-targets-hit reset.