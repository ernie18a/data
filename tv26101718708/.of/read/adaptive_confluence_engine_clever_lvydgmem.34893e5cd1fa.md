Calculation: Bullish score = sum of higher weights for close > long-term EMA, bullish Supertrend, MACD line > signal line AND MACD histogram > zero, RSI > bullish lower threshold AND RSI < bullish upper threshold, and (higher-timeframe filter disabled OR higher-timeframe close > higher-timeframe long-term EMA); plus lower weights for short-term EMA > medium-term EMA, smoothed stochastic RSI K > its signal AND K < upper threshold, ADX > threshold AND positive DI > negative DI, volume > its SMA, close > previous open AND open < previous close AND previous close < previous open, and ATR > its SMA multiplied by a factor. All higher weights are equal and exceed the equal lower weights.
Calculation: Bearish score = sum of higher weights for close < long-term EMA, bearish Supertrend, MACD line < signal line AND MACD histogram < zero, RSI < bearish upper threshold AND RSI > bearish lower threshold, and (higher-timeframe filter disabled OR higher-timeframe close < higher-timeframe long-term EMA); plus lower weights for short-term EMA < medium-term EMA, smoothed stochastic RSI K < its signal AND K > lower threshold, ADX > threshold AND negative DI > positive DI, volume > its SMA, close < previous open AND open > previous close AND previous close > previous open, and ATR > its SMA multiplied by a factor. All higher weights are equal and exceed the equal lower weights. The RSI thresholds in ascending order are bearish lower, bullish lower, bearish upper, bullish upper.
Calculation: Smoothed stochastic RSI K = SMA of stochastic applied to RSI as its high, low, and close inputs; its signal = SMA of K.
Calculation: Higher-timeframe close and EMA = values from the last completed higher-timeframe bar, including the bar that completes with the current chart bar.
Calculation: Entry ATR = ATR on the bar where a new position is opened. Stop and target levels remain fixed from that entry; target multipliers increase from first to third. A first-target hit is remembered until the next position is opened, including when the first target is reached on the entry bar.
Long: Short-term EMA crosses above medium-term EMA AND bullish score >= score threshold.
Short: Short-term EMA crosses below medium-term EMA AND bearish score >= score threshold.
Long: Close > long-term EMA.
Short: Close <= long-term EMA.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: Low > high two bars earlier.
Short: High < low two bars earlier.
Long: RSI < lower extreme threshold.
Short: RSI > upper extreme threshold.
Long: ADX > trend threshold AND close > long-term EMA.
Short: ADX > trend threshold AND close <= long-term EMA.
Long: Higher-timeframe filter disabled OR higher-timeframe close > higher-timeframe long-term EMA.
Short: Higher-timeframe filter enabled AND higher-timeframe close <= higher-timeframe long-term EMA.
Exit: Long, high >= entry price + entry ATR multiplied by a target multiplier.
Exit: Short, low <= entry price - entry ATR multiplied by a target multiplier.
Exit: Long, low <= entry price - entry ATR multiplied by the stop multiplier AND first target has not been reached, including on the current bar.
Exit: Short, high >= entry price + entry ATR multiplied by the stop multiplier AND first target has not been reached, including on the current bar.