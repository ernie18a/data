Calculation: Sideways score = sum of enabled points for low ADX, high Choppiness Index, ATR below a fraction of its longer-term average, Bollinger Band width below a fraction of its longer-term average, EMA flatness (absolute EMA change over a longer interval < ATR), and recent range width below a multiple of ATR; volume compression is disabled
Calculation: Sideways = sideways score >= configured threshold
Calculation: Recent range high = highest high over the recent range lookback
Calculation: Recent range low = lowest low over the recent range lookback
Long: previous bar was sideways AND current bar is not sideways AND close > previous bar's recent range high
Short: previous bar was sideways AND current bar is not sideways AND close < previous bar's recent range low