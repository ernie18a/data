Calculation: Smoothed RSI = 3-bar EMA of RSI
Calculation: Panic ratio = max(0, 50 − smoothed RSI) / 10 × current volume / average volume over the configured volume lookback; 0 when volume is unavailable or zero
Calculation: FOMO ratio = max(0, smoothed RSI − 50) / 10 × current volume / average volume over the configured volume lookback; 0 when volume is unavailable or zero
Calculation: Momentum reading = 100 + ((close − lowest low over 5 bars) / (highest high over 5 bars − lowest low over 5 bars) − 0.5) × 4; 100 when the range is zero
Long: smoothed RSI crosses above the configured oversold level AND panic ratio is not above the configured threshold OR momentum reading is below the configured oversold threshold OR panic ratio > configured threshold AND close < open OR close > macro SMA AND macro SMA > its value 5 bars earlier
Short: momentum reading is above the configured overbought threshold OR smoothed RSI crosses below the configured overbought level AND FOMO ratio is not above the configured threshold OR FOMO ratio > configured threshold AND close > open AND abs(close − 5-bar EMA of close) > ATR OR close < macro SMA AND macro SMA < its value 5 bars earlier
Exit: