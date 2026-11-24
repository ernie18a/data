Calculation: T1 trend = on chart bars, bullish when the last completed T1 high and low are both greater than the preceding completed T1 high and low, bearish when both are lower, otherwise neutral
Long: T1 trend is bullish
Short: T1 trend is bearish
Long: SuperTrend(factor, ATR lookback) is bullish on the chart bar
Short: SuperTrend(factor, ATR lookback) is bearish on the chart bar
Long: SuperTrend(factor, ATR lookback) flips from bearish to bullish on the chart bar
Short: SuperTrend(factor, ATR lookback) flips from bullish to bearish on the chart bar
Calculation: Volume confirmation = volume filter disabled OR (the selected baseline is available and positive AND chart-bar volume >= volume multiplier * selected baseline), where the selected baseline is average volume of the last completed T1 period, SMA(volume, lookback) on chart bars, or volume[1] on chart bars, according to the selected mode
Calculation: Long breakout setup = on a chart bar, low < low of the last completed T1 period AND Volume confirmation AND (trend filter disabled OR no-filter mode selected OR T1 trend is bearish)
Calculation: Short breakout setup = on a chart bar, high > high of the last completed T1 period AND Volume confirmation AND (trend filter disabled OR no-filter mode selected OR T1 trend is bullish)
Long: no earlier long signal in the current T1 period AND ((SuperTrend linkage disabled AND Long breakout setup) OR (SuperTrend linkage enabled AND Long breakout setup armed during the current T1 period AND SuperTrend(factor, ATR lookback) flips from bearish to bullish on the chart bar))
Short: no earlier short signal in the current T1 period AND ((SuperTrend linkage disabled AND Short breakout setup) OR (SuperTrend linkage enabled AND Short breakout setup armed during the current T1 period AND SuperTrend(factor, ATR lookback) flips from bullish to bearish on the chart bar))
Calculation: Long trailing stop = running maximum of the bullish SuperTrend line since entry, initialized to its value at entry
Calculation: Short trailing stop = running minimum of the bearish SuperTrend line since entry, initialized to its value at entry
Exit: Long, SuperTrend linkage enabled AND low <= Long trailing stop
Exit: Long, SuperTrend linkage enabled AND low > Long trailing stop AND take-profit mode is single ATR target AND high >= entry price + ATR(TP lookback) at entry * single-target ATR multiple
Exit: Long, SuperTrend linkage enabled AND low > Long trailing stop AND (take-profit mode is SuperTrend exit OR (take-profit mode is ATR scale-out AND remainder mode is SuperTrend trail)) AND SuperTrend(factor, ATR lookback) flips from bullish to bearish
Exit: Long, SuperTrend linkage enabled AND low > Long trailing stop AND take-profit mode is ATR scale-out AND first-target quantity parameter > 0 AND first target not previously taken AND high >= entry price + ATR(TP lookback) at entry * first-target multiple
Exit: Long, SuperTrend linkage enabled AND low > Long trailing stop AND take-profit mode is ATR scale-out AND second-target quantity parameter > 0 AND second target not previously taken AND high >= entry price + ATR(TP lookback) at entry * second-target multiple
Exit: Long, SuperTrend linkage enabled AND low > Long trailing stop AND take-profit mode is ATR scale-out AND remainder mode is take profit at the third target AND high >= entry price + ATR(TP lookback) at entry * third-target multiple
Exit: Short, SuperTrend linkage enabled AND high >= Short trailing stop
Exit: Short, SuperTrend linkage enabled AND high < Short trailing stop AND take-profit mode is single ATR target AND low <= entry price - ATR(TP lookback) at entry * single-target ATR multiple
Exit: Short, SuperTrend linkage enabled AND high < Short trailing stop AND (take-profit mode is SuperTrend exit OR (take-profit mode is ATR scale-out AND remainder mode is SuperTrend trail)) AND SuperTrend(factor, ATR lookback) flips from bearish to bullish
Exit: Short, SuperTrend linkage enabled AND high < Short trailing stop AND take-profit mode is ATR scale-out AND first-target quantity parameter > 0 AND first target not previously taken AND low <= entry price - ATR(TP lookback) at entry * first-target multiple
Exit: Short, SuperTrend linkage enabled AND high < Short trailing stop AND take-profit mode is ATR scale-out AND second-target quantity parameter > 0 AND second target not previously taken AND low <= entry price - ATR(TP lookback) at entry * second-target multiple
Exit: Short, SuperTrend linkage enabled AND high < Short trailing stop AND take-profit mode is ATR scale-out AND remainder mode is take profit at the third target AND low <= entry price - ATR(TP lookback) at entry * third-target multiple