Long: On T1 bars, current low < previous T1-bar low, using the T1 bar while it forms in realtime and returning values to chart bars without lookahead; within the configured chart-bar calculation lookback.
Short: On T1 bars, current high > previous T1-bar high, using the T1 bar while it forms in realtime and returning values to chart bars without lookahead; within the configured chart-bar calculation lookback.
Long: While the latest confirmed Turtle Soup is bullish and no CHoCH has yet been marked for it, chart-bar close > latest confirmed Pivot High(high, swing length, swing length).
Short: While the latest confirmed Turtle Soup is bearish and no CHoCH has yet been marked for it, chart-bar close < latest confirmed Pivot Low(low, swing length, swing length).
Long: While the latest confirmed Turtle Soup is bullish, chart-bar low > chart-bar high[2].
Short: While the latest confirmed Turtle Soup is bearish, chart-bar high < chart-bar low[2].
Exit: Long, while the latest confirmed Turtle Soup is bullish, chart-bar high >= the high of the T1 bar immediately preceding that setup, on the first bar from the setup onward that reaches the level.
Exit: Short, while the latest confirmed Turtle Soup is bearish, chart-bar low <= the low of the T1 bar immediately preceding that setup, on the first bar from the setup onward that reaches the level.