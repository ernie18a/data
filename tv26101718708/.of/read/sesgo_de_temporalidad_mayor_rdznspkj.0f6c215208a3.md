Calculation: StructureTrend(timeframe) = state per bar on that timeframe, initial 0. Pivot high = bar whose high is the highest among N bars left and N bars right (confirmed N bars later); pivot low = bar whose low is the lowest among N bars left and N bars right. Each bar, in this order: (1) on a new pivot high, set prevPH=lastPH and lastPH=new pivot high; if state==1 and lastPH<prevPH then state=0. (2) On a new pivot low, set prevPL=lastPL and lastPL=new pivot low; if state==-1 and lastPL>prevPL then state=0. (3) If lastPH exists and close>lastPH then state=1. (4) If lastPL exists and close<lastPL then state=-1 (overrides step 3 on the same bar). State 0 = range.
Long: close of the last completed higher-timeframe bar > open of that same bar
Long: StructureTrend on the chart timeframe (current bar) == 1
Long: StructureTrend on a higher timeframe, value from the last completed higher-timeframe bar, == 1
Short: close of the last completed higher-timeframe bar < open of that same bar
Short: StructureTrend on the chart timeframe (current bar) == -1
Short: StructureTrend on a higher timeframe, value from the last completed higher-timeframe bar, == -1