Calculation: Price-fitted WVF = lowest low over the WVF lookback + EMA(((highest high over the same lookback − close) / max(highest high over that lookback, a positive minimum price increment)) × 100, using the same lookback) × lowest low over that lookback × 0.01.
Calculation: Upper and lower price-fitted WVF levels = lowest low over the WVF lookback + the smoothed WVF before price fitting × an upper or lower multiplier, respectively, × lowest low over that lookback × 0.01; the upper multiplier is greater than the lower multiplier.
Calculation: Power score = round((trend power + RSI power + WVF power + volume power + 4) / 8 × 100), where trend power is 1 if the shorter-period close EMA > the longer-period close EMA and −1 otherwise; RSI power is 1 if RSI > its bullish threshold, −1 if RSI < its bearish threshold, and 0 otherwise; WVF power is 1 if close > price-fitted WVF and −1 otherwise; volume power is 0 if volume ≤ its SMA, 1 if volume > its SMA AND close > open, and −1 if volume > its SMA AND close ≤ open. The bullish RSI threshold is greater than the bearish RSI threshold.
Long: close > price-fitted WVF.
Short: close ≤ price-fitted WVF.
Long: power score ≥ its bullish threshold.
Short: power score ≤ its bearish threshold.
Long: shorter-period close EMA > longer-period close EMA.
Short: shorter-period close EMA ≤ longer-period close EMA.
Long: RSI > its bullish threshold.
Short: RSI < its bearish threshold.
Long: price-fitted WVF > its previous-bar value.
Short: price-fitted WVF ≤ its previous-bar value.
Long: a pivot low is confirmed using its left and right lookbacks.
Short: a pivot high is confirmed using its left and right lookbacks.
Long: close > upper price-fitted WVF level AND previous close ≤ previous upper price-fitted WVF level.
Short: close < lower price-fitted WVF level AND previous close ≥ previous lower price-fitted WVF level.