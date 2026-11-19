Calculation: Session VWAP = sum(source × volume) / sum(volume) over chart bars from session start through the current in-session bar, including the forming bar
Calculation: Session volume-weighted standard deviation = sqrt(max(sum(source² × volume) / sum(volume) − Session VWAP², 0)) over chart bars from session start through the current in-session bar, including the forming bar
Calculation: Long stop = tick-rounded(Session VWAP − stop-distance multiplier × Session volume-weighted standard deviation), fixed when the long entry order is submitted
Calculation: Short stop = tick-rounded(Session VWAP + stop-distance multiplier × Session volume-weighted standard deviation), fixed when the short entry order is submitted
Calculation: Long target = tick-rounded(Session VWAP − proximity tolerance), updated on each calculation
Calculation: Short target = tick-rounded(Session VWAP + proximity tolerance), updated on each calculation
Calculation: Cutoff reached = evaluation time ≥ session cutoff OR (chart bar confirmed AND chart-bar close datetime ≥ session cutoff)
Calculation: Entry window open = chart-bar datetime ≥ session start AND chart-bar datetime < session cutoff AND evaluation time ≥ entry-start time AND NOT cutoff reached
Calculation: Post-stop cooldown active = a stop-loss exit occurred this session AND evaluation time < stop-loss exit time + cooldown duration
Long: longs allowed AND position side = flat AND Entry window open AND NOT Post-stop cooldown active AND Long stop < tick-rounded(Session VWAP − outer-band multiplier × Session volume-weighted standard deviation + proximity tolerance) AND tick-rounded(Session VWAP − outer-band multiplier × Session volume-weighted standard deviation + proximity tolerance) < Long target
Short: shorts allowed AND position side = flat AND Entry window open AND NOT Post-stop cooldown active AND Short target < tick-rounded(Session VWAP + outer-band multiplier × Session volume-weighted standard deviation − proximity tolerance) AND tick-rounded(Session VWAP + outer-band multiplier × Session volume-weighted standard deviation − proximity tolerance) < Short stop
Exit: Long, low ≤ Long stop OR high ≥ Long target OR Cutoff reached OR position entry datetime < current session start
Exit: Short, high ≥ Short stop OR low ≤ Short target OR Cutoff reached OR position entry datetime < current session start