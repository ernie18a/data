Calculation: Upper boundary = highest high over the reference range lookback, excluding the current bar, plus ATR times the boundary buffer
Calculation: Lower boundary = lowest low over the reference range lookback, excluding the current bar, minus ATR times the boundary buffer
Long: Close is above the upper boundary for the required number of consecutive bars, and the prior bar did not already meet that condition
Long: A downside acceptance has failed within the failure window (close is above its accepted lower boundary)
Long: After an upside acceptance failure, close crosses above its accepted boundary
Long: An upside acceptance remains above its accepted boundary after the failure window
Long: Failure risk for a downside acceptance crosses above its threshold
Short: Close is below the lower boundary for the required number of consecutive bars, and the prior bar did not already meet that condition
Short: An upside acceptance has failed within the failure window (close is below its accepted upper boundary)
Short: After a downside acceptance failure, close crosses below its accepted boundary
Short: A downside acceptance remains below its accepted boundary after the failure window
Short: Failure risk for an upside acceptance crosses above its threshold