Calculation: LowPair(i, j, k) = ((low[i] >= low[j] AND corr_low_k[i] < corr_low_k[j]) OR (low[i] <= low[j] AND corr_low_k[i] > corr_low_k[j])) AND min(low[0..j-1]) >= min(low[i], low[j]) AND min(corr_low_k[0..j-1]) >= min(corr_low_k[i], corr_low_k[j]), where i < j, L is the SMT lookback, unprefixed bars are T1 bars of the traded instrument, offset 0 is the T1 bar still forming, and corr_*_k are T1 bars of correlated instrument k
Calculation: HighPair(i, j, k) = ((high[i] >= high[j] AND corr_high_k[i] < corr_high_k[j]) OR (high[i] <= high[j] AND corr_high_k[i] > corr_high_k[j])) AND max(high[0..j-1]) <= max(high[i], high[j]) AND max(corr_high_k[0..j-1]) <= max(corr_high_k[i], corr_high_k[j])
Calculation: InGap(x, n, p) = for some a > n, (low_x[a] > high_x[a+2] AND high_x[a+2] <= p AND p <= low_x[a]) OR (high_x[a] < low_x[a+2] AND high_x[a] <= p AND p <= low_x[a+2]), where x is the traded instrument or correlated instrument k, both on T1 bars
Calculation: PSPdis(c, k) = (close[c] > open[c]) differs from (corr_close_k[c] > corr_open_k[c])
Calculation: SSPSPLow(c) = for some correlated instrument k, PSPdis(c, k) AND ((low[c] < min(low[c+1..c+M]) AND corr_low_k[c] >= min(corr_low_k[c+1..c+M])) OR (corr_low_k[c] < min(corr_low_k[c+1..c+M]) AND low[c] >= min(low[c+1..c+M])))
Calculation: SSPSPHigh(c) = for some correlated instrument k, PSPdis(c, k) AND ((high[c] > max(high[c+1..c+M]) AND corr_high_k[c] <= max(corr_high_k[c+1..c+M])) OR (corr_high_k[c] > max(corr_high_k[c+1..c+M]) AND high[c] <= max(high[c+1..c+M])))
Calculation: SweepLow(i, a, k) = (low[a] < min(low[a+1..a+M]) AND low[i] > low[a] AND corr_low_k[i] < corr_low_k[a]) OR (corr_low_k[a] < min(corr_low_k[a+1..a+M]) AND corr_low_k[i] > corr_low_k[a] AND low[i] < low[a]), where M is the sweep lookback, a parameter separate from L
Calculation: SweepHigh(i, a, k) = (high[a] > max(high[a+1..a+M]) AND high[i] < high[a] AND corr_high_k[i] > corr_high_k[a]) OR (corr_high_k[a] > max(corr_high_k[a+1..a+M]) AND corr_high_k[i] < corr_high_k[a] AND high[i] > high[a]), where M is the sweep lookback, a parameter separate from L
Long: for some correlated instrument k and some i, j with i < j <= i + L, LowPair(i, j, k)
Short: for some correlated instrument k and some i, j with i < j <= i + L, HighPair(i, j, k)
Long: for some correlated instrument k and some i, j with i < j <= i + L, LowPair(i, j, k) AND (InGap(traded instrument, i, low[i]) OR InGap(correlated instrument k, i, corr_low_k[i]))
Short: for some correlated instrument k and some i, j with i < j <= i + L, HighPair(i, j, k) AND (InGap(traded instrument, i, high[i]) OR InGap(correlated instrument k, i, corr_high_k[i]))
Long: for some correlated instrument k and some i, LowPair(i, i+1, k) AND T1 is a cycle-quarter timeframe
Short: for some correlated instrument k and some i, HighPair(i, i+1, k) AND T1 is a cycle-quarter timeframe
Long: for some i and a with i < a <= i + L, LowPair(i, a, k) for some correlated instrument k, no a' with a < a' <= i + L has LowPair(i, a', k') for any correlated instrument k', and SweepLow(i, a, k'') for some correlated instrument k''
Short: for some i and a with i < a <= i + L, HighPair(i, a, k) for some correlated instrument k, no a' with a < a' <= i + L has HighPair(i, a', k') for any correlated instrument k', and SweepHigh(i, a, k'') for some correlated instrument k''
Long: SSPSPLow(0) OR SSPSPLow(1)
Short: SSPSPHigh(0) OR SSPSPHigh(1)
Long: low[0] < low[1] AND close[0] > low[1]
Long: low[0] < low[1] AND close[0] <= low[1]
Long: low[1] < low[2] AND close[1] > low[2]
Short: high[0] > high[1] AND close[0] < high[1]
Short: high[0] > high[1] AND close[0] >= high[1]
Short: high[1] > high[2] AND close[1] < high[2]