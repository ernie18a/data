Calculation: OsMA = (EMA of typical price with the shorter lookback minus EMA with the longer lookback) minus the signal-line EMA of that difference; typical price = (high+low+close)/3
Calculation: OsMA Bands = Bollinger Bands computed on the OsMA series: Upper/Lower = SMA(OsMA) +/- deviation multiplier x standard deviation of OsMA over the band lookback, which is longer than the OsMA MA lookback
Calculation: OsMA MA = simple moving average of OsMA with a shorter lookback than the band lookback
Calculation: BandState = persistent state (initial 0), updated once per new bar on the chart timeframe using the last completed bar L and the completed bar before it P. Step 1: set 0 if (BandState=+1 AND OsMA[P] >= OsMA MA[P] AND OsMA[L] < OsMA MA[L]) OR (BandState=-1 AND OsMA[P] <= OsMA MA[P] AND OsMA[L] > OsMA MA[L]). Step 2: if OsMA[P] <= Lower[P] AND OsMA[L] > Lower[L] set +1, else if OsMA[P] >= Upper[P] AND OsMA[L] < Upper[L] set -1
Calculation: StopLevel (long) = entry price minus a distance at entry, then raised to (current price minus distance) whenever that is higher than StopLevel, never lowered; StopLevel (short) = entry price plus distance, lowered to (current price plus distance) whenever that is lower, never raised; distance is fixed, or half of the high-low range of the last completed bar of a higher timeframe (daily)
Calculation: Close[n] = close of the n-th bar back from the forming bar (Close[1] = last completed bar)
Calculation: Reference = bid price at the moment neither a position nor pending orders exist
Calculation: Window = bar hour-of-day >= start hour AND < end hour (if start hour >= end hour: >= start OR < end)
Calculation: GridBase = price rounded to the nearest multiple of a fixed step, taken when no grid orders exist; resting buy limits at GridBase - k*step and sell limits at GridBase + k*step for k=1..N/2; any vacated level is refilled with a buy limit if below the current price or a sell limit if above
Long: flat AND BandState = +1
Short: flat AND BandState = -1
Long: flat AND Close[1] > Close[2] AND Close[2] > Close[3]
Short: flat AND Close[1] < Close[2] AND Close[2] < Close[3]
Long: flat AND Window AND (no earlier trade and the configured initial side is long OR last closed trade was long with profit >= 0 OR last closed trade was short with profit < 0; earlier-trade history is cleared when a position was closed by leaving the Window)
Short: flat AND Window AND (no earlier trade and the configured initial side is short OR last closed trade was short with profit >= 0 OR last closed trade was long with profit < 0; same history clearing)
Long: flat AND no open position AND high >= Reference + distance
Short: flat AND no open position AND low <= Reference - distance
Long: Window AND low <= price of a resting grid buy limit level
Short: Window AND high >= price of a resting grid sell limit level
Exit: long, BandState != +1 OR low <= StopLevel
Exit: short, BandState != -1 OR high >= StopLevel
Exit: long or short, NOT(Close[1] > Close[2] AND Close[2] > Close[3]) AND NOT(Close[1] < Close[2] AND Close[2] < Close[3])
Exit: long, high >= entry price + fixed take-profit distance OR low <= StopLevel OR NOT Window
Exit: short, low <= entry price - fixed take-profit distance OR high >= StopLevel OR NOT Window
Exit: long, high >= entry price + distance OR low <= entry price - distance
Exit: short, low <= entry price - distance OR high >= entry price + distance
Exit: long, low <= MA-StopLevel, where MA-StopLevel is ratcheted upward only to the simple moving average of close (shifted by one bar) whenever that average is below the current price and above the previous MA-StopLevel
Exit: short, high >= MA-StopLevel, where MA-StopLevel is ratcheted downward only to the simple moving average of close (shifted by one bar) whenever that average is above the current price and below the previous MA-StopLevel
Exit: long or short, a long and a short position are open at the same time (both closed against each other) OR NOT Window (close all)