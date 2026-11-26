Calculation: Top = Highest(high[1], range lookback)
Calculation: Bottom = Lowest(low[1], range lookback)
Calculation: BreakThreshold = minimum break ATR * sensitivity multiplier
Calculation: BreakMargin = ATR(ATR length) * BreakThreshold
Calculation: BreakDirection = if high > Top + BreakMargin and low < Bottom - BreakMargin then (if high - Top >= Bottom - low then 1 else -1) else if high > Top + BreakMargin then 1 else if low < Bottom - BreakMargin then -1 else 0
Calculation: Scale(x, weak, strong) = clamp((x - weak) / (strong - weak) * 100, 0, 100)
Calculation: VolRatio = volume / SMA(volume, volume baseline length)
Calculation: PriorInside = (Side[1] == 1 and close < Edge[1]) or (Side[1] == -1 and close > Edge[1])
Calculation: Cleared = Side[1] != 0 and ((Result[1] == 2 and PriorInside) or (Result[1] != 0 and bar - ResultBar[1] > resolved plan bars) or (Result[1] == 0 and bar - StartBar[1] > acceptance bars and (PriorInside or bar - StartBar[1] > acceptance bars + resolved plan bars)))
Calculation: StartsNew = BreakDirection != 0 and (BreakDirection != Side[1] or Cleared or Result[1] == 1 or (Result[1] == 2 and ((BreakDirection == 1 and high > Peak[1] + BreakMargin) or (BreakDirection == -1 and low < Peak[1] - BreakMargin))) or (Result[1] == 0 and bar - StartBar[1] > acceptance bars))
Calculation: Side = if StartsNew then BreakDirection else if Cleared then 0 else Side[1]
Calculation: StartBar = if StartsNew then bar else StartBar[1]
Calculation: Edge = if StartsNew then (if BreakDirection == 1 then Top else Bottom) else Edge[1]
Calculation: Peak = if StartsNew then (if BreakDirection == 1 then high else low) else if Result[1] == 0 then (if Side == 1 then max(Peak[1], high) else min(Peak[1], low)) else Peak[1]
Calculation: Pending = Side != 0 and (StartsNew or Result[1] == 0)
Calculation: Age = bar - StartBar
Calculation: CloseInside = (Side == 1 and close < Edge) or (Side == -1 and close > Edge)
Calculation: Holding = (Side == 1 and close > Edge) or (Side == -1 and close < Edge)
Calculation: Streak = if Pending then (if Holding then (if StartsNew then 0 else Streak[1]) + 1 else 0) else Streak[1]
Calculation: CloseBeyond = max(if Side == 1 then close - Edge else Edge - close, 0) / ATR(ATR length)
Calculation: Penetration = max(if Side == 1 then Peak - Edge else Edge - Peak, 0) / ATR(ATR length)
Calculation: BodyScore = 100 * abs(close - open) / (high - low)
Calculation: QualityScore = clamp(close weight * Scale(CloseBeyond, close-beyond floor, BreakThreshold * close-beyond multiple) + depth weight * Scale(Penetration, BreakThreshold * depth floor multiple, BreakThreshold * depth multiple) + body weight * BodyScore + quality volume weight * Scale(VolRatio, quality volume floor, volume spike level * quality volume multiple), 0, 100)
Calculation: StartQuality = if StartsNew then QualityScore else StartQuality[1]
Calculation: ReclaimDist = max(if Side == 1 then Edge - close else close - Edge, 0) / ATR(ATR length)
Calculation: WickRatio = if Side == 1 then (high - max(open, close)) / (high - low) else (min(open, close) - low) / (high - low)
Calculation: InsideScore = if CloseInside then 100 else if (Side == 1 and low <= Edge) or (Side == -1 and high >= Edge) then wick-inside score else 0
Calculation: RiskScore = clamp((failure weight * Scale(Age, fast reclaim window, 0) + reclaim weight * Scale(ReclaimDist, 0, strong reclaim ATR) + wick weight * clamp(WickRatio * wick scale, 0, 100) + spike weight * Scale(VolRatio, volume spike floor, volume spike level) + inside weight * InsideScore) * (if Holding and QualityScore > risk damping quality threshold then risk damping factor else 1), 0, 100)
Calculation: TrapMark = Pending and CloseInside and RiskScore >= trap score threshold and Age <= acceptance bars
Calculation: AcceptMark = Pending and Streak >= acceptance bars and StartQuality >= accept quality threshold
Calculation: Result = if TrapMark then 1 else if AcceptMark then 2 else if Pending then 0 else Result[1]
Calculation: ResultBar = if TrapMark or AcceptMark then bar else ResultBar[1]
Long: Side == 1 and AcceptMark
Long: Side == -1 and TrapMark
Short: Side == 1 and TrapMark
Short: Side == -1 and AcceptMark