Calculation: Up volume and down volume = sum volumes separately over all completed lower-timeframe bars within each chart bar. Assign each lower-timeframe bar to up or down according to close versus open; if equal, use close versus the preceding lower-timeframe close; if still equal, retain the last known polarity.
Calculation: Bar balance = up volume minus down volume.
Calculation: Average balance = EMA of up volume minus EMA of down volume, using the same period.
Calculation: Momentum balance = RSI of ((EMA of up volume minus SMA of up volume) minus (EMA of down volume minus SMA of down volume)) minus its midpoint; both EMAs use the average-balance period and both SMAs use twice that period.
Calculation: Relative balance = ALMA of (max(0, up volume minus its average-balance EMA) minus max(0, down volume minus its average-balance EMA)).
Calculation: Percent balance = ALMA of bar balance divided by chart-bar volume.
Calculation: Combined balance = sum of the signs of bar balance, average balance, momentum balance, relative balance, and percent balance.
Calculation: Selected balance = one selectable balance from bar balance, average balance, momentum balance, relative balance, percent balance, or combined balance; the balance selected for divergence confirmation can differ from that selected for balance shifts. Balance shifts exclude bar balance.
Calculation: Divergence = sign of the selected balance differs from sign of close minus open, including zero signs.
Calculation: Up bump = close > open AND close > previous close AND bar balance > 0 AND up volume > its average-balance EMA AND up volume > previous up volume.
Calculation: Down bump = close < open AND close < previous close AND bar balance < 0 AND down volume > its average-balance EMA AND down volume > previous down volume.
Calculation: Up divergence confirmation = previous bar has divergence AND close > open AND current bar has no divergence.
Calculation: Down divergence confirmation = previous bar has divergence AND close < open AND current bar has no divergence.
Calculation: Marker bias = rolling sum of (up bump + two consecutive up bumps + up divergence confirmation + selected balance crossing above zero) minus (down bump + two consecutive down bumps + down divergence confirmation + selected balance crossing below zero), counting each true condition as one.
Calculation: Volume top and bottom = max(open, close) plus reference body size times top factor, and min(open, close) minus reference body size times bottom factor. Reference body size is either the current absolute candle body size or its longer-period SMA. Factors are selectable as up and down volume divided by their sum, respectively; positive and negative bar balance magnitudes divided by total intrabar volume, respectively; or positive and negative combined balance magnitudes divided by the number of component balances, respectively. In the latter two modes the factor on the losing side is unavailable.
Calculation: Divergence channel = on a selected divergence, initialize or, after a breach, reset the upper and lower levels to a selectable pair: full range including volume top and bottom, volume top and bottom with high and low substituted where unavailable, candle body high and low, or high and low. On further divergences before a breach, expand the levels to include the selected pair. A breach occurs when selectable upper and lower reference prices exceed the upper level or fall below the lower level, respectively; references are either the opposite ends of the full range, volume top and bottom, candle body, or high-low range, or the corresponding volume top and bottom, high and low, or close. Retain the last breach direction until a new channel is created.
Long: close > open.
Short: close <= open.
Long: selected balance > 0 AND chart volume > previous chart volume.
Short: selected balance < 0 AND chart volume > previous chart volume.
Long: up volume > down volume.
Short: down volume > up volume.
Long: up bump OR up divergence confirmation OR selected balance crosses above zero OR marker bias crosses above zero OR all five component balances > 0.
Short: down bump OR down divergence confirmation OR selected balance crosses below zero OR marker bias crosses below zero OR all five component balances < 0.
Long: divergence channel last breach direction is above.
Short: divergence channel last breach direction is below.