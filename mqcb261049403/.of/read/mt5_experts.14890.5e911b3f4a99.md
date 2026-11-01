Calculation: Signal bar = a configurable bar on the indicator timeframe, which may be higher or lower than the chart timeframe; use the last completed bar by default, or the still-forming bar when configured. Previous signal bar = the immediately preceding bar on that timeframe. The same configurable lookback applies to all high and low comparisons.
Long: chart bar high > chart bar high at the lookback
Short: chart bar low < chart bar low at the lookback
Long: signal bar high > signal bar high at the lookback AND signal bar low >= signal bar low at the lookback AND previous signal bar low < previous signal bar low at the lookback
Short: signal bar high <= signal bar high at the lookback AND signal bar low < signal bar low at the lookback AND previous signal bar high > previous signal bar high at the lookback
Exit: short, signal bar high > signal bar high at the lookback AND signal bar low >= signal bar low at the lookback
Exit: long, signal bar high <= signal bar high at the lookback AND signal bar low < signal bar low at the lookback
Exit: long, low <= entry price minus stop distance OR high >= entry price plus profit target distance
Exit: short, high >= entry price plus stop distance OR low <= entry price minus profit target distance