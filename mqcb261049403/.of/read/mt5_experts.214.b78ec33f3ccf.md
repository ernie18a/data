Calculation: Open-price difference = open price at the longer lookback minus open price at the shorter lookback; use completed bars on the same timeframe as the chart
Long: open price at the longer lookback + bias < open price at the shorter lookback AND current hour = scheduled trading hour AND daily trading gate enabled AND no position is open
Short: open price at the longer lookback > open price at the shorter lookback + bias AND current hour = scheduled trading hour AND daily trading gate enabled AND no position is open
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance