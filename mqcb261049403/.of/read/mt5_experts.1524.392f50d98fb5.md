Calculation: Slope = current Jurik moving average of the selected price minus its previous-bar value. For the trading algorithm, calculate it on the chart timeframe or a configurable higher or lower timeframe, using a configurable signal bar: the forming bar or a completed bar. Previous values refer to preceding bars of that same timeframe. For the indicator markings, calculate it on the chart timeframe.
Long: Slope > 0 AND previous Slope <= 0
Short: Slope < 0 AND previous Slope >= 0
Long: Slope > previous Slope AND Slope two bars ago > previous Slope
Short: Slope < previous Slope AND Slope two bars ago < previous Slope
Long: Slope > 0 AND Slope != previous Slope
Short: Slope < 0 AND Slope != previous Slope
Exit: long, Slope < 0
Exit: short, Slope > 0
Exit: long, Slope < previous Slope
Exit: short, Slope > previous Slope
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance