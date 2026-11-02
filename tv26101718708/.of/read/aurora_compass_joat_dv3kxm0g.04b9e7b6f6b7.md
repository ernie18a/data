Calculation: Profile = On each chart bar, use chart bars from the start of the still-forming higher-timeframe interval through the current bar, limited to a maximum lookback. Divide their highest high to lowest low into equal-width price bins. Add a bar's full volume to every bin its high-low range intersects, including boundary touches. For each bin also sum volume × direction × weight, where direction is +1 if close > open and -1 otherwise, and weight is 1 plus a coefficient times the NVI change divided by the greater of the absolute previous NVI and 1; use weight 1 if unavailable. NVI changes by the close-to-close percentage return only when volume falls from the preceding bar. If the range is zero, POC and value-area boundaries are zero and bin values are unavailable.
Calculation: POC = Midpoint of the profile bin with greatest volume; break ties by choosing the lowest bin.
Calculation: High-volume nodes = The highest-volume positive-volume profile bins, ranked by volume with ties resolved toward the lowest bin; use the specified node count.
Calculation: Low-volume nodes = The lowest-volume positive-volume profile bins, ranked by volume with ties resolved toward the lowest bin; use the same node count as for high-volume nodes.
Calculation: Value area = Start at the POC bin and repeatedly add the larger-volume adjacent bin, choosing the upper bin on a tie, until the specified fraction of total bin volume is included or no bins remain. Its high and low are the outer boundaries of the included bins.
Calculation: Profile up volume and down volume = Sum the raw volumes of bins whose signed volumes are respectively nonnegative and negative. Profile imbalance is the absolute difference between these sums divided by their total, or zero when their total is zero.
Calculation: Bias = (close - POC) divided by the greater of chart-timeframe ATR and a minimum price increment, clamped between symmetric negative and positive limits.
Calculation: POC drift = (current POC - POC on the last chart bar of the preceding higher-timeframe interval) divided by the greater of chart-timeframe ATR and a minimum price increment; use zero before a preceding interval exists.
Long: Low < bottom of any high-volume node AND close > top of that node.
Short: High > top of any high-volume node AND close < bottom of that node.
Long: POC > previous chart bar's POC, substituting zero for an unavailable previous POC.
Short: POC < previous chart bar's POC, substituting zero for an unavailable previous POC.
Long: Profile up volume > profile down volume AND profile imbalance >= imbalance threshold AND previous chart bar's profile imbalance < imbalance threshold, substituting zero if unavailable.
Short: Profile down volume > profile up volume AND profile imbalance >= imbalance threshold AND previous chart bar's profile imbalance < imbalance threshold, substituting zero if unavailable.
Long: Close > value-area high AND previous close <= previous value-area high, substituting zero for unavailable previous values.
Short: Close < value-area low AND previous close >= previous value-area low, substituting zero for unavailable previous values.
Long: Bias > positive bias threshold.
Short: Bias < negative bias threshold.
Long: POC drift > positive drift threshold.
Short: POC drift < negative drift threshold.
Long: Profile up volume > profile down volume.
Short: Profile down volume > profile up volume.
Long: Any profile bin has signed volume > 0 OR any low-volume node has signed volume >= 0.
Short: Any profile bin has signed volume < 0.