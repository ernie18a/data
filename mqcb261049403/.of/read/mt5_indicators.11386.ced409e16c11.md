Calculation: Bull component = (high − low − |close − open|) / (2 × (high − low) / volume) + (open − close) / ((high − low) / volume) when open > close; otherwise (high − low − |close − open|) / (2 × (high − low) / volume)
Calculation: Bear component = (high − low − |close − open|) / (2 × (high − low) / volume) + (close − open) / ((high − low) / volume) when close > open; otherwise (high − low − |close − open|) / (2 × (high − low) / volume)
Calculation: Smoothed bull and bear components = apply the same configured moving-average method and lookback to each component; source bars are chart-timeframe bars or selected higher-timeframe bars, using the bar still forming
Long: smoothed bull component > smoothed bear component
Short: smoothed bear component > smoothed bull component