Short-only strategy on the traded instrument (gold), driven by a second instrument (crude oil) sampled on the same timeframe as the chart, using completed bars only with no lookahead.

Oil state, evaluated each bar from oil closes:
1. Oil uptrend: the fast EMA of oil close is above the mid EMA, the mid EMA is above the slow EMA, and the oil close is above the fast EMA.
2. Oil spike: the percent change of oil close versus the oil close N bars earlier is at or above a positive threshold.
3. Oil alert: the uptrend and the spike are both true on the same bar.

Entry: open a short on the traded instrument at the bar close when the oil alert turns true. It must be false on the previous bar and true on the current one. While the alert stays true, do not re-enter. A new entry needs the alert to go false and then true again. Do not enter if a short is already open.

Risk levels, set at entry from the traded instrument's own bar:
- Stop-loss = the entry bar's high plus ATR (of the traded instrument) times a stop multiplier.
- Take-profit = entry close minus (stop-loss minus entry close) times a reward-to-risk ratio.

Exit: close the short when price reaches the stop-loss (price at or above it) or the take-profit (price at or below it). The levels stay fixed until the next entry replaces them.

No long signals exist. The traded instrument's own EMA trend, RSI and the oil-trend-turned-up event are informational only. They do not gate entries or exits.