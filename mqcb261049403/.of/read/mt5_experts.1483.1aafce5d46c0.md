Calculation: Coppock = linear-weighted moving average of the sum of two fractional rates of change of open, using a longer and a shorter lookback.
Calculation: Higher-timeframe Coppock = Coppock calculated on higher-timeframe bars, using the last completed bar; earlier values refer to preceding completed higher-timeframe bars.
Long: Coppock > 0 AND Coppock != previous Coppock
Short: Coppock < 0 AND Coppock != previous Coppock
Long: Higher-timeframe Coppock > previous higher-timeframe Coppock AND previous higher-timeframe Coppock < higher-timeframe Coppock two bars ago
Short: Higher-timeframe Coppock < previous higher-timeframe Coppock AND previous higher-timeframe Coppock > higher-timeframe Coppock two bars ago
Exit: long, higher-timeframe Coppock < previous higher-timeframe Coppock
Exit: short, higher-timeframe Coppock > previous higher-timeframe Coppock
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance