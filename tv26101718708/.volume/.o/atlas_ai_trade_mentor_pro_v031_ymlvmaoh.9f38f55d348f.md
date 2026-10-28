Calculation: Short-, medium-, and long-term EMAs = exponential moving averages of close with progressively longer lookbacks.
Calculation: Trend score = 15 if short EMA > medium EMA, 15 if medium EMA > long EMA, 10 each if close > each EMA, 10 each if each EMA is above its value at the same slope lookback ago, 5 if the short/medium EMA gap > 0.30 ATR, and 5 if the medium/long EMA gap > 0.60 ATR; cap at 100. ATR uses a lookback shorter than the 50-bar ATR moving average.
Calculation: Swing highs/lows = confirmed pivot highs/lows using equal left and right lookbacks. Higher high/low and lower high/low compare the latest confirmed pivot with the preceding confirmed pivot of the same type.
Calculation: Structure score = +10 for each higher high and higher low, −10 for each lower high and lower low, capped to −20 through 20.
Calculation: Trend long score = trend-score points (25 if trend score ≥80, else 20 if ≥70, else 15 if ≥60, else 10 if ≥50, else 0) + positive structure score +15 for bullish BOS +15 for bullish CHOCH +5 each when close is above the short, medium, or long EMA; cap at 100. Bullish BOS means close > latest confirmed swing high. Bullish CHOCH means a lower low, close > short EMA, and short EMA rising over the slope lookback.
Calculation: Trend short score = trend-score points (25 if trend score ≤20, else 20 if ≤30, else 15 if ≤40, else 10 if ≤50, else 0) + absolute value of negative structure score +15 for bearish BOS +15 for bearish CHOCH +5 each when close is below the short, medium, or long EMA; cap at 100. Bearish BOS means close < latest confirmed swing low. Bearish CHOCH means a higher high, close < short EMA, and short EMA falling over the slope lookback.
Calculation: Long/short momentum score = 15 if RSI is respectively >50/<50, plus 15 if MACD line is respectively above/below its signal line and histogram is respectively positive/negative, plus volatility points (20 if ATR as a percent of close >1.5, else 10 if >0.8, else 5) plus 10 if volume > its 20-bar average.
Calculation: Long/short final score = corresponding trend score + corresponding momentum score, capped at 100.
Calculation: Long/short target 1 and target 2 = entry price adjusted favorably by their respective percentage parameters. Initial stop = entry price adjusted adversely by the stop-loss percentage parameter. Break-even stop = entry price after close has moved favorably by the break-even trigger percentage. Trailing stop = most protective value so far of close − ATR × trailing multiplier for long, or close + ATR × trailing multiplier for short. Active stop = trailing stop when trailing is enabled and initialized, otherwise current stop.
Long: Bullish BOS (close > latest confirmed swing high)
Long: Bullish CHOCH (lower low AND close > short-term EMA AND short-term EMA > its value at the slope lookback ago)
Long: Close > short-term EMA AND short-term EMA > medium-term EMA AND medium-term EMA > long-term EMA AND RSI > 50 AND MACD line > MACD signal line AND MACD histogram > 0 AND ADX > 20 AND long final score ≥ minimum signal score
Long: Long final score ≥ 70
Long: Close > short-term EMA AND short-term EMA > medium-term EMA AND medium-term EMA > long-term EMA
Short: Bearish BOS (close < latest confirmed swing low)
Short: Bearish CHOCH (higher high AND close < short-term EMA AND short-term EMA < its value at the slope lookback ago)
Short: Close < short-term EMA AND short-term EMA < medium-term EMA AND medium-term EMA < long-term EMA AND RSI < 50 AND MACD line < MACD signal line AND MACD histogram < 0 AND ADX > 20 AND short final score ≥ minimum signal score
Short: Short final score ≥ 70
Short: Close < short-term EMA AND short-term EMA < medium-term EMA AND medium-term EMA < long-term EMA
Exit: long, Close ≥ target 1 OR close ≥ target 2 OR close ≤ active stop
Exit: short, Close ≤ target 1 OR close ≤ target 2 OR close ≥ active stop