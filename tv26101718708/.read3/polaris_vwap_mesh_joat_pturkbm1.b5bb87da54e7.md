Calculation: Active anchor count = number of nonmissing session-start VWAPs, swing-high-pivot-confirmation VWAPs, swing-low-pivot-confirmation VWAPs, and day-open-reset VWAPs
Calculation: Bull count = number of active anchor VWAPs below close
Calculation: Multi-anchor bias = bullish when bull count >= bull-count threshold; bearish when active anchor count >= minimum-active-anchor threshold and bull count <= bear-count maximum; neutral otherwise
Long: close crosses above VWAP(hlc3, volume, anchored at session start) OR close crosses above VWAP(hlc3, volume, anchored at confirmed swing-high pivot confirmation bar using the pivot-lookback parameter on both sides) OR close crosses above VWAP(hlc3, volume, anchored at confirmed swing-low pivot confirmation bar using the pivot-lookback parameter on both sides) OR close crosses above VWAP(hlc3, volume, reset at each day-open after a prior day-open is observed), on confirmed bars
Short: close crosses below VWAP(hlc3, volume, anchored at session start) OR close crosses below VWAP(hlc3, volume, anchored at confirmed swing-high pivot confirmation bar using the pivot-lookback parameter on both sides) OR close crosses below VWAP(hlc3, volume, anchored at confirmed swing-low pivot confirmation bar using the pivot-lookback parameter on both sides) OR close crosses below VWAP(hlc3, volume, reset at each day-open after a prior day-open is observed), on confirmed bars
Long: active anchor count > 0 AND bull count > active anchor count - bull count
Short: active anchor count > 0 AND bull count < active anchor count - bull count
Long: multi-anchor bias is bullish
Short: multi-anchor bias is bearish
Long: multi-anchor bias becomes bullish on a confirmed bar
Short: multi-anchor bias becomes bearish on a confirmed bar