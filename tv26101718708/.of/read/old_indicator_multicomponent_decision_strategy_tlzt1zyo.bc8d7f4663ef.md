Calculation: ZLEMA(x,n) = 2*EMA(x,n) - EMA(EMA(x,n),n)
Calculation: bias(tf) = +1 if hlc3 > ZLEMA(hlc3,n) on timeframe tf, else -1. bias = bias(chart timeframe). biasHTF = bias(a timeframe higher than the chart, using the higher-timeframe bar still forming, built from chart bars up to the current one), with the same n.
Calculation: MACD = EMA(close,fast) - EMA(close,slow) with fast period < slow period; signal = EMA(MACD, signal period); hist = MACD - signal. histVote = +1 if (hist>=0 AND hist>hist[1]) OR (hist<0 AND hist>=hist[1]), else -1.
Calculation: rsiChange = RSI(close) - RSI(close)[1]. rsiVote = +1 if rsiChange > T, -1 if rsiChange < -T, else 0 (T > 0).
Calculation: candleVote = +1 if close>=open else -1. volumeVote = +1 if volume>=volume[1] else -1.
Calculation: the six votes are candleVote, volumeVote, biasHTF, histVote, rsiVote, bias. G = number of votes equal to +1. R = number of votes equal to -1. I = 6-G-R. S = max(G,R)/6.
Calculation: baseDecision, first matching rule applies: G>=4 -> green; R>=4 -> red; G==3 AND R==3 -> green if rsiChange>=c (c a small positive constant) else red; G==3 AND rsiVote==0 -> none; R>=G+I -> red; G>=R+I -> green; else none.
Calculation: decision = if close==close[1]: green if close[1]<open[1]; else red if close[1]>open[1] AND bias[1]==+1; else none. If close!=close[1]: baseDecision.
Calculation: falling = over the last m bars, count of bars with close<=close[1] is greater than count of bars with close>close[1].
Long: (on a confirmed bar) decision==green AND bias==+1 AND ((NOT falling AND S>t1) OR (falling AND rsiChange!=0 AND S>t2 AND S<1)), with t2>t1
Short: decision==red
Exit: long, (decision==red OR falling) AND NOT the Long condition