Long: Current hour = trigger hour AND Ask >= previous completed chart-timeframe high of the previous completed M15 bar + Point + (Ask - Bid) + previous completed chart-timeframe ATR(3)
Short: Current hour = trigger hour OR (Bid <= previous completed M15 low - Point - (Ask - Bid) - previous completed chart-timeframe ATR(3))
Exit: Long, Bid <= previous completed M15 low - Point OR Bid >= entry price + 30*Point
Exit: Short, Ask >= previous completed M15 high + Point OR Ask >= entry price + 30*Point OR Bid <= entry price - TakeProfit*Point