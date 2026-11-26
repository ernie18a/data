Calculation: RSI signal = MA(RSI(close, RSI lookback), signal lookback)
Calculation: Upper-band distance in points = (Upper Bollinger Band(close, band lookback, deviation) - Middle Bollinger Band(close, band lookback))/point size
Long: RSI(close, RSI lookback) > RSI signal AND Upper-band distance in points >= flat threshold 1
Short: RSI(close, RSI lookback) < RSI signal AND Upper-band distance in points >= flat threshold 1