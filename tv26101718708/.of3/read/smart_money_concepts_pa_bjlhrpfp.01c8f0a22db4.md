Calculation: Structure leg = bearish if high[lookback] > highest(high, lookback), else bullish if low[lookback] < lowest(low, lookback), else retain the prior leg; on a leg change, set the high pivot to high[lookback] for a bearish leg or the low pivot to low[lookback] for a bullish leg, and reset its crossed flag; use separate internal and swing lookbacks
Calculation: Structure bias = neutral initially; after a valid close cross above an uncrossed pivot high set bullish and mark that pivot crossed; after a valid close cross below an uncrossed pivot low set bearish and mark that pivot crossed; a break is CHoCH when prior bias is opposite the break direction, otherwise BOS
Calculation: Internal bullish confluence = high - max(close, open) > min(close, open - low); internal bearish confluence = high - max(close, open) < min(close, open - low)
Calculation: Bullish order block = high and low of the bar with the minimum low from the pivot bar up to the break bar; bearish order block = high and low of the bar with the maximum high over that interval
Calculation: Bearish order-block mitigation source = close in close mode, otherwise high; bullish order-block mitigation source = close in close mode, otherwise low
Calculation: FVG bar delta = (close of last completed T1 bar - open of last completed T1 bar) / (open of last completed T1 bar * 100)
Calculation: FVG threshold = if automatic threshold is enabled, 2 * cumulative sum on chart bars of abs(FVG bar delta when T1 changes, otherwise 0) / chart bar index; otherwise 0
Long: close crosses above the latest swing pivot high and it is uncrossed and prior swing bias is bearish
Long: close crosses above the latest swing pivot high and it is uncrossed and prior swing bias is not bearish
Short: close crosses below the latest swing pivot low and it is uncrossed and prior swing bias is bullish
Short: close crosses below the latest swing pivot low and it is uncrossed and prior swing bias is not bullish
Long: close crosses above the latest internal pivot high and it is uncrossed and it differs from the latest swing pivot high and (internal confluence filter is disabled or internal bullish confluence) and prior internal bias is bearish
Long: close crosses above the latest internal pivot high and it is uncrossed and it differs from the latest swing pivot high and (internal confluence filter is disabled or internal bullish confluence) and prior internal bias is not bearish
Short: close crosses below the latest internal pivot low and it is uncrossed and it differs from the latest swing pivot low and (internal confluence filter is disabled or internal bearish confluence) and prior internal bias is bullish
Short: close crosses below the latest internal pivot low and it is uncrossed and it differs from the latest swing pivot low and (internal confluence filter is disabled or internal bearish confluence) and prior internal bias is not bullish
Long: bearish order-block mitigation source > active bearish order-block high
Short: bullish order-block mitigation source < active bullish order-block low
Long: on chart bars using T1 values, T1 changes and low of the forming T1 bar > high from two T1 bars ago and close of the last completed T1 bar > that high and FVG bar delta > FVG threshold
Short: on chart bars using T1 values, T1 changes and high of the forming T1 bar < low from two T1 bars ago and close of the last completed T1 bar < that low and -FVG bar delta > FVG threshold