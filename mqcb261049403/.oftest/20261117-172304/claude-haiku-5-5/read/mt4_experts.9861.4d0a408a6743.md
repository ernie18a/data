Calculation: daily open = open of the still-forming bar on the daily timeframe, which is higher than the chart timeframe
Calculation: daily high = high of the still-forming bar on the daily timeframe, which is higher than the chart timeframe
Calculation: daily low = low of the still-forming bar on the daily timeframe, which is higher than the chart timeframe
Calculation: current price = close of the current chart bar
Calculation: current hour = hour of the current chart bar datetime
Calculation: point = minimum price increment of the instrument
Long: current price > daily open AND (daily open - daily low) > range parameter * point AND position side is flat AND current hour < long-entry hour parameter
Short: current price < daily open AND (daily high - daily open) > range parameter * point AND position side is flat AND current hour < short-entry hour parameter
Exit: long, current hour > exit-hour parameter - 1
Exit: short, current hour > exit-hour parameter - 1