Calculation: MACD = EMA(close, fast period) - EMA(close, slow period), fast period shorter than slow period. It is computed on bars of a timeframe equal to or higher than the chart timeframe. At each chart bar it uses the still-forming bar of that timeframe, not the last completed one.
Calculation: Signal = EMA(MACD, signal period)
Calculation: Mid = (highest MACD + lowest MACD) / 2 over the previous N bars, excluding the current bar
Long: (MACD > Signal AND MACD > Mid) OR (MACD == Signal AND the previous bar's state was Long)
Short: (MACD < Signal AND MACD < Mid) OR (MACD == Signal AND the previous bar's state was Short)