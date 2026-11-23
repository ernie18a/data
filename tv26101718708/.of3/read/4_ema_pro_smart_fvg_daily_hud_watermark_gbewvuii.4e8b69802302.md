Long: close > EMA(close, shortest lookback) AND EMA(close, shortest lookback) > EMA(close, next-shortest lookback) AND EMA(close, next-shortest lookback) > EMA(close, next-longest lookback) AND EMA(close, next-longest lookback) > EMA(close, longest lookback)
Short: close < EMA(close, shortest lookback) AND EMA(close, shortest lookback) < EMA(close, next-shortest lookback) AND EMA(close, next-shortest lookback) < EMA(close, next-longest lookback) AND EMA(close, next-longest lookback) < EMA(close, longest lookback)
Long: EMA(close, shortest lookback) crosses above EMA(close, next-shortest lookback)
Short: EMA(close, shortest lookback) crosses below EMA(close, next-shortest lookback)
Long: low > high[2]
Short: high < low[2]
Long: EMA(close, shortest lookback) > EMA(close, shortest lookback)[1] OR EMA(close, next-shortest lookback) > EMA(close, next-shortest lookback)[1] OR EMA(close, next-longest lookback) > EMA(close, next-longest lookback)[1] OR EMA(close, longest lookback) > EMA(close, longest lookback)[1]
Short: EMA(close, shortest lookback) < EMA(close, shortest lookback)[1] OR EMA(close, next-shortest lookback) < EMA(close, next-shortest lookback)[1] OR EMA(close, next-longest lookback) < EMA(close, next-longest lookback)[1] OR EMA(close, longest lookback) < EMA(close, longest lookback)[1]
Long: close > EMA(close, shortest lookback) OR close > EMA(close, next-shortest lookback) OR close > EMA(close, next-longest lookback) OR close > EMA(close, longest lookback)
Short: close < EMA(close, shortest lookback) OR close < EMA(close, next-shortest lookback) OR close < EMA(close, next-longest lookback) OR close < EMA(close, longest lookback)
Long: EMA(close, shortest lookback) >= EMA(close, next-shortest lookback) OR EMA(close, next-shortest lookback) >= EMA(close, next-longest lookback) OR EMA(close, next-longest lookback) >= EMA(close, longest lookback)
Short: EMA(close, shortest lookback) < EMA(close, next-shortest lookback) OR EMA(close, next-shortest lookback) < EMA(close, next-longest lookback) OR EMA(close, next-longest lookback) < EMA(close, longest lookback)
Long: on chart bars using T1 values, the T1 bar still forming has close >= open
Short: on chart bars using T1 values, the T1 bar still forming has close < open
Long: on chart bars using T1 values, close >= open on the last completed T1 bar OR close >= open on the T1 bar two bars ago
Short: on chart bars using T1 values, close < open on the last completed T1 bar OR close < open on the T1 bar two bars ago