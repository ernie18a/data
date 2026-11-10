Calculation: Pivot interval = the completed interval between the two most recent occurrences of the active session's pivot hour, using aggregated bars; the active session is selected by time of day, with a separate pivot hour before the first session on Monday. The aggregation timeframe can be higher than, equal to, or lower than the chart timeframe; use completed bars only.
Calculation: Pivot level = (highest high of the pivot interval + lowest low of the pivot interval + open of the first bar after the interval) / 3.
Long: Price reaches the pivot interval's lowest low plus an entry offset.
Short: Price reaches the pivot interval's highest high.
Exit: Long, price <= the pivot interval's lowest low at order placement minus a stop offset OR price >= the pivot level at order placement.
Exit: Short, price >= the pivot interval's highest high at order placement plus a stop offset OR price <= the pivot level at order placement.