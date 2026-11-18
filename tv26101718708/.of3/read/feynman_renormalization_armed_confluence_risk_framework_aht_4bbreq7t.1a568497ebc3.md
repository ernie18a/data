Calculation: Long score = trend weight × I(close > EMA(close, macro lookback)) + volume weight × I(volume > SMA(volume, volume lookback)) + RSI-space weight × I(RSI(close, RSI lookback) < upper RSI cutoff) + bar-direction weight × I(close > open)
Calculation: Short score = trend weight × I(close < EMA(close, macro lookback)) + volume weight × I(volume > SMA(volume, volume lookback)) + RSI-space weight × I(RSI(close, RSI lookback) > lower RSI cutoff) + bar-direction weight × I(close < open)
Calculation: Long stop-entry level = high + ATR(ATR lookback) × stop distance
Calculation: Short stop-entry level = low − ATR(ATR lookback) × stop distance
Long: close > EMA(close, macro lookback)
Short: close < EMA(close, macro lookback)
Long: Long score ≥ minimum score
Short: Short score ≥ minimum score
Long: Long score ≥ minimum score AND position is flat or short
Short: Short score ≥ minimum score AND position is flat or long