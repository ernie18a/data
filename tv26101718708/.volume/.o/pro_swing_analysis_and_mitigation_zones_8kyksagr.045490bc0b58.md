Calculation: Pivot low = a bar whose low is lower than the lows of the configured number of preceding bars and the 2 following bars; confirmed 2 bars after the pivot bar
Calculation: Pivot high = a bar whose high is higher than the highs of the configured number of preceding bars and the 2 following bars; confirmed 2 bars after the pivot bar
Calculation: Volume climax = pivot-bar volume > its 20-period volume SMA × a configurable multiplier
Calculation: Range climax = pivot-bar (high − low) > its 20-period (high − low) SMA × a configurable multiplier
Calculation: Qualifying pivot = confirmed pivot with both volume climax and range climax, and with the pivot-bar close above its EMA for a long pivot or below its EMA for a short pivot; the EMA filter is configurable
Calculation: Trendline price = price on the line extended through the latest two qualifying pivot lows in the current long trend, or latest two qualifying pivot highs in the current short trend
Calculation: Supply zone = band centered on a qualifying pivot high, with ATR-scaled padding; it becomes a ghost zone when price trades above its top and remains a ghost until a bar closes below its top
Calculation: Demand zone = band centered on a qualifying pivot low, with ATR-scaled padding; it becomes a ghost zone when price trades below its bottom and remains a ghost until a bar closes above its bottom
Long: qualifying pivot low
Short: qualifying pivot high
Exit: Long, close < Trendline price OR a ghost supply zone overlaps the bar (high ≥ zone bottom AND low ≤ zone top)
Exit: Short, close > Trendline price OR a ghost demand zone overlaps the bar (low ≤ zone top AND high ≥ zone bottom)