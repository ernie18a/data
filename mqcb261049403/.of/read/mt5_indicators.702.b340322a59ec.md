Calculation: Stochastic RSI component = for each bar, find the minimum and maximum close-based RSI over the current bar and a parameterized number of preceding bars; return 0 if they are equal, otherwise return (current RSI - minimum RSI) / (200 * (maximum RSI - minimum RSI)) - 100.
Calculation: 3D oscillator = recursively smooth the weighted sum of typical-price CCI and the stochastic RSI component, using a configurable weight for CCI and its complement for the stochastic RSI component. The smoothing coefficient is 2 / (max(signal smoothing period, 2) + 1); initialize the previous oscillator to 0.
Calculation: 3D signal line = recursively smooth the previous bar's 3D oscillator with coefficient 2 / (0.8 * max(signal smoothing period, 2) + 1); initialize the previous signal line to 0.
Calculation: Valid bullish crossover = 3D oscillator > 3D signal line AND previous 3D oscillator < previous 3D signal line AND 3D signal line - 15 != 0.
Calculation: Valid bearish crossover = 3D oscillator < 3D signal line AND previous 3D oscillator > previous 3D signal line AND 3D signal line + 15 != 0.
Calculation: Higher-timeframe trend = direction of the most recent valid bullish or bearish crossover calculated on higher-timeframe bars, including the bar still forming; undefined until such a crossover occurs.
Long: Valid bullish crossover on the chart timeframe.
Short: Valid bearish crossover on the chart timeframe.
Long: Higher-timeframe trend = bullish.
Short: Higher-timeframe trend = bearish.