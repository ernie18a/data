Calculation: stop level = average position entry price * stop-loss factor
Short: no open trades AND chart bar is within the entry-time window AND chart close < SMA(T1 close at the parameter offset of completed T1 bars ago, chart-bar lookback), calculated on chart bars
Short: exactly one open short entry AND chart high >= average position entry price * add-on entry factor
Exit: short, chart high >= stop level
Exit: short, first entry is open AND chart low <= average position entry price * first profit-target factor
Exit: short, second entry is open AND chart low <= average position entry price * second profit-target factor