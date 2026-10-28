Calculation: VWAP = current-session volume-weighted average of (high + low) / 2
Calculation: Volume-weighted standard deviation = sqrt(max(current-session volume-weighted average of ((high + low) / 2)² minus VWAP², 0))
Calculation: Lower VWAP band = VWAP minus the lower-band multiplier times the volume-weighted standard deviation
Long: close < lower VWAP band AND previous close >= current lower VWAP band
Exit: Long, close - entry price >= profit target