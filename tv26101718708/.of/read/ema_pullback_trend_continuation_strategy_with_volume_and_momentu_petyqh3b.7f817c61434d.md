Calculation: Pullback swing low = lowest low over a shorter lookback
Calculation: Pullback swing high = highest high over a shorter lookback
Long: position is flat AND fast EMA > slow EMA AND (previous bar low <= previous bar fast EMA OR previous bar close < previous bar fast EMA) AND close > fast EMA AND volume > its simple moving average over a shorter lookback AND RSI > its threshold
Short: position is flat AND fast EMA < slow EMA AND (previous bar high >= previous bar fast EMA OR previous bar close > previous bar fast EMA) AND close < fast EMA AND volume > its simple moving average over a shorter lookback AND RSI < its threshold
Exit: Long, low <= pullback swing low minus ATR buffer OR high >= entry price plus ATR multiple
Exit: Short, high >= pullback swing high plus ATR buffer OR low <= entry price minus ATR multiple