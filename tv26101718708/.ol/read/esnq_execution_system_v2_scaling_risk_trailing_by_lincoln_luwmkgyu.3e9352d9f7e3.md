Calculation: Previous day high/low = high/low of the last completed daily bar, which is higher timeframe than the chart timeframe.
Calculation: Premarket high/low = highest high/lowest low of premarket chart-timeframe bars so far today, including the current bar while it forms.
Calculation: Opening range high/low = highest high/lowest low of opening-range chart-timeframe bars so far today, including the current bar while it forms.
Calculation: Low sweep = current bar low < level AND current bar close > level.
Calculation: High sweep = current bar high > level AND current bar close < level.
Calculation: Long sweep count = number of low sweeps among previous day low, premarket low, and opening range low.
Calculation: Short sweep count = number of high sweeps among previous day high, premarket high, and opening range high.
Calculation: ATR buffer = chart-timeframe average true range over a lookback multiplied by a buffer factor.
Calculation: Long stop = signal-bar low minus ATR buffer; on each later bar, raise it to entry price when close >= entry price + current long risk, and after close >= current long second target raise it to the greater of its prior value and close minus ATR buffer. Current long risk = close minus (current bar low minus ATR buffer); current long second target = close + 2 × current long risk.
Calculation: Short stop = signal-bar high plus ATR buffer; on each later bar, lower it to entry price when close <= entry price - current short risk, and after close <= current short second target lower it to the lesser of its prior value and close plus ATR buffer. Current short risk = (current bar high plus ATR buffer) minus close; current short second target = close - 2 × current short risk.
Long: Daily trade count is below its configured maximum AND current time is within the NY core session AND long sweep count >= 2.
Short: Daily trade count is below its configured maximum AND current time is within the NY core session AND short sweep count >= 2.
Exit: long, current bar low <= long stop OR current bar high >= current long second target.
Exit: short, current bar high >= short stop OR current bar low <= current short second target.