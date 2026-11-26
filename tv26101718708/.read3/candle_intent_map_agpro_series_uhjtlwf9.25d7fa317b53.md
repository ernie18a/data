Calculation: BodyShare = abs(close - open) / (high - low)
Calculation: CloseLocation = (close - low) / (high - low)
Calculation: VolumeRatio = volume / SMA(volume, VolumeLookback)
Long: close > open AND BodyShare >= BodyMin AND CloseLocation > BullInitCloseLocMin AND VolumeRatio > VolumeMin
Long: (min(open, close) - low) / (high - low) >= WickMin AND CloseLocation > BullRejectCloseLocMin
Short: close < open AND BodyShare >= BodyMin AND CloseLocation < BearInitCloseLocMax AND VolumeRatio > VolumeMin
Short: (high - max(open, close)) / (high - low) >= WickMin AND CloseLocation < BearRejectCloseLocMax