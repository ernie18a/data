Calculation: Slot volumes = Divide each chart bar into a configurable number of price slots from its low, using slot width max((high - low) / number of slots, minimum price increment). For each available lower-timeframe bar within the chart bar, including the bar still forming, divide its volume equally among all slots touched by its low-to-high range; clamp the endpoint slot indices to the chart bar's slot range. Allocate the shares to estimated ask volume if its close >= open, otherwise to estimated bid volume. If no lower-timeframe bars are available, divide the chart bar's volume equally among all slots and allocate it to ask if the chart close >= open, otherwise to bid.
Calculation: Bar delta = Sum of estimated ask volume minus estimated bid volume across all slots of the chart bar.
Calculation: Cumulative delta = Sum of bar delta over completed chart bars from the start of the available data; exclude the current chart bar while it is still forming.
Long: Bar delta >= 0
Short: Bar delta < 0
Long: Estimated ask volume in any slot > estimated bid volume in that slot
Short: Estimated ask volume in any slot < estimated bid volume in that slot
Long: Estimated bid volume in the slot immediately below any slot > 0 AND estimated ask volume in that slot >= estimated bid volume in the slot immediately below multiplied by the imbalance ratio
Short: Estimated ask volume in the slot immediately above any slot > 0 AND estimated bid volume in that slot >= estimated ask volume in the slot immediately above multiplied by the imbalance ratio
Long: Cumulative delta >= 0
Short: Cumulative delta < 0