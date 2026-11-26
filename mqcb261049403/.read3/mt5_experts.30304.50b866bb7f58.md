Calculation: distance to T1 high = high(T1, bar still forming) − current ask, sampled on chart bars
Calculation: distance from T1 low = current bid − low(T1, bar still forming), sampled on chart bars
Calculation: trigger range = ATR(lookback, T1, last completed bar) × trigger percentage
Calculation: remaining range = ATR(lookback, T1, last completed bar) × (1 − trigger percentage)
Long: distance from T1 low > trigger range AND no trade has been opened since midnight
Short: distance to T1 high > trigger range AND distance from T1 low ≤ trigger range AND no trade has been opened since midnight
Long: distance to T1 high < distance from T1 low
Short: distance to T1 high ≥ distance from T1 low
Exit: long, low ≤ entry price − trigger range OR high ≥ entry price + remaining range OR datetime reaches midnight
Exit: short, high ≥ entry price + trigger range OR low ≤ entry price − remaining range OR datetime reaches midnight