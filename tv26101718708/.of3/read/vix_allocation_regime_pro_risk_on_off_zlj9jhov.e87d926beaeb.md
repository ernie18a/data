Calculation: Regime = panic if close(T1, still-forming bar) > panic threshold; otherwise risk-off if close(T1, still-forming bar) > risk-off threshold AND close(T1, still-forming bar) > EMA(close, EMA lookback, T1, still-forming bar); otherwise risk-on if close(T1, still-forming bar) < risk-on threshold AND close(T1, still-forming bar) < EMA(close, EMA lookback, T1, still-forming bar); otherwise neutral, evaluated on chart bars using values from T1
Long: Regime = risk-on AND Regime on the preceding chart bar != risk-on
Short: (Regime = risk-off AND Regime on the preceding chart bar != risk-off) OR (Regime = panic AND Regime on the preceding chart bar != panic)
Calculation: VIX regime = PANIC if VIX close on T1 > panic threshold; otherwise RISK OFF if VIX close on T1 > risk-off threshold AND VIX close on T1 > EMA of VIX close on T1 using EMA length; otherwise RISK ON if VIX close on T1 < risk-on threshold AND VIX close on T1 < EMA of VIX close on T1 using EMA length; otherwise NEUTRAL
Long: VIX regime is RISK ON AND prior-bar VIX regime differs
Short: VIX regime is RISK OFF AND prior-bar VIX regime differs
Short: VIX regime is PANIC AND prior-bar VIX regime differs