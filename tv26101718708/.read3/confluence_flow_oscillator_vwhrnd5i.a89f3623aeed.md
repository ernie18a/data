Calculation: CompositeFlow = (100 * SMA(CLV, CLV smoothing) * CLV weight + 2 * (RSI(close, RSI lookback) - 50) * RSI distance weight + 100 * CMF(CMF lookback) * CMF weight) / (CLV weight + RSI distance weight + CMF weight)
Calculation: BullishBars = Count(CompositeFlow > 0 over last regime window bars including current bar)
Long: CompositeFlow crosses above long threshold AND volume >= Percentile(volume, volume window, volume percentile) AND BarsSince(PivotLow(low, pivot left bars, pivot right bars) is defined) <= max pivot age AND RSI(close, RSI lookback) < RSI overbought block AND Count(CompositeFlow < 0 over last regime window bars including current bar) > 0
Short: CompositeFlow crosses below short threshold AND volume >= Percentile(volume, volume window, volume percentile) AND BarsSince(PivotHigh(high, pivot left bars, pivot right bars) is defined) <= max pivot age AND RSI(close, RSI lookback) > RSI oversold block AND BullishBars > 0
Exit: long, CompositeFlow crosses below short threshold AND RSI(close, RSI lookback) > RSI oversold block AND BullishBars > 0
Long: CompositeFlow >= long threshold
Long: CompositeFlow >= 0
Short: CompositeFlow <= short threshold
Short: CompositeFlow < 0