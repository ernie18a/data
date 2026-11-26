Calculation: Upper Boundary = Highest(high, reference length)[1] + ATR(atr length) * buffer ATR multiplier
Calculation: Lower Boundary = Lowest(low, reference length)[1] - ATR(atr length) * buffer ATR multiplier
Calculation: Accept Up = Count(close > Upper Boundary, acceptance count) == acceptance count AND Count(close > Upper Boundary, acceptance count)[1] < acceptance count
Calculation: Accept Down = Count(close < Lower Boundary, acceptance count) == acceptance count AND Count(close < Lower Boundary, acceptance count)[1] < acceptance count
Calculation: Accept Side = 1 if Accept Up, -1 if Accept Down, otherwise Accept Side[1]
Calculation: Accept Boundary = Upper Boundary if Accept Up, Lower Boundary if Accept Down, otherwise Accept Boundary[1]
Calculation: Bars Since Accept = 0 if Accept Up OR Accept Down, otherwise Bars Since Accept[1] + 1
Calculation: Up Failure = Accept Side == 1 AND Bars Since Accept <= failure window AND close < Accept Boundary
Calculation: Down Failure = Accept Side == -1 AND Bars Since Accept <= failure window AND close > Accept Boundary
Calculation: Late Up = Accept Side == 1 AND Bars Since Accept > failure window AND close < Accept Boundary
Calculation: Late Down = Accept Side == -1 AND Bars Since Accept > failure window AND close > Accept Boundary
Calculation: Held Up = Accept Side == 1 AND Bars Since Accept > failure window AND close > Accept Boundary
Calculation: Held Down = Accept Side == -1 AND Bars Since Accept > failure window AND close < Accept Boundary
Calculation: Failure Risk = 0 if Accept Side == 0, otherwise Accept Side * (Accept Boundary - close) / ATR(atr length) * risk scale + risk offset
Calculation: Path State = first listed condition that holds, otherwise Path State[1]: Accept Above if Accept Up; Accept Below if Accept Down; Upside Failed if Up Failure AND NOT Up Failure[1]; Downside Failed if Down Failure AND NOT Down Failure[1]; Late Up Fail if Late Up AND NOT Late Up[1]; Late Down Fail if Late Down AND NOT Late Down[1]; Accept Held if (Held Up AND NOT Held Up[1]) OR (Held Down AND NOT Held Down[1]); Reclaim Test if NOT Accept Up AND NOT Accept Down AND ((Path State[1] == Upside Failed AND close > Accept Boundary) OR (Path State[1] == Downside Failed AND close < Accept Boundary))
Long: Accept Up
Short: Accept Down
Short: Up Failure AND NOT Up Failure[1]
Long: Down Failure AND NOT Down Failure[1]
Short: Late Up AND NOT Late Up[1]
Long: Late Down AND NOT Late Down[1]
Long: Held Up AND NOT Held Up[1]
Short: Held Down AND NOT Held Down[1]
Short: Accept Side == 1 AND Failure Risk >= pressure threshold AND Failure Risk[1] < pressure threshold
Long: Accept Side == -1 AND Failure Risk >= pressure threshold AND Failure Risk[1] < pressure threshold
Long: (Path State == Accept Above OR (Path State == Accept Held AND Accept Side == 1)) AND Failure Risk < pressure threshold
Short: (Path State == Accept Below OR (Path State == Accept Held AND Accept Side == -1)) AND Failure Risk < pressure threshold