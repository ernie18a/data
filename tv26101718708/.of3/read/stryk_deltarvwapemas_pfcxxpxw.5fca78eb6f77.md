Calculation: MultiEMA(x) = EMA applied smoothing passes times to x, each pass with smoothing length
Calculation: SmoothVWAP = MultiEMA(VWAP(hlc3, VWAP lookback))
Calculation: StdDev = MultiEMA(volume-weighted standard deviation of hlc3 over VWAP lookback)
Calculation: UpBand(k) = SmoothVWAP + k * StdDev
Calculation: LoBand(k) = SmoothVWAP - k * StdDev
Calculation: VWSlope = SmoothVWAP - SmoothVWAP[slope lookback]
Calculation: TurnUp = VWSlope > flat threshold OR VWSlope > VWSlope[slope lookback]
Calculation: TurnDn = VWSlope < -flat threshold OR VWSlope < VWSlope[slope lookback]
Calculation: Delta = buy volume - sell volume of the current bar, from footprint data if available, else summed over T1 bars inside it signed by their direction
Calculation: ClosePos = (close - low) / (high - low) of the current bar
Calculation: Edge = 1 if high >= UpBand(edge multiplier) AND low > LoBand(edge multiplier); -1 if low <= LoBand(edge multiplier) AND high < UpBand(edge multiplier); else 0
Calculation: Flow = Edge != 0 AND sign(Delta) = (Edge if MdpIsAbs, else -Edge)
Calculation: RevScore = 1 + [Flow] + [ClosePos >= strong close if Edge = -1, or ClosePos <= 1 - strong close if Edge = 1]
Calculation: ContScore = [close > SmoothVWAP if Delta > 0, or close < SmoothVWAP if Delta < 0] + [VWSlope > flat threshold if Delta > 0, or VWSlope < -flat threshold if Delta < 0] + [ClosePos >= strong close if Delta > 0, or ClosePos <= 1 - strong close if Delta < 0]
Calculation: ZScore = abs(0.6745 * (Delta - median(Delta, baseline length)) / median(abs(Delta - median(Delta, baseline length)), baseline length))
Calculation: RelVol = Volume / average Volume of the same time-of-day slot over time-of-day session count sessions, or SMA(Volume, baseline length) until warmed up
Calculation: RangeTicks = max(1, (high - low) / tick size)
Calculation: BodyTicks = max(1, abs(close - open) / tick size)
Calculation: EffR = (Volume / RangeTicks) / median(Volume / RangeTicks, baseline length)
Calculation: EffB = (Volume / BodyTicks) / median(Volume / BodyTicks, baseline length)
Calculation: AggPass = ZScore >= z threshold AND RelVol >= relvol threshold AND abs(Delta) >= delta floor
Calculation: AbsPass = RelVol >= relvol threshold AND ((EffR >= effort threshold AND RangeTicks / median(RangeTicks, baseline length) <= range threshold) OR (EffB >= effort threshold AND BodyTicks / median(BodyTicks, baseline length) <= range threshold))
Calculation: AbsScore = the larger of EffR (if its range test passes) and EffB (if its body test passes)
Calculation: AggScore = magnitude weight * abs(Delta) / median(abs(Delta), baseline length) + anomaly weight * AnomRatio + efficiency weight * (abs(Delta) / Volume) / median(abs(Delta) / Volume, baseline length), where AnomRatio = abs(Delta) / average abs(Delta) of the same time-of-day slot over time-of-day session count sessions, or ZScore until warmed up
Calculation: MdpIsAbs = AbsPass AND (NOT AggPass OR AbsScore > AggScore)
Calculation: MdpPrint = (AggPass OR AbsPass) AND (AbsScore if MdpIsAbs, else AggScore) >= the highest such score of earlier MdpPrint bars of the same type in this session, or no such bar
Calculation: LongArm = MdpPrint AND MdpIsAbs AND Edge = -1 AND Delta < 0 AND RevScore >= setup min score
Calculation: ShortArm = MdpPrint AND MdpIsAbs AND Edge = 1 AND Delta > 0 AND RevScore >= setup min score
Calculation: PendingLong = (LongArm OR ArmedLong[1]) AND NOT ShortArm AND close >= low of the arming print AND bars since arming <= reclaim window
Calculation: ArmedLong = PendingLong AND NOT (close > LoBand(edge multiplier) AND TurnUp)
Calculation: PendingShort = (ShortArm OR ArmedShort[1]) AND NOT LongArm AND close <= high of the arming print AND bars since arming <= reclaim window
Calculation: ArmedShort = PendingShort AND NOT (close < UpBand(edge multiplier) AND TurnDn)
Calculation: TrendArmLong = MdpPrint AND NOT MdpIsAbs AND Delta > 0 AND NOT Flow AND close > SmoothVWAP AND VWSlope > flat threshold AND ContScore >= setup min score
Calculation: TrendArmShort = MdpPrint AND NOT MdpIsAbs AND Delta < 0 AND NOT Flow AND close < SmoothVWAP AND VWSlope < -flat threshold AND ContScore >= setup min score
Long: PendingLong AND close > LoBand(edge multiplier) AND TurnUp
Short: PendingShort AND close < UpBand(edge multiplier) AND TurnDn
Long: TrendArmLong[trend hold count] AND for each of the last trend hold count bars: close > SmoothVWAP AND VWSlope >= -flat threshold
Short: TrendArmShort[trend hold count] AND for each of the last trend hold count bars: close < SmoothVWAP AND VWSlope <= flat threshold
Long: MdpPrint AND Delta > 0
Short: MdpPrint AND Delta < 0
Long: MdpPrint AND Flow AND Edge = -1 AND RevScore >= context min score
Short: MdpPrint AND Flow AND Edge = 1 AND RevScore >= context min score
Long: MdpPrint AND NOT MdpIsAbs AND Delta > 0 AND NOT Flow AND close > SmoothVWAP AND ContScore >= context min score
Short: MdpPrint AND NOT MdpIsAbs AND Delta < 0 AND NOT Flow AND close < SmoothVWAP AND ContScore >= context min score
Long: close crosses above SmoothVWAP OR close crosses above UpBand(alert band multiplier) OR close crosses above LoBand(alert band multiplier)
Short: close crosses below SmoothVWAP OR close crosses below UpBand(alert band multiplier) OR close crosses below LoBand(alert band multiplier)
Exit: long, close < low of the arming print bar
Exit: long, close < SmoothVWAP at the entry bar
Exit: short, close > high of the arming print bar
Exit: short, close > SmoothVWAP at the entry bar