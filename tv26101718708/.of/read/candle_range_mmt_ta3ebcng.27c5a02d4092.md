Calculation: Range = initialize the high and low to the first bar's high and low and direction to neutral; when a later bar closes strictly above the current high or strictly below the current low, replace the high and low with that bar's high and low and set direction to bullish or bearish respectively; otherwise retain the range and direction. Calculate execution and context ranges independently; execution uses the chart timeframe or a higher timeframe, and context uses the execution timeframe or a higher timeframe. For each range above the chart timeframe, use the last completed bar; for a range on the chart timeframe, use the completed chart bar.
Calculation: Range midpoint = (range high + range low) / 2.
Long: context range direction = bullish AND execution range direction = bullish AND close >= execution range midpoint
Short: context range direction = bearish AND execution range direction = bearish AND close <= execution range midpoint
Long: execution range direction = bullish AND context range direction = bullish AND low <= execution range midpoint AND high >= execution range midpoint
Short: execution range direction = bearish AND context range direction = bearish AND low <= execution range midpoint AND high >= execution range midpoint
Long: execution range did not reset on the current chart bar AND low < execution range low AND close >= execution range low
Short: execution range did not reset on the current chart bar AND high > execution range high AND close <= execution range high
Long: execution range did not reset on the current chart bar AND close > execution range midpoint AND previous close <= previous execution range midpoint
Short: execution range did not reset on the current chart bar AND close < execution range midpoint AND previous close >= previous execution range midpoint
Long: execution range resets bullish on the current chart bar
Short: execution range resets bearish on the current chart bar
Exit: long, execution range resets bearish on the current chart bar
Exit: short, execution range resets bullish on the current chart bar
Exit: long, high >= execution range high OR high >= context range high
Exit: short, low <= execution range low OR low <= context range low