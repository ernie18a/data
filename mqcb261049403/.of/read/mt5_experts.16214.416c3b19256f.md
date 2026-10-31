Calculation: Smoothed balance of power = 100 × a configurable moving average of (close − open) / (high − low); use 0 when high = low. Calculate separately on the chart timeframe and on the configurable signal timeframe, which may be higher or lower than the chart timeframe. For the signal timeframe, use the last completed bar by default or the still-forming bar if configured; references to earlier bars are relative to that selected bar.
Long: Chart-timeframe smoothed balance of power > 0 AND chart-timeframe smoothed balance of power != its previous value
Short: Chart-timeframe smoothed balance of power < 0 AND chart-timeframe smoothed balance of power != its previous value
Long: Signal-timeframe smoothed balance of power > its previous value AND its value two bars ago > its previous value
Short: Signal-timeframe smoothed balance of power < its previous value AND its value two bars ago < its previous value
Exit: long, signal-timeframe smoothed balance of power < its previous value
Exit: short, signal-timeframe smoothed balance of power > its previous value
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance