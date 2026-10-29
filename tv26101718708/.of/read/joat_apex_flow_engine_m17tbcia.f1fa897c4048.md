Calculation: Efficiency ratio = absolute close change over the lookback divided by the sum of absolute one-bar close changes over that lookback (0 if the sum is 0)
Calculation: Flow baseline = initialize to close; thereafter previous baseline + min(1, (efficiency ratio × (2/3 − 2/31) + 2/31)² × acceleration) × (close − previous baseline)
Calculation: Flow bands = flow baseline ± ATR × envelope width
Calculation: Flow state = bullish after the required consecutive closes above the upper band when the prior state is neutral or bearish; bearish after the required consecutive closes below the lower band when the prior state is neutral or bullish; otherwise retain the prior state. A close outside a band increments its consecutive count; any close not outside that band resets its count.
Calculation: Momentum = close − close from the momentum lookback
Calculation: Volume ratio = volume divided by its simple moving average over the volume lookback (1 if the average is 0)
Calculation: Body ratio = absolute close − open divided by candle range
Calculation: Directional quality score = 25 if momentum is in the signal direction, otherwise 0; plus volume points (25 if volume ratio ≥ 1.2, 15 if ≥ 1, otherwise 0); plus body points (25 if body ratio ≥ 0.6, 15 if ≥ 0.4, otherwise 5); plus efficiency points (25 if efficiency ratio ≥ 0.4, 15 if ≥ 0.25, otherwise 5)
Calculation: Risk distance = ATR × stop multiplier or entry price × stop percentage
Long: Flow state changes to bullish AND long directional quality score ≥ minimum quality
Short: Flow state changes to bearish AND short directional quality score ≥ minimum quality
Exit: long, after the entry bar, low ≤ entry price − risk distance OR (a furthest enabled profit target exists AND high ≥ that target)
Exit: short, after the entry bar, high ≥ entry price + risk distance OR (a furthest enabled profit target exists AND low ≤ that target)