Calculation: Confirmed pivot high/low = a high/low that is higher/lower than the configured number of bars before and after it; becomes confirmed after those later bars complete
Calculation: Latest pivot high/low = the most recently confirmed pivot high/low
Calculation: Sweep depth = ATR × configurable multiplier
Calculation: Protective low/high = the latest confirmed pivot low/high within the configured maximum bar distance when the corresponding sweep occurs
Long: low <= latest pivot low - sweep depth AND close > latest pivot low AND previous bar low >= latest pivot low AND no low sweep is active
Long: a low sweep is active AND close > protective high
Long: low > high two bars ago AND low - high two bars ago >= configurable minimum FVG size (ATR × configurable multiplier)
Short: high >= latest pivot high + sweep depth AND close < latest pivot high AND previous bar high <= latest pivot high AND no high sweep is active
Short: a high sweep is active AND close < protective low
Short: high < low two bars ago AND low two bars ago - high >= configurable minimum FVG size (ATR × configurable multiplier)