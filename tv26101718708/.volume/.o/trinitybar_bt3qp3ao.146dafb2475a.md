Calculation: current bar thirds = lower: low + (high − low)/3; upper: high − (high − low)/3
Calculation: daily VWAP = cumulative volume-weighted (high + low + close)/3 from the current daily session start through the current, possibly forming, bar
Calculation: long target = high[2] + multiplier × (high[2] − low[3]); short target = low[2] − multiplier × (high[3] − low[2])
Long: (open[2] ≤ lower third[2] AND close[2] ≥ upper third[2] OR open[2] ≥ upper third[2] AND close[2] ≥ upper third[2]) AND low[3] < low[2] AND low[3] < daily VWAP AND close[2] > daily VWAP
Short: (open[2] ≤ lower third[2] AND close[2] ≤ lower third[2] OR open[2] ≥ upper third[2] AND close[2] ≤ lower third[2]) AND high[3] > high[2] AND high[3] > daily VWAP AND close[2] < daily VWAP
Exit: long, short condition OR high ≥ entry price + (long target − signal-bar close) OR low ≤ entry price − (signal-bar close − low[2])
Exit: short, long condition OR low ≤ entry price − (signal-bar close − short target) OR high ≥ entry price + (high[2] − signal-bar close)