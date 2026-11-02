Calculation: Trend score = when enabled, 0.4 × EMA alignment score + 0.3 × price score + 0.3 × directional ADX score; otherwise 0. Using short-, medium-, and long-period close EMAs, EMA alignment score is 100 for short > medium > long, -100 for short < medium < long, and otherwise the sum of 33 × sign(short - medium) and 33 × sign(medium - long). Price score is 100 when close is above all three EMAs, -100 when below all three, and otherwise 50 × sign(close - medium EMA). Directional ADX score is min(100, 50 × ADX / ADX threshold), multiplied by 1 if +DI > -DI and by -1 otherwise.
Calculation: Momentum score = when enabled, 0.35 × 2 × (RSI - 50) + 0.4 × MACD score + 0.25 × 2 × (stochastic %K - 50); otherwise 0. MACD score is clamp(200000 × MACD histogram / close, -100, 100), multiplied by 1 when MACD line > signal line AND histogram > 0, by -1 when MACD line < signal line AND histogram < 0, and otherwise by 0.25 when histogram > 0 or -0.25 when histogram <= 0. MACD uses a shorter and a longer EMA and a signal EMA.
Calculation: Volatility score = when enabled, a positive squeeze bonus if Bollinger Band width's rolling range position is below its squeeze threshold; otherwise a negative score if ATR percentage's rolling range position exceeds its upper threshold, a smaller positive score if it exceeds an intermediate threshold, or a larger positive score otherwise. When disabled, the score is 0. ATR percentage is 100 × ATR / close; Bollinger Band width is 100 × (upper band - lower band) / middle band. Rolling range position is 100 × (current value - rolling minimum) / (rolling maximum - rolling minimum), including the current bar; both positions use the same lookback.
Calculation: Volume score = when enabled, clamp(0.35 × OBV score + 0.3 × 200 × CMF + 0.35 × 2 × (MFI - 50), -100, 100); otherwise 0. OBV score is 50 when OBV > its EMA and -50 otherwise. MFI uses typical price.
Calculation: Composite score = weighted sum of the enabled trend, momentum, volatility, and volume scores divided by the sum of their enabled weights; use 1 as the divisor if that sum is 0.
Calculation: Signal probability = max(bull probability, 100 - bull probability) × (0.7 × alignment / 100 + 0.3), where bull probability = clamp(50 + 0.5 × composite score, 0, 100), and alignment = max(0, 100 - population standard deviation of the enabled trend, momentum, and volume scores); use zero dispersion when fewer than two of those scores are enabled.
Calculation: Bollinger Band position = 100 × (close - lower band) / (upper band - lower band).
Long: Composite score > 0.
Short: Composite score < 0.
Long: Composite score crosses above 0 AND signal probability >= signal threshold.
Short: Composite score crosses below 0 AND signal probability >= signal threshold.
Long: Composite score > 0 AND signal probability >= recommendation threshold.
Short: Composite score < 0 AND signal probability >= recommendation threshold.
Long: Trend score > positive trend threshold.
Short: Trend score <= negative trend threshold.
Long: Trend score crosses above positive trend threshold.
Short: Trend score crosses below negative trend threshold.
Long: Short-period close EMA > medium-period close EMA AND medium-period close EMA > long-period close EMA.
Short: Short-period close EMA < medium-period close EMA AND medium-period close EMA < long-period close EMA.
Long: ADX > ADX threshold AND +DI > -DI.
Short: ADX > ADX threshold AND +DI <= -DI.
Long: Momentum score > positive bullish threshold AND momentum score <= higher overbought threshold.
Short: Momentum score > higher overbought threshold.
Short: Momentum score <= negative bearish threshold AND momentum score > lower oversold threshold.
Long: Momentum score <= lower oversold threshold.
Long: RSI < lower RSI threshold.
Short: RSI > upper RSI threshold.
Long: MACD line > signal line AND MACD histogram > 0.
Short: MACD line < signal line AND MACD histogram < 0.
Long: Stochastic %K crosses above its SMA.
Short: Stochastic %K crosses below its SMA.
Long: Stochastic %K < lower stochastic threshold.
Short: Stochastic %K > upper stochastic threshold.
Long: MACD histogram > 0.
Short: MACD histogram <= 0.
Long: Bollinger Band position < lower position threshold.
Short: Bollinger Band position > upper position threshold.
Long: Volume score > positive flow threshold.
Short: Volume score <= negative flow threshold.
Long: MFI < lower MFI threshold.
Short: MFI > upper MFI threshold.
Long: CMF > positive CMF threshold.
Short: CMF < negative CMF threshold.
Long: OBV > its EMA.
Short: OBV <= its EMA.