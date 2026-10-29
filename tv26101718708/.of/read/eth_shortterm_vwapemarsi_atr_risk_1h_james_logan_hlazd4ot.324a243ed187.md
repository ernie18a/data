Long: EMA(close, long-term) > EMA(close, short-term) AND close > VWAP AND close >= EMA(close, shorter lookback) AND low <= EMA(close, shorter lookback) AND RSI crosses above its threshold
Short: EMA(close, long-term) < EMA(close, short-term) AND close < VWAP AND close <= EMA(close, shorter lookback) AND high >= EMA(close, shorter lookback) AND RSI crosses below its threshold
Calculation: Long stop = close - ATR × stop multiple
Calculation: Long take-profit = close + ATR × take-profit multiple
Calculation: Short stop = close + ATR × stop multiple
Calculation: Short take-profit = close - ATR × take-profit multiple
Calculation: Long trailing stop = maximum of (close - ATR × trailing multiple) and long stop
Calculation: Short trailing stop = minimum of (close + ATR × trailing multiple) and short stop
Exit: long, low <= long stop OR high >= long take-profit OR low <= long trailing stop OR bars since entry >= time limit OR short condition
Exit: short, high >= short stop OR low <= short take-profit OR high >= short trailing stop OR bars since entry >= time limit OR long condition