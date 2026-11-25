Calculation: Adaptive CCI = CCI(MA(selected applied price, price-smoothing lookback, selected smoothing method), adaptive lookback), where adaptive lookback is ceil(base CCI lookback × -ln(VHF(selected applied price, base CCI lookback))) when VHF adaptation is selected and VHF is nonzero; otherwise it is the base CCI lookback
Calculation: Effective level lookback = minimum valid lookback when the requested level lookback is negative; base CCI lookback when it is zero; otherwise the requested level lookback
Calculation: Rolling quantile(x, lookback, percentile) = linearly interpolated percentile of x over the current and preceding chart bars in the lookback
Calculation: Upper level = in floating-range mode, rolling minimum(Adaptive CCI, effective level lookback) plus the upper percentage of the rolling range; in quantile mode, Rolling quantile(Adaptive CCI, effective level lookback, upper percentile)
Calculation: Lower level = in floating-range mode, rolling minimum(Adaptive CCI, effective level lookback) plus the lower percentage of the rolling range; in quantile mode, Rolling quantile(Adaptive CCI, effective level lookback, lower percentile)
Calculation: Middle level = in floating-range mode, the midpoint of the rolling minimum and maximum of Adaptive CCI over the effective level lookback; in quantile mode, Rolling quantile(Adaptive CCI, effective level lookback, the midpoint of the upper and lower percentiles)
Long: effective level lookback exceeds the minimum valid lookback AND color mode is level AND Adaptive CCI > Upper level
Short: effective level lookback exceeds the minimum valid lookback AND color mode is level AND Adaptive CCI < Lower level
Long: effective level lookback exceeds the minimum valid lookback AND color mode is middle AND Adaptive CCI > Middle level
Short: effective level lookback exceeds the minimum valid lookback AND color mode is middle AND Adaptive CCI < Middle level
Long: (effective level lookback is the minimum valid lookback OR color mode is slope) AND Adaptive CCI > Adaptive CCI[1]
Short: (effective level lookback is the minimum valid lookback OR color mode is slope) AND Adaptive CCI < Adaptive CCI[1]