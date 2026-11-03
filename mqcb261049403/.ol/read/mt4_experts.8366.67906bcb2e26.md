Calculation: Long stop-entry level = Ask at straddle placement or adjustment + configured distance from price.
Calculation: Short stop-entry level = Bid at straddle placement or adjustment − configured distance from price.
Calculation: Long break-even stop = entry price + configured lock distance, activated when price is above entry price by the configured break-even threshold.
Calculation: Short break-even stop = entry price − configured lock distance, activated when price is below entry price by the configured break-even threshold.
Calculation: Long trailing stop = current price − configured trail distance; it can advance only when current price is above entry price by the trail distance, and, when trailing starts after break-even, by the break-even threshold as well.
Calculation: Short trailing stop = current price + configured trail distance; it can advance only when current price is below entry price by the trail distance, and, when trailing starts after break-even, by the break-even threshold as well.
Long: At the configured straddle placement time, High ≥ long stop-entry level.
Short: At the configured straddle placement time, Low ≤ short stop-entry level.
Exit: Long, Low ≤ active stop loss OR High ≥ take-profit price.
Exit: Short, High ≥ active stop loss OR Low ≤ take-profit price.