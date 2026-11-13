Instrument traded: S&P 500 e-mini futures (ES). Evaluate on every bar of the chart timeframe, using each series' close. Outside inputs: NQ futures, RTY futures, HYG, IEF, and the 10-year yield index.

Build three relative-strength ratios: NQ/ES (leadership), RTY/ES (breadth), HYG/IEF (credit vs duration). For each ratio, and for ES itself, compute percent rate of change over a short fixed lookback. Compute the same rate of change for the 10-year yield, with its own lookback.

Define the flags:
- ES up: ES rate of change is above a positive equity threshold T. ES down: it is below -T.
- Confirm-up count: how many of the three ratios have rate of change above zero. Confirm-down count: how many are below zero.
- Yield rising: yield rate of change is above a positive yield threshold. Yield falling: it is below the negative of that threshold.
- Risk-on: ES up and confirm-up count is at least 2.
- Risk-off: ES down and confirm-down count is at least 2.
- Hollow rally: ES up and confirm-up count is below 2.
- Credit warning: HYG/IEF rate of change is below -2*T. This does not depend on ES direction.
- Liquidation: ES down and yield rising.

Classify one regime per bar by strict priority, first match wins: Liquidation, Credit warning, Risk-off, Hollow rally, Risk-on (split into durable if yield rising, fragile if yield falling, plain otherwise), else Neutral.

Trading bias for ES, acting on the regime:
- Liquidation, Credit warning, Risk-off: bearish. Go short, or exit longs and stay out of longs. Liquidation is the most severe, then Credit warning, then Risk-off. Credit warning means credit is leading equities lower, so expect ES to follow down.
- Hollow rally: ES is rising without confirmation from the internals. Fade the strength by going short or exiting longs. This is mildly bearish.
- Risk-on: bullish. Go long. Durable (yield rising) has the highest conviction, plain is medium, and fragile (yield falling) has the lowest.
- Neutral: no position. Exit or stay flat.

Act when the regime changes from the prior bar. Exit the current position when the regime leaves the state that justified it. The opposite regime flips the position.