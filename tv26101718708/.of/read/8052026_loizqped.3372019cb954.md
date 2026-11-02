Calculation: A confirmed pivot high or low is a high or low at the center of a symmetric window of chart bars, confirmed after the same number of bars on its right as on its left. When a supply/demand pivot high and low are confirmed together, process only the high.
Calculation: Supply and demand zones = at each confirmed supply/demand pivot high or low, respectively, form a zone from the pivot price toward the price interior by an ATR multiple calculated on the confirmation bar. Create it only if its midpoint lies outside the inclusive range of each existing same-side zone midpoint plus or minus an ATR multiple; retain a limited number of most recent zones on each side. Delete a supply zone when close reaches or exceeds its pivot high; delete a demand zone when close reaches or falls below its pivot low.
Calculation: FVG threshold = either a fixed proportion or the cumulative sum of (high - low) / low divided by the zero-based bar index, calculated on the FVG timeframe. FVG calculations may use the chart timeframe, a higher timeframe, or a lower timeframe; for a higher timeframe use the last completed bar on historical bars and the still-forming bar in real time, and for a lower timeframe use the last available lower-timeframe bar within each chart bar.
Calculation: MACD histogram = fast EMA of the selected price source minus slow EMA of that source minus the signal EMA of their difference; the fast EMA has a shorter lookback than the slow EMA.
Long: Close SMA > its previous-bar value.
Short: Close SMA < its previous-bar value.
Long: (high + low + close) / 3 >= close EMA.
Short: (high + low + close) / 3 < close EMA.
Long: Close crosses above its short-term SMA, with previous close <= previous SMA.
Short: Close crosses below its short-term SMA, with previous close >= previous SMA.
Long: FVG-timeframe low > high two FVG bars earlier AND previous FVG-bar close > that high AND (low - that high) / that high > FVG threshold.
Short: FVG-timeframe high < low two FVG bars earlier AND previous FVG-bar close < that low AND (that low - high) / high > FVG threshold.
Long: A demand zone is created at a confirmed pivot low.
Short: A supply zone is created at a confirmed pivot high.
Long: Close >= the pivot high of an existing supply zone.
Short: Close <= the pivot low of an existing demand zone.
Long: A confirmed pivot high >= the preceding confirmed pivot high OR a confirmed pivot low >= the preceding confirmed pivot low.
Short: A confirmed pivot high < the preceding confirmed pivot high OR a confirmed pivot low < the preceding confirmed pivot low.
Long: Price low and MACD histogram form confirmed pivot lows at the same bar AND the price pivot < the preceding simultaneously confirmed price pivot low AND the histogram pivot > the preceding simultaneously confirmed histogram pivot low.
Short: Price high and MACD histogram form confirmed pivot highs at the same bar AND the price pivot > the preceding simultaneously confirmed price pivot high AND the histogram pivot < the preceding simultaneously confirmed histogram pivot high.
Long: MACD histogram >= 0.
Short: MACD histogram < 0.