Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Exit: long, trailing-stop distance > 0 AND highest(high since entry) > entry price + trailing-stop distance AND low <= highest(high since entry) - trailing-stop distance
Exit: short, trailing-stop distance > 0 AND lowest(low since entry) < entry price - trailing-stop distance AND high >= lowest(low since entry) + trailing-stop distance