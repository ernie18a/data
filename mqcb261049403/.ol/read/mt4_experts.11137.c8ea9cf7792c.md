Calculation: OsMA = MACD line (shorter-period EMA minus longer-period EMA of weighted price) minus its signal moving average; compare the current forming bar with the previous completed bar on each of the three fixed trend timeframes, which may be higher or lower than the chart timeframe.
Calculation: Simple moving average of close using the same lookback on each trend timeframe; compare the current value with the value horizontally shifted by one bar, both evaluated on the current forming bar.
Calculation: Normalized Williams %R = 100 − absolute Williams %R, evaluated on the current forming bar of a daily timeframe, which may be higher or lower than the chart timeframe.
Calculation: Bollinger Band width = upper band minus lower band, using the same lookback and deviation setting on a fixed hourly timeframe, which may be higher or lower than the chart timeframe; use its current forming bar.
Calculation: Profit target distance = either a configured minimum distance or a fraction of Bollinger Band width, with smaller fractions for wider bands.
Long: OsMA is higher than its previous-bar value on all three trend timeframes AND the current simple moving average exceeds the horizontally shifted simple moving average on at least two of them AND normalized Williams %R is below its upper bound.
Short: OsMA is lower than its previous-bar value on all three trend timeframes AND the current simple moving average is less than or equal to the horizontally shifted simple moving average on at least two of them AND normalized Williams %R is above its lower bound.
Exit: Long, close price is greater than entry price plus profit target distance AND current bar high minus close exceeds the reversal threshold.
Exit: Short, close price is less than entry price minus profit target distance AND current bar close minus low exceeds the reversal threshold.
Exit: Long, close price is greater than entry price plus profit target distance AND close price is below entry price minus the reversal threshold.
Exit: Short, close price is less than entry price minus profit target distance AND close price is above entry price plus the reversal threshold.
Exit: Long, close price is at or below the stop price.
Exit: Short, close price is at or above the stop price.