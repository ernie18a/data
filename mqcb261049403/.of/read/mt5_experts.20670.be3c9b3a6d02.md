Calculation: Composite = 100 × DeMarker × Money Flow Index / Momentum; use 100 when Momentum is zero. Calculate Momentum as 100 × selected price / selected price its lookback bars ago, and calculate Money Flow Index using volume.
Calculation: Smoothed composite = Jurik moving average of Composite.
Long: On the chart timeframe, smoothed composite > its previous-bar value.
Short: On the chart timeframe, smoothed composite < its previous-bar value.
Long: On the configurable indicator timeframe, using the last completed bar, smoothed composite > its previous-bar value AND the previous-bar value <= the value two bars earlier.
Short: On the configurable indicator timeframe, using the last completed bar, smoothed composite < its previous-bar value AND the previous-bar value >= the value two bars earlier.
Exit: long, on the configurable indicator timeframe, using the last completed bar, smoothed composite < its previous-bar value OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, on the configurable indicator timeframe, using the last completed bar, smoothed composite > its previous-bar value OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.