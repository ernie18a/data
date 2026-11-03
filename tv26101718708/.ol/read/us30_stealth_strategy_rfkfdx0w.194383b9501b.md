Calculation: Higher-low bar = current low > the lowest low over the prior short-term lookback
Calculation: Lower-high bar = current high < the highest high over the prior short-term lookback
Calculation: Bullish engulfing = current bullish candle whose body fully contains the previous candle's body
Calculation: Bearish engulfing = current bearish candle whose body fully contains the previous candle's body
Calculation: Risk distance = signal candle high minus low, halved when that range exceeds the large-candle threshold; otherwise the full range
Long: close > simple moving average AND simple moving average slope over a short-term lookback > slope threshold AND higher-low count since the last long entry is a multiple of the swing-count interval AND bullish engulfing AND volume > longer-term average volume AND high - low <= maximum candle size AND datetime hour >= session start hour OR datetime hour < session end hour
Short: close < simple moving average AND simple moving average slope over a short-term lookback < negative slope threshold AND lower-high count since the last short entry is a multiple of the swing-count interval AND bearish engulfing AND volume > longer-term average volume AND high - low <= maximum candle size AND datetime hour >= session start hour OR datetime hour < session end hour
Exit: long, low <= entry price - risk distance OR high >= entry price + reward multiple × risk distance
Exit: short, high >= entry price + risk distance OR low <= entry price - reward multiple × risk distance