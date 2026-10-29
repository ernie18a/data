Calculation: Selected moving average = ALMA, EMA, VWMA, or Hull MA of close over a lookback.
Calculation: MA slope = selected moving average minus its value at the slope lookback.
Calculation: Slope acceleration = current MA slope minus previous-bar MA slope.
Calculation: Scaled slope angle = degrees(arctan(angle multiplier × 100 × (selected moving average − its value at the slope lookback) / its value at the slope lookback)).
Long: Flat AND scaled slope angle ≥ minimum angle AND (MA slope crosses above 0 OR close crosses above selected moving average OR slope acceleration crosses above 0 OR (MA slope > 0 AND close > selected moving average AND close crosses above previous-bar high)).
Short: Flat AND scaled slope angle ≤ −minimum angle AND (MA slope crosses below 0 OR close crosses below selected moving average OR slope acceleration crosses below 0 OR (MA slope < 0 AND close < selected moving average AND close crosses below previous-bar low)).
Exit: Long, MA slope crosses below 0 OR close crosses below selected moving average OR slope acceleration crosses below 0 OR low ≤ long stop OR close ≥ long take-profit OR low ≤ trailing stop.
Exit: Short, MA slope crosses above 0 OR close crosses above selected moving average OR slope acceleration crosses above 0 OR high ≥ short stop OR close ≤ short take-profit OR high ≥ trailing stop.