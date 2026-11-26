Calculation: fast = WMA(Stochastic(VWMA((high+low+2*close)/4, Length), Period), Length)
Calculation: slow = WMA(fast, Length)
Long: fast >= slow
Short: fast < slow