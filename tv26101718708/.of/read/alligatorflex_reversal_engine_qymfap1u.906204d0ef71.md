Calculation: Jaw = EMA((high + low) / 2, long lookback)
Calculation: Teeth = EMA((high + low) / 2, medium lookback)
Calculation: Lips = EMA((high + low) / 2, short lookback)
Calculation: Line slope = current line value minus its prior-bar value
Calculation: Recent range = highest high minus lowest low over the range lookback
Calculation: Average range = SMA(recent range, same range lookback)
Calculation: Average volume = SMA(volume, volume lookback)
Long: Lips < Teeth AND Teeth < Jaw AND Jaw slope > 0 AND Teeth slope > 0 AND Lips slope > 0 AND absolute Jaw slope > slope threshold AND absolute Teeth slope > slope threshold AND absolute Lips slope > slope threshold AND Average range > 0 AND Recent range > Average range × range multiplier AND Average volume > 0 AND volume > Average volume × volume multiplier
Short: Lips > Teeth AND Teeth > Jaw AND Jaw slope < 0 AND Teeth slope < 0 AND Lips slope < 0 AND absolute Jaw slope > slope threshold AND absolute Teeth slope > slope threshold AND absolute Lips slope > slope threshold AND Average range > 0 AND Recent range > Average range × range multiplier AND Average volume > 0 AND volume > Average volume × volume multiplier