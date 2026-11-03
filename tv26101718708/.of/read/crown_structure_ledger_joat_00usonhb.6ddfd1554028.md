Calculation: Pivot rails = For each of three horizons, retain the latest confirmed pivot high and pivot low, using equal left and right pivot lengths; the intermediate length is longer than the short length, and the primary length is longer than the intermediate length. Update a rail on the bar that confirms its pivot.
Calculation: Corridor width = ATR multiplied by a corridor multiplier. If adaptive depth is enabled, also multiply by the greater of a positive floor and an EMA of ATR divided by the greater of its same-length SMA and a small positive price floor.
Calculation: Break state = For each horizon, start neutral. On each completed bar, set the state bullish if close is above its pivot-high rail plus corridor width multiplied by that horizon's break multiplier; then set it bearish if close is below its pivot-low rail minus corridor width multiplied by that horizon's break multiplier. Retain the previous state otherwise. The break multiplier increases from short to intermediate to primary.
Calculation: Pressure = The sum of volume on bars with close greater than or equal to open minus the sum of volume on bars with close below open, divided by the greater of their combined volume and a positive volume floor.
Calculation: Selected high and low = Independently select the latest available primary pivot rail if that horizon is enabled; otherwise select the latest available intermediate rail if enabled; otherwise select the short rail.
Calculation: Bias = A positive trend weight if the short EMA of close is above the long EMA, otherwise its negative, plus weighted pressure, plus weighted location, plus weighted slope. Location is close minus the midpoint of the selected high and low, divided by the greater of their difference and a small positive price floor; use zero if either rail is unavailable. Slope is the difference between the current and previous fitted values of a linear regression of the short EMA, divided by the greater of ATR and a small positive price floor.
Long: Close is above a horizon's pivot-high rail plus its corridor-width break allowance AND that horizon's state before processing the bullish break is not bullish.
Short: Close is below a horizon's pivot-low rail minus its corridor-width break allowance AND that horizon's state after processing the bullish break is not bearish.
Long: Any horizon's break state is bullish.
Short: Any horizon's break state is bearish.
Long: Bias is greater than or equal to zero.
Short: Bias is below zero.
Long: Pressure is greater than or equal to zero.
Short: Pressure is below zero.
Long: Short EMA of close is above long EMA of close.
Short: Short EMA of close is below long EMA of close.