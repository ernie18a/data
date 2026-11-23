Calculation: Hull line = MovingAverage(close, hull length, hull type, T1, last completed bar)
Calculation: Rapid difference = HMA(close, rapid length, T1, last completed bar)[1] - 2 * HMA(close, rapid length, T1, last completed bar)
Calculation: SSL state(length, type) = IF close > MovingAverage(high, length, type, T1, last completed bar) THEN 1 ELSE IF close < MovingAverage(low, length, type, T1, last completed bar) THEN -1 ELSE SSL state(length, type)[1]
Calculation: SSL(length, type) = IF SSL state(length, type) < 0 THEN MovingAverage(high, length, type, T1, last completed bar) ELSE MovingAverage(low, length, type, T1, last completed bar)
Calculation: ATR value = ATR(period, T1, last completed bar)
Calculation: ATR coefficient = IF highest(ATR value, period) = lowest(ATR value, period) THEN 0.5 ELSE 1 - (ATR value - lowest(ATR value, period)) / (highest(ATR value, period) - lowest(ATR value, period))
Calculation: Adaptive JMA = JMA(close, int(period * (ATR coefficient + 1) / 2), JMA phase, T1, last completed bar)
Long: Hull line > Hull line[1]
Short: Hull line <= Hull line[1]
Long: Hull line > Hull line[1] AND Hull line[1] < Hull line[2]
Short: Hull line < Hull line[1] AND Hull line[1] > Hull line[2]
Long: close > SSL(baseline length, baseline type)
Short: close < SSL(baseline length, baseline type)
Long: close crosses above SSL(exit length, exit type)
Short: close crosses below SSL(exit length, exit type)
Long: Rapid difference < Rapid difference[1] AND Rapid difference[1] >= Rapid difference[2]
Short: Rapid difference > Rapid difference[1] AND Rapid difference[1] <= Rapid difference[2]
Long: Adaptive JMA crosses above Adaptive JMA[1]
Short: Adaptive JMA crosses below Adaptive JMA[1]
Long: PivotLow(low, depth, depth) is defined
Short: PivotHigh(high, depth, depth) is defined
Long: low > high[2] AND close[1] > high[2]
Short: high < low[2] AND close[1] < low[2]
Long: Hull line > Hull line[1] AND Hull line[1] < Hull line[2] AND close crosses above SSL(exit length, exit type) AND Rapid difference < Rapid difference[1] AND Rapid difference[1] >= Rapid difference[2]
Short: Hull line < Hull line[1] AND Hull line[1] > Hull line[2] AND close crosses below SSL(exit length, exit type) AND Rapid difference > Rapid difference[1] AND Rapid difference[1] <= Rapid difference[2]