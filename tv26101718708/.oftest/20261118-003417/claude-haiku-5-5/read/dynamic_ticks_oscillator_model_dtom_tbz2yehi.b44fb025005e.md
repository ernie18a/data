Calculation: Rc = ROC(close of I2 from T1 last completed bar on chart bars, rocLength)
Calculation: Sd = STDEV(Rc, volatilityLookback)
Long: Rc < -Sd * entryStdDevMultiplier
Exit: Long, Rc > Sd * exitStdDevMultiplier