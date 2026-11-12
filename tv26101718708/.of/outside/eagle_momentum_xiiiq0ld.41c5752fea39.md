Long-only entry framework on the traded instrument, using a benchmark index (an outside instrument) for a relative-strength check. It produces no short or exit signals. On each bar, evaluate up to seven boolean conditions:
1. Trend: close is above a medium-term EMA, and that EMA is above a long-term SMA.
2. MACD momentum: the MACD histogram is positive and greater than its previous-bar value.
3. RSI zone: RSI is between a lower and an upper bound, inclusive, which defines a bullish-but-not-overbought band.
4. Bollinger: close is above the Bollinger middle band, which is the SMA of close.
5. Volume surge: volume is at least a multiplier above its simple moving average, with a multiplier greater than 1.
6. SuperTrend: the SuperTrend direction is bullish (price above the line, ATR-based).
7. Relative strength, optional via a toggle: the instrument's percentage return over a fixed lookback is greater than the benchmark index's percentage return over the same lookback on the same timeframe. The benchmark is fetched as a separate security series. If the toggle is off, this condition is treated as true and excluded from the count.

Score = the number of conditions that are true. Total checks = 7 if relative strength is enabled, otherwise 6.
- Perfect match: score equals total checks.
- Almost there: score is at least round(0.75 * total checks) and it is not a perfect match.
- Eagle signal: perfect match or almost there.

Entry trigger (go long): the eagle signal is true on the current bar AND the MACD line crossed above its signal line on the current bar or any of the previous three bars. Fire the entry on the bar where the trigger turns true from false (rising edge). There is no exit or short logic; positions would be closed by external rules.