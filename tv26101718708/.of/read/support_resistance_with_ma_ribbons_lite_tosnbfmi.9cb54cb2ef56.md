Calculation: Fast and slow moving averages = independently selected moving averages of a selected chart-bar price source, using respectively shorter and longer lengths. If an anchor is enabled, multiply both lengths by the rounded anchor-to-chart duration ratio when that ratio exceeds one; otherwise use the original lengths. Cap each resulting length at the implementation's maximum history. The triangular moving average is an SMA of an SMA of the same length; the Laguerre moving average uses a zero damping factor and therefore equals the source.
Calculation: Bullish zone = HLC3 > fast moving average AND HLC3 > slow moving average AND, if the open filter is enabled, open > fast moving average AND open > slow moving average.
Calculation: Bearish zone = HLC3 < fast moving average AND HLC3 < slow moving average AND, if the open filter is enabled, open < fast moving average AND open < slow moving average.
Calculation: Filtered bullish zone = bullish zone AND, if the ribbon filter is enabled, fast moving average >= slow moving average AND, if the slope filter is enabled, fast moving average is not lower than every fast moving average in the preceding slope lookback.
Calculation: Filtered bearish zone = bearish zone AND, if the ribbon filter is enabled, fast moving average <= slow moving average AND, if the slope filter is enabled, fast moving average is not higher than every fast moving average in the preceding slope lookback.
Calculation: Main resistance and main support = the most recently confirmed pivot high of high and pivot low of low, respectively, using the same left lookback and a shorter right confirmation lookback than the strong levels. Calculate on chart bars or, when selected, on higher-timeframe bars using the last completed higher-timeframe bar.
Calculation: Broken-resistance state = true after an enabled upside breakout until an enabled resistance retest; broken-support state = true after an enabled downside breakout until an enabled support retest. Evaluate retests using the state at the start of the bar, and update the states even if an alert is suppressed by cooldown.
Long: HLC3 > fast moving average.
Short: HLC3 < fast moving average.
Long: HLC3 > slow moving average.
Short: HLC3 < slow moving average.
Long: fast moving average > slow moving average.
Short: fast moving average < slow moving average.
Long: bullish zone.
Short: bearish zone.
Long: filtered bullish zone AND previous bar was not in the filtered bullish zone.
Short: filtered bearish zone AND previous bar was not in the filtered bearish zone.
Exit: long, previous bar was in the filtered bullish zone AND current bar is not in the filtered bullish zone.
Exit: short, previous bar was in the filtered bearish zone AND current bar is not in the filtered bearish zone.
Long: fast moving average > slow moving average AND previous fast moving average < previous slow moving average.
Short: fast moving average < slow moving average AND previous fast moving average > previous slow moving average.
Long: fast moving average > slow moving average AND close > previous close AND no earlier close > its previous close has occurred since the most recent bar with fast moving average < slow moving average.
Short: fast moving average < slow moving average AND close < previous close AND no earlier close < its previous close has occurred since the most recent bar with fast moving average > slow moving average.
Long: previous close <= current main resistance AND close > current main resistance × (1 + breakout threshold).
Short: previous close >= current main support AND close < current main support × (1 - breakout threshold).
Long: broken-resistance state = true AND low >= main resistance × (1 - touch tolerance) AND low <= main resistance × (1 + touch tolerance) AND close > main resistance.
Short: broken-support state = true AND high >= main support × (1 - touch tolerance) AND high <= main support × (1 + touch tolerance) AND close < main support.
Long: low < main support × (1 - touch tolerance) AND close > main support.
Short: high > main resistance × (1 + touch tolerance) AND close < main resistance.