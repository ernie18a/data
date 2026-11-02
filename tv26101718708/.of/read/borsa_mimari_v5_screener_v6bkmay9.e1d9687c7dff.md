Calculation: Bullish score = sum of +1 for each true condition and -1 for each false condition: MACD line > signal line; RSI > midpoint AND RSI <= overbought threshold; ADX > strength threshold AND +DI > -DI; close > shorter-period EMA; close > longer-period EMA; SuperTrend direction is up; volume > volume SMA multiplied by a volume factor.
Calculation: Dip condition = SuperTrend direction is up AND close < longer-period EMA - ATR × (dip multiplier - band offset) AND MACD line > signal line AND RSI > midpoint AND RSI <= overbought threshold AND bullish score >= dip score threshold.
Calculation: Strong dip condition = SuperTrend direction is up AND close < longer-period EMA - ATR × (dip multiplier - band offset) AND MACD line > signal line AND RSI > midpoint AND volume > volume SMA × volume factor AND bullish score >= higher dip score threshold.
Calculation: Peak condition = SuperTrend direction is down AND close > shorter-period EMA + ATR × (peak multiplier - band offset) AND MACD line <= signal line AND RSI <= overbought threshold AND bullish score <= peak score threshold.
Calculation: Strong peak condition = SuperTrend direction is down AND close > shorter-period EMA + ATR × (peak multiplier - band offset) AND MACD line <= signal line AND RSI <= midpoint AND volume > volume SMA × volume factor AND bullish score <= lower peak score threshold.
Calculation: Buy condition = SuperTrend direction is up AND MACD line > signal line AND RSI > midpoint AND RSI <= overbought threshold AND ADX > strength threshold AND +DI > -DI AND close > shorter-period EMA AND close > longer-period EMA AND bullish score >= buy score threshold.
Calculation: Sell condition = SuperTrend direction is down AND MACD line <= signal line AND RSI <= midpoint AND ADX > strength threshold AND +DI <= -DI AND close <= shorter-period EMA AND close <= longer-period EMA AND bullish score <= sell score threshold.
Calculation: Descending resistance = the line through the two most recently confirmed pivot highs when the newer high is lower; retain the last such line until another qualifying pair replaces it. A pivot is confirmed after equal numbers of bars on either side.
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized to (open + close) / 2; Heikin-Ashi high = max(high, Heikin-Ashi open, Heikin-Ashi close); Heikin-Ashi low = min(low, Heikin-Ashi open, Heikin-Ashi close).
Calculation: Profit targets = three levels with increasing ATR multipliers. On the first bar of either dip condition or strong dip condition, reset all targets to the lowest low over a lookback plus current ATR multiplied by each target multiplier, and mark each unhit. On the first bar of the buy condition, if the first target is absent or already hit, reset all targets to close plus current ATR multiplied by each target multiplier and mark each unhit. Mark an unhit target hit when high >= target; clear all targets when all three are hit. Apply resets before hit checks.
Calculation: Trailing stop = SuperTrend value on the first bar of either dip condition or strong dip condition; clear it when close < the stop; on the first bar of the buy condition set it to the current SuperTrend value; then, while the stop exists and SuperTrend direction is up, raise it to the maximum of its current value and the current SuperTrend value.
Long: MACD line > MACD signal line.
Short: MACD line <= MACD signal line.
Long: ADX > strength threshold AND +DI > -DI.
Short: ADX > strength threshold AND +DI <= -DI.
Long: SuperTrend direction is up.
Long: Bullish score >= buy classification threshold.
Short: Bullish score < neutral classification threshold.
Long: Close is within the accumulation or deep-dip bands below the longer-period EMA; their adjacent boundaries are the longer-period EMA minus ATR multiplied by the dip multiplier minus the band offset, the dip multiplier plus the band offset, and the dip multiplier plus a larger offset, respectively.
Short: Close is within the distribution or overbought bands above the shorter-period EMA; their adjacent boundaries are the shorter-period EMA plus ATR multiplied by the peak multiplier minus the band offset, the peak multiplier plus the band offset, and the peak multiplier plus a larger offset, respectively.
Long: Previous close < previous lower Bollinger Band AND close >= lower Bollinger Band AND close <= upper Bollinger Band.
Long: Close > current descending resistance AND previous close <= descending resistance evaluated at the previous bar using the current line.
Long: Heikin-Ashi close > Heikin-Ashi open AND previous Heikin-Ashi close <= previous Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND previous Heikin-Ashi close > previous Heikin-Ashi open.
Long: Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi low = Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi high = Heikin-Ashi open.
Long: Dip condition OR strong dip condition.
Short: Peak condition OR strong peak condition.
Long: Buy condition AND previous buy condition is false.
Short: Sell condition AND previous sell condition is false.
Long: SuperTrend direction is up AND previous SuperTrend direction is down.
Short: SuperTrend direction is down AND previous SuperTrend direction is up.
Exit: long, an unhit profit target exists AND high >= that target AND at least one of the three targets remains unhit after the current bar's hit checks.
Exit: long, trailing stop exists before its current-bar update AND close < trailing stop.