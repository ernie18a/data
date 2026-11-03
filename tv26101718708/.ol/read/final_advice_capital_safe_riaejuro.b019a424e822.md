Calculation: Session wick midpoint = (session high + session low) / 2
Calculation: Session body midpoint = (max(session open, session close) + min(session open, session close)) / 2
Calculation: Session range percentage = (session high - session low) / close * 100
Long: session has ended AND current day is a weekday AND no trade has been taken today AND session range percentage >= minimum range percentage AND session close > session open AND close > session wick midpoint AND previous bar close > session wick midpoint AND close > session body midpoint
Short: session has ended AND current day is a weekday AND no trade has been taken today AND session range percentage >= minimum range percentage AND session close < session open AND close < session wick midpoint AND previous bar close < session wick midpoint AND close < session body midpoint
Exit: long, close <= session low OR close >= entry signal bar close + (entry signal bar close - session low) * risk/reward
Exit: short, close >= session high OR close <= entry signal bar close - (session high - entry signal bar close) * risk/reward