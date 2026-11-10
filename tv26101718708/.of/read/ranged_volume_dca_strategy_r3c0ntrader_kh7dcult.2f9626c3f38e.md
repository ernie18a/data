Calculation: Selected source = a configurable source derived from the input bar fields, optionally using its previous chart bar when repainting is disabled.
Calculation: Signal open and source = chart-bar open and selected source, optionally calculated from Heikin-Ashi bars instead of ordinary bars.
Calculation: Volume maximum = highest chart-bar volume over the configured lookback, including the current bar; use its previous-bar value when repainting is disabled.
Calculation: Safety threshold = initial order source price × (1 − price deviation × safety-order number) if the step scale equals 1; otherwise initial order source price × (1 − price deviation × (step scale ^ safety-order number − 1) / (step scale − 1)). The safety-order number starts at 1 after the initial entry and increases by 1 after each safety order.
Calculation: Average entry price = quantity-weighted average fill price of the initial entry and safety orders; initial quantity is base-order amount divided by selected source, and safety-order quantity is safety-order amount × volume scale ^ (safety-order number − 1) divided by safety threshold.
Calculation: Trailing activation = the first bar after entry whose high is at least average entry price × (1 + take-profit fraction); it remains active until exit.
Calculation: Trailing stop = the maximum of its previous value and close × (1 − trailing fraction), updated on each bar starting with the trailing-activation bar and reset to zero after exit.
Long: Volume maximum > previous volume maximum AND signal source > signal open.
Short: Volume maximum > previous volume maximum AND signal source < signal open.
Long: Position is flat AND selected source > 0 AND volume maximum > previous volume maximum AND signal source > signal open AND datetime is within the configured start and end times inclusive.
Long: Safety-order number > 0 AND safety-order number <= maximum safety orders AND low <= safety threshold AND trailing activation is inactive.
Exit: Long, trailing fraction = 0 AND high >= average entry price × (1 + take-profit fraction).
Exit: Long, trailing fraction > 0 AND trailing activation was active before the current bar AND (high <= trailing stop OR close <= trailing stop).