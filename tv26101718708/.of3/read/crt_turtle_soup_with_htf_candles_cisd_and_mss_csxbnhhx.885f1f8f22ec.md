Calculation: Waiting range(T1) = high and low of the last completed T1 bar that took a higher high or a lower low than the Waiting range before it
Calculation: Previous inside bar(T1) = the completed T1 bar immediately before the last completed T1 bar, if it lay inside the Waiting range(T1)
Calculation: CRT in play(T1) = a Waiting range(T1) or Previous inside bar(T1) that a completed T1 bar swept on one side and closed back inside, and that no later completed T1 bar has closed outside of
Calculation: Armed low(R, T2) = a T2 bar low below the low of R occurred after the last earlier T2 bar that closed above the low of R, the current T2 bar included
Calculation: Armed high(R, T2) = a T2 bar high above the high of R occurred after the last earlier T2 bar that closed below the high of R, the current T2 bar included
Calculation: Bullish FVG(minimum gap) = bar low above the high two bars earlier by at least the minimum gap; top = bar low, bottom = that high
Calculation: Bearish FVG(minimum gap) = bar high below the low two bars earlier by at least the minimum gap; top = that low, bottom = bar high
Calculation: Bullish iFVG(minimum gap) = a Bearish FVG that a later chart close has closed above its top; level = that top
Calculation: Bearish iFVG(minimum gap) = a Bullish FVG that a later chart close has closed below its bottom; level = that bottom
Calculation: Bullish OB(thickness multiple, average body length, OB lookback) = open of the last thick down-close chart bar since the previous Bullish OB was confirmed, provided the lowest low since the first thick down-close chart bar of that leg is below the lowest low of the OB lookback chart bars before that first bar; confirmed when a later chart close is above that open; thick = body at least the thickness multiple times the average body of the prior average-body-length bars
Calculation: Bearish OB(thickness multiple, average body length, OB lookback) = open of the last thick up-close chart bar since the previous Bearish OB was confirmed, provided the highest high since the first thick up-close chart bar of that leg is above the highest high of the OB lookback chart bars before that first bar; confirmed when a later chart close is below that open; thick as for Bullish OB
Calculation: Down-run open = open of the first down-close chart bar of the latest run of consecutive down-close chart bars
Calculation: Up-run open = open of the first up-close chart bar of the latest run of consecutive up-close chart bars
Calculation: Swing high(swing size) = high of a chart bar above the highs of the swing-size chart bars on each side of it, known once those bars have closed; Swing low(swing size) = low of a chart bar below the lows of those bars
Calculation: Trend bias(T1) = up or down from completed T1 bars; the reference is the last completed T1 bar that took a higher high or a lower low than the previous reference; a bar that took only the reference high is up if it closed above that high, else down; a bar that took only the reference low is down if it closed below that low, else up; a bar that took both is up above the reference high, down below the reference low, else unchanged; an inside bar keeps the previous bias
Long: the last completed T1 bar has low below the low of R, high not above the high of R, and close above the low of R, for any R among Waiting range(T1), Previous inside bar(T1) and CRT in play(T1); for Previous inside bar(T1) the last completed T1 bar also lies inside the Waiting range(T1)
Short: the last completed T1 bar has high above the high of R, low not below the low of R, and close below the high of R, for any R among Waiting range(T1), Previous inside bar(T1) and CRT in play(T1); for Previous inside bar(T1) the last completed T1 bar also lies inside the Waiting range(T1)
Long: the last completed T2 bar closes above the low of R and below the high of R, Armed low(R, T2) holds, no Short for R holds on this bar, and no Long from R is waiting or open; for R = CRT in play(T1) this suffices; for R = Waiting range(T1) or Previous inside bar(T1) it also requires that no CRT in play(T1) is Armed low, that R has not already given a Long, and for Previous inside bar(T1) that Waiting range(T1) is not Armed low
Short: the last completed T2 bar closes below the high of R and above the low of R, Armed high(R, T2) holds, no Long for R holds on this bar, and no Short from R is waiting or open; for R = CRT in play(T1) this suffices; for R = Waiting range(T1) or Previous inside bar(T1) it also requires that no CRT in play(T1) is Armed high, that R has not already given a Short, and for Previous inside bar(T1) that Waiting range(T1) is not Armed high
Long: a Long T1 marker holds on the last completed T1 bar and a Long entry condition held on a T2 bar within that same T1 bar, when the live-entry switch is off
Long: the chart low is at or below the level of the first Bullish OB confirmed after a low sweep of R whose level lies between the stop and the 100% level, tested from the chart bar after that confirmation
Long: the chart low is at or below the top of the first Bullish iFVG formed after a low sweep of R whose top lies between the stop and the 100% level, tested from the chart bar after that iFVG forms
Exit: long, the chart low is at or below the stop, where stop = the lowest T2 low of the sweep that opened the trade, less a buffer
Exit: long, the chart high is at or above the 50% level of the trade's range, the first time, only when the entry price is below that level
Exit: long, the chart high is at or above the high of the trade's range
Exit: long, the chart low is at or below the entry price, when breakeven after the 50% level is enabled and the 50% level has been reached
Exit: short, the chart high is at or above the stop, where stop = the highest T2 high of the sweep that opened the trade, plus a buffer
Exit: short, the chart low is at or below the 50% level of the trade's range, the first time, only when the entry price is above that level
Exit: short, the chart low is at or below the low of the trade's range
Exit: short, the chart high is at or above the entry price, when breakeven after the 50% level is enabled and the 50% level has been reached
Long: the last completed chart bar or completed T1 bar forms a Bullish FVG(minimum gap)
Short: the last completed chart bar or completed T1 bar forms a Bearish FVG(minimum gap)
Long: the last completed chart bar forms a Bullish iFVG(minimum gap)
Short: the last completed chart bar forms a Bearish iFVG(minimum gap)
Long: the last completed chart bar confirms a Bullish OB
Short: the last completed chart bar confirms a Bearish OB
Long: the last completed chart bar closes above the Down-run open, and the last CISD marker was not bullish
Short: the last completed chart bar closes below the Up-run open, and the last CISD marker was not bearish
Long: the last completed chart bar closes above the latest Swing high that no chart close has yet exceeded, and the last MSS marker was not bullish
Short: the last completed chart bar closes below the latest Swing low that no chart close has yet gone below, and the last MSS marker was not bearish
Long: Trend bias(T1) is up
Short: Trend bias(T1) is down
Long: the chart high is at or above the high of a completed T1 bar whose low a later bar took without taking its high, the first time after that sweep
Short: the chart low is at or below the low of a completed T1 bar whose high a later bar took without taking its low, the first time after that sweep