Calculation: SwingState = 0 if the high of the bar L bars ago is greater than the highest high of the latest L bars (including the current bar); else 1 if the low of the bar L bars ago is lower than the lowest low of the latest L bars (including the current bar); else the previous SwingState (initially 0)
Calculation: VolPivot = the volume of the bar L bars ago is the highest volume among the L bars before it and the L bars after it (same L as SwingState)
Calculation: BullOB = zone created when VolPivot AND SwingState=1, spanning from the low of the bar L bars ago up to the midpoint of its high and low; it stays active until mitigated
Calculation: BearOB = zone created when VolPivot AND SwingState=0, spanning from the midpoint of the high and low of the bar L bars ago up to its high; it stays active until mitigated
Calculation: BullMitigated = on the current bar, the lowest low (or alternatively the lowest close) of the latest L bars (including the current bar) is below the bottom of any active BullOB; that BullOB is then removed
Calculation: BearMitigated = on the current bar, the highest high (or alternatively the highest close) of the latest L bars (including the current bar) is above the top of any active BearOB; that BearOB is then removed
Calculation: LastSwingHigh = the price of the most recent pivot high of the high (highest among N bars on each side, confirmed N bars later; N is independent of L); it is cleared once broken by a close above it
Calculation: LastSwingLow = the price of the most recent pivot low of the low (lowest among N bars on each side, confirmed N bars later); it is cleared once broken by a close below it
Long: a BullOB is created on the current bar (VolPivot AND SwingState=1)
Long: close crosses above LastSwingHigh (previous close <= LastSwingHigh AND close > LastSwingHigh); this is a BOS if the previous structure break was upward, otherwise a CHoCH
Long: BullMitigated AND close > open AND close > low + 0.5*(high-low)
Short: a BearOB is created on the current bar (VolPivot AND SwingState=0)
Short: close crosses below LastSwingLow (previous close >= LastSwingLow AND close < LastSwingLow); this is a BOS if the previous structure break was downward, otherwise a CHoCH
Short: BearMitigated AND close < open AND close < high - 0.5*(high-low)