Long: no open position AND SMA(close, S1 shorter-lookback parameter) crosses above SMA(close, S1 longer-lookback parameter)
Long: no open position AND SMA(close, S2 shorter-lookback parameter) crosses above SMA(close, S2 longer-lookback parameter) AND close > SMA(close, S2 longer-lookback parameter, T1, still-forming bar), evaluated on chart bars using T1 values
Exit: Long, S1 trailing is enabled AND low <= high[1] - S1 pip-distance parameter * minimum tick
Exit: Long, S1 trailing is disabled AND S1 take-profit mode is percentage AND high >= close[1] * (1 + S1 take-profit percentage parameter)
Exit: Long, S1 trailing is disabled AND S1 take-profit mode is pips AND high >= close[1] + S1 pip-distance parameter * minimum tick
Exit: Long, high >= close[1] * (1 + S2 partial-take-profit percentage parameter / 100)
Exit: Long, low <= close[1] - ATR(S2 ATR lookback parameter)[1] * S2 ATR multiplier parameter