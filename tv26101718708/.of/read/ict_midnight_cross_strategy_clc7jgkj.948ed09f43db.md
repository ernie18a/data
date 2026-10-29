Calculation: Midnight price = open of the bar timestamped 00:00 New York time
Long: close is above Midnight price AND the number of changes in closing-price side relative to Midnight price on bars after the midnight bar equals the configured required-cross count AND (entry delay is disabled OR the configured number of bars has elapsed since that count was reached) AND no trade has been taken that day AND position is flat
Short: close is below Midnight price AND the number of changes in closing-price side relative to Midnight price on bars after the midnight bar equals the configured required-cross count AND (entry delay is disabled OR the configured number of bars has elapsed since that count was reached) AND no trade has been taken that day AND position is flat
Exit: long, close is below Midnight price
Exit: short, close is above Midnight price
Exit: long, current New York time equals the configured exit time
Exit: short, current New York time equals the configured exit time
Exit: long, high is at least entry price plus configured take-profit ticks times minimum tick
Exit: short, low is at most entry price minus configured take-profit ticks times minimum tick
Exit: long, high reaches entry price plus configured breakeven-trigger ticks times minimum tick AND low is at or below entry price plus configured breakeven-offset ticks times minimum tick
Exit: short, low reaches entry price minus configured breakeven-trigger ticks times minimum tick AND high is at or above entry price minus configured breakeven-offset ticks times minimum tick
Exit: long, price reaches the trailing stop, set configured trailing-stop ticks behind the highest price since entry
Exit: short, price reaches the trailing stop, set configured trailing-stop ticks above the lowest price since entry