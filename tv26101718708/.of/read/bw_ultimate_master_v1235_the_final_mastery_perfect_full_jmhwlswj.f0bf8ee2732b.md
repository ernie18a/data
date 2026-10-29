Calculation: Awesome Oscillator = 5-bar SMA of (high + low)/2 minus 34-bar SMA of (high + low)/2.
Calculation: Acceleration/Deceleration = Awesome Oscillator minus its 5-bar SMA.
Calculation: Higher-timeframe trend = compare the sign of the Awesome Oscillator on higher-timeframe weekly, daily, and 4-hour bars, weighted 3, 2, and 2 respectively; bullish if bullish weight exceeds bearish weight and is at least 5, bearish if bearish weight exceeds bullish weight and is at least 5. Use the higher-timeframe bar still forming.
Calculation: Last confirmed swing high/low = most recent pivot high/low with 5 bars on each side; confirm only after the 5 right-side bars have completed.
Calculation: Bullish engulfing = close > open, close ≥ prior open and close, and open ≤ prior open and close. Bearish engulfing = close < open, close ≤ prior open and close, and open ≥ prior open and close.
Calculation: Bullish pin bar = lower wick ≥ 2 × body and upper wick ≤ 0.5 × body. Bearish pin bar = upper wick ≥ 2 × body and lower wick ≤ 0.5 × body. Body = max(abs(close − open), 0.001).
Calculation: Bullish/bearish EMA retest = low ≤ EMA( close, 30 ) and close > EMA( close, 30 ) / high ≥ EMA( close, 30 ) and close < EMA( close, 30 ), respectively.
Calculation: Bullish/bearish momentum = current Acceleration/Deceleration > / < its prior-bar value.
Calculation: Bullish/bearish structure break = close crosses above the last confirmed swing high / below the last confirmed swing low, respectively.
Calculation: Bullish/bearish price action = bullish engulfing or bullish pin bar / bearish engulfing or bearish pin bar, respectively.
Calculation: Recent low/high sweep = low ≤ the lowest low / high ≥ the highest high of the prior 15 bars; retain the sweep state for at most 15 subsequent bars, resetting its age on another sweep.
Calculation: Bullish/bearish structure shift = while the corresponding recent sweep state is active, close crosses above the last confirmed swing high / below the last confirmed swing low, respectively.
Calculation: Bullish/bearish retest level = average of the lowest low of the latest 15 bars and the close at bullish structure shift / average of the highest high of the latest 15 bars and the close at bearish structure shift, respectively. Wait for a retest after the shift.
Calculation: Signal cooldown is clear when more than the configured cooldown bars have elapsed since the prior buy or sell signal, or the absolute distance from the current close to that signal's close exceeds current ATR(14) times the configured cooldown distance.
Calculation: Asia 07:00 open = open of the chart-timeframe bar that begins at 07:00 Asia/Bangkok.
Long: At least 3 of these 4 conditions are true: bullish structure break; bullish price action; bullish EMA retest; bullish higher-timeframe trend and bullish momentum. RSI(14) ≤ 68. Signal cooldown is clear.
Long: A recent low sweep is active, close crosses above the last confirmed swing high, and after that shift low ≤ bullish retest level and close > open. Signal cooldown is clear.
Long: close > Asia 07:00 open.
Short: At least 3 of these 4 conditions are true: bearish structure break; bearish price action; bearish EMA retest; bearish higher-timeframe trend and bearish momentum. RSI(14) ≥ 32. Signal cooldown is clear.
Short: A recent high sweep is active, close crosses below the last confirmed swing low, and after that shift high ≥ bearish retest level and close < open. Signal cooldown is clear.
Short: close ≤ Asia 07:00 open.
Short: Higher-timeframe 4-hour Awesome Oscillator < 0 and bearish divergence: a confirmed price pivot high exceeds the prior confirmed price pivot high while its associated RSI(14) pivot high is lower. Use the higher-timeframe bar still forming.