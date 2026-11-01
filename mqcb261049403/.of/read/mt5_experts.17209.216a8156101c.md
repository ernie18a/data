Calculation: Box levels = the last completed higher-timeframe bar's high plus an entry offset and low minus the same offset, recorded at each scheduled box-order placement time and retained until the next scheduled box cancellation time.
Calculation: Weekly levels = the highest high and lowest low over a lookback of lower-timeframe bars including the bar still forming at the weekly placement time, respectively increased and decreased by an entry offset; retain these levels until the weekly closing time.
Calculation: Trailing stop = initialize the stop at the strategy's initial stop price; on each chart bar where that strategy has no other signal, raise a long stop to the current price minus the strategy's trailing distance only if the increase exceeds the trailing step, or lower a short stop to the current price plus the trailing distance only if the decrease exceeds the trailing step.
Long: RSI on the second-last completed chart bar < the lower RSI threshold AND RSI on the last completed chart bar > the lower RSI threshold AND no RSI long position is open.
Short: RSI on the second-last completed chart bar > the upper RSI threshold AND RSI on the last completed chart bar < the upper RSI threshold AND no RSI short position is open.
Long: An RSI long position is open AND its position count is below the entry limit AND current price > the most recently opened RSI position's entry price + the re-entry offset.
Short: An RSI short position is open AND its position count is below the entry limit AND current price < the most recently opened RSI position's entry price - the re-entry offset.
Long: A box buy-stop order is active AND price >= the upper box level.
Short: A box sell-stop order is active AND price <= the lower box level.
Long: A weekly buy-stop order is active AND price >= the upper weekly level.
Short: A weekly sell-stop order is active AND price <= the lower weekly level.
Long: The current hour equals the gap-entry hour AND no gap position is open AND the open of the higher-timeframe bar still forming < the low of the last completed higher-timeframe bar.
Short: The current hour equals the gap-entry hour AND no gap position is open AND the open of the higher-timeframe bar still forming > the high of the last completed higher-timeframe bar.
Exit: long, the current hour equals a scheduled box cancellation hour AND the position is a box position.
Exit: short, the current hour equals a scheduled box cancellation hour AND the position is a box position.
Exit: long, the current weekday equals the weekly closing day AND the current hour > the weekly closing hour AND the position is a weekly position.
Exit: short, the current weekday equals the weekly closing day AND the current hour > the weekly closing hour AND the position is a weekly position.
Exit: long, price <= the trailing stop; initialize the RSI and gap stops at entry price minus their respective stop distances, and box and weekly stops at the corresponding lower level.
Exit: short, price >= the trailing stop; initialize the RSI and gap stops at entry price plus their respective stop distances, and box and weekly stops at the corresponding upper level.