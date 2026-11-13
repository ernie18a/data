Calculation: DRSI = EMA(RSI(close, n), s) on chart-timeframe bars, with s shorter than n
Calculation: DSig = EMA(DRSI, m) on chart-timeframe bars, with m longer than s
Calculation: WRSI, WSig = the same RSI smoothing and signal calculations (RSI, EMA smoothing, EMA signal) computed on higher-timeframe bars aggregated from chart bars. At each chart bar use the value of the still-forming higher-timeframe bar. WRSI_prev = WRSI at the previous chart bar.
Calculation: RelVol = volume / SMA(volume, k)
Calculation: Drawdown% = (1 - close / highest(high, long lookback)) * 100
Calculation: DailyScore = 30*[buyLow <= DRSI <= buyHigh] + 20*[DRSI > DSig] + 15*[DRSI > DRSI at previous bar] + 20*[close > EMA(close, d)] + 15*[RelVol >= relVolMin]
Calculation: WeeklyScore = 35*[WRSI >= weeklyMin] + 25*[WRSI > WSig] + 15*[WRSI > WRSI_prev] + 25*[higher-timeframe forming-bar close > EMA of higher-timeframe closes (length w)]
Calculation: Composite = round(wD*DailyScore + wW*WeeklyScore), with wD > wW and wD + wW = 1. Thresholds satisfy HC > Approved. avoidHigh >= buyHigh. highVol > relVolMin.
Long: (Composite >= Approved AND Composite < HC AND DRSI <= avoidHigh) is true on this bar and was false on the previous bar (fires on the first bar of the state)
Long: (Composite >= HC AND DRSI > DSig AND WRSI > WSig AND RelVol >= highVol AND DRSI <= avoidHigh) is true on this bar and was false on the previous bar
Long: (Drawdown% >= extremeDrawdown AND WRSI <= extremeWeeklyMax AND DRSI <= extremeDailyMax AND DRSI > DRSI at previous bar) is true on this bar and was false on the previous bar