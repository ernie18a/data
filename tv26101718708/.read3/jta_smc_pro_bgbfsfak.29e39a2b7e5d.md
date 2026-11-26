Calculation: Structure High = last non-na value of Pivot High(high, S, S)
Calculation: Structure Low = last non-na value of Pivot Low(low, S, S)
Calculation: Structure Bias = 0 before the first event; set to 1 on each bar where close crosses above Structure High AND Structure Bias[1] <= 0; set to -1 on each bar where close crosses below Structure Low AND Structure Bias[1] >= 0
Calculation: Active Bullish OBs = list of zones (high, low), updated each bar: on each bar where close crosses above Structure High AND Structure Bias[1] <= 0, append zone (high[i], low[i]) of the most recent bar i in 1..Q*S bars back with close[i] < open[i], if one exists; then drop the oldest zone if the list holds more than M zones; after each bar's decisions, drop every zone containing that bar's low
Calculation: Active Bearish OBs = list of zones (high, low), updated each bar: on each bar where close crosses below Structure Low AND Structure Bias[1] >= 0, append zone (high[i], low[i]) of the most recent bar i in 1..Q*S bars back with close[i] > open[i], if one exists; then drop the oldest zone if the list holds more than M zones; after each bar's decisions, drop every zone containing that bar's high
Calculation: Sweep High = last non-na value of Pivot High(high, W, W)
Calculation: Sweep Low = last non-na value of Pivot Low(low, W, W)
Calculation: Sweep Bias = Structure Bias on the latest bar where the Short sweep rule or the Long sweep rule holds; none before the first such bar
Calculation: Session High(Ki) = highest high of bars inside window Ki since window Ki last started
Calculation: Session Low(Ki) = lowest low of bars inside window Ki since window Ki last started
Calculation: Swing High 1 = most recent non-na value of Pivot High(high, R, R)
Calculation: Swing High 2 = non-na value of Pivot High(high, R, R) before Swing High 1
Calculation: Swing Low 1 = most recent non-na value of Pivot Low(low, R, R)
Calculation: Swing Low 2 = non-na value of Pivot Low(low, R, R) before Swing Low 1
Long: close crosses above Structure High AND Structure Bias[1] <= 0
Short: close crosses below Structure Low AND Structure Bias[1] >= 0
Long: low >= zone low AND low <= zone high for some zone in Active Bullish OBs
Short: high >= zone low AND high <= zone high for some zone in Active Bearish OBs
Long: low > high[2] AND low - high[2] >= K_fvg * ATR(A)
Short: high < low[2] AND low[2] - high >= K_fvg * ATR(A)
Short: high > Sweep High AND high - Sweep High >= K_sw * ATR(A) AND close <= Sweep High AND high - max(open, close) >= Wk * (high - low) AND (Sweep Bias is none OR Structure Bias != Sweep Bias)
Long: low < Sweep Low AND Sweep Low - low >= K_sw * ATR(A) AND close >= Sweep Low AND min(open, close) - low >= Wk * (high - low) AND (Sweep Bias is none OR Structure Bias != Sweep Bias)
Short: high > Session High(K1) for the first time since window K1 last started
Short: high > Session High(K2) for the first time since window K2 last started
Short: high > Session High(K3) for the first time since window K3 last started
Short: high > Session High(K4) for the first time since window K4 last started
Long: low < Session Low(K1) for the first time since window K1 last started
Long: low < Session Low(K2) for the first time since window K2 last started
Long: low < Session Low(K3) for the first time since window K3 last started
Long: low < Session Low(K4) for the first time since window K4 last started
Short: Pivot High(high, R, R) is confirmed on this bar AND abs(Swing High 1 - Swing High 2) <= K_pat * ATR(A) AND Swing Low 1 < min(Swing High 1, Swing High 2) - K_pat * ATR(A)
Long: Pivot Low(low, R, R) is confirmed on this bar AND abs(Swing Low 1 - Swing Low 2) <= K_pat * ATR(A) AND Swing High 1 > max(Swing Low 1, Swing Low 2) + K_pat * ATR(A)
Long: Structure Bias computed on T1 bars, taken from last completed T1 bar, > 0
Long: Structure Bias computed on T2 bars, taken from last completed T2 bar, > 0
Long: Structure Bias computed on T3 bars, taken from last completed T3 bar, > 0
Long: Structure Bias computed on T4 bars, taken from last completed T4 bar, > 0
Long: Structure Bias computed on T5 bars, taken from last completed T5 bar, > 0
Short: Structure Bias computed on T1 bars, taken from last completed T1 bar, < 0
Short: Structure Bias computed on T2 bars, taken from last completed T2 bar, < 0
Short: Structure Bias computed on T3 bars, taken from last completed T3 bar, < 0
Short: Structure Bias computed on T4 bars, taken from last completed T4 bar, < 0
Short: Structure Bias computed on T5 bars, taken from last completed T5 bar, < 0
Long: Structure Bias > 0
Short: Structure Bias < 0
Long: base-currency policy rate / quote-currency policy rate > 1, each the latest non-na value at the last completed T1 bar
Short: base-currency policy rate / quote-currency policy rate < 1, each the latest non-na value at the last completed T1 bar