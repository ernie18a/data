Calculation: CyclicRSI = (2/(SmoothLength+1))*(2*RSI(close, CycleLength/2) - RSI(close, CycleLength/2)[floor((SmoothLength-1)/2)]) + (1 - 2/(SmoothLength+1))*CyclicRSI[1]
Calculation: RangeHigh = MAX(0, Highest(CyclicRSI, 2*CycleLength))
Calculation: RangeLow = MIN(0, Lowest(CyclicRSI, 2*CycleLength))
Calculation: UpperBand = RangeHigh - k*(RangeHigh-RangeLow)/GridSteps for the smallest k in 0..GridSteps such that at least LevelPercent/100 of the last 2*CycleLength values of CyclicRSI are >= that value
Calculation: LowerBand = RangeLow + k*(RangeHigh-RangeLow)/GridSteps for the smallest k in 0..GridSteps such that at least LevelPercent/100 of the last 2*CycleLength values of CyclicRSI are < that value
Calculation: Peak(x, n) = x[0] < x[1] AND x[k] > x[k+1] for every k from 1 to n-1
Calculation: Trough(x, n) = x[0] > x[1] AND x[k] < x[k+1] for every k from 1 to n-1
Calculation: CandidateA = Trough(CyclicRSI, PivotLookback) AND CyclicRSI[1] < LowerBand[1]
Calculation: CandidateB = Peak(CyclicRSI, PivotLookback) AND (CyclicRSI[1] < WMA(CyclicRSI, MALength)[1] OR CyclicRSI[1] < MidLevel)
Calculation: CandidateC = CandidateA OR (Trough(CyclicRSI, PivotLookback) AND CyclicRSI[1] < WMA(CyclicRSI, MALength)[1])
Calculation: LowPivot = CandidateA OR CandidateC
Calculation: HighPivot = Peak(CyclicRSI, PivotLookback) AND (CyclicRSI[1] >= UpperBand[1] OR (CyclicRSI[1] < UpperBand[1] AND CyclicRSI > WMA(CyclicRSI, MALength)))
Calculation: Seq(T, P) = T AND the most recent bar i in 1..SearchLookback with P[i] true exists and CyclicRSI < WMA(CyclicRSI, MALength) on every bar from 1 through i
Calculation: AB = Seq(CandidateB, CandidateA)
Calculation: ABC = Seq(CandidateC, AB)
Calculation: ABCD = Seq(CandidateB, ABC)
Calculation: ABCDE = Seq(CandidateC, ABCD)
Calculation: ABCDEF = Seq(CandidateB, ABCDE)
Calculation: ABCDEFG = Seq(CandidateC, ABCDEF)
Calculation: StageA = CandidateA AND NOT ABC AND NOT ABCDE
Calculation: LastCyclicRSI(E) = CyclicRSI[i] for the most recent i in 1..SearchLookback with E[i] true (undefined if none; comparisons with undefined are false)
Calculation: LastClose(E) = close[i] for the same i as LastCyclicRSI(E)
Calculation: RegularBullDiv = LowPivot AND CyclicRSI > LastCyclicRSI(LowPivot) AND close <= LastClose(LowPivot)
Calculation: BullCross = CyclicRSI >= WMA(CyclicRSI, MALength) AND CyclicRSI[1] < WMA(CyclicRSI, MALength)[1]
Calculation: BandMA(x) = VWMA(x, BandLength) if VolumeWeighted, else WMA(x, BandLength)
Calculation: SessionOK = NOT SessionsEnabled OR ((hour(datetime), minute(datetime)) >= (Session1StartHour, Session1StartMinute) AND (hour(datetime), minute(datetime)) < (Session1StopHour, Session1StopMinute)) OR ((hour(datetime), minute(datetime)) >= (Session2StartHour, Session2StartMinute) AND (hour(datetime), minute(datetime)) < (Session2StopHour, Session2StopMinute))
Calculation: LongEvent = (BullCross OR (StageA AND RegularBullDiv) OR (ABC AND RegularBullDiv) OR (ABCDE AND PivotLookback == LongerPivotLookback) OR (ABCDEFG AND PivotLookback == ShorterPivotLookback)) AND NOT (LongEvent[1] OR ... OR LongEvent[SuppressWindow])
Calculation: ShortEvent = ((Peak(CyclicRSI, PivotLookback) AND CyclicRSI[1] >= UpperBand[1]) OR (CyclicRSI < CyclicRSI[1] AND (CyclicRSI >= UpperBand OR CyclicRSI[1] >= UpperBand[1] OR CyclicRSI[2] >= UpperBand[2]))) AND UpperBand > HighLevel AND NOT (ShortEvent[1] OR ... OR ShortEvent[SuppressWindow])
Long: LongEvent AND SessionOK
Short: ShortEvent AND SessionOK
Long: BullCross
Short: CyclicRSI < WMA(CyclicRSI, MALength) AND CyclicRSI[1] >= WMA(CyclicRSI, MALength)[1]
Long: CyclicRSI >= WMA(CyclicRSI, MALength)
Short: CyclicRSI < WMA(CyclicRSI, MALength)
Long: close > BandMA(high)
Short: close < BandMA(low)
Long: RegularBullDiv
Long: LowPivot AND CyclicRSI <= LastCyclicRSI(LowPivot) AND close > LastClose(LowPivot)
Short: HighPivot AND CyclicRSI <= LastCyclicRSI(HighPivot) AND close > LastClose(HighPivot)
Short: HighPivot AND CyclicRSI > LastCyclicRSI(HighPivot) AND close <= LastClose(HighPivot)
Exit: long, (CloseSession1 AND hour(datetime) == Session1StopHour AND minute(datetime) >= Session1StopMinute) OR (CloseSession2 AND hour(datetime) == Session2StopHour AND minute(datetime) >= Session2StopMinute)
Exit: short, (CloseSession1 AND hour(datetime) == Session1StopHour AND minute(datetime) >= Session1StopMinute) OR (CloseSession2 AND hour(datetime) == Session2StopHour AND minute(datetime) >= Session2StopMinute)