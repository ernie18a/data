Calculation: Session wick midpoint = (highest high during the analysis session + lowest low during the analysis session) / 2
Calculation: Session body midpoint = (max(analysis-session open, analysis-session close) + min(analysis-session open, analysis-session close)) / 2
Long: session complete = true AND entries today = 0 AND weekday = true AND close > session wick midpoint AND close > session body midpoint AND previous close <= session wick midpoint
Short: session complete = true AND entries today = 0 AND weekday = true AND close < session wick midpoint AND close < session body midpoint AND previous close >= session wick midpoint
Exit: long, low <= analysis-session low OR high >= entry price + (entry price - analysis-session low) * reward-to-risk multiple
Exit: short, high >= analysis-session high OR low <= entry price - (analysis-session high - entry price) * reward-to-risk multiple