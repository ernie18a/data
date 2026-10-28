Calculation: Volume pivot high = volume is greater than the volume of the L bars before and the L bars after the pivot bar; detected L bars after the pivot bar, and must be nonzero.
Calculation: Swing state = 0 if the high L bars before the current bar is greater than the highest high of the current L bars; otherwise 1 if the low L bars before the current bar is less than the lowest low of the current L bars; otherwise retain the prior state (initially 0).
Long: A nonzero volume pivot high is detected AND swing state = 1.
Short: A nonzero volume pivot high is detected AND swing state = 0.