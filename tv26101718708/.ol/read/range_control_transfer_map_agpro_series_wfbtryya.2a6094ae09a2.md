Calculation: ATR = average true range.
Calculation: Range high/low = highest high / lowest low over the range lookback, including the current bar; range height = range high − range low.
Calculation: Mature range = range height / ATR is within the configured minimum and effective maximum, and the combined count of upper-edge and lower-edge touches over the range lookback meets the configured minimum. A touch is a bar whose high is within the configured ATR tolerance of the range high or whose low is within that tolerance of the range low; the effective maximum may be multiplied by the configured intraday multiplier on intraday charts.
Calculation: Control band = range midpoint ± configured ATR multiple × ATR.
Calculation: Candle body/range ratio = |close − open| / max(high − low, minimum tick size).
Calculation: Transfer quality = rounded, clamped 0–100 weighted score: 40% range health + 32% body score + 28% volume score. Range health weights height balance 38%, edge-touch score 34%, and closeness of close to range midpoint 28%; body score is body/range ratio relative to its configured minimum; volume score is current volume relative to its moving average and configured confirmation ratio. The moving average uses a longer lookback than the range lookback only if configured that way.
Calculation: Buyer-control transfer = mature range AND close above the control band AND body/range ratio meets its configured minimum AND prior active control side is 0 or seller AND transfer quality meets max(configured minimum transfer score − 12, 1).
Calculation: Seller-control transfer = mature range AND close below the control band AND body/range ratio meets its configured minimum AND prior active control side is 0 or buyer AND transfer quality meets max(configured minimum transfer score − 12, 1).
Calculation: Buyer-edge reaction = mature range AND high is within the configured ATR tolerance of range high? No: within tolerance of range low AND close > open AND close above range low + tolerance × ATR.
Calculation: Seller-edge reaction = mature range AND high is within the configured ATR tolerance of range high AND close < open AND close below range high − tolerance × ATR.
Long: Buyer-control transfer OR buyer-edge reaction.
Short: Seller-control transfer OR seller-edge reaction.
Exit: long, prior active control side is buyer AND close < control band bottom − configured failure-buffer ATR × ATR.
Exit: short, prior active control side is seller AND close > control band top + configured failure-buffer ATR × ATR.