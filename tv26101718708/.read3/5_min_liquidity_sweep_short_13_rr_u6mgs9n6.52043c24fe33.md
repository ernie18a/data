Calculation: running date high = maximum high from the first chart bar of the current date through the current chart bar
Short: close[1] > open[1] AND high[1] >= running date high[1] AND close < open[1] AND high > high[1]
Short: close[1] > open[1] AND high[1] >= running date high[1] AND close < open[1] AND high > high[1] AND high > close AND position is flat
Exit: short, high >= entry bar high OR low <= entry price - (entry bar high - entry price) × reward multiple