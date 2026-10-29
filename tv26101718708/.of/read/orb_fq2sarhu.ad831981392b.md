Calculation: Opening-range high/low = highest high and lowest low, respectively, during the configured opening window; the range is ready after that window ends.
Calculation: Active-session high/low = highest high and lowest low, respectively, since the active session began.
Calculation: Long retracement level(p) = swing high − (swing high − active-session low) × p
Calculation: Short retracement level(p) = swing low + (active-session high − swing low) × p
Calculation: Average candle body = rolling average of |close − open|
Calculation: Average volume = rolling average of volume
Calculation: Long stop = Long retracement level(0.786) − ATR × stop-buffer parameter
Calculation: Short stop = Short retracement level(0.786) + ATR × stop-buffer parameter
Long: Opening range is ready AND datetime is within the active session AND close crossed above the opening-range high (current close > high AND previous close ≤ high) since the latest cross below the opening-range low AND a pullback since the latest swing high reached or passed the selected long retracement level (low ≤ level) AND close > selected long retracement level AND close > open AND this session's long signal has not fired before AND (MACD line > MACD signal line if MACD filter is enabled) AND (volume > average volume × volume multiplier if volume filter is enabled) AND (close − open > average candle body if strong-candle filter is enabled)
Short: Opening range is ready AND datetime is within the active session AND close crossed below the opening-range low (current close < low AND previous close ≥ low) since the latest cross above the opening-range high AND a pullback since the latest swing low reached or passed the selected short retracement level (high ≥ level) AND close < selected short retracement level AND close < open AND this session's short signal has not fired before AND (MACD line < MACD signal line if MACD filter is enabled) AND (volume > average volume × volume multiplier if volume filter is enabled) AND (open − close > average candle body if strong-candle filter is enabled)
Exit: long, high ≥ swing high at entry OR low ≤ long stop
Exit: short, low ≤ swing low at entry OR high ≥ short stop