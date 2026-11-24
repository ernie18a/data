Calculation: CSRSI = cyclic smoothed RSI(close, cycle length, vibration)
Calculation: CSRSI_WMA = WMA(CSRSI, WMA length)
Calculation: UpperBand = highest level v such that at least band tail percent of CSRSI over the last 2*cycle length bars are at or above v
Calculation: LowerBand = lowest level v such that at least band tail percent of CSRSI over the last 2*cycle length bars are below v
Calculation: TopPivot(x, n) = x[0] < x[1] AND x[i] > x[i+1] for every i from 1 to n-1
Calculation: BottomPivot(x, n) = x[0] > x[1] AND x[i] < x[i+1] for every i from 1 to n-1
Calculation: CandA = BottomPivot(CSRSI, pivot lookback) AND CSRSI[1] < LowerBand[1]
Calculation: CandB = TopPivot(CSRSI, pivot lookback) AND (CSRSI[1] < CSRSI_WMA[1] OR CSRSI[1] < midline)
Calculation: LowPivot = BottomPivot(CSRSI, pivot lookback) AND (CSRSI[1] < LowerBand[1] OR CSRSI[1] < CSRSI_WMA[1])
Calculation: HighPivot = TopPivot(CSRSI, pivot lookback) AND (CSRSI[1] >= UpperBand[1] OR CSRSI[0] > CSRSI_WMA[0])
Calculation: Chain(P, W) = P[0] AND (W[i] AND CSRSI[i] < CSRSI_WMA[i]) at the first i in 1..search depth where CSRSI[i] >= CSRSI_WMA[i] OR W[i]
Calculation: AB = Chain(CandB, CandA)
Calculation: ABC = Chain(LowPivot, AB)
Calculation: ABCD = Chain(CandB, ABC)
Calculation: ABCDE = Chain(LowPivot, ABCD)
Calculation: ABCDEF = Chain(CandB, ABCDE)
Calculation: ABCDEFG = Chain(LowPivot, ABCDEF)
Calculation: CorrectiveA = CandA AND NOT ABC AND NOT ABCDE
Calculation: RegularBullDiv = LowPivot[0] AND CSRSI[0] > CSRSI[j] AND close[0] <= close[j], where j is the most recent i in 1..search depth with LowPivot[i]; false if none
Calculation: HiddenBullDiv = LowPivot[0] AND CSRSI[0] <= CSRSI[j] AND close[0] > close[j], where j is as in RegularBullDiv
Calculation: RegularBearDiv = HighPivot[0] AND CSRSI[0] <= CSRSI[k] AND close[0] > close[k], where k is the most recent i in 1..search depth with HighPivot[i]; false if none
Calculation: HiddenBearDiv = HighPivot[0] AND CSRSI[0] > CSRSI[k] AND close[0] <= close[k], where k is as in RegularBearDiv
Long: CSRSI[0] >= CSRSI_WMA[0] AND CSRSI[1] < CSRSI_WMA[1]
Long: CSRSI >= CSRSI_WMA
Long: close > VWMA(high, VWMA length)
Long: RegularBullDiv
Long: HiddenBullDiv
Long: ((CSRSI[0] >= CSRSI_WMA[0] AND CSRSI[1] < CSRSI_WMA[1]) OR (CorrectiveA AND RegularBullDiv) OR (ABC AND RegularBullDiv) OR (ABCDE AND pivot lookback is its longer option) OR (ABCDEFG AND pivot lookback is its shorter option)) AND NOT(Long[i] for any i from 1 to filter lookback)
Short: CSRSI[0] < CSRSI_WMA[0] AND CSRSI[1] >= CSRSI_WMA[1]
Short: CSRSI < CSRSI_WMA
Short: close < VWMA(low, VWMA length)
Short: RegularBearDiv
Short: HiddenBearDiv
Short: ((TopPivot(CSRSI, pivot lookback) AND CSRSI[1] >= UpperBand[1]) OR (CSRSI[0] < CSRSI[1] AND (CSRSI[0] >= UpperBand[0] OR CSRSI[1] >= UpperBand[1] OR CSRSI[2] >= UpperBand[2]))) AND UpperBand > upper level AND NOT(Short[i] for any i from 1 to filter lookback)