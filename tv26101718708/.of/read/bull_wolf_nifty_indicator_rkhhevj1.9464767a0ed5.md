Calculation: HLC3 = (high + low + close) / 3
Calculation: Session VWAP = cumulative sum of (HLC3 × volume) / cumulative volume since session start
Calculation: Volume-weighted standard deviation = square root of max( cumulative sum of (HLC3² × volume) / cumulative volume − Session VWAP², 0 ), since session start
Calculation: Lower third-SD band = Session VWAP − 3 × volume-weighted standard deviation
Calculation: Upper third-SD band = Session VWAP + 3 × volume-weighted standard deviation
Calculation: Long entry limit = lower third-SD band + entry tolerance
Calculation: Short entry limit = upper third-SD band − entry tolerance
Calculation: Long stop = Session VWAP − stop-distance multiplier × volume-weighted standard deviation, fixed when the long entry order is submitted
Calculation: Short stop = Session VWAP + stop-distance multiplier × volume-weighted standard deviation, fixed when the short entry order is submitted
Calculation: Long target = Session VWAP − entry tolerance
Calculation: Short target = Session VWAP + entry tolerance
Long: Current time is within the session's entry window AND not within the post-stop cooldown AND volume-weighted standard deviation > 0 AND long stop < long entry limit < long target AND low <= long entry limit
Short: Current time is within the session's entry window AND not within the post-stop cooldown AND volume-weighted standard deviation > 0 AND short target < short entry limit < short stop AND high >= short entry limit
Exit: long, low <= fixed long stop OR high >= current long target OR current time >= session cutoff OR position entry time < current session start
Exit: short, high >= fixed short stop OR low <= current short target OR current time >= session cutoff OR position entry time < current session start