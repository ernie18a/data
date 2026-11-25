Calculation: Skyscraper trend = initialize bearish with both thresholds at the first close; on each bar become bullish if close > prior upper threshold, bearish if close < prior lower threshold, otherwise retain the prior trend; step = floor(0.5 × sensitivity × (highest(ATR(ATR lookback), range lookback) + lowest(ATR(ATR lookback), range lookback)) / point size) × point size; upper candidate = low + 2 × step and lower candidate = high − 2 × step in high/low mode, otherwise upper candidate = close + 2 × step and lower candidate = close − 2 × step; after a bullish bar, lower threshold = max(lower candidate, prior lower threshold) and upper threshold = upper candidate; after a bearish or neutral bar, upper threshold = min(upper candidate, prior upper threshold) and lower threshold = lower candidate
Long: Skyscraper trend changes from bearish to bullish on chart bars
Short: Skyscraper trend changes from bullish to bearish on chart bars
Long: Skyscraper trend is bullish on the still-forming T1 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T1 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T2 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T2 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T3 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T3 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T4 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T4 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T5 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T5 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T6 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T6 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T7 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T7 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T8 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T8 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T9 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T9 bar, with values mapped to chart bars
Long: Skyscraper trend is bullish on the still-forming T10 bar, with values mapped to chart bars
Short: Skyscraper trend is bearish on the still-forming T10 bar, with values mapped to chart bars