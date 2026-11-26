Long: On chart bars, BrainTrend2(ATR lookback) is bullish at the signal-bar offset AND bearish on the immediately preceding chart bar.
Short: On chart bars, BrainTrend2(ATR lookback) is bearish at the signal-bar offset AND bullish on the immediately preceding chart bar.
Long: On T1 bars, BrainTrend2(ATR lookback, T1, last completed bar) is bullish AND BrainTrend2(ATR lookback, T1, preceding completed bar) is bearish.
Short: On T1 bars, BrainTrend2(ATR lookback, T1, last completed bar) is bearish AND BrainTrend2(ATR lookback, T1, preceding completed bar) is bullish.
Long: On T2 bars, AbsolutelyNoLagLWMA(close, line lookback, T2, last completed bar) > AbsolutelyNoLagLWMA(close, line lookback, T2, preceding completed bar) AND AbsolutelyNoLagLWMA(close, line lookback, T2, preceding completed bar) <= AbsolutelyNoLagLWMA(close, line lookback, T2, two completed bars ago).
Short: On T2 bars, AbsolutelyNoLagLWMA(close, line lookback, T2, last completed bar) < AbsolutelyNoLagLWMA(close, line lookback, T2, preceding completed bar) AND AbsolutelyNoLagLWMA(close, line lookback, T2, preceding completed bar) >= AbsolutelyNoLagLWMA(close, line lookback, T2, two completed bars ago).
Long: On T3 bars, X2MACandle(open, close, first smoothing method, first smoothing lookback, first phase, second smoothing method, second smoothing lookback, second phase, T3, last completed bar) is bullish AND the preceding completed T3 bar is not bullish.
Short: On T3 bars, X2MACandle(open, close, first smoothing method, first smoothing lookback, first phase, second smoothing method, second smoothing lookback, second phase, T3, last completed bar) is bearish AND the preceding completed T3 bar is not bearish.
Exit: long, low <= entry price - system A stop-loss distance in points OR high >= entry price + system A take-profit distance in points.
Exit: short, high >= entry price + system A stop-loss distance in points OR low <= entry price - system A take-profit distance in points.
Exit: long, low <= entry price - system B stop-loss distance in points OR high >= entry price + system B take-profit distance in points.
Exit: short, high >= entry price + system B stop-loss distance in points OR low <= entry price - system B take-profit distance in points.
Exit: long, low <= entry price - system C stop-loss distance in points OR high >= entry price + system C take-profit distance in points.
Exit: short, high >= entry price + system C stop-loss distance in points OR low <= entry price - system C take-profit distance in points.