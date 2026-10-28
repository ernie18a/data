Calculation: Dynamic POC = HL2 of the most recent bar with the highest volume in the lookback
Calculation: Long stop = low of the bar before the long signal bar minus ATR at the signal bar × stop multiplier
Calculation: Short stop = high of the bar before the short signal bar plus ATR at the signal bar × stop multiplier
Long: fast EMA > slow EMA AND close > Dynamic POC AND Stochastic RSI %K crosses above the oversold level
Short: fast EMA < slow EMA AND close < Dynamic POC AND Stochastic RSI %K crosses below the overbought level
Exit: Long, low <= the long stop set on entry
Exit: Short, high >= the short stop set on entry