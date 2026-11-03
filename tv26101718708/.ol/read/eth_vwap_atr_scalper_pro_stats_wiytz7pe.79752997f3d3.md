Calculation: ATR buffer = Average True Range × buffer multiplier
Calculation: Long stop = lowest low over the lookback − ATR buffer
Calculation: Short stop = highest high over the lookback + ATR buffer
Calculation: Long TP1 = entry price + Average True Range × TP1 multiplier
Calculation: Long TP2 = entry price + Average True Range × TP2 multiplier
Calculation: Short TP1 = entry price − Average True Range × TP1 multiplier
Calculation: Short TP2 = entry price − Average True Range × TP2 multiplier
Long: close > VWAP + ATR buffer AND close > open AND close > previous bar high AND RSI > its neutral level
Short: close < VWAP − ATR buffer AND close < open AND close < previous bar low AND RSI < its neutral level
Exit: Long, low <= Long stop OR high >= Long TP2 OR (high >= Long TP1 AND high < Long TP2)
Exit: Short, high >= Short stop OR low <= Short TP2 OR (low <= Short TP1 AND low > Short TP2)