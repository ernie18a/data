Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, reset at the session boundary
Calculation: Stop distance = either a fixed price amount or ATR × a configurable multiplier
Calculation: Target distance = either a fixed price amount or ATR × a configurable multiplier
Long: datetime is within the configured Asia session AND low >= session VWAP - pullback band AND low <= session VWAP + pullback band AND close > session VWAP
Short: datetime is within the configured Asia session AND high >= session VWAP - pullback band AND high <= session VWAP + pullback band AND close < session VWAP
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance OR current bar is outside the configured Asia session AND previous bar was inside it
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance OR current bar is outside the configured Asia session AND previous bar was inside it