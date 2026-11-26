Calculation: Up score = round(100 - (bars since highest high in the lookback + half a bar) × 100 / lookback), on each T1 bar
Calculation: Down score = round(100 - (bars since lowest low in the lookback + half a bar) × 100 / lookback), on each T1 bar
Calculation: Trend = bullish when Up score > Down score and Up score >= threshold; bearish when Up score < Down score and Down score >= threshold; otherwise the previous Trend; initially neutral
Long: previous Trend is bearish AND current Trend is bullish on the last completed T1 bar
Short: previous Trend is bullish AND current Trend is bearish on the last completed T1 bar