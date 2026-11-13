Calculation: HTF = the still-forming bar of a timeframe higher than the chart timeframe (a one-day bar), with its open, high, low
Calculation: Excursion up = HTF high - HTF open; Excursion down = HTF open - HTF low
Long: price > HTF open AND Excursion up > Excursion down AND no open position AND hour of day is >= entry window start AND < entry window end
Short: price < HTF open AND Excursion down > Excursion up AND no open position AND hour of day is >= entry window start AND < entry window end
Exit: long, price - entry >= profit target k, for k = 1, 2, 3 in ascending distance, each checked only after target k-1 was hit; targets 1 and 2 close part of the position and target 3 closes the remainder
Exit: short, entry - price >= profit target k, for k = 1, 2, 3 in ascending distance, each checked only after target k-1 was hit; targets 1 and 2 close part of the position and target 3 closes the remainder
Exit: long, price <= entry AND the highest price since entry - entry >= breakeven trigger distance
Exit: short, price >= entry AND entry - the lowest price since entry >= breakeven trigger distance
Exit: long, price <= entry + lock distance AND the highest price since entry - entry >= lock trigger distance (lock trigger distance > breakeven trigger distance > lock distance > 0)
Exit: short, price >= entry - lock distance AND entry - the lowest price since entry >= lock trigger distance (lock trigger distance > breakeven trigger distance > lock distance > 0)
Exit: long, price >= entry AND entry - the lowest price since entry >= recovery trigger distance (recovery trigger distance ~ breakeven trigger distance)
Exit: short, price <= entry AND the highest price since entry - entry >= recovery trigger distance (recovery trigger distance ~ breakeven trigger distance)
Exit: long or short, hour of day >= closing hour (later than entry window end)