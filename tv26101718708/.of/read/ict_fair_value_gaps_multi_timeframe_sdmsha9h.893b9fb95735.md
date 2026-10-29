Calculation: Body top = max(open, close)
Calculation: Body bottom = min(open, close)
Calculation: Pattern bars = three consecutive bars from the chart timeframe or a higher timeframe; evaluate only after the third bar has completed
Calculation: Session break = the next bar opens after the previous bar closes, or the time between their opens exceeds one bar interval
Long: low(C3) > high(C1) OR (body top(C1) < body bottom(C2) AND low(C3) > body bottom(C2) AND NOT session break(C1,C2)) AND NOT ((session break(C1,C2) AND open(C2) > high(C1)) OR (session break(C2,C3) AND open(C3) > high(C2)))
Short: high(C3) < low(C1) OR (body bottom(C1) > body top(C2) AND high(C3) < body top(C2) AND NOT session break(C1,C2)) AND NOT ((session break(C1,C2) AND open(C2) < low(C1)) OR (session break(C2,C3) AND open(C3) < low(C2)))