Calculation: Liquidity pools = enabled confirmed chart pivot highs/lows, equal same-side pivot levels within ATR(lookback) × equal-level tolerance merged by touch-weighted average, and configured prior-period and session highs/lows.
Calculation: Qualified sweep = on a confirmed chart bar, price pierces an untouched pool by at least the greater of ATR(lookback) × sweep-depth parameter and the minimum-tick floor, then closes back inside: low <= sellside pool level and close >= level, or high >= buyside pool level and close <= level.
Calculation: Pool reclaim = after a qualified sweep, a later confirmed chart bar closes back through the pool level within the reclaim window; when the body-close requirement is enabled, the long-side close is above max(open, level) and the short-side close is below min(open, level).
Calculation: Active sweep story = a qualifying sweep takes ownership if there is no live story or its source rank is at least the current story rank; equal-or-lower-ranked draw-side sweeps count as legs. Source rank is higher-period pools > lower-period pools > equal pools > session pools > swing pools.
Calculation: Confirmed post-reclaim higher low/lower high = the pullback low/high since the prior run extreme, confirmed when price makes a new run extreme; the run starts at the reclaim bar's high/low.
Calculation: Story stop = swept wick, replaced by the latest confirmed post-reclaim higher low above it for a long story or lower high below it for a short story.
Calculation: Nearest untouched pool above/below = the closest untouched pool strictly above/below close.
Calculation: Story reward/risk = distance from close to the nearest untouched pool on the story side divided by distance from close to the story stop.
Calculation: Story stop width = distance from close to the story stop divided by ATR(lookback).
Calculation: T1 structure bias persists until a confirmed chart bar closes above the latest T1 pivot high or below the latest T1 pivot low; that break sets bullish or bearish unless the prior bias flip was within the chop lookback, which sets neutral. Chart bars read T1 pivot values from the T1 bar still forming; T1 pivot highs and lows use their own left/right parameters.
Calculation: Minimum-R:R pass price = (target + minimum-R:R parameter × stop) / (1 + minimum-R:R parameter).
Long: a qualified sellside pool sweep occurs.
Short: a qualified buyside pool sweep occurs.
Long: a swept sellside pool reclaims.
Short: a swept buyside pool reclaims.
Long: T1 structure bias changes to bullish.
Short: T1 structure bias changes to bearish.
Long: a sellside sweep exists, LTF confirmation is enabled and not yet confirmed, and a later chart bar within the validity window closes above the latest confirmed T2 pivot high; chart bars use the latest completed T2 value, and T2 pivots have separate left/right parameters.
Short: a buyside sweep exists, LTF confirmation is enabled and not yet confirmed, and a later chart bar within the validity window closes below the latest confirmed T2 pivot low; chart bars use the latest completed T2 value, and T2 pivots have separate left/right parameters.
Long: at least two of these are true: the latest pair of confirmed chart pivot highs and lows are both rising; T1 structure bias is bullish; the latest pool break was upward within its lookback. Chart pivots use separate left/right parameters from T1 and T2 pivots.
Short: at least two of these are true: the latest pair of confirmed chart pivot highs and lows are both falling; T1 structure bias is bearish; the latest pool break was downward within its lookback. Chart pivots use separate left/right parameters from T1 and T2 pivots.
Long: an active, unfinished sellside-sweep story is reclaimed, and LTF confirmation is disabled or confirmed, and the nearest untouched pool above close exists, and Story reward/risk >= the minimum-R:R parameter, and Story stop width <= the maximum ATR-width parameter, and the story stop < close.
Short: an active, unfinished buyside-sweep story is reclaimed, and LTF confirmation is disabled or confirmed, and the nearest untouched pool below close exists, and Story reward/risk >= the minimum-R:R parameter, and Story stop width <= the maximum ATR-width parameter, and the story stop > close.
Long: an active, unfinished reclaimed long story is armed but fails at least one fresh-entry gate.
Short: an active, unfinished reclaimed short story is armed but fails at least one fresh-entry gate.
Long: an active, unfinished armed long story fails at least one fresh-entry gate and low <= the Minimum-R:R pass price.
Short: an active, unfinished armed short story fails at least one fresh-entry gate and high >= the Minimum-R:R pass price.
Exit: long, an active long story closes below its swept wick or below its latest confirmed higher low.
Exit: short, an active short story closes above its swept wick or above its latest confirmed lower high.
Exit: long, a position entry is set and an active unfinished short story has a stop at or below the position entry.
Exit: short, a position entry is set and an active unfinished long story has a stop at or above the position entry.
Exit: long, breadth is enabled and live during the configured cash session, the instrument is neither crypto nor forex, it is a weekday, ADD and TICK have values, and TICK >= the exhaustion parameter.
Exit: short, breadth is enabled and live during the configured cash session, the instrument is neither crypto nor forex, it is a weekday, ADD and TICK have values, and TICK <= negative exhaustion parameter.