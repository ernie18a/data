Calculation: Session range high = highest high during the configured range window
Calculation: Session range low = lowest low during the configured range window
Calculation: Session range width = session range high - session range low
Long: close > session range high + breakout buffer AND session range width is within the configured acceptable range AND time is within the configured trade window AND no trade has been entered that day
Short: close < session range low - breakout buffer AND session range width is within the configured acceptable range AND time is within the configured trade window AND no trade has been entered that day
Exit: long, low <= session range low OR high >= entry price + configured multiple of session range width
Exit: short, high >= session range high OR low <= entry price - configured multiple of session range width