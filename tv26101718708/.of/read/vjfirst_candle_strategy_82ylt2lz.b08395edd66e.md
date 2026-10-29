Calculation: First bar of the day = first chart-timeframe bar whose calendar day differs from the preceding bar; use its open and close
Long: First bar of the day open > close AND current bar time is within the configured intraday session
Short: First bar of the day open < close AND current bar time is within the configured intraday session
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage) OR current bar time is outside the configured intraday session
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage) OR current bar time is outside the configured intraday session