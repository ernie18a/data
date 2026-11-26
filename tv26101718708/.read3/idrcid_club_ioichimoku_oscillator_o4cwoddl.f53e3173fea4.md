Calculation: Tenkan = Ichimoku Tenkan-sen(conversion length, T1 high and low on chart bars, last completed bar)
Calculation: Kijun = Ichimoku Kijun-sen(base length, T1 high and low on chart bars, last completed bar)
Calculation: SenkouA = Ichimoku Senkou Span A(Tenkan, Kijun)
Calculation: SenkouB = Ichimoku Senkou Span B(span B length, T1 high and low on chart bars, last completed bar)
Calculation: CloudTop = max(SenkouA[cloud shift length - 1], SenkouB[cloud shift length - 1])
Calculation: CloudBottom = min(SenkouA[cloud shift length - 1], SenkouB[cloud shift length - 1])
Calculation: Bias = close(T1, last completed bar) > CloudTop ? 1 : (close(T1, last completed bar) < CloudBottom ? -1 : Bias[1])
Calculation: InCloud = close(T1, last completed bar) >= CloudBottom AND close(T1, last completed bar) <= CloudTop
Calculation: Tolerance = ATR(ATR length, T1 bars, last completed bar) * ATR multiplier
Calculation: Layer1 = Bias == 1 ? close(T1, last completed bar) - CloudBottom : close(T1, last completed bar) - CloudTop
Calculation: Layer2 = Bias == 1 ? Layer1 + max(close(T1, last completed bar) - CloudTop[cloud shift length - 1], 0) : Layer1 + min(close(T1, last completed bar) - CloudBottom[cloud shift length - 1], 0)
Calculation: Layer3 = Bias == 1 ? Layer2 + max(Tenkan - Kijun, 0) : Layer2 + min(Tenkan - Kijun, 0)
Calculation: Layer4 = Bias == 1 ? Layer3 + max(SenkouA - SenkouB, 0) : Layer3 + min(SenkouA - SenkouB, 0)
Calculation: Prior = Bias[1] == -Bias ? 0 : Score[1]
Calculation: Score = (Bias == 1) ? (((Prior < 4) AND (close(T1, last completed bar) > CloudTop)) ? 1 + (Layer2 > Layer1 ? 1 : 0) + ((Tenkan >= Kijun AND (Tenkan > Tenkan[1] OR Kijun > Kijun[1])) ? 1 : 0) + (SenkouA >= SenkouB ? 1 : 0) : (Tenkan < Kijun - Tolerance ? 0 : Prior)) : ((Bias == -1) ? (((Prior > -4) AND (close(T1, last completed bar) < CloudBottom)) ? -1 - (Layer2 < Layer1 ? 1 : 0) - ((Tenkan <= Kijun AND (Tenkan < Tenkan[1] OR Kijun < Kijun[1])) ? 1 : 0) - (SenkouA <= SenkouB ? 1 : 0) : (Tenkan > Kijun + Tolerance ? 0 : Prior)) : Score[1])
Long: Score == 4 AND Score[1] != 4
Long: Score == 4 AND close(T1, last completed bar) > CloudTop AND InCloud[1]
Short: Score == -4 AND Score[1] != -4
Short: Score == -4 AND close(T1, last completed bar) < CloudBottom AND InCloud[1]
Exit: long, Score[1] == 4 AND Score != 4 AND Score != -4
Exit: short, Score[1] == -4 AND Score != -4 AND Score != 4
Exit: long, Score == 4 AND Kijun crosses above Tenkan
Exit: long, Score == 4 AND EMA(Layer4, EMA length) crosses above Layer4
Exit: short, Score == -4 AND Tenkan crosses above Kijun
Exit: short, Score == -4 AND Layer4 crosses above EMA(Layer4, EMA length)