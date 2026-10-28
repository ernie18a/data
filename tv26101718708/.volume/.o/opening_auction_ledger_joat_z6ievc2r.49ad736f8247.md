Calculation: Opening range = highest high and lowest low during the configured opening session (or highest max(open, close) and lowest min(open, close) in body mode), locked after the session ends
Calculation: Relative volume = current bar volume divided by the greater of its moving average over a lookback and 1
Calculation: Adaptive ATR trail = while long, the greater of the previous trail and close minus ATR times a multiplier; while short, the lesser of the previous trail and close plus ATR times a multiplier; initialize from the current close and ATR when a breakout begins
Long: flat AND opening range locked AND bar close confirmed AND close > opening range high + opening range size × minimum break fraction AND (relative volume filter disabled OR relative volume ≥ relative volume threshold)
Short: flat AND opening range locked AND bar close confirmed AND close < opening range low − opening range size × minimum break fraction AND (relative volume filter disabled OR relative volume ≥ relative volume threshold)
Exit: long, bar close confirmed AND close < adaptive ATR trail
Exit: short, bar close confirmed AND close > adaptive ATR trail