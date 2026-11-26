Calculation: Short line = smooth(smooth(applied price 1, short first-pass method, lookback, phase), short second-pass method, lookback, phase), with each lookback shorter than the corresponding long-line lookback
Calculation: Long line = smooth(smooth(applied price 2, long first-pass method, lookback, phase), long second-pass method, lookback, phase), with each lookback longer than the corresponding short-line lookback
Long: Short line > Long line
Short: Short line < Long line
Long: On chart bars, Short line calculated from the T1 bar still forming > Long line calculated from the T1 bar still forming
Short: On chart bars, Short line calculated from the T1 bar still forming < Long line calculated from the T1 bar still forming