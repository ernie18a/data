Calculation: JMA close movement = absolute difference between the JMA-smoothed close of the current signal bar and two signal bars earlier, rounded to instrument precision. Use chart-timeframe bars in the base indicator; in the HTF indicator use the higher-timeframe still-forming bar.
Calculation: Volatility threshold = ATR on the signal timeframe divided by an ATR scaling parameter
Long: Stochastic %K < lower threshold AND JMA close movement > Volatility threshold
Short: Stochastic %K > upper threshold AND JMA close movement > Volatility threshold