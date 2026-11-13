Calculation: HTF bands = on a timeframe higher than the chart, using the still-forming higher-timeframe bar: HTFmid = volume-weighted moving average of close over a long lookback; HTFstd = standard deviation of close over the same lookback; HTFupper = HTFmid + m*HTFstd; HTFlower = HTFmid - m*HTFstd; HTFclose = close of that still-forming higher-timeframe bar
Calculation: ADV = exponential moving average of the higher-timeframe volume (still-forming bar) over a long lookback
Calculation: threshold = max(1, (a + b*ln(ADV)) * ADV / (number of chart bars per day)), with constants a and b, b > 0
Calculation: RedTrig = volume N bars ago > threshold N bars ago AND close N bars ago < open N bars ago (N = core lookback, N >= 1)
Calculation: GreenTrig = volume N bars ago > threshold N bars ago AND close N bars ago > open N bars ago
Calculation: RedCluster = count of bars with RedTrig true within the last M bars (including the current bar) >= a minimum count of 2 or more; GreenCluster = same count using GreenTrig (M = reversal lookback, M >= minimum count)
Long: (on a confirmed bar, flat position; entry at that bar's close) HTFclose > HTFupper AND (RedTrig OR GreenCluster)
Short: (on a confirmed bar, flat position; entry at that bar's close) HTFclose < HTFlower AND (GreenTrig OR RedCluster)
Exit: long opened via RedTrig, low <= (low N bars before the entry bar)*(1 - stop buffer) OR high >= (high N bars before the entry bar)*(1 + target buffer)
Exit: short opened via GreenTrig, high >= (high N bars before the entry bar)*(1 + stop buffer) OR low <= (low N bars before the entry bar)*(1 - target buffer)
Exit: long opened via GreenCluster, low <= entry price*(1 - stop pct) OR high >= entry price*(1 + target pct), where target pct > stop pct
Exit: short opened via RedCluster, high >= entry price*(1 + stop pct) OR low <= entry price*(1 - target pct), where target pct > stop pct