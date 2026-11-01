Calculation: Buy and sell volume = sum the volumes of completed lower-timeframe bars within each chart bar, assigning each lower-timeframe bar to buy if its close is above its open, to sell if below; if equal, assign by the direction of its close versus the preceding lower-timeframe close, or, if unchanged, by the preceding lower-timeframe bar's assigned direction. Leave volume unassigned if no direction is known.
Calculation: On-bar balance = buy volume minus sell volume.
Calculation: Average balance = EMA of buy volume minus EMA of sell volume, using the same lookback.
Calculation: Momentum balance = RSI of ((buy-volume EMA minus buy-volume SMA) minus (sell-volume EMA minus sell-volume SMA)), minus the RSI midpoint; both SMAs use twice the average-balance EMA lookback.
Calculation: Relative balance = ALMA of (max(0, buy volume minus its average-balance EMA) minus max(0, sell volume minus its average-balance EMA)).
Calculation: Percent balance = ALMA of (on-bar balance divided by chart-bar volume).
Calculation: Combined balance = sum of the signs of the on-bar, average, momentum, relative, and percent balances; each sign is positive, negative, or zero according to its balance.
Calculation: Up bump = close > previous close AND on-bar balance > 0 AND buy volume > its average-balance EMA AND buy volume > previous buy volume.
Calculation: Down bump = close < previous close AND on-bar balance < 0 AND sell volume > its average-balance EMA AND sell volume > previous sell volume.
Calculation: Up divergence = selected balance > its previous value AND close < previous close; down divergence = selected balance < its previous value AND close > previous close. The selected balance may be on-bar, average, momentum, relative, percent, or combined.
Calculation: Up marker events = combined balance = 5; or up bumps on each of the two preceding bars; or an up divergence two bars ago AND the preceding close > the close two bars ago AND neither divergence direction occurred on the preceding bar; or a selected average, momentum, relative, percent, or combined balance crossed above zero on the preceding bar.
Calculation: Down marker events = combined balance = -5; or down bumps on each of the two preceding bars; or a down divergence two bars ago AND the preceding close < the close two bars ago AND neither divergence direction occurred on the preceding bar; or a selected average, momentum, relative, percent, or combined balance crossed below zero on the preceding bar.
Calculation: Marker bias = rolling sum of the number of up marker events minus the number of down marker events on each chart bar, counting each of the four event types separately.
Long: Selected on-bar, average, momentum, relative, percent, combined, or marker-bias balance > 0.
Short: Selected on-bar, average, momentum, relative, percent, combined, or marker-bias balance < 0.
Short: Selected line-color balance <= 0.
Long: Any up marker event occurs OR marker bias crossed above zero on the preceding bar.
Short: Any down marker event occurs OR marker bias crossed below zero on the preceding bar.