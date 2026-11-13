Pair relative-value mean reversion. The traded instrument is the chart symbol, and a correlated peer symbol supplies the outside data. Evaluate only on confirmed (closed) bars, with the peer's close aligned to the chart's timeframe and no lookahead.

Model:
1. Take the log of both closes. Use log returns over a rolling window to get the correlation between chart and peer, and beta = correlation * (chart return stdev / peer return stdev).
2. Alpha = rolling mean of chart log price minus beta * rolling mean of peer log price.
3. Spread = chart log price - (alpha + beta * peer log price).
4. Z = (spread - rolling mean of spread) / rolling stdev of spread, over a separate z window. Spread velocity = z minus the previous bar's z.
5. The pair is valid when correlation is at or above a minimum and spread stdev is positive.
6. A cooldown applies: a new primary entry is allowed only if no primary entry has fired within a set number of bars.

Primary entries:
- Long the chart symbol (chart is cheap vs peer): pair valid, z at or below the negative entry threshold, spread velocity positive (z already turning up), cooldown elapsed.
- Short the chart symbol (chart is rich vs peer): pair valid, z at or above the positive entry threshold, spread velocity negative (z already turning down), cooldown elapsed.
- Record the bar of each entry for the cooldown.

Exit:
- Define 'reverting' as pair valid and |z| at or below a small reversion threshold. Exit and go flat on the first bar where reverting becomes true after being false (fair-value reset). In the source this is shown as a neutral marker and is the natural exit for both long and short.
- Pair breakdown is a defensive exit/warning. It fires on the first bar where either breakdown pressure is high or correlation falls well below the minimum (a fraction of it). Breakdown pressure is a clamped 0-100 score that rises as correlation falls below the minimum, as beta drifts versus its value 20 bars earlier, and as spread kurtosis exceeds a fat-tail level.

Secondary Kalman entries (same direction semantics, event fires only on the first bar the condition turns true):
- Run a one-dimensional recursive Kalman filter on the spread. The prediction is the prior state, initialised at the first spread. Prediction variance = prior variance + process noise, where process noise is a small base plus a multiple of |spread velocity|. Measurement noise = the spread's rolling variance, floored at a tiny value. Gain = predicted variance / (predicted variance + measurement noise). New state = prediction + gain * (spread - prediction), and new variance = (1 - gain) * predicted variance.
- Kalman z = (spread - filtered state) / sqrt(filter variance).
- Kalman long: pair valid, Kalman z below the negative entry threshold, and reversion pressure above a mid-level threshold.
- Kalman short: pair valid, Kalman z above the positive entry threshold, and reversion pressure above the same threshold.
- Reversion pressure is a clamped 0-100 composite. It rises with spread velocity moving toward zero (opposite the sign of z), with |z| exceeding the entry threshold, with stationarity quality, and with positive OU speed (mean-reversion speed from the regression slope of spread changes relative to spread level).
- Stationarity quality is 100 minus penalties for beta drift, falling correlation versus 20 bars earlier, spread skew, and excess kurtosis.

Optional quality filter ('prime' dislocation): fire when a composite arbitrage grade is high, the pair is valid, and |z| is at or above the entry threshold, on the first bar it turns true. The grade is a weighted blend of pair quality (from correlation, beta distance from 1, and half-life proxy) + stationarity + reversion pressure + cointegration energy - breakdown pressure. Use it only to confirm or gate the cheap/rich entries; it does not change direction.