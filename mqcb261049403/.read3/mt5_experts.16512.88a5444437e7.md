Calculation: WPR trend state = up when Williams %R(close, high, low, shorter lookback) > Williams %R(close, high, low, longer lookback) AND Williams %R(close, high, low, longer lookback) > Level; down when Williams %R(close, high, low, shorter lookback) < Williams %R(close, high, low, longer lookback) AND Williams %R(close, high, low, longer lookback) < -100 - Level; neutral otherwise, calculated on T1 bars
Long: WPR trend state is up on the signal T1 bar at the signal-bar offset (offset zero is still forming; positive offsets are completed bars)
Long: WPR trend state is up on the signal T1 bar AND WPR trend state is not up on the preceding T1 bar
Short: WPR trend state is down on the signal T1 bar at the signal-bar offset (offset zero is still forming; positive offsets are completed bars)
Short: WPR trend state is down on the signal T1 bar AND WPR trend state is not down on the preceding T1 bar
Exit: long, WPR trend state is down on the signal T1 bar AND WPR trend state was down on the preceding T1 bar
Exit: short, WPR trend state is up on the signal T1 bar AND WPR trend state was up on the preceding T1 bar