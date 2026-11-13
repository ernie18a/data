Calculation: RefHigh = running maximum of high since the first bar
Calculation: DD = close / RefHigh - 1 (<= 0)
Calculation: MA = simple moving average of close over a long lookback, on the chart timeframe
Calculation: Regime = Bull if close > MA; Caution if close <= MA AND close > MA*(1 - buffer); Bear otherwise (buffer is a percentage)
Calculation: RSI = RSI of close, on the chart timeframe
Calculation: Armed1, Armed2, Armed3 = flags, all true at start. On each bar, first set all three true if DD >= -rearm (rearm is smaller than the Tier 1 drawdown threshold), then evaluate the Long lines. A flag is set false on the bar its tier fires.
Long: Tier 3 = Armed3 AND DD <= -(Tier 3 drawdown threshold); no regime filter
Long: Tier 2 = Armed2 AND DD <= -(Tier 2 drawdown threshold) AND Regime is Bull or Caution
Long: Tier 1 = Armed1 AND DD <= -(Tier 1 drawdown threshold) AND Regime is Bull AND (optional filter, may be off) RSI < RSI upper limit
Note: Tier 3 drawdown threshold > Tier 2 drawdown threshold > Tier 1 drawdown threshold. All three tiers are evaluated on every bar, deepest tier first, and more than one can fire on the same bar.