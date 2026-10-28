Calculation: Opening range high/low = highest high/lowest low of the configured opening-range session, reset each day and used after that session is complete.
Calculation: VWAP = cumulative close × volume divided by cumulative volume for the current session.
Long: ORB is complete AND close > opening-range high
Long: ORB is complete AND close is within the opening range AND low < opening-range low AND high − low > ATR AND close > VWAP
Long: Previous bar close > opening-range high AND previous bar close > previous bar VWAP AND low > previous bar low AND current close is outside the opening range
Long: low < opening-range low AND close > opening-range low AND close is outside the opening range
Long: A bar's high exceeded opening-range high within the recent configured lookback AND close < previous close AND close > previous high AND close is outside the opening range
Short: ORB is complete AND close < opening-range low
Short: ORB is complete AND close is within the opening range AND low < opening-range low AND high − low > ATR AND close < VWAP
Short: Previous bar close < opening-range low AND previous bar close < previous bar VWAP AND high < previous bar high AND current close is outside the opening range
Short: high > opening-range high AND close < opening-range high AND close is outside the opening range
Short: A bar's low fell below opening-range low within the recent configured lookback AND close > previous close AND close < previous low AND close is outside the opening range