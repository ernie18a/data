Calculation: Opening-range high = highest high of the lower-timeframe M1 bars in the opening range, using completed bars
Calculation: Opening-range low = lowest low of the lower-timeframe M1 bars in the opening range, using completed bars
Long: last completed chart-timeframe close > opening-range high + breakout buffer AND datetime is after the opening range ends and no later than the trading window end AND opening range high > opening-range low
Short: last completed chart-timeframe close < opening-range low - breakout buffer AND datetime is after the opening range ends and no later than the trading window end AND opening-range high > opening-range low
Exit: long, bar low <= opening-range low - stop buffer OR bar high >= entry price + reward-to-risk ratio × (entry price - stop loss)
Exit: short, bar high >= opening-range high + stop buffer OR bar low <= entry price - reward-to-risk ratio × (stop loss - entry price)