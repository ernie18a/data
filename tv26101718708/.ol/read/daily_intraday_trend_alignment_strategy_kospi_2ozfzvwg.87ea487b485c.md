Long: close > previous day's close AND close > open AND weekday AND KST hour < 14 AND configured intraday entry-check bar closes AND no entry has occurred that day
Short: close <= previous day's close AND close <= open AND weekday AND KST hour < 14 AND configured intraday entry-check bar closes AND no entry has occurred that day
Exit: long, low <= entry price minus the configured stop-loss distance
Exit: long, high >= entry price plus the configured take-profit distance
Exit: short, high >= entry price plus the configured stop-loss distance
Exit: short, low <= entry price minus the configured take-profit distance
Exit: long or short, KST hour = 14 AND KST minute >= 50