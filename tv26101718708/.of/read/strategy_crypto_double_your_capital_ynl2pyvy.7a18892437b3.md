Calculation: HullMA = WMA(2*WMA(close, n/2) - WMA(close, n), round(sqrt(n)))
Calculation: VolOsc = 100*(EMA(volume, short lookback) - EMA(volume, long lookback)) / EMA(volume, long lookback)
Calculation: SRSI = EMA(RSI(close, p), s)
Calculation: QQE trailing line TL: AtrRsi = abs(SRSI[1] - SRSI); dar = f * EMA(EMA(AtrRsi, 2p-1), 2p-1); newLong = SRSI - dar; newShort = SRSI + dar; longband = (SRSI[1] > longband[1] AND SRSI > longband[1]) ? max(longband[1], newLong) : newLong; shortband = (SRSI[1] < shortband[1] AND SRSI < shortband[1]) ? min(shortband[1], newShort) : newShort; trend = 1 if SRSI crosses shortband[1], else -1 if longband[1] crosses SRSI, else previous trend (initially 1); TL = trend == 1 ? longband : shortband
Calculation: QQEupper = SMA(TL - 50, k) + m*stdev(TL - 50, k); QQElower = SMA(TL - 50, k) - m*stdev(TL - 50, k) (m is a constant multiplier)
Calculation: QQEup = (SRSI - 50 > threshold) AND (SRSI - 50 > QQEupper); QQEdown = (SRSI - 50 < -threshold) AND (SRSI - 50 < QQElower)
Calculation: R = (entry price - lowest low over last N bars at entry bar) / entry price for long; (highest high over last N bars at entry bar - entry price) / entry price for short
Long: flat AND close > HullMA AND HullMA > HullMA 2 bars ago AND VolOsc > 0 AND QQEup AND NOT QQEup on previous bar (QQE is computed twice with the same RSI/smoothing parameters; only the factor f differs, and the threshold test above uses SRSI directly)
Short: flat AND close < HullMA 2 bars ago AND HullMA < HullMA 2 bars ago AND VolOsc > 0 AND QQEdown AND NOT QQEdown on previous bar
Exit: long, low <= entry price*(1 - R) (initial stop, whole position, while TP1 not yet reached)
Exit: long, high >= entry price*(1 + t1*R) (close 50% of position, take profit 1)
Exit: long, after high has reached entry price*(1 + t1*R): remaining position exits when low <= entry price OR high >= entry price*(1 + t2*R), with t2 > t1
Exit: short, high >= entry price*(1 + R) (initial stop, whole position, while TP1 not yet reached)
Exit: short, low <= entry price*(1 - t1*R) (close 50% of position, take profit 1)
Exit: short, after low has reached entry price*(1 - t1*R): remaining position exits when high >= entry price OR low <= entry price*(1 - t2*R), with t2 > t1