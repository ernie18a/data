Long-only daily-timeframe scanner over a fixed watchlist of large-cap stocks. All data is sampled without lookahead, so only completed daily bars are used. Each watchlist stock is evaluated independently, and a long entry signal is produced for it when a market-regime gate passes and the stock's own score reaches a minimum.

1) Market regime gate, using data outside the traded stock. The gate passes only if both sub-conditions hold, and each can be switched off by an option (a disabled sub-condition counts as passing).
- Bull-market condition: the daily close of the QQQ index ETF is above its own 200-day simple moving average. If either value is unavailable, the condition fails.
- Volatility condition: the daily close of the VIX index is below a configurable threshold. If VIX is unavailable, the condition fails.
If the gate fails, no stock produces a signal.

2) Per-stock score, computed on the stock's own daily bars as the sum of five binary tests, each worth 1 point.
- Trend: close > 50-day SMA, the 50-day SMA > 150-day SMA, and the 150-day SMA > 200-day SMA (a strict stacked uptrend).
- Momentum: 14-period RSI of close lies within a configurable inclusive band (a lower and an upper bound).
- Volume surge: the 5-day SMA of volume divided by the 20-day SMA of volume is at least a configurable multiplier, and the 20-day average volume is positive.
- Volatility range: ATR(14) as a percentage of close lies within a configurable inclusive min-to-max band.
- Proximity to high: let the 52-week high be the highest high of the last 252 daily bars, and let the distance be (close / 52-week high - 1) * 100. The test passes if the stock is at most a configurable percentage below the high and at least 1% below it (that is, near the high but not at or above it).

3) Entry rule. Go long on a stock when the regime gate passes, the score is available, and the score is at least a configurable minimum (out of 5). The signal is evaluated on confirmed (closed) bars.

4) Exit levels set at signal time, using the stock's own ATR(14) and close as entry price.
- Stop-loss = entry price minus a configurable multiple of ATR.
- Profit target = entry price plus a larger configurable multiple of ATR.
- Risk/reward = (target - entry) / (entry - stop).
These levels are only defined when price and ATR are positive. The exit is a stop-loss or a profit target hit. There is no short logic and no other exit condition.

5) Position-sizing advisory, which does not change entries. If several qualifying signals occur at once among the tech-like stocks (all watchlist names except the one non-pure-tech name, PLTR), a correlation warning is raised, advising that they be sized as a single combined position. The warning triggers when three or more of them qualify at the same time.