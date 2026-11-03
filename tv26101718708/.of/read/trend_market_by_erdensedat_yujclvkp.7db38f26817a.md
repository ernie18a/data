Calculation: Structure levels = the most recently confirmed pivot high and pivot low, each confirmed with equal numbers of bars on either side; a new pivot replaces the corresponding level and resets its broken flag.
Calculation: Structure direction = initially neutral; set to up after an upward structure break and down after a downward structure break. If both occur on one bar, process the upward break first.
Calculation: Structure break = the first bar after a structure level is set on which close is strictly beyond that level; alternatively use high for upward breaks and low for downward breaks. Evaluate newly confirmed levels on the confirmation bar.
Calculation: Re-entry pivot = a pivot confirmed with equal numbers of bars on either side, using a separate lookback from the structure pivot; evaluate the signal on the confirmation bar.
Calculation: Profit targets = on each structure break with both structure levels available, reset the target direction to the break direction, the target origin to the broken level, and the distance to the high structure level minus the low structure level. Target n is origin plus direction times distance times its multiplier; odd-numbered target multipliers are (n - 1) / 2 + 0.618 and even-numbered multipliers are n / 2. Start with the first target and advance through consecutive targets reached by the current bar, including on the break bar.
Long: Upward structure break.
Long: Confirmed re-entry pivot low AND structure direction is up after processing current-bar structure breaks.
Long: Low > high two bars ago AND previous close > previous open.
Short: Downward structure break.
Short: Confirmed re-entry pivot high AND structure direction is down after processing current-bar structure breaks.
Short: High < low two bars ago AND previous close < previous open.
Exit: Long, profit target direction is up AND high >= next profit target.
Exit: Short, profit target direction is down AND low <= next profit target.