Calculation: Timeframe data = for each selected timeframe, use its current bar if it is the chart timeframe, its last completed bar if it is higher than the chart timeframe, and its last completed intrabar within the chart bar if it is lower. Evaluate each EMA and crossover in its own timeframe.
Calculation: EMA set = five close EMAs with strictly increasing lengths, shared across an ordered set of timeframes from shortest to longest.
Calculation: Trend score = sum, over every timeframe and EMA, of a weight multiplied by +1 when that timeframe's close is above the EMA and -1 otherwise. Each weight is proportional to the timeframe duration multiplied by the EMA length, with the weight for the longest timeframe multiplied by a separate factor.
Calculation: Recent upward crossover = an EMA crossed above any other EMA in the same timeframe within the lookback, including the current bar. A crossover occurs when the EMA is above the other EMA now and was at or below it on the preceding bar of that timeframe.
Calculation: Recent downward crossover = an EMA crossed below any other EMA in the same timeframe within the lookback, including the current bar. A crossover occurs when the EMA is below the other EMA now and was at or above it on the preceding bar of that timeframe.
Long: Recent upward crossover for any EMA in any selected timeframe.
Short: Recent downward crossover for any EMA in any selected timeframe AND no recent upward crossover for that same EMA and timeframe.
Long: Close above any EMA in any selected timeframe AND no recent upward crossover AND no recent downward crossover for that same EMA and timeframe.
Short: Close at or below any EMA in any selected timeframe AND no recent upward crossover AND no recent downward crossover for that same EMA and timeframe.
Long: Trend score > 0.
Short: Trend score < 0.
Long: Trend score > 0 AND main-timeframe close > its second-shortest EMA AND main-timeframe close > its middle EMA AND trigger-timeframe close > its second-shortest EMA. The main timeframe is one of the selected timeframes; the trigger timeframe is the next shorter selected timeframe, or the same timeframe when the main timeframe is the shortest.
Short: Trend score < 0 AND main-timeframe close <= its second-shortest EMA AND main-timeframe close <= its middle EMA AND trigger-timeframe close <= its second-shortest EMA. The main timeframe is one of the selected timeframes; the trigger timeframe is the next shorter selected timeframe, or the same timeframe when the main timeframe is the shortest.
Long: Close > middle EMA in each of the two longest timeframes AND main-timeframe close <= its second-shortest EMA.
Long: Close > middle EMA in each of the two longest timeframes AND main-timeframe close > its second-shortest EMA AND trigger-timeframe close > its second-shortest EMA.
Short: Close <= middle EMA in each of the two longest timeframes AND main-timeframe close > its second-shortest EMA.
Short: Close <= middle EMA in each of the two longest timeframes AND main-timeframe close <= its second-shortest EMA AND trigger-timeframe close <= its second-shortest EMA.