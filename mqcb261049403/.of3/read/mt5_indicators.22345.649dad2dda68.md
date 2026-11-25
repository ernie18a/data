Calculation: Chart Skyscraper step = point size × truncate_toward_zero(chart step coefficient × chart sensitivity × (highest(ATR(chart ATR period), chart ATR range lookback) + lowest(ATR(chart ATR period), chart ATR range lookback)) / point size)
Calculation: Chart Skyscraper trend = initialize trend neutral and both bands to the first close; on each chart bar, set trend bullish if close > prior upper band, then set it bearish if close < prior lower band, otherwise retain prior trend; band width = chart band multiplier × Chart Skyscraper step; if chart price-basis parameter selects high/low, candidate lower band = high − band width and candidate upper band = low + band width, otherwise candidate bands = close − band width and close + band width; if trend is bullish, lower band = max(candidate lower band, prior lower band) and upper band = candidate upper band; otherwise, upper band = min(candidate upper band, prior upper band) and lower band = candidate lower band
Calculation: T1 Skyscraper step = point size × truncate_toward_zero(T1 step coefficient × T1 sensitivity × (highest(ATR(T1 ATR period), T1 ATR range lookback) + lowest(ATR(T1 ATR period), T1 ATR range lookback)) / point size)
Calculation: T1 Skyscraper trend = the Chart Skyscraper trend recurrence on T1 bars, using T1 parameters
Long: Chart Skyscraper trend > 0
Short: Chart Skyscraper trend ≤ 0
Long: Chart Skyscraper trend crosses from ≤ 0 to > 0
Short: Chart Skyscraper trend crosses from > 0 to ≤ 0
Long: T1 Skyscraper trend > 0, sampled on chart bars from the still-forming T1 bar
Short: T1 Skyscraper trend ≤ 0, sampled on chart bars from the still-forming T1 bar