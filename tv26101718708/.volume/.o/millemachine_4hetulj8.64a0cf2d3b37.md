Calculation: Entry indicator = configured indicator applied to its configured source
Calculation: Baseline = configured indicator applied to its configured source
Calculation: ATR stop fraction = ATR-based distance multiplier × ATR / (close + ATR × distance multiplier)
Calculation: Long trailing stop = maximum of prior stop and smoothed low × (1 − ATR stop fraction)
Calculation: Short trailing stop = minimum of prior stop and smoothed high × (1 + ATR stop fraction)
Long: Position is flat AND Entry indicator > its prior value AND its prior value ≤ its value two bars ago AND Baseline > its prior value
Short: Position is flat AND Entry indicator < its prior value AND its prior value ≥ its value two bars ago AND Baseline < its prior value
Exit: Long, Entry indicator < its prior value AND its prior value ≥ its value two bars ago OR low ≤ long stop
Exit: Short, Entry indicator > its prior value AND its prior value ≤ its value two bars ago OR high ≥ short stop