Calculation: VolumeRatio = volume / SMA(volume, volume lookback), undefined when that SMA is 0
Calculation: DirectionRef = close[1] if previous-close flag is on, else open
Calculation: BodyOK = body filter is off OR 100 * abs(close - open) / (high - low) >= min body percent, where that ratio is 0 when high = low
Calculation: AlertThreshold = the confirm, strong or extreme threshold that the minimum-alert-strength parameter selects
Long: close >= DirectionRef
Short: close < DirectionRef
Long: alerts enabled AND (current bar is closed OR confirm-on-close is off) AND close >= DirectionRef AND ((VolumeRatio >= AlertThreshold AND BodyOK) OR (VolumeRatio >= extreme threshold AND (BodyOK OR extreme-weak-body flag is on)))
Short: alerts enabled AND (current bar is closed OR confirm-on-close is off) AND close < DirectionRef AND ((VolumeRatio >= AlertThreshold AND BodyOK) OR (VolumeRatio >= extreme threshold AND (BodyOK OR extreme-weak-body flag is on)))