Calculation: Confirmed swing high = a high confirmed as a pivot using equal lookback lengths on the left and right; retain the most recently confirmed value.
Calculation: Confirmed swing low = a low confirmed as a pivot using equal lookback lengths on the left and right; retain the most recently confirmed value.
Calculation: Trend state = neutral initially; set bullish after an upward break and bearish after a downward break. A break against the prior trend is a change of character (CHoCH); otherwise it is a break of structure (BOS).
Calculation: Break price = close in close-confirmation mode, or high for upward breaks and low for downward breaks in wick-confirmation mode.
Long: Break price > most recent confirmed swing high
Short: Break price < most recent confirmed swing low
Exit: Long, a downward break occurs while trend state is bullish OR close < the level of an upward break within the configured failure window after that break
Exit: Short, an upward break occurs while trend state is bearish OR close > the level of a downward break within the configured failure window after that break