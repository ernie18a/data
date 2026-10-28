Calculation: Candle body-to-range percentage = abs(close - open) / (high - low) * 100, when high > low
Calculation: Bar delta = ((close - open) / (high - low), or close - open when high = low) * volume
Long: Volume exceeds a parameterized multiple of its lookback average AND high > low AND candle body-to-range percentage is at or below a parameterized maximum AND bar delta < 0
Short: Volume exceeds a parameterized multiple of its lookback average AND high > low AND candle body-to-range percentage is at or below a parameterized maximum AND bar delta > 0