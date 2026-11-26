Calculation: Tape side = latest nonzero sign of close - close[1] on successive T1 bars, carrying forward when close is unchanged.
Calculation: Tape size = volume or hlc3 * volume, according to the selected size type.
Long: Tape side > 0 OR sum of Tape size for the N most recent positive-size T1 rows with Tape side > 0 >= sum of Tape size for those rows with Tape side < 0.
Short: Tape side < 0 OR sum of Tape size for the N most recent positive-size T1 rows with Tape side < 0 > sum of Tape size for those rows with Tape side > 0.