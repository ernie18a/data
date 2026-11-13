Long-only, one position at a time, evaluated on each bar of an ETF against a benchmark index (default SPY), whose close is fetched on the same timeframe.

Definitions:
- Relative strength (RSMK): take the ratio of the instrument's close to the benchmark's close. Compute ln(ratio now) minus ln(ratio N bars ago), treating a missing past ratio as 0. Smooth that with a short EMA and multiply by 100.
- RSMK moving average: a long SMA of RSMK.
- Correlation: rolling correlation of the instrument's close with the benchmark's close over a long window.
- Benchmark ROC: the benchmark's percent change over the last few bars (about one trading week).
- RSI: a short-period RSI of the instrument's close.

Entry (go long at the close) when flat and ALL of the following hold:
1. Liquidity: a short SMA of volume is above a minimum volume.
2. Relative strength: RSMK is above its moving average, above a positive entry level, equal to its highest value over the last few bars (a new short-term high), and below a high overbought cap.
3. Market risk filter, either of:
   - Benchmark ROC is above a negative crash threshold AND correlation is above a positive minimum.
   - Benchmark ROC is below that crash threshold AND correlation is below the negative of that minimum.
4. Oversold pullback: the lowest RSI over a recent window (about a month) is below an oversold level, AND the current RSI is higher than it was a few bars ago.
5. Trend confirmation: a short EMA of close is above the value that a medium SMA of close had a few bars ago.

Record the entry price (the close) and the entry bar.

Exit (go flat) when in a long and ANY of the following holds:
- RSMK is below the negative of the entry level AND correlation with the benchmark is very high (above a high correlation threshold).
- Close is at or above the entry price times a profit-target multiplier (about +25%).
- The number of bars since entry is at least a fixed holding limit (about 30 bars).

A new entry is not allowed while a position is open. There are no short signals and no stop loss.