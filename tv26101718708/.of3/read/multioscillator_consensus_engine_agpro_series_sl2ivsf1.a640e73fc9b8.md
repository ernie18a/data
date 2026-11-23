Calculation: norm(x, n) = 100 * (x - lowest(x, n)) / (highest(x, n) - lowest(x, n)), or 50 if highest(x, n) equals lowest(x, n)
Calculation: DI balance(n) = 100 * DI+(n) / (DI+(n) + DI-(n)), or 50 if DI+(n) + DI-(n) equals 0
Calculation: Aroon balance(n) = (Aroon Up(high, n) - Aroon Down(low, n) + 100) / 2
Calculation: osc = {RSI(close, RSI length), Stochastic %K(high, low, close, Stochastic length), norm(CCI(close, CCI length), 2 * CCI length), MFI((high + low + close) / 3, volume, MFI length), Williams %R(high, low, close, Williams %R length) + 100, norm(ROC(close, ROC length), 2 * ROC length), Ultimate Oscillator(high, low, close, Ultimate fast length, Ultimate mid length, Ultimate slow length), norm(MACD histogram(close, MACD fast length, MACD slow length, MACD signal length), 2 * MACD slow length), DI balance(DMI length), Aroon balance(Aroon length)}, where Ultimate fast length < Ultimate mid length < Ultimate slow length
Calculation: bull count = number of values in osc that are >= bullish threshold
Calculation: bear count = number of values in osc that are <= bearish threshold, where bearish threshold < bullish threshold
Calculation: agreement = 10 * max(bull count, bear count)
Calculation: regime = bull if bull count >= consensus count, else bear if bear count >= consensus count, else divergent if abs(bull count - bear count) <= divergence band, else transition
Calculation: streak = streak[1] + 1 if regime == regime[1], else 1
Calculation: zone(side) = interval from close - h to close + h, where h = ATR(zone ATR length) * zone height multiplier, both taken at the most recent bar where regime == side and regime[1] != side
Calculation: last extreme side = bull if bull count >= bear count, else bear, taken at the most recent bar where agreement >= extreme agreement level AND agreement[1] < extreme agreement level
Long: regime == bull AND regime[1] != bull
Short: regime == bear AND regime[1] != bear
Long: agreement >= extreme agreement level AND agreement[1] < extreme agreement level AND bull count >= bear count
Short: agreement >= extreme agreement level AND agreement[1] < extreme agreement level AND bull count < bear count
Exit: long, regime == divergent OR regime == transition
Exit: short, regime == divergent OR regime == transition
Long: regime == bull AND streak > streak threshold AND low <= upper bound of zone(bull) AND high >= lower bound of zone(bull)
Short: regime == bear AND streak > streak threshold AND low <= upper bound of zone(bear) AND high >= lower bound of zone(bear)
Long: regime == bull AND regime[1] == bull AND regime[2] == bear AND last extreme side == bear
Short: regime == bear AND regime[1] == bear AND regime[2] == bull AND last extreme side == bull