Calculation: safe range = max(high − low, minimum price increment)
Calculation: upper absorption = volume > volume SMA × volume threshold AND |close − open| < (high − low) × maximum body fraction AND (high − max(open, close)) / safe range ≥ wick ratio AND close < open
Calculation: lower absorption = volume > volume SMA × volume threshold AND |close − open| < (high − low) × maximum body fraction AND (min(open, close) − low) / safe range ≥ wick ratio AND close > open
Long: previous bar lower absorption AND current low ≥ previous bar low − confirmation tolerance
Short: previous bar upper absorption AND current high ≤ previous bar high + confirmation tolerance