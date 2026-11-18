Long: Stochastic RSI(close, lookback, lookback) crosses above long threshold AND SMA(close, shorter lookback) > SMA(close, longer lookback) AND close < VWAP(hlc3)
Short: Stochastic RSI(close, lookback, lookback) crosses below short threshold AND SMA(close, shorter lookback) < SMA(close, longer lookback) AND close > VWAP(hlc3)
Exit: long, low <= close[1] - stop distance in ticks OR high >= close[1] + take-profit distance in ticks
Exit: short, high >= close[1] + stop distance in ticks OR low <= close[1] - take-profit distance in ticks