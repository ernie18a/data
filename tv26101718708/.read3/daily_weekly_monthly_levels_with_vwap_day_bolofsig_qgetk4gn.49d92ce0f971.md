Calculation: Prior high/low on T1, T2, and T3 = high/low of the last completed bar on each timeframe, sampled on chart bars; T1 is shorter than T2, which is shorter than T3
Calculation: Session open = open of the first chart bar of the current session
Calculation: Range midpoint = (prior high on T1 + prior low on T1) / 2
Calculation: VWAP slope (%) = 100 × (VWAP(hlc3, session) − VWAP(hlc3, session)[slope lookback]) / VWAP(hlc3, session)[slope lookback]
Calculation: Current-month AVWAP = AVWAP(hlc3, volume, current calendar-month boundary), calculated on chart bars
Calculation: Prior-month AVWAP = AVWAP(hlc3, volume, prior calendar-month boundary), calculated on chart bars
Calculation: Earlier-month AVWAP = AVWAP(hlc3, volume, calendar-month boundary before the prior month), calculated on chart bars
Calculation: Uptrend = close > each EMA(close, separate lookback, T1, last completed bar) for five separate lookbacks AND close > each SMA(close, separate lookback, T1, last completed bar) for three separate lookbacks
Calculation: Latest session-high time = datetime of the latest chart bar whose high established a strict new high for the current session
Long: close > the same prior high on T1, T2, or T3 for the break-confirmation lookback consecutive chart bars AND the close immediately before that run was at or below that high
Long: close > a prior low on T1, T2, or T3 AND close[1] <= the same low
Long: For any prior high or low on T1, T2, or T3, close[1] > the level AND low <= the level AND close >= the level AND (NOT Uptrend OR current datetime − Latest session-high time <= recent-high age threshold)
Long: For any of the three month-start AVWAPs, (close[1] >= AVWAP AND low <= AVWAP AND close >= AVWAP) OR (close[1] < AVWAP AND close >= AVWAP), AND (NOT Uptrend OR current datetime − Latest session-high time <= recent-high age threshold)
Long: Session open > prior high on T1 × (1 + gap threshold)
Long: Session open > prior low on T1 AND session open < prior high on T1 AND session open > Range midpoint AND session open is not within the open-proximity tolerance of prior high on T1
Long: close > prior high on T1 AND VWAP slope > slope threshold AND close > VWAP(hlc3, session)
Long: All closes over the setup lookback chart bars were strictly below VWAP(hlc3, session) AND close > VWAP(hlc3, session) AND close > open AND close < prior high on T1
Long: All closes over the setup lookback chart bars were strictly above VWAP(hlc3, session) AND low <= VWAP(hlc3, session) × (1 + VWAP-test tolerance) AND close > VWAP(hlc3, session) AND close > open
Long: (A close has been above session open in the current session AND no close-below transition or low below session open has occurred since AND no open-held signal has fired this session AND session-open <= low <= session-open × (1 + open-test tolerance) AND close > session open AND close > open) OR (a close has been above session open in the current session AND no close-below transition has occurred since AND no open-wick-reclaim signal has fired this session AND low < session open AND close > session open AND close > open) OR (after a close below session open, this is the second consecutive chart-bar close above session open)
Long: For any prior high or low on T2 or T3, a chart-bar close has been above the level during the current session AND ((no low below the level has occurred this session AND level <= low <= level × (1 + HTF-test tolerance) AND close > level AND close > open) OR (low < level AND close > level AND close > open)); emit at most once per level per session for each pattern, reset when the session starts or the level changes, and require no same-bar prior-high break, prior-high rejection, failed-high sweep, prior-low break, or prior-low reclaim
Long: close > prior high on T1 AND VWAP slope is flat
Short: close < prior low on T1 AND VWAP slope < −slope threshold AND close < VWAP(hlc3, session)
Short: For any prior high on T1, T2, or T3, high >= the level AND close < the level AND high[1] < the level
Short: For any prior low on T1, T2, or T3, close < the level AND close[1] >= the same level
Short: For any prior high on T1, T2, or T3, close[1] > the level AND close < the level AND a confirmed prior-high break occurred within the sweep-window parameter
Short: All closes over the setup lookback chart bars were strictly above VWAP(hlc3, session) AND close < VWAP(hlc3, session) AND close < open AND close > prior low on T1
Short: Session open > prior low on T1 AND session open < prior high on T1 AND session open < Range midpoint AND session open is not within the open-proximity tolerance of prior low on T1
Exit: long, close > prior high on T1 AND NOT (VWAP slope > slope threshold AND close > VWAP(hlc3, session)) AND (VWAP slope is flat OR VWAP slope < −slope threshold)