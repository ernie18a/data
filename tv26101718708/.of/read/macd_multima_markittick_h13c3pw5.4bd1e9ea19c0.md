Calculation: MACD line = fast selected moving average of the chosen price source minus slow selected moving average of the same source; fast lookback is shorter than slow lookback
Calculation: Signal line = selected moving average of the MACD line with its own lookback
Calculation: Risk distance = chart-timeframe ATR × stop multiple
Calculation: Long stop = entry price − risk distance; short stop = entry price + risk distance
Calculation: Target prices = entry price ± risk distance × target multiples, with the three multiples sorted from smallest to largest
Long: On a completed chart-timeframe bar, MACD line crosses above signal line AND fast lookback < slow lookback AND ATR and both lines are available AND risk distance > one tick AND long stop > 0 AND first target > entry price
Short: On a completed chart-timeframe bar, MACD line crosses below signal line AND fast lookback < slow lookback AND ATR and both lines are available AND risk distance > one tick AND farthest short target > 0 AND short stop > entry price
Exit: long, high ≥ first target (partial close) OR high ≥ second target (partial close) OR high ≥ third target OR, on a completed bar, close < long stop OR MACD line crosses below signal line
Exit: short, low ≤ first target (partial close) OR low ≤ second target (partial close) OR low ≤ third target OR, on a completed bar, close > short stop OR MACD line crosses above signal line
Long: MACD line > selected candle reference (signal line in signal mode, zero in zero mode)
Short: MACD line < selected candle reference (signal line in signal mode, zero in zero mode)