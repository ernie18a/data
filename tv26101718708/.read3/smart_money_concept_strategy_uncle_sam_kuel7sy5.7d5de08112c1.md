Calculation: Active pivot high = most recently confirmed Pivot High(high, pivot lookback, same pivot lookback), active until high > it; replace it when a newer pivot high is confirmed
Calculation: Active pivot low = most recently confirmed Pivot Low(low, pivot lookback, same pivot lookback), active until low < it; replace it when a newer pivot low is confirmed
Calculation: MA trend state = bullish after close > selected MA(selected source, MA lookback), bearish after close < selected MA(selected source, MA lookback), unchanged on equality, initially neutral; MA type is selected from SMA, HMA, EMA, RMA, WMA, or VWMA
Long: high > active pivot high AND (MA trend filter disabled OR MA trend state is bullish)
Short: low < active pivot low AND (MA trend filter disabled OR MA trend state is bearish)
Exit: long, low <= entry price - close * long stop-loss parameter / 100 OR high >= entry price + close * long take-profit parameter / 100
Exit: short, high >= entry price + close * short stop-loss parameter / 100 OR low <= entry price - close * short take-profit parameter / 100