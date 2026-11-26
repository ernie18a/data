Calculation: LastHigh = price of the latest PivotHigh(high, swing length, swing length)
Calculation: LastLow = price of the latest PivotLow(low, swing length, swing length)
Calculation: LastHigherLow = price of the latest pivot low that is higher than the pivot low before it
Calculation: LastLowerHigh = price of the latest pivot high that is lower than the pivot high before it
Calculation: Equilibrium = (LastHigh + LastLow) / 2
Calculation: StructTrend = 1 if (close > LastHigh AND StructTrend[1] <= 0) OR (StructTrend[1] = -1 AND close > LastLowerHigh); -1 if (close < LastLow AND StructTrend[1] >= 0) OR (StructTrend[1] = 1 AND close < LastHigherLow); otherwise StructTrend[1]
Calculation: RegimeFactor = regime adjust / 100 if ATR(ATR length) / SMA(ATR(ATR length), regime length) > regime high; -regime adjust / 100 if that ratio < regime low; otherwise 0
Calculation: Threshold = round(score threshold + regime score points * RegimeFactor)
Calculation: InKillzone = bar time lies inside a killzone session window in the killzone timezone
Calculation: KZMult = killzone weight if killzone mode is Weight AND NOT InKillzone; otherwise 1
Calculation: BSLLevel = average price of a newly confirmed pivot high and an earlier pivot high whose prices differ by at most tolerance = max(liquidity tolerance percent / 100 * close, min liquidity tolerance ATR multiple * ATR), added only if no existing BSLLevel lies within tolerance of that average
Calculation: SSLLevel = same as BSLLevel with pivot lows and SSL levels
Calculation: SweepDir = 1 on a bar where an unswept BSLLevel L has high > L and close < L, -1 on a bar where an unswept SSLLevel L has low < L and close > L (each such level becomes swept); otherwise SweepDir[1]
Calculation: SweepAge = bars since the latest bar on which a level was swept
Calculation: NearestBSL = lowest unswept BSLLevel above close
Calculation: NearestSSL = highest unswept SSLLevel below close
Calculation: F1Long = 1 if close of T1 (last completed bar) > EMA(close, HTF EMA length, T1, last completed bar); otherwise 0
Calculation: F1Short = 1 if close of T1 (last completed bar) < EMA(close, HTF EMA length, T1, last completed bar); otherwise 0
Calculation: F2Long = 1 if StructTrend = 1 AND bars since StructTrend last changed <= structure recency; otherwise 0
Calculation: F2Short = 1 if StructTrend = -1 AND bars since StructTrend last changed <= structure recency; otherwise 0
Calculation: F3Long = 1 if SweepDir = -1 AND SweepAge <= sweep recency; otherwise 0
Calculation: F3Short = 1 if SweepDir = 1 AND SweepAge <= sweep recency; otherwise 0
Calculation: F5Long = 1 if close <= Equilibrium; otherwise 0
Calculation: F5Short = 1 if close >= Equilibrium; otherwise 0
Calculation: POIGradeLong = 1 if a bull OB overlaps the bar; else FVG grade if a bull FVG overlaps the bar; else OTE grade if the bar overlaps the OTE band; else 0. Bull OB = on a bullish BOS (close > LastHigh AND StructTrend[1] <= 0), the first bar i in 1..OB lookback with close[i] < open[i] and volume[i] / SMA(volume, volume length)[i] >= OB detection volume multiple; zone = low[i] to high[i]; active while age (bars since candle i) <= OB max age, its volume ratio >= OB volume multiple * (1 + RegimeFactor), and no close since creation has been inside the zone. Bull FVG = bar with low > high[2] and low - high[2] >= FVG min ATR multiple * (1 + RegimeFactor) * ATR; zone = high[2] to low; active while age <= FVG max age and no low since creation has reached the zone bottom. OTE band = [RangeTop - OTE far fib * Range, RangeTop - OTE near fib * Range] if StructTrend >= 0, else [RangeBot + OTE near fib * Range, RangeBot + OTE far fib * Range]; RangeTop = max(LastHigh, LastLow); RangeBot = min(LastHigh, LastLow); Range = RangeTop - RangeBot
Calculation: POIGradeShort = same as POIGradeLong with bear OB (on a bearish BOS: close < LastLow AND StructTrend[1] >= 0; first bar with close[i] > open[i]; zone = low[i] to high[i]; no close since creation inside zone), bear FVG (high < low[2] and low[2] - high >= FVG min ATR multiple * (1 + RegimeFactor) * ATR; zone = high to low[2]; no high since creation has reached the zone top), and the same OTE band
Calculation: ScoreLong = 100 * (HTF weight * KZMult * F1Long + structure weight * F2Long + sweep weight * F3Long + POI weight * POIGradeLong + zone weight * F5Long)
Calculation: ScoreShort = 100 * (HTF weight * KZMult * F1Short + structure weight * F2Short + sweep weight * F3Short + POI weight * POIGradeShort + zone weight * F5Short)
Calculation: ActiveLong = F1Long + F2Long + F3Long + (POIGradeLong > 0) + F5Long
Calculation: ActiveShort = F1Short + F2Short + F3Short + (POIGradeShort > 0) + F5Short
Calculation: EntryStopLong = LastLow - stop buffer ATR multiple * ATR if LastLow exists, else close - fallback ATR multiple * ATR
Calculation: EntryStopShort = LastHigh + stop buffer ATR multiple * ATR if LastHigh exists, else close + fallback ATR multiple * ATR
Calculation: RiskLong = max(close - EntryStopLong, min stop ATR multiple * ATR)
Calculation: RiskShort = max(EntryStopShort - close, min stop ATR multiple * ATR)
Calculation: TP2Long = NearestBSL if liquidity target on AND NearestBSL exists AND NearestBSL > close + TP1 multiple * RiskLong; otherwise close + TP2 multiple * RiskLong
Calculation: TP2Short = NearestSSL if liquidity target on AND NearestSSL exists AND NearestSSL < close - TP1 multiple * RiskShort; otherwise close - TP2 multiple * RiskShort
Calculation: TP1HitLong = 1 from the first bar after entry whose high >= entry price + TP1 multiple * RiskLong (RiskLong of the entry bar), until flat; otherwise 0
Calculation: TP1HitShort = 1 from the first bar after entry whose low <= entry price - TP1 multiple * RiskShort (RiskShort of the entry bar), until flat; otherwise 0
Calculation: StopLong = EntryStopLong on the entry bar; on later bars max(StopLong[1], candidate), where candidate = entry price if (early BE on AND high - entry price >= early BE multiple * RiskLong of the entry bar) OR TP1HitLong = 1, and candidate = LastHigherLow - stop buffer ATR multiple * ATR if (trailing on AND TP1HitLong = 1)
Calculation: StopShort = EntryStopShort on the entry bar; on later bars min(StopShort[1], candidate), where candidate = entry price if (early BE on AND entry price - low >= early BE multiple * RiskShort of the entry bar) OR TP1HitShort = 1, and candidate = LastLowerHigh + stop buffer ATR multiple * ATR if (trailing on AND TP1HitShort = 1)
Calculation: MTFStack(tf) = 1 if EMA(close, MTF short length, tf, last completed bar) > EMA(close, MTF mid length, tf, last completed bar) AND EMA(close, MTF mid length, tf, last completed bar) > EMA(close, MTF long length, tf, last completed bar); -1 if EMA(close, MTF short length, tf, last completed bar) < EMA(close, MTF mid length, tf, last completed bar) AND EMA(close, MTF mid length, tf, last completed bar) < EMA(close, MTF long length, tf, last completed bar); otherwise 0
Long: bar closed AND no position open AND long allowed AND NOT (killzone mode is Hard AND NOT InKillzone) AND NOT (HTF filter on AND F1Short = 1) AND ScoreLong >= Threshold AND ActiveLong >= min factors AND (NOT F1 required OR F1Long = 1) AND (NOT F2 required OR F2Long = 1) AND (NOT F3 required OR F3Long = 1) AND (NOT F4 required OR POIGradeLong > 0) AND (NOT F5 required OR F5Long = 1) AND RiskLong <= max stop percent / 100 * close AND TP2Long - close >= TP1 multiple * RiskLong
Short: bar closed AND no position open AND short allowed AND NOT (killzone mode is Hard AND NOT InKillzone) AND NOT (HTF filter on AND F1Long = 1) AND ScoreShort >= Threshold AND ActiveShort >= min factors AND (NOT F1 required OR F1Short = 1) AND (NOT F2 required OR F2Short = 1) AND (NOT F3 required OR F3Short = 1) AND (NOT F4 required OR POIGradeShort > 0) AND (NOT F5 required OR F5Short = 1) AND RiskShort <= max stop percent / 100 * close AND close - TP2Short >= TP1 multiple * RiskShort
Exit: long, low <= StopLong[1]
Exit: long, TP1HitLong = 1 AND TP1HitLong[1] = 0
Exit: long, high >= TP2Long of the entry bar
Exit: short, high >= StopShort[1]
Exit: short, TP1HitShort = 1 AND TP1HitShort[1] = 0
Exit: short, low <= TP2Short of the entry bar
Long: ScoreLong > ScoreShort AND ScoreLong >= Threshold AND ActiveLong >= min factors
Short: ScoreShort > ScoreLong AND ScoreShort >= Threshold AND ActiveShort >= min factors
Long: ScoreLong > ScoreShort
Short: ScoreShort > ScoreLong
Long: no position open AND ActiveLong >= preview min factors AND NOT (HTF filter on AND F1Short = 1) AND TP2Long - close >= TP1 multiple * RiskLong
Short: no position open AND ActiveShort >= preview min factors AND NOT (HTF filter on AND F1Long = 1) AND close - TP2Short >= TP1 multiple * RiskShort
Long: MTFStack(T2) = 1
Long: MTFStack(T3) = 1
Long: MTFStack(T4) = 1
Long: MTFStack(T5) = 1
Long: MTFStack(T6) = 1
Long: MTFStack(T7) = 1
Long: MTFStack(T8) = 1
Short: MTFStack(T2) = -1
Short: MTFStack(T3) = -1
Short: MTFStack(T4) = -1
Short: MTFStack(T5) = -1
Short: MTFStack(T6) = -1
Short: MTFStack(T7) = -1
Short: MTFStack(T8) = -1