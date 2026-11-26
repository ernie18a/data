Calculation: Selected price = selected open, high, low, close, (high+low)/2, (high+low+close)/3, (high+low+2*close)/4, or (open+high+low+close)/4
Calculation: Bull strength = MA(MA(if mode is RSI method then max(selected price - selected price[1], 0) else selected price - lowest(low, Length), Length, selected averaging method), Smooth, selected averaging method)
Calculation: Bear strength = MA(MA(if mode is RSI method then max(selected price[1] - selected price, 0) else highest(high, Length) - selected price, Length, selected averaging method), Smooth, selected averaging method)
Long: Bull strength crosses above Bear strength
Short: Bull strength crosses below Bear strength