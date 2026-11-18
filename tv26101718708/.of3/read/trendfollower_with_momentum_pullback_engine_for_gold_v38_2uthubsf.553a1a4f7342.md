Calculation: Trend MA = selected MA type(source parameter, lookback parameter), where type is SMA, EMA, WMA, RMA, HMA, ALMA(offset parameter, sigma parameter), or VWMA
Calculation: MA percent slope = (Trend MA - Trend MA[1]) / Trend MA[1] * 100
Calculation: RSI = RSI(close, lookback parameter)
Calculation: Upper zone = Trend MA * (1 + zone width parameter / 100)
Calculation: Lower zone = Trend MA * (1 - zone width parameter / 100)
Calculation: Clearance distance = Trend MA * zone width parameter / 100 * clearance factor parameter
Calculation: Bullish trend state = false initially; each bar set true if MA percent slope > impulse threshold parameter, then set false if MA percent slope < -impulse threshold parameter, then set false if close crosses below Trend MA; otherwise retain the prior state
Calculation: Bearish trend state = false initially; each bar set false if MA percent slope > impulse threshold parameter, then set true if MA percent slope < -impulse threshold parameter, then set false if close crosses above Trend MA; otherwise retain the prior state
Calculation: Zone clear state = true initially; each bar retain its prior value or set true if (Bullish trend state and high > Upper zone + Clearance distance) or (Bearish trend state and low < Lower zone - Clearance distance); after evaluating entries, set false when either entry signal occurs
Calculation: Bars since last entry signal = current bar index - last entry signal bar index; initialize the last entry signal bar index to 0 and update it on each long or short entry signal
Long: Bullish trend state[1] AND low[1] <= Upper zone[1] AND close[1] > Trend MA[1] AND Zone clear state[1] AND close > Trend MA AND MA percent slope > impulse threshold parameter AND Bars since last entry signal > minimum spacing parameter
Short: Bearish trend state[1] AND high[1] >= Lower zone[1] AND close[1] < Trend MA[1] AND Zone clear state[1] AND close < Trend MA AND MA percent slope < -impulse threshold parameter AND Bars since last entry signal > minimum spacing parameter
Exit: long, RSI crosses below overbought threshold parameter
Exit: short, RSI crosses above oversold threshold parameter