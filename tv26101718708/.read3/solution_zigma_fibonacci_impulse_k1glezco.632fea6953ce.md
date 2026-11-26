Calculation: FibEMA(ratio, lookback, length) = EMA(length) on chart bars of the Fibonacci retracement level at ratio between the highest high and lowest low of the last lookback bars of T1, using the last completed T1 bar
Calculation: SmoothedLinearRegression(regression length, offset, smoothing length) = EMA(smoothing length) on chart bars of LinearRegression(close, regression length, offset)
Calculation: ChandelierExitDirection(ATR length, multiplier) = Chandelier Exit trend direction on chart bars, bullish or bearish
Calculation: PlusDI(DMI length) = +DI(DMI length) of T2 bars, using the last completed T2 bar, held on chart bars
Calculation: MinusDI(DMI length) = -DI(DMI length) of T2 bars, using the last completed T2 bar, held on chart bars
Calculation: ADX(DMI length) = ADX(DMI length) of T2 bars, using the last completed T2 bar, held on chart bars
Long: close crosses above FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bullish AND close > SmoothedLinearRegression(regression length, offset, smoothing length) AND close > SmoothedLinearRegression(regression length, offset, smoothing length)[lag] AND position side is flat
Long: close crosses above FibEMA(ratio, lookback, longer length) AND PlusDI(DMI length) >= DI threshold AND PlusDI(DMI length) > ADX(DMI length) AND ChandelierExitDirection(ATR length, multiplier) is bullish AND close > SmoothedLinearRegression(regression length, offset, smoothing length) AND close > SmoothedLinearRegression(regression length, offset, smoothing length)[lag] AND position side is flat
Long: close crosses above FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bullish AND position side is flat
Long: close crosses above FibEMA(ratio, lookback, longer length) AND PlusDI(DMI length) >= DI threshold AND PlusDI(DMI length) > ADX(DMI length) AND ChandelierExitDirection(ATR length, multiplier) is bullish AND position side is flat
Long: close > FibEMA(ratio, lookback, longer length)
Long: FibEMA(ratio, lookback, longer length) < FibEMA(ratio, lookback, shorter length)
Long: SmoothedLinearRegression(regression length, offset, smoothing length) > SmoothedLinearRegression(regression length, offset, smoothing length)[1]
Long: ChandelierExitDirection(ATR length, multiplier) is bullish
Long: ChandelierExitDirection(ATR length, multiplier) is bullish AND ChandelierExitDirection(ATR length, multiplier)[1] is bearish
Short: close crosses below FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bearish AND close < SmoothedLinearRegression(regression length, offset, smoothing length) AND close < SmoothedLinearRegression(regression length, offset, smoothing length)[lag] AND position side is flat
Short: close crosses below FibEMA(ratio, lookback, longer length) AND MinusDI(DMI length) >= DI threshold AND MinusDI(DMI length) > ADX(DMI length) AND ChandelierExitDirection(ATR length, multiplier) is bearish AND close < SmoothedLinearRegression(regression length, offset, smoothing length) AND close < SmoothedLinearRegression(regression length, offset, smoothing length)[lag] AND position side is flat
Short: close crosses below FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bearish AND position side is flat
Short: close crosses below FibEMA(ratio, lookback, longer length) AND MinusDI(DMI length) >= DI threshold AND MinusDI(DMI length) > ADX(DMI length) AND ChandelierExitDirection(ATR length, multiplier) is bearish AND position side is flat
Short: close < FibEMA(ratio, lookback, longer length)
Short: FibEMA(ratio, lookback, longer length) > FibEMA(ratio, lookback, shorter length)
Short: SmoothedLinearRegression(regression length, offset, smoothing length) <= SmoothedLinearRegression(regression length, offset, smoothing length)[1]
Short: ChandelierExitDirection(ATR length, multiplier) is bearish
Short: ChandelierExitDirection(ATR length, multiplier) is bearish AND ChandelierExitDirection(ATR length, multiplier)[1] is bullish
Exit: Long, close < FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bearish
Exit: Short, close > FibEMA(ratio, lookback, longer length) AND ChandelierExitDirection(ATR length, multiplier) is bullish
Exit: Long, low <= entry price * (1 - stop percent) OR high >= entry price * (1 + stop percent * reward-to-risk ratio)
Exit: Short, high >= entry price * (1 + stop percent) OR low <= entry price * (1 - stop percent * reward-to-risk ratio)