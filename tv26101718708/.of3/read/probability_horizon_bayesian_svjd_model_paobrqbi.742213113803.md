Calculation: Log return = ln(close / close[1])
Calculation: K = KAMA(close, KAMA lookback, fast parameter, slow parameter)
Calculation: Realized volatility = STDEV(Log return, volatility lookback)
Calculation: KAMA-trend P(up) = 0.5 + sign((K - K[slope lookback]) / close) × probability offset parameter × min(1, abs((K - K[slope lookback]) / close) × trend strength parameter)
Calculation: Z-score mean-reversion P(up) = 0.5 + probability offset parameter × min(1, abs(z-score(close - K, z-score lookback)) / strength saturation parameter) when the z-score is below the negative activation threshold; subtract that amount when above the positive activation threshold; otherwise 0.5
Calculation: Haar-wavelet trend P(up) = 0.5 plus or minus probability offset parameter × min(1, abs(normalized slope of the selected Haar trend) × strength parameter), with direction set by whether that slope is above the positive threshold or below the negative threshold; otherwise 0.5
Calculation: Kalman-adaptive P(up) = 0.5 plus or minus probability offset parameter × min(1, abs(normalized slope of Kalman-filtered close) × strength parameter), with direction set by whether that slope is above the positive threshold or below the negative threshold; otherwise 0.5
Calculation: Hamilton P(up) = clamp(0.5 + probability offset parameter × (P(bull) - P(bear)), lower probability bound, upper probability bound) from the Hamilton 3-state Gaussian regime model; use 0.5 when disabled or below its activation timeframe
Calculation: Bayesian P(up) = weighted mean of the five model probabilities; initialize weights equally, and after the evaluation horizon update each weight by multiplying it by exp(-learning-rate parameter × binary log loss against whether close exceeded the forecast close), apply the minimum-weight parameter, then renormalize; use 0.5 when disabled
Calculation: Hawkes-adjusted P(up) = 0.5 + (Bayesian P(up) - 0.5) × (1 - modifier), where event is abs(Log return) above an event threshold parameter times Realized volatility, intensity = prior intensity × exp(-decay parameter) + event × excitation parameter, modifier is zero when intensity / SMA(event, baseline lookback) is at or below the warning threshold, and otherwise is the lesser of a cap parameter and (ratio - warning threshold) / warning threshold
Calculation: Calibrated P(up) = 0.5 + (Hawkes-adjusted P(up) - 0.5) × shrinkage; bin forecasts by abs(P(up) - 0.5) using calibration-bin boundary parameters, and when calibration and the ensemble are enabled and a bin has at least the minimum sample parameter, set shrinkage to max(shrinkage floor parameter, actual directional hit rate / predicted bin midpoint) if hit rate is below that midpoint, otherwise 1
Calculation: Hamilton dominant state = Bull when P(bull) exceeds both P(bear) and P(range), Bear when P(bear) exceeds P(range), otherwise Range
Long: KAMA-trend P(up) > 0.5
Short: KAMA-trend P(up) < 0.5
Long: Z-score mean-reversion P(up) > 0.5
Short: Z-score mean-reversion P(up) < 0.5
Long: Haar-wavelet trend P(up) > 0.5
Short: Haar-wavelet trend P(up) < 0.5
Long: Kalman-adaptive P(up) > 0.5
Short: Kalman-adaptive P(up) < 0.5
Long: Hamilton P(up) > 0.5
Short: Hamilton P(up) < 0.5
Long: Calibrated P(up) > 0.5 + neutral probability margin
Short: Calibrated P(up) < 0.5 - neutral probability margin
Long: Calibrated P(up) > 0.5 + neutral probability margin AND Calibrated P(up) >= minimum Bayesian probability
Short: Calibrated P(up) < 0.5 - neutral probability margin AND Calibrated P(up) <= 1 - minimum Bayesian probability
Long: Bayesian ensemble enabled AND Calibrated P(up) crosses above minimum Bayesian probability
Short: Bayesian ensemble enabled AND Calibrated P(up) crosses below 1 - minimum Bayesian probability
Long: conjunction filter enabled AND Bayesian ensemble enabled AND at least three of the five model probabilities are above 0.5 AND Calibrated P(up) >= minimum Bayesian probability AND NOT (at least three previous-bar model probabilities were above 0.5 AND previous-bar Calibrated P(up) >= minimum Bayesian probability)
Short: conjunction filter enabled AND Bayesian ensemble enabled AND at least three of the five model probabilities are below 0.5 AND Calibrated P(up) <= 1 - minimum Bayesian probability AND NOT (at least three previous-bar model probabilities were below 0.5 AND previous-bar Calibrated P(up) <= 1 - minimum Bayesian probability)
Long: Hamilton active AND Hamilton dominant state is Bull
Short: Hamilton active AND Hamilton dominant state is Bear
Long: Hamilton enabled AND Hamilton active AND Hamilton dominant state is Bull AND previous-bar Hamilton dominant state is not Bull
Short: Hamilton enabled AND Hamilton active AND Hamilton dominant state is Bear AND previous-bar Hamilton dominant state is not Bear
Long: Realized volatility is below its lower percentile over the volatility-regime lookback AND SMA(Log return, regime lookback) / (STDEV(Log return, regime lookback) / sqrt(regime lookback)) exceeds the positive return t-statistic threshold
Short: Realized volatility is below its lower percentile over the volatility-regime lookback AND SMA(Log return, regime lookback) / (STDEV(Log return, regime lookback) / sqrt(regime lookback)) is below the negative return t-statistic threshold