Calculation: Reference high = running maximum of high when all-time-high mode is selected; otherwise Highest(high, reference-high lookback) on chart bars, including the current bar
Calculation: Drawdown = close / reference high - 1
Calculation: Trend regime = Bull when the trend gate is disabled, the SMA is unavailable, or close > SMA(close, trend lookback); otherwise Caution when close > SMA(close, trend lookback) × (1 - bear buffer / 100); otherwise Bear
Calculation: Regime multiplier = Bull multiplier, Caution multiplier, or Bear multiplier according to the trend regime
Calculation: Each tier starts armed, becomes disarmed when it fires, and rearms when drawdown >= -rearm threshold / 100
Calculation: Reserve balance starts at zero, compounds each chart bar by (1 + cash APY / 100)^(1 / annualization bar count), receives monthly contribution × (1 - core allocation) at each TF1 boundary, and at that boundary invests any amount above reserve contribution × reserve-cap periods; subtract each tier deployment in Tier 3, Tier 2, Tier 1 order, where deployment = current reserve balance × that tier's deployment percentage / 100 × regime multiplier
Long: First chart bar of each TF1 period AND close > 0
Long: First chart bar of each TF1 period AND close > 0 AND reserve balance after adding the reserve contribution exceeds the reserve cap
Long: Tier 3 is armed AND drawdown <= -Tier 3 trigger / 100 AND reserve balance > minimum reserve balance AND close > 0
Long: Tier 2 is armed AND drawdown <= -Tier 2 trigger / 100 AND reserve balance after any Tier 3 deployment on this bar > minimum reserve balance AND (trend regime is Bull OR trend regime is Caution) AND close > 0
Long: Tier 1 is armed AND drawdown <= -Tier 1 trigger / 100 AND reserve balance after any Tier 3 and Tier 2 deployments on this bar > minimum reserve balance AND trend regime is Bull AND (RSI confirmation is disabled OR RSI(close, RSI lookback) < RSI threshold) AND close > 0