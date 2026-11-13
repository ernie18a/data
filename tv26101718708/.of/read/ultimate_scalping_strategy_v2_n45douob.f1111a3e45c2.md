Calculation: VWAP = session-anchored volume-weighted average price of hlc3, reset at the start of each trading day
Calculation: ATR = Wilder average true range on the chart timeframe, using the current bar's value
Calculation: BullEngulf = close > open AND previous close < previous open AND close > previous open AND open < previous close
Calculation: BearEngulf = close < open AND previous close > previous open AND close < previous open AND open > previous close
Long: fast EMA of close crosses above slow EMA of close (fast <= slow on the previous bar AND fast > slow on the current bar; fast has the shorter lookback, slow the longer) AND close > VWAP AND (optional filter) BullEngulf AND (optional filter) volume > simple moving average of volume
Short: fast EMA of close crosses below slow EMA of close (fast >= slow on the previous bar AND fast < slow on the current bar) AND close < VWAP AND (optional filter) BearEngulf AND (optional filter) volume > simple moving average of volume
Exit: long, low <= entry price - k_sl * ATR OR high >= entry price + k_tp * ATR OR Short condition is true on the current bar
Exit: short, high >= entry price + k_sl * ATR OR low <= entry price - k_tp * ATR OR Long condition is true on the current bar
Exit (optional, replaces the take-profit part): long, once highest high since entry >= entry price + k_act * ATR at entry, low <= highest high since entry - k_trail * ATR at entry
Exit (optional, replaces the take-profit part): short, once lowest low since entry <= entry price - k_act * ATR at entry, high >= lowest low since entry + k_trail * ATR at entry