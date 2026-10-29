Calculation: EMA trend = shorter-lookback EMA of close and longer-lookback EMA of close.
Calculation: Relative volume = volume / simple moving average of volume.
Calculation: Confirmed swing high/low = pivot high/low confirmed after matching left and right lookbacks; the sweep pivots use a longer left lookback than right lookback.
Calculation: Opening range high/low = highest high and lowest low during each session's shorter or longer opening interval, formed from chart bars.
Calculation: Range mode = ADX below its threshold AND current ATR below its moving average times a threshold AND highest high minus lowest low over the lookback below current ATR times half the lookback.
Long: EMA trend is bullish AND low <= shorter-lookback EMA + ATR * pullback threshold AND close > shorter-lookback EMA AND prior close <= prior shorter-lookback EMA AND close > open AND close > prior high AND relative volume >= 1.0
OR prior close > latest confirmed resistance pivot AND low <= latest confirmed resistance pivot * 1.002 AND close > latest confirmed resistance pivot AND close > open
OR EMA trend is bullish AND prior low > prior shorter-lookback EMA AND low <= shorter-lookback EMA * 1.001 AND close > shorter-lookback EMA AND close > open
OR close crosses above an opening-range high for any session and opening interval
OR low < latest confirmed swing low AND close > latest confirmed swing low AND close > open
OR close > latest confirmed structure swing high AND prior close <= prior latest confirmed structure swing high
OR Range mode AND low <= range low * 1.001 AND close > open AND close > range low AND volume > volume moving average
OR previous bar was in Range mode AND close > current range high AND volume > 1.5 * volume moving average
Short: EMA trend is bearish AND high >= shorter-lookback EMA - ATR * pullback threshold AND close < shorter-lookback EMA AND prior close >= prior shorter-lookback EMA AND close < open AND close < prior low AND relative volume >= 1.0
OR prior close < latest confirmed support pivot AND high >= latest confirmed support pivot * 0.998 AND close < latest confirmed support pivot AND close < open
OR EMA trend is bearish AND prior high < prior shorter-lookback EMA AND high >= shorter-lookback EMA * 0.999 AND close < shorter-lookback EMA AND close < open
OR close crosses below an opening-range low for any session and opening interval
OR high > latest confirmed swing high AND close < latest confirmed swing high AND close < open
OR close < latest confirmed structure swing low AND prior close >= prior latest confirmed structure swing low
OR Range mode AND high >= range high * 0.999 AND close < open AND close < range high AND volume > volume moving average
OR previous bar was in Range mode AND close < current range low AND volume > 1.5 * volume moving average