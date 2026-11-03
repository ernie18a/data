Calculation: Opening-range high/low = highest high / lowest low during the selected session’s opening interval, whose duration is the selected opening-range timeframe; that timeframe is the same as or higher than the chart timeframe, and the range is used only after the interval completes.
Calculation: EMA = exponential moving average of close over the selected lookback on the selected EMA timeframe; that timeframe may be lower or higher than the chart timeframe, and its latest available value is used.
Long: close > EMA
Long: opening range captured AND selected session active AND close > opening-range high AND close > EMA
Short: close < EMA
Short: opening range captured AND selected session active AND close < opening-range low AND close < EMA