Calculation: EnabledCount = number of enabled timeframe slots among T1–T6
Calculation: BullishCount = count of enabled slots whose nonmissing RSI(source, RSI lookback, slot timeframe), requested on chart bars with lookahead off (forming timeframe bar in real time; completed bar historically), is at or above the midline
Calculation: BearishCount = EnabledCount - BullishCount
Long: EnabledCount > 0 AND every enabled slot's RSI(source, RSI lookback, slot timeframe), requested on chart bars with lookahead off (forming timeframe bar in real time; completed bar historically), is at or below the oversold threshold
Long: BullishCount crosses above BearishCount
Short: EnabledCount > 0 AND every enabled slot's RSI(source, RSI lookback, slot timeframe), requested on chart bars with lookahead off (forming timeframe bar in real time; completed bar historically), is at or above the overbought threshold
Short: BullishCount crosses below BearishCount