Calculation: Prior-day high/low = high/low of the last completed daily bar.
Calculation: Prior-week high/low = high/low of the last completed weekly bar.
Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3 over the current session.
Calculation: VWAP slope = percentage change in session VWAP from its value a configurable lookback of chart bars earlier; rising means above a configurable positive threshold, falling means below its negative, and flat means between them.
Long: Close > prior-day high AND previous chart-bar close <= prior-day high.
Long: Close > prior-day low AND previous chart-bar close <= prior-day low.
Long: Close > prior-week high AND previous chart-bar close <= prior-week high.
Long: Close > prior-week low AND previous chart-bar close <= prior-week low.
Long: Each of the configurable number of preceding chart bars closed below its session VWAP AND current close > session VWAP AND close > open AND close < prior-day high.
Short: High >= prior-day high AND close < prior-day high AND previous chart-bar high < prior-day high.
Short: Close < prior-day low AND previous chart-bar close >= prior-day low.
Short: Close < prior-week high AND previous chart-bar close > prior-week high AND high >= prior-week high AND previous chart-bar high < prior-week high.
Short: Close < prior-week low AND previous chart-bar close >= prior-week low.
Short: Each of the configurable number of preceding chart bars closed above its session VWAP AND current close < session VWAP AND close < open AND close > prior-day low.
Exit: long, close > prior-day high AND VWAP slope is flat or falling.