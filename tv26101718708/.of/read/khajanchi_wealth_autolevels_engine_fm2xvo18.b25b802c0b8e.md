Calculation: PrevHTFHigh/PrevHTFLow = high/low of the last completed bar of a higher timeframe than the chart timeframe
Calculation: ConfirmedPivotLow = a bar whose low is lower than the lows of N bars before it and N bars after it; it is known only on the bar N bars after the pivot bar, so evaluate on that confirmation bar. ConfirmedPivotHigh is the mirror case using highs.
Long: low > high 2 bars ago AND close 1 bar ago > high 2 bars ago (bullish fair value gap)
Long: a ConfirmedPivotLow is confirmed on the current bar (bullish order block)
Long: close > PrevHTFHigh
Short: high < low 2 bars ago AND close 1 bar ago < low 2 bars ago (bearish fair value gap)
Short: a ConfirmedPivotHigh is confirmed on the current bar (bearish order block)
Short: close < PrevHTFLow