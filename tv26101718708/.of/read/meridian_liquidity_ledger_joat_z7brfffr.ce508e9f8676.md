Calculation: Reference price = EMA(close, reference lookback); when the adaptive anchor is enabled, subtract 0.20 × standard deviation(close, deviation lookback) × reference bias if close ≥ EMA, otherwise add that amount.
Calculation: Ledger imbalance = (rolling volume on bars where close ≥ open − rolling volume on bars where close < open) ÷ max(total rolling volume, 1), using the ledger lookback.
Calculation: Outer anchor upper = reference price + standard deviation(close, deviation lookback) × outer band multiplier.
Calculation: Outer anchor lower = reference price − standard deviation(close, deviation lookback) × outer band multiplier.
Long: bar is confirmed AND ledger imbalance > positive dominance threshold AND close ≥ reference price
Long: bar is confirmed AND close > outer anchor upper AND ledger imbalance > 0
Short: bar is confirmed AND ledger imbalance < negative dominance threshold AND close ≤ reference price
Short: bar is confirmed AND close < outer anchor lower AND ledger imbalance < 0