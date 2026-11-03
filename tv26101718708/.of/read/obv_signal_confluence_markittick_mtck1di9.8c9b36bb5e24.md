Calculation: OBV = cumulative sum of volume multiplied by the sign of the change in a chosen price source.
Calculation: OBV baseline = a chosen SMA, RMA, WMA, or VWMA of OBV.
Calculation: OBV histogram = OBV minus its baseline.
Calculation: Confirmed pivot high or low = the high or low of the bar one more than the pivot lookback bars ago, strictly greater or lower respectively than every other high or low in the symmetric window of that lookback on each side; confirmation occurs on the current bar.
Calculation: Entry risk = ATR on the signal bar multiplied by a stop-distance parameter; the projected entry price is the close of the bar preceding the signal bar.
Long: OBV histogram >= 0.
Short: OBV histogram < 0.
Long: OBV > OBV baseline.
Short: OBV < OBV baseline.
Long: OBV crosses above its baseline AND, if enabled, higher-timeframe close-based OBV > its baseline on the last completed higher-timeframe bar AND, if enabled, ADX >= its threshold AND, if enabled, volume >= SMA of volume multiplied by a volume threshold.
Short: OBV crosses below its baseline AND, if enabled, higher-timeframe close-based OBV <= its baseline on the last completed higher-timeframe bar AND, if enabled, ADX >= its threshold AND, if enabled, volume >= SMA of volume multiplied by a volume threshold.
Long: A pivot low is confirmed AND its price is lower than the preceding pivot low AND its OBV histogram is higher than at the preceding pivot low.
Long: A pivot low is confirmed AND its price is higher than the preceding pivot low AND its OBV histogram is lower than at the preceding pivot low.
Short: A pivot high is confirmed AND its price is higher than the preceding pivot high AND its OBV histogram is lower than at the preceding pivot high.
Short: A pivot high is confirmed AND its price is lower than the preceding pivot high AND its OBV histogram is higher than at the preceding pivot high.
Exit: long, OBV crosses below its baseline AND, if enabled, higher-timeframe close-based OBV <= its baseline on the last completed higher-timeframe bar AND, if enabled, ADX >= its threshold AND, if enabled, volume >= SMA of volume multiplied by a volume threshold.
Exit: short, OBV crosses above its baseline AND, if enabled, higher-timeframe close-based OBV > its baseline on the last completed higher-timeframe bar AND, if enabled, ADX >= its threshold AND, if enabled, volume >= SMA of volume multiplied by a volume threshold.
Exit: long, high >= projected entry price plus entry risk multiplied by a chosen one of three independently configured reward-to-risk parameters, AND that target has not previously been hit since the latest entry signal.
Exit: short, low <= projected entry price minus entry risk multiplied by a chosen one of three independently configured reward-to-risk parameters, AND that target has not previously been hit since the latest entry signal.