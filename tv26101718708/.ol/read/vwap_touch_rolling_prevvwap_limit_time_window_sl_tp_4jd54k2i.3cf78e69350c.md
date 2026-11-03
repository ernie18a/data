Long: close[1] > VWAP[1] AND position is flat AND time is within the configured entry window AND long re-entry is not blocked; place a limit entry at VWAP[1]
Short: close[1] < VWAP[1] AND position is flat AND time is within the configured entry window AND short re-entry is not blocked; place a limit entry at VWAP[1]
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance OR force-flat time reached
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance OR force-flat time reached