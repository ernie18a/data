Calculation: Sine projection for each Tn = close of the current Tn bar, sampled on chart bars (developing in realtime and mapped historical close on historical bars) + ATR on chart bars with the sine-amplitude ATR lookback × sine-amplitude multiplier × sin(2π × chart-bar index / the separate sine-period parameter for Tn + the separate phase parameter for Tn), for T1 through T8
Calculation: Timeframe up-count = number of the eight sine projections greater than their respective values on the previous chart bar
Calculation: Composite = arithmetic mean of the eight sine projections
Calculation: GAN up-count = number of eight Linear Regression(close, separate GAN lookback parameter, offset 0) values greater than their respective values on the previous chart bar
Calculation: Merged volume = sum of volume over the current and preceding chart bars in the merge lookback
Calculation: Signed merged volume = merged volume when close > open[merge lookback − 1], negative merged volume when close < open[merge lookback − 1], otherwise zero
Calculation: Merged OBV step = merged volume when close > close[1], negative merged volume when close < close[1], otherwise zero
Calculation: Rolling normalization(x) = (x − Lowest(x, normalization lookback)) / (Highest(x, normalization lookback) − Lowest(x, normalization lookback)), or 0.5 when the highest equals the lowest
Calculation: Volume fusion = mean(Rolling normalization(EMA(signed merged volume, volume smoothing lookback)), Rolling normalization(EMA(cumulative sum of signed merged volume, volume trend lookback)), Rolling normalization(EMA(cumulative sum of merged OBV step, volume trend lookback)))
Calculation: Power score = round(sine weight × (timeframe up-count / 8 × score scale) + GAN weight × (GAN up-count / 8 × score scale) + trend weight × trend score + volume weight × volume score + RSI weight × RSI score + ATR weight × ATR score), where trend score is maximum score if close > EMA(close, trend lookback), minimum score if close < that EMA, otherwise neutral score; RSI score is maximum score if RSI(close, RSI lookback) ≥ RSI score upper threshold, minimum score if it ≤ RSI score lower threshold, otherwise neutral score; volume score is maximum score on crossover(Volume fusion, Highest(Volume fusion, fusion support-resistance lookback)[1]), minimum score on crossunder(Volume fusion, Lowest(Volume fusion, fusion support-resistance lookback)[1]), high-flow score if Volume fusion > EMA(Volume fusion, volume smoothing lookback), low-flow score if it is below that EMA, otherwise neutral score, in that priority order; ATR score is maximum score if ATR(close, score ATR lookback) > SMA(ATR(close, score ATR lookback), ATR averaging lookback) and close > open, minimum score if that ATR exceeds its average and close < open, otherwise neutral score
Long: Composite > its value on the previous chart bar
Short: Composite ≤ its value on the previous chart bar
Long: Timeframe up-count ≥ timeframe alignment threshold
Short: 8 − timeframe up-count ≥ timeframe alignment threshold
Long: GAN up-count ≥ GAN alignment threshold
Short: 8 − GAN up-count ≥ GAN alignment threshold
Long: close > EMA(close, trend lookback)
Short: close ≤ EMA(close, trend lookback)
Long: RSI(close, RSI lookback) > RSI bullish display threshold
Short: RSI(close, RSI lookback) < RSI bearish display threshold
Long: crossover(Volume fusion, Highest(Volume fusion, fusion support-resistance lookback)[1])
Short: crossunder(Volume fusion, Lowest(Volume fusion, fusion support-resistance lookback)[1])
Long: not crossover(Volume fusion, Highest(Volume fusion, fusion support-resistance lookback)[1]) AND not crossunder(Volume fusion, Lowest(Volume fusion, fusion support-resistance lookback)[1]) AND Volume fusion > EMA(Volume fusion, volume smoothing lookback)
Short: not crossover(Volume fusion, Highest(Volume fusion, fusion support-resistance lookback)[1]) AND not crossunder(Volume fusion, Lowest(Volume fusion, fusion support-resistance lookback)[1]) AND Volume fusion < EMA(Volume fusion, volume smoothing lookback)
Long: Power score ≥ buy score threshold
Short: Power score ≤ sell score threshold
Long: Power score ≥ buy score threshold AND Composite > its value on the previous chart bar AND close > EMA(close, trend lookback) AND GAN up-count ≥ GAN alignment threshold AND not crossunder(Volume fusion, Lowest(Volume fusion, fusion support-resistance lookback)[1]) AND position side is not long
Short: Power score ≤ sell score threshold AND Composite ≤ its value on the previous chart bar AND close < EMA(close, trend lookback) AND 8 − GAN up-count ≥ GAN alignment threshold AND not crossover(Volume fusion, Highest(Volume fusion, fusion support-resistance lookback)[1]) AND position side is not short