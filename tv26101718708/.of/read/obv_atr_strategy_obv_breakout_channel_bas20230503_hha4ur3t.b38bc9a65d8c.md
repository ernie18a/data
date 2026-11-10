Calculation: Breakout mode = initially 0; set to 1 when OBV crosses above the previous bar's rolling maximum OBV, set to -1 when OBV crosses below the previous bar's rolling minimum OBV, and otherwise retain the previous mode. Both rolling extrema use the same lookback and include their current bar.
Long: Breakout mode = 1 AND previous breakout mode != 1
Short: Breakout mode = -1 AND previous breakout mode != -1
Exit: long, breakout mode = -1 AND previous breakout mode != -1
Exit: short, breakout mode = 1 AND previous breakout mode != 1