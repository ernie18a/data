Calculation: Volume Profile = aggregate volume into bins rounded to the configured bin width over the configured profile period, using T1 bars when available and chart bars otherwise; assign volume evenly across bins from rounded low to rounded high or to the configured representative price, with T2 profiles using chart close when T1 data is unavailable; POC is the lowest-price bin tied for maximum volume, and value area expands from POC by adding the higher-volume adjacent bin, ties upward, until the configured volume fraction is reached
Calculation: Chart-bar signed volume delta = sum across available T1 bars of volume when close > open, negative volume when close < open, and zero when close = open; when T1 data is unavailable, use the chart bar with the same formula
Calculation: Current T2 delta = sum of chart-bar signed volume deltas in the current forming T2 candle, including the live chart-bar delta while that bar is forming
Calculation: Session reference profile = prior completed configured profile period, or the developing session profile on the latest chart bar; historical bars use the prior completed profile
Calculation: Higher-timeframe reference profile = the previous completed T2 candle profile, the combined Volume Profile of the last N completed T2 candles held fixed during the current T2 candle, or the selected session reference profile
Calculation: Session up-volume share = cumulative session up-volume on confirmed chart bars divided by cumulative chart-bar volume; per chart bar, up-volume is (sum of T1 volume + sum of T1 signed volume delta) / 2 when T1 data is available, otherwise chart volume if close > open and zero otherwise
Calculation: Profile-row up-volume = sum of volume assigned to that displayed profile row from T1 bars with close > open, or chart bars when T1 data is unavailable
Long: valid selected reference profile AND close > VAH
Short: valid selected reference profile AND close < VAL
Long: valid selected delta-profile reference AND close >= VAL AND close <= VAH AND close > POC AND inside-value lean parameter > 0
Short: valid selected delta-profile reference AND close >= VAL AND close <= VAH AND close < POC AND inside-value lean parameter > 0
Long: valid session reference profile AND close > POC
Short: valid session reference profile AND close < POC
Long: chart-bar signed volume delta > 0
Short: chart-bar signed volume delta < 0
Long: current forming T2 delta > 0, evaluated on chart bars using the current T2 value
Short: current forming T2 delta < 0, evaluated on chart bars using the current T2 value
Long: session volume > 0 AND session up-volume share > 1/2
Short: session volume > 0 AND session up-volume share < 1/2
Long: displayed profile-row up-volume >= half of displayed profile-row volume
Short: displayed profile-row up-volume < half of displayed profile-row volume
Long: on a confirmed chart bar, close > most recently stored developing-session POC AND close[1] <= that POC
Short: on a confirmed chart bar, close < most recently stored developing-session POC AND close[1] >= that POC
Long: on a confirmed chart bar, close > most recently stored developing-session VAH AND close[1] <= that VAH
Short: on a confirmed chart bar, close < most recently stored developing-session VAL AND close[1] >= that VAL