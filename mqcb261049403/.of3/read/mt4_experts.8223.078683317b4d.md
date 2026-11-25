Calculation: R = round(mean(high - low, lookback, T1, last completed bars, sampled on chart bars) × range scale, rounding precision)
Calculation: P = max(minimum profit distance, round(R / profit ratio, rounding precision))
Calculation: D = R - P - slippage distance
Long: high >= active buy-stop level, initialized at close + D while flat, trailed to close + D when the level is more than D + trailing step above close, and set to a prior long entry price for pendulum entries
Short: low <= active sell-stop level, initialized at close - D while flat, trailed to close - D when the level is more than D + trailing step below close, and set to a prior short entry price for pendulum entries
Exit: long, high > entry price + P + slippage distance
Exit: short, low < entry price - P - slippage distance