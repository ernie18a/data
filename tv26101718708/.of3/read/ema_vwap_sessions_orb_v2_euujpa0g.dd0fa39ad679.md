Calculation: ORB upper = highest high of chart bars during the ORB session window, held until the next ORB session window
Calculation: ORB lower = lowest low of chart bars during the ORB session window, held until the next ORB session window
Calculation: Upper breakout = outside the ORB session window AND low[2] < ORB upper AND close[2] > ORB upper AND low[1] > ORB upper AND close[1] > ORB upper AND close > low[1] AND low > ORB upper
Calculation: Lower breakout = outside the ORB session window AND high[2] > ORB lower AND close[2] < ORB lower AND high[1] < ORB lower AND close[1] < ORB lower AND close < high[1] AND high < ORB lower
Calculation: Upper retest = close[1] > ORB upper AND low <= ORB upper AND close >= ORB upper
Calculation: Lower retest = close[1] < ORB lower AND high >= ORB lower AND close <= ORB lower
Calculation: Failed upper retest = outside the ORB session window AND pending ORB breakout AND close[1] > ORB upper AND close < ORB upper
Calculation: Failed lower retest = outside the ORB session window AND pending ORB breakout AND close[1] < ORB lower AND close > ORB lower
Calculation: Pending ORB breakout = false at the start of each ORB session window; true after either breakout; false after either outside-window retest or failed retest
Long: outside the ORB session window AND (Upper breakout OR (pending ORB breakout AND Upper retest) OR (breakout-only alert mode is disabled AND crosses(close, ORB upper)))
Short: outside the ORB session window AND (Lower breakout OR (pending ORB breakout AND Lower retest) OR (breakout-only alert mode is disabled AND crosses(close, ORB lower)))
Exit: long, Failed upper retest
Exit: short, Failed lower retest