Long: EMA(source, lookback) > EMA(source, lookback)[1] on chart bars
Short: EMA(source, lookback) < EMA(source, lookback)[1] on chart bars
Long: EMA(source, lookback) > EMA(source, lookback)[1] AND EMA(source, lookback)[1] <= EMA(source, lookback)[2] on chart bars
Short: EMA(source, lookback) < EMA(source, lookback)[1] AND EMA(source, lookback)[1] >= EMA(source, lookback)[2] on chart bars
Long: close crosses above EMA(source, lookback) on chart bars
Short: close crosses below EMA(source, lookback) on chart bars
Long: close > EMA(source, lookback) on chart bars
Short: close <= EMA(source, lookback) on chart bars
Long: For each of T1 through T8, EMA(source, lookback) on the current T bar > EMA(source, lookback) on the previous completed T bar; calculate on T bars and map values to chart bars, using the forming T bar in real time and the last completed T bar historically
Short: For each of T1 through T8, EMA(source, lookback) on the current T bar <= EMA(source, lookback) on the previous completed T bar; calculate on T bars and map values to chart bars, using the forming T bar in real time and the last completed T bar historically
Long: For each of T1 through T8, close on the current T bar > EMA(source, lookback) on the current T bar; calculate on T bars and map values to chart bars, using the forming T bar in real time and the last completed T bar historically
Short: For each of T1 through T8, close on the current T bar <= EMA(source, lookback) on the current T bar; calculate on T bars and map values to chart bars, using the forming T bar in real time and the last completed T bar historically