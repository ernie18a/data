Calculation: ATR = average true range over a lookback on the configured analysis timeframe, using its still-forming bar
Calculation: Chaos = absolute value of the mean of recent log close-to-close returns divided by their population standard deviation, over the configured analysis timeframe using its still-forming bar
Calculation: Fast and slow moving averages = simple moving averages of close on the configured analysis timeframe using its still-forming bar; fast lookback is shorter than slow lookback
Calculation: Composite signal strength = weighted sum of (RSI − 50) / 50, (ADX − 20) / 30, (fast moving average − slow moving average) / point size, chaos, and (quantum state − half the number of quantum states) / number of quantum states; each term is multiplied by its module weight and adaptive AI weight
Long: Composite signal strength > adaptive threshold AND (chaos filter disabled OR chaos >= chaos threshold)
Short: Composite signal strength < −adaptive threshold AND (chaos filter disabled OR chaos >= chaos threshold)
Exit: long, price <= entry price − ATR × stop-loss multiplier OR price >= entry price + ATR × take-profit-to-stop-loss ratio OR price <= active trailing stop
Exit: short, price >= entry price + ATR × stop-loss multiplier OR price <= entry price − ATR × take-profit-to-stop-loss ratio OR price >= active trailing stop