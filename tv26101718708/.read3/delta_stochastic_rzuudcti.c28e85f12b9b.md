Calculation: K = StochRSI(close, fast RSI lookback, fast stochastic lookback, fast K smoothing) OR SMA(Stochastic(close, high, low, standard stochastic lookback), standard K smoothing) OR StochRSI(close, slow RSI lookback, slow stochastic lookback, slow K smoothing)
Calculation: D = SMA(K, the selected variant's D smoothing lookback)
Calculation: Oscillator = SMA(K, divergence smoothing lookback)
Calculation: Momentum RSI = RSI(close, RSI lookback)
Calculation: Indicator(condition) = 1 when condition is true, otherwise 0
Calculation: Raw long cross = crosses above K and D AND K <= oversold threshold + zone tolerance AND (trend filter disabled OR close > EMA(close, trend EMA lookback))
Calculation: Raw short cross = crosses below K and D AND K >= overbought threshold - zone tolerance AND (trend filter disabled OR close < EMA(close, trend EMA lookback))
Calculation: Long signal = Raw long cross AND (cooldown disabled OR no prior Raw long cross OR bars since Raw long cross[1] > signal cooldown)
Calculation: Short signal = Raw short cross AND (cooldown disabled OR no prior Raw short cross OR bars since Raw short cross[1] > signal cooldown)
Calculation: Bullish divergence = confirmed pivot low of Oscillator AND bars since previous confirmed pivot low is between minimum and maximum divergence range AND (low at current pivot < low at previous pivot AND Oscillator at current pivot > Oscillator at previous pivot OR low at current pivot > low at previous pivot AND Oscillator at current pivot < Oscillator at previous pivot)
Calculation: Bearish divergence = confirmed pivot high of Oscillator AND bars since previous confirmed pivot high is between minimum and maximum divergence range AND (high at current pivot > high at previous pivot AND Oscillator at current pivot < Oscillator at previous pivot OR high at current pivot < high at previous pivot AND Oscillator at current pivot > Oscillator at previous pivot)
Calculation: Strong long signal = strong signal enabled AND Long signal AND bars since Bullish divergence <= strong signal window
Calculation: Strong short signal = strong signal enabled AND Short signal AND bars since Bearish divergence <= strong signal window
Calculation: Long score = base score weight * (Indicator(K > D) + Indicator(K > D AND K - K[1] > K momentum threshold) + Indicator(K <= oversold threshold) + Indicator(K > D AND K > midline) + Indicator(Momentum RSI - Momentum RSI[1] > RSI momentum threshold) + Indicator(external stochastic K enabled AND external stochastic K > external stochastic K[1]) + Indicator(external stochastic K enabled AND external stochastic K > midline) + Indicator(external stochastic K enabled AND external stochastic K < external oversold threshold)) + ordinary signal weight * Indicator(Long signal AND NOT Strong long signal) + strong signal weight * Indicator(Strong long signal) + divergence weight * Indicator(Bullish divergence)
Calculation: Short score = base score weight * (Indicator(K < D) + Indicator(K < D AND K - K[1] < -K momentum threshold) + Indicator(K >= overbought threshold) + Indicator(K < D AND K < midline) + Indicator(Momentum RSI - Momentum RSI[1] < -RSI momentum threshold) + Indicator(external stochastic K enabled AND external stochastic K < external stochastic K[1]) + Indicator(external stochastic K enabled AND external stochastic K < midline) + Indicator(external stochastic K enabled AND external stochastic K > external overbought threshold)) + ordinary signal weight * Indicator(Short signal AND NOT Strong short signal) + strong signal weight * Indicator(Strong short signal) + divergence weight * Indicator(Bearish divergence)
Calculation: Net score = Long score - Short score
Long: Long signal
Short: Short signal
Long: Bullish divergence
Short: Bearish divergence
Long: K <= oversold threshold OR (K color mode is Momentum AND K > D AND K - K[1] > K momentum threshold)
Short: K >= overbought threshold OR (K color mode is Momentum AND K < D AND K - K[1] < -K momentum threshold)
Long: K > D AND K > midline
Short: K < D AND K < midline
Long: (K color mode is Momentum AND Momentum RSI - Momentum RSI[1] > RSI momentum threshold) OR (K color mode is Zone AND Momentum RSI <= RSI oversold threshold)
Short: (K color mode is Momentum AND Momentum RSI - Momentum RSI[1] < -RSI momentum threshold) OR (K color mode is Zone AND Momentum RSI >= RSI overbought threshold)
Long: Net score > score color threshold
Short: Net score < -score color threshold
Long: Long score > Short score
Short: Short score > Long score
Long: count of Long signals in the current T1 period > count of Short signals in the current T1 period
Short: count of Short signals in the current T1 period > count of Long signals in the current T1 period