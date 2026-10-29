Calculation: Bullish candle = close > open AND close > previous close
Calculation: Bearish candle = close < open AND close < previous close
Calculation: Volume spike = previous bar volume >= the simple moving average of volume on the previous bar × a multiplier
Calculation: Long sweep of level = level exists AND low is within a zone around the level AND bullish candle
Calculation: Short sweep of level = level exists AND high is within a zone around the level AND bearish candle
Calculation: Session-open levels = the open of the first bar in each of the 07:30, 08:00, 09:30, 10:00, and 18:00 New York time windows; each can trigger at most once per day
Calculation: Prior-day levels = high and low of the last completed daily bar
Calculation: Prior-week levels = high and low of the last completed weekly bar; use only on Mondays
Calculation: Morning bias = close > open on the 09:30 New York time bar; otherwise bearish, reset to neutral each day
Calculation: Higher-timeframe EMA = 20-period EMA on a higher timeframe, using the latest completed higher-timeframe bar
Calculation: Long stop = current bar low minus a buffer in wick-based mode, or current bar close minus a fixed distance in fixed mode
Calculation: Short stop = current bar high plus a buffer in wick-based mode, or current bar close plus a fixed distance in fixed mode
Calculation: Long risk = entry price − long stop; long TP1 and TP2 = entry price + long risk × their respective multipliers
Calculation: Short risk = short stop − entry price; short TP1 and TP2 = entry price − short risk × their respective multipliers
Long: flat AND (session filter disabled OR New York time is 02:00–05:00 OR 09:30–11:00) AND volume spike AND at least one long sweep of a session-open level not yet traded that day or a prior-day level, or a prior-week level on Monday AND (EMA filter disabled OR close > chart-timeframe EMA) AND (morning-bias filter disabled OR morning bias is neutral or bullish) AND close > higher-timeframe EMA
Short: flat AND (session filter disabled OR New York time is 02:00–05:00 OR 09:30–11:00) AND volume spike AND at least one short sweep of a session-open level not yet traded that day or a prior-day level, or a prior-week level on Monday AND (EMA filter disabled OR close < chart-timeframe EMA) AND (morning-bias filter disabled OR morning bias is neutral or bearish) AND close < higher-timeframe EMA AND NOT long
Exit: long, low <= active long stop OR high >= long TP1 OR high >= long TP2 OR bars since entry >= maximum bars in trade OR configured end-of-day close time
Exit: short, high >= active short stop OR low <= short TP1 OR low <= short TP2 OR bars since entry >= maximum bars in trade OR configured end-of-day close time