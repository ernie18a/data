Calculation: Negative Volume Index = increase by the close-to-close percentage change when volume is lower than on the previous bar; otherwise unchanged.
Calculation: NVI exponential moving average = exponential moving average of the Negative Volume Index.
Calculation: Lower channel band = selected lower Bollinger band (basis minus a multiplier times standard deviation) or lower Keltner band (EMA basis minus a multiplier times EMA of true range).
Long: position is flat AND close < lower channel band AND Negative Volume Index > NVI exponential moving average
Exit: long, Negative Volume Index < NVI exponential moving average OR take profit is enabled AND close > entry price × (1 + take profit percentage / 100) OR stop loss is enabled AND close < entry price × (1 − stop loss percentage / 100)