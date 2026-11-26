Calculation: StepLine(close, percent) on T1 bars = IF close*(1 - percent/100) > StepLine[1] THEN close*(1 - percent/100) ELSE IF close*(1 + percent/100) < StepLine[1] THEN close*(1 + percent/100) ELSE StepLine[1]
Long: StepLine(T1, current bar still forming) > StepLine(T1, previous bar)
Short: StepLine(T1, current bar still forming) < StepLine(T1, previous bar)