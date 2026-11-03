Calculation: Daily pivot = (previous completed daily bar high + low + close) / 3
Calculation: R1 = 2 × daily pivot − previous completed daily low
Calculation: S1 = 2 × daily pivot − previous completed daily high
Calculation: R2 = daily pivot + (R1 − S1)
Calculation: S2 = daily pivot − (R1 − S1)
Calculation: R3 = previous completed daily bar high + 2 × (daily pivot − previous completed daily low)
Calculation: S3 = previous completed daily bar low − 2 × (previous completed daily bar high − daily pivot)
Long: (previous chart bar low < configured support entry level OR previous chart bar close <= configured support entry level) AND previous chart bar open > configured support entry level AND latest completed chart bar close >= configured support entry level; use S1 entry and S2 stop for schemes 1–2, or S2 entry and S3 stop for schemes 3–5; take profit is R1, R2, or R3 according to the configured scheme
Short: (previous chart bar high > configured resistance entry level OR previous chart bar close >= configured resistance entry level) AND previous chart bar open < configured resistance entry level AND latest completed chart bar close <= configured resistance entry level; use R1 entry and R2 stop for schemes 1–2, or R2 entry and R3 stop for schemes 3–5; take profit is S1, S2, or S3 according to the configured scheme
Exit: long, low <= configured stop-loss level OR high >= configured take-profit level OR configured intraday-only mode is enabled AND datetime hour = 23
Exit: short, high >= configured stop-loss level OR low <= configured take-profit level OR configured intraday-only mode is enabled AND datetime hour = 23