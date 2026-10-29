Calculation: Center = VWAP, or 20-bar EMA when VWAP use is disabled
Calculation: CE level = round up to the strike increment of Center + ATR × multiplier
Calculation: PE level = round down to the strike increment of Center − ATR × multiplier
Short: high ≥ CE level AND RSI > oversold threshold AND time is 09:45–15:15 Asia/Kolkata AND daily trade count < daily limit AND no CE position is open
Long: low ≤ PE level AND RSI < overbought threshold AND time is 09:45–15:15 Asia/Kolkata AND daily trade count < daily limit AND no PE position is open
Exit: short, high ≥ CE level × (1 + stop-loss percentage) OR low ≤ CE level × (1 − target percentage) OR time is 15:25–15:30 Asia/Kolkata
Exit: long, low ≤ PE level × (1 − stop-loss percentage) OR high ≥ PE level × (1 + target percentage) OR time is 15:25–15:30 Asia/Kolkata