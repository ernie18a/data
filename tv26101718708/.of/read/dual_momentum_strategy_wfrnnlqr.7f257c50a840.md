Calculation: Risky asset momentum = percentage change from the close at the start of the lookback to the current close, using higher-timeframe bars; the current bar is still forming
Calculation: Safe asset momentum = percentage change from the close at the start of the same lookback to the current close, using higher-timeframe bars; the current bar is still forming
Long: risky asset momentum > 0 AND risky asset momentum > safe asset momentum
Long: risky asset momentum <= 0 OR risky asset momentum <= safe asset momentum
Exit: long, risky asset momentum <= 0 OR risky asset momentum <= safe asset momentum
Exit: long, risky asset momentum > 0 AND risky asset momentum > safe asset momentum