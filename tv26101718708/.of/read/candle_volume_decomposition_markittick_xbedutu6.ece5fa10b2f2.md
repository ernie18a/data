Calculation: Zone volumes = For each lower-timeframe bar within the chart bar, allocate its volume among the chart bar's upper wick, body, and lower wick in proportion to the overlap of its high-low range with each zone. For a zero-range lower-timeframe bar, allocate all its volume to the upper wick if its price is at or above the body top; otherwise to the lower wick if at or below the body bottom; otherwise to the body. Sum each allocation across the lower-timeframe bars available in the chart bar, including the bar still forming.
Calculation: Total allocated volume = upper wick volume + body volume + lower wick volume.
Calculation: Net signed volume = lower wick volume + body volume if close >= open, otherwise lower wick volume - body volume; then subtract upper wick volume. It is undefined when total allocated volume is zero.
Calculation: Cumulative net signed volume = running sum of net signed volume from the start of the data, treating undefined values as zero.
Long: close >= open
Short: close < open
Long: total allocated volume > 0 AND net signed volume >= 0
Short: total allocated volume > 0 AND net signed volume < 0
Long: lower wick volume > upper wick volume
Short: upper wick volume > lower wick volume
Long: cumulative net signed volume >= 0
Short: cumulative net signed volume < 0
Long: lower wick volume >= body volume AND lower wick volume > upper wick volume
Short: upper wick volume >= body volume AND upper wick volume >= lower wick volume
Long: total allocated volume of the previous chart bar > total allocated volume of the chart bar one lookback before it AND high of the previous chart bar < high of the chart bar one lookback before it
Short: total allocated volume of the previous chart bar < total allocated volume of the chart bar one lookback before it AND high of the previous chart bar > high of the chart bar one lookback before it