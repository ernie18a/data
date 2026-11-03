Calculation: Valid body = body-filter multiplier is zero OR absolute(close - open) > body-filter multiplier × SMA of absolute(close - open), evaluated at the same bar.
Calculation: Active setup = a bullish or bearish four-bar pattern retained among the most recent configurable number of setups; zero means all retained setups. Its range is the highest high and lowest low of the pattern's last three bars, and its midpoint is their average. A setup can invert only once. The newest setup remains eligible to invert until replaced; an older setup is eligible only through its creation bar. When all setups are retained, remove older setups after the configurable retention interval.
Calculation: Confirmed pivot high/low = pivot high/low with equal numbers of bars on each side; make the pivot available on its confirmation bar. Retain only the latest confirmed pivot of each kind, and mark it unbroken until its first break.
Long: Close three bars ago < open three bars ago AND each of the last three closes > its open AND each of the last three bars has a valid body.
Short: Close three bars ago > open three bars ago AND each of the last three closes < its open AND each of the last three bars has a valid body.
Long: An eligible bearish active setup has not inverted AND close > its midpoint.
Short: An eligible bullish active setup has not inverted AND close < its midpoint.
Long: Close > latest unbroken confirmed pivot high when close-based breaks are selected OR high > latest unbroken confirmed pivot high when wick-based breaks are selected.
Short: Close < latest unbroken confirmed pivot low when close-based breaks are selected OR low < latest unbroken confirmed pivot low when wick-based breaks are selected.
Long: Close > reference-timeframe open.
Short: Close <= reference-timeframe open.
Calculation: Reference-timeframe open = open requested from a configurable reference timeframe; for a higher timeframe, historical bars use the last completed bar and real-time bars use the still-forming bar; for a lower timeframe, use the last available intrabar.
Long: RSI < lower RSI threshold.
Short: RSI > higher RSI threshold.
Long: Positive directional indicator > negative directional indicator.
Short: Positive directional indicator <= negative directional indicator.
Long: Close > close a configurable number of bars ago.
Short: Close < close the same number of bars ago.