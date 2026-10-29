Calculation: Pivot center = initialize at the first confirmed pivot high or low; when a pivot is confirmed, update to (2 × prior center + pivot price) / 3, using the pivot high if both a pivot high and low confirm on the same bar; otherwise retain the prior center. A pivot is confirmed using equal left and right lookbacks.
Calculation: Base upper band = pivot center − ATR × factor; base lower band = pivot center + ATR × factor. ATR uses chart-timeframe bars.
Calculation: Trailing upper band = prior close > prior trailing upper band ? max(base upper band, prior trailing upper band) : base upper band; trailing lower band = prior close < prior trailing lower band ? min(base lower band, prior trailing lower band) : base lower band.
Calculation: Trend = close > prior trailing lower band ? 1 : close < prior trailing upper band ? −1 : prior trend; initialize prior trend as 1.
Long: Trend = 1 AND prior trend = −1
Short: Trend = −1 AND prior trend = 1