Calculation: Candle pressure balance = 100 * ((close - low) - (high - close)) / (high - low + a small positive constant).
Calculation: Session VWAP = cumulative sum of close * volume divided by cumulative volume, reset at the start of each trading session.
Long: Candle pressure balance > positive pressure threshold.
Short: Candle pressure balance <= negative pressure threshold.
Long: Close > session VWAP AND (volume > short-lookback SMA of volume * spike multiplier OR short-lookback SMA of volume / long-lookback SMA of volume > expansion threshold).
Short: Close < session VWAP AND (volume > short-lookback SMA of volume * spike multiplier OR short-lookback SMA of volume / long-lookback SMA of volume > expansion threshold).