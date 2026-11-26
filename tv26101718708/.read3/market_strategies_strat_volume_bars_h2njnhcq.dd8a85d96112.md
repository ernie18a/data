Calculation: Body strength = high > low ? abs(close - open) / (high - low) * 100 : 0
Calculation: Close position = high > low ? (close - low) / (high - low) * 100 : 50
Calculation: Elevated volume = SMA(volume, average volume lookback) is defined AND volume >= SMA(volume, average volume lookback) * volume multiplier
Long: high > high[1] AND low >= low[1] OR Elevated volume AND close > open AND Close position >= close-position threshold AND Body strength >= body-strength threshold
Short: low < low[1] AND high <= high[1] OR Elevated volume AND close < open AND Close position <= 100 - close-position threshold AND Body strength >= body-strength threshold