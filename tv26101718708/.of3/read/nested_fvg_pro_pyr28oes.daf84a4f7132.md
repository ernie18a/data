Calculation: BullZone = on T1 bars, with last completed T1 bar as [0]: T1 low[0] > T1 high[2] AND T1 low[0] - T1 high[2] >= MinGapT1 AND in session; zone bottom = T1 high[2], zone top = T1 low[0]
Calculation: BearZone = on T1 bars, with last completed T1 bar as [0]: T1 high[0] < T1 low[2] AND T1 low[2] - T1 high[0] >= MinGapT1 AND in session; zone top = T1 low[2], zone bottom = T1 high[0]
Calculation: ActiveZone = a BullZone or BearZone (current direction, possibly flipped) that is not retired; a zone is violated on a chart bar when chart close < zone bottom if bullish or chart close > zone top if bearish (ViolationMode may instead test low <= top or low <= midpoint if bullish, high >= bottom or high >= midpoint if bearish); a zone's first violation retires it unless AllowInverted AND it is not older than MaxZoneAge (if set), in which case it flips direction and becomes inverted; an inverted zone is retired at its next violation or InvMaxAge chart bars after inversion (if set); any zone is retired MaxZoneAge chart bars after formation (if set); per direction only the newest MaxZones active zones remain (if set)
Calculation: LongSignal = low > high[2] AND low - high[2] >= MinGap1 AND an ActiveZone with bullish direction exists such that ((zone never violated AND AllowVirgin) OR (zone inverted AND AllowInverted)) AND high[2] >= zone bottom - Prox AND low <= zone top + Prox
Calculation: ShortSignal = high < low[2] AND low[2] - high >= MinGap1 AND an ActiveZone with bearish direction exists such that ((zone never violated AND AllowVirgin) OR (zone inverted AND AllowInverted)) AND high >= zone bottom - Prox AND low[2] <= zone top + Prox
Calculation: GapFar = far edge of the 1-min gap on the signal bar: high[2] for a long signal, low[2] for a short signal
Calculation: GapMid = midpoint of the 1-min gap on the signal bar: (low + high[2]) / 2 for a long signal, (high + low[2]) / 2 for a short signal
Calculation: EntryPrice = close of the signal bar when NOT PullbackEntry AND AnchorToEntryFill, otherwise GapFar
Calculation: StopLevel = EntryPrice - StopDist for a long, EntryPrice + StopDist for a short; once a partial exit has occurred on an earlier bar and BreakEvenAtPartial is on, StopLevel = average entry price instead
Long: NOT PullbackEntry AND bar time in session AND (NOT WindowsEnabled OR bar time in an enabled trading window) AND bars since last Long or Short signal >= Cooldown AND no trade open or pending AND LongSignal
Short: NOT PullbackEntry AND bar time in session AND (NOT WindowsEnabled OR bar time in an enabled trading window) AND bars since last Long or Short signal >= Cooldown AND no trade open or pending AND ShortSignal
Long: PullbackEntry AND a long entry is pending from an earlier long signal, not yet filled or cancelled, AND low <= EntryPrice AND (NOT PartialCancel OR no bar since that signal had high >= EntryPrice + PartialDist)
Short: PullbackEntry AND a short entry is pending from an earlier short signal, not yet filled or cancelled, AND high >= EntryPrice AND (NOT PartialCancel OR no bar since that signal had low <= EntryPrice - PartialDist)
Long: NOT PullbackEntry AND LadderEnabled AND leg 2 enabled AND leg 2 not yet filled AND position side long AND no partial exit yet AND low <= GapMid
Long: NOT PullbackEntry AND LadderEnabled AND leg 3 enabled AND leg 3 not yet filled AND position side long AND no partial exit yet AND low <= GapFar
Short: NOT PullbackEntry AND LadderEnabled AND leg 2 enabled AND leg 2 not yet filled AND position side short AND no partial exit yet AND high >= GapMid
Short: NOT PullbackEntry AND LadderEnabled AND leg 3 enabled AND leg 3 not yet filled AND position side short AND no partial exit yet AND high >= GapFar
Exit: long, low <= StopLevel
Exit: long, high >= EntryPrice + PartialDist AND no partial exit yet
Exit: long, high >= EntryPrice + TargetDist AND no target exit yet
Exit: long, high >= EntryPrice + ExtDist AND no extended exit yet
Exit: long, RunnerEnabled AND high >= EntryPrice + RunnerDist
Exit: long, MaxLossEnabled AND (close - average entry price) * open contracts * DollarPerPoint < -MaxLoss
Exit: short, high >= StopLevel
Exit: short, low <= EntryPrice - PartialDist AND no partial exit yet
Exit: short, low <= EntryPrice - TargetDist AND no target exit yet
Exit: short, low <= EntryPrice - ExtDist AND no extended exit yet
Exit: short, RunnerEnabled AND low <= EntryPrice - RunnerDist
Exit: short, MaxLossEnabled AND (average entry price - close) * open contracts * DollarPerPoint < -MaxLoss