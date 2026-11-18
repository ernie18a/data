Calculation: Bull flow = shorter-lookback selected MA(source, MA type 1, lookback 1) > longer-lookback selected MA(source, MA type 2, lookback 2) AND shorter-lookback selected MA(source, MA type 1, lookback 1) > its value n chart bars ago AND (both-slopes setting disabled OR longer-lookback selected MA(source, MA type 2, lookback 2) > its value n chart bars ago)
Calculation: Bear flow = shorter-lookback selected MA(source, MA type 1, lookback 1) < longer-lookback selected MA(source, MA type 2, lookback 2) AND shorter-lookback selected MA(source, MA type 1, lookback 1) < its value n chart bars ago AND (both-slopes setting disabled OR longer-lookback selected MA(source, MA type 2, lookback 2) < its value n chart bars ago)
Long: shorter-lookback selected MA(source, MA type 1, lookback 1) crosses above longer-lookback selected MA(source, MA type 2, lookback 2)
Short: shorter-lookback selected MA(source, MA type 1, lookback 1) crosses below longer-lookback selected MA(source, MA type 2, lookback 2)
Long: Bull flow
Short: Bear flow
Long: Bull flow AND NOT Bull flow[1]
Short: Bear flow AND NOT Bear flow[1]