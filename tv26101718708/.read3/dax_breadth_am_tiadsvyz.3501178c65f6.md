Calculation: TICK = COUNT(constituent close > constituent close[1]) - COUNT(constituent close < constituent close[1])
Calculation: CUM_TICK = running sum of TICK from session open through current bar, 0 outside session
Calculation: UP_VOLUME_SHARE = 100 * SUM(constituent volume where constituent close > constituent close[1]) / SUM(constituent volume)
Calculation: ADVANCING_SHARE = 100 * COUNT(constituent close > constituent close[1]) / constituent count
Calculation: NET_EMA = EMA(TICK / constituent count, smoothing lookback)
Calculation: COMPOSITE = 100 * (w_tick * TICK / constituent count + w_cum * clamp(CUM_TICK / cumulative scale, -1, 1) + w_net * NET_EMA + w_vol * (UP_VOLUME_SHARE - 50) / 50 + w_adv * (ADVANCING_SHARE - 50) / 50)
Long: (bars since session open <= early-session bars AND TICK >= early TICK threshold) OR (bars since session open > early-session bars AND TICK >= normal TICK threshold)
Long: CUM_TICK >= cumulative TICK threshold
Long: UP_VOLUME_SHARE >= up-volume high threshold
Long: ADVANCING_SHARE >= advancing-share high threshold
Long: NET_EMA >= net threshold
Long: COMPOSITE >= composite threshold
Long: UP_VOLUME_SHARE > up-volume high threshold AND CUM_TICK > CUM_TICK[1] AND ADVANCING_SHARE > advancing-share high threshold
Short: (bars since session open <= early-session bars AND TICK <= -early TICK threshold) OR (bars since session open > early-session bars AND TICK <= -normal TICK threshold)
Short: CUM_TICK <= -cumulative TICK threshold
Short: UP_VOLUME_SHARE <= up-volume low threshold
Short: ADVANCING_SHARE <= advancing-share low threshold
Short: NET_EMA <= -net threshold
Short: COMPOSITE <= -composite threshold
Short: high > MAX(high from session open to previous bar) AND CUM_TICK < CUM_TICK[1]