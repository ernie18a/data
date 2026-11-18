Calculation: +DI = WMA(fixnan(100 * WMA(positive directional movement * volume weight, DI lookback) / WMA(true range(high, low, close) * volume weight, DI lookback)), ADX smoothing), where positive directional movement is high - high[1] when high - high[1] exceeds low[1] - low and is positive, otherwise zero; volume weight is volume when volume weighting is enabled, otherwise one
Calculation: -DI = WMA(fixnan(100 * WMA(negative directional movement * volume weight, DI lookback) / WMA(true range(high, low, close) * volume weight, DI lookback)), ADX smoothing), where negative directional movement is low[1] - low when low[1] - low exceeds high - high[1] and is positive, otherwise zero; volume weight is volume when volume weighting is enabled, otherwise one
Calculation: signed index = round((100 * (+DI - -DI) / denominator) / Step) * Step when Step > 0, otherwise 100 * (+DI - -DI) / denominator, where denominator is +DI + -DI unless that sum is zero, in which case it is one
Long: +DI crosses above -DI AND +DI crosses above KeyLevel
Long: signed index >= 0
Short: -DI crosses above +DI AND -DI crosses above KeyLevel
Short: signed index < 0