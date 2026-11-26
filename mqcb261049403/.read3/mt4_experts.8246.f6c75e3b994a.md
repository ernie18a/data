Long: DeMarker(lookback) crosses above the long DeMarker threshold AND Stochastic %K(K lookback, slowing, EMA method) crosses above the long stochastic threshold
Short: DeMarker(lookback) crosses below the short DeMarker threshold AND Stochastic %K(K lookback, slowing, EMA method) crosses below the short stochastic threshold
Exit: long, Bid <= entry price - stop-loss distance in points OR Bid >= entry price + take-profit distance in points
Exit: short, Ask >= entry price + stop-loss distance in points OR Ask <= entry price - take-profit distance in points