Calculation: Opening price = open of the first chart bar after a higher-timeframe period begins; use the still-forming period and leave undefined until the first observed boundary.
Calculation: Deviation level = opening price × (1 + level index × percentage step), where the signed nonzero level index selects an upper or lower grid level.
Calculation: State score = clipped percentage change from the opening price divided by the deviation step, plus a weighted, centered position of close within the still-forming period's high-low range; use zero for the range-position term when high equals low. The clipping limits and bullish and bearish score thresholds are symmetric.
Calculation: Anchored VWAP = volume-weighted average of (high + low + close) / 3 since the start of a higher-timeframe anchor period; use the still-forming anchor period.
Calculation: VWAP bands = anchored VWAP plus or minus either a percentage of VWAP or a multiple of anchored standard deviation; the inner band is the enabled band closest to VWAP.
Long: Close >= opening price of a still-forming higher-timeframe period or the chart bar's open.
Short: Close < opening price of a still-forming higher-timeframe period or the chart bar's open.
Long: State score > bullish threshold, using the still-forming higher-timeframe period or the chart bar.
Short: State score < bearish threshold, using the still-forming higher-timeframe period or the chart bar.
Long: Close > the nearest upper deviation level.
Short: Close < the nearest lower deviation level.
Long: Close > the upper inner VWAP band when bands are enabled, OR close >= anchored VWAP when bands are disabled.
Short: Close < the lower inner VWAP band when bands are enabled, OR close < anchored VWAP when bands are disabled.
Long: High >= an upper deviation level AND low <= that level AND close > that level AND no earlier bar in the current anchor period reached that level.
Short: Low <= a lower deviation level AND high >= that level AND close < that level AND no earlier bar in the current anchor period reached that level.