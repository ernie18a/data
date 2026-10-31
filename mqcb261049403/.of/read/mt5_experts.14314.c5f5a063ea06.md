Calculation: Smoothed bear power = Jurik moving average of (low minus the simple moving average of close), using a shorter lookback for the Jurik moving average. Calculate on the chart timeframe or a selectable higher or lower timeframe; use the last completed bar or the still-forming bar according to the signal-bar setting. Index 0 denotes the selected bar and negative indices denote preceding bars on that timeframe.
Long: Smoothed bear power[0] > smoothed bear power[-1]
Short: Smoothed bear power[0] < smoothed bear power[-1]
Long: Smoothed bear power[0] > smoothed bear power[-1] AND smoothed bear power[-1] < smoothed bear power[-2]
Short: Smoothed bear power[0] < smoothed bear power[-1] AND smoothed bear power[-1] > smoothed bear power[-2]
Exit: long, smoothed bear power[0] < smoothed bear power[-1]
Exit: short, smoothed bear power[0] > smoothed bear power[-1]
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance