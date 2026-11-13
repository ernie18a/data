Directional bias framework for a foreign-currency/rand pair (the traded instrument), producing a long-bias, short-bias or neutral signal from a bounded additive score. The score starts at a neutral midpoint on a fixed scale with a lower and upper bound, and the final value is clamped to that scale. Higher means bullish for the pair (rand weakness); lower means bearish for the pair (rand strength). All components are evaluated on the current bar's closed data.

Own-instrument components, each adding or subtracting a fixed weight:
1. Trend: add if close is above the fast EMA, otherwise subtract. Add if the fast EMA is above the medium EMA, otherwise subtract. Add if close is above the slow EMA, otherwise subtract, with the slow-EMA term carrying the largest trend weight.
2. Momentum: add if the short-lookback return (close versus close N bars ago) is positive, otherwise subtract. Do the same for a longer-lookback return, with equal weights.
3. MACD: add if the MACD line is above its signal line, otherwise subtract, with a relatively large weight.
4. RSI, with zones checked in order. Very high RSI (overbought) adds a small amount. Moderately high RSI (above the upper-mid threshold) adds a slightly larger amount. Very low RSI subtracts a small amount. Moderately low RSI (below the lower-mid threshold) subtracts a slightly larger amount. Anything else adds nothing. Because the zones are checked in order, the extreme zones take precedence over the moderate ones.
5. Bollinger position: compute the percent-B of close within the bands. Add a small amount if it is in the upper part of the band range, and subtract the same amount if it is in the lower part.
6. Volatility pressure: compute annualised realised volatility from the standard deviation of log returns, and compare it with its own long-run moving average. If current volatility is well above that average, add a small amount. If it is well below, subtract a smaller amount.

Outside-data component (optional, toggled by a switch and off by default): fetch three external series on the chart timeframe, a USD index, a US 10-year yield and a volatility index (VIX). For each, compute its percentage change over the last 20 bars. For each series, add a small fixed amount if the change is positive and subtract the same amount if it is negative. Add nothing if the change is zero. The three terms have equal weight, and a rising USD index, rising US yield or rising VIX each push the score toward bullish for the pair.

Decision rule from the clamped score:
- Score at or above the upper threshold (about 70 on a 0-100 scale): bullish regime, so long bias on the pair (rand pressure).
- Score at or below the lower threshold (about 30): bearish regime, so short bias on the pair (rand support).
- Anything in between is neutral or mixed, so stay flat or no new bias. The neutral zone is also where a prior directional bias would lapse.

The signal is a regime or filter. Entry timing, stops and invalidation are left to the user's price structure and risk management, and the logic defines no stop or target.