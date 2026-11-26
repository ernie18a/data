Calculation: Flow RSI = RSI(sum(volume * hlc3 when change(hlc3) > 0, flow lookback), sum(volume * hlc3 when change(hlc3) < 0, flow lookback))
Long: EMA(Flow RSI, smoothing period) crosses below oversold level AND datetime is within the configured date window
Short: EMA(Flow RSI, smoothing period) crosses above overbought level AND datetime is within the configured date window
Exit: Long, limit exits are enabled AND Flow RSI one bar ago > long exit threshold AND Flow RSI > long exit threshold
Exit: Short, limit exits are enabled AND Flow RSI one bar ago < short exit threshold AND Flow RSI < short exit threshold
Exit: Long, stop and trailing exits are enabled AND low <= entry price / (1 + stop-loss percentage)
Exit: Short, stop and trailing exits are enabled AND high >= entry price * (1 + stop-loss percentage)
Exit: Long, stop and trailing exits are enabled AND high >= entry price * (1 + take-profit percentage) AND low <= highest high since activation - (entry price - entry price / (1 + trailing offset percentage))
Exit: Short, stop and trailing exits are enabled AND low <= entry price / (1 + take-profit percentage) AND high >= lowest low since activation + (entry price * (1 + trailing offset percentage) - entry price)