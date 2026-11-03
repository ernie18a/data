Calculation: EMA = exponential moving average of close.
Calculation: Prior-window high = highest high over a lookback window ending one bar before the last completed higher-timeframe bar.
Calculation: Prior-window low = lowest low over a lookback window ending one bar before the last completed higher-timeframe bar.
Long: On any of the three aggregated timeframes, each higher than the chart timeframe, using its last completed bar: close > EMA AND (close > prior-window high OR EMA > its value on the preceding bar).
Short: On any of the three aggregated timeframes, each higher than the chart timeframe, using its last completed bar: close < EMA AND (close < prior-window low OR EMA < its value on the preceding bar).