Calculation: pin-bar range = high[1] - low[1]
Calculation: body size fraction = abs(open[1] - close[1]) / pin-bar range
Calculation: body top = max(open[1], close[1])
Calculation: body bottom = min(open[1], close[1])
Calculation: body midpoint = (body top + body bottom) / 2
Calculation: upper shadow = high[1] - body top
Calculation: lower shadow = body bottom - low[1]
Calculation: body-location offset = (high[2] - low[2]) × body-location fraction parameter
Long: pin-bar range >= minimum candle-size parameter in points × point size AND body size fraction <= maximum body-size fraction parameter AND body top <= high[2] AND body bottom >= low[2] AND low[1] < low[2] AND low[1] <= low[3] AND body midpoint <= low[2] + body-location offset AND upper shadow >= lower shadow × shadow aspect-ratio parameter
Short: pin-bar range >= minimum candle-size parameter in points × point size AND body size fraction <= maximum body-size fraction parameter AND body top <= high[2] AND body bottom >= low[2] AND high[1] > high[2] AND high[1] >= high[3] AND body midpoint >= high[2] - body-location offset AND lower shadow >= upper shadow × shadow aspect-ratio parameter