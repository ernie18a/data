Option-buying framework, evaluated once per bar on closed-bar data, with a sector index series on the same timeframe as outside data. It only ever buys options; it defines no exit rule, and stops, targets and strike suggestions are informational only.

Inputs: the traded instrument's close, volume and RSI; a fast and a slow EMA of its close; and a sector index's close and its own EMA.

Bullish score: one point for each true condition.
1. Fast EMA is above slow EMA.
2. Close is above the previous close. This is the 'OI proxy': long buildup and short covering are both just price-up, whatever the volume.
3. Sector index close is above the sector index's own EMA.
4. RSI is below an upper overbought threshold, so it is not overbought.
5. Volume is above a multiple of its longer-term average (volume spike).

Bearish score: the mirror image, one point for each true condition.
1. Fast EMA is not above slow EMA.
2. Close is not above the previous close.
3. Sector index close is not above its EMA.
4. RSI is above a lower oversold threshold, so it is not oversold.
5. The same volume spike (counts for both sides).

Decisions:
- BUY CALL (long call option): on the bar where the fast EMA crosses above the slow EMA, and the bullish score is at least four out of five.
- BUY PUT (long put option): on the bar where the fast EMA crosses below the slow EMA, and the bearish score is at least four out of five.
- Otherwise do nothing. A score of three, or a score of four or more without an EMA cross on that bar, is a weak or no setup and triggers no trade.

On a cross bar the EMA-trend point is automatically satisfied, so the cross bar needs at least three of the other four conditions.