Calculation: Tenkan = midpoint of the highest high and lowest low over the shorter lookback
Calculation: Kijun = midpoint of the highest high and lowest low over the longer lookback
Calculation: Current cloud top = maximum of Senkou A and Senkou B, each taken from the bar `displacement` bars earlier; Senkou A = midpoint of Tenkan and Kijun; Senkou B = midpoint of the highest high and lowest low over a longer lookback than Kijun
Calculation: Current cloud bottom = minimum of Senkou A and Senkou B from `displacement` bars earlier
Long: Tenkan > Kijun AND previous Tenkan <= previous Kijun AND close > current cloud top AND MFI > its configured threshold AND datetime is within the configured date range
Exit: long, (close < Kijun AND datetime is within the configured date range) OR low <= current cloud bottom