Calculation: T1 direction = sign of the latest nonzero close-to-close change, carried forward through unchanged closes and zero until a nonzero change occurs, using T1 observations available on the latest chart bar, including any still-forming T1 bar
Calculation: T1 volume sample = the latest stored-history-length available T1 observations on the latest chart bar, including any still-forming T1 bar
Calculation: Balance sample = T1 volume sample excluding its oldest omission-count observations
Calculation: Up volume = sum(T1 volume where T1 direction > 0 in the balance sample)
Calculation: Down volume = sum(T1 volume where T1 direction ≤ 0 in the balance sample)
Calculation: T1 CVD = sum(T1 volume × T1 direction over the T1 volume sample, calculated on chart bars)
Calculation: Chart CVD = selected rolling SUM, EMA, or SMA over its separate lookback of [volume × (open < close ? 1 : −1) × (max(high − low, minimum tick) − upper wick − lower wick) / max(high − low, minimum tick)] on chart bars including the current forming bar; upper wick = open < close ? high − close : high − open; lower wick = open < close ? open − low : close − low
Long: Up volume > Down volume
Short: Down volume > Up volume
Long: Chart CVD > 0
Short: Chart CVD < 0
Long: Chart CVD > Chart CVD[1]
Short: Chart CVD < Chart CVD[1]
Long: T1 CVD > 0
Short: T1 CVD < 0
Long: T1 CVD > T1 CVD[1]
Short: T1 CVD < T1 CVD[1]
Long: latest T1 volume ≥ mean(T1 volume in the balance sample) × volume-spike multiplier AND latest T1 direction > 0
Short: latest T1 volume ≥ mean(T1 volume in the balance sample) × volume-spike multiplier AND latest T1 direction < 0