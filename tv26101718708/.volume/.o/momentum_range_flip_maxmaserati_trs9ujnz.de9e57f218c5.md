Calculation: Range high = highest high from the anchor candle through the current bar
Calculation: Range low = lowest low from the anchor candle through the current bar
Long: Current bar is confirmed AND ((close > previous bar high AND close >= open) OR (previous bar close > high two bars ago OR previous bar close < low two bars ago) AND current bar close >= previous bar high AND current bar close <= previous bar low AND previous bar close >= previous bar open)
Short: Current bar is confirmed AND ((close < previous bar low AND close < open) OR (previous bar close > high two bars ago OR previous bar close < low two bars ago) AND current bar close >= previous bar low AND current bar close <= previous bar high AND previous bar close < previous bar open)
Exit: long, close < Range low
Exit: short, close > Range high