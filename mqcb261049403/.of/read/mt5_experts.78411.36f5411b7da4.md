Calculation: EMA signal = Calculate short-period and long-period EMAs from completed chart-timeframe bars or completed bars of a configurable higher or lower timeframe. Initialize both EMAs with the first observed bar close. After the long EMA period plus one completed bars, signal long if the short EMA is above the long EMA, or short if it is below. Thereafter, signal long when the EMA ordering changes from its most recent non-equal ordering to short above long, or short when it changes to short below long; equal EMA values do not change the remembered ordering.
Long: EMA signal is long
Short: EMA signal is short
Exit: long, EMA signal is short
Exit: short, EMA signal is long
Exit: long, take-profit distance > 0 AND current close - entry price >= take-profit distance
Exit: long, stop-loss distance > 0 AND current close - entry price <= -stop-loss distance