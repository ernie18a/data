Calculation: VIX regime = PANIC if VIX close on T1 > panic threshold; otherwise RISK OFF if VIX close on T1 > risk-off threshold AND VIX close on T1 > EMA of VIX close on T1 using EMA length; otherwise RISK ON if VIX close on T1 < risk-on threshold AND VIX close on T1 < EMA of VIX close on T1 using EMA length; otherwise NEUTRAL
Long: VIX regime is RISK ON AND prior-bar VIX regime differs
Short: VIX regime is RISK OFF AND prior-bar VIX regime differs
Short: VIX regime is PANIC AND prior-bar VIX regime differs