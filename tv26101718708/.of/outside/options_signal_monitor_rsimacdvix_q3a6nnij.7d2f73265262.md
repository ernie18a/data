Evaluate on each closed bar of the chart instrument. Compute RSI, MACD (line, signal line, histogram) and two EMAs of close, a short one and a long one. Each signal needs all three conditions to hold at once.

BUY CALL (bullish option entry):
1. RSI is strictly between the oversold and overbought levels.
2. MACD is bullish: the MACD line crosses above its signal line on this bar, OR the histogram is above zero and higher than on the previous bar.
3. Trend is up: close is above the short EMA, and the short EMA is above the long EMA.

BUY PUT (bearish option entry):
1. RSI is above the neutral midline (50) and at or below the overbought level plus a small buffer.
2. MACD is bearish: the MACD line crosses below its signal line on this bar, OR the histogram is below zero and lower than on the previous bar.
3. Trend is down: close is below the short EMA, and the short EMA is below the long EMA.

EXIT / STOP (close the option position):
- Exit a call if a call-buy signal was true 3 bars ago and RSI is now below the oversold level.
- Exit a put if a put-buy signal was true 3 bars ago and RSI is now above the overbought level.

Notes:
- The call and put conditions cannot both be true on the same bar.
- A volatility-index series is fetched, and calm and fear flags are computed from it, but neither flag feeds any entry or exit. Ignore it.
- Strike, expiry, max premium and premium-based stop values are only labels and alert text, not decision inputs.