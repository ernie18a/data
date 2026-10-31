Calculation: Wave = a selectable moving average of the sum of seven weighted components, calculated on a selectable higher or lower timeframe. Each component is its positive weight times the sign of, respectively: close minus a moving average of a selected price; MACD main line minus its previous value; OsMA; CCI; momentum minus 100; RSI minus 50; and positive directional indicator minus negative directional indicator. A component with a nonpositive weight contributes zero. MACD and OsMA each use a shorter and a longer average and a signal average; each indicator may use its own selected price and parameters. Wave smoothing may use SMA, EMA, SMMA, LWMA, Jurik moving average, ultralinear moving average, parabolic moving average, T3, VIDYA, or Kaufman adaptive moving average. Evaluate Wave on the last completed bar by default, or on the still-forming bar if selected; previous Wave values refer to preceding bars of that timeframe.
Long: zero-crossing mode = selected AND Wave > 0 AND previous Wave <= 0
Short: zero-crossing mode = selected AND Wave < 0 AND previous Wave >= 0
Long: turning-point mode = selected AND Wave > previous Wave AND previous Wave < Wave two bars ago
Short: turning-point mode = selected AND Wave < previous Wave AND previous Wave > Wave two bars ago
Exit: long, zero-crossing mode = selected AND Wave < 0
Exit: short, zero-crossing mode = selected AND Wave > 0
Exit: long, turning-point mode = selected AND Wave < previous Wave
Exit: short, turning-point mode = selected AND Wave > previous Wave
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance