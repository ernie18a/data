Calculation: Fast HA open EMA = EMA(Heikin-Ashi open from the current T1 bar, still forming in real time and mapped onto chart bars, fast smoothing lookback)
Calculation: Fast HA close EMA = EMA(Heikin-Ashi close from the current T1 bar, still forming in real time and mapped onto chart bars, fast smoothing lookback)
Calculation: Major HA open EMA = EMA(Heikin-Ashi open from the current T2 bar, still forming in real time and mapped onto chart bars, major smoothing lookback)
Calculation: Major HA close EMA = EMA(Heikin-Ashi close from the current T2 bar, still forming in real time and mapped onto chart bars, major smoothing lookback)
Calculation: Stochastic %K = SMA(Stochastic(close, high, low, stochastic lookback), smoothing lookback)
Calculation: Stochastic %D = SMA(Stochastic %K, same smoothing lookback)
Calculation: Short EMA = EMA(close, shorter lookback)
Calculation: Long EMA = EMA(close, longer lookback)
Long: Fast HA close EMA > Fast HA open EMA
Short: Fast HA close EMA <= Fast HA open EMA
Long: Major HA close EMA > Major HA open EMA
Short: Major HA close EMA <= Major HA open EMA
Long: Short EMA crosses above Long EMA
Short: Short EMA crosses below Long EMA
Long: Stochastic %K crosses above Stochastic %D AND Stochastic %K < lower threshold AND Fast HA close EMA > Fast HA open EMA AND Major HA close EMA > Major HA open EMA
Short: Stochastic %K crosses below Stochastic %D AND Stochastic %K > upper threshold AND Fast HA close EMA <= Fast HA open EMA AND Major HA close EMA <= Major HA open EMA
Long: Stochastic %K crosses above Stochastic %D AND Stochastic %K < lower threshold AND Fast HA close EMA > Fast HA open EMA AND Major HA close EMA > Major HA open EMA AND close > Short EMA
Short: Stochastic %K crosses below Stochastic %D AND Stochastic %K > upper threshold AND Fast HA close EMA <= Fast HA open EMA AND Major HA close EMA <= Major HA open EMA AND close < Short EMA