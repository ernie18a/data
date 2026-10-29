Calculation: CBC state = persistent bullish state after a bar closes above the previous bar’s high; persistent bearish state after a bar closes below the previous bar’s low; otherwise retain the previous state.
Calculation: Higher-timeframe CBC state = the same CBC state calculated from higher-timeframe bars; for HTF labels and status, use the last completed higher-timeframe bar, and for agreement bar coloring, use the higher-timeframe bar still forming.
Calculation: Opening range high/low = highest high and lowest low during the selected session’s opening range.
Calculation: Yesterday’s RTH high/low/close = the prior completed New York regular-session high, low, and close. Premarket high/low = the high and low from the premarket session, frozen at the regular-session open.
Long: CBC state is bullish
Long: CBC state changes from bearish to bullish
Long: Higher-timeframe CBC state changes from bearish to bullish, using the last completed higher-timeframe bar
Long: CBC state and higher-timeframe CBC state are both bullish on a confirmed chart bar
Long: 9-period EMA is greater than or equal to 20-period EMA
Long: Higher-timeframe 9-period EMA is greater than or equal to higher-timeframe 20-period EMA, using the higher-timeframe bar still forming
Long: Close is above VWAP
Long: Close is above 200-period EMA
Long: Close is above the active session’s opening range high
Short: CBC state is bearish
Short: CBC state changes from bullish to bearish
Short: Higher-timeframe CBC state changes from bullish to bearish, using the last completed higher-timeframe bar
Short: CBC state and higher-timeframe CBC state are both bearish on a confirmed chart bar
Short: 9-period EMA is below 20-period EMA
Short: Higher-timeframe 9-period EMA is below higher-timeframe 20-period EMA, using the higher-timeframe bar still forming
Short: Close is below VWAP
Short: Close is below 200-period EMA
Short: Close is below the active session’s opening range low
Exit: