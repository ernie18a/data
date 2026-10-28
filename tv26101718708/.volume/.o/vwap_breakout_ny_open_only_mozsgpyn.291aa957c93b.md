Calculation: Weekly anchored VWAP = cumulative volume-weighted average of hlc3 from the start of the current week, including the forming week
Long: close crosses above session VWAP AND close < weekly anchored VWAP AND time is within 09:30–11:30 America/New_York
Short: close crosses below session VWAP AND close > weekly anchored VWAP AND time is within 09:30–11:30 America/New_York
Exit: long, low <= entry-bar session VWAP − stop-distance parameter OR high >= entry-bar weekly anchored VWAP
Exit: short, high >= entry-bar session VWAP + stop-distance parameter OR low <= entry-bar weekly anchored VWAP