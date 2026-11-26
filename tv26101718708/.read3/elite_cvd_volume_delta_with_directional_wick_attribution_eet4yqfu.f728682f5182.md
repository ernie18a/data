Calculation: Buy fraction = share of Volume credited to buyers under the chosen proxy method: classic = min(max((close - low) / (high - low), 0), 1); context-aware = if close >= open then (abs(close - open) + wick bias * (min(open, close) - low) + (1 - wick bias) * (high - max(open, close))) / (high - low), else 1 - (abs(close - open) + wick bias * (high - max(open, close)) + (1 - wick bias) * (min(open, close) - low)) / (high - low); blended = (classic + context-aware) / 2; all methods are 0.5 when high = low
Calculation: Session pass = false only when custom-session-only mode is on under the custom session basis and the bar is outside the custom session; otherwise true
Calculation: Relative volume = Volume / MA(Volume, baseline length)[1], where MA is EMA, SMA, or RMA by parameter
Calculation: Relative weight = 1 if weighting is off or Relative volume is undefined; otherwise sqrt(min(max(Relative volume, weight floor), weight cap))
Calculation: Volume delta = 0 if Session pass is false; otherwise (2 * Buy fraction - 1) * Volume * Relative weight
Calculation: Reset point = true on the first bar; in session mode also on the first chart bar of each new T1 period (exchange-day basis) or the first chart bar inside the custom session (custom-session basis); in block mode also on every block-length-th bar
Calculation: Cumulative delta = in session or block mode, sum of Volume delta from the latest Reset point through the current bar; in rolling mode, sum of Volume delta over the last block-length bars; in none mode, sum of Volume delta from the first bar
Calculation: Delta signal = MA(Cumulative delta, signal length), where MA is EMA restarted at each Reset point, SMA, or WMA by parameter; in session or block mode, SMA and WMA are undefined until the bars since the latest Reset point reach signal length
Calculation: Delta acceleration = (Volume delta - Volume delta[acceleration lookback]) * Volume delta > 0
Calculation: Delta scale = EMA(abs(Volume delta), scale length)
Calculation: Prior pivot high = most recent earlier PivotHigh(high, left bars, right bars) value taken at a pivot bar whose Session pass is true
Calculation: Prior pivot low = most recent earlier PivotLow(low, left bars, right bars) value taken at a pivot bar whose Session pass is true
Long: Cumulative delta crosses above 0
Short: Cumulative delta crosses below 0
Long: Cumulative delta crosses above Delta signal
Short: Cumulative delta crosses below Delta signal
Long: Cumulative delta >= 0
Short: Cumulative delta < 0
Long: Cumulative delta >= Delta signal
Short: Cumulative delta < Delta signal
Long: Volume delta >= 0
Short: Volume delta < 0
Long: Buy fraction >= 0.5
Short: Buy fraction < 0.5
Long: Relative volume >= spike threshold AND Volume delta > 0
Short: Relative volume >= spike threshold AND Volume delta < 0
Long: PivotLow(low, left bars, right bars) < Prior pivot low AND Cumulative delta[right bars] > Cumulative delta at Prior pivot low AND Cumulative delta[right bars] - Cumulative delta at Prior pivot low >= separation multiple * Delta scale[right bars] AND no Reset point between Prior pivot low and the current pivot AND bars from Prior pivot low to the current pivot <= max bars between pivots AND Session pass[right bars] = true
Short: PivotHigh(high, left bars, right bars) > Prior pivot high AND Cumulative delta[right bars] < Cumulative delta at Prior pivot high AND Cumulative delta at Prior pivot high - Cumulative delta[right bars] >= separation multiple * Delta scale[right bars] AND no Reset point between Prior pivot high and the current pivot AND bars from Prior pivot high to the current pivot <= max bars between pivots AND Session pass[right bars] = true
Short: Volume delta > 0 AND Delta acceleration[1] = true AND Delta acceleration = false
Long: Volume delta < 0 AND Delta acceleration[1] = true AND Delta acceleration = false