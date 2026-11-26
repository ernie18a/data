Calculation: LastPivotLow = low[m] for the smallest m >= pivot length such that low[m] <= low[j] for all j with m - pivot length <= j <= m + pivot length
Calculation: LastPivotHigh = high[m] for the smallest m >= pivot length such that high[m] >= high[j] for all j with m - pivot length <= j <= m + pivot length
Calculation: LowSweep = low < LastPivotLow AND close > LastPivotLow
Calculation: HighSweep = high > LastPivotHigh AND close < LastPivotHigh
Calculation: InSession = bar time (session time zone) is within the AM session, PM session, Silver Bullet AM session, Silver Bullet PM session, or London Silver Bullet session if enabled
Calculation: BullFVG = low > high[2] AND low - high[2] >= ATR(high, low, close, ATR lookback) * displacement multiple AND InSession AND (sweep not required OR LowSweep[a] for some a with 0 <= a <= sweep window)
Calculation: BearFVG = high < low[2] AND low[2] - high >= ATR(high, low, close, ATR lookback) * displacement multiple AND InSession AND (sweep not required OR HighSweep[a] for some a with 0 <= a <= sweep window)
Calculation: RecentFVGs(n) = number of j with 0 <= j < n for which BullFVG[j] OR BearFVG[j] is true
Calculation: LowQuality = quality tiers enabled AND LOW suppression enabled AND bar time of day (session time zone) >= MED-end time
Calculation: BullCE = (low + high[2]) / 2
Calculation: BearCE = (low[2] + high) / 2
Calculation: CEalerts = number of long or short CE tap alerts fired on earlier chart bars within the T1 bar still forming
Long: BullFVG
Short: BearFVG
Long: for some n >= 1, BullFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[j] >= high[n+2] for all 0 <= j < n AND low <= BullCE[n] <= high AND no j with 1 <= j < n has low[j] <= BullCE[n] <= high[j] AND CEalerts < daily CE cap
Short: for some n >= 1, BearFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[j] <= low[n+2] for all 0 <= j < n AND low <= BearCE[n] <= high AND no j with 1 <= j < n has low[j] <= BearCE[n] <= high[j] AND CEalerts < daily CE cap
Long: for some n >= 1, BullFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[j] >= high[n+2] for all 0 <= j < n AND high >= high[n+2] AND low <= low[n] AND no j with 1 <= j < n has high[j] >= high[n+2] AND low[j] <= low[n]
Short: for some n >= 1, BearFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[j] <= low[n+2] for all 0 <= j < n AND high >= high[n] AND low <= low[n+2] AND no j with 1 <= j < n has high[j] >= high[n] AND low[j] <= low[n+2]
Long: for some n >= 1, BearFVG[n] AND RecentFVGs(n) < max tracked gaps AND close > low[n+2] AND close[j] <= low[n+2] for all 1 <= j < n
Short: for some n >= 1, BullFVG[n] AND RecentFVGs(n) < max tracked gaps AND close < high[n+2] AND close[j] >= high[n+2] for all 1 <= j < n
Long: for some n >= 1 and some p with 1 <= p < n, BearFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[p] > low[n+2] AND close[j] <= low[n+2] for all p < j < n AND high >= high[n] AND low <= low[n+2] AND no j with 1 <= j < p has high[j] >= high[n] AND low[j] <= low[n+2]
Short: for some n >= 1 and some p with 1 <= p < n, BullFVG[n] AND RecentFVGs(n) < max tracked gaps AND NOT LowQuality[n] AND close[p] < high[n+2] AND close[j] >= high[n+2] for all p < j < n AND high >= high[n+2] AND low <= low[n] AND no j with 1 <= j < p has high[j] >= high[n+2] AND low[j] <= low[n]
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance