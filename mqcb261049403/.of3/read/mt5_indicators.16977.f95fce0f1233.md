Calculation: DMI stochastic = 0 if SUM(HHV(x, stochastic lookback) - LLV(x, stochastic lookback), slowing lookback) = 0, otherwise 100 * SUM(x - LLV(x, stochastic lookback), slowing lookback) / SUM(HHV(x, stochastic lookback) - LLV(x, stochastic lookback), slowing lookback), where x = DMI oscillator(DMI lookback, smoothing method); calculate on chart bars when using the chart timeframe, or on T1 bars using the T1 bar still forming and map the values to chart bars when using T1
Long: outer-level color mode AND DMI stochastic > upper level
Short: outer-level color mode AND DMI stochastic < lower level
Long: middle-line color mode AND DMI stochastic > (upper level + lower level) / 2
Short: middle-line color mode AND DMI stochastic < (upper level + lower level) / 2
Long: slope color mode AND DMI stochastic > DMI stochastic[1]
Short: slope color mode AND DMI stochastic < DMI stochastic[1]