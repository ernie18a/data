Calculation: transformed price = sqrt((high²/2 + low²/2 + open²/2 + close²/2) / 4)
Calculation: upper and lower volatility bands = SMA(transformed price, lookback) ± SMA(high − low, same lookback) × multiplier
Calculation: weekly VWAP = cumulative volume-weighted OHLC4 within the current, forming week
Long: transformed price crosses above the upper volatility band AND close > weekly VWAP AND datetime is within the configured date window
Exit: long, transformed price crosses below the lower volatility band AND close < weekly VWAP AND datetime is within the configured date window