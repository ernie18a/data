Calculation: Bullish 2-1-2 setup = low[1] < low[2] AND high[1] <= high[2] AND high <= high[1] AND low >= low[1] (computed on T1 bars; T1 is the selected execution timeframe or the chart timeframe if unset; the current T1 bar is still forming, and its values are sampled onto chart bars)
Calculation: Bearish 2-1-2 setup = high[1] > high[2] AND low[1] >= low[2] AND high <= high[1] AND low >= low[1] (computed on T1 bars; T1 is the selected execution timeframe or the chart timeframe if unset; the current T1 bar is still forming, and its values are sampled onto chart bars)
Calculation: Session allowed = session filter disabled OR chart-bar time is within the selected session window
Calculation: Long target = high(T1, forming bar) + (high(T1, forming bar) - low(T1, forming bar)) × risk-reward parameter (computed on T1 bars; values are sampled onto chart bars)
Calculation: Short target = low(T1, forming bar) - (high(T1, forming bar) - low(T1, forming bar)) × the same risk-reward parameter (computed on T1 bars; values are sampled onto chart bars)
Long: Bullish 2-1-2 setup AND Session allowed
Long: Bullish 2-1-2 setup AND Session allowed AND NOT (Bullish 2-1-2 setup AND Session allowed) on the previous chart bar
Long: Bullish 2-1-2 setup AND Session allowed AND chart-bar high >= high(T1, forming bar)
Long: Bullish 2-1-2 setup AND Session allowed AND chart-bar high >= high(T1, forming bar) AND NOT (the same condition on the previous chart bar)
Short: Bearish 2-1-2 setup AND Session allowed
Short: Bearish 2-1-2 setup AND Session allowed AND NOT (Bearish 2-1-2 setup AND Session allowed) on the previous chart bar
Short: Bearish 2-1-2 setup AND Session allowed AND chart-bar low <= low(T1, forming bar)
Short: Bearish 2-1-2 setup AND Session allowed AND chart-bar low <= low(T1, forming bar) AND NOT (the same condition on the previous chart bar)
Exit: long, Bullish 2-1-2 setup AND Session allowed AND chart-bar high >= high(T1, forming bar) AND chart-bar low <= low(T1, forming bar)
Exit: long, Bullish 2-1-2 setup AND Session allowed AND chart-bar high >= high(T1, forming bar) AND chart-bar high >= Long target
Exit: short, Bearish 2-1-2 setup AND Session allowed AND chart-bar low <= low(T1, forming bar) AND chart-bar high >= high(T1, forming bar)
Exit: short, Bearish 2-1-2 setup AND Session allowed AND chart-bar low <= low(T1, forming bar) AND chart-bar low <= Short target