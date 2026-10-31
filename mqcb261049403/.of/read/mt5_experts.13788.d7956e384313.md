Calculation: Range midpoint = (highest high + lowest low) / 2 over the specified lookback, including the evaluated bar.
Calculation: Oscillator = close − longest-lookback range midpoint − (shortest-lookback range midpoint − intermediate-lookback range midpoint).
Calculation: Signal = configurable moving average of the oscillator, with its own smoothing period and method. For the indicator markings, calculate it on the chart timeframe. For the trading decisions, calculate it on a configurable higher or lower timeframe, using the last completed bar by default or the forming bar when configured.
Long: Chart-timeframe signal > its previous-bar value.
Short: Chart-timeframe signal < its previous-bar value.
Long: Trading-timeframe signal > its previous-bar value AND its value two bars earlier >= its previous-bar value.
Short: Trading-timeframe signal < its previous-bar value AND its value two bars earlier <= its previous-bar value.
Exit: short, trading-timeframe signal > its previous-bar value.
Exit: long, trading-timeframe signal < its previous-bar value.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.