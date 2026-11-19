Calculation: Mansfield relative strength = (traded instrument close / benchmark close / SMA(traded instrument close / benchmark close, RS smoothing length) - 1) * 100
Calculation: Relative volume = traded instrument volume / SMA(traded instrument volume, RVOL averaging length), when the average is nonzero; undefined otherwise
Calculation: Volatility contraction = ATR(traded instrument high, low, close, VCP ATR length) < SMA(ATR(traded instrument high, low, close, VCP ATR length), VCP ATR smoothing length) * ATR contraction ratio AND SMA(traded instrument close, Bollinger length) != 0 AND Bollinger Band Width(traded instrument close, Bollinger length, Bollinger deviation multiplier) < SMA(Bollinger Band Width(traded instrument close, Bollinger length, Bollinger deviation multiplier), Bollinger length)
Calculation: Bullish signal count = count of bullish conditions among Mansfield relative strength > 0, Supertrend direction < 0, MACD line > MACD signal line, RSI > RSI threshold, traded instrument close > fast EMA AND fast EMA > slow EMA, and positive DI > negative DI
Long: Mansfield relative strength > 0
Short: Mansfield relative strength <= 0
Long: Supertrend(traded instrument high, low, close, Supertrend ATR factor, Supertrend ATR length).direction < 0
Short: Supertrend(traded instrument high, low, close, Supertrend ATR factor, Supertrend ATR length).direction >= 0
Long: MACD(traded instrument close, MACD fast length, MACD slow length, MACD signal length).line > MACD(traded instrument close, MACD fast length, MACD slow length, MACD signal length).signal
Short: MACD(traded instrument close, MACD fast length, MACD slow length, MACD signal length).line <= MACD(traded instrument close, MACD fast length, MACD slow length, MACD signal length).signal
Long: RSI(traded instrument close, RSI length) > RSI threshold
Short: RSI(traded instrument close, RSI length) <= RSI threshold
Long: traded instrument close > EMA(traded instrument close, fast EMA length) AND EMA(traded instrument close, fast EMA length) > EMA(traded instrument close, slow EMA length)
Short: traded instrument close <= EMA(traded instrument close, fast EMA length) OR EMA(traded instrument close, fast EMA length) <= EMA(traded instrument close, slow EMA length)
Long: positive DI of DMI(traded instrument high, low, close, DI length) > negative DI of DMI(traded instrument high, low, close, DI length)
Short: positive DI of DMI(traded instrument high, low, close, DI length) <= negative DI of DMI(traded instrument high, low, close, DI length)
Long: bullish signal count > half of the six directional signals
Short: bullish signal count <= half of the six directional signals
Long: Mansfield relative strength > 0 AND Relative volume >= RVOL expansion threshold
Long: Volatility contraction AND Relative volume >= RVOL expansion threshold AND Mansfield relative strength > 0
Long: Volatility contraction AND bullish signal count > half of the six directional signals
Long: bullish signal count equals the number of directional signals
Short: bullish signal count = 0