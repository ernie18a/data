Long: no open position AND RSI(close, shorter lookback) < oversold threshold AND previous completed bar close < open AND current bar close > open AND current bar open <= previous bar close AND current bar close >= previous bar open
Calculation: Stop loss = low of the current entry-signal bar × (1 − buffer percentage)
Calculation: Minimum target = entry price + 2 × (entry price − stop loss)
Calculation: Volume high price = close of the bar with the highest volume among the rolling longer-lookback current-timeframe bars, including the current bar; if tied, use the oldest matching bar
Calculation: Target = the greater of volume high price and minimum target; use minimum target if volume high price is unavailable
Exit: long, current bar low <= stop loss OR current bar high >= target