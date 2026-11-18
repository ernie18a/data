Calculation: signed-volume EMA difference = EMA(volume if change(hlc3) >= 0 else -volume, shorter lookback) - EMA(volume if change(hlc3) >= 0 else -volume, longer lookback)
Long: high > high[1] AND low < low[1] AND signed-volume EMA difference > 0 AND close > HMA(close, lookback) AND close > open
Short: high < high[1] AND low > low[1] AND signed-volume EMA difference < 0 AND close < HMA(close, lookback) AND close < open
Exit: long, high >= entry price + close × long take-profit parameter OR low <= entry price - close × long stop-loss parameter
Exit: short, low <= entry price - close × short take-profit parameter OR high >= entry price + close × short stop-loss parameter