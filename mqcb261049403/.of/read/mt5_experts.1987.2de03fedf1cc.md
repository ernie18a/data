Calculation: Oscillator = apply a moving average to the chosen bar price, subtract that average from the price, and smooth the difference with two successive moving averages using independently adjustable lookbacks; use the same smoothing method for all stages. The price-average lookback is longer than either smoothing lookback, and the first smoothing lookback is longer than the second.
Calculation: Signal line = moving average of the oscillator using the same smoothing method and a lookback longer than either oscillator smoothing lookback but shorter than the price-average lookback.
Calculation: Decision-bar oscillator and signal line = oscillator and signal line on the selected indicator timeframe, which may be higher or lower than the chart timeframe; use either its last completed bar or its still-forming bar as the selected signal bar. Previous values refer to preceding bars of that indicator timeframe.
Long: Decision-bar oscillator > 0 AND previous decision-bar oscillator <= 0.
Long: Decision-bar oscillator > previous decision-bar oscillator AND previous decision-bar oscillator < oscillator two decision bars ago.
Long: Decision-bar oscillator > decision-bar signal line AND previous decision-bar oscillator <= previous decision-bar signal line.
Short: Decision-bar oscillator < 0 AND previous decision-bar oscillator >= 0.
Short: Decision-bar oscillator < previous decision-bar oscillator AND previous decision-bar oscillator > oscillator two decision bars ago.
Short: Decision-bar oscillator < decision-bar signal line AND previous decision-bar oscillator >= previous decision-bar signal line.
Long: Chart-timeframe oscillator != 0 AND chart-timeframe oscillator > previous chart-timeframe oscillator.
Short: Chart-timeframe oscillator != 0 AND chart-timeframe oscillator < previous chart-timeframe oscillator.
Long: Chart-timeframe oscillator > chart-timeframe signal line.
Short: Chart-timeframe oscillator < chart-timeframe signal line.
Exit: long, decision-bar oscillator < 0.
Exit: long, decision-bar oscillator < previous decision-bar oscillator.
Exit: long, decision-bar oscillator < decision-bar signal line.
Exit: short, decision-bar oscillator > 0.
Exit: short, decision-bar oscillator > previous decision-bar oscillator.
Exit: short, decision-bar oscillator > decision-bar signal line.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.