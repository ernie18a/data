Calculation: ADRsafe = SMA(high[1] - low[1], adrLen) on T1 bars, last completed T1 bar value, if that is > 0, else adrFallback * close
Calculation: Tol = eqTolPct * ADRsafe / 100
Calculation: STol = slopeTolPct * ADRsafe / 100
Calculation: H3 = most recent confirmed value of PivotHigh(high, pivotLen, pivotLen)
Calculation: H2 = the confirmed PivotHigh value before H3
Calculation: H1 = the confirmed PivotHigh value before H2
Calculation: L3 = most recent confirmed value of PivotLow(low, pivotLen, pivotLen)
Calculation: L2 = the confirmed PivotLow value before L3
Calculation: L1 = the confirmed PivotLow value before L2
Calculation: SpanOK = at least three PivotHigh and three PivotLow values are confirmed AND minSpan <= max(bar of H3, bar of L3) - min(bar of H1, bar of L1) <= maxSpan
Calculation: HDir = 1 if H3 - H1 > STol, -1 if H3 - H1 < -STol, else 0
Calculation: LDir = 1 if L3 - L1 > STol, -1 if L3 - L1 < -STol, else 0
Calculation: Conv = H1 - L1 > 0 AND H3 - L3 <= convergeFrac * (H1 - L1)
Calculation: Resist = max(H1, H2, H3)
Calculation: Support = min(L1, L2, L3)
Calculation: HTri = Resist - Support
Calculation: Score(diff, h) = round(10 * ((1 - hWeight) * max(0, 1 - diff / Tol) + hWeight * min(1, h / (hScale * ADRsafe))), to one decimal)
Calculation: HS = {dir: -1, pri: 0, trig: (L2 + L3) / 2, inval: H3, h: H2 - (L2 + L3) / 2, score: Score(abs(H1 - H3), H2 - (L2 + L3) / 2)} if enableHS AND SpanOK AND H2 > H1 + Tol AND H2 > H3 + Tol AND abs(H1 - H3) <= shoulderMult * Tol, otherwise none
Calculation: IHS = {dir: 1, pri: 0, trig: (H2 + H3) / 2, inval: L3, h: (H2 + H3) / 2 - L2, score: Score(abs(L1 - L3), (H2 + H3) / 2 - L2)} if enableHS AND SpanOK AND L2 < L1 - Tol AND L2 < L3 - Tol AND abs(L1 - L3) <= shoulderMult * Tol, otherwise none
Calculation: DT = {dir: -1, pri: 1, trig: L3, inval: max(H2, H3), h: (H2 + H3) / 2 - L3, score: Score(abs(H2 - H3), (H2 + H3) / 2 - L3)} if enableDbl AND SpanOK AND abs(H2 - H3) <= Tol AND H2 > L3 + Tol AND (H2 + H3) / 2 - L3 >= dblDepthMult * Tol, otherwise none
Calculation: DB = {dir: 1, pri: 1, trig: H3, inval: min(L2, L3), h: H3 - (L2 + L3) / 2, score: Score(abs(L2 - L3), H3 - (L2 + L3) / 2)} if enableDbl AND SpanOK AND abs(L2 - L3) <= Tol AND H3 > L2 + Tol AND H3 - (L2 + L3) / 2 >= dblDepthMult * Tol, otherwise none
Calculation: AT = {dir: 1, pri: 2, trig: Resist, inval: L3, h: HTri} if enableTri AND SpanOK AND HDir = 0 AND LDir = 1, otherwise none
Calculation: DS = {dir: -1, pri: 2, trig: Support, inval: H3, h: HTri} if enableTri AND SpanOK AND LDir = 0 AND HDir = -1, otherwise none
Calculation: ST = {dir: p, pri: 3, trig: Resist if p = 1 else Support, inval: Support if p = 1 else Resist, h: HTri} where p = 1 if H1 + L1 < H3 + L3 else -1, if enableTri AND SpanOK AND HDir = -1 AND LDir = 1 AND Conv, otherwise none
Calculation: RW = {dir: -1, pri: 4, trig: L3, inval: H3, h: HTri} if enableWedge AND SpanOK AND HDir = 1 AND LDir = 1 AND Conv, otherwise none
Calculation: FW = {dir: 1, pri: 4, trig: H3, inval: L3, h: HTri} if enableWedge AND SpanOK AND HDir = -1 AND LDir = -1 AND Conv, otherwise none
Calculation: Setup = the non-none candidate among HS, IHS, DT, DB, AT, DS, ST, RW, FW with the lowest pri; if several, the one with the highest score; if still several, the first in this list
Calculation: StillPending = Pending[1] exists AND NOT (Pending[1].dir = 1 AND close > Pending[1].trig OR Pending[1].dir = -1 AND close < Pending[1].trig) AND NOT (Pending[1].dir = 1 AND low < Pending[1].inval OR Pending[1].dir = -1 AND high > Pending[1].inval) AND Pending[1] was selected no more than pendingExpiry bars before this bar
Calculation: Scan = (a PivotHigh or PivotLow value is confirmed on this bar) AND NOT StillPending AND no position is open after this bar's exit and entry checks AND bars since last entry >= minSpacing
Calculation: Pending = Setup if Scan AND Setup exists; Pending[1] if StillPending; none otherwise
Long: Pending[1].dir = 1 AND close > Pending[1].trig
Short: Pending[1].dir = -1 AND close < Pending[1].trig
Long: Scan AND Setup.dir = 1
Long: Pending.dir = 1 AND abs(close - Pending.trig) <= alProxPct * close / 100
Short: Scan AND Setup.dir = -1
Short: Pending.dir = -1 AND abs(close - Pending.trig) <= alProxPct * close / 100
Calculation: Hm = min(max(h, minHadr * ADRsafe), maxHadr * ADRsafe), with h the height of the setup that triggered the entry and ADRsafe taken on the entry bar
Calculation: LongStop = inval - slBufAdr * ADRsafe if that is below EntryPrice, else EntryPrice - slFallbackMult * slBufAdr * ADRsafe, with inval the invalidation of the setup that triggered the entry and ADRsafe taken on the entry bar
Calculation: ShortStop = inval + slBufAdr * ADRsafe if that is above EntryPrice, else EntryPrice + slFallbackMult * slBufAdr * ADRsafe, with inval the invalidation of the setup that triggered the entry and ADRsafe taken on the entry bar
Exit: long, high >= EntryPrice + tp1Mult * Hm OR high >= EntryPrice + tp2Mult * Hm OR low <= LongStop
Exit: short, low <= EntryPrice - tp1Mult * Hm OR low <= EntryPrice - tp2Mult * Hm OR high >= ShortStop