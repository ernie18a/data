Calculation: volume delta = in geometric mode, volume*((close-low)-(high-close))/(high-low) when high>low, otherwise 0; in intrabar mode, on each chart bar sum T1 up-volume minus down-volume from its intrabars, including a forming intrabar when present.
Calculation: total volume = volume in geometric mode; in intrabar mode, on each chart bar sum T1 up-volume plus down-volume from its intrabars, including a forming intrabar when present.
Calculation: CVD = cumulative sum of volume delta on chart bars.
Calculation: CVD pressure = (EMA(CVD, CVD smoothing lookback) - its prior value) / ATR(ATR lookback), or 0 when ATR is unavailable or zero.
Calculation: Bollinger %B = (close - lower Bollinger Band) / (upper Bollinger Band - lower Bollinger Band), or 0.5 when band width is zero; bands use a selected SMA, EMA, or VWMA basis, a shared band and volume lookback, and a deviation multiplier.
Calculation: normalized Bollinger bandwidth = (bandwidth - lowest(bandwidth, squeeze normalization lookback)) / (highest(bandwidth, squeeze normalization lookback) - lowest(bandwidth, squeeze normalization lookback)), or 0 when the denominator is zero; bandwidth = (upper Bollinger Band - lower Bollinger Band) / Bollinger basis.
Calculation: effort without result = high>low AND abs(close-open)/(high-low) < effort/result ratio maximum.
Calculation: VCS long stop = initialized to entry-signal-bar close - ATR at that bar * initial-stop ATR multiplier; on each subsequent in-position chart bar, update to max(previous stop, close - current ATR * trailing-stop ATR multiplier).
Calculation: VCS short stop = initialized to entry-signal-bar close + ATR at that bar * initial-stop ATR multiplier; on each subsequent in-position chart bar, update to min(previous stop, close + current ATR * trailing-stop ATR multiplier).
Long: (close > previous chart bar's upper Bollinger Band AND total volume > SMA(total volume, shared band and volume lookback) * VCS volume multiplier AND normalized Bollinger bandwidth <= squeeze threshold on the current or a prior chart bar within the recent-squeeze window AND volume delta > 0 AND CVD pressure > VCS pressure threshold)
Long: Bollinger %B < lower AD threshold AND total volume > SMA(total volume, shared band and volume lookback) * AD volume multiplier AND (effort without result OR volume delta > 0) AND CVD pressure > -AD pressure threshold
Long: CVD pressure > dashboard moderate-pressure threshold
Long: Bollinger %B > dashboard upper-outside boundary AND CVD pressure >= -dashboard moderate-pressure threshold
Long: (Bollinger %B <= dashboard lower-near boundary OR (Bollinger %B >= dashboard upper-near boundary AND Bollinger %B <= dashboard upper-outside boundary)) AND CVD pressure > dashboard moderate-pressure threshold
Long: Bollinger %B > dashboard lower-near boundary AND Bollinger %B < dashboard upper-near boundary AND CVD pressure > dashboard extreme-pressure threshold
Short: (close < previous chart bar's lower Bollinger Band AND total volume > SMA(total volume, shared band and volume lookback) * VCS volume multiplier AND normalized Bollinger bandwidth <= squeeze threshold on the current or a prior chart bar within the recent-squeeze window AND volume delta < 0 AND CVD pressure < -VCS pressure threshold)
Short: Bollinger %B > upper AD threshold AND total volume > SMA(total volume, shared band and volume lookback) * AD volume multiplier AND (effort without result OR volume delta < 0) AND CVD pressure < AD pressure threshold
Short: CVD pressure < -dashboard moderate-pressure threshold
Short: Bollinger %B > dashboard upper-outside boundary AND CVD pressure < -dashboard moderate-pressure threshold
Short: ((Bollinger %B > dashboard lower-outside boundary AND Bollinger %B <= dashboard lower-near boundary) OR (Bollinger %B >= dashboard upper-near boundary AND Bollinger %B <= dashboard upper-outside boundary)) AND CVD pressure < -dashboard moderate-pressure threshold
Short: Bollinger %B <= dashboard lower-outside boundary AND CVD pressure <= dashboard moderate-pressure threshold
Short: Bollinger %B > dashboard lower-near boundary AND Bollinger %B < dashboard upper-near boundary AND CVD pressure < -dashboard extreme-pressure threshold
Exit: long, after VCS entry, low <= VCS long stop
Exit: short, after VCS entry, high >= VCS short stop
Exit: long, after AD@B entry, low <= entry-signal-bar close - ATR at signal bar * initial-stop ATR multiplier OR (selected dynamic target (current Bollinger basis or upper Bollinger Band) > entry price AND high >= selected dynamic target)
Exit: short, after AD@B entry, high >= entry-signal-bar close + ATR at signal bar * initial-stop ATR multiplier OR (selected dynamic target (current Bollinger basis or lower Bollinger Band) < entry price AND low <= selected dynamic target)