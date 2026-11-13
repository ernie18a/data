Calculation: RC = 2*(HeikinAshi open of previous bar + HeikinAshi close of previous bar) - high - low - open of the current bar; then, if RC < low, RC = (low + RC)/2; then, if RC > high, RC = (high + RC)/2 (all on the chart timeframe, completed bars)
Calculation: S = moving average (SMA) of RC over a lookback of N bars
Long: close crosses above S (close > S AND previous close <= previous S)
Short: close crosses below S (close < S AND previous close >= previous S)
Exit: long, low <= entry price * (1 - long stop fraction) OR the Short condition occurs (position reverses)
Exit: short, high >= entry price * (1 + short stop fraction) OR the Long condition occurs (position reverses)