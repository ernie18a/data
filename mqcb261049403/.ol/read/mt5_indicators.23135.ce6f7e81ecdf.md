Calculation: Breakout high = highest high over the lookback, including the current bar
Calculation: Breakout low = lowest low over the lookback, including the current bar
Long: flat or short position AND high >= Breakout high AND close > one-period TEMA of median price AND close > longer-period TEMA of median price AND high > longer-period TEMA of median price AND MFI >= upper threshold
Short: flat or long position AND low <= Breakout low AND close < one-period TEMA of median price AND close < longer-period TEMA of median price AND low < longer-period TEMA of median price AND MFI <= lower threshold
Calculation: Long stop = the greater of the prior long stop and the current Breakout low; initialize to the current Breakout low on entering long
Calculation: Long take-profit = the greater of the prior long take-profit and the current Breakout high; initialize to the current Breakout high on entering long
Calculation: Short stop = the lesser of the prior short stop and the current Breakout high; initialize to the current Breakout high on entering short
Calculation: Short take-profit = the lesser of the prior short take-profit and the current Breakout low; initialize to the current Breakout low on entering short
Exit: long, low <= Long stop OR high >= Long take-profit
Exit: short, high >= Short stop OR low <= Short take-profit