Calculation: Chart high bound = Highest(high, chart lookback) over chart bars including the current bar
Calculation: Chart low bound = Lowest(low, chart lookback) over chart bars including the current bar
Calculation: Chart band width = chart high bound − chart low bound
Calculation: Chart trend state = prior chart trend state; set to −1 if close < chart low bound + chart band width × (chart offset parameter − chart risk parameter)/100, then set to +1 if close > chart high bound − chart band width × (chart offset parameter − chart risk parameter)/100; initialize to 0
Calculation: T1 high bound = Highest(high, T1 lookback) over T1 bars including the still-forming T1 bar, with values mapped to chart bars
Calculation: T1 low bound = Lowest(low, T1 lookback) over T1 bars including the still-forming T1 bar, with values mapped to chart bars
Calculation: T1 band width = T1 high bound − T1 low bound
Calculation: T1 trend state = prior T1 trend state; set to −1 if T1 close < T1 low bound + T1 band width × (T1 offset parameter − T1 risk parameter)/100, then set to +1 if T1 close > T1 high bound − T1 band width × (T1 offset parameter − T1 risk parameter)/100; initialize to 0; calculate on T1 bars and map values to chart bars
Long: Chart trend state > 0
Long: Prior chart trend state ≤ 0 AND chart trend state > 0
Short: Chart trend state < 0
Short: Prior chart trend state ≥ 0 AND chart trend state < 0
Long: T1 trend state > 0
Long: Prior T1 trend state ≤ 0 AND T1 trend state > 0
Short: T1 trend state < 0
Short: Prior T1 trend state ≥ 0 AND T1 trend state < 0