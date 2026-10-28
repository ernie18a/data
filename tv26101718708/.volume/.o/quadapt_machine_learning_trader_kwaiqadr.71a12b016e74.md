Calculation: Smoothed upper and lower envelopes (for each enabled length L) = E=EMA(close,L); D=EMA(abs(sin(z)×cos(z)),L)×abs(E), where z=0.68×(|close−E|/|E|)²+1.79×(|close−E|/|E|); upper=EMA(max(close,E+D),L); lower=EMA(min(close,E−D),L)
Calculation: Wedge = lower envelope has risen and upper envelope has fallen over max(1,floor(L/5)) bars
Calculation: Signal trigger = envelope range (upper−lower) was falling over L bars on the prior bar and is no longer falling on the current bar
Long: Signal trigger AND close above lower envelope AND NOT Wedge, on the primary length, the secondary (shorter) length, or both as required by the selected signal mode; the primary length is longer than the secondary
Short: Signal trigger AND close below upper envelope AND NOT Wedge, on the primary length, the secondary (shorter) length, or both as required by the selected signal mode; the primary length is longer than the secondary
Exit: Long, low <= active stop-loss level OR all active take-profit levels have been reached
Exit: Short, high >= active stop-loss level OR all active take-profit levels have been reached