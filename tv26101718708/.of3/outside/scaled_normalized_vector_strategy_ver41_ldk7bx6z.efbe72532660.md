Calculation: transformed relative close = configured transform of x, where x = close(T1)/close(T2)-1 and T1 and T2 are the lower and higher configured non-chart timeframes; the transform is leaky ReLU max(x,0)-P3*max(-x,0), step (1 if x>=0 else -1), Swish x/(1+exp(-x)), cumulative z-score (x-cum(x)/bar index)/sqrt((x-(cum(x)/bar index)/(bar index-1))^2), or x
Calculation: normalized Karobein Oscillator = 2*(Karobein Oscillator(selected source series, P1)-its all-time minimum)/(its all-time maximum-its all-time minimum)-1
Long: transformed relative close crosses above P2 AND normalized Karobein Oscillator > 0 AND current signal is not long
Short: transformed relative close crosses below -P2 AND normalized Karobein Oscillator < 0 AND current signal is not short
Exit: long, chart bars since last signal change = P4
Exit: short, chart bars since last signal change = P4