Calculation: Volume average = simple moving average of volume over a lookback
Calculation: Volume spike = current volume > volume average × spike multiplier
Calculation: Bullish FVG = current low − low two bars ago's corresponding high (high two bars ago) ≥ minimum gap threshold
Calculation: Bearish FVG = low two bars ago − current high ≥ minimum gap threshold
Long: Bullish FVG AND current volume ≥ volume average × low-volume multiplier AND (volume-spike filter disabled OR Volume spike) AND (high/low-of-two filter disabled OR low two bars ago ≤ lows three and four bars ago AND Volume spike)
Short: Bearish FVG AND current volume ≥ volume average × low-volume multiplier AND (volume-spike filter disabled OR Volume spike) AND (high/low-of-two filter disabled OR high two bars ago ≥ highs three and four bars ago AND Volume spike)
Long: An unmitigated bullish FVG has not been retested, current low ≤ its top, current low ≥ its bottom, and no new bullish FVG forms
Short: An unmitigated bearish FVG has not been retested, current high ≥ its bottom, current high ≤ its top, and no new bearish FVG forms
Exit: Long, current low < the bottom of an unmitigated bullish FVG
Exit: Short, current high > the top of an unmitigated bearish FVG