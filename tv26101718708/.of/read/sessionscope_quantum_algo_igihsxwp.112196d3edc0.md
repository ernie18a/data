Calculation: Session high and low = highest high and lowest low of chart bars within a configurable session window in a configurable timezone; freeze them when the session ends and retain them until the same session next opens.
Calculation: Session upward bias = fraction of completed instances of a session whose last close is greater than or equal to their first open.
Long: Session upward bias >= threshold.
Short: Session upward bias < threshold.
Long: After a completed session and before its next opening, the low first falls below its frozen session low AND the close first rises above that low on the sweep bar or within the reversal window.
Short: After a completed session and before its next opening, the high first rises above its frozen session high AND the close first falls below that high on the sweep bar or within the reversal window.
Long: After a completed session, the high first rises above its frozen session high AND no close falls below that high through the reversal window or before the session next opens, whichever occurs first.
Short: After a completed session, the low first falls below its frozen session low AND no close rises above that low through the reversal window or before the session next opens, whichever occurs first.