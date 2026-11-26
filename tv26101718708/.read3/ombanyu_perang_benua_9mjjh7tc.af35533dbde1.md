Calculation: Session membership = chart-bar opening timestamp’s UTC hour is within the configured start-inclusive, end-exclusive hour range, wrapping midnight when the start-hour parameter is greater than or equal to the end-hour parameter.
Calculation: Asia-session low = minimum low of chart bars in the current day that belong to the configured Asia session.
Calculation: Asia-session high = maximum high of chart bars in the current day that belong to the configured Asia session.
Calculation: London-session low = minimum low of chart bars in the current day that belong to the configured London session.
Calculation: NY final-hour low = minimum low of chart bars in the configured NY final-hour session; update it only when that session ends and retain it until the next such session ends.
Calculation: Long stop = latest completed NY final-hour low minus ATR(lookback parameter, chart bars) times stop-padding parameter, captured on the signal bar.
Calculation: Long target = signal-bar close plus (signal-bar close minus long stop) times reward-risk parameter.
Calculation: Short stop = current-day Asia-session high plus ATR(lookback parameter, chart bars) times stop-padding parameter, captured on the signal bar.
Calculation: Short target = signal-bar close minus (short stop minus signal-bar close) times reward-risk parameter.
Long: On the first confirmed chart bar outside the London session after the previous chart bar was inside it, long entries are enabled, Asia-session low and London-session low are defined and both are greater than or equal to the latest completed NY final-hour low, position is flat, and signal-bar close minus long stop exceeds minimum tick size.
Short: On the first confirmed chart bar outside the Asia session after the previous chart bar was inside it, short entries are enabled, Asia-session low is defined and less than the latest completed NY final-hour low, position is flat, and short stop minus signal-bar close exceeds minimum tick size.
Exit: long, low is less than or equal to the captured long stop OR high is greater than or equal to the captured long target.
Exit: short, high is greater than or equal to the captured short stop OR low is less than or equal to the captured short target.