Calculation: Momentum Z-score = (current close change − its 50-bar average) ÷ the 50-bar standard deviation of close changes
Calculation: Confirmed pivot high/low = swing high/low with the specified lookback number of bars on both sides; use the latest confirmed pivot
Calculation: Bullish/bearish order block = high-to-low range of the nearest bearish/bullish candle among the previous 10 bars at a bullish/bearish market-structure break; if none exists, use the current bar
Calculation: A bullish/bearish order block is mitigated when a later bar’s low is below its bottom / high is above its top; retain it as active until then
Calculation: Dynamic long stop = after close reaches entry price plus the break-even distance, set to the greater of its previous value and close minus 2.5 × ATR(14); initialize to entry price and reset when flat
Calculation: Dynamic short stop = after close reaches entry price minus the break-even distance, set to the lesser of its previous value and close plus 2.5 × ATR(14); initialize to entry price and reset when flat
Long: (close > latest confirmed pivot high AND previous close ≤ that pivot high AND Momentum Z-score > threshold) OR (an active bullish order block exists AND low ≤ its top AND close > its bottom)
Short: (close < latest confirmed pivot low AND previous close ≥ that pivot low AND Momentum Z-score < −threshold) OR (an active bearish order block exists AND high ≥ its bottom AND close < its top)
Exit: long, low ≤ max(entry price − hard-stop distance, dynamic long stop if initialized) OR high ≥ entry price + target distance
Exit: short, high ≥ min(entry price + hard-stop distance, dynamic short stop if initialized) OR low ≤ entry price − target distance