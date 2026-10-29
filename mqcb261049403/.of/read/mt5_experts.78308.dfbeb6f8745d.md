Calculation: Confirmed swing high = the most recent high strictly greater than the highs of the specified older and newer neighboring completed bars; use bars from the fixed structure timeframe, with newer confirmation bars completed.
Calculation: Confirmed swing low = the most recent low strictly lower than the lows of the specified older and newer neighboring completed bars; use bars from the fixed structure timeframe, with newer confirmation bars completed.
Calculation: Buy stop-entry level = confirmed swing high + swing high × buy offset percentage.
Calculation: Sell stop-entry level = confirmed swing low − swing low × sell offset percentage.
Long: Ask < confirmed swing high − minimum clearance AND buy stop-entry level > Ask + broker minimum stop distance; enter when price reaches the buy stop-entry level.
Short: Bid > confirmed swing low + minimum clearance AND sell stop-entry level < Bid − broker minimum stop distance; enter when price reaches the sell stop-entry level.
Exit: long, price ≤ active stop loss OR price ≥ active take profit.
Exit: short, price ≥ active stop loss OR price ≤ active take profit.