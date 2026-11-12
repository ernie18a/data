Calculation: TF_main = a timeframe higher than the chart timeframe; TF_h1 = a timeframe higher than TF_main; TF_h2 = a timeframe higher than TF_h1. Every value below is computed from that timeframe's bars. 'Forming' means the bar still forming, 'completed' means the last completed bar, and 'prior completed' means the completed bar before that.
Calculation: Main EMAs = EMA of close on TF_main with four lengths, EMA_a < EMA_b < EMA_c < EMA_d (in length order)
Calculation: H1 EMAs = EMA of close on TF_h1 with a shorter length (H1_short) and a longer length (H1_long)
Calculation: H2 averages = EMA of close on TF_h2 with a short, a medium and a long length (H2_short < H2_mid < H2_long), plus an SMA of close on TF_h2 with the long length
Calculation: StochRSI_K = SMA (short smoothing) of the stochastic of RSI, i.e. (RSI - lowest RSI over lookback) / (highest RSI - lowest RSI) * 100; RSI is computed on close. RSI and StochRSI_K are evaluated on each of TF_main, TF_h1 and TF_h2.
Long: forming EMA_a > EMA_b AND EMA_b > EMA_c (all on TF_main)
Short: forming EMA_a < EMA_b AND EMA_b < EMA_c (all on TF_main)
Long: forming TF_main close > EMA_a AND > EMA_b AND RSI(TF_main, forming) > 50 (weak). Adding close > EMA_c makes it medium. Adding close > EMA_c AND > EMA_d makes it strong.
Short: forming TF_main close < EMA_a AND < EMA_b AND RSI(TF_main, forming) < 50 (weak). Adding close < EMA_c makes it medium. Adding close < EMA_c AND < EMA_d makes it strong.
Long: forming TF_main close > EMA_b AND forming close < EMA_b * (1 + small fraction) AND NOT the weak long condition above (pullback to EMA_b in an uptrend)
Short: forming TF_main close < EMA_b AND forming close > EMA_b * (1 - small fraction) AND NOT the weak short condition above (rally to EMA_b in a downtrend)
Long: for a given average on TF_main, TF_h1 or TF_h2, that timeframe's forming close > that average
Short: for a given average on TF_main, TF_h1 or TF_h2, that timeframe's forming close < that average
Long: for a timeframe among TF_main, TF_h1, TF_h2, completed close > its medium-length EMA AND > its long-length EMA (TF_main uses EMA_b and EMA_d; TF_h1 uses H1_short and H1_long; TF_h2 uses H2_mid and H2_long). Trend is strong when all three timeframes agree.
Short: for a timeframe among TF_main, TF_h1, TF_h2, completed close < its medium-length EMA AND < its long-length EMA (same EMA pairs as the Long line above). Trend is strong when all three timeframes agree.
Long: for a timeframe among TF_main, TF_h1, TF_h2, completed medium-length EMA (EMA_b, H1_short, H2_mid) > the same EMA on the prior completed bar
Short: for a timeframe among TF_main, TF_h1, TF_h2, completed medium-length EMA (EMA_b, H1_short, H2_mid) < the same EMA on the prior completed bar
Long: for a timeframe among TF_main, TF_h1, TF_h2, completed RSI > 50 AND completed StochRSI_K > 50
Short: for a timeframe among TF_main, TF_h1, TF_h2, completed RSI < 50 AND completed StochRSI_K < 50
Long: for a timeframe among TF_main, TF_h1, TF_h2, completed RSI > prior completed RSI
Short: for a timeframe among TF_main, TF_h1, TF_h2, completed RSI < prior completed RSI