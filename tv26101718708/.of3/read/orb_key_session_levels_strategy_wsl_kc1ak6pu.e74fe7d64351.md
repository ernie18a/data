Calculation: ORB High = highest high of the current day's bars whose time is at or after opening range start and before opening range end
Calculation: ORB Low = lowest low of the current day's bars whose time is at or after opening range start and before opening range end
Calculation: ORB Mid = (ORB High + ORB Low) / 2
Calculation: Bars Above ORB High = number of consecutive bars ending at the previous bar on which close is above ORB High
Calculation: Bars Below ORB Low = number of consecutive bars ending at the previous bar on which close is below ORB Low
Calculation: Initial Long Stop = ORB Mid if stop method = S1; ORB Low if stop method = S2; entry price - fixed stop distance if stop method = S3
Calculation: Initial Short Stop = ORB Mid if stop method = S1; ORB High if stop method = S2; entry price + fixed stop distance if stop method = S3
Calculation: Long Target(R) = entry price + R * (entry price - Initial Long Stop)
Calculation: Short Target(R) = entry price - R * (Initial Short Stop - entry price)
Calculation: Last Pivot High(Tn) = value of the most recent confirmed PivotHigh(Tn high, swing lookback, swing lookback) computed on chart bars, where Tn high is the high of the last completed Tn bar
Calculation: Prior Pivot High(Tn) = value of the confirmed PivotHigh immediately before Last Pivot High(Tn)
Calculation: Last Pivot Low(Tn) = value of the most recent confirmed PivotLow(Tn low, swing lookback, swing lookback) computed on chart bars, where Tn low is the low of the last completed Tn bar
Calculation: Prior Pivot Low(Tn) = value of the confirmed PivotLow immediately before Last Pivot Low(Tn)
Calculation: FVG Threshold = if auto threshold switch = B1, (sum of (high - low) / low over all bars through the current bar) / (number of bars before the current bar); otherwise fixed FVG threshold
Long: entry mode = E1 AND close crosses above ORB High AND no entry earlier today
Short: entry mode = E1 AND close crosses below ORB Low AND no entry earlier today
Long: entry mode = E2 AND 1 <= Bars Above ORB High <= retest timeout AND low <= ORB High AND close > ORB High AND no entry earlier today
Long: entry mode = E3 AND 1 <= Bars Above ORB High <= retest timeout AND low <= ORB Mid AND close > ORB High AND no entry earlier today
Short: entry mode = E2 AND 1 <= Bars Below ORB Low <= retest timeout AND high >= ORB Low AND close < ORB Low AND no entry earlier today
Short: entry mode = E3 AND 1 <= Bars Below ORB Low <= retest timeout AND high >= ORB Mid AND close < ORB Low AND no entry earlier today
Exit: long, low <= Initial Long Stop
Exit: long, low <= entry price AND break-even switch = B1 AND highest high since entry through current bar >= Long Target(TP1 reward-to-risk)
Exit: long, high >= Long Target(TP1 reward-to-risk)
Exit: long, high >= Long Target(TP2 reward-to-risk)
Exit: long, high >= Long Target(TP3 reward-to-risk)
Exit: short, high >= Initial Short Stop
Exit: short, high >= entry price AND break-even switch = B1 AND lowest low since entry through current bar <= Short Target(TP1 reward-to-risk)
Exit: short, low <= Short Target(TP1 reward-to-risk)
Exit: short, low <= Short Target(TP2 reward-to-risk)
Exit: short, low <= Short Target(TP3 reward-to-risk)
Long: Last Pivot High(T1) > Prior Pivot High(T1) AND Last Pivot Low(T1) > Prior Pivot Low(T1)
Short: Last Pivot High(T1) < Prior Pivot High(T1) AND Last Pivot Low(T1) < Prior Pivot Low(T1)
Long: Last Pivot High(T2) > Prior Pivot High(T2) AND Last Pivot Low(T2) > Prior Pivot Low(T2)
Short: Last Pivot High(T2) < Prior Pivot High(T2) AND Last Pivot Low(T2) < Prior Pivot Low(T2)
Long: low > high[2] AND close[1] > high[2] AND (low - high[2]) / high[2] > FVG Threshold
Short: high < low[2] AND close[1] < low[2] AND (low[2] - high) / high > FVG Threshold