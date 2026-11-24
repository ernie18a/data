Calculation: entry ATM strike = nearest multiple of the strike-step parameter to entry close
Calculation: first trigger-call strike = entry ATM strike + first trigger offset parameter × strike-step parameter
Calculation: second trigger-call strike = entry ATM strike + second trigger offset parameter × strike-step parameter
Calculation: entry trigger = external-source mode enabled AND (external source on the previous chart bar > close on the previous chart bar AND external source < close) OR external-source mode disabled AND Supertrend(ATR-length parameter, factor parameter) changes from bearish to bullish OR a prior raw signal is within the lookback parameter in chart bars, subsequent chart-bar highs and available T1 highs have not exceeded signal close + invalidation-distance parameter × strike-step parameter, (external-source mode enabled AND close > external source OR external-source mode disabled AND Supertrend direction is bullish), and an available T1 intrabar close <= signal close × (1 + entry-tolerance parameter)
Calculation: eligible entry = entry trigger AND flat AND a target expiry exists, has not already been traded, and current time is before the day-before-expiry cutoff
Long: eligible entry
Option: buy call, eligible entry
Option: sell call, eligible entry
Option: buy put, eligible entry
Option: sell put, eligible entry
Calculation: first adjustment trigger = long position at adjustment level zero AND, on chart bars, an available T1 intrabar value selected by the adjustment-trigger parameter (high or close) > first trigger-call strike
Option: buy call, first adjustment trigger
Option: sell call, first adjustment trigger
Option: buy put, first adjustment trigger
Option: sell put, first adjustment trigger
Calculation: second adjustment trigger = long position at adjustment level one AND, on chart bars, an available T1 intrabar value selected by the adjustment-trigger parameter (high or close) > second trigger-call strike
Option: buy call, second adjustment trigger
Option: buy put, second adjustment trigger
Calculation: trail adjustment trigger = long position at adjustment level two AND trail adjustment not already triggered AND at least one call or put adjustment is enabled AND chart high >= second trigger-call strike + trail-adjustment trigger-level parameter × strike-step parameter
Option: sell call, trail adjustment trigger AND call adjustment enabled
Option: buy call, trail adjustment trigger AND call adjustment enabled
Option: sell put, trail adjustment trigger AND put adjustment enabled
Option: buy put, trail adjustment trigger AND put adjustment enabled
Calculation: stop level = at entry, entry price × (1 − initial-stop percentage); on a chart bar whose day-of-month differs from the entry bar's, ratchet to the greater of the prior stop level and entry price × (1 − day-two stop percentage); when adjustment level first reaches two, set to second trigger-call strike − level-two-entry stop distance parameter × strike-step parameter; at adjustment level two, if effective trail steps >= minimum active trail level parameter, ratchet to the greater of the prior stop level and chart high minus the trail-distance parameter for the effective trail level, where effective trail steps = the lesser of floor((chart high − second trigger-call strike) / strike-step parameter) and maximum trail-level parameter
Calculation: exit trigger = long position AND (chart low < stop level OR chart time >= configured square-off time on the active expiry date OR an available T1 intrabar timestamp >= that time on the active expiry date)
Exit: Long, exit trigger
Option: sell call, exit trigger
Option: buy call, exit trigger AND trail adjustment not triggered
Option: sell put, exit trigger AND (trail adjustment not triggered OR put adjustment disabled)
Option: buy put, exit trigger AND (trail adjustment not triggered OR put adjustment disabled)