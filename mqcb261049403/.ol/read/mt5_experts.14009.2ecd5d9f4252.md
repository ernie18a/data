Calculation: Smoothed linear regression slope = the slope of a linear regression over a rolling lookback of a smoothed price series.
Calculation: Trigger = the linear regression slope from a shorter lookback offset into the past by the trigger lag.
Long: On the indicator timeframe, using the latest and preceding completed bars, the slope on the preceding bar is below its trigger AND the slope on the latest bar is at or above its trigger.
Short: On the indicator timeframe, using the latest and preceding completed bars, the slope on the preceding bar is above its trigger AND the slope on the latest bar is at or below its trigger.
Exit: long, On the latest completed bar of the indicator timeframe, the slope is below its trigger.
Exit: short, On the latest completed bar of the indicator timeframe, the slope is above its trigger.