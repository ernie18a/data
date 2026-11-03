Calculation: Premarket high = highest high during the current day's premarket session
Calculation: Premarket low = lowest low during the current day's premarket session
Long: During the regular session, low < premarket low AND close > premarket low
Long: During the regular session, close > premarket high
Long: After a premarket-low sweep and reclaim, low <= premarket low + retest tolerance AND close > premarket low AND close < open
Long: After a close above premarket high, low <= premarket high + retest tolerance AND close > premarket high
Long: During the regular session, after either corresponding long retest occurred on a prior bar and before that setup is invalidated, close > open AND abs(close - open) >= ATR × minimum body multiple AND close > prior bar high AND (range filter disabled OR high - low >= minimum candle range) AND (one-signal-per-side limit disabled OR no long signal has fired that day)
Short: During the regular session, high > premarket high AND close < premarket high
Short: During the regular session, close < premarket low
Short: After a premarket-high sweep and failure, high >= premarket high - retest tolerance AND close < premarket high AND close > open
Short: After a close below premarket low, high >= premarket low - retest tolerance AND close < premarket low
Short: During the regular session, after either corresponding short retest occurred on a prior bar and before that setup is invalidated, close < open AND abs(close - open) >= ATR × minimum body multiple AND close < prior bar low AND (range filter disabled OR high - low >= minimum candle range) AND (one-signal-per-side limit disabled OR no short signal has fired that day)