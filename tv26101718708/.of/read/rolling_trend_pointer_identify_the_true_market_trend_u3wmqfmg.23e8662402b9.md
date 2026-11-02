Calculation: Rolling VWAP = sum of open × volume divided by sum of volume over a rolling lookback; undefined when the volume sum is not positive.
Calculation: Price distance = high − rolling VWAP when close ≥ rolling VWAP; otherwise low − rolling VWAP.
Calculation: Histogram = price distance, optionally smoothed with SMA, EMA, WMA, or RMA.
Calculation: Channel boundaries = maintain separate queues of the latest rolling-lookback-count positive price distances and absolute negative price distances, including the current completed chart bar. Weight each sample by its volume, or by 1 when volume is missing or nonpositive. For each new sample, store its squared difference from the weighted mean of its queue after insertion and removal of the oldest excess sample. For each full queue, choose either the current weighted variance of its samples or the weighted mean of its stored squared residuals, and multiply the square root by twice a configurable multiplier. The upper boundary is the positive result; the lower boundary is the negative result. A boundary is undefined until its queue is full.
Calculation: Anchored VWAP = cumulative sum of selected price source × volume divided by cumulative volume since the start of its calendar anchor period, including the current chart bar; reset at each new period and at the first available bar. Use a base anchor and optionally enabled progressively longer calendar anchors. Compare each anchored VWAP with its value the same configurable number of chart bars earlier, including across anchor resets.
Long: Histogram ≥ 0.
Short: Histogram < 0.
Long: Histogram > upper channel boundary.
Short: Histogram < lower channel boundary.
Long: Base anchored VWAP ≥ its earlier value.
Short: Base anchored VWAP < its earlier value.
Long: Base anchored VWAP ≥ its earlier value AND every enabled longer-period anchored VWAP ≥ its earlier value AND (synchronization disabled OR histogram ≥ 0).
Short: Base anchored VWAP < its earlier value AND every enabled longer-period anchored VWAP < its earlier value AND (synchronization disabled OR histogram < 0).
Long: Base anchored VWAP ≥ its earlier value AND every enabled longer-period anchored VWAP ≥ its earlier value AND histogram ≥ 0 AND histogram > upper channel boundary AND synchronization enabled.
Short: Base anchored VWAP < its earlier value AND every enabled longer-period anchored VWAP < its earlier value AND histogram < 0 AND histogram < lower channel boundary AND synchronization enabled.