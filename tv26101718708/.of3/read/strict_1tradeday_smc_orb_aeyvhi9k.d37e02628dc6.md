Calculation: OR high = maximum chart-bar high during the opening-range session of the trading day
Calculation: OR low = minimum chart-bar low during the opening-range session of the trading day
Calculation: OR range = OR high - OR low
Calculation: Latest swing high = latest confirmed pivot high of high, using the same pivot-lookback parameter on both sides
Calculation: Latest swing low = latest confirmed pivot low of low, using the same pivot-lookback parameter on both sides
Long: after the opening-range session, within the regular session, outside the entry-cutoff session, flat, and no earlier entry that trading day AND close > OR high AND a close cross above the latest swing high occurred within the CHoCH-validity lookback AND low > high two chart bars ago + the FVG minimum-gap parameter
Short: after the opening-range session, within the regular session, outside the entry-cutoff session, flat, and no earlier entry that trading day AND close < OR low AND a close cross below the latest swing low occurred within the CHoCH-validity lookback AND high < low two chart bars ago - the FVG minimum-gap parameter
Exit: long, high >= entry price + partial-exit range multiple × OR range OR the shorter-lookback SMA crosses below the longer-lookback SMA
Exit: short, low <= entry price - partial-exit range multiple × OR range OR the shorter-lookback SMA crosses above the longer-lookback SMA
Exit: long, low <= OR low OR low <= highest high since entry - ATR(ATR lookback) at entry × ATR-trail multiplier OR high >= entry price + take-profit multiple × OR range OR (elapsed time since entry > break-even delay AND low <= entry price) OR datetime is within the exit session
Exit: short, high >= OR high OR high >= lowest low since entry + ATR(ATR lookback) at entry × ATR-trail multiplier OR low <= entry price - take-profit multiple × OR range OR (elapsed time since entry > break-even delay AND high >= entry price) OR datetime is within the exit session