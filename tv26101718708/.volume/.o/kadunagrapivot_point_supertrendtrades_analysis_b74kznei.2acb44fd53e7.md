Calculation: Confirmed pivot = a pivot high or pivot low confirmed by later bars
Calculation: Pivot center = first confirmed pivot; thereafter (2 × previous pivot center + latest confirmed pivot) / 3
Calculation: ATR bands = pivot center − ATR and pivot center + ATR
Calculation: Trailing lower band = previous close > previous trailing lower band ? max(current lower ATR band, previous trailing lower band) : current lower ATR band
Calculation: Trailing upper band = previous close < previous trailing upper band ? min(current upper ATR band, previous trailing upper band) : current upper ATR band
Calculation: Trend = close > previous trailing upper band ? bullish : close < previous trailing lower band ? bearish : previous trend
Calculation: Selected MA = selected moving average of close
Long: Trend is bullish AND previous trend was bearish AND close > Selected MA
Short: Trend is bearish AND previous trend was bullish AND close < Selected MA
Exit: long, low <= entry price × (1 − stop-loss percentage)
Exit: short, high >= entry price × (1 + stop-loss percentage)