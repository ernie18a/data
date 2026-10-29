Calculation: ATH = highest high from the start of the data
Calculation: Retracement level = ATH reduced by that level’s configured percentage
Calculation: Tolerance band = retracement level ± its configured tolerance percentage
Calculation: Confirmed pivot = a chart-timeframe high or low that is highest or lowest, respectively, across equal configurable lookback bars before and after it
Long: For any configured retracement level, the bar intersects its tolerance band but not the level, OR intersects the level, OR (after the level was touched since the latest confirmed pivot) closes above the band; each alert type occurs at most once per level per pivot leg
Short: For any configured retracement level, (after the level was touched since the latest confirmed pivot) the bar closes below the band; each alert type occurs at most once per level per pivot leg