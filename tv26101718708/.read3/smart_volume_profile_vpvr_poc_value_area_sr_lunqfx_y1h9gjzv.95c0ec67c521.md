Calculation: VP = volume per price bucket over the last profile lookback bars ending with the current bar, split into profile rows equal-width buckets from the lowest low to the highest high, each bar's volume spread evenly over the buckets from its low to its high (all into its close's bucket if its high equals its low)
Calculation: POC = midpoint price of the bucket with the most VP volume
Calculation: VA = bucket range grown outward from the POC bucket by repeatedly adding whichever adjacent bucket has more VP volume, until the range holds at least value area percentage of total VP volume
Calculation: VAH = top price of VA
Calculation: VAL = bottom price of VA
Calculation: OrderFlow = (BuyShare + AboveShare) / 2, where BuyShare = 100 * volume of bars with close >= open / total volume and AboveShare = 100 * VP volume in buckets above the POC bucket / VP volume in buckets above or below the POC bucket, all over the last profile lookback bars
Long: close < VAL AND OrderFlow > bearish threshold
Long: close > VAH AND OrderFlow >= bullish threshold
Long: close crosses above VAH
Long: low <= VAL AND VAL <= close <= VAH
Short: close < VAL AND OrderFlow <= bearish threshold
Short: close > VAH AND OrderFlow < bullish threshold
Short: close crosses below VAL
Short: high >= VAH AND VAL <= close <= VAH
Exit: long, high >= POC AND entry price < POC
Exit: short, low <= POC AND entry price > POC