Calculation: AnchorWindow = last lookback bars if anchor mode is rolling or no in-session bar lies within the last lookback bars, else the contiguous run of in-session bars ending at the latest in-session bar, restricted to the last lookback bars
Calculation: BarDelta = volume * (CloseWeight * CLV(high, low, close) + WickWeight * CLV(high, low, close) + BodyWeight * (close - open) / (high - low))
Calculation: NetDeltaRatio = Sum(BarDelta, AnchorWindow) / Sum(volume, AnchorWindow)
Calculation: PriceOffsetFromVWAP = (close - AnchoredVWAP(typical price, volume, AnchorWindow)) / (Highest(high, AnchorWindow) - Lowest(low, AnchorWindow))
Calculation: RangePosition = (close - Lowest(low, AnchorWindow)) / (Highest(high, AnchorWindow) - Lowest(low, AnchorWindow))
Long: NetDeltaRatio > bias band
Short: NetDeltaRatio < -bias band
Long: PriceOffsetFromVWAP < -vwap band
Short: PriceOffsetFromVWAP > vwap band
Long: RangePosition > upper range threshold
Short: RangePosition < lower range threshold