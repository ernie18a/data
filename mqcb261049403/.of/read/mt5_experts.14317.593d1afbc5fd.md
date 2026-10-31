Calculation: Smoothed bull power = Jurik moving average of (high − simple moving average of close), with a shorter smoothing lookback than the price-average lookback.
Long: Chart-timeframe smoothed bull power > its previous-bar value.
Short: Chart-timeframe smoothed bull power < its previous-bar value.
Long: Higher-timeframe smoothed bull power on the last completed bar > its previous-bar value AND its previous-bar value < its value two bars earlier.
Short: Higher-timeframe smoothed bull power on the last completed bar < its previous-bar value AND its previous-bar value > its value two bars earlier.
Exit: long, higher-timeframe smoothed bull power on the last completed bar < its previous-bar value OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, higher-timeframe smoothed bull power on the last completed bar > its previous-bar value OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.