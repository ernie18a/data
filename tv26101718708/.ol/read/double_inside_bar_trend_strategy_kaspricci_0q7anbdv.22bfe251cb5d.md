Long: open trades = 0 AND bar is confirmed AND configured date/session filters pass AND high[2] > high[1] AND high[2] > high AND low[2] < low[1] AND low[2] < low AND close > trend moving average; place a buy stop at the setup bar high
Short: open trades = 0 AND bar is confirmed AND configured date/session filters pass AND high[2] > high[1] AND high[2] > high AND low[2] < low[1] AND low[2] < low AND close < trend moving average; place a sell stop at the setup bar low
Exit: long, price <= entry price − stop distance OR price >= entry price + take-profit distance
Exit: short, price >= entry price + stop distance OR price <= entry price − take-profit distance
Calculation: Stop distance = ATR × configured factor, or configured fixed stop distance
Calculation: Take-profit distance = stop distance × configured ratio in ATR mode, or configured fixed take-profit distance