Calculation: PreviousHigh(T) = high of the last completed bar of T, taken on chart bars
Calculation: PreviousLow(T) = low of the last completed bar of T, taken on chart bars
Calculation: PreviousOpen(T) = open of the last completed bar of T, taken on chart bars
Calculation: CurrentOpen(T) = open of the bar of T still forming, taken on chart bars
Calculation: AllTimeHigh(T, all-time lookback) = highest high over the last all-time lookback bars of T including the bar still forming, taken on chart bars; if NA, highest chart-bar high since the first chart bar
Calculation: AllTimeLow(T, all-time lookback) = lowest low over the last all-time lookback bars of T including the bar still forming, taken on chart bars; if NA, lowest chart-bar low since the first chart bar
Calculation: OpeningRangeHigh(OR length) = highest high of chart bars within the forming T1 bar whose bar time is in [session open, session open + OR length)
Calculation: OpeningRangeLow(OR length) = lowest low of chart bars within the forming T1 bar whose bar time is in [session open, session open + OR length)
Calculation: PremarketHigh = highest high of chart bars within the forming T1 bar whose bar time is in premarket window
Calculation: PremarketLow = lowest low of chart bars within the forming T1 bar whose bar time is in premarket window
Calculation: UpBreak(level, mode) = (mode = touch AND high >= level AND high[1] < level) OR (mode = close break AND close > level AND close[1] <= level) OR (mode = confirmed break AND close > level + buffer AND close[1] <= level), with buffer = buffer multiple x (ATR(ATR length) if available, else close x ATR fallback fraction)
Calculation: DownBreak(level, mode) = (mode = touch AND low <= level AND low[1] > level) OR (mode = close break AND close < level AND close[1] >= level) OR (mode = confirmed break AND close < level - buffer AND close[1] >= level), with buffer = buffer multiple x (ATR(ATR length) if available, else close x ATR fallback fraction)
Calculation: Cooldown(signal, cooldown length) = signal AND bars since Cooldown was last true >= cooldown length
Long: Cooldown((OR enabled) AND chart shorter than T1 AND bar time >= session open + OR length AND (session filter off OR bar in session window) AND UpBreak(OpeningRangeHigh(OR length), alert mode), cooldown length)
Long: Cooldown((premarket enabled) AND chart shorter than T1 AND (session filter off OR bar in session window) AND UpBreak(PremarketHigh, alert mode), cooldown length)
Long: Cooldown((current-open enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(CurrentOpen(T1), alert mode), cooldown length)
Long: Cooldown((prev-day-open enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousOpen(T1), alert mode), cooldown length)
Long: Cooldown((prev-day enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousHigh(T1), alert mode), cooldown length)
Long: Cooldown((prev-week enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousHigh(T2), alert mode), cooldown length)
Long: Cooldown((prev-month enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousHigh(T3), alert mode), cooldown length)
Long: Cooldown((prev-quarter enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousHigh(T4), alert mode), cooldown length)
Long: Cooldown((prev-year enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(PreviousHigh(T5), alert mode), cooldown length)
Long: Cooldown((all-time-high enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND UpBreak(AllTimeHigh(T3, all-time lookback), alert mode), cooldown length)
Short: Cooldown((OR enabled) AND chart shorter than T1 AND bar time >= session open + OR length AND (session filter off OR bar in session window) AND DownBreak(OpeningRangeLow(OR length), alert mode), cooldown length)
Short: Cooldown((premarket enabled) AND chart shorter than T1 AND (session filter off OR bar in session window) AND DownBreak(PremarketLow, alert mode), cooldown length)
Short: Cooldown((current-open enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(CurrentOpen(T1), alert mode), cooldown length)
Short: Cooldown((prev-day-open enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousOpen(T1), alert mode), cooldown length)
Short: Cooldown((prev-day enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousLow(T1), alert mode), cooldown length)
Short: Cooldown((prev-week enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousLow(T2), alert mode), cooldown length)
Short: Cooldown((prev-month enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousLow(T3), alert mode), cooldown length)
Short: Cooldown((prev-quarter enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousLow(T4), alert mode), cooldown length)
Short: Cooldown((prev-year enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(PreviousLow(T5), alert mode), cooldown length)
Short: Cooldown((all-time-low enabled) AND (session filter off OR (chart shorter than T1 AND bar in session window)) AND DownBreak(AllTimeLow(T3, all-time lookback), alert mode), cooldown length)