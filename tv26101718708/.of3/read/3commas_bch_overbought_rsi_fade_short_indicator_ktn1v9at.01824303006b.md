Calculation: active window = window filter disabled OR (datetime >= window start AND datetime <= window end)
Calculation: averaging deviation(k) = first averaging deviation * SUM over j from 0 to k-1 of averaging deviation multiplier^j
Calculation: averaging order size(k) = first averaging order size * averaging order size multiplier^(k-1)
Calculation: average entry price = (base order size + SUM of averaging order size(k) over averaging orders k filled through current bar) / (base order size / base entry price + SUM of averaging order size(k) / close on bar of fill k over the same k)
Calculation: lowest close since take-profit = minimum close from the first bar where close <= average entry price * (1 - take-profit/100) through current bar; undefined before that bar
Short: position side is flat AND active window AND RSI(close, RSI length, T1) crosses below RSI level on T1 bars, taken at last completed T1 bar
Short: position side is short AND active window AND averaging orders filled < averaging order count AND close >= base entry price * (1 + averaging deviation(averaging orders filled + 1) / 100)
Exit: short, active window AND close >= average entry price * (1 + stop loss/100)
Exit: short, active window AND close >= lowest close since take-profit * (1 + trailing stop/100)