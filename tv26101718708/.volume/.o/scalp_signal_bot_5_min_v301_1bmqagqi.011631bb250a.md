Calculation: Confirmed swing high/low = latest pivot high/low, using the configured swing source and lookback length on both sides; available after the right-side bars complete
Calculation: Sweep buffer = ATR × configured multiplier, or minimum tick × configured tick count
Calculation: Recent low-sweep reclaim = within the configured age after the latest new lowest-low sweep, close > sweep price + buffer; in cross-confirm mode, previous close must also be <= that level
Calculation: Recent high-sweep reclaim = within the configured age after the latest new highest-high sweep, close < sweep price − buffer; in cross-confirm mode, previous close must also be >= that level
Calculation: Long stop = latest low-sweep price − buffer, or latest confirmed swing low − buffer if no low-sweep price exists
Calculation: Short stop = latest high-sweep price + buffer, or latest confirmed swing high + buffer if no high-sweep price exists
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × configured R multiple, or signal-bar close × (1 + configured target percentage)
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × configured R multiple, or signal-bar close × (1 − configured target percentage)
Long: close > latest confirmed swing high AND recent low-sweep reclaim AND bars since latest low or high sweep > configured entry-delay bars AND (trend filter disabled or close > configured EMA)
Short: close < latest confirmed swing low AND bars since latest low or high sweep > configured entry-delay bars AND (trend filter disabled or close < configured EMA)
Exit: long, low <= locked long stop OR high >= locked long target
Exit: short, high >= locked short stop OR low <= locked short target