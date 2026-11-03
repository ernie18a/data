Calculation: Aroon Up = on the indicator timeframe, for each bar, round to the nearest integer: 100 − (bars since the highest high in the lookback + 0.5) × 100 / lookback; use the last completed indicator bar.
Calculation: Aroon Down = on the indicator timeframe, for each bar, round to the nearest integer: 100 − (bars since the lowest low in the lookback + 0.5) × 100 / lookback; use the last completed indicator bar.
Calculation: Aroon trend = retain the previous trend unless Aroon Up > Aroon Down AND Aroon Up ≥ 50, which sets it bullish, or Aroon Up < Aroon Down AND Aroon Down ≥ 50, which sets it bearish; initialize as neutral.
Long: Previous Aroon trend is bearish AND current Aroon trend is bullish
Short: Previous Aroon trend is bullish AND current Aroon trend is bearish
Exit: long, Previous Aroon trend is bullish AND current Aroon trend is bearish
Exit: short, Previous Aroon trend is bearish AND current Aroon trend is bullish