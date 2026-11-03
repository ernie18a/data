Long: (Strategy 1 selected AND fast SMA crosses above slow SMA) OR (Strategy 2 selected AND fast SMA crosses above slow SMA AND close > slow SMA of the higher timeframe, calculated using its still-forming bar)
Calculation: Strategy 1 percentage target = close × (1 + take-profit percentage)
Calculation: Strategy 1 pip target = close + pip distance × minimum tick size
Calculation: Strategy 1 trailing stop = current bar high − pip distance × minimum tick size
Calculation: Strategy 2 take-profit level = close × (1 + take-profit percentage / 100)
Calculation: Strategy 2 stop-loss level = close − ATR × stop-loss multiplier
Exit: long, Strategy 1 selected AND trailing enabled AND low ≤ trailing stop
Exit: long, Strategy 1 selected AND trailing disabled AND high ≥ (percentage target or pip target, as selected)
Exit: long, Strategy 2 selected AND high ≥ Strategy 2 take-profit level
Exit: long, Strategy 2 selected AND low ≤ Strategy 2 stop-loss level