Calculation: NormHigh(x, weak, strong) = min(max((x - weak) / (strong - weak) * 100, 0), 100)
Calculation: PeakScore(x, weak, ideal, bad) = x <= ideal ? NormHigh(x, weak, ideal) : NormHigh(x, bad, ideal)
Calculation: BaseSlopeNorm = Change(EMA(close, base length), slope lookback) / ATR(ATR length)
Calculation: MomentumSmoothed = EMA(ROC(close, momentum length), smoothing length)
Calculation: VolumeVsBaseline = SMA(volume, volume length) > 0 ? volume / SMA(volume, volume length) : 1
Calculation: CloseStrength(side) = side == +1 ? (close - low) / (high - low) : (high - close) / (high - low)
Calculation: MomentumTrend(side) = chart timeframe is intraday and between T1 and T2 minutes AND side * (EMA(close, fast length) - EMA(close, base length)) > 0 AND side * (EMA(close, base length) - EMA(close, slow length)) > 0 AND side * BaseSlopeNorm >= slope threshold AND side * MomentumSmoothed >= momentum threshold
Calculation: UpperPocket(side) = side == +1 ? EMA(close, fast length) + pocket margin * ATR(ATR length) : EMA(close, base length) + pocket width * ATR(ATR length)
Calculation: LowerPocket(side) = side == +1 ? EMA(close, base length) - pocket width * ATR(ATR length) : EMA(close, fast length) - pocket margin * ATR(ATR length)
Calculation: PocketContact(side) = MomentumTrend(side) AND high >= LowerPocket(side) AND low <= UpperPocket(side)
Calculation: ResetWindowOpen(side) = MomentumTrend(side) AND BarsSince(PocketContact(+1) OR PocketContact(-1)) <= reset window
Calculation: RiskRail(side) = side == +1 ? min(LowerPocket(side), EMA(close, slow length)) - risk buffer * ATR(ATR length) : max(UpperPocket(side), EMA(close, slow length)) + risk buffer * ATR(ATR length)
Calculation: RailBreach(side) = ResetWindowOpen(side) AND side * (close - RiskRail(side)) < 0
Calculation: ContinuationTrigger(side) = bar is closed AND ResetWindowOpen(side) AND side * (close - EMA(close, fast length)) > 0 AND side * (close - open) > 0 AND CloseStrength(side) >= close strength threshold
Calculation: TargetLevel(side) = side == +1 ? Highest(high, impulse lookback) + target offset * ATR(ATR length) : Lowest(low, impulse lookback) - target offset * ATR(ATR length)
Calculation: TargetRoom(side) = side * (TargetLevel(side) - close) / ATR(ATR length)
Calculation: PullbackDepth(side) = side == +1 ? (Highest(high, impulse lookback) - low) / ATR(ATR length) : (high - Lowest(low, impulse lookback)) / ATR(ATR length)
Calculation: TrendPart(side) = NormHigh(side * BaseSlopeNorm, slope weak, slope strong) * trend slope weight + NormHigh(side * (EMA(close, fast length) - EMA(close, slow length)) / ATR(ATR length), spread weak, spread strong) * trend spread weight
Calculation: MomentumPart(side) = NormHigh(side * MomentumSmoothed, momentum weak, momentum strong) * momentum level weight + NormHigh(side * Change(MomentumSmoothed, slope lookback), momentum slope weak, momentum slope strong) * momentum slope weight
Calculation: ResetPart(side) = PeakScore(PullbackDepth(side), depth low, depth ideal, depth max) * reset depth weight + 100 * reset pocket weight
Calculation: RecoveryPart(side) = NormHigh(side * (close - EMA(close, fast length)) / ATR(ATR length), recovery distance weak, recovery distance strong) * recovery distance weight + NormHigh(CloseStrength(side), location weak, location strong) * recovery location weight
Calculation: RoomPart(side) = NormHigh(TargetRoom(side), room weak, clean target room)
Calculation: SetupScore(side) = TrendPart(side) * trend weight + MomentumPart(side) * momentum weight + ResetPart(side) * reset weight + RecoveryPart(side) * recovery weight + NormHigh(VolumeVsBaseline, volume weak, volume strong) * volume weight + RoomPart(side) * room weight
Calculation: ReadyCondition(side) = ContinuationTrigger(side) AND SetupScore(side) >= ready score AND TargetRoom(side) >= min target room
Long: ReadyCondition(+1) AND NOT ReadyCondition(+1)[1]
Short: ReadyCondition(-1) AND NOT ReadyCondition(-1)[1]
Exit: Long, RailBreach(+1)
Exit: Short, RailBreach(-1)