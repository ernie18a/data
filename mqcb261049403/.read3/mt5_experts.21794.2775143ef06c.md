Calculation: Color1 = on T1 bars, rising when round(Smooth(PWMA(applied price1, period1, power1), smoothing method1, smoothing length1, phase1), digits1) is greater than its prior-bar value, falling when lower, otherwise retain the prior color; offset 0 is the forming bar and positive offsets are completed bars
Calculation: Color2 = on T2 bars, rising when round(Smooth(PWMA(applied price2, period2, power2), smoothing method2, smoothing length2, phase2), digits2) is greater than its prior-bar value, falling when lower, otherwise retain the prior color; offset 0 is the forming bar and positive offsets are completed bars
Calculation: Color3 = on T3 bars, rising when round(Smooth(PWMA(applied price3, period3, power3), smoothing method3, smoothing length3, phase3), digits3) is greater than its prior-bar value, falling when lower, otherwise retain the prior color; offset 0 is the forming bar and positive offsets are completed bars
Long: long-entry-enabled1 AND Color1[signal offset1] = rising AND Color1[signal offset1 + 1] != rising
Short: short-entry-enabled1 AND Color1[signal offset1] = falling AND Color1[signal offset1 + 1] != falling
Exit: long, long-exit-enabled1 AND Color1[signal offset1] = falling
Exit: short, short-exit-enabled1 AND Color1[signal offset1] = rising
Long: long-entry-enabled2 AND Color2[signal offset2] = rising AND Color2[signal offset2 + 1] != rising
Short: short-entry-enabled2 AND Color2[signal offset2] = falling AND Color2[signal offset2 + 1] != falling
Exit: long, long-exit-enabled2 AND Color2[signal offset2] = falling
Exit: short, short-exit-enabled2 AND Color2[signal offset2] = rising
Long: long-entry-enabled3 AND Color3[signal offset3] = rising AND Color3[signal offset3 + 1] != rising
Short: short-entry-enabled3 AND Color3[signal offset3] = falling AND Color3[signal offset3 + 1] != falling
Exit: long, long-exit-enabled3 AND Color3[signal offset3] = falling
Exit: short, short-exit-enabled3 AND Color3[signal offset3] = rising