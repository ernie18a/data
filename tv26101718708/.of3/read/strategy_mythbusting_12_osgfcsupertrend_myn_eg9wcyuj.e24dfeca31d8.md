Calculation: OneSidedGaussian(source, depth) = (sum over i = 0 to depth of source[i] * g(i)) / (sum over j = 0 to depth of g(j)), where g(k) = exp(-width * k^2 / (F + 1)^2) and F = the element at index depth (counting from 0) of the sequence 1, 2, 3, 5, 8, ...
Calculation: GaussianFilter(source, depth, smoothing period) = SuperSmoother(OneSidedGaussian(source, depth), smoothing period)
Long: GaussianFilter(source, depth, smoothing period) crosses above GaussianFilter(source, depth, smoothing period)[1] AND barssince(GaussianFilter(source, depth, smoothing period) crosses below GaussianFilter(source, depth, smoothing period)[1]) > Gaussian lookback AND SuperTrend(ATR length, ATR multiplier) is bullish AND barssince(SuperTrend(ATR length, ATR multiplier) is bearish) > SuperTrend lookback AND (ADX filter disabled OR ADX(DI length, ADX smoothing) > ADX threshold)
Long: GaussianFilter(source, depth, smoothing period) crosses above GaussianFilter(source, depth, smoothing period)[1]
Long: GaussianFilter(source, depth, smoothing period) > GaussianFilter(source, depth, smoothing period)[1]
Long: SuperTrend(ATR length, ATR multiplier) is bullish
Short: GaussianFilter(source, depth, smoothing period) crosses below GaussianFilter(source, depth, smoothing period)[1] AND barssince(GaussianFilter(source, depth, smoothing period) crosses above GaussianFilter(source, depth, smoothing period)[1]) > Gaussian lookback AND SuperTrend(ATR length, ATR multiplier) is bearish AND barssince(SuperTrend(ATR length, ATR multiplier) is bullish) > SuperTrend lookback AND (ADX filter disabled OR ADX(DI length, ADX smoothing) > ADX threshold)
Short: GaussianFilter(source, depth, smoothing period) crosses below GaussianFilter(source, depth, smoothing period)[1]
Short: GaussianFilter(source, depth, smoothing period) <= GaussianFilter(source, depth, smoothing period)[1]
Short: SuperTrend(ATR length, ATR multiplier) is bearish
Exit: Long, GaussianFilter(source, depth, smoothing period) crosses below GaussianFilter(source, depth, smoothing period)[1]
Exit: Short, GaussianFilter(source, depth, smoothing period) crosses above GaussianFilter(source, depth, smoothing period)[1]
Exit: Long, close < entry price * (1 - stop-loss)
Exit: Short, close > entry price * (1 + stop-loss)
Exit: Long, high >= entry price * (1 + take-profit 1) OR high >= entry price * (1 + take-profit 2) OR high >= entry price * (1 + take-profit 3) OR high >= entry price * (1 + take-profit 4)
Exit: Short, low <= entry price * (1 - take-profit 1) OR low <= entry price * (1 - take-profit 2) OR low <= entry price * (1 - take-profit 3) OR low <= entry price * (1 - take-profit 4)