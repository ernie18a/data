Calculation: Confirmed volume pivot high = volume is higher than the volume of the preceding and following N bars; confirmed after the following N bars.
Calculation: Swing state = 0 if the high N bars ago is greater than the highest high of the last N bars; otherwise 1 if the low N bars ago is less than the lowest low of the last N bars; otherwise the prior bar’s swing state.
Long: Confirmed volume pivot high AND swing state = 1
Short: Confirmed volume pivot high AND swing state = 0