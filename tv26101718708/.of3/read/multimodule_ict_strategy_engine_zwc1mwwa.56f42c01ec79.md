Calculation: Resistance = most recent PivotHigh(high, S/R lookback, S/R lookback)
Calculation: Support = most recent PivotLow(low, S/R lookback, S/R lookback)
Calculation: PrevT1High = high of the last completed T1 bar, on chart bars taking values from T1
Calculation: PrevT1Low = low of the last completed T1 bar, on chart bars taking values from T1
Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: Body = abs(close - open)
Calculation: BodyRatio = Body / (high - low), or 0 when high = low
Calculation: MacroMA = EMA(close, macro length) if MA type is EMA, else SMA(close, macro length)
Calculation: BullReaction = close > open AND (open - low > pin wick multiple * Body OR (close > open[1] AND open < close[1] AND close[1] < open[1]))
Calculation: BearReaction = close < open AND (high - open > pin wick multiple * Body OR (close < open[1] AND open > close[1] AND close[1] > open[1]))
Calculation: BullBreakout = Resistance[acceptance bars - 1], set on a bar where close > Resistance on each of the last acceptance bars, provided no BullBreakout was defined at the start of any of those bars; cleared on a long retest entry
Calculation: BearBreakout = Support[acceptance bars - 1], set on a bar where close < Support on each of the last acceptance bars, provided no BearBreakout was defined at the start of any of those bars; cleared on a short retest entry
Calculation: BullDisp = close > open AND Body > ATR * displacement ATR multiple AND BodyRatio > min body ratio AND close > Resistance
Calculation: BearDisp = close < open AND Body > ATR * displacement ATR multiple AND BodyRatio > min body ratio AND close < Support
Calculation: BullZoneAge = bars since the most recent bar where BullDisp is true, 0 on that bar
Calculation: BearZoneAge = bars since the most recent bar where BearDisp is true, 0 on that bar
Calculation: BullSweep = (low[1] < PrevT1Low) OR (BullSweep[1] AND (BullReaction[1] OR any retest or SFP entry on the previous bar) AND NOT long macro-sweep entry on the previous bar)
Calculation: BearSweep = (high[1] > PrevT1High) OR (BearSweep[1] AND (BearReaction[1] OR any retest or SFP entry on the previous bar) AND NOT short macro-sweep entry on the previous bar)
Calculation: ActiveBullGaps = bull gaps g where bars since g <= gap expiry, close > bottom on every bar since g, no long FVG entry has used g, and g is among the most recent max-tracked gaps of either direction that are not expired or filled; a bull gap forms at bar g when high two bars before g < low at g, with top = low at g, bottom = high two bars before g, CE = midpoint of top and bottom
Calculation: ActiveBearGaps = bear gaps g where bars since g <= gap expiry, close < top on every bar since g, no short FVG entry has used g, and g is among the most recent max-tracked gaps of either direction that are not expired or filled; a bear gap forms at bar g when low two bars before g > high at g, with top = low two bars before g, bottom = high at g, CE = midpoint of top and bottom
Calculation: RiskDistance = ATR * stop multiplier, taken on the entry bar
Long: BullBreakout is defined AND low <= BullBreakout AND close > BullBreakout AND no open position
Long: low < PrevT1Low AND close > PrevT1Low AND no open position AND no entry already taken on this bar
Long: close > MacroMA AND BullSweep AND BullReaction AND no open position AND no entry already taken on this bar
Long: BullZoneAge <= pullback bars AND min(low[0..BullZoneAge]) >= open[BullZoneAge] AND no long displacement entry in bars 1 to BullZoneAge ago AND low <= close[BullZoneAge] AND close >= (open[BullZoneAge] + close[BullZoneAge]) / 2 AND no open position AND no entry already taken on this bar
Long: for some gap in ActiveBullGaps, low <= its CE (its top when the CE-entry option is off) AND close > its bottom AND no open position AND no entry already taken on this bar
Short: BearBreakout is defined AND high >= BearBreakout AND close < BearBreakout AND no open position AND no entry already taken on this bar
Short: high > PrevT1High AND close < PrevT1High AND no open position AND no entry already taken on this bar
Short: close < MacroMA AND BearSweep AND BearReaction AND no open position AND no entry already taken on this bar
Short: BearZoneAge <= pullback bars AND max(high[0..BearZoneAge]) <= open[BearZoneAge] AND no short displacement entry in bars 1 to BearZoneAge ago AND high >= close[BearZoneAge] AND close <= (open[BearZoneAge] + close[BearZoneAge]) / 2 AND no open position AND no entry already taken on this bar
Short: for some gap in ActiveBearGaps, high >= its CE (its bottom when the CE-entry option is off) AND close < its top AND no open position AND no entry already taken on this bar
Exit: long, low <= entry price - RiskDistance OR high >= entry price + reward-to-risk multiple * RiskDistance
Exit: short, high >= entry price + RiskDistance OR low <= entry price - reward-to-risk multiple * RiskDistance