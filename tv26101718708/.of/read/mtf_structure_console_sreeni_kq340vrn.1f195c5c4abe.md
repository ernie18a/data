Calculation: Side break = high > previous high and low < previous low, respectively; alternatively, use >= and <= when equality counts as a break. An inside bar breaks neither side; an outside bar breaks both.
Calculation: Setup = an inside bar with available ATR; optionally require the preceding bar to be outside and optionally require risk / ATR <= a threshold. ATR is the simple moving average of true range on the last completed bar of a configurable higher or chart timeframe; use the chart timeframe if the configured timeframe is lower. Freeze ATR at the setup bar. Risk is the larger of long and short trigger-to-stop distances. A new eligible inside bar replaces the current setup, except that an option retains the first inside bar while watching a consecutive run. A setup watches from the following bar until a break or replacement.
Calculation: Long stop = setup low minus an ATR buffer, or setup high minus an ATR multiple. Short stop = setup high plus an ATR buffer, or setup low plus an ATR multiple.
Calculation: Break = close beyond the watched setup high or low, or, alternatively, high above the setup high or low below the setup low. If a wick-mode bar breaks both sides, resolve its direction only when its close is beyond one of the setup boundaries; otherwise continue watching. The entry price is the broken boundary.
Calculation: Target = entry price plus, for a long, or minus, for a short, a configurable multiple of the entry-to-stop distance. Targets and stops are checked only after the break bar; a stop takes precedence over targets. A new setup replaces an active setup.
Long: On the chart timeframe or a configured higher timeframe, high breaks the previous high AND low does not break the previous low. For a higher timeframe, use either the last completed bar or the still-forming bar, according to the selected mode.
Short: On the chart timeframe or a configured higher timeframe, low breaks the previous low AND high does not break the previous high. For a higher timeframe, use either the last completed bar or the still-forming bar, according to the selected mode.
Long: On the chart timeframe or a configured higher timeframe, close > open OR close > previous high. For a higher timeframe, use either the last completed bar or the still-forming bar, according to the selected mode.
Short: On the chart timeframe or a configured higher timeframe, close < open OR close < previous low. For a higher timeframe, use either the last completed bar or the still-forming bar, according to the selected mode.
Long: A watched setup breaks upward.
Short: A watched setup breaks downward.
Exit: long, low <= long stop.
Exit: short, high >= short stop.
Exit: long, no target has been hit AND the current bar does not hit a target AND close < entry price.
Exit: short, no target has been hit AND the current bar does not hit a target AND close > entry price.
Exit: long, low > long stop AND high >= final target.
Exit: short, high < short stop AND low <= final target.