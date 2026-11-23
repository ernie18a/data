Calculation: Bar(F) = F of the bar of the longer of chart timeframe and T1 containing this bar, still forming
Calculation: RangeHigh(S) = highest Bar(high) over bars in S, as of the most recent first bar after S
Calculation: RangeLow(S) = lowest Bar(low) over bars in S, as of the most recent first bar after S
Calculation: SessionStartOpen = Bar(open) at the most recent first bar in S1, S2 or S3
Calculation: UpCross(S,E) = bar in E AND close > RangeHigh(S) AND close[1] <= RangeHigh(S)
Calculation: UpBroken(S,E) = (UpCross(S,E) OR UpBroken(S,E)[1]) AND NOT (this bar is the first bar after S)
Calculation: DownCross(S,E) = bar in E AND close < RangeLow(S) AND close[1] >= RangeLow(S)
Calculation: DownBroken(S,E) = (DownCross(S,E) OR DownBroken(S,E)[1]) AND NOT (this bar is the first bar after S)
Long: UpCross(S1,E1) AND NOT UpBroken(S1,E1)[1]
Long: UpCross(S2,E2) AND NOT UpBroken(S2,E2)[1]
Long: UpCross(S3,E3) AND NOT UpBroken(S3,E3)[1]
Short: DownCross(S1,E1) AND NOT DownBroken(S1,E1)[1]
Short: DownCross(S2,E2) AND NOT DownBroken(S2,E2)[1]
Short: DownCross(S3,E3) AND NOT DownBroken(S3,E3)[1]
Long: bar in S1, S2 or S3 AND Bar(close) > SessionStartOpen
Short: bar in S1, S2 or S3 AND Bar(close) <= SessionStartOpen