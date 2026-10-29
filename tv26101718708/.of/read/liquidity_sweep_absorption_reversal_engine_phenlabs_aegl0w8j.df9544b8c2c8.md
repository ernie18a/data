Calculation: BSL pools = confirmed pivot highs using equal left and right lookbacks; retain the most recent configured maximum number of active levels per side, and retire a level when price wicks above it.
Calculation: SSL pools = confirmed pivot lows using equal left and right lookbacks; retain the most recent configured maximum number of active levels per side, and retire a level when price wicks below it.
Calculation: Nearest BSL = lowest active BSL above the current low.
Calculation: Nearest SSL = highest active SSL below the current high.
Calculation: Absorption = current volume >= its moving average × a configured multiplier AND abs(close − open) / (high − low) <= a configured maximum; when high = low, the ratio is 0.
Long: low < Nearest SSL AND ((mode is close-back-inside AND close > Nearest SSL) OR (mode is displacement AND close < Nearest SSL − ATR × configured displacement)) AND (absorption confirmation is disabled OR Absorption)
Short: high > Nearest BSL AND ((mode is close-back-inside AND close < Nearest BSL) OR (mode is displacement AND close > Nearest BSL + ATR × configured displacement)) AND (absorption confirmation is disabled OR Absorption)