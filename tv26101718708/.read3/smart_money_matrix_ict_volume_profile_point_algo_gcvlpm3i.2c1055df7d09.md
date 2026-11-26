Calculation: Structural bias = bullish on a close above the latest confirmed Pivot High(high, swing lookback, swing lookback), bearish on a close below the latest confirmed Pivot Low(low, swing lookback, swing lookback), otherwise retain the previous value, initially neutral
Calculation: Profile bin = the equal-width interval, among the number of price levels spanning the lowest low to highest high over lookback chart bars, containing a bar's (high + low) / 2
Calculation: Bull volume per profile bin = sum of volume over lookback chart bars assigned to the bin where close > open
Calculation: Bear volume per profile bin = sum of volume over lookback chart bars assigned to the bin where close <= open
Long: low < latest confirmed Pivot Low(low, swing lookback, swing lookback) AND close > latest confirmed Pivot Low(low, swing lookback, swing lookback)
Short: high > latest confirmed Pivot High(high, swing lookback, swing lookback) AND close < latest confirmed Pivot High(high, swing lookback, swing lookback)
Long: close > latest confirmed Pivot High(high, swing lookback, swing lookback)
Short: close < latest confirmed Pivot Low(low, swing lookback, swing lookback)
Long: a bullish FVG forms when low > high[2] AND close[1] > high[2]
Short: a bearish FVG forms when high < low[2] AND close[1] < low[2]
Long: close crosses above Volume Profile POC(lookback, number of price levels)
Short: close crosses below Volume Profile POC(lookback, number of price levels)
Long: close crosses above Volume Profile VAL(lookback, number of price levels) AND close[1] < Volume Profile VAL(lookback, number of price levels)
Short: close crosses below Volume Profile VAH(lookback, number of price levels) AND close[1] > Volume Profile VAH(lookback, number of price levels)
Long: a profile bin has positive total volume AND bull volume per profile bin > bear volume per profile bin
Short: a profile bin has positive total volume AND bull volume per profile bin <= bear volume per profile bin
Long: structural bias is bullish
Short: structural bias is bearish
Exit: long, high >= Volume Profile POC(lookback, number of price levels)
Exit: short, low <= Volume Profile POC(lookback, number of price levels)