Calculation: atr = ATR(high, low, close, atr length, T1, last completed bar)
Calculation: priorHigh(T) = high(T, last completed bar)
Calculation: priorLow(T) = low(T, last completed bar)
Calculation: touchBar(L) = first bar of the current period of the timeframe that defines L on which high >= L (low <= L for lower levels) AND (close-through touch not required OR close is beyond L)
Calculation: levelAtr(L) = atr evaluated at touchBar(L)
Calculation: upExcursion(L) = maximum of (high - L) over bars after touchBar(L)
Calculation: downExcursion(L) = maximum of (L - low) over bars after touchBar(L)
Calculation: retestStart(L) = first bar at or after touchBar(L) on which close is beyond L in the breakout direction (up for upper levels, down for lower levels) AND no reaction or breakout outcome of L resolved on an earlier bar AND current bar - touchBar(L) <= evaluation horizon AND earlier breakout outcomes of the same level kind exceed earlier reaction outcomes of the same level kind
Calculation: retestConfirm(L) = first bar b with retestStart(L) < b <= retestStart(L) + retest window + 1 on which close is beyond L in the breakout direction AND (directional confirmation not required OR close is above open for upper levels or below open for lower levels) AND the bar range overlaps L plus or minus retest zone width * levelAtr(L) on some bar from retestStart(L) through b AND no bar from retestStart(L) through b - 1 closed beyond L against the breakout direction by more than retest zone width * levelAtr(L)
Calculation: retestExit(L) = first bar after retestConfirm(L) on which price trades at least break target * levelAtr(L) beyond L in the breakout direction OR closes beyond L against the breakout direction by more than retest zone width * levelAtr(L)
Long: current bar = retestConfirm(priorHigh(T1))
Long: current bar = retestConfirm(priorHigh(T2))
Short: current bar = retestConfirm(priorLow(T1))
Short: current bar = retestConfirm(priorLow(T2))
Exit: long, current bar = retestExit(priorHigh(T1))
Exit: long, current bar = retestExit(priorHigh(T2))
Exit: short, current bar = retestExit(priorLow(T1))
Exit: short, current bar = retestExit(priorLow(T2))
Long: upExcursion(priorHigh(T1)) crosses above break target * levelAtr(priorHigh(T1)) AND downExcursion(priorHigh(T1)) < reaction target * levelAtr(priorHigh(T1)) AND current bar - touchBar(priorHigh(T1)) <= evaluation horizon
Long: upExcursion(priorHigh(T2)) crosses above break target * levelAtr(priorHigh(T2)) AND downExcursion(priorHigh(T2)) < reaction target * levelAtr(priorHigh(T2)) AND current bar - touchBar(priorHigh(T2)) <= evaluation horizon
Short: downExcursion(priorHigh(T1)) crosses above reaction target * levelAtr(priorHigh(T1)) AND upExcursion(priorHigh(T1)) < break target * levelAtr(priorHigh(T1)) AND current bar - touchBar(priorHigh(T1)) <= evaluation horizon
Short: downExcursion(priorHigh(T2)) crosses above reaction target * levelAtr(priorHigh(T2)) AND upExcursion(priorHigh(T2)) < break target * levelAtr(priorHigh(T2)) AND current bar - touchBar(priorHigh(T2)) <= evaluation horizon
Long: upExcursion(priorLow(T1)) crosses above reaction target * levelAtr(priorLow(T1)) AND downExcursion(priorLow(T1)) < break target * levelAtr(priorLow(T1)) AND current bar - touchBar(priorLow(T1)) <= evaluation horizon
Long: upExcursion(priorLow(T2)) crosses above reaction target * levelAtr(priorLow(T2)) AND downExcursion(priorLow(T2)) < break target * levelAtr(priorLow(T2)) AND current bar - touchBar(priorLow(T2)) <= evaluation horizon
Short: downExcursion(priorLow(T1)) crosses above break target * levelAtr(priorLow(T1)) AND upExcursion(priorLow(T1)) < reaction target * levelAtr(priorLow(T1)) AND current bar - touchBar(priorLow(T1)) <= evaluation horizon
Short: downExcursion(priorLow(T2)) crosses above break target * levelAtr(priorLow(T2)) AND upExcursion(priorLow(T2)) < reaction target * levelAtr(priorLow(T2)) AND current bar - touchBar(priorLow(T2)) <= evaluation horizon