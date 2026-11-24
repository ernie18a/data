Calculation: RowSize = max(minimum price increment, X), where X = (previous session high - previous session low) / RowsPerPriorRange if that previous session range is positive, else (this session's first bar high - low) * FallbackRangeFactor; fixed on the session's first bar
Calculation: Profile = for one session through a given bar, the count per price row of height RowSize measured from the session's first open, where each bar through that bar adds one to every row from its low to its high
Calculation: PriorPOC = center of the row with the highest Profile count of the previous session (ties to the row nearest close)
Calculation: DevelopingPOC = center of the row with the highest Profile count of the current session through this bar (ties to the row nearest close)
Calculation: PriorValueArea = rows grown one at a time from the row containing PriorPOC toward the side whose next two rows hold more previous-session Profile count (up on tie) until the grown rows hold at least ValueAreaPct of the previous session's total Profile count
Calculation: PriorVAH = top edge of the highest row of PriorValueArea
Calculation: PriorVAL = bottom edge of the lowest row of PriorValueArea
Calculation: AcceptBars = max(MinimumAcceptBars, ceiling(AcceptMinutes * 60 / chart bar length in seconds))
Calculation: AboveRun = count of consecutive bars of this session, ending at this bar, with close above PriorVAH (0 if this bar's close is not above PriorVAH)
Calculation: BelowRun = count of consecutive bars of this session, ending at this bar, with close below PriorVAL (0 if this bar's close is not below PriorVAL)
Calculation: AboveExcursionHigh = highest high over the most recent run of consecutive bars of this session with close above PriorVAH
Calculation: BelowExcursionLow = lowest low over the most recent run of consecutive bars of this session with close below PriorVAL
Calculation: AcceptUp = AboveRun >= AcceptBars AND (NOT MigrationRequired OR DevelopingPOC > PriorPOC)
Calculation: AcceptDown = BelowRun >= AcceptBars AND (NOT MigrationRequired OR DevelopingPOC < PriorPOC)
Calculation: FailUp = close >= PriorVAL AND close <= PriorVAH AND 0 < BelowRun[1] < AcceptBars (BelowRun[1] is 0 on the session's first bar)
Calculation: FailDown = close >= PriorVAL AND close <= PriorVAH AND 0 < AboveRun[1] < AcceptBars (AboveRun[1] is 0 on the session's first bar)
Calculation: LongStop = on the entry bar, PriorVAH - StopFraction * (PriorVAH - PriorVAL) for a long from AcceptUp, or min(BelowExcursionLow, low) - RowSize for a long from FailUp
Calculation: ShortStop = on the entry bar, PriorVAL + StopFraction * (PriorVAH - PriorVAL) for a short from AcceptDown, or max(AboveExcursionHigh, high) + RowSize for a short from FailDown
Calculation: LongTarget = on the entry bar, PriorVAH + TargetFraction * (PriorVAH - PriorVAL) for a long from AcceptUp, or PriorVAH for a long from FailUp
Calculation: ShortTarget = on the entry bar, PriorVAL - TargetFraction * (PriorVAH - PriorVAL) for a short from AcceptDown, or PriorVAL for a short from FailDown
Long: AcceptUp AND no earlier bar this session had AcceptUp
Long: FailUp AND no earlier bar this session had FailUp AND no earlier bar this session had BelowRun >= AcceptBars
Short: AcceptDown AND no earlier bar this session had AcceptDown
Short: FailDown AND no earlier bar this session had FailDown AND no earlier bar this session had AboveRun >= AcceptBars
Exit: long, bar after entry AND low <= LongStop
Exit: long, bar after entry AND high >= LongTarget AND low > LongStop
Exit: long, this bar starts a new session
Exit: short, bar after entry AND high >= ShortStop
Exit: short, bar after entry AND low <= ShortTarget AND high < ShortStop
Exit: short, this bar starts a new session