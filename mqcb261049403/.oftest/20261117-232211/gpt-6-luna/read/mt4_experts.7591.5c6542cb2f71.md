Calculation: pivot = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: upper entry = pivot + metric * Point
Calculation: lower entry = pivot - metric * Point
Calculation: lower outer level = pivot - 2 * metric * Point
Calculation: long target = max(close(T1, last completed bar) + (high(T1, last completed bar) - low(T1, last completed bar)) * 1.1 / 2, lower outer level - 20 * Point)
Calculation: short target = min(close(T1, last completed bar) - (high(T1, last completed bar) - low(T1, last completed bar)) * 1.1 / 2, lower outer level - 20 * Point)
Long: chart-bar hour is between the start-hour and end-hour parameters, no matching long or short position is open, and no entry has been made on this chart bar AND previous tick's close < upper entry AND current close >= upper entry
Short: chart-bar hour is between the start-hour and end-hour parameters, no matching long or short position is open, and no entry has been made on this chart bar AND previous tick's close > lower entry AND current close <= lower entry
Exit: long, chart-bar hour is before the start-hour parameter or after the end-hour parameter OR price reaches the long target OR price reaches the active stop loss, initially lower entry and trailed to close - Trail * Point when close - Trail * Point exceeds both entry price and active stop loss
Exit: short, chart-bar hour is before the start-hour parameter or after the end-hour parameter OR price reaches the short target OR price reaches the active stop loss, initially upper entry and trailed to close + Trail * Point when close + Trail * Point is below both entry price and active stop loss