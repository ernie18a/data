Calculation: Range low = lowest low of the first N chart bars in each T1 period
Calculation: Range high = highest high of the first N chart bars in each T1 period
Long: Before any signal in the T1 period, after a chart bar's low falls below Range low, a chart bar closes above VWAP(hlc3)
Short: Before any signal in the T1 period, after a chart bar's high rises above Range high, a chart bar closes below VWAP(hlc3)