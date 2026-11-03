Calculation: Volume profile = Over a configurable rolling lookback on the chart timeframe, including the current bar, divide the window’s low-to-high range into configurable price bins; distribute each bar’s volume equally across bins touched by its high-low range (or assign it to the close-price bin if range distribution is disabled). The point of control (POC) is the midpoint of the highest-volume bin. Starting at the POC bin, expand the value area toward the higher-volume adjacent bin until it contains a configurable fraction of total volume; VAH and VAL are its upper and lower edges.
Calculation: Above-POC volume share = 100 × volume in bins above the POC ÷ volume in all bins above and below the POC; exclude the POC bin.
Calculation: Buy-volume share = 100 × volume on bars where close ≥ open ÷ volume on bars where close ≥ open or close < open.
Calculation: Order-flow score = average of above-POC volume share and buy-volume share.
Long: (close < VAL AND order-flow score > 45) OR (close > VAH AND order-flow score ≥ 55) OR (close crosses above VAH)
Short: (close > VAH AND order-flow score < 55) OR (close < VAL AND order-flow score ≤ 45) OR (close crosses below VAL)
Exit: long, close ≥ POC
Exit: short, close ≤ POC