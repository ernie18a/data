Calculation: Bullish FVG = current low > high two bars earlier, optionally requiring the difference to be at least a minimum gap size; its interval is [high two bars earlier, current low].
Calculation: Bearish FVG = current high < low two bars earlier, optionally requiring the difference to be at least a minimum gap size; its interval is [current high, low two bars earlier].
Calculation: FVG cluster = for each direction, retain the first FVG's bar and interval; expire it when its age exceeds a maximum bar count. An opposite-direction FVG clears it. A same-direction FVG whose interval overlaps or touches the cluster expands the interval to their union without changing the first bar; a non-overlapping same-direction FVG produces a 2x event and clears the cluster.
Calculation: Structure break = track the latest confirmed pivot high and low, each with an independent broken flag, and a direction initially neutral. Pivots use equal left and right lookbacks. On each bar, first test the previously stored unbroken high and low against close, or optionally high and low respectively. Mark every breached level broken. If both break, select the low when direction is bullish, the high when direction is bearish, otherwise the high when close >= open and the low when close < open. If neither old level produces a selected break, test newly confirmed pivots using the same sources and tie rule. A selected high break sets direction bullish; a selected low break sets it bearish. Finally replace stored levels with newly confirmed pivots and mark each new level broken if its source already exceeds it in the corresponding direction.
Calculation: Climax = volume >= a multiplier times the simple moving average of volume, OR, if enabled, volume × (high - low) >= the highest volume × (high - low) over the same lookback including the current bar.
Long: Bullish FVG.
Short: Bearish FVG.
Long: A bullish FVG does not overlap the active bullish FVG cluster.
Short: A bearish FVG does not overlap the active bearish FVG cluster.
Long: A confirmed pivot low is available.
Short: A confirmed pivot high is available.
Long: Structure break selects a high break.
Short: Structure break selects a low break.
Long: Shorter-period close EMA crosses above longer-period close EMA.
Short: Shorter-period close EMA crosses below longer-period close EMA.
Long: Close > open AND climax.
Short: Close <= open AND climax.
Long: Close > open AND climax is false AND volume >= a separate above-average multiplier times the simple moving average of volume.
Short: Close <= open AND climax is false AND volume >= a separate above-average multiplier times the simple moving average of volume.
Long: Close > open AND climax is false AND volume < the above-average multiplier times the simple moving average of volume.
Short: Close <= open AND climax is false AND volume < the above-average multiplier times the simple moving average of volume.