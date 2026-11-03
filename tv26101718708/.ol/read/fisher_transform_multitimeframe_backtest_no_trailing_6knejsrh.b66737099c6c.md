Calculation: Trend state = On the selected interval’s boundary, set to +1 when the selected-interval smoothed Fisher value is above its prior value and the change in its value rounded to 4 decimal places is nonnegative; set to −1 when it is below its prior value and the rounded change is nonpositive; otherwise retain the prior state. Retain the state between boundaries. Use the current still-forming selected-interval bar; the selected interval is higher than the chart interval, or equal when configured to use the chart interval.
Calculation: Trend-state change = current trend state − prior trend state.
Long: Trend state > 0 OR trend-state change > 0
Short: Trend state < 0 OR trend-state change < 0
Exit: Long, trend-state change < 0
Exit: Short, trend-state change > 0