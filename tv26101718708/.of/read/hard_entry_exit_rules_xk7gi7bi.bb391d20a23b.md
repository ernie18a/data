Calculation: PDH = high of the last completed daily bar on a higher timeframe than the chart
Calculation: PDL = low of the last completed daily bar on a higher timeframe than the chart
Calculation: PMH = highest high during the current day's premarket session
Calculation: PML = lowest low during the current day's premarket session
Calculation: Entry HOD/LOD = highest high / lowest low in the regular session up to the entry bar
Long: flat AND trades today below the configured daily maximum AND within the configured entry window AND close > VWAP AND fast EMA > slow EMA AND close > slow EMA AND close > fast EMA AND (close > PDH OR close > PMH) AND ((enabled PDH or PMH retest: low <= level × (1 + tolerance) AND close > level AND close > open) OR (enabled PDH or PMH first touch: high >= level × (1 - tolerance) AND low <= level × (1 + tolerance) AND close > level AND close > open) OR (enabled fast EMA tap: low <= fast EMA AND close > fast EMA AND close > open))
Short: flat AND trades today below the configured daily maximum AND within the configured entry window AND close < VWAP AND fast EMA < slow EMA AND close < slow EMA AND close < fast EMA AND (close < PDL OR close < PML) AND ((enabled PDL or PML retest: high >= level × (1 - tolerance) AND close < level AND close < open) OR (enabled PDL or PML first touch: high >= level × (1 - tolerance) AND low <= level × (1 + tolerance) AND close < level AND close < open) OR (enabled fast EMA tap: high >= fast EMA AND close < fast EMA AND close < open))
Exit: long, low <= slow EMA
Exit: long, close < fast EMA OR (entry level is set AND close < entry level)
Exit: long, high >= entry HOD + minimum tick
Exit: long, position is open AND within the configured end-of-day flatten window
Exit: short, high >= slow EMA
Exit: short, close > fast EMA OR (entry level is set AND close > entry level)
Exit: short, low <= entry LOD - minimum tick
Exit: short, position is open AND within the configured end-of-day flatten window