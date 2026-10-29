Calculation: ORB high = high of the first bar in the opening-range session, from the correlation series; use Heikin-Ashi high if that option is enabled
Calculation: ORB low = low of the first bar in the opening-range session, from the correlation series; use Heikin-Ashi low if that option is enabled
Calculation: Relative volume = cumulative volume in the current higher-timeframe anchor period divided by the average cumulative volume at the same point in the prior completed anchor periods
Long: close > ORB high AND time is within the trading session AND relative volume > 1 AND no short trade is active
Short: close < ORB low AND time is within the trading session AND relative volume > 1 AND no long trade is active
Exit: long, time is within the session-ending window
Exit: short, time is within the session-ending window