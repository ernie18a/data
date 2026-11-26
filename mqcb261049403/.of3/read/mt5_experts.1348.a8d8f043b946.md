Calculation: plotted value = AMA(Momentum(applied price, indicator momentum lookback), indicator AMA lookback, indicator fast lookback, indicator slow lookback, indicator smoothing exponent) on chart bars
Calculation: expert value = AMA(Momentum(applied price, expert momentum lookback), expert AMA lookback, expert fast lookback, expert slow lookback, expert smoothing exponent) on T1 bars; chart-bar checks read completed T1 bars
Long: plotted value on the current chart bar > 0 AND plotted value on the current chart bar > plotted value on the previous chart bar
Short: plotted value on the current chart bar < 0 AND plotted value on the current chart bar < plotted value on the previous chart bar
Long: expert value one T1 bar ago < expert value two T1 bars ago AND expert value on the latest completed T1 bar > expert value one T1 bar ago AND long entries enabled
Short: expert value one T1 bar ago > expert value two T1 bars ago AND expert value on the latest completed T1 bar < expert value one T1 bar ago AND short entries enabled
Exit: long, expert value one T1 bar ago > expert value two T1 bars ago AND expert value on the latest completed T1 bar >= expert value one T1 bar ago AND long exits enabled
Exit: short, expert value one T1 bar ago < expert value two T1 bars ago AND expert value on the latest completed T1 bar <= expert value one T1 bar ago AND short exits enabled