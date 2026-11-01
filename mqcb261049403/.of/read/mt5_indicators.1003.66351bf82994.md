Calculation: Selected price = a configurable choice of open, high, low, close, median price, typical price, weighted close, (open + close) / 2, (open + high + low + close) / 4, or a trend-following price; the first trend-following price is high when close > open, low when close < open, and close otherwise; the second is (high + close) / 2 when close > open, (low + close) / 2 when close < open, and close otherwise.
Calculation: Oscillator = 100 times the ratio of a configurable moving average of selected-price changes to the same moving average of their absolute values, clipped to the interval [-1, 1]; it is undefined when the denominator is zero. The smoothing method is configurable among SMA, EMA, SMMA, LWMA, JMA, JurX, parabolic regression moving average, T3, VIDYA, and Kaufman adaptive moving average.
Calculation: JurX = apply three successive stages to the input; each stage updates two cascaded exponential averages with smoothing factor 3 / (period + 2) and outputs 1.5 times the first average minus 0.5 times the second; initialize both averages in each stage to the first input.
Calculation: Signal = a configurable moving average of the oscillator, with its own independently configurable smoothing method and period.
Calculation: Higher-timeframe oscillator and signal = calculate the oscillator and signal on higher-timeframe bars; at the start of each higher-timeframe bar, sample its still-forming values and retain them for the chart bars until the next higher-timeframe bar.
Long: Oscillator > 0 AND oscillator > previous oscillator OR oscillator < 0 AND oscillator > previous oscillator.
Short: Oscillator > 0 AND oscillator < previous oscillator OR oscillator < 0 AND oscillator < previous oscillator.
Long: Oscillator > previous signal.
Short: Oscillator < previous signal.
Long: Higher-timeframe oscillator > 0 AND higher-timeframe oscillator > previous higher-timeframe oscillator OR higher-timeframe oscillator < 0 AND higher-timeframe oscillator > previous higher-timeframe oscillator.
Short: Higher-timeframe oscillator > 0 AND higher-timeframe oscillator < previous higher-timeframe oscillator OR higher-timeframe oscillator < 0 AND higher-timeframe oscillator < previous higher-timeframe oscillator.
Long: Higher-timeframe oscillator > higher-timeframe signal.
Short: Higher-timeframe oscillator < higher-timeframe signal.