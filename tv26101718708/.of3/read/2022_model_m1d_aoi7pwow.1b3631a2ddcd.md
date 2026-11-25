Calculation: Threshold = P, or F * (high - low) of the last completed T4 bar
Calculation: ChartSellSweep = most recent chart bar s with low_s < L < close_s, where L = PivotLow(low, S, S) confirmed by s and no low below L from its confirmation through s-1; level = L
Calculation: ChartBuySweep = most recent chart bar s with high_s > H > close_s, where H = PivotHigh(high, S, S) confirmed by s and no high above H from its confirmation through s-1; level = H
Long: first bar after ChartSellSweep where close - min(low from ChartSellSweep through this bar) >= Threshold AND bars since ChartSellSweep <= W + 1 AND min(close from ChartSellSweep through this bar) >= ChartSellSweep level
Short: first bar after ChartBuySweep where max(high from ChartBuySweep through this bar) - close >= Threshold AND bars since ChartBuySweep <= W + 1 AND max(close from ChartBuySweep through this bar) <= ChartBuySweep level
Calculation: SwingHigh_T[p] = on T bars ([1] = last completed T bar), high_T[p] > high_T[p-1] AND high_T[p] > high_T[p+1] AND ((close_T[p+1] > open_T[p+1] AND close_T[p] < open_T[p]) OR (close_T[p] > open_T[p] AND close_T[p-1] < open_T[p-1])), for 2 <= p <= K_T
Calculation: SwingLow_T[p] = on T bars ([1] = last completed T bar), low_T[p] < low_T[p-1] AND low_T[p] < low_T[p+1] AND ((close_T[p+1] < open_T[p+1] AND close_T[p] > open_T[p]) OR (close_T[p] < open_T[p] AND close_T[p-1] > open_T[p-1])), for 2 <= p <= K_T
Calculation: BullMSS_T = at each new T bar, exists p with SwingHigh_T[p] AND close_T[1] > high_T[p] AND close_T[n] <= high_T[p] for every n from 2 to p-1
Calculation: BearMSS_T = at each new T bar, exists p with SwingLow_T[p] AND close_T[1] < low_T[p] AND close_T[n] >= low_T[p] for every n from 2 to p-1
Calculation: AvgRange_T = mean of (high_T[n] - low_T[n]) for n = 1 to M_T
Calculation: BullGap_T = at each new T bar, low_T[1] > high_T[3] AND low_T[1] - high_T[3] >= A * AvgRange_T AND close_T[2] > open_T[2] AND close_T[2] - open_T[2] >= D * AvgRange_T
Calculation: BearGap_T = at each new T bar, high_T[1] < low_T[3] AND low_T[3] - high_T[1] >= A * AvgRange_T AND close_T[2] < open_T[2] AND open_T[2] - close_T[2] >= D * AvgRange_T
Calculation: BullSB_T = at each new T bar, close_T[3] > open_T[3] AND close_T[2] > open_T[2] AND close_T[1] > open_T[1] AND open_T[2] > close_T[3] AND open_T[1] > close_T[2] AND open_T[1] - close_T[3] >= A * AvgRange_T AND consecutive opens of T bars 1 to 3 are at most G T-bar lengths apart
Calculation: BearSB_T = at each new T bar, close_T[3] < open_T[3] AND close_T[2] < open_T[2] AND close_T[1] < open_T[1] AND open_T[2] < close_T[3] AND open_T[1] < close_T[2] AND close_T[3] - open_T[1] >= A * AvgRange_T AND consecutive opens of T bars 1 to 3 are at most G T-bar lengths apart
Calculation: SellSweep_T = at each new T bar, the nearest p with 3 <= p <= K_T such that low_T[p] < low_T[p-1] AND low_T[p] < low_T[p+1] AND low_T[1] < low_T[p] < close_T[1] AND low_T[n] >= low_T[p] for every n from 2 to p-1; value = p
Calculation: BuySweep_T = at each new T bar, the nearest p with 3 <= p <= K_T such that high_T[p] > high_T[p-1] AND high_T[p] > high_T[p+1] AND high_T[1] > high_T[p] > close_T[1] AND high_T[n] <= high_T[p] for every n from 2 to p-1; value = p
Long: chart < T1 AND BullMSS_T1
Long: chart < T2 < T1 AND BullMSS_T2
Long: chart < T3 < T1 AND BullMSS_T3
Short: chart < T1 AND BearMSS_T1
Short: chart < T2 < T1 AND BearMSS_T2
Short: chart < T3 < T1 AND BearMSS_T3
Long: chart < T1 AND (BullGap_T1 OR BullSB_T1)
Long: chart < T2 < T1 AND (BullGap_T2 OR BullSB_T2)
Long: chart < T3 < T1 AND (BullGap_T3 OR BullSB_T3)
Short: chart < T1 AND (BearGap_T1 OR BearSB_T1)
Short: chart < T2 < T1 AND (BearGap_T2 OR BearSB_T2)
Short: chart < T3 < T1 AND (BearGap_T3 OR BearSB_T3)
Long: chart < T1 AND SellSweep_T1 defined AND correlated low_T1[1] >= correlated low_T1[SellSweep_T1] AND correlated T1 bar and chart T1 bar open at the same time
Short: chart < T1 AND BuySweep_T1 defined AND correlated high_T1[1] <= correlated high_T1[BuySweep_T1] AND correlated T1 bar and chart T1 bar open at the same time
Long: chart close >= open of the forming T4 bar
Short: chart close < open of the forming T4 bar