Long: Position side is flat AND current chart-bar close > linear weighted moving average of closes on the last completed bar of a higher or lower timeframe
Short: Position side is flat AND current chart-bar close < linear weighted moving average of closes on the last completed bar of a higher or lower timeframe
Long: Position side is flat AND current chart-bar close > exponential moving average of closes on the last completed chart bar
Short: Position side is flat AND current chart-bar close < exponential moving average of closes on the last completed chart bar
Exit: long, last completed chart-bar close < exponential moving average of closes on the last completed chart bar
Exit: short, last completed chart-bar close > exponential moving average of closes on the last completed chart bar
Exit: long, current chart-bar close - entry price >= take-profit distance
Exit: short, entry price - current chart-bar close >= take-profit distance