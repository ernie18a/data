Calculation: LSMA angle = price-scale factor × (least-squares moving average of close at a more recent bar offset − the same moving average at an older bar offset) / (2 × the difference between the offsets). Calculate on a configurable timeframe that may be higher or lower than the chart timeframe; use its last completed bar, or its still-forming bar when configured. Apply the same choice to the previous bar’s angle.
Calculation: Up state = angle > positive threshold AND angle > previous angle.
Calculation: Down state = angle < negative threshold AND angle < previous angle; the negative threshold is the negation of the positive threshold.
Calculation: Negative state = angle < negative threshold AND angle != previous angle.
Long: Up state = true AND previous bar’s up state = false.
Short: Down state = true AND previous bar’s down state = false.
Exit: long, negative state = true OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, negative state = false OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.