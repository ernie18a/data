Calculation: Smoothed detrended price = a configurable moving average of (price minus a separate configurable moving average of that same price), calculated independently for open and close, with independently configurable methods and lengths for detrending and smoothing.
Calculation: Indicator close = smoothed detrended close.
Calculation: Indicator open = previous bar's indicator close if abs(open - close) <= a configurable price-distance threshold; otherwise smoothed detrended open.
Long: Indicator close > indicator open on the chart timeframe OR indicator close > indicator open on the still-forming higher-timeframe bar.
Short: Indicator close < indicator open on the chart timeframe OR indicator close < indicator open on the still-forming higher-timeframe bar.