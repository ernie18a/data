Calculation: Fibonacci retracement level = selected Fibonacci ratio calculated from the configured lookback of highs and lows on the configured higher timeframe, using its bar still forming
Calculation: Impulse threshold = 12-period EMA of the Fibonacci retracement level
Long: close crosses above the impulse threshold AND Chandelier Exit direction is bullish AND no position is open
Short: close crosses below the impulse threshold AND Chandelier Exit direction is bearish AND no position is open
Exit: long, close < impulse threshold AND Chandelier Exit direction is bearish
Exit: short, close > impulse threshold AND Chandelier Exit direction is bullish
Exit: long, close <= entry price minus the configured stop distance OR close >= entry price plus the configured stop distance multiplied by the configured reward-to-risk ratio
Exit: short, close >= entry price plus the configured stop distance OR close <= entry price minus the configured stop distance multiplied by the configured reward-to-risk ratio