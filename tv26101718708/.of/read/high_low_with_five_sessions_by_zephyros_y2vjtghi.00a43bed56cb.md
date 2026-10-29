Calculation: Active completed levels = each configured session’s High and Low from chart bars after that session closes, plus the High and Low of the last completed Daily, Weekly, or Monthly bar (higher timeframe); retain each level until its first touch or configured age limit, and omit period levels when their timeframe is lower than the chart timeframe.
Calculation: High-touch priority = highest category among active levels touched where current High >= level price; session < Daily < Weekly = Monthly; 0 if none.
Calculation: Low-touch priority = highest category among active levels touched where current Low <= level price; session < Daily < Weekly = Monthly; 0 if none.
Long: Low-touch priority > High-touch priority
Short: High-touch priority > Low-touch priority