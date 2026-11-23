Calculation: ORB high = highest high of T1 bars opening within ORB duration after session start, on chart bars taking the last completed T1 bar
Calculation: ORB low = lowest low of T1 bars opening within ORB duration after session start, on chart bars taking the last completed T1 bar
Calculation: ORB active = bar is in session and at or after ORB window end
Calculation: long stop = (ORB high + ORB low) / 2 if stop placement is midpoint, otherwise ORB low
Calculation: short stop = (ORB high + ORB low) / 2 if stop placement is midpoint, otherwise ORB high
Long: close > ORB high AND bar is at or after ORB window end
Long: ORB active AND close > ORB high AND no close above ORB high earlier in session after ORB window
Long: entry mode = breakout AND ORB active AND close > ORB high AND no entry earlier in session
Long: ORB active AND low <= ORB high AND close > ORB high AND close above ORB high occurred earlier in session after ORB window AND no retest held earlier in session
Long: entry mode = retest AND ORB active AND low <= ORB high AND close > ORB high AND close above ORB high occurred earlier in session after ORB window AND no entry earlier in session
Short: close < ORB low AND bar is at or after ORB window end
Short: ORB active AND close < ORB low AND no close below ORB low earlier in session after ORB window
Short: entry mode = breakout AND ORB active AND close < ORB low AND no entry earlier in session
Short: ORB active AND high >= ORB low AND close < ORB low AND close below ORB low occurred earlier in session after ORB window AND no retest held earlier in session
Short: entry mode = retest AND ORB active AND high >= ORB low AND close < ORB low AND close below ORB low occurred earlier in session after ORB window AND no entry earlier in session
Exit: long, low <= long stop
Exit: long, high >= entry price + target 2 multiple * (entry price - long stop)
Exit: long, bar is last bar of session
Exit: short, high >= short stop
Exit: short, low <= entry price - target 2 multiple * (short stop - entry price)
Exit: short, bar is last bar of session