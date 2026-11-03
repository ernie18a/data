Calculation: HLC3 = (high + low + close) / 3
Calculation: Anchored VWAP = sum(HLC3 × volume) / sum(volume) since the start of the selected daily, weekly, monthly, or custom session period
Calculation: Close location = (close − low) / (high − low)
Calculation: Candle body ratio = abs(close − open) / (high − low)
Calculation: VWAP distance in ATRs = abs(close − selected VWAP) / ATR
Calculation: Average volume = moving average of volume
Long: At bar close, low ≤ selected VWAP AND close > selected VWAP AND close > open AND close location ≥ its configured threshold AND candle body ratio ≥ its configured threshold AND VWAP distance in ATRs ≥ its configured threshold AND (volume is unavailable OR volume ≥ average volume) AND selected VWAP > its previous value within the same anchor period AND the configured cooldown since the last bullish or bearish marker has elapsed
Short: At bar close, high ≥ selected VWAP AND close < selected VWAP AND close < open AND close location ≤ its configured threshold AND candle body ratio ≥ its configured threshold AND VWAP distance in ATRs ≥ its configured threshold AND (volume is unavailable OR volume ≥ average volume) AND selected VWAP < its previous value within the same anchor period AND the configured cooldown since the last bullish or bearish marker has elapsed