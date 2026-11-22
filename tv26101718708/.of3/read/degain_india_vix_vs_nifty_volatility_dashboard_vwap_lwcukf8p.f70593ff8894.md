Calculation: Reference benchmark close = benchmark close from T1 on the last completed bar when static mode is selected or the session is closed; otherwise on the still-forming T1 bar
Calculation: Volatility estimate = volatility-index close from the same T1 bar / sqrt(annualization factor)
Long: on chart bars, chart close crosses above Reference benchmark close × (1 + Volatility estimate / 100)
Short: on chart bars, chart close crosses below Reference benchmark close × (1 − Volatility estimate / 100)
Calculation: Daily volatility = daily close of India VIX on T1 / sqrt(P1)
Long: close crosses above daily close of Nifty on T1 * (1 + Daily volatility / 100)
Short: close crosses below daily close of Nifty on T1 * (1 - Daily volatility / 100)