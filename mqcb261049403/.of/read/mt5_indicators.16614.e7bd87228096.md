Calculation: Applied price = selectable open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2 × close)/4, (open + close)/2, (open + high + low + close)/4, high if close > open else low if close < open else close, (high + close)/2 if close > open else (low + close)/2 if close < open else close, or (high + low + close + X - high - low)/2 where X = low if close < open, high if close > open, otherwise close.
Calculation: Regression line at bar t = 6 / (N × (N + 1)) × sum over i = 1 to N of (i - (N + 1)/3) × applied price at bar t - N + i, where N is the regression lookback.
Calculation: Trigger line at bar t = regression line at t - 1 + 2 / (M + 1) × (regression line at t - regression line at t - 1), where M is a separately selectable smoothing parameter.
Calculation: Higher-timeframe regression and trigger lines = regression and trigger lines calculated on a higher timeframe's still-forming bar at the start of that higher-timeframe bar and held constant until the next higher-timeframe bar starts.
Long: Regression line > trigger line.
Short: Regression line < trigger line.
Long: Higher-timeframe regression line > higher-timeframe trigger line.
Short: Higher-timeframe regression line < higher-timeframe trigger line.