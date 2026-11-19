Calculation: Bullish trend = close > EMA(close, long-term lookback) AND EMA(close, short-term lookback) > EMA(close, long-term lookback)
Calculation: Bearish trend = close < EMA(close, long-term lookback) AND EMA(close, short-term lookback) < EMA(close, long-term lookback)
Calculation: Bullish pin bar = high > low AND min(open, close) - low >= minimum wick fraction × (high - low) AND abs(close - open) <= maximum body fraction × (high - low)
Calculation: Bearish pin bar = high > low AND high - max(open, close) >= minimum wick fraction × (high - low) AND abs(close - open) <= maximum body fraction × (high - low)
Calculation: Bullish setup = high[2] < low OR (close[1] < open[1] AND close > high[1]) OR bullish pin bar[1]
Calculation: Bearish setup = low[2] > high OR (close[1] > open[1] AND close < low[1]) OR bearish pin bar[1]
Long: UTC hour of datetime >= first-window start AND UTC hour of datetime < first-window end OR UTC hour of datetime >= second-window start AND UTC hour of datetime < second-window end; bullish trend AND (VWAP filter disabled OR close > VWAP) AND RSI(close, lookback) < overbought threshold AND bullish setup AND position side is flat
Short: (UTC hour of datetime >= first-window start AND UTC hour of datetime < first-window end OR UTC hour of datetime >= second-window start AND UTC hour of datetime < second-window end) AND bearish trend AND (VWAP filter disabled OR close < VWAP) AND RSI(close, lookback) > oversold threshold AND bearish setup AND position side is flat
Long: bullish trend
Short: bearish trend
Long: close > VWAP
Short: close <= VWAP
Long: bullish setup
Short: bearish setup AND NOT bullish setup
Long: bullish pin bar
Short: bearish pin bar
Exit: Long, low <= entry price - stop multiple × ATR(lookback) at entry OR high >= entry price + target multiple × ATR(lookback) at entry
Exit: Short, high >= entry price + stop multiple × ATR(lookback) at entry OR low <= entry price - target multiple × ATR(lookback) at entry