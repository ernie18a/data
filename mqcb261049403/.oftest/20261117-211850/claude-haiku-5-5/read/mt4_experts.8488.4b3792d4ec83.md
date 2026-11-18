Calculation: FastEMA = exponential moving average of close with short EMA period, which is shorter than long EMA period, on the strategy timeframe, using the last completed bar
Calculation: SlowEMA = exponential moving average of close with long EMA period on the strategy timeframe, using the last completed bar
Calculation: RSI = relative strength index of close with RSI period on the strategy timeframe, using the bar still forming
Calculation: CorWindow = number of minutes in the strategy timeframe
Calculation: CorDiff = (sum over i from 0 to CorWindow-1 of Db_i x Dh_i) / sqrt((sum over i from 0 to CorWindow-1 of Db_i^2) x (sum over i from 0 to CorWindow-1 of Dh_i^2)), where Db_i = close of the base series at shift i minus the simple moving average of close over the CorWindow bars ending at shift i, Dh_i = same calculation on the hedge series, bars of the correlation timeframe, shift 0 is the bar still forming and shift i is i bars before it
Long: position side is flat AND (day of month of current bar < last allowed day of month OR (day of month of current bar = last allowed day of month AND hour of current bar <= hour limit)) AND FastEMA > SlowEMA AND RSI <= oversold threshold AND CorDiff < 0
Short: position side is flat AND (day of month of current bar < last allowed day of month OR (day of month of current bar = last allowed day of month AND hour of current bar <= hour limit)) AND FastEMA < SlowEMA AND RSI >= overbought threshold AND CorDiff < 0
Calculation: OpenProfit = sum over all open positions of (floating profit + swap)
Exit: long, OpenProfit > take profit threshold
Exit: short, OpenProfit > take profit threshold