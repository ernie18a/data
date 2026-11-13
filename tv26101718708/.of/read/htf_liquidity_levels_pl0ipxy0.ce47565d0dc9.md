Calculation: UntappedHTFHighs = set of highs of the last completed bar of a higher timeframe than the chart (one or more such timeframes). Each high is added on the first chart bar of a new higher-timeframe bar, before the comparisons on that bar. It stays in the set until a chart bar's high exceeds it, then it is removed (a level triggers only once).
Calculation: UntappedHTFLows = same as UntappedHTFHighs, but using lows. A level is removed once a chart bar's low goes below it.
Long: current high > any level in UntappedHTFHighs
Short: current low < any level in UntappedHTFLows