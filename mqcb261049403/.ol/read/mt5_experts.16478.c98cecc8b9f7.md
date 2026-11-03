Calculation: XvaMA = Apply the selected price to the indicator-timeframe bars; smooth it with the configured long-term method and lookback M. Let a=floor(M/4), b=floor(M/8), c=floor(M/12), and let Mₜ denote the smoothed value. Smooth Mₜ + (Mₜ−Mₜ₋ₐ) + (Mₜ−2Mₜ₋ₐ+Mₜ₋ᵦ)/2 + (Mₜ−3Mₜ₋ₐ+3Mₜ₋ᵦ−Mₜ₋𝒸)/6 with the configured short-term method and lookback. Decisions use the last completed indicator-timeframe bar; this timeframe may be higher or lower than the chart timeframe.
Calculation: XvaMA change = current XvaMA − previous XvaMA.
Calculation: Change standard deviation = population standard deviation of the latest configured number of consecutive XvaMA changes.
Calculation: Rounded XvaMA line = XvaMA rounded to the configured decimal precision.
Long: XvaMA change > lower threshold AND XvaMA change <= upper threshold OR XvaMA change > upper threshold OR Rounded XvaMA line is rising after falling.
Short: XvaMA change < −lower threshold AND XvaMA change >= −upper threshold OR XvaMA change < −upper threshold OR Rounded XvaMA line is falling after rising.
Exit: long, XvaMA change < −lower threshold AND XvaMA change >= −upper threshold OR XvaMA change < −upper threshold OR Rounded XvaMA line is falling.
Exit: short, XvaMA change > lower threshold AND XvaMA change <= upper threshold OR XvaMA change > upper threshold OR Rounded XvaMA line is rising.