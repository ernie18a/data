Calculation: Low-lag filter = selectable Super Smoother, Ultimate Smoother, or Chebyshev Type-I filter. For input x and length L, initialize unavailable prior outputs to x. Super Smoother: f=sqrt(2)*pi/L, a=exp(-f), c2=2*a*cos(f), c3=-a*a, c1=1-c2-c3; y=c1*(x+x[1])/2+c2*y[1]+c3*y[2]. Ultimate Smoother: a=exp(-sqrt(2)*pi/L), c2=2*a*cos(sqrt(2)*pi/L), c3=-a*a, c1=(1+c2-c3)/4; y=(1-c1)*x+(2*c1-c2)*x[1]-(c1+c3)*x[2]+c2*y[1]+c3*y[2]. Chebyshev: A=cosh(acosh(1/(1-ripple))/L), B=sinh(asinh(1/ripple)/L), g=(A-B)/(A+B); y=(1-g)*x+g*y[1]. Use the same selected filter throughout.
Calculation: Momentum = low-lag filter of the rolling z-score of close minus the current endpoint of a linear regression of close over the momentum lookback. A zero rolling standard deviation produces zero.
Calculation: Flow = exponential recursive smoothing, initialized with its input, of the rolling z-score of HMA(signed volume)/max(HMA(volume), epsilon), where signed volume is volume if close exceeds close two bars ago and negative volume otherwise; both HMAs use the same volume lookback. The z-score uses a separate normalization lookback and is zero when its standard deviation is zero.
Calculation: Oscillator = 50 times the low-lag filter of the weighted average of momentum and the low-lag-filtered flow; both use the momentum smoothing length. Signal = the low-lag filter of oscillator with a separate signal length.
Calculation: Oscillator bands = rolling SMA of oscillator plus or minus a sensitivity multiplier times its rolling standard deviation over the same band lookback.
Calculation: Fast wave = 100*tanh(0.33*F/SD(F)), where F is the low-lag filter of 50*flow using a fast ribbon length and SD(F) is its rolling standard deviation over a separate normalization lookback; use zero when SD(F) is not positive. Slow wave uses the same formula and fast-wave standard deviation, replacing F in the numerator with the low-lag filter of 50*flow using a longer ribbon length.
Calculation: Fan rank = sum over every pair of close EMAs with increasing, equally spaced lengths, adding one when the shorter EMA exceeds the longer EMA and subtracting one otherwise. Initialize each EMA at the first close.
Calculation: Higher-timeframe bias = higher-timeframe close minus its EMA using the momentum lookback, evaluated on the last completed higher-timeframe bar. If higher-timeframe confirmation is disabled, use oscillator instead.
Calculation: Confluence score = 100 times the fraction of these seven conditions that are true: oscillator > 0; oscillator > signal; flow > 0; fan rank > 0; close > session VWAP of typical price, or momentum's unsmoothed z-score > 0 if VWAP is unavailable; close > close one momentum lookback ago; higher-timeframe bias > 0.
Calculation: Efficiency ratio = absolute change in close over its lookback divided by the sum of absolute one-bar close changes over that lookback; use zero when the denominator is zero.
Calculation: Confirmed oscillator pivot = an oscillator pivot high or low with equal left and right lookbacks, identified on the bar that completes the right lookback. Compare each confirmed pivot with the immediately preceding confirmed pivot of the same kind, using high or low at the respective pivot bars and their bar-index distance.
Long: oscillator crosses above signal AND oscillator < lower oscillator band AND confluence score >= signal threshold AND efficiency ratio >= chop threshold AND fast wave < positive wave-extreme threshold.
Short: oscillator crosses below signal AND oscillator > upper oscillator band AND confluence score <= 100 minus signal threshold AND efficiency ratio >= chop threshold AND fast wave > negative wave-extreme threshold.
Long: volume > its SMA times a climax multiplier AND oscillator < lower oscillator band.
Short: volume > its SMA times a climax multiplier AND oscillator > upper oscillator band.
Long: a low pivot is confirmed AND pivot distance <= maximum distance AND ((current pivot low < previous pivot low AND current oscillator pivot > previous oscillator pivot) OR (current pivot low > previous pivot low AND current oscillator pivot < previous oscillator pivot)).
Short: a high pivot is confirmed AND pivot distance <= maximum distance AND ((current pivot high > previous pivot high AND current oscillator pivot < previous oscillator pivot) OR (current pivot high < previous pivot high AND current oscillator pivot > previous oscillator pivot)).
Long: efficiency ratio >= chop threshold AND confluence score >= signal threshold.
Short: efficiency ratio >= chop threshold AND confluence score <= 100 minus signal threshold.
Long: confluence score > bullish trend threshold.
Short: confluence score < bearish trend threshold.
Long: confluence score >= strong bullish threshold.
Short: confluence score <= strong bearish threshold.
Long: fast wave >= slow wave.
Short: fast wave < slow wave.
Long: oscillator >= 0.
Short: oscillator < 0.
Long: flow > 0.
Short: flow <= 0.
Long: higher-timeframe bias > 0.
Short: higher-timeframe bias <= 0.
Long: oscillator < lower oscillator band.
Short: oscillator > upper oscillator band.