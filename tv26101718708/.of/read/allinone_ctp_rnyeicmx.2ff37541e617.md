Calculation: Fast EMA = EMA of close with a shorter lookback than the Slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the Fast EMA
Calculation: ATR = average true range over a lookback
Calculation: Confirmed structure swing high/low = pivot high/low with equal left and right lookback; a high qualifies when pivot high minus the low at its pivot bar exceeds ATR times a sensitivity factor and its swing height exceeds average ATR over a longer lookback times a swing-size factor; a low qualifies by the mirrored condition
Calculation: Structure break level = most recent qualifying confirmed structure swing high or low
Calculation: Internal swing high/low = confirmed pivot high/low using a shorter lookback than the structure swing
Calculation: SFP reference high/low = most recent confirmed pivot high/low, valid only within a finite lookback
Calculation: SFP upper/lower wick = high minus max(open, close) / min(open, close) minus low
Calculation: SFP candle range = max(high minus low, minimum price tick)
Calculation: Opening range high/low = highest high and lowest low during the opening window after a session open, calculated from lower-timeframe bars (completed bars; use chart bars if lower-timeframe data is unavailable)
Long: close > structure break level + ATR × displacement AND (volume filtering is disabled, volume is unavailable, or volume > its moving average) AND (structure trend is not bearish OR this condition holds on two consecutive bars while structure trend is bearish)
Long: close > internal swing high + ATR × displacement AND (volume filtering is disabled, volume is unavailable, or volume > its moving average) AND no structure BOS or CHoCH fires on this bar AND the internal swing high is not within 0.5 ATR of the current structure break high
Long: Fast EMA crosses above Slow EMA
Long: low < SFP reference low AND close > SFP reference low AND SFP lower wick > ATR × wick threshold AND SFP lower wick > SFP candle range × wick fraction AND (sweep-depth filter is disabled or reference low minus low > ATR × sweep threshold) AND (trend filter is disabled or close < Fast EMA) AND (volume filter is disabled, volume is unavailable, or volume > its moving average) AND (confirmation is disabled or the next bar closes above the reference low) AND (confluence is not required or a bullish BOS/CHoCH occurs within the configured bar window)
Long: opening range is locked AND its breakout state is unset AND close > opening range high
Short: close < structure break level − ATR × displacement AND (volume filtering is disabled, volume is unavailable, or volume > its moving average) AND (structure trend is not bullish OR this condition holds on two consecutive bars while structure trend is bullish)
Short: close < internal swing low − ATR × displacement AND (volume filtering is disabled, volume is unavailable, or volume > its moving average) AND no structure BOS or CHoCH fires on this bar AND the internal swing low is not within 0.5 ATR of the current structure break low
Short: Fast EMA crosses below Slow EMA
Short: high > SFP reference high AND close < SFP reference high AND SFP upper wick > ATR × wick threshold AND SFP upper wick > SFP candle range × wick fraction AND (sweep-depth filter is disabled or high minus reference high > ATR × sweep threshold) AND (trend filter is disabled or close > Fast EMA) AND (volume filter is disabled, volume is unavailable, or volume > its moving average) AND (confirmation is disabled or the next bar closes below the reference high) AND (confluence is not required or a bearish BOS/CHoCH occurs within the configured bar window)
Short: opening range is locked AND its breakout state is unset AND close < opening range low