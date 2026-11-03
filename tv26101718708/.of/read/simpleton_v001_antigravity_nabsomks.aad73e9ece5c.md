Calculation: Z-score = (close − SMA of close) / standard deviation of close over the same lookback; use zero when the standard deviation is zero.
Calculation: Bollinger width = (upper Bollinger band − lower Bollinger band) / middle Bollinger band.
Calculation: VWAP deviation bands = session VWAP of (high + low + close) / 3, plus or minus a multiplier times the standard deviation of (close − session VWAP) over a lookback.
Calculation: Long votes and short votes = counts of the seven corresponding entry conditions below, from RSI mean reversion through VWAP deviation, including their optional trend filters.
Long: selected strategy = RSI mean reversion AND RSI of close < entry threshold AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = RSI mean reversion AND RSI of close > RSI maximum − entry threshold AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = RSI mean reversion AND RSI of close > exit threshold.
Exit: short, selected strategy = RSI mean reversion AND RSI of close < RSI maximum − exit threshold.
Long: selected strategy = Z-score mean reversion AND Z-score < −entry threshold AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = Z-score mean reversion AND Z-score > entry threshold AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = Z-score mean reversion AND Z-score > −exit threshold.
Exit: short, selected strategy = Z-score mean reversion AND Z-score < exit threshold.
Long: selected strategy = EMA and RSI momentum AND shorter EMA of close crosses above longer EMA of close AND RSI of close < upper threshold AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = EMA and RSI momentum AND shorter EMA of close crosses below longer EMA of close AND RSI of close > lower threshold AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = EMA and RSI momentum AND (shorter EMA crosses below longer EMA OR RSI > upper exit threshold).
Exit: short, selected strategy = EMA and RSI momentum AND (shorter EMA crosses above longer EMA OR RSI < lower exit threshold).
Long: selected strategy = Bollinger squeeze AND close < lower Bollinger band AND previous bar's Bollinger width < its SMA over the Bollinger lookback divided by a squeeze multiplier AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = Bollinger squeeze AND close > upper Bollinger band AND previous bar's Bollinger width < its SMA over the Bollinger lookback divided by a squeeze multiplier AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = Bollinger squeeze AND close > middle Bollinger band.
Exit: short, selected strategy = Bollinger squeeze AND close < middle Bollinger band.
Long: selected strategy = MACD and RSI AND MACD line crosses above its signal line AND RSI of close < RSI midpoint AND MACD histogram > previous MACD histogram AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = MACD and RSI AND MACD line crosses below its signal line AND RSI of close > RSI midpoint AND MACD histogram < previous MACD histogram AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = MACD and RSI AND (MACD line crosses below its signal line OR RSI > upper exit threshold).
Exit: short, selected strategy = MACD and RSI AND (MACD line crosses above its signal line OR RSI < lower exit threshold).
Long: selected strategy = triple EMA AND shortest EMA of close crosses above middle EMA of close AND middle EMA > longest EMA of close AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = triple EMA AND shortest EMA of close crosses below middle EMA of close AND middle EMA < longest EMA of close AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = triple EMA AND shortest EMA < middle EMA.
Exit: short, selected strategy = triple EMA AND shortest EMA > middle EMA.
Long: selected strategy = VWAP deviation AND close < lower VWAP deviation band AND (trend filter disabled OR close > trend SMA of close).
Short: selected strategy = VWAP deviation AND close > upper VWAP deviation band AND (trend filter disabled OR close < trend SMA of close).
Exit: long, selected strategy = VWAP deviation AND close > session VWAP.
Exit: short, selected strategy = VWAP deviation AND close < session VWAP.
Long: selected strategy = consensus AND long votes >= consensus threshold.
Short: selected strategy = consensus AND short votes >= consensus threshold.
Exit: long, selected strategy = consensus AND long votes = 0.
Exit: short, selected strategy = consensus AND short votes = 0.
Long: long votes >= alert consensus threshold.
Short: short votes >= alert consensus threshold.
Long: RSI of close < display lower threshold.
Short: RSI of close > display upper threshold.
Long: Z-score < negative display threshold.
Short: Z-score > positive display threshold.
Long: close > trend SMA of close.
Short: close <= trend SMA of close.
Exit: long, time exit enabled AND bars in position >= maximum bars.
Exit: short, time exit enabled AND bars in position >= maximum bars.
Exit: long, profit and stop orders enabled AND (high >= entry price + latest close-based profit distance OR low <= entry price − latest close-based loss distance).
Exit: short, profit and stop orders enabled AND (low <= entry price − latest close-based profit distance OR high >= entry price + latest close-based loss distance).
Exit: long, profit and stop orders enabled AND trailing enabled AND price has reached entry price + latest close-based trailing activation distance AND low <= highest price since activation − latest close-based trailing offset.
Exit: short, profit and stop orders enabled AND trailing enabled AND price has reached entry price − latest close-based trailing activation distance AND high >= lowest price since activation + latest close-based trailing offset.
Calculation: Close-based profit, loss, and trailing activation distances = most recent completed bar's close multiplied by their respective percentage parameters; trailing offset = half the close-based trailing activation distance. Update the active exit order after each bar.