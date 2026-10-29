Calculation: Zero-lag EMA = EMA(close + (close - close[lag]), lookback), where lag = floor((lookback - 1) / 2)
Calculation: Volatility offset = highest ATR over a longer lookback, scaled; ATR and EMA use the same lookback
Calculation: Trend state = bullish when close crosses above zero-lag EMA + volatility offset; bearish when close crosses below zero-lag EMA - volatility offset; otherwise retain the prior state
Calculation: Volume change (%) = (volume - previous bar volume) / previous bar volume × 100; use 0 when previous bar volume is 0
Long: Trend state is bullish on any configured timeframe (using that timeframe’s current bar, which may still be forming)
Short: Trend state is not bullish on any configured timeframe (using that timeframe’s current bar, which may still be forming)
Long: Volume change (%) > a positive threshold
Short: Volume change (%) < a negative threshold