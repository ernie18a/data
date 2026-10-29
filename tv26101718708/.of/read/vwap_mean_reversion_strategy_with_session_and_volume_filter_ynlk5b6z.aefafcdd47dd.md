Calculation: Session VWAP = cumulative sum of (((high + low + close) / 3) × volume) since session start / cumulative volume since session start
Long: close < Session VWAP - ATR × distance threshold AND volume < its longer-lookback simple moving average AND datetime >= session start AND datetime < session end AND position side = flat
Short: close > Session VWAP + ATR × distance threshold AND volume < its longer-lookback simple moving average AND datetime >= session start AND datetime < session end AND position side = flat
Exit: long, low <= entry price - ATR at entry × stop multiplier OR high >= Session VWAP at entry
Exit: short, high >= entry price + ATR at entry × stop multiplier OR low <= Session VWAP at entry