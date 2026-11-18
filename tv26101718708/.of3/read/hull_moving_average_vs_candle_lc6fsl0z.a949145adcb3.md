Calculation: Chart HMA = HMA(open, lookback)
Calculation: Higher-timeframe open = open(T1, sampled on chart bars; historically uses the latest completed T1 bar and updates on its final chart bar, while realtime uses the forming T1 bar)
Long: Chart HMA > Higher-timeframe open
Short: Chart HMA <= Higher-timeframe open
Long: open > Chart HMA AND Chart HMA > Higher-timeframe open AND open > open[1]
Short: open < Chart HMA AND Chart HMA < Higher-timeframe open AND open < open[1]
Exit: long, open < Chart HMA AND Chart HMA < Higher-timeframe open AND open >= open[1]
Exit: short, open > Chart HMA AND Chart HMA > Higher-timeframe open AND open <= open[1]