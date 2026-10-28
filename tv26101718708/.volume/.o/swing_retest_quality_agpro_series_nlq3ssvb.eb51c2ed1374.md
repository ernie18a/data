Calculation: Active swing = the most recent confirmed pivot high and pivot low, ordered by which occurred last; bull if the high came later, bear if the low came later; require a nonzero leg above a volatility-scaled minimum and a terminal pivot within the maximum swing age
Calculation: Retest pocket = band inside the active leg, bounded by configurable shallow and deep retracement depths measured from the terminal pivot toward the origin; pocket touch = current bar range overlaps the band
Calculation: Defense line = beyond the swing origin by a configurable ATR buffer, below for a bull swing and above for a bear swing
Calculation: Retest quality = 0–100 weighted score of swing clarity (leg size and duration), retest depth (best near an ideal depth within the pocket), directional wick rejection, close response relative to the pocket midpoint and range, and optionally relative volume; apply sensitivity adjustment and clamp to 0–100
Calculation: Recent pocket touch = a pocket touch occurred within the configurable response window
Calculation: Valid retest = active swing AND recent pocket touch AND close on the defended side of the pocket midpoint AND close has not crossed the defense line AND target room toward the swing terminal/extension is at least the configured ATR minimum AND retest quality meets the valid threshold
Calculation: Watch retest = active swing AND recent pocket touch AND close has not crossed the defense line AND NOT valid retest AND retest quality meets the watch threshold
Calculation: Directional label event = first bar of a pocket touch, valid retest, or watch retest state; require quality at least the label-score threshold for these labels
Long: active bull swing AND directional label event
Short: active bear swing AND directional label event
Exit: long, close < defense line
Exit: short, close > defense line