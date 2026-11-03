Calculation: TRIX = percentage change from the previous bar in an EMA of an SMMA of an SMMA of close; all three smoothing lengths use the TRIX lookback
Calculation: Signal = EMA of TRIX using the signal lookback
Long: On the last completed chart-timeframe bar, TRIX > Signal AND on the preceding bar, TRIX <= Signal
Short: On the last completed chart-timeframe bar, TRIX < Signal AND on the preceding bar, TRIX >= Signal
Exit: Long, TRIX < Signal AND on the preceding bar, TRIX >= Signal OR close <= entry price minus the configured stop-loss distance
Exit: Short, TRIX > Signal AND on the preceding bar, TRIX <= Signal OR close >= entry price plus the configured stop-loss distance