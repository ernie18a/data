Calculation: RSI legs = RSI of the selected source at fast, middle, and slow lookbacks, where fast < middle < slow.
Calculation: RSI signals = EMA of each RSI leg, using the same signal lookback for all three legs.
Calculation: Stochastic %K legs = SMA-smoothed stochastic %K at fast, middle, and slow lookbacks, where fast < middle < slow; %K smoothing is shared.
Calculation: Stochastic %D legs = SMA of each %K leg, using the same %D smoothing for all three legs.
Long: (RSI engine selected AND (fast RSI > fast RSI signal OR middle RSI > middle RSI signal OR slow RSI > slow RSI signal)) OR (Stochastic engine selected AND (fast %K > fast %D OR middle %K > middle %D OR slow %K > slow %D))
Short: (RSI engine selected AND (fast RSI < fast RSI signal OR middle RSI < middle RSI signal OR slow RSI < slow RSI signal)) OR (Stochastic engine selected AND (fast %K < fast %D OR middle %K < middle %D OR slow %K < slow %D))
Exit: long, (previous bar had all three selected-engine legs above their signals AND current bar does not have all three above)
Exit: short, (previous bar had all three selected-engine legs below their signals AND current bar does not have all three below)
Calculation timeframe is the chart timeframe or a higher timeframe. Live decisions use the forming calculation-timeframe bar; confirmed decisions use its last completed bar.