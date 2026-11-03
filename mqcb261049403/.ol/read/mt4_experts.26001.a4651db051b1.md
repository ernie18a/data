Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Calculation: Bar range = high − low
Calculation: Typical price = (high + low + close) / 3
Calculation: Fast and slow averages = linear weighted moving averages of typical price, with the fast lookback shorter than the slow lookback, on a higher timeframe’s bar still forming
Calculation: Entry distance threshold = a parameterized number of chart points
Long: ((previous completed chart bar open > close AND upper wick / bar range >= 0.50) OR (previous completed chart bar open < close AND upper wick / bar range >= 0.50)) AND fast average > slow average AND absolute distance between current chart bar price and the close two chart bars ago > entry distance threshold
Short: ((previous completed chart bar open > close AND lower wick / bar range >= 0.50) OR (previous completed chart bar open < close AND lower wick / bar range >= 0.50)) AND fast average < slow average AND absolute distance between current chart bar price and the previous completed chart bar close > entry distance threshold
Exit: long, price <= entry price − stop-loss distance OR price >= entry price + take-profit distance
Exit: short, price >= entry price + stop-loss distance OR price <= entry price − take-profit distance