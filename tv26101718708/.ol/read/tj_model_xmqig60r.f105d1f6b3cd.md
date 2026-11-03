Calculation: CISD long level = highest high of the three bars immediately before the current bar
Calculation: CISD short level = lowest low of the three bars immediately before the current bar
Calculation: IFVG threshold = low from two bars before the current bar, updated whenever the previous bar’s high is below that low
Calculation: Chart trend = close above a long-term SMA; higher-timeframe trend = close above an SMA with the same lookback, using the last completed higher-timeframe bar
Long: within the trading window AND no trade has been signaled that day AND the daily sweep flag is true AND current close crosses above the CISD long level AND current close is above the latest IFVG threshold AND chart trend is true AND higher-timeframe trend is true
Short: within the trading window AND no trade has been signaled that day AND the daily sweep flag is true AND current close crosses below the CISD short level AND chart trend is false AND higher-timeframe trend is false