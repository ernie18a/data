Calculation: Selected oscillator = configured RSI, 3-bar-smoothed Stochastic %K, MACD histogram, CCI, MFI, rate of change, Williams %R, OBV, or external oscillator plot.
Calculation: Confirmed pivot low/high = a local low/high using configured left and right bars, available only after the right bars have closed; evaluate signals at that confirmation bar using the pivot bar’s low/high and oscillator value.
Calculation: Oscillator range = highest selected oscillator − lowest selected oscillator over the configured normalization lookback.
Calculation: Oscillator rank = percentile rank of the selected oscillator over the configured normalization lookback.
Calculation: Pivot pair = a new confirmed pivot P2 and a stored earlier pivot P1 of the same kind, separated by at least the configured minimum and at most the configured maximum bars; scan only the configured maximum number of stored pivots.
Calculation: Regular bullish = P2 low < P1 low AND P2 oscillator > P1 oscillator.
Calculation: Regular bearish = P2 high > P1 high AND P2 oscillator < P1 oscillator.
Calculation: Hidden bullish = P2 low > P1 low AND P2 oscillator < P1 oscillator.
Calculation: Hidden bearish = P2 high < P1 high AND P2 oscillator > P1 oscillator.
Calculation: Oscillator divergence size = absolute difference between P2 and P1 oscillator values.
Calculation: Price separation = absolute difference between P2 and P1 prices.
Calculation: Bullish swing = highest intervening high − greater of P1 and P2 lows.
Calculation: Bearish swing = lesser of P1 and P2 highs − lowest intervening low.
Calculation: Clean bullish line of sight = every intervening low and oscillator value is greater than or equal to its value on the straight P1-to-P2 line.
Calculation: Clean bearish line of sight = every intervening high and oscillator value is less than or equal to its value on the straight P1-to-P2 line.
Calculation: Regular score = 100 × (0.40 × min(oscillator divergence size / (0.25 × oscillator range), 1) + 0.25 × zone depth + 0.20 × min(swing / (2 × ATR), 1) + 0.15 × min(price separation / (2 × ATR), 1)); bullish zone depth = max(0, (25 − P1 oscillator rank) / 25), bearish zone depth = max(0, (P1 oscillator rank − 75) / 25).
Calculation: Hidden score = 100 × (0.50 × min(oscillator divergence size / (0.25 × oscillator range), 1) + 0.30 × min(swing / (2 × ATR), 1) + 0.20 × min(price separation / (2 × ATR), 1)).
Calculation: Regular pair qualifies = configured regular type is enabled AND oscillator divergence size >= configured minimum percentage of oscillator range AND price separation >= configured minimum ATR multiple AND (zone filter is off OR (adaptive bullish: P1 rank <= configured outer percentile AND P2 rank <= configured outer percentile OR adaptive bearish: P1 rank >= 100 minus configured outer percentile AND P2 rank >= 100 minus configured outer percentile OR fixed bullish: P1 oscillator < configured oversold level AND P2 oscillator < configured oversold level OR fixed bearish: P1 oscillator > configured overbought level AND P2 oscillator > configured overbought level)) AND (line-of-sight filter is off OR corresponding clean line of sight) AND swing >= configured minimum ATR multiple AND regular score >= configured minimum score.
Calculation: Hidden pair qualifies = configured hidden type is enabled AND oscillator divergence size >= configured minimum percentage of oscillator range AND price separation >= configured minimum ATR multiple AND (line-of-sight filter is off OR corresponding clean line of sight) AND swing >= configured minimum ATR multiple AND hidden score >= configured minimum score.
Calculation: Signal pair = among qualifying P1s for each new P2 and divergence type, select the configured best-scoring P1 or the most recent qualifying P1; emit at most one signal per type and P2.
Long: confirmed pivot low AND (selected signal pair is regular bullish OR selected signal pair is hidden bullish).
Short: confirmed pivot high AND (selected signal pair is regular bearish OR selected signal pair is hidden bearish).