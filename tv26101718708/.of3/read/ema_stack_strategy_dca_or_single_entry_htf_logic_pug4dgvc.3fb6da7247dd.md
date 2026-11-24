Calculation: MA_k = type_k(source_k, length_k) computed on T1 bars from the last completed T1 bar and taken by chart bars, for k = 1 to 4
Calculation: Atr = ATR(length) computed on T1 bars from the last completed T1 bar and taken by chart bars
Calculation: NewT1Bar = this chart bar is the first chart bar of a T1 bar
Calculation: StackLong = MA_1 > MA_2 AND (NOT use_MA_3 OR MA_2 > MA_3) AND (NOT (use_MA_3 AND use_MA_4) OR MA_3 > MA_4), evaluated on T1 bars, where [n] is n completed T1 bars ago
Calculation: StackShort = MA_1 < MA_2 AND (NOT use_MA_3 OR MA_2 < MA_3) AND (NOT (use_MA_3 AND use_MA_4) OR MA_3 < MA_4), evaluated on T1 bars, where [n] is n completed T1 bars ago
Calculation: InWindow(start, end, time zone) = bar time in time zone, as minutes since midnight, is >= start and <= end, or if start > end is >= start or <= end
Calculation: BlockNew = (enabled_1 AND InWindow(start_1, end_1, time zone)) OR (enabled_2 AND InWindow(start_2, end_2, time zone)) OR (enabled_3 AND InWindow(start_3, end_3, time zone))
Calculation: Dist(mode, price, units, pct, atr multiple) = units * unit size if mode is Units; price * pct / 100 if mode is Percent; Atr * atr multiple if mode is ATR
Calculation: AvgEntry = average entry price of the current position
Calculation: Anchor = base entry price if DCA anchor mode is First Entry, else AvgEntry
Calculation: Entries = number of entries in the current position, counting the base entry and each DCA add
Calculation: CashUsed = base order size plus the sizes of DCA adds in the current position
Calculation: LastEntry = base entry price, or the DCA level of the latest DCA add
Calculation: DcaStep = Dist(DCA distance mode, Anchor, base units, base pct, base ATR multiple) * sum of step scale^j for j = 0 to Entries - 1
Calculation: Peak = highest high since entry if long, or lowest low since entry if short, including the current bar
Calculation: Excursion = Peak - AvgEntry if long, or AvgEntry - Peak if short
Calculation: TrailArmed(d) = in position AND (TrailArmed(d)[1] OR Excursion >= d), where [1] is the previous chart bar
Calculation: BEArmed = BE enabled AND in position AND (BEArmed[1] OR Excursion >= Dist(BE trigger mode, AvgEntry, BE trigger units, BE trigger pct, BE trigger ATR multiple)), where [1] is the previous chart bar
Calculation: BEStop = AvgEntry + BE offset units * unit size if long, or AvgEntry - BE offset units * unit size if short
Calculation: RRStop = if long, AvgEntry - Atr * R:R ATR multiple or Lowest(low, swing lookback) - swing buffer * unit size; if short, AvgEntry + Atr * R:R ATR multiple or Highest(high, swing lookback) + swing buffer * unit size; ATR or swing chosen by R:R stop method
Long: flat AND NewT1Bar AND StackLong[i] for all i from 0 to stack hold closes AND NOT BlockNew
Short: flat AND NewT1Bar AND StackShort[i] for all i from 0 to stack hold closes AND NOT BlockNew
Long: NewT1Bar AND StackLong[i] for all i from 0 to stack hold closes AND NOT StackLong[stack hold closes + 1]
Short: NewT1Bar AND StackShort[i] for all i from 0 to stack hold closes AND NOT StackShort[stack hold closes + 1]
Long: long position AND DCA mode AND DCA adds enabled AND Entries < max entries AND NOT (block DCA in windows AND BlockNew) AND CashUsed < max total cash AND low <= Anchor - DcaStep
Short: short position AND DCA mode AND DCA adds enabled AND Entries < max entries AND NOT (block DCA in windows AND BlockNew) AND CashUsed < max total cash AND high >= Anchor + DcaStep
Exit: Long, DCA mode AND DCA exit type is breakeven AND high >= AvgEntry + Dist(TP mode, AvgEntry, TP units, TP pct, TP ATR multiple)
Exit: Short, DCA mode AND DCA exit type is breakeven AND low <= AvgEntry - Dist(TP mode, AvgEntry, TP units, TP pct, TP ATR multiple)
Exit: Long, DCA mode AND DCA exit type is after last DCA AND Entries >= max entries AND high >= LastEntry + Dist(last-exit mode, LastEntry, last-exit units, last-exit pct)
Exit: Short, DCA mode AND DCA exit type is after last DCA AND Entries >= max entries AND low <= LastEntry - Dist(last-exit mode, LastEntry, last-exit units, last-exit pct)
Exit: Long, DCA mode AND DCA trailing enabled AND TrailArmed(Dist(trail activation mode, AvgEntry, trail activation units, trail activation pct, trail activation ATR multiple)) AND low <= Peak - Dist(trail distance mode, AvgEntry, trail distance units, trail distance pct, trail distance ATR multiple)
Exit: Short, DCA mode AND DCA trailing enabled AND TrailArmed(Dist(trail activation mode, AvgEntry, trail activation units, trail activation pct, trail activation ATR multiple)) AND high >= Peak + Dist(trail distance mode, AvgEntry, trail distance units, trail distance pct, trail distance ATR multiple)
Exit: Long, DCA mode AND MA kill switch enabled AND DCA exit type is breakeven AND closed chart bar AND MA_1 < MA_2
Exit: Short, DCA mode AND MA kill switch enabled AND DCA exit type is breakeven AND closed chart bar AND MA_1 > MA_2
Exit: Long, single-entry mode AND single trailing enabled AND TrailArmed(Dist(single trail activation mode, AvgEntry, single trail activation units, single trail activation pct, single trail activation ATR multiple)) AND low <= Peak - Dist(single trail distance mode, AvgEntry, single trail distance units, single trail distance pct, single trail distance ATR multiple)
Exit: Short, single-entry mode AND single trailing enabled AND TrailArmed(Dist(single trail activation mode, AvgEntry, single trail activation units, single trail activation pct, single trail activation ATR multiple)) AND high >= Peak + Dist(single trail distance mode, AvgEntry, single trail distance units, single trail distance pct, single trail distance ATR multiple)
Exit: Long, single-entry mode AND exit type is MA cross AND closed chart bar AND MA_1 crosses below MA_2
Exit: Short, single-entry mode AND exit type is MA cross AND closed chart bar AND MA_1 crosses above MA_2
Exit: Long, single-entry mode AND exit type is time stop AND closed chart bars in position >= time stop bars
Exit: Short, single-entry mode AND exit type is time stop AND closed chart bars in position >= time stop bars
Exit: Long, single-entry mode AND exit type is ATR bracket AND (low <= max(AvgEntry - Atr * single ATR stop multiple, BEStop if BEArmed) OR high >= AvgEntry + Atr * single ATR target multiple)
Exit: Short, single-entry mode AND exit type is ATR bracket AND (high >= min(AvgEntry + Atr * single ATR stop multiple, BEStop if BEArmed) OR low <= AvgEntry - Atr * single ATR target multiple)
Exit: Long, single-entry mode AND exit type is risk-reward bracket AND (low <= max(RRStop, BEStop if BEArmed) OR high >= AvgEntry + (AvgEntry - RRStop) * risk-reward ratio)
Exit: Short, single-entry mode AND exit type is risk-reward bracket AND (high >= min(RRStop, BEStop if BEArmed) OR low <= AvgEntry - (RRStop - AvgEntry) * risk-reward ratio)
Exit: Long, single-entry mode AND exit type is percent bracket AND (low <= max(AvgEntry * (1 - single stop pct / 100), BEStop if BEArmed) OR high >= AvgEntry * (1 + single target pct / 100))
Exit: Short, single-entry mode AND exit type is percent bracket AND (high >= min(AvgEntry * (1 + single stop pct / 100), BEStop if BEArmed) OR low <= AvgEntry * (1 - single target pct / 100))
Exit: Long, MA_1 crosses below MA_2
Exit: Short, MA_1 crosses above MA_2