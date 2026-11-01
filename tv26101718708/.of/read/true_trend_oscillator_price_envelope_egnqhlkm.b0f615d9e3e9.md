Calculation: Smoothed ATR stochastic = clamp to [0, 100] the rational quadratic kernel weighted average of the SMA of 100 × (ATR − lowest ATR) / (highest ATR − lowest ATR), using a stochastic lookback for the ATR extrema. For kernel lag i from 0 through start-bar parameter + 1, the weight is (1 + i² / (2 × kernel lookback² × relative weighting)) raised to −relative weighting.
Calculation: Bull trend = square root of RSI of a selected OHLC-derived price source × smoothed ATR stochastic.
Calculation: Bear trend = square root of (100 − RSI of the same price source) × smoothed ATR stochastic.
Long: Bull trend > bear trend AND minimum of bull trend and bear trend > active threshold.
Short: Bear trend > bull trend AND minimum of bull trend and bear trend > active threshold.
Long: Bull trend > extreme threshold.
Short: Bear trend > extreme threshold.
Long: Bull trend >= bear trend.
Short: Bear trend > bull trend.
Long: Bull trend > bear trend AND minimum of bull trend and bear trend > active threshold AND previous bar's bull trend <= previous bar's bear trend OR bull trend > bear trend AND minimum of bull trend and bear trend > active threshold AND previous bar's minimum of bull trend and bear trend <= previous bar's active threshold.
Short: Bear trend > bull trend AND minimum of bull trend and bear trend > active threshold AND previous bar's bear trend <= previous bar's bull trend OR bear trend > bull trend AND minimum of bull trend and bear trend > active threshold AND previous bar's minimum of bull trend and bear trend <= previous bar's active threshold.
Long: Higher-timeframe bull trend >= higher-timeframe bear trend AND minimum of higher-timeframe bull trend and bear trend > higher-timeframe active threshold OR higher-timeframe bull trend > extreme threshold.
Short: Higher-timeframe bear trend > higher-timeframe bull trend AND minimum of higher-timeframe bull trend and bear trend > higher-timeframe active threshold AND higher-timeframe bull trend <= extreme threshold OR higher-timeframe bear trend > extreme threshold AND higher-timeframe bull trend <= extreme threshold.
Calculation: Higher-timeframe bull trend, bear trend, and active threshold = the same calculations on a higher timeframe, using either its still-forming bar or its last completed bar, consistently for all three.