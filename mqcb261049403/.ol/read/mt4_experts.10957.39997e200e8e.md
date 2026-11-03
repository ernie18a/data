Calculation: Entry Parabolic SAR = Parabolic SAR using entry settings on the chart timeframe's last completed bar
Calculation: Exit Parabolic SAR = Parabolic SAR using exit settings on the chart timeframe's last completed bar
Calculation: Initial stop distance = ATR on the chart timeframe's last completed bar × configured stop multiplier
Long: Entry Parabolic SAR < close AND Exit Parabolic SAR < close
Short: Entry Parabolic SAR > close AND Exit Parabolic SAR > close
Exit: Long, Exit Parabolic SAR > close OR low ≤ entry price − Initial stop distance OR high − entry price > Initial stop distance OR (Entry Parabolic SAR > close AND Exit Parabolic SAR > close)
Exit: Short, Exit Parabolic SAR < close OR high ≥ entry price + Initial stop distance OR entry price − low > Initial stop distance OR (Entry Parabolic SAR < close AND Exit Parabolic SAR < close)