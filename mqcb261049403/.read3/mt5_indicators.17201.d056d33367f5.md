Calculation: positive and negative directional indices = RMA(U/(U+D), lookback) and RMA(D/(U+D), lookback), where U = RMA(max(price - price[1], 0), lookback) and D = RMA(max(price[1] - price, 0), lookback); use zero when U+D=0 and initialize the RMA series at zero
Long: positive directional index > direction threshold
Short: negative directional index > direction threshold