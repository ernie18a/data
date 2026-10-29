Calculation: Bullish consensus = at least half of these six comparisons are true: RSI > midpoint; smoothed stochastic > midpoint OR smoothed stochastic > its signal; stochastic RSI > midpoint; MACD line > signal line; Williams %R > midpoint; CCI > zero
Calculation: Bearish consensus = at least half of these six comparisons are true: RSI < midpoint; smoothed stochastic < midpoint OR smoothed stochastic < its signal; stochastic RSI < midpoint; MACD line < signal line; Williams %R < midpoint; CCI < zero
Calculation: Stochastic RSI = RSI normalized between its rolling low and high, scaled to a percentage
Calculation: Williams %R = negative percentage of the rolling high-to-low range from the rolling high to close
Calculation: CCI = (close − simple moving average of close) / (0.015 × mean absolute deviation of close)
Calculation: Positive and negative directional indicators = Wilder-smoothed positive high changes and negative low changes, respectively, each divided by Wilder-smoothed true range and scaled to a percentage
Calculation: ADX = Wilder-smoothed DX, where DX is the absolute difference between the positive and negative directional indicators divided by their sum, scaled to a percentage
Calculation: Normalized trend strength = absolute value of the average of TEMA change over a short lookback, LSMA change over a medium lookback, and EMA change over a long lookback, divided by ATR
Calculation: Bullish trend alignment = TEMA, LSMA, and EMA are each rising; when full alignment is not required, TEMA > LSMA and close > EMA
Calculation: Bearish trend alignment = TEMA, LSMA, and EMA are each falling; when full alignment is not required, TEMA < LSMA and close < EMA
Calculation: Trend exhaustion = aligned trend has lasted longer than twice its minimum duration AND (normalized trend strength is below its threshold OR alignment has broken OR momentum diverges); bullish-trend divergence is close higher than its long-lookback value while RSI is lower, and bearish-trend divergence is close lower while RSI is higher
Calculation: Oversold zone = the average percentage distance of close above or below TEMA, LSMA, and EMA is below the negative oversold threshold; extreme oversold uses the more extreme threshold. Overbought and extreme overbought use the corresponding positive thresholds
Calculation: Last pivot high and low = most recent confirmed local high and low, using equal left and right lookbacks
Calculation: Liquidity sweep down = low < last pivot low AND close > prior bar high AND prior bar high − low exceeds the minimum ATR-scaled sweep size
Calculation: Liquidity sweep up = high > last pivot high AND close < prior bar low AND high − prior bar low exceeds the minimum ATR-scaled sweep size
Calculation: Bullish structure retest = close is within the retest tolerance of the EMA value recorded at its latest upward cross AND close > open
Calculation: Bearish structure retest = close is within the retest tolerance of the EMA value recorded at its latest downward cross AND close < open
Calculation: Lower high = high < last pivot high AND high > prior bar high
Calculation: EMA test count = count of distinct closes within the ATR-scaled test distance of EMA, reset when close is farther than the reset distance
Calculation: Bullish reversal trend = close > KAMA AND KAMA is rising AND (ADX exceeds its threshold OR positive directional indicator > negative directional indicator)
Calculation: Bearish reversal trend = close < KAMA AND KAMA is falling AND (ADX exceeds its threshold OR negative directional indicator > positive directional indicator)
Calculation: Volume confirmation = volume > its moving average × volume multiplier
Long: liquidity sweep down
Short: liquidity sweep up
Long: position is flat AND no ideal sell condition is true AND (liquidity sweep down AND close > EMA AND volume confirmation OR bullish structure retest AND TEMA > LSMA AND volume confirmation OR oversold or extreme oversold zone AND close > EMA AND TEMA > LSMA AND volume confirmation)
Short: position is flat AND (bearish structure retest AND TEMA < LSMA AND volume confirmation OR lower high AND overbought or extreme overbought zone AND TEMA < LSMA OR EMA test count reaches its maximum AND close < EMA AND TEMA < LSMA AND close crosses below EMA)
Long: position is flat AND no ideal action is active AND bullish reversal trend AND bullish consensus AND volume > its moving average × reversal volume multiplier
Short: position is flat AND no ideal action is active AND bearish reversal trend AND bearish consensus AND volume > its moving average × reversal volume multiplier
Long: position is flat AND no ideal action or reversal entry is active AND volume confirmation AND TEMA crosses above LSMA AND (bullish trend alignment OR trend is exhausted and the current trend is bearish)
Short: position is flat AND no ideal action or reversal entry is active AND volume confirmation AND TEMA crosses below LSMA AND (bearish trend alignment OR trend is exhausted and the current trend is bullish)
Exit: long, low <= entry price − stop-loss ATR multiple × ATR OR high >= entry price + take-profit ATR multiple × ATR OR the trailing stop is hit OR bars since entry >= maximum holding bars
Exit: short, high >= entry price + stop-loss ATR multiple × ATR OR low <= entry price − take-profit ATR multiple × ATR OR the trailing stop is hit OR bars since entry >= maximum holding bars