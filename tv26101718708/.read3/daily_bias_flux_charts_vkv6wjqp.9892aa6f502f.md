Calculation: PrevHigh(Tn) = high of the last completed Tn bar, taken on chart bars
Calculation: PrevLow(Tn) = low of the last completed Tn bar, taken on chart bars
Calculation: SessionHigh(S) = highest high of bars in the most recent completed session S
Calculation: SessionLow(S) = lowest low of bars in the most recent completed session S
Calculation: SessionClose(S) = close of the last bar of the most recent completed session S
Calculation: HighLevel(src) = PrevHigh(src) for a timeframe source, SessionHigh(src) for a session source
Calculation: LowLevel(src) = PrevLow(src) for a timeframe source, SessionLow(src) for a session source
Calculation: HighSwept(S) = SessionHigh(S) > HighLevel(src) for some src in {T3, T4, T5} or any session other than S
Calculation: LowSwept(S) = SessionLow(S) < LowLevel(src) for some src in {T3, T4, T5} or any session other than S
Calculation: HighRev(S) = HighSwept(S) AND SessionClose(S) < the highest HighLevel(src) that SessionHigh(S) exceeds
Calculation: LowRev(S) = LowSwept(S) AND SessionClose(S) > the lowest LowLevel(src) that SessionLow(S) is below
Calculation: Profile(S) = Complex if HighSwept(S) AND LowSwept(S); else Bullish Reversal if LowRev(S); else Bearish Reversal if HighRev(S); else Low Sweep if LowSwept(S); else High Sweep if HighSwept(S); else Consolidation
Calculation: PrevProfile = Profile(NY) during the Asia window, Profile(Asia) during the London window, Profile(London) during the NY window
Calculation: BullStructure = close > PrevHigh(T1) OR close > PrevHigh(T2)
Calculation: BearStructure = close < PrevLow(T1) OR close < PrevLow(T2)
Calculation: SweepLow(src) = src enabled AND low crosses below LowLevel(src)
Calculation: SweepHigh(src) = src enabled AND high crosses above HighLevel(src)
Calculation: RevLow(src) = src enabled AND low < LowLevel(src) AND close > LowLevel(src)
Calculation: RevHigh(src) = src enabled AND high > HighLevel(src) AND close < HighLevel(src)
Calculation: BarEvent(src) = +1 if RevLow(src); else -1 if RevHigh(src); else 0 if SweepLow(src) OR SweepHigh(src); else none
Calculation: Remembered(src) = latest non-none BarEvent(src) on or after the last reset of src, or empty if none; src resets on the first chart bar of each new bar of src for timeframe sources, and on the bar where a new session src completes for session sources
Calculation: CurrentDir = Remembered(src) for the source with non-empty Remembered whose value changed most recently; ties go to the source listed last in T3, T4, T5, Asia, London, NY
Long: bar in a session window AND (PrevProfile = Consolidation OR PrevProfile = Low Sweep) AND CurrentDir = +1 AND (BullStructure OR structure filter off)
Long: bar in a session window AND PrevProfile = Bullish Reversal AND (BullStructure OR structure filter off)
Long: SweepLow(T3) OR SweepLow(T4) OR SweepLow(T5) OR SweepLow(Asia) OR SweepLow(London) OR SweepLow(NY)
Short: bar in a session window AND (PrevProfile = Consolidation OR PrevProfile = High Sweep) AND CurrentDir = -1 AND (BearStructure OR structure filter off)
Short: bar in a session window AND PrevProfile = Bearish Reversal AND (BearStructure OR structure filter off)
Short: SweepHigh(T3) OR SweepHigh(T4) OR SweepHigh(T5) OR SweepHigh(Asia) OR SweepHigh(London) OR SweepHigh(NY)