Calculation: Initial Balance high = highest high during the configured Initial Balance window; lock after the window closes
Calculation: Initial Balance low = lowest low during the configured Initial Balance window; lock after the window closes
Calculation: Initial Balance range = Initial Balance high - Initial Balance low
Calculation: Initial Balance midpoint = (Initial Balance high + Initial Balance low) / 2
Calculation: Long target = Initial Balance high + configured extension multiple × Initial Balance range
Calculation: Short target = Initial Balance low - configured extension multiple × Initial Balance range
Long: close > Initial Balance high AND previous close <= Initial Balance high AND close > VWAP when the VWAP filter is enabled AND Initial Balance range is within configured minimum and maximum AND time is within the configured trade window AND no long entry has been taken that day AND position is flat
Short: close < Initial Balance low AND previous close >= Initial Balance low AND close < VWAP when the VWAP filter is enabled AND Initial Balance range is within configured minimum and maximum AND time is within the configured trade window AND no short entry has been taken that day AND position is flat
Exit: long, low <= configured stop level (Initial Balance low or midpoint) OR high >= Long target OR time is within the configured end-of-day closing window
Exit: short, high >= configured stop level (Initial Balance high or midpoint) OR low <= Short target OR time is within the configured end-of-day closing window