Calculation: Rolling profile = over a configurable lookback of chart bars, divide the highest high–lowest low range into configurable equal price bins; assign each bar’s volume to the bin containing its close. The point of control (POC) is the midpoint of the highest-volume bin. Value area expands from the POC toward the adjacent bin with greater volume (ties go lower) until it contains a configurable share of total volume; its upper and lower bounds are VAH and VAL, and its midpoint is (VAH + VAL) / 2.
Calculation: Participation axis = stabilize the rolling POC in three stages: clamp each bar’s POC change from stage 1 to ±(55-bar ATR × configurable band), add it to stage 1 and smooth with an EMA; update stage 2 to stage 1 only when their difference exceeds the band; update stage 3 to stage 2 only when their difference exceeds the band. Initialize all stages to the POC. Use stage 3 as the axis.
Calculation: Axis deviation = (close − participation axis) / max(55-bar ATR, minimum tick), clamped to a configurable positive and negative limit.
Calculation: Balance tilt = volume share above VAH − volume share below VAL, using the rolling profile.
Long: close crosses above participation axis
Long: axis deviation ≤ −0.85 × its configurable absolute limit
Long: close crosses above VAH
Long: close crosses above the value-area midpoint
Long: balance tilt crosses above 0
Long: participation-axis slope crosses above 0
Short: close crosses below participation axis
Short: axis deviation ≥ 0.85 × its configurable absolute limit
Short: close crosses below VAL
Short: close crosses below the value-area midpoint
Short: balance tilt crosses below 0
Short: participation-axis slope crosses below 0