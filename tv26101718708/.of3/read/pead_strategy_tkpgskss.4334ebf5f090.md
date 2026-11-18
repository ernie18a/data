Long: On the first regular-session chart bar of each T1 period, close(T1, last completed bar) ≠ 0 AND open(T1, bar still forming) / close(T1, last completed bar) − 1 ≥ gapThresh / 100 AND close(T1, last completed bar) > close(T1, perfDays + 1 bars ago); compute these conditions on T1 bars and map their values to chart bars
Calculation: Protective stop = entry price × (1 − stopPct / 100), raised permanently to entry price once a chart-bar close ≥ entry price × (1 + breakevenMultiple × stopPct / 100)
Exit: long, chart-bar close crosses below EMA(close, emaLen, T1, bar still forming), calculated on T1 bars and mapped to chart bars
Exit: long, chart-bar low ≤ Protective stop
Exit: long, chart bars since entry ≥ maxHoldBars