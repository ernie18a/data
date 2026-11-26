Calculation: tick-value multiplier = tick value when fair-lot sizing is off, otherwise one
Calculation: group profit threshold = sum of (position lot × profit target × tick-value multiplier) less spread and commission
Calculation: pair profit threshold = pair lot × profit target × tick-value multiplier less spread and commission
Calculation: group loss threshold = negative sum of (average lot per order × loss target × tick-value multiplier) less spread and commission
Calculation: step progression multiplier = current group count for static progression, sum of group indices from zero through the current count for geometric progression, or sum of max(one, two to the power of index minus one) over those indices for exponential progression
Calculation: next-entry loss threshold = negative sum of (position lot × loss step × step progression multiplier × tick-value multiplier) less spread and commission
Long: long entries are enabled AND no long-entry basket is open
Short: short entries are enabled AND no short-entry basket is open
Long: a long-entry basket is open AND its open-order count is at least the basket size AND its net open profit is at or below the next-entry loss threshold AND the entry interval has elapsed since its last opening
Short: a short-entry basket is open AND its open-order count is at least the basket size AND its net open profit is at or below the next-entry loss threshold AND the entry interval has elapsed since its last opening
Exit: long, long-entry basket net open profit is at or above its group profit threshold
Exit: short, short-entry basket net open profit is at or above its group profit threshold
Exit: long, long-entry basket net open profit is below zero AND at or below its group loss threshold
Exit: short, short-entry basket net open profit is below zero AND at or below its group loss threshold
Exit: long, long-entry basket net open profit is below zero AND its order count exceeds the short-entry basket order count AND its net open profit is at or below its group loss threshold
Exit: short, short-entry basket net open profit is below zero AND its order count exceeds the long-entry basket order count AND its net open profit is at or below its group loss threshold
Exit: long, per-pair net open profit is at or above its pair profit threshold
Exit: short, per-pair net open profit is at or above its pair profit threshold
Exit: long, combined long- and short-entry basket net open profit is positive and at or above the greater of their group profit thresholds
Exit: short, combined long- and short-entry basket net open profit is positive and at or above the greater of their group profit thresholds
Exit: long, long-entry basket net open profit is positive AND its order count is no greater than the short-entry basket order count AND short-entry basket net open profit is at or below its next-entry loss threshold
Exit: short, short-entry basket net open profit is positive AND its order count is no greater than the long-entry basket order count AND long-entry basket net open profit is at or below its next-entry loss threshold