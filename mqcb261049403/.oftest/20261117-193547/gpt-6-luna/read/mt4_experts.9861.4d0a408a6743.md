Calculation: Forming-bar open = open of the bar still forming at the calculation's timeframe
Calculation: Forming-bar high = high of the bar still forming at the calculation's timeframe
Calculation: Forming-bar low = low of the bar still forming at the calculation's timeframe
Long: close > forming-bar open AND forming-bar open - forming-bar low > long lower-wick threshold AND open order count < maximum open-order count AND current hour < long entry hour cutoff
Short: close < forming-bar open AND forming-bar high - forming-bar open > short upper-wick threshold AND open order count < maximum open-order count AND current hour < short entry hour cutoff
Exit: Long, current hour > market-close-hour parameter - exit-hour offset parameter
Exit: Short, current hour > market-close-hour parameter - exit-hour offset parameter