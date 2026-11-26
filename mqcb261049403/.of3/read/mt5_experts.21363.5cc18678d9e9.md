Calculation: BrainTrend2 color index = BrainTrend2(open, high, low, close, spread, ATR lookback, weight-normalization parameter, width multiplier)
Long: Absolutely No Lag LWMA(close, lookback)[0] > Absolutely No Lag LWMA(close, lookback)[1] on chart bars
Short: Absolutely No Lag LWMA(close, lookback)[0] < Absolutely No Lag LWMA(close, lookback)[1] on chart bars
Long: BrainTrend2 color index <2 on chart bars
Short: BrainTrend2 color index >2 on chart bars
Long: BrainTrend2 color index[signal offset] <2 AND BrainTrend2 color index[signal offset + 1] >1 on chart bars
Short: BrainTrend2 color index[signal offset] >2 AND BrainTrend2 color index[signal offset + 1] <3 on chart bars
Long: On each T1 bar close, BrainTrend2 color index >1 AND the previous T1 bar's BrainTrend2 color index <2
Short: On each T1 bar close, BrainTrend2 color index <3 AND the previous T1 bar's BrainTrend2 color index >2
Exit: short, On each T1 bar close, the previous T1 bar's BrainTrend2 color index <2 AND BrainTrend2 color index <2
Exit: long, On each T1 bar close, the previous T1 bar's BrainTrend2 color index >2 AND BrainTrend2 color index >2
Long: On each T2 bar close, Absolutely No Lag LWMA color index !=2 AND the previous T2 bar's Absolutely No Lag LWMA color index ==2
Short: On each T2 bar close, Absolutely No Lag LWMA color index !=0 AND the previous T2 bar's Absolutely No Lag LWMA color index ==0
Exit: short, On each T2 bar close, the previous T2 bar's Absolutely No Lag LWMA color index ==2 AND Absolutely No Lag LWMA color index ==2
Exit: long, On each T2 bar close, the previous T2 bar's Absolutely No Lag LWMA color index ==0 AND Absolutely No Lag LWMA color index ==0