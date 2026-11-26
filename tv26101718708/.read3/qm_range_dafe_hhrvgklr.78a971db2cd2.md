Calculation: Fractal low bar = the most recent bar p from current bar minus pivot lookback to current bar minus 1 whose low is below the lows of bars p-1 and p+1
Calculation: Fractal high bar = the most recent bar p from current bar minus pivot lookback to current bar minus 1 whose high is above the highs of bars p-1 and p+1
Calculation: Bullish sweep = low < low at Fractal low bar AND close >= low at Fractal low bar
Calculation: Bearish sweep = high > high at Fractal high bar AND close <= high at Fractal high bar
Calculation: Latest sweep bar = the most recent bar where Bullish sweep OR Bearish sweep holds
Calculation: Bullish sweep level = low at Fractal low bar as of Latest sweep bar
Calculation: Bearish sweep level = high at Fractal high bar as of Latest sweep bar
Calculation: Bullish break = highest high from Fractal low bar as of Latest sweep bar through Latest sweep bar
Calculation: Bearish break = lowest low from Fractal high bar as of Latest sweep bar through Latest sweep bar
Calculation: Bullish QM = close crosses above Bullish break AND Bullish sweep holds at Latest sweep bar AND Latest sweep bar is within QM break lookback bars AND close has stayed at or above Bullish sweep level since Latest sweep bar
Calculation: Bearish QM = close crosses below Bearish break AND Bullish sweep does not hold at Latest sweep bar AND Latest sweep bar is within QM break lookback bars AND close has stayed at or below Bearish sweep level since Latest sweep bar
Long: Bullish QM
Short: Bearish QM
Calculation: Range = (high, low) formed on a bar where Bullish QM OR Bearish QM holds, if the latest earlier bar where either holds is of the opposite type and lies within range gap bars before it; high = max and low = min of the QM levels at both bars, where a Bullish QM's levels are Bullish sweep level and Bullish break, and a Bearish QM's levels are Bearish sweep level and Bearish break
Calculation: Active range = the latest Range, if no Bullish BOS OR Bearish CHoCH holds on an earlier bar since that Range formed
Calculation: Bullish BOS = close > high of Active range
Calculation: Bearish CHoCH = close < low of Active range
Long: Bullish BOS
Short: Bearish CHoCH
Calculation: Supply zone = created on a Bearish CHoCH bar as (high, low) of the nearest bar i from 1 to SD lookback bars before it with close[i] > open[i], if such i exists
Calculation: Demand zone = created on a Bullish BOS bar as (high, low) of the nearest bar i from 1 to SD lookback bars before it with close[i] < open[i], if such i exists
Calculation: Active zone = a Supply or Demand zone created on or before the current bar, with fewer than zone touch limit earlier bars where high >= its low (Supply) or low <= its high (Demand), and not dropped as the oldest zone by a zone creation on or before the current bar that left more than max visible zones
Short: high >= low of an Active zone of type Supply
Long: low <= high of an Active zone of type Demand