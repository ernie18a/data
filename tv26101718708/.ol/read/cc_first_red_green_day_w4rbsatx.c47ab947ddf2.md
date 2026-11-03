Calculation: Signal bars = completed bars of the signal timeframe when it is higher than the chart timeframe; otherwise completed chart-timeframe bars.
Calculation: Red day = signal-bar close below its prior close, below its open, or both, according to the selected red/green definition; green day is the corresponding above comparison.
Calculation: FRD setup = the highest high in the longer of the extreme-lookback and arm-duration windows is within the arm duration, at least the minimum number of closes in the shorter run-count window ending at that peak are higher than their prior closes, and the first red day on or after the peak exists; FRD signal day = that first red day is the current signal bar. FGD setup and signal day are the mirror using the lowest low and lower closes.
Calculation: MA = the selected SMA or EMA of close on the MA timeframe; when that timeframe is higher than the chart, use its last completed bar, otherwise evaluate at chart-bar close.
Calculation: Normalized MA slope = (current MA − MA at the longer slope lookback) / ATR over that lookback timeframe; use the last completed MA-timeframe bar when it is higher than the chart, otherwise evaluate at chart-bar close.
Calculation: FRD armed = FRD setup remains within the arm duration and has not already fired for that peak; FGD armed = the mirror for a trough.
Calculation: Swing high/low = a pivot high/low with the selected number of bars on each side; confirmed when the required bars on both sides have completed.
Short: FRD signal day AND FRD armed
Long: FGD signal day AND FGD armed
Short: FRD armed AND close below MA AND a cross below MA occurs now or within the allowed gap before the FRD signal day AND normalized MA slope is below its maximum
Long: FGD armed AND close above MA AND a cross above MA occurs now or within the allowed gap before the FGD signal day AND normalized MA slope is above the negative maximum
Short: A signal bar is forming red after the prior completed signal bars have at least the minimum consecutive higher closes, and the current forming signal bar makes or matches the highest high in the extreme-lookback window
Long: A signal bar is forming green after the prior completed signal bars have at least the minimum consecutive lower closes, and the current forming signal bar makes or matches the lowest low in the extreme-lookback window
Short: Close below the latest unbroken swing low
Long: Close above the latest unbroken swing high
Short: Close below the FRD trigger level within the zone duration, before the setup is invalidated by a close above the peak or an FGD confirmation, and the zone has never been touched if the no-touch option is enabled
Long: Close above the FGD trigger level within the zone duration, before the setup is invalidated by a close below the trough or an FRD confirmation, and the zone has never been touched if the no-touch option is enabled