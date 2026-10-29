Calculation: Pre-market high = highest high during the defined pre-market range, fixed when that range ends
Calculation: Pre-market low = lowest low during the defined pre-market range, fixed when that range ends
Calculation: Opening-range high = highest high during the defined opening range, fixed when that range ends
Calculation: Opening-range low = lowest low during the defined opening range, fixed when that range ends
Calculation: ATR = average true range on the selected timeframe; when that timeframe is higher than the chart timeframe, use its current bar, which may still be forming
Calculation: Trend moving average = selected moving average of the selected price source over its lookback
Long: selected range is pre-market or opening range AND current close > selected range high AND previous close <= previous selected range high AND current time is within the entry window AND daily trade count is below its maximum AND long entries are enabled
Short: selected range is pre-market or opening range AND current close < selected range low AND previous close >= previous selected range low AND current time is within the entry window AND daily trade count is below its maximum AND short entries are enabled
Exit: Long, current time is at or after the daily close time
Exit: Short, current time is at or after the daily close time
Exit: Long, selected exit mode is full ATR or partial ATR AND low <= entry price - ATR-based stop distance OR high >= entry price + ATR-based target distance
Exit: Short, selected exit mode is full ATR or partial ATR AND high >= entry price + ATR-based stop distance OR low <= entry price - ATR-based target distance
Exit: Long, selected exit mode is trailing stop AND low <= trailing stop level OR high >= trailing take-profit level
Exit: Short, selected exit mode is trailing stop AND high >= trailing stop level OR low <= trailing take-profit level
Exit: Long, selected exit mode is moving-average exit AND low <= trend moving average OR low <= the stop level specified by the ATR exit calculation
Exit: Short, selected exit mode is moving-average exit AND high >= trend moving average OR high >= the stop level specified by the ATR exit calculation
Exit: Long, selected exit mode is points scalp AND low <= entry price - stop distance OR high >= entry price + target distance
Exit: Short, selected exit mode is points scalp AND high >= entry price + stop distance OR low <= entry price - target distance
Exit: Long, selected exit mode is pre-market multiplier AND low <= the level between pre-market high and low set by the multiplier OR high >= entry price + ATR-based target distance
Exit: Short, selected exit mode is pre-market multiplier AND high >= the level between pre-market low and high set by the multiplier OR low <= entry price - ATR-based target distance