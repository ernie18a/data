Calculation: AnchorBar(y) = the T1 bar dated nearest the month and day of the last completed T1 bar, y years earlier, if within a day tolerance, else undefined; computed on T1 bars and taken by chart bars
Calculation: YearReturn(y, k) = (close at offset k+1 / close at offset k) - 1, where offset j is the T1 bar j bars after AnchorBar(y) (negative j means before); undefined if AnchorBar(y) or either bar is undefined
Calculation: SeasonalReturn(k) = mean of YearReturn(y, k) over y from 1 to profile lookback years, skipping undefined values
Calculation: SmoothedReturn(k) = mean of SeasonalReturn(j) over j from k - floor(smoothing length / 2) to k + floor(smoothing length / 2), limited to j from -past profile days to future profile days, skipping undefined values
Calculation: SignAgreement(k) = max(count of y from 1 to profile lookback years where YearReturn(y, k) > 0, count where YearReturn(y, k) < 0) / count of y where YearReturn(y, k) is defined; undefined if none is defined
Calculation: MoveThreshold = max(direction factor * (mean of abs(SmoothedReturn(j)) over j from -past profile days to future profile days, skipping undefined values), threshold floor)
Calculation: StateAt(k) = None if SignAgreement(k) is undefined or below state agreement minimum; otherwise Long if SmoothedReturn(k) > MoveThreshold; otherwise Short if SmoothedReturn(k) < -MoveThreshold; otherwise Range
Calculation: FutureStateCount(X) = count of k from 1 to future profile days where StateAt(k) = X
Calculation: MajorityFutureState = the state among Long, Short, Range with the largest FutureStateCount, ties going to the earlier listed; None if all three counts are 0
Calculation: ForwardAverageReturn(h) = mean over y from 1 to classic lookback years of ((close h bars after AnchorBar(y)) / (close at AnchorBar(y))) - 1, skipping undefined values
Calculation: SampleReliable(h) = (count of y from 1 to classic lookback years where close h bars after AnchorBar(y) is defined) >= min samples AND that count / classic lookback years >= min coverage
Long: StateAt(0) = Long
Short: StateAt(0) = Short
Long: MajorityFutureState = Long
Short: MajorityFutureState = Short
Long: SampleReliable(horizon) AND ForwardAverageReturn(horizon) > alignment magnitude AND (StateAt(0) = Long OR MajorityFutureState = Long) AND StateAt(0) != Short AND MajorityFutureState != Short AND SignAgreement(0) >= alignment agreement minimum
Short: SampleReliable(horizon) AND ForwardAverageReturn(horizon) < -alignment magnitude AND (StateAt(0) = Short OR MajorityFutureState = Short) AND StateAt(0) != Long AND MajorityFutureState != Long AND SignAgreement(0) >= alignment agreement minimum