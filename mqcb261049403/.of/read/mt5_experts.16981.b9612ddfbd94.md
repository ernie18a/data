Calculation: Momentum line = weighted sum of five momentum ratios, each equal to 100 times the selected OHLC-derived price divided by that price a respective lookback ago; the lookbacks increase from shortest to longest, and the third ratio uses the same weight as the second.
Calculation: Signal line = recursively smoothed momentum line: current momentum line divided by the smoothing period plus the previous signal line multiplied by (smoothing period minus 1) divided by the smoothing period; initialize the first signal line to the first momentum line divided by the smoothing period.
Long: chart-timeframe momentum line > chart-timeframe signal line.
Short: chart-timeframe momentum line < chart-timeframe signal line.
Long: higher-timeframe momentum line > higher-timeframe signal line, using the higher-timeframe bar still forming.
Short: higher-timeframe momentum line < higher-timeframe signal line, using the higher-timeframe bar still forming.
Long: last completed higher-timeframe momentum line > its signal line AND last completed entry-timeframe momentum line > its signal line AND the preceding entry-timeframe momentum line <= its signal line.
Short: last completed higher-timeframe momentum line < its signal line AND last completed entry-timeframe momentum line < its signal line AND the preceding entry-timeframe momentum line >= its signal line.
Exit: long, last completed higher-timeframe momentum line < its signal line OR last completed entry-timeframe momentum line < its signal line when entry-timeframe exits are enabled.
Exit: short, last completed higher-timeframe momentum line > its signal line OR last completed entry-timeframe momentum line > its signal line when entry-timeframe exits are enabled.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.