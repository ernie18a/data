Calculation: Selected-period Camarilla and CPR levels = use the last completed bar of the selected pivot period (daily, weekly, or monthly): range = high − low; CP = (high + low + close)/3; BC = (high + low)/2; TC = 2×CP − BC; R3/S3 = close ± range×k/4; R4/S4 = close ± range×k/2; R4.5 = R4 + 1.168×(R4−R3); S4.5 = S4 − 1.168×(S3−S4); for k=1.1, R5 = (high/low)×close and S5 = 2×close−R5; otherwise R5/S5 = close ± range×k.
Calculation: Anchored VWAP = volume-weighted average of HLC3 since the start of the current daily, weekly, monthly, or calendar-year period; use the still-forming period. If volume is unavailable or zero, use equal weights.
Calculation: Daily ATR = average true range over a longer lookback; use the last completed daily bar.
Calculation: Yearly VWAP standard deviation = volume-weighted standard deviation of HLC3 since the start of the current calendar year; use the still-forming year. Yearly bands = yearly VWAP ± one, two, or three standard deviations.
Long: Close > VWAP for any daily, weekly, monthly, or yearly anchor AND Close − that VWAP ≥ 0.15 × daily ATR.
Short: Close < VWAP for any daily, weekly, monthly, or yearly anchor AND that VWAP − Close ≥ 0.15 × daily ATR.
Long: Central pivot for the current selected period > central pivot for the previous selected period by at least one minimum price increment.
Short: Central pivot for the current selected period < central pivot for the previous selected period by at least one minimum price increment.
Long: Close > selected-period central pivot AND previous close ≤ selected-period central pivot.
Short: Close < selected-period central pivot AND previous close ≥ selected-period central pivot.
Long: Close > selected-period anchored VWAP AND previous close ≤ selected-period anchored VWAP.
Short: Close < selected-period anchored VWAP AND previous close ≥ selected-period anchored VWAP.
Long: Close > yearly VWAP AND previous close ≤ yearly VWAP.
Short: Close < yearly VWAP AND previous close ≥ yearly VWAP.
Long: Close > any yearly VWAP band AND previous close ≤ that band.
Short: Close < any yearly VWAP band AND previous close ≥ that band.
Long: Low ≤ selected-period S3 OR S4 OR S4.5 OR S5.
Short: High ≥ selected-period R3 OR R4 OR R4.5 OR R5.
Long: High ≥ high of the last completed selected pivot-period bar.
Short: Low ≤ low of the last completed selected pivot-period bar.