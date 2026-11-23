Calculation: T2 = the timeframe immediately above T1
Calculation: Bias(X, k) = bull if (low[1] < low[2] AND close[1] > low[2]) OR close[1] > high[2]; else bear if (high[1] > high[2] AND close[1] < high[2]) OR close[1] < low[2]; else Bias(X, k)[1]; computed on X bars of correlated instrument k, using the last completed X bar as [1]
Long: Bias(T1, 1) = bull
Long: Bias(T1, 2) = bull
Long: Bias(T1, 3) = bull
Long: Bias(T2, 1) = bull
Long: Bias(T2, 2) = bull
Long: Bias(T2, 3) = bull
Long: Bias(T1, 1) = bull AND (Bias(T2, 1) = bull OR NOT htf_validation)
Long: Bias(T1, 2) = bull AND (Bias(T2, 2) = bull OR NOT htf_validation)
Long: Bias(T1, 3) = bull AND (Bias(T2, 3) = bull OR NOT htf_validation)
Long: count of k in 1..counted_instruments where Bias(T1, k) = bull AND (Bias(T2, k) = bull OR NOT htf_validation) is at least required_agreement
Short: Bias(T1, 1) = bear
Short: Bias(T1, 2) = bear
Short: Bias(T1, 3) = bear
Short: Bias(T2, 1) = bear
Short: Bias(T2, 2) = bear
Short: Bias(T2, 3) = bear
Short: Bias(T1, 1) = bear AND (Bias(T2, 1) = bear OR NOT htf_validation)
Short: Bias(T1, 2) = bear AND (Bias(T2, 2) = bear OR NOT htf_validation)
Short: Bias(T1, 3) = bear AND (Bias(T2, 3) = bear OR NOT htf_validation)
Short: count of k in 1..counted_instruments where Bias(T1, k) = bear AND (Bias(T2, k) = bear OR NOT htf_validation) is at least required_agreement