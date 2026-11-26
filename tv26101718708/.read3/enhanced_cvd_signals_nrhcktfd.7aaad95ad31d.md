Calculation: CVD = running sum over completed T2 bars of signed volume, where signed volume is +volume if T2 close > T2 open, -volume if T2 close < T2 open, else +volume if T2 close >= previous T2 close and -volume otherwise; the sum resets at the start of each T1 bar (or at each session start in session anchor mode)
Calculation: CVDOpen = CVD at the start of the chart bar
Calculation: CVDHigh = highest CVD during the chart bar, including CVDOpen
Calculation: CVDLow = lowest CVD during the chart bar, including CVDOpen
Calculation: CVDClose = CVD at the end of the chart bar
Calculation: Delta = CVDClose - CVDOpen
Calculation: MeanAbsDelta = SMA(abs(Delta), delta average length)
Calculation: DeltaVsMean = Delta / MeanAbsDelta
Calculation: ATR = ATR(ATR period)
Calculation: MoveInATR = (close - open) / ATR
Calculation: AtRecentHigh(L) = Highest(high, N) >= Highest(high, L), where N is the near-extreme window parameter
Calculation: AtRecentLow(L) = Lowest(low, N) <= Lowest(low, L), where N is the near-extreme window parameter
Calculation: RunBars = count of consecutive bars ending at the current bar whose Delta is nonzero with the same sign as Delta; 0 if Delta = 0
Calculation: RunDelta = sum of Delta over those bars; 0 if Delta = 0
Calculation: AbsDeltaRank = PercentRank(abs(Delta), climax lookback)
Calculation: MeanCVDRange = SMA(CVDHigh - CVDLow, reversal average length)
Calculation: UpExcursion = CVDHigh - CVDOpen
Calculation: DownExcursion = CVDOpen - CVDLow
Calculation: DisplayedClose = (CVDOpen + CVDHigh + CVDLow + CVDClose) / 4 for Heikin-Ashi candles; LinReg(CVDClose, linear regression length) for linear-regression candles; CVDClose for regular candles
Calculation: DisplayedOpen = Heikin-Ashi open of the CVD bars (CVDOpen at each CVD reset, else average of previous Heikin-Ashi open and previous Heikin-Ashi close) for Heikin-Ashi candles; LinReg(CVDOpen, linear regression length) for linear-regression candles; CVDOpen for regular candles
Calculation: Spaced(C, n) = C AND (no earlier bar had Spaced(C, n) true, or the latest such bar is at least n bars before the current bar)
Long: Spaced(DeltaVsMean <= -absorption delta multiple AND -MoveInATR <= absorption max progress AND (absorption swing filter off OR AtRecentLow(absorption swing lookback)), absorption cooldown)
Short: Spaced(DeltaVsMean >= absorption delta multiple AND MoveInATR <= absorption max progress AND (absorption swing filter off OR AtRecentHigh(absorption swing lookback)), absorption cooldown)
Long: Spaced(close > open AND DisplayedClose < DisplayedOpen, absorption cooldown)
Short: Spaced(close < open AND DisplayedClose > DisplayedOpen, absorption cooldown)
Long: Spaced(Delta > 0 AND Delta[1] < 0 AND RunBars[1] >= turnaround min run AND Delta >= turnaround delta multiple * MeanAbsDelta AND Delta >= turnaround retrace * abs(RunDelta[1]) AND close - open >= turnaround min body * ATR AND (turnaround break filter off OR close > high[1]), turnaround cooldown)
Short: Spaced(Delta < 0 AND Delta[1] > 0 AND RunBars[1] >= turnaround min run AND -Delta >= turnaround delta multiple * MeanAbsDelta AND -Delta >= turnaround retrace * abs(RunDelta[1]) AND open - close >= turnaround min body * ATR AND (turnaround break filter off OR close < low[1]), turnaround cooldown)
Long: Spaced(AbsDeltaRank >= climax percentile AND Delta < 0 AND (climax swing filter off OR AtRecentLow(climax swing lookback)) AND (climax min rejection <= 0 OR (close - low) / (high - low) >= climax min rejection), climax cooldown)
Short: Spaced(AbsDeltaRank >= climax percentile AND Delta > 0 AND (climax swing filter off OR AtRecentHigh(climax swing lookback)) AND (climax min rejection <= 0 OR (high - close) / (high - low) >= climax min rejection), climax cooldown)
Long: Spaced(MeanCVDRange > 0 AND DownExcursion >= reversal push multiple * MeanCVDRange AND DownExcursion > UpExcursion AND (CVDClose - CVDLow) >= reversal give-back * DownExcursion AND (reversal swing filter off OR AtRecentLow(reversal swing lookback)), reversal cooldown)
Short: Spaced(MeanCVDRange > 0 AND UpExcursion >= reversal push multiple * MeanCVDRange AND UpExcursion > DownExcursion AND (CVDHigh - CVDClose) >= reversal give-back * UpExcursion AND (reversal swing filter off OR AtRecentHigh(reversal swing lookback)), reversal cooldown)