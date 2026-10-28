Long: Current low = lowest low over the 14-bar chart-timeframe lookback AND current RSI > lowest RSI over that lookback AND RSI 14 bars ago = that lowest RSI
Long: Smoothed up-pressure > expansion-pressure level AND (volume / 20-bar average volume - 1) × 100 > run-rate expansion level AND this condition was false on the previous bar
Long: Flow score > 50 AND previous-bar flow score ≤ 50
Short: Current high = highest high over the 14-bar chart-timeframe lookback AND current RSI < highest RSI over that lookback AND RSI 14 bars ago = that highest RSI
Short: Flow score < -50 AND previous-bar flow score ≥ -50
Calculation: Up-pressure = EMA over 14 bars of max(RSI - 50, 0) / 50 × 100
Calculation: Flow score = bullish flow score - bearish flow score; bullish flow score adds 20 for each condition true: RSI > RSI bull level, MFI > MFI bull level, up/down volume ratio > bullish threshold, close > 20-bar SMA of close, close rising over 3 bars. Bearish flow score adds 20 for each condition true: RSI < RSI weak level, MFI < 50, up/down volume ratio < bearish threshold, close < 20-bar SMA of close, close falling over 3 bars.