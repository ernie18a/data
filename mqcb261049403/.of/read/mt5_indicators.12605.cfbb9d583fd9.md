Calculation: Value = volume-weighted average of weighted close ((high+low+2*close)/4, weights = volume) over the last N bars including the current bar
Calculation: RSV = (Value - lowest Value over the last M bars including the current bar) / max(highest Value - lowest Value over the same M bars, tiny positive constant) * 100 - 50
Calculation: Fast = moving-average smoothing of RSV; Slow = the same smoothing (same method and length) applied to Fast
Long: Fast > Slow on the current bar AND Fast <= Slow on the previous bar (Fast crosses above Slow)
Short: Fast <= Slow on the current bar AND Fast > Slow on the previous bar (Fast crosses below Slow)