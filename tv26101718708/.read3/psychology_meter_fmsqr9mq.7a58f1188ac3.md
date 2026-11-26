Calculation: RelativeVolume = volume / SMA(volume, volume average lookback)[1]
Calculation: CloseLocation = (close - low) / (high - low)
Calculation: UpVolumeShare = SUM(volume where close > close[1], up-volume lookback) / SUM(volume, up-volume lookback)
Calculation: TickDirection(T1 bar) = 1 if close > open, else -1 if close < open, else 1 if close > close[1], else -1 if close < close[1], else TickDirection[1]
Calculation: LargeVolumeThreshold = large-bar multiplier * average volume of the T1 bars inside the last completed chart bar
Calculation: LargeBarCount = count of T1 bars inside the last completed chart bar where volume >= LargeVolumeThreshold
Calculation: LargeBuyVolume = sum of volume of T1 bars inside the last completed chart bar where volume >= LargeVolumeThreshold AND TickDirection = 1
Calculation: LargeSellVolume = sum of volume of T1 bars inside the last completed chart bar where volume >= LargeVolumeThreshold AND TickDirection = -1
Long: close > close[1] AND close > Highest(high, prior-high lookback)[1] AND RelativeVolume >= breakout volume multiplier
Long: close > close[1] AND close[1] < close[2] AND RelativeVolume[1] >= climax volume multiplier AND RSI(close, RSI lookback)[1] < RSI panic threshold AND CloseLocation[1] >= close-location threshold
Long: LargeBarCount >= minimum large-bar count AND LargeBuyVolume >= dominance ratio * LargeSellVolume AND LargeBuyVolume > 0
Short: close < close[1] AND RelativeVolume >= climax volume multiplier AND RSI(close, RSI lookback) < RSI panic threshold
Short: LargeBarCount >= minimum large-bar count AND LargeSellVolume >= dominance ratio * LargeBuyVolume AND LargeSellVolume > 0
Short: UpVolumeShare < up-volume threshold AND close < SMA(close, price average lookback) AND NOT (UpVolumeShare[1] < up-volume threshold AND close[1] < SMA(close, price average lookback)[1])