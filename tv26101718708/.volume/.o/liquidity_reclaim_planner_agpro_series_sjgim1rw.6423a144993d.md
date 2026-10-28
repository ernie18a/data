Calculation: Confirmed swing high/low = a pivot high/low confirmed after the selected number of bars on each side.
Calculation: ATR = average true range over the selected lookback.
Calculation: Eligible liquidity level = latest confirmed swing low/high not yet swept and within the maximum age.
Long: Eligible swing low exists AND (low is at least the selected minimum ATR distance below it OR close is above it but no more than 0.80 ATR away AND close < previous close) OR an active sell-side sweep is reclaimed within the selected reclaim window with close > swept level + reclaim buffer.
Short: Eligible swing high exists AND (high is at least the selected minimum ATR distance above it OR close is below it but no more than 0.80 ATR away AND close > previous close) OR an active buy-side sweep is reclaimed within the selected reclaim window with close < swept level - reclaim buffer.
Exit: Long, close < active sell-side event low - 0.08 ATR.
Exit: Short, close > active buy-side event high + 0.08 ATR.