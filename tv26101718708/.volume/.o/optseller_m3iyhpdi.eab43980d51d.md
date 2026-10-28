Calculation: Center = configured VWAP or 20-period EMA of close
Calculation: CE sell level = round upward to the configured strike increment of Center + ATR × configured multiplier
Calculation: PE sell level = round downward to the configured strike increment of Center − ATR × configured multiplier
Short: high ≥ CE sell level AND within the configured entry session AND trades entered today < configured daily limit AND RSI > configured oversold threshold AND no open CE short
Long: low ≤ PE sell level AND within the configured entry session AND trades entered today < configured daily limit AND RSI < configured overbought threshold AND no open PE long
Exit: short (CE), high ≥ current CE sell level × (1 + configured stop percentage) OR low ≤ current CE sell level × (1 − configured target percentage) OR within the configured end-of-day exit window
Exit: long (PE), low ≤ current PE sell level × (1 − configured stop percentage) OR high ≥ current PE sell level × (1 + configured target percentage) OR within the configured end-of-day exit window