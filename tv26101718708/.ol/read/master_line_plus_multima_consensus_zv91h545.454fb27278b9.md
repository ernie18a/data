Calculation: Consensus = the mean of the EMA, SMA, WMA, HMA, RMA, DEMA, TEMA, and ALMA of close, all using the same lookback
Calculation: ATR band = ATR multiplied by a configurable factor
Calculation: Trend state = bullish when close > consensus + ATR band; bearish when close < consensus − ATR band; otherwise retain the prior state, initially neutral
Calculation: Higher-timeframe consensus = the same consensus calculated on higher-timeframe bars, using the still-forming higher-timeframe bar
Long: current trend state is bullish AND prior trend state is not bullish AND (higher-timeframe filter is disabled OR chart close > higher-timeframe consensus)
Short: current trend state is bearish AND prior trend state is not bearish AND (higher-timeframe filter is disabled OR chart close < higher-timeframe consensus)