Calculation: Bullish momentum = current close > current open OR current close > previous close OR current close > close two bars ago OR current close > close three bars ago
Calculation: Bearish momentum = current close < current open OR current close < previous close OR current close < close two bars ago OR current close < close three bars ago
Calculation: Long stop-entry level = signal bar high increased by a percentage margin
Calculation: Short stop-entry level = signal bar low decreased by a percentage margin
Calculation: Long trailing stop = the highest, since entry, of each bar's high reduced by a percentage
Calculation: Short trailing stop = the lowest, since entry, of each bar's low increased by a percentage
Long: Bullish momentum AND (EMA filter disabled OR close > the EMA calculated on a higher timeframe using its last completed bar) AND datetime is within the configured backtest date range AND high >= the pending long stop-entry level
Short: Bearish momentum AND (EMA filter disabled OR close < the EMA calculated on a higher timeframe using its last completed bar) AND datetime is within the configured backtest date range AND low <= the pending short stop-entry level
Exit: Long, low <= long trailing stop
Exit: Short, high >= short trailing stop
Exit: Long or Short, current datetime is outside the configured backtest date range AND previous bar's datetime was within it