Calculation: signed volume = volume if change(source) > 0, -volume if change(source) < 0, otherwise 0
Long: signed volume crosses above -SMA(volume, lookback) AND datetime is within the configured date window
Short: signed volume crosses below SMA(volume, lookback) AND datetime is within the configured date window
Exit: long, signed volume crosses above SMA(volume, lookback) AND datetime is within the configured date window
Exit: short, signed volume crosses below -SMA(volume, lookback) AND datetime is within the configured date window