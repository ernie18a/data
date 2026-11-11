Calculation: Session VWAP = cumulative sum of source price × max(volume, 1) divided by cumulative sum of max(volume, 1), using chart bars in the current session through the current bar; reset at each new session and retain the last value outside the session. Source price is configurable.
Calculation: Session weighted standard deviation = square root of max(cumulative sum of source price² × max(volume, 1) divided by cumulative sum of max(volume, 1) minus session VWAP², 0), using the same session bars and retention rules as session VWAP.
Calculation: Upper and lower middle bands = session VWAP plus and minus a configurable multiplier of session weighted standard deviation, respectively.
Long: close crosses above session VWAP.
Long: low <= lower middle band AND previous low > previous lower middle band.
Short: close crosses below session VWAP.
Short: high >= upper middle band AND previous high < previous upper middle band.