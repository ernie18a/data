Calculation: Session = bars grouped by calendar day in the selected timezone, optionally restricted to a session window; reset session state at each new session.
Calculation: TPO profile = for each session, choose a price-row size at its start, using a fixed size or an ATR fraction; for each chart bar, add one count to every row from floor(low / row size) through floor(high / row size). If a single bar spans more than the row limit, multiply the row size by the ceiling of its row count divided by the limit before adding that bar; retain existing row keys. The developing profile includes the current bar; the prior profile is the last completed session. The POC is the midpoint of the first inserted row with the maximum count. Starting at the POC, expand the value area one adjacent row at a time toward the larger count, choosing the upper row on ties, until the selected share of total counts is included. Value-area high and low are the upper and lower boundaries of the included rows. Session high and low are the outer boundaries of the highest and lowest occupied rows.
Calculation: Initial balance = highest high and lowest low of the first selected number of chart bars in the session, developing until that number is reached.
Calculation: Bias score = location score + migration score + extension score. Location is +1 when close is above developing value-area high, -1 when below developing value-area low, otherwise 0. Migration is +1 when developing value-area low is above prior value-area high, -1 when developing value-area high is below prior value-area low, otherwise 0. Extension is +1 when session high is above initial-balance high and session low is not below initial-balance low, -1 when session low is below initial-balance low and session high is not above initial-balance high, otherwise 0.
Calculation: TPO counts above and below POC = sums of row counts on each respective side of the developing POC, excluding rows with a count of one.
Calculation: Rotation factor = cumulative sum, within the session, of the signs of the changes in high and low between successive completed time brackets; each bracket high and low is calculated from its constituent chart bars. Start scoring after two brackets have completed.
Calculation: Profile shape = classify the developing profile as double distribution if its row range meets a minimum, its lowest-count interior row is no more than a selected fraction of the POC count, and the counts on each side of that row are each at least a selected fraction of total counts; the interior excludes a selected number of rows at each extreme. Otherwise calculate POC position as (POC row index - lowest row index) / (highest row index - lowest row index).
Calculation: Prior-value re-entry = count consecutive closes within the prior value area. At the start of each such run, record whether the preceding close was above or below prior value; retain the previously recorded side if it was inside. Reset the count, but not the recorded side, when close is outside; reset both at a new session. The required count is a selected multiple of the rounded ratio of bracket duration to chart-bar duration, with a minimum of one chart bar per bracket.
Long: close > developing value-area high.
Short: close < developing value-area low.
Long: close crosses above developing value-area high.
Short: close crosses below developing value-area low.
Long: developing value-area low > prior value-area high.
Short: developing value-area high < prior value-area low.
Long: bias score > 0.
Short: bias score < 0.
Long: session high - session low >= initial-balance width multiplied by the trend threshold AND max(0, session high - initial-balance high) >= max(0, initial-balance low - session low).
Short: session high - session low >= initial-balance width multiplied by the trend threshold AND max(0, session high - initial-balance high) < max(0, initial-balance low - session low).
Long: close - session open >= initial-balance width AND the smaller of the session's maximum upward and downward excursions from its open <= initial-balance width multiplied by the drive threshold.
Short: session open - close >= initial-balance width AND the smaller of the session's maximum upward and downward excursions from its open <= initial-balance width multiplied by the drive threshold.
Long: TPO count above POC > TPO count below POC multiplied by the imbalance threshold.
Short: TPO count below POC > TPO count above POC multiplied by the imbalance threshold.
Long: rotation factor > positive rotation threshold.
Short: rotation factor < negative rotation threshold.
Long: profile shape is not double distribution AND POC position >= upper position threshold.
Short: profile shape is not double distribution AND POC position <= lower position threshold.
Short: session high has exceeded prior value-area high AND close < prior value-area high.
Long: session low has fallen below prior value-area low AND close > prior value-area low AND NOT (session high has exceeded prior value-area high AND close < prior value-area high).
Long: prior-value re-entry count >= required count AND recorded entry side is below.
Short: prior-value re-entry count >= required count AND recorded entry side is above.