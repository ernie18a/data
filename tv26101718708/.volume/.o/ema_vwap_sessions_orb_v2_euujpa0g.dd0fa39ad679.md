Calculation: ORB high/low = highest high and lowest low during the configured opening-range session; use the finalized range after that session ends.
Calculation: Breakout pending = true after either breakout condition and remains true until either retest or failed-retest condition occurs.
Long: ORB session has ended AND low[2] < ORB high AND close[2] > ORB high AND low[1] > ORB high AND close[1] > ORB high AND close > low[1] AND low > ORB high
Short: ORB session has ended AND high[2] > ORB low AND close[2] < ORB low AND high[1] < ORB low AND close[1] < ORB low AND close < high[1] AND high < ORB low
Long: ORB session has ended AND close[1] > ORB high AND low <= ORB high AND close >= ORB high
Short: ORB session has ended AND close[1] < ORB low AND high >= ORB low AND close <= ORB low
Exit: long, Breakout pending AND close[1] > ORB high AND close < ORB high
Exit: short, Breakout pending AND close[1] < ORB low AND close > ORB low