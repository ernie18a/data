Calculation: T1 volume per chart bar = sum(volume of T1 bars within the chart bar); T1 is lower than the chart timeframe, and the current chart bar includes its still-forming T1 bar
Calculation: Upper-wick, body, and lower-wick volume = on each chart bar, allocate each T1 bar's volume among the chart bar's upper wick, body, and lower wick in proportion to high-low range overlap; for a zero-range T1 bar, allocate all volume to the upper wick if its midpoint is at or above the body top, otherwise to the lower wick if its midpoint is at or below the body bottom, otherwise to the body
Calculation: Net Signed Volume = lower-wick volume + (close >= open ? body volume : -body volume) - upper-wick volume when total zone volume is greater than zero; otherwise unavailable
Calculation: Cumulative Net Signed Volume = cumulative sum of nz(Net Signed Volume) across chart bars, initialized to zero
Long: Net Signed Volume >= 0
Short: Net Signed Volume < 0
Long: close >= open
Short: close < open
Long: lower-wick volume > upper-wick volume
Short: upper-wick volume > lower-wick volume
Long: lower-wick volume > upper-wick volume AND lower-wick volume >= body volume
Short: upper-wick volume >= lower-wick volume AND upper-wick volume >= body volume
Long: Cumulative Net Signed Volume >= 0
Short: Cumulative Net Signed Volume < 0
Long: T1 volume per chart bar[1] > T1 volume per chart bar[lookback + 1] AND high[1] < high[lookback + 1]
Short: T1 volume per chart bar[1] < T1 volume per chart bar[lookback + 1] AND high[1] > high[lookback + 1]