Calculation: RSI = Relative Strength Index of close
Calculation: RSI pivot low = confirmed local minimum of RSI using configurable left and right lookbacks
Calculation: RSI pivot high = confirmed local maximum of RSI using configurable left and right lookbacks
Long: a confirmed RSI pivot low is higher than the previous RSI pivot low AND its corresponding price low is lower than the previous price low AND the pivot separation is within the configured minimum and maximum
Short: a confirmed RSI pivot high is lower than the previous RSI pivot high AND its corresponding price high is higher than the previous price high AND the pivot separation is within the configured minimum and maximum
Long: bullish divergence AND no simultaneous bearish divergence AND the selected trend filter permits longs AND no position is active AND no position closed on this bar AND ATR is available and greater than zero
Short: bearish divergence AND no simultaneous bullish divergence AND the selected trend filter permits shorts AND no position is active AND no position closed on this bar AND ATR is available and greater than zero
Calculation: risk distance = ATR at entry × configurable stop-loss multiplier
Calculation: target distance = risk distance × configurable target R
Exit: long, on a bar after entry, low ≤ entry price − risk distance OR high ≥ entry price + target distance
Exit: short, on a bar after entry, high ≥ entry price + risk distance OR low ≤ entry price − target distance