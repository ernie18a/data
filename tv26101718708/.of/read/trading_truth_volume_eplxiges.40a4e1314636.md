Calculation: Wilder volume moving average = previous value + (current volume − previous value) / lookback
Calculation: Wave direction = up when price crosses above the prior value plus the configured reversal threshold; down when it crosses below the prior value minus that threshold; otherwise retain prior direction. The threshold is based on the configured ATR, fixed-point, or price-fraction method.
Calculation: Volume slope in the current wave = rising when its lowest-volume bar precedes its highest-volume bar; falling when its highest-volume bar precedes its lowest-volume bar.
Long: Wave direction is up AND volume slope is rising
Long: Wave direction is down AND volume is below the normal-volume threshold
Short: Wave direction is down AND volume slope is rising
Short: Wave direction is up AND volume is below the normal-volume threshold
Exit: Long, wave direction is up AND volume slope is falling
Exit: Short, wave direction is down AND volume slope is falling