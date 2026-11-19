Calculation: Opening-range high = high of the configured opening-time bar of T1, read from the T1 series on chart bars with lookahead off (using the current T1 bar while it forms)
Calculation: Opening-range low = low of the configured opening-time bar of T1, read from the T1 series on chart bars with lookahead off (using the current T1 bar while it forms)
Calculation: Entry eligibility = opening range initialized AND within the configured intraday entry window AND outside the configured annual blackout interval AND flat AND (one-trade-per-day restriction disabled OR no trade yet today)
Calculation: Bullish FVG = low > high[2] AND low[1] > high[2]
Calculation: Bearish FVG = high < low[2] AND high[1] < low[2]
Calculation: Initial upside-break low = low of the first chart bar after range initialization whose close > opening-range high
Calculation: Initial downside-break high = high of the first chart bar after range initialization whose close < opening-range low
Calculation: Upside-break retest = true from the first later chart bar closing within the range after an initial upside break until the daily reset
Calculation: Downside-break retest = true from the first later chart bar closing within the range after an initial downside break until the daily reset
Calculation: Break long stop = low of the earliest of the current bar and prior two bars whose close > opening-range high
Calculation: Break short stop = high of the earliest of the current bar and prior two bars whose close < opening-range low
Calculation: Reversal long stop = low[2]
Calculation: Reversal short stop = high[2]
Long: Entry eligibility AND break entries enabled AND Bullish FVG AND (close > opening-range high OR close[1] > opening-range high OR close[2] > opening-range high)
Short: Entry eligibility AND break entries enabled AND Bearish FVG AND (close < opening-range low OR close[1] < opening-range low OR close[2] < opening-range low)
Long: Entry eligibility AND break entries enabled AND Bullish FVG AND (close > opening-range high OR close[1] > opening-range high OR close[2] > opening-range high) AND close > Break long stop
Short: Entry eligibility AND break entries enabled AND Bearish FVG AND (close < opening-range low OR close[1] < opening-range low OR close[2] < opening-range low) AND close < Break short stop
Long: Entry eligibility AND trap entries enabled AND Initial upside break occurred AND Upside-break retest AND close > opening-range high
Short: Entry eligibility AND trap entries enabled AND Initial downside break occurred AND Downside-break retest AND close < opening-range low
Long: Entry eligibility AND trap entries enabled AND Initial upside break occurred AND Upside-break retest AND close > opening-range high AND close > Initial upside-break low
Short: Entry eligibility AND trap entries enabled AND Initial downside break occurred AND Downside-break retest AND close < opening-range low AND close < Initial downside-break high
Long: Entry eligibility AND reversal entries enabled AND Initial downside break occurred AND Bullish FVG AND close >= opening-range low AND close <= opening-range high
Short: Entry eligibility AND reversal entries enabled AND Initial upside break occurred AND Bearish FVG AND close >= opening-range low AND close <= opening-range high
Long: Entry eligibility AND reversal entries enabled AND Initial downside break occurred AND Bullish FVG AND close >= opening-range low AND close <= opening-range high AND close > Reversal long stop
Short: Entry eligibility AND reversal entries enabled AND Initial upside break occurred AND Bearish FVG AND close >= opening-range low AND close <= opening-range high AND close < Reversal short stop
Exit: Long, low <= stop price OR high >= entry price + R-multiple parameter * (entry price - stop price)
Exit: Short, high >= stop price OR low <= entry price - R-multiple parameter * (stop price - entry price)