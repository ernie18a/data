Calculation: Premarket high and low = highest high and lowest low observed during the configured premarket session, reset each trading day.
Long: Outside the premarket session AND a premarket bar has occurred today AND close on the fixed calculation timeframe > premarket high.
Short: Outside the premarket session AND a premarket bar has occurred today AND close on the fixed calculation timeframe < premarket low.
Long: Close on the fixed calculation timeframe > short-period EMA > medium-period EMA > long-period EMA, all calculated from closes on that timeframe.
Short: Close on the fixed calculation timeframe < short-period EMA < medium-period EMA < long-period EMA, all calculated from closes on that timeframe.
Long: Current daily high > previous completed daily high.
Short: Current daily low < previous completed daily low.
Calculation: Fixed calculation timeframe and daily timeframe = independently configured timeframes that may be higher, lower, or equal to the chart timeframe. For a higher timeframe, use the last completed bar historically and the bar still forming in real time; for a lower timeframe, use the last available intrabar. Current daily high and low use the current daily bar under these same rules.