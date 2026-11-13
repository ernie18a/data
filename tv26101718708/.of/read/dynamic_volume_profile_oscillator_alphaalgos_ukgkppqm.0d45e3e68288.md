Calculation: snapshot_vwap = volume-weighted mean of close over a lookback window of recent bars, with the window snapshot refreshed only every few bars and held fixed between refreshes
Calculation: snapshot_dev = volume-weighted mean absolute deviation of the snapshot closes from snapshot_vwap, using the same snapshot and weights
Calculation: osc = EMA(50 + (current close - snapshot_vwap) / (snapshot_dev * sensitivity) * 25, short smoothing length)
Calculation: midline = SMA(osc, long lookback)
Calculation: fast = EMA(osc, short length)
Calculation: slow = EMA(osc, longer length than fast)
Long: osc > midline OR fast > slow
Short: NOT (osc > midline OR fast > slow), i.e. osc <= midline AND fast <= slow
Long: fast crosses above slow (fast[1] <= slow[1] AND fast > slow)
Short: fast crosses below slow (fast[1] >= slow[1] AND fast < slow)