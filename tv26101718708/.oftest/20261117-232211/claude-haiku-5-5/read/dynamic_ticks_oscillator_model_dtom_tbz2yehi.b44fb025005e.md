Calculation: V = close(S, T1, last completed bar)
Calculation: ROC = (V - V[rocLookback]) / V[rocLookback]
Calculation: SD = stdev(ROC, volatilityLookback)
Long: ROC < -entryMultiplier * SD
Exit: long, ROC > exitMultiplier * SD