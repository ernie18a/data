Calculation: Middle = selected moving average(selected price source, middle lookback, middle average type and settings, T1, selected candle type), computed on T1 bars and mapped to chart bars using the current T1 bar while it forms in real time and the completed T1 bar on historical data
Calculation: Deviation = ATR(ATR lookback, T1, selected candle type) when ATR deviation is selected, otherwise standard deviation(selected price source, middle lookback, T1, selected candle type); computed on T1 bars and mapped to chart bars using the current T1 bar while it forms in real time and the completed T1 bar on historical data
Calculation: Upper band = Middle + Deviation × upper deviation multiplier, computed on chart bars from the mapped T1 values
Calculation: Lower band = Middle − Deviation × lower deviation multiplier, computed on chart bars from the mapped T1 values
Calculation: Smoothed upper band = selected moving average(Upper band, upper smoothing lookback, upper smoothing average type and settings), computed on chart bars
Calculation: Smoothed lower band = selected moving average(Lower band, lower smoothing lookback, lower smoothing average type and settings), computed on chart bars
Long: close crosses above Middle
Short: close crosses below Middle
Long: close crosses above Smoothed upper band
Short: close crosses below Smoothed upper band
Long: close crosses above Smoothed lower band
Short: close crosses below Smoothed lower band