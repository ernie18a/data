Calculation: bar delta = if high = low then 0 else volume * ((close - low) - (high - close)) / (high - low)
Calculation: session cumulative delta = sum(bar delta over chart bars since session start)
Calculation: session VWAP Delta = if sum(abs(bar delta) over chart bars since session start) = 0 then (high + low + close) / 3 else sum(((high + low + close) / 3) * abs(bar delta) over chart bars since session start) / sum(abs(bar delta) over chart bars since session start)
Long: session cumulative delta >= 0
Short: session cumulative delta < 0
Long: close > session VWAP Delta