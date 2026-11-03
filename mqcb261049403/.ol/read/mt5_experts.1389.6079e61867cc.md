Calculation: Distance-weighted average = For each bar t, choose an OHLC-derived price p. For lookback N and power k, set w(t) = sum over j = 0 to N-1 of abs((p(t) - p(t-j))^k). The average at t is sum over i = 0 to N-1 of w(t-i) * p(t-i), divided by sum over i = 0 to N-1 of w(t-i); use zero when the denominator is zero. Calculate on the chart timeframe or a selectable higher or lower timeframe, using the last completed bar or the still-forming bar as selected. Let A0, A1 and A2 be its values on the selected signal bar and the two preceding bars, respectively.
Calculation: Volatility state = Smooth ATR and the standard deviation of close separately with selectable moving averages; ATR and standard deviation use the same lookback. On the same timeframe and signal bar as the distance-weighted average, state is 3 if both smoothed values are greater than their previous-bar values, 2 if both are less, and 1 otherwise.
Long: A0 > A1 AND A2 > A1
Short: A0 < A1 AND A2 < A1
Long: A0 > A1 AND A2 > A1 AND volatility state >= selected volatility threshold
Short: A0 < A1 AND A2 < A1 AND volatility state >= selected volatility threshold
Exit: long, A0 < A1 OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, A0 > A1 OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance