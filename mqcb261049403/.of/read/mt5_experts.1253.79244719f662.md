Calculation: Bullish state = shorter-period smoothed RSI > longer-period smoothed RSI AND shorter-period smoothed CCI > longer-period smoothed CCI; RSI and CCI use the same lookback and applied price, and all smoothing uses the same method.
Calculation: Bearish state = shorter-period smoothed RSI < longer-period smoothed RSI AND shorter-period smoothed CCI < longer-period smoothed CCI, using the same parameters as the bullish state.
Calculation: Neutral state = bullish state is false AND bearish state is false.
Long: Bullish state is true on the chart bar.
Short: Bearish state is true on the chart bar.
Long: Bullish state is true on the last completed higher-timeframe bar AND bullish state is false on its preceding bar.
Short: Bearish state is true on the last completed higher-timeframe bar AND bearish state is false on its preceding bar.
Exit: long, bearish state is true on the last completed higher-timeframe bar OR neutral-state exits are enabled AND neutral state is true on the last completed higher-timeframe bar.
Exit: short, bullish state is true on the last completed higher-timeframe bar OR neutral-state exits are enabled AND neutral state is true on the last completed higher-timeframe bar.
Exit: long, low <= entry price minus the stop-loss distance OR high >= entry price plus the take-profit distance.
Exit: short, high >= entry price plus the stop-loss distance OR low <= entry price minus the take-profit distance.