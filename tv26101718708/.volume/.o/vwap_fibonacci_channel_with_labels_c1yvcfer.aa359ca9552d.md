Calculation: Intraday VWAP = cumulative sum of ((high + low + close) / 3 × volume) since the start of the current day, divided by cumulative volume since the start of the current day; use the current, still-forming day
Calculation: Intraday range = highest high minus lowest low since the start of the current day; use the current, still-forming day
Calculation: 1.000 level = Intraday VWAP + 0.5 × Intraday range
Calculation: 0.786 level = Intraday VWAP + 0.286 × Intraday range
Calculation: 0.618 level = Intraday VWAP + 0.118 × Intraday range
Calculation: 0.500 level = Intraday VWAP
Calculation: 0.382 level = Intraday VWAP − 0.118 × Intraday range
Calculation: 0.236 level = Intraday VWAP − 0.286 × Intraday range
Calculation: 0.000 level = Intraday VWAP − 0.5 × Intraday range
Long: close > 0.618 level
Long: previous completed bar close > 0.618 level AND low <= 0.500 level AND (close > open OR low < min(open, close))
Long: low < 0.000 level AND close >= 0.000 level AND close <= 0.236 level AND close > open
Exit: long, close >= 0.786 level OR close >= 1.000 level OR (close < 0.500 level AND volume is low)
Exit: long, (close >= 0.618 level OR close >= 0.786 level) OR (close < 0.382 level AND close < open)
Exit: long, close >= 0.382 level OR close >= 0.500 level OR low < 0.000 level