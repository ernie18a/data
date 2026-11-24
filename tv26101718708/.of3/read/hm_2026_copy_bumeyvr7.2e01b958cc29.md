Calculation: AdaptMult = clamp((ATR(ATR length) / SMA(ATR(ATR length), baseline multiple * ATR length)) ^ (-adaptation strength), min multiplier, max multiplier)
Calculation: AdaptLen(base length, minimum length) = clamp(round(base length * AdaptMult), minimum length, length cap)
Calculation: AdaptRSI = RSI(source, AdaptLen(RSI length, minimum RSI length))
Calculation: FastMA = EMA(AdaptRSI, AdaptLen(shorter MA length, minimum shorter MA length))
Calculation: SlowMA = WMA(AdaptRSI, AdaptLen(longer MA length, minimum longer MA length))
Calculation: VolumeConfirm = (cumulative volume = 0) OR (volume > volume multiplier * SMA(volume, volume length))
Calculation: BaseLong = FastMA crosses above SlowMA AND VolumeConfirm AND (AdaptRSI > RSI midline OR RSI side filter is off)
Calculation: BaseShort = FastMA crosses below SlowMA AND VolumeConfirm AND (AdaptRSI < RSI midline OR RSI side filter is off)
Calculation: HoldBars(hours) = ceil(hours * 3600 / chart bar seconds)
Calculation: PivotLowRsi = PivotLow(AdaptRSI, pivot length, pivot length)
Calculation: PivotHighRsi = PivotHigh(AdaptRSI, pivot length, pivot length)
Calculation: PrevPivot(x, p) = value of x at the most recent earlier bar where p is not na
Calculation: BarsSincePivot(p) = bars since the most recent earlier bar where p is not na
Calculation: PrevLowRsi = PrevPivot(PivotLowRsi, PivotLowRsi)
Calculation: PrevLowPrice = PrevPivot(low[pivot length], PivotLowRsi)
Calculation: LowDisp = abs(low[pivot length] - PrevLowPrice) / PrevLowPrice * 100
Calculation: PrevHighRsi = PrevPivot(PivotHighRsi, PivotHighRsi)
Calculation: PrevHighPrice = PrevPivot(high[pivot length], PivotHighRsi)
Calculation: HighDisp = abs(high[pivot length] - PrevHighPrice) / PrevHighPrice * 100
Calculation: RegimeLength = if regime auto-scale then clamp(round(regime lookback * 3600 / chart bar seconds), min regime length, max regime length) else regime lookback
Calculation: ThresholdScale = if regime auto-scale then sqrt(RegimeLength * chart bar seconds / (regime lookback * 3600)) else 1
Calculation: BullLevel = bull threshold * ThresholdScale
Calculation: BearLevel = bear threshold * ThresholdScale
Calculation: LinRegOld = LinReg(close, RegimeLength, RegimeLength - 1)
Calculation: RegimeSlope = (LinReg(close, RegimeLength, 0) - LinRegOld) / LinRegOld * 100
Long: BaseLong AND (bars since this Long was last true >= HoldBars(shorter hold hours), or never true)
Long: BaseLong AND (bars since this Long was last true >= HoldBars(longer hold hours), or never true)
Long: AdaptRSI <= reversal low level AND AdaptRSI[1] > reversal low level
Long: PivotLowRsi is not na AND BarsSincePivot(PivotLowRsi) <= max bars between pivots AND low[pivot length] < PrevLowPrice AND PivotLowRsi - PrevLowRsi >= min RSI delta AND (quality tier = All OR (PrevLowRsi <= oversold level AND (quality tier = Standard OR LowDisp >= premium displacement))) AND LowDisp >= min displacement
Long: RegimeSlope >= BullLevel AND NOT (RegimeSlope[1] >= BullLevel)
Short: BaseShort AND (bars since this Short was last true >= HoldBars(shorter hold hours), or never true)
Short: BaseShort AND (bars since this Short was last true >= HoldBars(longer hold hours), or never true)
Short: AdaptRSI >= reversal high level AND AdaptRSI[1] < reversal high level
Short: PivotHighRsi is not na AND BarsSincePivot(PivotHighRsi) <= max bars between pivots AND high[pivot length] > PrevHighPrice AND PrevHighRsi - PivotHighRsi >= min RSI delta AND (quality tier = All OR (PrevHighRsi >= overbought level AND (quality tier = Standard OR HighDisp >= premium displacement))) AND HighDisp >= min displacement
Short: RegimeSlope <= BearLevel AND NOT (RegimeSlope[1] <= BearLevel)