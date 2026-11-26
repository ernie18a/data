Calculation: RSI = RSI(price source, RSI length)
Calculation: Fast RSI = RSI(price source, fast RSI length), where fast RSI length = half of RSI length
Calculation: Slow RSI = RSI(price source, slow RSI length), where slow RSI length = twice RSI length
Calculation: T1 RSI = RSI(close, RSI length) computed on T1 bars, taken from the last completed T1 bar
Calculation: ATR = ATR(ATR length)
Calculation: Features = [RSI, RSI - RSI[slope lag], (RSI - RSI[slope lag]) - (RSI[slope lag] - RSI[2 * slope lag]), Fast RSI - Slow RSI, PercentRank(RSI, RSI percentile window), StDev(RSI, RSI volatility window), T1 RSI, (price source - EMA(price source, trend length)) / ATR, ADX(ADX length), PercentRank(ATR, ATR percentile window)]
Calculation: Standardized Features = (Features - running mean) / sqrt(running variance), where running mean = EMA(Features, normalization window) and running variance = exponentially weighted variance of Features with the same smoothing factor, both updated on each confirmed bar before use
Calculation: Label = 2 if price source - price source[forecast horizon] > move threshold factor * ATR[forecast horizon]; 0 if price source - price source[forecast horizon] < -move threshold factor * ATR[forecast horizon]; otherwise 1
Calculation: Stored samples = newest-first list of (Features[forecast horizon], Label) pairs, one appended on each confirmed bar whose bar count exceeds forecast horizon + feature warm-up length and whose Features[forecast horizon] are all finite; the oldest pair is dropped beyond memory capacity
Calculation: Weights = Weights[1] trained, if the number of Stored samples >= minimum training samples, by training passes per bar over the newest replay batch size entries of Stored samples, each pass applying one Adam update (learning rate, Adam beta1, Adam beta2, L2 penalty) per entry, using the gradient of cross-entropy loss of a softmax-over-3-classes network with a tanh hidden layer of hidden units, evaluated on the entry's stored Features standardized with current running statistics against its Label; initial Weights are fixed pseudo-random values with zero Adam state
Calculation: Conviction = 50 + 50 * (P(up) - P(down)), where P(down), P(neutral), P(up) = softmax(W2 * tanh(W1 * Standardized Features + b1) + b2), with W1, b1, W2, b2 from Weights
Calculation: Ready = (number of pairs ever appended to Stored samples) >= warm-up count
Calculation: Reference level = midpoint if fixed-center option, else EMA(Conviction, adaptive lookback) seeded at midpoint
Calculation: Direction = 0 if abs(Conviction - Reference level) < neutral band; +1 if Conviction > Reference level; otherwise -1
Long: Ready AND Direction = +1
Long: Direction = +1 AND Direction[1] != +1
Short: Ready AND Direction = -1
Short: Direction = -1 AND Direction[1] != -1
Exit: long, Ready AND Direction = 0
Exit: short, Ready AND Direction = 0