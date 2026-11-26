Long: RSX(close, lookback) > RSX(close, lookback)[1] AND RSX(close, lookback) > upper-level parameter
Long: RSX(close, lookback) > RSX(close, lookback)[1] AND RSX(close, lookback) <= upper-level parameter
Short: RSX(close, lookback) < RSX(close, lookback)[1] AND RSX(close, lookback) < lower-level parameter
Short: RSX(close, lookback) < RSX(close, lookback)[1] AND RSX(close, lookback) >= lower-level parameter
Long: on chart bars using T1 values, RSX(close, lookback, T1, last completed bar) > RSX(close, lookback, T1, one bar before the last completed bar) AND RSX(close, lookback, T1, one bar before the last completed bar) < RSX(close, lookback, T1, two bars before the last completed bar)
Short: on chart bars using T1 values, RSX(close, lookback, T1, last completed bar) < RSX(close, lookback, T1, one bar before the last completed bar) AND RSX(close, lookback, T1, one bar before the last completed bar) > RSX(close, lookback, T1, two bars before the last completed bar)
Exit: long, elapsed holding time > holding-time parameter
Exit: short, elapsed holding time > holding-time parameter