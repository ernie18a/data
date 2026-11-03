Calculation: Entry indicator = selected moving-average type applied to close over its lookback
Calculation: Baseline = selected moving-average type applied to close over its lookback
Calculation: Confirmation indicator = selected moving-average type applied to close over its lookback
Calculation: ATR stop fraction = ATR × multiplier / (close + ATR × multiplier)
Calculation: Long stop = maximum of entry price × (1 − ATR stop fraction at entry) and the prior long stop and the smoothed low × (1 − current ATR stop fraction)
Calculation: Short stop = minimum of entry price × (1 + ATR stop fraction at entry) and the prior short stop and the smoothed high × (1 + current ATR stop fraction)
Long: Entry indicator > its previous-bar value AND its previous-bar value ≤ its value two bars ago AND position is flat AND baseline > its previous-bar value AND (confirmation filter disabled OR confirmation indicator > its previous-bar value)
Short: Entry indicator < its previous-bar value AND its previous-bar value ≥ its value two bars ago AND position is flat AND baseline < its previous-bar value AND (confirmation filter disabled OR confirmation indicator < its previous-bar value)
Exit: Long, entry indicator < its previous-bar value AND its previous-bar value ≥ its value two bars ago OR low ≤ long stop
Exit: Short, entry indicator > its previous-bar value AND its previous-bar value ≤ its value two bars ago OR high ≥ short stop