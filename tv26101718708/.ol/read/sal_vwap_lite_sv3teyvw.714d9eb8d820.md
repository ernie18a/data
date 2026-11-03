Calculation: Short-lookback SMA = simple moving average of chart-timeframe close with a shorter lookback than the long-lookback SMA
Calculation: Long-lookback SMA = simple moving average of chart-timeframe close with a longer lookback than the short-lookback SMA
Calculation: VWAP = session cumulative volume-weighted average of (high + low + close) / 3
Calculation: Prior upper wick = previous chart bar high − max(previous chart bar open, previous chart bar close)
Calculation: Prior lower wick = min(previous chart bar open, previous chart bar close) − previous chart bar low
Long: Higher-timeframe close > higher-timeframe VWAP on the last completed higher-timeframe bar AND another higher-timeframe close > its VWAP on the last completed bar AND short-lookback SMA > long-lookback SMA AND chart close > long-lookback SMA AND chart close > chart VWAP AND prior upper wick >= minimum wick threshold AND RSI > bullish threshold
Short: Higher-timeframe close < higher-timeframe VWAP on the last completed higher-timeframe bar AND another higher-timeframe close < its VWAP on the last completed bar AND short-lookback SMA < long-lookback SMA AND chart close < long-lookback SMA AND chart close < chart VWAP AND prior lower wick >= minimum wick threshold AND RSI < bearish threshold
Exit: Long, high >= entry price + profit target distance OR low <= entry price − stop-loss distance
Exit: Short, low <= entry price − profit target distance OR high >= entry price + stop-loss distance