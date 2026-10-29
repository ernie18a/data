Calculation: BullsBearsEyes output = indicator output on the chart timeframe, using the bar still forming
Calculation: trailing distance = one price point + 1.5 × ATR with a shorter lookback, on the chart timeframe using the last completed bar
Long: BullsBearsEyes output > threshold AND no position is open
Short: BullsBearsEyes output < threshold AND no position is open
Exit: long, low ≤ entry price − configured stop-loss distance OR high ≥ entry price + configured take-profit distance OR low ≤ the active trailing stop
Exit: short, high ≥ entry price + configured stop-loss distance OR low ≤ entry price − configured take-profit distance OR high ≥ the active trailing stop