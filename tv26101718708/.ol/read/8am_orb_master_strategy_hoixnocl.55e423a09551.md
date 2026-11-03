Calculation: Opening-range high = highest high from 08:00 through 08:14 New York time
Calculation: Opening-range low = lowest low from 08:00 through 08:14 New York time
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: Midpoint zone = a configurable fraction of the opening-range width
Calculation: Long-term trend = exponential moving average of close over a long lookback
Calculation: Average volume = simple moving average of volume over a short lookback
Long: Opening range is complete AND current New York time is after 08:15 AND no entry has occurred that day AND the previous bar touched the midpoint or had its high or low within the midpoint zone AND close > opening-range midpoint AND close > open AND close > long-term trend AND volume > average volume × a configurable threshold
Short: Opening range is complete AND current New York time is after 08:15 AND no entry has occurred that day AND the previous bar touched the midpoint or had its high or low within the midpoint zone AND close < opening-range midpoint AND close < open AND close < long-term trend AND volume > average volume × a configurable threshold