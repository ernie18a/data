Calculation: Resistance = candidate bar high + ATR when the candidate high is below and within the point tolerance of more than Equal comparison-window highs; otherwise retain the previous resistance
Calculation: Support = candidate bar low - ATR when the candidate low is above and within the point tolerance of more than Equal comparison-window lows; otherwise retain the previous support
Calculation: Long target = signal bar high + abs(Resistance - Support) - point tolerance
Calculation: Short target = signal bar low - abs(Resistance - Support) + point tolerance
Long: each of the previous two completed chart bars' lows > Resistance AND Resistance > the third previous completed chart bar's open AND ATR < current bar volume AND Resistance has persisted longer than Delay bars AND no long signal has fired at this unchanged Resistance
Short: each of the previous two completed chart bars' highs < Support AND Support < the third previous completed chart bar's open AND ATR < current bar volume AND Support has persisted longer than two bars AND no short signal has fired at this unchanged Support
Exit: long, current bar high > Long target AND current bar low < Long target
Exit: short, current bar high > Short target AND current bar low < Short target