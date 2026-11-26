Calculation: histogram = Ideal MA(close, fast rough lookback, fast adjusting lookback) − Ideal MA(Ideal MA(Ideal MA(close, slow stage 1 rough lookback, slow stage 1 adjusting lookback), slow stage 2 rough lookback, slow stage 2 adjusting lookback), slow stage 3 rough lookback, slow stage 3 adjusting lookback), calculated on bars of T1 with [0] the last completed bar
Long: histogram[1] < histogram[2] AND histogram[0] > histogram[1]
Short: histogram[1] > histogram[2] AND histogram[0] < histogram[1]
Exit: Long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance