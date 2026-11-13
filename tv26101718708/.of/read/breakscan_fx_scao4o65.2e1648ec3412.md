Calculation: RangeHigh = highest high of the previous N bars (excluding the current bar) on the detection timeframe; the detection timeframe is independent of the chart timeframe, and each detection-timeframe bar is evaluated on its completed close
Calculation: RangeLow = lowest low of the previous N bars (excluding the current bar) on the same detection timeframe, with the same N as RangeHigh
Long: detection-timeframe close > RangeHigh
Short: detection-timeframe close < RangeLow