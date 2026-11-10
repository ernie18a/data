Calculation: Rolling profile = On each completed chart bar, take the available bars up to a lookback, find their highest high and lowest low, and divide that range into equal-width bins. Assign each bar's volume to the bin containing its high-low midpoint, clamping the bin index to the valid range. The point of control is the center of the bin with the greatest accumulated volume; choose the lowest bin on ties. Starting at that bin, expand the value area one adjacent bin at a time toward the side with greater volume, choosing the upper side on ties, until its cumulative volume reaches the specified fraction of total volume. The value area high is the upper edge of the highest included bin; the value area low is the lower edge of the lowest included bin. Use a small positive floor for the range and bin width.
Calculation: Pressure oscillator = EMA of 100 times (close minus the rolling lowest low) divided by the floored rolling high-low range, clamped to 0–100 before smoothing. Use the same lookback as the rolling profile.
Calculation: Scaled profile level = 100 times (profile price level minus the rolling lowest low) divided by the floored rolling high-low range, clamped to 0–100. Apply this separately to the point of control, value area high, and value area low.
Calculation: Pressure slope = EMA of the pressure oscillator minus the scaled point of control.
Calculation: Pressure basis = EMA of the pressure oscillator, using a longer smoothing length than the pressure slope.
Long: Pressure oscillator > scaled point of control.
Short: Pressure oscillator <= scaled point of control.
Long: Pressure slope >= 0.
Short: Pressure slope < 0.
Long: Pressure oscillator >= pressure basis.
Short: Pressure oscillator < pressure basis.
Long: Pressure oscillator < oversold threshold.
Short: Pressure oscillator > overbought threshold.
Long: Pressure oscillator < scaled value area low.
Short: Pressure oscillator > scaled value area high.
Long: Pressure oscillator > scaled value area high.
Short: Pressure oscillator < scaled value area low.
Long: Pressure oscillator > scaled point of control for the required number of consecutive completed bars AND the preceding bar's consecutive count was below that number.
Short: Pressure oscillator < scaled point of control for the required number of consecutive completed bars AND the preceding bar's consecutive count was below that number.
Long: Previous pressure oscillator <= previous scaled point of control plus the point-of-control break filter AND current pressure oscillator > current scaled point of control plus that filter.
Short: Previous pressure oscillator >= previous scaled point of control minus the point-of-control break filter AND current pressure oscillator < current scaled point of control minus that filter.
Long: Previous pressure oscillator <= previous scaled value area high plus the value-area break filter AND current pressure oscillator > current scaled value area high plus that filter.
Short: Previous pressure oscillator >= previous scaled value area low minus the value-area break filter AND current pressure oscillator < current scaled value area low minus that filter.