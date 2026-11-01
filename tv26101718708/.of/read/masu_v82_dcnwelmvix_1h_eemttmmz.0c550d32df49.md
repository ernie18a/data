Calculation: Gaussian ribbon = eight endpoint Gaussian-weighted averages of the selected price source over the same lookback, with progressively increasing bandwidths; weight at lag i is exp(-0.5 × (i / bandwidth)²). Optionally multiply all bandwidths by the ratio of ATR/close to its longer-lookback SMA, clamped between lower and upper bounds.
Calculation: Bullish ribbon count = number of adjacent ribbon pairs for which the shorter-bandwidth average is greater than the longer-bandwidth average; bearish ribbon count uses less than.
Calculation: Daily VWAP = cumulative sum of volume × (high + low + close) / 3 divided by cumulative volume, reset at each new day; use close when cumulative volume is zero.
Calculation: Cumulative volume delta = cumulative sum of volume on bars with close > open minus volume on bars with close < open. Buy/sell volume ratio = volume on an up bar, otherwise zero, divided by the greater of one and volume on a down bar, otherwise zero.
Calculation: Bullish order block = close > open AND previous close < previous open AND high - close < a fraction of high - low. Bearish order block = close < open AND previous close > previous open AND close - low < a fraction of high - low.
Calculation: Bullish fair value gap = low > high two bars ago AND low - high two bars ago > an ATR multiple. Bearish fair value gap = high < low two bars ago AND low two bars ago - high > an ATR multiple.
Calculation: Bullish liquidity sweep = low < lowest low over the preceding lookback AND close > open AND close > that preceding lowest low. Bearish liquidity sweep = high > highest high over the preceding lookback AND close < open AND close < that preceding highest high.
Calculation: Confirmed pivot high or low = a high or low at a bar with the required number of bars on each side; the pivot becomes available only after the right-hand bars complete. Bullish structure break = close > latest confirmed pivot high AND previous close <= that same pivot high. Bearish structure break = close < latest confirmed pivot low AND previous close >= that same pivot low.
Calculation: Neural probability = logistic transform of a clamped weighted sum of normalized features and a bias. The features are RSI, rate of change, (close - long-period EMA) / close, ADX, shortest-bandwidth ribbon slope divided by that ribbon value, bullish minus bearish ribbon count, and volume divided by its SMA. Clamp each feature's linear normalization to its parameterized range. Initialize weights and bias as parameters; on each completed bar, use features from the target lookback and target 1 if close > close at that lookback, otherwise 0. Compute the prediction using the current weights and those historical features, then update each weight to decay × weight + learning rate × (target - prediction) × historical feature and update the bias similarly without a feature multiplier. Compute the current probability using the updated weights and current features.
Long: bullish order block.
Short: bearish order block.
Long: bullish fair value gap.
Short: bearish fair value gap.
Long: bullish liquidity sweep.
Short: bearish liquidity sweep.
Long: bullish structure break.
Short: bearish structure break.
Long: bullish ribbon count >= ribbon threshold.
Short: bullish ribbon count < ribbon threshold AND bearish ribbon count >= ribbon threshold.
Long: neural probability > upper confidence threshold.
Short: neural probability <= upper confidence threshold AND neural probability < lower confidence threshold.
Long: close > daily VWAP AND ((cumulative volume delta > its SMA AND cumulative volume delta > its previous value) OR buy/sell volume ratio > an upper threshold).
Short: close < daily VWAP AND ((cumulative volume delta < its SMA AND cumulative volume delta < its previous value) OR buy/sell volume ratio < a lower threshold).
Long: close > daily VWAP.
Short: close <= daily VWAP.
Exit: long, low <= the stop fixed on the entry-signal bar, where the stop is that bar's lower Donchian boundary OR that bar's close minus ATR times the selected regime stop multiplier.
Exit: short, high >= the stop fixed on the entry-signal bar, where the stop is that bar's upper Donchian boundary OR that bar's close plus ATR times the selected regime stop multiplier.
Exit: long, high >= entry-signal close + entry-signal ATR × partial-profit multiplier; exit the configured fraction of the position.
Exit: short, low <= entry-signal close - entry-signal ATR × partial-profit multiplier; exit the configured fraction of the position.
Exit: long, trailing disabled AND high >= entry-signal close + entry-signal ATR × regime target multiplier.
Exit: short, trailing disabled AND low <= entry-signal close - entry-signal ATR × regime target multiplier.