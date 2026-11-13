Long-only, evaluated on daily bars of the traded instrument. It uses the instrument's own price and volume, plus an external daily market-breadth series: the percentage of large-cap index constituents trading above their 50-day average (S5FI). The weekly trend average is the simple moving average of weekly closes over about 30 weeks, computed on the weekly timeframe and read on each daily bar.

Definitions:
- Uptrend stage: the close is above the weekly trend average, and that average is higher than it was a few weeks ago (positive slope).
- Accumulation day: the daily close change is above a small positive percentage and volume is above its 50-bar average.
- Distribution day: the daily close change is below a small negative percentage and volume is above its 50-bar average.
- Over the trailing 25 bars, count accumulation days and distribution days. Net accumulation is accumulation count minus distribution count.
- Accumulating: net accumulation is at or above a small positive threshold.
- Breadth bullish: within the last 30 days the breadth series fell below a low oversold level, AND it is now above a mid-level recovery threshold.
- Breadth bearish: within the last 30 days the breadth series rose above a high overheated level, AND it is now below the same mid-level recovery threshold.
- Top-distribution stage: the close is above the weekly trend average, the average's slope is flat or negative, and the 25-bar distribution count is at or above a warning threshold.
- Trend just broken: the previous bar was in the uptrend stage and the current close is below the weekly trend average.

LONG ENTRY: Enter long on the first bar where uptrend stage, accumulating and breadth bullish are all true together. Do not enter again while the combined condition stays true; the condition must have been false on the prior bar.

EXIT: Define an exit condition as top-distribution stage, OR trend just broken, OR breadth bearish. Close the long on the first bar where this exit condition becomes true after being false on the prior bar. It is not tied to any stop or target.

There is no short logic. Other stage classifications (basing, downtrend) are for display only and do not drive trades. Breadth data that is not yet available means breadth bullish and breadth bearish are both false.