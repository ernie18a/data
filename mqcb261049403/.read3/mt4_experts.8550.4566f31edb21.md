Calculation: Pivot point = (high[2] + low[2] + close[2]) / 3
Calculation: Second resistance = Pivot point + high[2] - low[2]
Long: low <= Pivot point
Short: low <= Pivot point
Exit: long, high >= Second resistance OR (highest high since entry > entry price + trailing distance in points AND low <= highest high since entry - trailing distance in points)
Exit: short, high >= Second resistance OR (lowest low since entry < entry price - trailing distance in points AND high >= lowest low since entry + trailing distance in points)