Calculation: all bars are chart-timeframe bars; x[1]/x[2] = value on the previous bar / two bars ago; w = a short recent window that includes the current bar
Calculation: spread = high-low; avgspread = SMA(spread, lookback longer than volavg's); volavg = SMA(volume, N)
Calculation: wide = spread > a*avgspread (a>1); narrow = spread < b*avgspread (b<1)
Calculation: upbar = close>close[1]; downbar = close<close[1]
Calculation: pos = (close-low)/spread; q = quintile index of pos (1 = lowest fifth ... 5 = highest fifth); upclose = pos in the top zone of the bar; downclose = pos in the bottom zone of the bar (mirror of the top zone)
Calculation: volHigh = m1*volavg < volume <= m2*volavg (m2>m1>1); volVeryHigh = volume > m2*volavg
Calculation: RH(n) = (high-low[n])/(ATR(n)*sqrt(n)); RL(n) = (high[n]-low)/(ATR(n)*sqrt(n)); short-term periods n1<n2 and long-term periods n3<n4, with both short-term periods smaller than both long-term periods; hs = max(RH(n1),RH(n2)); ls = max(RL(n1),RL(n2)); hl = max(RH(n3),RH(n4)); major = +1 if hs-ls>1, -1 if hs-ls<-1, else 0
Calculation: upthrust = wide AND q in {1,2} AND hl>1 AND high>high[1] AND (hs>1 OR major>0) AND volume>volavg
Calculation: upthrustTrue = wide AND q==1 AND major>0 AND high>high[1] AND volume>volavg
Calculation: pseudoUpthrust = upbar[1] AND high>high[1] AND volume[1]>m*volavg (m>1) AND downbar AND downclose AND NOT upthrust
Calculation: lowVolTest = low==lowest(low,w) AND upclose AND volume<volume[1] AND volume<volume[2]
Calculation: revUp = major<0 AND upbar AND upclose AND volume>volume[1] AND volume>volavg AND wide AND downbar[1] AND downclose[1] AND hl<=1
Calculation: strength = downbar[1] AND upbar AND q>3 AND hl<=1 AND hs<=1 AND volume>volavg
Calculation: effortUp = high>high[1] AND low>low[1] AND close>close[1] AND upclose AND spread>avgspread AND volume>volavg
Calculation: effortDown = high<high[1] AND low<low[1] AND close<close[1] AND downclose AND wide AND volume>volume[1]
Long: revUp OR lowVolTest OR (upbar AND revUp[1]) OR (lowVolTest[1] AND upbar AND upclose)
Long: effortUp
Long: effortDown[1] AND ((upbar AND spread>avgspread) OR revUp OR strength)
Short: upthrust OR upthrustTrue
Short: effortDown
Short: effortUp[1] AND (upthrust OR (downbar AND (spread>avgspread OR (upthrust[1] AND (NOT narrow OR volHigh)))))
Short: upbar[1] AND high==highest(high,w) AND downbar AND NOT upclose AND volume>volavg AND major>0 AND hs>1 AND NOT wide AND NOT pseudoUpthrust
Exit: long, upthrustTrue