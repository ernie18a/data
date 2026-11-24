Calculation: PullbackBars(d) = BarsSince(d == 1 ? low <= VWAP(Source, volume) - PocketAtr * ATR(AtrLength) : high >= VWAP(Source, volume) + PocketAtr * ATR(AtrLength))
Calculation: BullReclaim = close > VWAP(Source, volume) + ReclaimBufferAtr * ATR(AtrLength) AND close[1] <= VWAP(Source, volume) AND PullbackBars(1) <= PullbackLookback AND volume >= MinVolume
Calculation: BearReclaim = close < VWAP(Source, volume) - ReclaimBufferAtr * ATR(AtrLength) AND close[1] >= VWAP(Source, volume) AND PullbackBars(-1) <= PullbackLookback AND volume >= MinVolume
Calculation: ReclaimScore(d) = CloseWeight * min(d * (close - VWAP(Source, volume)) / (ATR(AtrLength) * CloseRef), 1) + PullbackWeight * (1 - PullbackBars(d) / PullbackLookback) + WickWeight * min((d == 1 ? min(open, close) - low : high - max(open, close)) / ((high - low) * WickRef), 1) + BodyWeight * min(abs(close - open) / ((high - low) * BodyRef), 1) + (UseVolumeScore ? VolumeWeight * min(volume / (SMA(volume, VolumeLength) * VolumeRef), 1) : VolumeFallback) + SlopeWeight * ((d * (VWAP(Source, volume) - VWAP(Source, volume)[SlopeLookback]) >= 0) ? 1 : SlopeFactor) + DistanceWeight * min(abs(close - VWAP(Source, volume)) / (ATR(AtrLength) * DistanceRef), 1)
Calculation: BullReady = BullReclaim AND ReclaimScore(1) >= ReadyScore + ConfirmOffset
Calculation: BearReady = BearReclaim AND ReclaimScore(-1) >= ReadyScore + ConfirmOffset
Calculation: BarsSinceBullReady = BarsSince(BullReady)
Calculation: BarsSinceBearReady = BarsSince(BearReady)
Long: BullReady
Long: BullReady AND ReclaimScore(1) >= LabelScore
Short: BearReady
Short: BearReady AND ReclaimScore(-1) >= LabelScore
Exit: long, BarsSinceBullReady <= ReclaimWindow AND close < VWAP(Source, volume)[BarsSinceBullReady] - ATR(AtrLength)[BarsSinceBullReady] * InvalidationAtr AND Highest(close, BarsSinceBullReady + 1) < VWAP(Source, volume)[BarsSinceBullReady] + ATR(AtrLength)[BarsSinceBullReady] * TargetTwoAtr
Exit: short, BarsSinceBearReady <= ReclaimWindow AND close > VWAP(Source, volume)[BarsSinceBearReady] + ATR(AtrLength)[BarsSinceBearReady] * InvalidationAtr AND Lowest(close, BarsSinceBearReady + 1) > VWAP(Source, volume)[BarsSinceBearReady] - ATR(AtrLength)[BarsSinceBearReady] * TargetTwoAtr