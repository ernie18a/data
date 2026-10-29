Calculation: Centerline = selectable EMA or SMA of close over a configurable lookback, VWAP of close, or close
Calculation: Amplitude = ATR over a configurable lookback multiplied by a configurable multiplier, or a configurable fixed amplitude multiplied by that multiplier
Calculation: Sine wave = centerline + amplitude × sin(2π × chart-bar index / configurable cycle length + configurable phase shift)
Long: Sine wave > its prior-bar value OR sine wave > centerline AND its prior-bar value ≤ centerline's prior-bar value
Short: Sine wave < its prior-bar value OR sine wave < centerline AND its prior-bar value ≥ centerline's prior-bar value