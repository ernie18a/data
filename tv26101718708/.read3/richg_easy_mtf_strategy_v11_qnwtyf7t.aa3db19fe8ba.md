Long: open < close on chart bars taking values from the still-forming bar of any of T1, T2, T3, or T4
Short: open >= close on chart bars taking values from the still-forming bar of any of T1, T2, T3, or T4
Long: open < close on chart bars taking values from the still-forming bars of T1, T2, T3, and T4
Short: open >= close on chart bars taking values from the still-forming bars of T1, T2, T3, and T4
Exit: long, close < SMA(close, KC lookback) + SMA(true range, KC lookback) * KC factor
Exit: short, close > SMA(close, KC lookback) - SMA(true range, KC lookback) * KC factor