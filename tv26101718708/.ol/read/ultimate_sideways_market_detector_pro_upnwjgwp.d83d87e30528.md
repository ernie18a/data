Calculation: Sideways score = sum of enabled filter points for low ADX, high Choppiness Index, compressed ATR, compressed Bollinger Band width, flat EMA, compressed price range, and (optionally) compressed volume
Calculation: Flat EMA = absolute difference between the EMA and its value at a longer lookback < ATR
Calculation: Compressed price range = highest high − lowest low over the range lookback < ATR × a parameter
Long: close > EMA AND ADX > a threshold AND Sideways score < its threshold OR Sideways score < its threshold AND previous bar was sideways AND close > previous bar's range high
Short: close < EMA AND ADX > a threshold AND Sideways score < its threshold OR Sideways score < its threshold AND previous bar was sideways AND close < previous bar's range low