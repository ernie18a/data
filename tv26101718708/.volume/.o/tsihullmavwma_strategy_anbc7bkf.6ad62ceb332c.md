Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: TSI = 100 × double-EMA-smoothed change in OHLC4 / double-EMA-smoothed absolute change in OHLC4; the two smoothing lengths are equal
Calculation: H1 = WMA(2 × WMA(OHLC4, rounded half-length) − WMA(OHLC4, full length), rounded square root of full length)
Calculation: H2 = WMA(2 × WMA(OHLC4[1], rounded half-length) − WMA(OHLC4[1], full length), rounded square root of full length)
Long: TSI > EMA(TSI, signal length) AND OHLC4 > OHLC4[1] AND OHLC4 > OHLC4[2] AND OHLC4 > OHLC4[3] AND H1 > H2 AND H1 > H2[1] AND VWMA(OHLC4, shorter length) > VWMA(OHLC4, twice the shorter length)
Short: TSI < EMA(TSI, signal length) AND OHLC4 < OHLC4[1] AND OHLC4 < OHLC4[2] AND OHLC4 < OHLC4[3] AND H1 < H2 AND H1 < H2[1] AND VWMA(OHLC4, shorter length) < VWMA(OHLC4, twice the shorter length)
Exit: long or short, unrealized position profit > target threshold OR unrealized position profit < stop-loss threshold