Calculation: Body fraction = abs(close - open) / (high - low), or zero when high equals low.
Calculation: Bull impulse = body fraction of each of the two preceding bars >= the same body-fraction threshold AND volume of the immediately preceding bar > volume of the bar before it AND ((both bars close above their opens) OR (the two bars do not both close above their opens AND the immediately preceding close > the earlier high)).
Calculation: Bear impulse = body fraction of each of the two preceding bars >= the same body-fraction threshold AND volume of the immediately preceding bar > volume of the bar before it AND ((both bars close below their opens) OR (the two bars do not both close below their opens AND the immediately preceding close < the earlier low)).
Calculation: Bull retrace bounds = immediately preceding high minus its range multiplied by the larger and smaller retracement fractions, respectively.
Calculation: Bear retrace bounds = immediately preceding low plus its range multiplied by the smaller and larger retracement fractions, respectively; use the same two fractions as for the bull retrace bounds.
Calculation: Bull entry signal = bull impulse AND current low >= lower bull retrace bound AND current low <= upper bull retrace bound AND (VWAP filter disabled OR current close > session VWAP of typical price).
Calculation: Bear entry signal = bear impulse AND current high >= lower bear retrace bound AND current high <= upper bear retrace bound AND (VWAP filter disabled OR current close < session VWAP of typical price).
Long: bull impulse = true
Short: bear impulse = true AND bull impulse = false
Long: bull entry signal = true
Short: bear entry signal = true
Exit: long, current low <= the low of the bar preceding the most recent bull entry signal minus the stop offset
Exit: short, current high >= the high of the bar preceding the most recent bear entry signal plus the stop offset
Exit: long, bear entry signal = true
Exit: short, bull entry signal = true