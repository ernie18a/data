Calculation: NonLagMA(x, L) = sum over k=0..(4*L+L-1)-1 of w_k*x[k bars back] / sum of w_k (k=0 is the current bar; returns x unchanged if L<3 or fewer than 3 bars exist). With P=L-1: t_k = k/(P-1) if k<=P-1, otherwise t_k = 1+(k-P+1)*7/(4*L-1); w_k = cos(pi*t_k) * g, where g=1 if t_k<=0.5, otherwise g=1/(3*pi*t_k+1)
Calculation: MACD = NonLagMA(close, short length) - NonLagMA(close, long length)
Calculation: Signal = NonLagMA(MACD, signal length), where signal length is shorter than the long length
Calculation: OSMA = MACD - Signal
Long: OSMA > 0 (MACD above Signal; the entry is the bar where OSMA turns from <=0 to >0)
Short: OSMA < 0 (MACD below Signal; the entry is the bar where OSMA turns from >=0 to <0)