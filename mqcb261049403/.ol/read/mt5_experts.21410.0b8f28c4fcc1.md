Calculation: Rounded double-smoothed price = apply a configurable moving average to a configurable OHLC-derived price, apply a second configurable moving average to that result, then round to a configurable price increment; the first smoothing has a longer lookback than the second.
Calculation: Trend state = +1 when the rounded double-smoothed price is greater than its previous-bar value, -1 when it is less, and otherwise the previous trend state; initialize to 0.
Calculation: Trading-system trend state = independently calculate the trend state on each of three configurable timeframes, ordered longest to shortest; each may be higher or lower than the chart timeframe or equal to it. Use the last completed bar, or the still-forming bar if configured.
Long: chart-timeframe trend state = +1
Short: chart-timeframe trend state = -1
Long: any trading-system trend state = +1 AND its previous-bar trend state != +1
Short: any trading-system trend state = -1 AND its previous-bar trend state != -1
Exit: long, the position's trading-system trend state = -1 OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, the position's trading-system trend state = +1 OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance