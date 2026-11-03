Calculation: OBV = cumulative volume signed by the direction of close change (positive for an increase, negative for a decrease, zero for no change)
Calculation: OBV moving average = a configurable moving average of OBV; use the same lookback for both
Calculation: OBV histogram = OBV − OBV moving average
Calculation: Confirmed price pivot high/low = a high/low strictly above/below the surrounding bars, using equal configurable lookbacks on both sides; compare the two most recent confirmed pivots
Calculation: Pivot OBV histogram = OBV histogram at the bar of the corresponding confirmed price pivot
Calculation: Average volume = moving average of volume over a configurable lookback
Long: On a closed bar, OBV crosses above its moving average AND (if enabled) the last completed higher-timeframe bar has OBV above its moving average AND (if enabled) ADX is at least its threshold AND (if enabled) volume is at least average volume multiplied by its threshold
Short: On a closed bar, OBV crosses below its moving average AND (if enabled) the last completed higher-timeframe bar has OBV below or equal to its moving average AND (if enabled) ADX is at least its threshold AND (if enabled) volume is at least average volume multiplied by its threshold
Long: A confirmed price pivot low is lower than the previous confirmed price pivot low AND its pivot OBV histogram is higher; OR a confirmed price pivot low is higher than the previous confirmed price pivot low AND its pivot OBV histogram is lower
Short: A confirmed price pivot high is higher than the previous confirmed price pivot high AND its pivot OBV histogram is lower; OR a confirmed price pivot high is lower than the previous confirmed price pivot high AND its pivot OBV histogram is higher
Exit: long, the short-entry condition occurs on a closed bar
Exit: short, the long-entry condition occurs on a closed bar