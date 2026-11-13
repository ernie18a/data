Calculation: median(x,n) = rolling median of x over the last n bars
Calculation: gauss(x,n) = recursive low-pass filter f = a*x + (1-a)*f[1], seeded with x on the first bar, where b = 2.415*(1-cos(2π/n))/(cos(2π/n)-1+sqrt(2)) and a = -b+sqrt(b^2+2b)
Calculation: smoothClose = gauss(median(close, m1), n_short); smoothVolume = gauss(median(volume, m1), n_short)
Calculation: amihud = (smoothClose - smoothClose[1]) / (smoothClose*smoothVolume), 0 if denominator is 0
Calculation: z = (amihud - SMA(amihud,N)) / stdev(amihud,N), with a tiny positive value used if stdev is 0
Calculation: div = ROC(smoothClose,N) - ROC(SMA(smoothVolume,N),N), where ROC is percent change over N bars
Calculation: raw = z*div; base = raw / stdev(raw, 2N)
Calculation: macro = median(gauss(base, n_long), m2), where n_long is longer than n_short and m2 is a short window
Calculation: scaled = 200*(macro - lowest(macro,L)) / (highest(macro,L) - lowest(macro,L)) - 100, 0 if the range is 0
Calculation: score = 100*tanh(scaled/100)
Calculation: stdS = stdev(score, L); upperExtreme = min(upper cap, positive base level + k*stdS); lowerExtreme = max(-upper cap, -(base level + k*stdS)), so the two thresholds are symmetric around 0
Long: score < lowerExtreme
Short: score > upperExtreme