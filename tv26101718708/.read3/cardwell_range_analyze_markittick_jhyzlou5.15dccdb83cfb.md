Calculation: Regime = 1 if (RSI(RSI source, RSI length) in [bull low, bull high] AND trend source > SMA(trend source, trend length)) holds on each of the last confirm bars; -1 if (RSI(RSI source, RSI length) in [bear low, bear high] AND trend source < SMA(trend source, trend length)) holds on each of the last confirm bars
Long: Regime = 1
Short: Regime = -1
Long: Regime = 1 AND Regime[1] != 1 AND (NOT use T1 filter OR Regime(T1 bars, last completed bar) = 1) AND (NOT use ADX filter OR ADX(ADX length) >= ADX minimum)
Short: Regime = -1 AND Regime[1] != -1 AND (NOT use T1 filter OR Regime(T1 bars, last completed bar) = -1) AND (NOT use ADX filter OR ADX(ADX length) >= ADX minimum)