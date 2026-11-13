Calculation: NW(src) = Nadaraya-Watson kernel regression of src on the chart timeframe: weighted average of src over recent bars, where the weight of the bar i bars back is (1 + i^2/(2*alpha*h^2))^(-alpha), h = lookback window, alpha = relative weighting
Calculation: Band = NW(close) +/- F * ATR_nw, where ATR_nw = Wilder RMA of true range computed on the series NW(high), NW(low), NW(close) (true range = max(NW(high)-NW(low), |NW(high)-prior NW(close)|, |NW(low)-prior NW(close)|)), F = a fixed multiplier; Upper = NW(close) + F*ATR_nw, Lower = NW(close) - F*ATR_nw
Calculation: SMI = 200 * DEMA_smooth(close - (HH+LL)/2) / DEMA_smooth(HH-LL), where HH = highest high and LL = lowest low over a lookback of bars on a timeframe higher than the chart, taken from the still-forming higher-timeframe bar, and DEMA_smooth(x) = EMA(EMA(x, n), n) with n shorter than the HH/LL lookback; the numerator close is the chart-timeframe close
Calculation: SMI_sig = EMA of SMI over chart bars
Long: close < Lower AND SMI crosses above SMI_sig AND SMI < -T
Short: close > Upper AND SMI crosses below SMI_sig AND SMI > +T
Exit: long, close crosses above Upper OR low <= entry price - fixed stop distance
Exit: short, close crosses below Lower OR high >= entry price + fixed stop distance