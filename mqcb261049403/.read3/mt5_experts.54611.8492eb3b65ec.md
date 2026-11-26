Calculation: T1 range percentage = 100 × (high(T1, current forming bar) − low(T1, current forming bar)) / high(T1, current forming bar), read on chart bars
Calculation: zone divisor = if T1 range percentage >= lower range threshold AND T1 range percentage >= midpoint(lower range threshold, upper range threshold), larger-range divisor parameter; otherwise default divisor parameter
Calculation: T1 upper zone = high(T1, current forming bar) − (high(T1, current forming bar) − low(T1, current forming bar)) / zone divisor, read on chart bars
Calculation: T1 lower zone = low(T1, current forming bar) + (high(T1, current forming bar) − low(T1, current forming bar)) / zone divisor, read on chart bars
Calculation: previous chart bar range in points = (high[1] − low[1]) / point
Calculation: spread threshold = current instrument spread × point × spread multiplier parameter
Long: (time filter disabled OR (current time > entry start time AND current time < entry end time AND weekday is Monday through Friday)) AND T1 range percentage > lower range threshold AND T1 range percentage < upper range threshold AND previous chart bar range in points > spread threshold AND close[1] > T1 upper zone AND open[0] >= close[1] AND current bid > T1 upper zone
Short: (time filter disabled OR (current time > entry start time AND current time < entry end time AND weekday is Monday through Friday)) AND T1 range percentage > lower range threshold AND T1 range percentage < upper range threshold AND previous chart bar range in points > spread threshold AND close[1] < T1 lower zone AND open[0] <= close[1] AND current ask < T1 lower zone
Exit: long, current time >= configured close time
Exit: short, current time >= configured close time