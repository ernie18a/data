<!-- tradingview-pine-id: PUB;598b6ed7e67b41c0b09a198f98cbfb77 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breakout Quality Analyzer (Wyckoff VSA)

Source: https://www.tradingview.com/script/FcPagxyf-Breakout-Quality-Analyzer-Wyckoff-VSA/

## Description

BREAKOUT QUALITY ANALYZER v3.2 (Wyckoff VSA)

A 9-module volume analysis system that reads the "tape" — the hidden story inside every price bar — to tell you whether a stock breakout is backed by genuine institutional buying or is a trap about to reverse.

Version 3.2 adds an independent higher-timeframe (HTF) confirmation layer on top of those nine modules — described in its own section below — that checks whether the stock's bigger-picture weekly (or other higher-timeframe) tape agrees with what the daily bar is telling you.

Written in plain English for beginners. Every abbreviation is spelled out. Every concept is defined before it is used.

================================================================
WHAT IS "TAPE READING"?
================================================================

Before computers, stock prices were printed on a thin strip of paper called a ticker tape. Traders who could read this tape — watching the speed, size, and direction of trades as they printed — could see what big money was doing before the price reflected it.

Today we do not have paper tape, but the concept is the same: reading the relationship between price and volume on each bar to understand who is in control — buyers or sellers — and whether that control is strengthening or weakening.

This indicator automates tape reading. It looks at every daily bar and asks: "What is the volume telling me that the price alone does not?"

================================================================
THE THREE-COLUMN DASHBOARD
================================================================

The indicator displays a table with three columns side by side:

COLUMN 1 — LIVE TAPE READER
Shows what is happening on today's bar RIGHT NOW. Updates with every tick. This is your real-time tape read.

COLUMN 2 — LAST BREAKOUT SCORECARD
Shows the frozen scores from the most recent breakout day. These values are captured ("latched") at the moment of breakout and do not change afterward, so you can always reference exactly how the breakout scored.

COLUMN 3 — VSA RECENCY
Shows how many bars ago each Volume Spread Analysis signal last appeared. This is the column that tells you the recent history of institutional activity at a glance.

Version 3.2 adds a fourth, separate table — the HTF CONTEXT TABLE — placed in a different corner of the panel so it never overlaps the three-column dashboard. It is covered in its own section below.

================================================================
KEY VOCABULARY (read this first)
================================================================

BAR: One unit on the chart. On a daily chart, one bar = one trading day. Each bar has four prices: Open (where it started), High (the highest price reached), Low (the lowest price reached), and Close (where it finished).

SPREAD: The distance from the bar's High to its Low. A wide spread means price moved a lot. A narrow spread means price barely moved. Not to be confused with bid-ask spread.

CLOSE POSITION: Where the Close falls between the Low and the High, expressed as a percentage. If the High is $150, the Low is $140, and the Close is $148, the close position is 80% (near the top). Close near the top = buyers won. Close near the bottom = sellers won.

VOLUME: The total number of shares traded during that bar. High volume means lots of participation. Low volume means few participants.

DELTA: The difference between buying volume and selling volume within a single bar. Positive delta = more buying. Negative delta = more selling.

CVD (Cumulative Volume Delta): A running total of delta across all bars. Tracks the cumulative tide of buying vs selling pressure over time.

DV RATIO (Dollar Volume Ratio): The percentage of a bar's volume estimated to be buyer-initiated, calculated using the close position formula. DV Ratio of 70% means roughly 70% of that bar's volume was buying.

ATR (Average True Range): The average size of daily price movement over the last 14 days. Used as a yardstick to measure whether today's spread is normal, narrow, or wide relative to recent history.

EMA (Exponential Moving Average): A smoothed average that gives more weight to recent data. The "50 EMA" is the average of the last 50 bars with extra emphasis on the most recent ones.

HIGHER TIMEFRAME (HTF): A bigger-picture chart built from the same data, just grouped into longer bars. If you are looking at a daily chart, the weekly timeframe groups five days into one bar. Institutions build positions over weeks and months, so the weekly bar often tells a cleaner story than any single daily bar — it filters out one day's noise.

REPAINTING: When an indicator's reading on a still-forming bar keeps changing as new price ticks come in, then locks into a DIFFERENT final value once the bar actually closes. A repainting weekly reading might show "Accumulation" on Wednesday and quietly flip to "Exhaustion" by Friday's close — meaning the "confirmation" you traded on Wednesday was never real. This indicator is built specifically to avoid that; see "THE HTF CONTEXT TABLE" below for how.

BREAKOUT: When price closes above a prior resistance level (the highest high of the last 20 bars) on above-average volume. This is the specific event the indicator scores.

ACCUMULATION: The process of institutions quietly buying shares over time, building a large position before the price moves significantly higher.

DISTRIBUTION: The opposite — institutions quietly selling shares into strength, unloading their position before the price drops.

EXHAUSTION: A move that has run out of fuel. The final push higher or lower before a reversal, often characterized by high volume but poor price progress.

================================================================
THE NINE SCORING MODULES
================================================================

The indicator runs nine separate tests on every breakout and combines them into a composite score out of 28 points. Here is what each one measures and why it matters.

MODULE 1: EFFORT vs RESULT (0 to 3 points)
Abbreviation on scorecard: Effort/Result

WHAT IT IS:
Effort = how much volume (trading activity) occurred.
Result = how much the price actually moved (the spread).

This module divides the Result by the Effort. If a stock traded 80 million shares (big effort) and the price moved $8 (big result), the ratio is healthy — effort produced result. If the same 80 million shares only moved the price $1, something is absorbing all that buying. Sellers are meeting every buy order with a sell order. The move is struggling.

SCORING:
Ratio above 1.2 = 3 points (result exceeds effort — easy, unresisted move)
Ratio 0.9 to 1.2 = 2 points (balanced — acceptable)
Ratio 0.6 to 0.9 = 1 point (effort starting to exceed result — caution)
Ratio below 0.6 = 0 points (heavy effort, little result — exhaustion signal)

WHY IT MATTERS:
This is Richard Wyckoff's Third Law: the Law of Effort vs Result. When effort and result are in harmony, the move is genuine. When they diverge, the move is about to fail.

MODULE 2: CLOSE POSITION (0 to 3 points)
Abbreviation on scorecard: Close Pos

WHAT IT IS:
Where the price closed within the bar's range, expressed as a percentage from 0% (closed at the low) to 100% (closed at the high).

This comes from Tom Williams' Volume Spread Analysis. The close position reveals who won the battle on that bar. If a stock rallied to $150 during the day but closed at $141 (close position = 10%), sellers overwhelmed buyers by the end of the session despite the initial rally.

SCORING:
Above 75% = 3 points (buyers dominated through the close)
60% to 75% = 2 points (buyers have the edge)
40% to 60% = 1 point (contested — neither side won decisively)
Below 40% = 0 points (sellers dominated despite any intraday rally)

WHY IT MATTERS:
On a breakout day, you want to see the stock close near its high. A breakout that closes near the low of the day — even if it went higher during the day — means institutions were selling into the rally. That is the classic distribution pattern.

MODULE 3: PRE-BREAKOUT ABSORPTION (0 to 3 points)
Abbreviation on scorecard: Absorption

WHAT IT IS:
Checks the 20 trading days BEFORE the breakout for three signs that institutions were quietly accumulating shares:

Sign 1 — Volume Dry-Up (+1 point): Average volume in the base period was below 85% of the longer-term average. Sellers are running out of shares to sell. Like a lake being drained — no more water to push the boat down.

Sign 2 — Range Contraction (+1 point): Average daily spread in the base period was below 85% of the longer-term average. Price swings are getting smaller, like a spring being compressed. This is the Volatility Contraction Pattern (VCP) that Mark Minervini describes.

Sign 3 — Accumulation Days Beat Distribution Days (+1 point): More up-days on above-average volume than down-days on above-average volume. The net institutional flow in the base was positive.

SCORING:
All three signs present = 3 points (textbook pre-breakout accumulation)
Two signs = 2 points (strong)
One sign = 1 point (partial)
None = 0 points (breakout came without proper base building)

WHY IT MATTERS:
Genuine breakouts are prepared. Institutions spend weeks quietly buying before the breakout happens. This module detects that preparation. A breakout without prior absorption is more likely to be impulsive and unsustainable.

MODULE 4: VOLUME CHARACTER CHANGE (0 to 3 points)
Abbreviation on scorecard: Vol Surge

WHAT IT IS:
Compares the breakout day's volume to the average volume during the quiet pre-breakout period. A genuine breakout should show a dramatic increase — a "character change" — from the quiet base to the breakout day.

Think of it as the difference between a whisper and a shout. If the base period averaged 2 million shares per day and the breakout day traded 6 million, that is a 3x character change. Institutions are making their move with conviction.

If the base was already loud (4 million per day) and the breakout was only slightly louder (5 million), the character change is modest. The breakout may be just noise, not a deliberate institutional move.

SCORING:
Above 2.5x the pre-breakout average = 3 points (dramatic character change)
1.8x to 2.5x = 2 points (solid surge)
1.3x to 1.8x = 1 point (modest)
Below 1.3x = 0 points (no meaningful character change)

MODULE 5: VOLUME RANK (0 to 2 points)
Abbreviation on scorecard: Vol Rank

WHAT IT IS:
Checks whether the breakout day had the highest volume of the last 20 trading days.

On a genuine institutional breakout, the breakout day should be the single busiest day in a month. If it is not even the busiest day in the last two weeks, institutions are not showing up with maximum conviction.

SCORING:
Highest volume in 20 days = 2 points
Higher than the prior 10-day high = 1 point
Not the highest = 0 points

MODULE 6: SPREAD QUALITY (0 to 2 points)
Abbreviation on scorecard: Spread

WHAT IT IS:
Compares the breakout bar's spread (high minus low) to the average spread over the last 50 bars. A breakout bar should have a wider-than-average range, showing that price moved with purpose.

A narrow-spread bar on heavy volume is one of the clearest exhaustion signals in tape reading. It means massive effort produced almost no price progress — Wyckoff's Effort vs Result divergence at its most visible.

SCORING:
Spread above 1.5x average = 2 points (decisive move)
Spread 1.0x to 1.5x average = 1 point (adequate)
Spread below average = 0 points (weak despite volume)

MODULE 7: CVD DIVERGENCE (0 to 3 points)
Abbreviation on scorecard: CVD
Full name: Cumulative Volume Delta Divergence

WHAT IT IS:
CVD is the running total of buying volume minus selling volume across every bar on the chart. Each bar's buying and selling volume is estimated using the High-Low-Close formula:

Buying Volume = Total Volume multiplied by (Close minus Low) divided by (High minus Low)
Selling Volume = Total Volume multiplied by (High minus Close) divided by (High minus Low)

The indicator compares the direction of CVD over the last 3 bars to the direction of price over the same 3 bars.

CONFIRMATION: CVD rising + Price rising = harmony. The volume flow supports the price move. This is what you want on a breakout. (+2 points)

DIVERGENCE: CVD falling + Price rising = conflict. Price is going up but the cumulative buying pressure underneath is actually declining. Smart money has been net sellers over the last few days even though price managed to push higher. The breakout is on borrowed time. (+0 points)

STEALTH ACCUMULATION BONUS: If CVD was rising in the 5 bars before the breakout while price was flat or declining, institutions were buying during the quiet period when nobody was watching. This adds +1 bonus point.

SCORING:
CVD confirms breakout + stealth accumulation = 3 points (maximum)
CVD confirms breakout = 2 points
Neutral = 1 point
CVD diverges (bearish) = 0 points (exhaustion warning)

WHY CVD INSTEAD OF OBV:
The older OBV (On-Balance Volume) indicator assigns ALL of a bar's volume as buying or selling based solely on whether the bar closed up or down. CVD splits each bar's volume proportionally based on where the close fell within the range. A bar that rallied to $150 then sold off to close at $141 would have ALL its volume counted as buying by OBV (because close was above yesterday). CVD correctly identifies that most of that volume was selling pressure pushing the stock down from its high.

MODULE 8: HIDDEN SIGNAL / DV FLOW (0 to 3 points)
Abbreviation on scorecard: Hidden Signal
Full name: Dollar Volume Flow with Hidden Buy/Sell Detection

WHAT IT IS:
This module estimates the buy/sell volume split on each bar and looks for conflicts between the volume flow direction and the candle color.

DV RATIO = Buying Volume divided by Total Volume. Expressed as 0 to 1.0 (or 0% to 100%).

HIDDEN BUY (HB): A red (down) bar where the DV Ratio is above 55%. Price fell, but buyers actually controlled the majority of the volume. Someone large is accumulating shares while keeping the price from rising. This is stealth institutional buying — they are filling their order without alerting the market.

HIDDEN SELL (HS): A green (up) bar where the DV Ratio is below 45%. Price rose, but sellers dominated the volume. Institutions are distributing shares into the rally while retail traders chase the green candle. This is the most dangerous pattern on a breakout day.

SCORING (on the breakout bar):
DV Ratio above 65% = 3 points (strong buyer dominance — genuine accumulation)
DV Ratio 55% to 65% = 2 points (moderate buyer flow — acceptable)
DV Ratio 45% to 55% = 1 point (balanced — no edge)
DV Ratio below 45% = 0 points (HIDDEN SELL — institutions distributing into the breakout)

The indicator marks "HB" and "HS" labels on every bar throughout the chart, not just breakout bars. This lets you visually scan the base-building period before a breakout. Seeing multiple HB labels in the base before a breakout is powerful confirmation of genuine accumulation.

MODULE 9: TOM WILLIAMS VSA ENGINE (negative 5 to positive 5 points)
Abbreviation on scorecard: TW VSA Net
Full name: Tom Williams Volume Spread Analysis Engine

WHAT IT IS:
This module detects four specific bar patterns that Tom Williams identified as the fingerprints of institutional operators. Unlike Modules 1-8 which score from zero upward, this module can ADD or SUBTRACT points — rewarding bullish patterns and penalizing bearish ones.

The four patterns:

NO SUPPLY (NS) — worth +2 points
Full definition: A down bar (close below open) with low volume (below 70% of average), narrow spread (below 0.5x ATR), and the close near the high of the bar (above 60% of the range).

What it means in plain English: The stock dipped, but nobody was selling. Volume was thin, the move was small, and the close recovered near the top. Sellers are absent. In an uptrend, this is healthy — it means pullbacks lack selling conviction. The stock is being held, not distributed.

Real-world analogy: Imagine a store lowering prices to see if anyone wants to sell their inventory back. Nobody shows up. That means everyone who owns the product wants to keep it. When the store raises prices again, there is no supply to push them back down.

SHAKEOUT (SHK) — worth +3 points (highest bullish score)
Full definition: The low breaches the local support level (the lowest low of the last 10 bars), but the close recovers back above support, on high volume (above 1.5x average), wide spread (above 1.2x ATR), and close near the high.

What it means: Smart money engineered a false breakdown to trigger stop-loss orders from weak holders. The stock plunged through support (triggering panic selling), then immediately reversed and closed strong. The institutions bought all the shares that the panicked traders sold.

This is one of the highest-conviction bullish signals in all of tape reading. Wyckoff called it a "spring" — the market springs below support and snaps back, clearing out weak hands and confirming that demand overwhelms supply.

Real-world analogy: A landlord lowers the rent briefly to scare existing tenants into leaving, then immediately fills the building with better tenants at higher rent. The price drop was not weakness — it was a deliberate trap to reload.

NO DEMAND (ND) — worth negative 2 points
Full definition: An up bar (close above open) with low volume, narrow spread, and close near the low, AND a Buying Climax (BC) or End of Rising Market (EoR) must have occurred within the last 5 bars.

What it means: The stock ticked up, but nobody was buying. Volume was thin, the move was tiny, and the close fell to the bottom of the bar. Buyers are absent.

IMPORTANT: No Demand requires a CONTEXT GATE. It only fires when a prior sign of weakness (Buying Climax or End of Rising) has already appeared in the recent past. This prevents false signals during healthy uptrends where low-volume up-bars are normal and benign. No Demand without prior weakness is just a quiet day — not a warning.

The context gate labels on the scorecard:
"BC armed" = a Buying Climax was detected within the lookback window
"EoR armed" = an End of Rising Market was detected
"no gate" = neither was detected, so No Demand cannot fire

UPTHRUST (UT) — worth negative 3 points (highest bearish penalty)
Full definition: The high breaches the local resistance level (the highest high of the last 10 bars), but the close falls back below resistance, with wide spread and close near the low.

What it means: Smart money engineered a false breakout to trap buyers. The stock surged above resistance (triggering buy orders from breakout traders), then immediately reversed and closed weak. The institutions sold into all the buying that the breakout generated.

This is the mirror image of the Shakeout — and equally powerful in the opposite direction. When an Upthrust appears on the same bar as a breakout signal from the Momentum Masters Screener, it is the loudest possible warning: that breakout is a trap.

================================================================
MAJOR VSA SIGNS OF STRENGTH AND WEAKNESS
================================================================

Beyond the four Module 9 patterns, the indicator detects ten additional Volume Spread Analysis patterns and marks them with labels in the chart panel. These are the "major signs" that Tom Williams catalogued:

SIGNS OF STRENGTH (bullish — labeled at the bottom of the panel)

SC — SELLING CLIMAX
A down bar on above-average volume with a wide spread that closes in the UPPER half of its total range. Panic selling has been absorbed by strong hands. The sellers have exhausted themselves. Often marks the end of a decline and the beginning of accumulation.

SV — STOPPING VOLUME
Three consecutive down bars where the spreads DECREASE progressively (each bar's range is smaller than the last) while volume INCREASES progressively (each bar is busier than the last). The final bar closes in the upper portion of its range. This is classic Wyckoff absorption: selling effort is rising but the result (price movement) is shrinking. Smart money is absorbing every sell order.

BR — BOTTOM REVERSAL
A down bar on above-average volume closing in the upper 60% of its total range. Sellers pushed price down but buyers fought back and closed strong. Less dramatic than a Selling Climax but still a sign of strength.

BH — BAG HOLDING
An up bar on high volume that follows a prior flush bar (a down bar on heavy volume that closed strong). The combination means: sellers tried to dump (the flush), but someone caught all the shares (closed strong), and then buying continued the next day. The "bag holder" is the institution that deliberately caught the falling shares because they wanted them.

SA — SUPPLY ABSORPTION
An up bar on high volume but with a narrow spread relative to the average. Huge volume with a small move means supply (selling) is being absorbed at this price level. Buyers are meeting every sell order without letting the price move much. This is the institutional equivalent of building a wall.

SIGNS OF WEAKNESS (bearish — labeled at the top of the panel)

BC — BUYING CLIMAX
An up bar on above-average volume with a wide spread that closes in the LOWER half of its total range. Euphoric buying has been met by smart money distribution. The stock rallied but closed weak. Often marks the end of a rally and the beginning of distribution. On a gap-up earnings day that fades into the close, this is especially significant.

EoR — END OF RISING MARKET
An up bar on high volume where the spread is contracting compared to the prior bar and the close is in the lower half. Buying is still happening but weakening — each push higher produces less progress. The rally is running out of steam.

TR — TOP REVERSAL
An up bar on above-average volume closing in the lower 40% of its total range. Buyers tried to push higher but sellers overwhelmed them by the close. Less dramatic than a Buying Climax but still a warning.

SoD — SUPPLY OVER DEMAND
A down bar on higher volume than the prior up bar, closing in the lower 40% of its range. Sellers showed up with more force than the prior day's buyers. The balance has shifted from demand to supply.

DA — DEMAND ABSORPTION
A down bar on high volume but with a narrow spread. Huge selling volume but price barely moved — demand (buying) is absorbing the selling pressure at this level. Mirror image of Supply Absorption, but bearish: it means someone is defending a price level on the way down, often to distribute at a controlled price.

================================================================
THE VSA RECENCY COLUMN (Column 3)
================================================================

This column answers the question: "When did each signal last fire?"

Instead of showing "active" only on the rare day a signal fires, every row shows the bars-ago count for each signal, so the column is ALWAYS informative.

HOW TO READ THE RECENCY:

NOW = the signal is firing on today's bar (bright color)
1d ago to 2d ago = fired very recently (bright color)
3d ago to 5d ago = fired within the last week (moderate color)
6d ago to 10d ago = fading relevance (orange)
11d ago or more = stale, not part of the current picture (gray)
--- = signal has never fired on this chart

ROW-BY-ROW GUIDE:

Best Strength: Automatically identifies the MOST RECENT bullish signal (whichever one fired most recently out of SC, SV, BR, BH, SA, NS, SHK) and shows its name and bars-ago. This is the single most useful row — one glance tells you the freshest bullish evidence.

Best Weakness: Same logic for bearish signals (BC, EoR, TR, SoD, DA, UT, ND). Shows the freshest bearish evidence.

SC | SV: Selling Climax and Stopping Volume recency. These are the two most powerful strength signals.

BR | BH | SA: Bottom Reversal, Bag Holding, and Supply Absorption recency. Supporting strength signals.

NS | SHK: No Supply and Shakeout recency. These are Module 9's bullish patterns.

BC | EoR: Buying Climax and End of Rising recency. The two most powerful weakness signals.

TR | SoD | DA: Top Reversal, Supply over Demand, and Demand Absorption recency. Supporting weakness signals.

UT | ND: Upthrust and No Demand recency. Module 9's bearish patterns.

HB | HS: Hidden Buy and Hidden Sell recency from Module 8.

VSA BIAS: A summary verdict. If the most recent strength signal is within 5 bars and no weakness signal is that recent, it shows "BULL BIAS" in green. If weakness is more recent, "BEAR BIAS" in red. If both are recent, "CONTESTED" in orange. If neither is recent, "NEUTRAL" in gray.

================================================================
THE GRADING SYSTEM
================================================================

All nine modules combine into a composite score out of 28 maximum points. The percentage determines the verdict:

70% or higher (20+ points) = ACCUMULATION
The breakout is backed by genuine institutional buying. Multiple modules confirm: effort matched result, close was strong, volume was decisive, CVD confirms, no hidden selling, and VSA patterns are bullish. Highest conviction. Execute the trade.

50% to 69% (14-19 points) = LIKELY ACCUMULATION
Most modules pass with one or two minor gaps. Acceptable to enter, but consider a tighter stop-loss or a half position initially.

35% to 49% (10-13 points) = UNCERTAIN
Mixed signals. Some modules bullish, others bearish. The breakout could go either way. Do not enter immediately. Wait 1-3 days and watch the follow-through.

Below 35% (under 10 points) = EXHAUSTION
Multiple modules are failing. The volume story contradicts the price story. Smart money is likely distributing into this breakout. Do not buy. Walk away regardless of what the price chart looks like.

This grading applies to the daily composite score above. Version 3.2 adds a separate, smaller composite for the higher-timeframe read — see "THE HTF CONTEXT TABLE" below.

================================================================
FOLLOW-THROUGH TRACKING
================================================================

After a breakout, smaller colored columns appear for the next 3 trading days, checking three things each day:

1. Is price still holding above the breakout level?
2. Is volume still at least 80% of average (sustained demand)?
3. Is the close still in the upper half of the daily range?

Each check scores 1 point (maximum 3 per day). The column colors:
Green = 2 or 3 out of 3 (healthy follow-through)
Orange = 1 out of 3 (weakening)
Red = 0 out of 3 (breakout failing)

Genuine accumulation breakouts hold and build over the first 3 days. Exhaustion breakouts typically fail within this window.

================================================================
THE HTF CONTEXT TABLE (NEW IN VERSION 3.2)
================================================================

Everything described so far — all nine modules, the three-column dashboard, the VSA Recency column — runs on the chart's own timeframe. If you are looking at a daily chart, every calculation above is measuring what happened on individual DAYS.

Version 3.2 adds a separate table, in its own corner of the panel, that asks a different question: "Does the stock's bigger-picture story agree?"

This table re-runs four of the nine modules — Effort vs Result, Close Position, Volume Character Change, and the Tom Williams VSA Engine — but measures them on a HIGHER TIMEFRAME instead of the chart's own bars. By default this is the WEEKLY timeframe, so on a daily chart it is asking: "Over the last several weeks, does this stock's volume and price behavior, measured week by week, still look like accumulation?"

WHY ONLY FOUR OF THE NINE MODULES:
Modules 3 (Pre-Breakout Absorption), 7 (CVD Divergence), and 8 (Hidden Signal) were left out of this HTF check to keep it fast and focused. The four modules that ARE included — Effort vs Result, Close Position, Volume Character, and the Tom Williams VSA patterns (No Supply, Shakeout, No Demand, Upthrust) — are the ones that read the CHARACTER of a single bar most directly, which is exactly what you want when compressing weeks of trading into individual weekly bars.

ROWS IN THE HTF CONTEXT TABLE:

Verdict: The higher-timeframe's own ACCUMULATION / LIKELY ACCUM / UNCERTAIN / EXHAUSTION read, using the same four labels and color scheme as the main scorecard, but computed from a separate, smaller composite (see SCORE BREAKDOWN REFERENCE below).

Composite: The point total behind that verdict, shown as X/14 and as a percentage, using the same 70% / 50% / 35% grading breakpoints as the main daily score.

TW VSA Net: The higher timeframe's own Tom Williams VSA Engine score (-5 to +5), exactly like the main scorecard's row of the same name, but measuring weekly bars instead of daily ones.

Best Strength / Best Weakness: The most recent higher-timeframe No Supply or Shakeout (strength), and the most recent higher-timeframe Upthrust or No Demand (weakness), shown as "bars ago." Here, "bars" means weekly bars (or whatever higher timeframe you have selected), not days.

HTF Breakout: How many higher-timeframe bars ago this same engine's own breakout test last fired, using the same breakout logic as Module 1's pivot/volume test, just measured on the higher timeframe.

Alignment: The single most useful row. It compares your LAST DAILY BREAKOUT's verdict (from the main scorecard's LAST BREAKOUT column) against the higher-timeframe verdict above, and shows one of:

CONFIRMS (green) — the daily breakout was accumulation or likely accumulation, AND the higher timeframe also reads accumulation or likely accumulation. The two timeframes agree.

CONFLICTS! (red) — the daily breakout looked like accumulation, but the higher-timeframe tape reads exhaustion. This is a warning that the bigger picture disagrees with the day you are looking at.

CONFIRMS (avoid) (red) — the daily breakout itself already read as exhaustion, and the higher timeframe agrees it is weak. Two independent confirmations that this is not a trade.

NEUTRAL (gray) — the two readings do not clearly agree or disagree (for example, the higher timeframe is UNCERTAIN).

OFF (gray) — HTF Confirmation is disabled in settings, or the Higher Timeframe input is not actually higher than your chart's own timeframe.

ON THE CHART: when a daily breakout fires and the alignment is CONFIRMS or CONFLICTS, a small "HTF: OK" or "HTF: NO" tag appears just above the usual ACCUM/EXHAUST verdict label, so you do not need to look at the table to catch a conflict at a glance.

================================================================
WHY HIGHER-TIMEFRAME CONFIRMATION WAS ADDED
================================================================

A single daily bar is a small sample. Modules 1, 2, 4, 5, 6, and 9 all measure the character of ONE bar (today's), and Module 3 only looks back 20 bars. That is enough to judge whether TODAY looks like genuine accumulation — but it says nothing about whether the stock's bigger, slower-moving story agrees. Institutions build positions over weeks and months. A single strong daily bar can be a real breakout, or it can be one good day inside a stock that has been quietly weakening for a month. The daily modules alone cannot always tell the difference.

Checking the weekly (or other higher) timeframe independently answers a genuinely different question than anything the nine daily modules ask. It is not a repeat of Module 3's absorption check — that still only looks at daily bars. It is asking whether the stock's own volume and spread character, measured in WEEKLY chunks, still tells the same story the daily breakout is telling you.

THE ENGINEERING PROBLEM THIS CREATED:

Pulling a higher timeframe's reading onto a lower-timeframe chart has a well-known trap of its own — one that has nothing to do with the market and everything to do with how charting software updates in real time.

A still-forming weekly bar changes every single day until the week actually closes on Friday. If the indicator simply showed you "whatever the weekly bar currently looks like," that reading would REPAINT (see KEY VOCABULARY): it might show "Accumulation" on Tuesday, and by Friday's close, after two down days you did not see coming, it could have quietly become "Exhaustion" instead. Anyone who acted on Tuesday's "confirmation" would have traded on a reading that was never actually true — the exact same kind of trap this whole indicator is built to help you spot in the market itself, except this time the trap would be inside the tool.

To prevent that, the HTF engine is built as what is sometimes called a "stable snapshot": it always looks at the LAST FULLY CLOSED higher-timeframe bar, and never the bar that is still forming. Practically, that means the HTF Context Table updates once per week (or once per whatever higher timeframe you choose) — not every day — and every reading it shows you, once shown, will never change. The tradeoff is a small amount of lag: on a Monday, the table is still describing last week, not this one. That tradeoff is deliberate. A slightly delayed reading you can trust is worth more than an up-to-the-minute one that might reverse on you.

WHY THE HTF TOM WILLIAMS ENGINE IS GAP-AWARE:

The chart-timeframe VSA signals in this indicator (the SC, SV, BC, EoR, and related labels) were already rebuilt to be "gap-aware" after real testing on SNOW showed that an earnings gap-up bar could fail to trigger signals under the plain high-minus-low spread math — a big overnight jump was not being counted as part of that bar's true range. The HTF engine's Tom Williams module (No Supply, Shakeout, No Demand, Upthrust) uses that same gap-aware math from the start, because a weekly bar is, if anything, MORE likely than a daily bar to have an earnings report or other gap-causing event happen somewhere inside it.

================================================================
CHART LABELS AND BACKGROUND SHADING
================================================================

The indicator places two types of markers directly on the chart panel:

LABELS: Two-letter abbreviations appear at the top (weakness) or bottom (strength) of the panel whenever a VSA signal fires. Major signals (SC, BC, SHK, UT) use larger labels. Minor signals (NS, ND, BR, TR) use smaller labels. Version 3.2 adds one more: a small "HTF: OK" or "HTF: NO" tag above the verdict label on breakout bars, described in THE HTF CONTEXT TABLE section above.

BACKGROUND SHADING:
Green tint = Shakeout or No Supply is active (bullish)
Red tint = Upthrust or No Demand is active (bearish)

Both can be toggled on/off in settings.

================================================================
HOW TO USE THIS WITH YOUR OTHER INDICATORS
================================================================

This indicator is Panel 2 in your three-panel analysis stack:

PANEL 1 (Price Chart): Momentum Masters Synergy Screener
Identifies Grade A/B stocks, fires entry signals (green triangle for breakout, blue circle for pullback, orange diamond for VCP resolution), plots stop-loss and target levels.

PANEL 2 (Lower): This indicator — Breakout Quality Analyzer v3.2
Scores each breakout as Accumulation or Exhaustion using 9 modules, shows the live tape reader, tracks VSA signal recency, and now checks whether the higher timeframe agrees.

PANEL 3 (Lower): CVD Divergence + Heikin-Ashi
Shows the continuous volume flow trend using detrended CVD with Heikin-Ashi smoothing, fast/slow EMA crossovers, and multi-bar divergence detection.

THE CONFIRMATION SEQUENCE:

Step 1: Momentum Masters fires a green triangle entry signal.

Step 2: Look at this indicator's LAST BREAKOUT column. Is the composite score 70%+? Is the verdict ACCUMULATION?

Step 3: Check the VSA RECENCY column. Is the Best Strength signal recent (within 5 bars) and Best Weakness old (10+ bars or never)? Does VSA BIAS show BULL BIAS?

Step 4 (NEW in v3.2): Check the HTF CONTEXT TABLE. Does Alignment show CONFIRMS? If it shows CONFLICTS, the daily breakout and the bigger-picture weekly tape disagree — treat the daily read as unconfirmed.

Step 5: Check the CVD panel (Panel 3). Are the Heikin-Ashi candles green? Is CVD above both EMAs? No bearish divergence?

Step 6: If all panels confirm, execute the trade with full position size. Set stop at the level shown by the Momentum Masters indicator. After 3 days of confirmed follow-through, begin selling covered calls for income.

WHEN TO BE CAUTIOUS:

- Composite score is 50-69% (Likely Accumulation): Enter with a half position. Add to full only if follow-through is green for 3 days.

- VSA BIAS shows CONTESTED: Strength and weakness signals are both recent. The market is undecided. Wait for one side to dominate.

- Hidden Sell (HS) appears on the breakout bar: Even if the composite score passes, institutions may be distributing. Consider waiting one day for confirmation.

- Upthrust (UT) fires on the breakout bar: The breakout is very likely a trap. Do not enter regardless of the composite score.

- HTF Alignment shows CONFLICTS (NEW in v3.2): the daily bar looks like accumulation, but the higher timeframe's own tape reading disagrees. Treat the daily read as unconfirmed — wait for the next higher-timeframe bar to close, or take a reduced position.

WHEN TO EXIT AN EXISTING POSITION:

- Buying Climax (BC) appears: Major distribution signal. Tighten your stop immediately.

- End of Rising (EoR) appears followed by No Demand (ND): Classic Wyckoff distribution sequence. Consider exiting.

- VSA BIAS shifts from BULL to BEAR: The weight of recent evidence has flipped against you.

- Follow-through drops to 0/3 within 3 days of entry: The breakout has failed. Exit at your stop.

================================================================
SETTINGS REFERENCE
================================================================

1. BREAKOUT DETECTION
- Pivot Lookback (default 20): How many bars back to find the breakout level
- Min Breakout Volume (default 1.3x): Minimum volume multiplier to qualify as a breakout

2. VSA SETTINGS
- Volume Average Length (default 50): Baseline for "average" volume
- Pre-Breakout Absorption Window (default 20): Days before breakout to check for accumulation

3. CVD DIVERGENCE
- CVD Slope Lookback (default 3): Bars to compare CVD direction vs price direction

4. HIDDEN SIGNAL
- Hidden Buy Threshold (default 0.55): Min DV Ratio on a red bar to flag as hidden buying
- Hidden Sell Threshold (default 0.45): Max DV Ratio on a green bar to flag as hidden selling
- Tighter thresholds = fewer but higher-conviction signals

5. FOLLOW-THROUGH
- Days to Track (default 3): How many days after breakout to monitor

6. TOM WILLIAMS VSA ENGINE
- Low Volume Threshold (default 0.7x): Below this = "low volume" for No Supply / No Demand
- High Volume Threshold (default 1.5x): Above this = "high volume" for Shakeout
- Narrow Spread Threshold (default 0.5x ATR): Below this = "narrow spread"
- Wide Spread Threshold (default 1.2x ATR): Above this = "wide spread"
- Close-High Threshold (default 0.6): Close position above this = "near the high"
- Close-Low Threshold (default 0.4): Close position below this = "near the low"
- Support/Resistance Lookback (default 10): Bars used to find local support and resistance
- Prior Weakness Lookback (default 5): Bars to scan for Buying Climax or End of Rising (No Demand gate)
- Show VSA Labels: Toggle the two-letter signal labels on/off
- Show VSA Background Shading: Toggle the green/red background tints on/off

7. DISPLAY
- Show Breakout Scorecard: Toggle the entire table on/off
- Show Verdict Labels on Chart: Toggle the ACCUM/EXHAUST labels on breakout bars

8. HIGHER TIMEFRAME CONTEXT (MTF) — NEW IN v3.2
- Enable HTF Confirmation (default ON): Turns the separate HTF Context Table and its checks on or off
- Higher Timeframe (default Weekly): Must be a timeframe higher than your chart's own. If it is not, the table shows "INVALID TF" and falls back to a harmless no-op reading rather than erroring
- HTF Pivot Lookback (default 20): The higher-timeframe equivalent of the main Pivot Lookback setting
- HTF Min Breakout Volume (default 1.3x): The higher-timeframe equivalent of the main breakout volume filter
- Show HTF Context Table: Toggle the entire HTF table on or off

================================================================
ALERTS
================================================================

Thirteen pre-built alert conditions:

Breakout Alerts:
- Accumulation Breakout: Composite score 70%+ (green light)
- HTF-Confirmed Accumulation Breakout (NEW in v3.2): Composite score 70%+ AND the higher timeframe also reads Accumulation or Likely Accumulation — the highest-conviction alert this indicator can fire
- Exhaustion Breakout: Composite score below 35% (trap warning)
- Hidden Sell on Breakout: DV Ratio below threshold on breakout day
- CVD Divergence on Breakout: CVD falling while price rising on breakout
- Upthrust on Breakout Bar: Breakout + immediate close below resistance (highest danger)

Follow-Through Alert:
- Weak Follow-Through: Score drops below 2/3 in days after breakout

Continuous VSA Alerts (fire on any bar, not just breakouts):
- Hidden Buy Detected: Stealth institutional buying
- Hidden Sell Detected: Stealth institutional selling
- Shakeout Detected: Smart money cleared weak holders (bullish trap)
- No Supply Detected: Sellers absent on pullback (healthy uptrend)
- Upthrust Detected: Smart money trapped breakout buyers (bearish trap)
- No Demand Detected: Buyers absent on rally after prior weakness

================================================================
SCORE BREAKDOWN REFERENCE
================================================================

Module 1 — Effort vs Result:           0 to 3 points
Module 2 — Close Position:             0 to 3 points
Module 3 — Pre-Breakout Absorption:    0 to 3 points
Module 4 — Volume Character Change:    0 to 3 points
Module 5 — Volume Rank:                0 to 2 points
Module 6 — Spread Quality:             0 to 2 points
Module 7 — CVD Divergence:             0 to 3 points
Module 8 — Hidden Signal (DV Flow):    0 to 3 points
Module 9 — Tom Williams VSA Engine:    -5 to +5 points
MAXIMUM:                               28 points

Grading: 70%+ = Accumulation | 50-69% = Likely Accumulation | 35-49% = Uncertain | Below 35% = Exhaustion

NOTE ON THE HTF COMPOSITE (NEW IN v3.2): The HTF Context Table runs a separate, smaller composite of its own, and is NOT part of the 28-point score above:

Module 1 — Effort vs Result:           0 to 3 points
Module 2 — Close Position:             0 to 3 points
Module 4 — Volume Character Change:    0 to 3 points
Module 9 — Tom Williams VSA Engine:    0 to 5 points toward this composite (only the positive portion counts here; the TW VSA Net row it shows can still read as low as -5)
MAXIMUM:                               14 points

Same grading breakpoints apply: 70%+ = Accumulation | 50-69% = Likely Accumulation | 35-49% = Uncertain | Below 35% = Exhaustion.

================================================================
THE ONE IDEA THAT TIES EVERYTHING TOGETHER
================================================================

Every one of the nine modules, all fourteen VSA signals, and the entire three-column dashboard are asking variations of the same question:

"Does the volume confirm what the price is doing?"

When price goes up and volume confirms it — strong close position, rising CVD, high DV ratio, no signs of weakness — the move is real. When price goes up but volume tells a different story — weak close, diverging CVD, hidden selling, Buying Climax patterns — someone is lying, and it is always the price.

Volume cannot be faked at scale. Every share bought requires a share sold. The cumulative record of who initiated those transactions — and where within each bar's range the battle was resolved — is the closest thing to a truth detector that the stock market has.

This indicator puts that truth detector on your chart, reads it for you in real time, and gives you a single number that says: trust this breakout, or walk away. Version 3.2 simply asks that same question twice — once on the day in front of you, and once on the bigger-picture bar it sits inside of.

================================================================
CREDITS
================================================================

Built on the volume-price analysis framework of Richard D. Wyckoff (1873-1934), refined by Tom Williams (Volume Spread Analysis, "Master the Markets"), CVD concepts from modern institutional order flow analysis, and DV flow analysis adapted from the BTC Delta MTF indicator. Designed as the central analysis companion to the Momentum Masters Synergy Screener. The higher-timeframe confirmation layer (v3.2) uses a standard non-repainting request.security pattern common among Pine Script developers for reliable multi-timeframe indicators.

===========
DISCLAIMER
===========

This is an educational tool and does not constitute financial advice. Trading stocks and options involves substantial risk of loss. Past performance is not indicative of future results. The indicator identifies historical patterns that may not repeat. Always consult a licensed financial advisor before making investment decisions.

---

## Source Code

````pine
//@version=6
indicator("Breakout Quality Analyzer (Wyckoff VSA)", shorttitle="BQ_Wyckoff_v3.2", overlay=false)

// BREAKOUT QUALITY ANALYZER v3.2
// v3.1: VSA column rebuilt with bars-ago recency tracking
// v3.2: Added HIGHER-TIMEFRAME (HTF) confirmation using the MTF
//       stable-snapshot technique (non-repainting request.security
//       wrapper: force _commit=true inside a *_HTF() function, offset
//       every returned field by [1], call via lookahead_on). All
//       original v3.1 logic below is unchanged. New material is in
//       section "8. HIGHER TIMEFRAME CONTEXT" and everything tagged
//       "NEW in v3.2" below.

// INPUTS
grp_bo = "1. BREAKOUT DETECTION"
bo_lookback = input.int(20, "Pivot Lookback", group=grp_bo, minval=5, maxval=50)
bo_vol_mult = input.float(1.3, "Min Breakout Volume (x avg)", group=grp_bo, minval=1.0, maxval=5.0, step=0.1)

grp_vsa = "2. VSA SETTINGS"
vol_avg_len = input.int(50, "Volume Average Length", group=grp_vsa, minval=10, maxval=200)
absorption_len = input.int(20, "Pre-Breakout Absorption Window", group=grp_vsa, minval=5, maxval=50)

grp_cvd = "3. CVD DIVERGENCE"
cvd_lookback = input.int(3, "CVD Slope Lookback (bars)", group=grp_cvd, minval=2, maxval=10)

grp_hidden = "4. HIDDEN SIGNAL"
hidden_buy_thresh = input.float(0.55, "Hidden Buy: Min DV Ratio on red bar", group=grp_hidden, minval=0.51, maxval=0.75, step=0.01)
hidden_sell_thresh = input.float(0.45, "Hidden Sell: Max DV Ratio on green bar", group=grp_hidden, minval=0.25, maxval=0.49, step=0.01)

grp_follow = "5. FOLLOW-THROUGH"
ft_days = input.int(3, "Follow-Through Days to Track", group=grp_follow, minval=1, maxval=10)

grp_tw = "6. TOM WILLIAMS VSA ENGINE"
tw_vol_low_mult = input.float(0.7, "Low Volume Threshold (x avg)", group=grp_tw, minval=0.3, maxval=0.95, step=0.05)
tw_vol_high_mult = input.float(1.5, "High Volume Threshold (x avg)", group=grp_tw, minval=1.1, maxval=3.0, step=0.1)
tw_spread_narrow = input.float(0.5, "Narrow Spread Threshold (ATR mult)", group=grp_tw, minval=0.2, maxval=1.0, step=0.05)
tw_spread_wide = input.float(1.2, "Wide Spread Threshold (ATR mult)", group=grp_tw, minval=0.8, maxval=3.0, step=0.1)
tw_close_high = input.float(0.6, "Close-High Threshold (pct of range)", group=grp_tw, minval=0.5, maxval=0.9, step=0.05)
tw_close_low = input.float(0.4, "Close-Low Threshold (pct of range)", group=grp_tw, minval=0.1, maxval=0.5, step=0.05)
tw_support_lb = input.int(10, "Support/Resistance Lookback", group=grp_tw, minval=5, maxval=30)
tw_weakness_lb = input.int(5, "Prior Weakness Lookback (No Demand gate)", group=grp_tw, minval=2, maxval=15)
show_vsa_labels = input.bool(true, "Show VSA Labels on Chart", group=grp_tw)
show_vsa_bg = input.bool(true, "Show VSA Background Shading", group=grp_tw)

grp_disp = "7. DISPLAY"
show_bo_table = input.bool(true, "Show Breakout Scorecard", group=grp_disp)
show_labels = input.bool(true, "Show Verdict Labels on Chart", group=grp_disp)

// NEW in v3.2 -------------------------------------------------------
grp_htf = "8. HIGHER TIMEFRAME CONTEXT (MTF)"
htf_enable = input.bool(true, "Enable HTF Confirmation", group=grp_htf)
htf_tf = input.timeframe("W", "Higher Timeframe", group=grp_htf, tooltip="Must be strictly higher than the chart timeframe. Uses a non-repainting stable snapshot: reads only the last CLOSED higher-timeframe bar, never the still-forming one.")
htf_bo_lookback = input.int(20, "HTF Pivot Lookback", group=grp_htf, minval=5, maxval=50)
htf_vol_mult = input.float(1.3, "HTF Min Breakout Volume (x avg)", group=grp_htf, minval=1.0, maxval=5.0, step=0.1)
show_htf_table = input.bool(true, "Show HTF Context Table", group=grp_htf)
// ---------------------------------------------------------------------

// CORE CALCULATIONS
vol_avg = ta.sma(volume, vol_avg_len)
spread = high - low
avg_spread = ta.sma(spread, vol_avg_len)
pivot_high = ta.highest(high, bo_lookback)[1]
is_breakout = (close > pivot_high) and (close[1] <= pivot_high)
bo_volume_ok = volume > (vol_avg * bo_vol_mult)
breakout_bar = is_breakout and bo_volume_ok

// MODULE 1: EFFORT vs RESULT
effort = volume / vol_avg
result = spread / avg_spread
evr_ratio = effort > 0 ? (result / effort) : 0.0
evr_score = evr_ratio > 1.2 ? 3 : (evr_ratio > 0.9 ? 2 : (evr_ratio > 0.6 ? 1 : 0))

// MODULE 2: CLOSE POSITION
close_pct = spread > 0 ? ((close - low) / spread) : 0.5
close_score = close_pct > 0.75 ? 3 : (close_pct > 0.60 ? 2 : (close_pct > 0.40 ? 1 : 0))

// MODULE 3: PRE-BREAKOUT ABSORPTION
avg_vol_pre = ta.sma(volume, absorption_len)[1]
vol_ratio_pre = vol_avg > 0 ? (avg_vol_pre / vol_avg) : 1.0
vol_dryup_before = vol_ratio_pre < 0.85
avg_spread_pre = ta.sma(spread, absorption_len)[1]
spread_ratio_pre = avg_spread > 0 ? (avg_spread_pre / avg_spread) : 1.0
range_contracted = spread_ratio_pre < 0.85
accum_day = (close > close[1]) and (volume > vol_avg) ? 1.0 : 0.0
distrib_day = (close < close[1]) and (volume > vol_avg) ? 1.0 : 0.0
pre_accum = ta.sma(accum_day, absorption_len) * absorption_len
pre_distrib = ta.sma(distrib_day, absorption_len) * absorption_len
pre_ad_ratio = pre_distrib > 0 ? (pre_accum / pre_distrib) : 2.0
pre_ad_healthy = pre_ad_ratio > 1.0
abs_s1 = vol_dryup_before ? 1 : 0
abs_s2 = range_contracted ? 1 : 0
abs_s3 = pre_ad_healthy ? 1 : 0
absorption_score = abs_s1 + abs_s2 + abs_s3

// MODULE 4: VOLUME CHARACTER CHANGE
vol_surge_magnitude = avg_vol_pre > 0 ? (volume / avg_vol_pre) : 1.0
vol_char_score = vol_surge_magnitude > 2.5 ? 3 : (vol_surge_magnitude > 1.8 ? 2 : (vol_surge_magnitude > 1.3 ? 1 : 0))

// MODULE 5: VOLUME RANK
highest_vol_20 = ta.highest(volume, bo_lookback)
vol_is_highest = volume >= highest_vol_20
highest_vol_10_prev = ta.highest(volume, 10)[1]
vol_rank_score = vol_is_highest ? 2 : (volume > highest_vol_10_prev ? 1 : 0)

// MODULE 6: SPREAD QUALITY
spread_vs_avg = avg_spread > 0 ? (spread / avg_spread) : 1.0
spread_score = spread_vs_avg > 1.5 ? 2 : (spread_vs_avg > 1.0 ? 1 : 0)

// MODULE 7: CVD DIVERGENCE
bar_spread_cvd = high - low
bar_buy_vol = bar_spread_cvd > 0 ? (volume * (close - low) / bar_spread_cvd) : (volume * 0.5)
bar_sell_vol = bar_spread_cvd > 0 ? (volume * (high - close) / bar_spread_cvd) : (volume * 0.5)
bar_delta = bar_buy_vol - bar_sell_vol
cvd_raw = ta.cum(bar_delta)
cvd_change = cvd_raw - nz(cvd_raw[cvd_lookback], cvd_raw)
price_change = close - nz(close[cvd_lookback], close)
cvd_div_bull = (cvd_change > 0) and (price_change < 0)
cvd_div_bear = (cvd_change < 0) and (price_change > 0)
cvd_confirms = (cvd_change > 0) and (price_change > 0)
cvd_diverges = cvd_div_bear
cvd_score = cvd_confirms ? 2 : (cvd_diverges ? 0 : 1)
cvd_chg_pre = nz(cvd_raw[1]) - nz(cvd_raw[6], cvd_raw[1])
price_chg_pre = nz(close[1]) - nz(close[6], close[1])
cvd_stealth_accum = (cvd_chg_pre > 0) and (price_chg_pre <= 0)
cvd_bonus = cvd_stealth_accum ? 1 : 0
cvd_total_score = cvd_score + cvd_bonus

// MODULE 8: HIDDEN SIGNAL DV FLOW
dv_buy_vol = spread > 0 ? (volume * (close - low) / spread) : (volume * 0.5)
dv_sell_vol = spread > 0 ? (volume * (high - close) / spread) : (volume * 0.5)
dv_total = dv_buy_vol + dv_sell_vol
dv_ratio = dv_total > 0 ? (dv_buy_vol / dv_total) : 0.5
is_green_bar = close > open
is_red_bar = close < open
hidden_buy = (dv_ratio > hidden_buy_thresh) and is_red_bar
hidden_sell = (dv_ratio < hidden_sell_thresh) and is_green_bar
hidden_score = dv_ratio > 0.65 ? 3 : (dv_ratio > 0.55 ? 2 : (dv_ratio > 0.45 ? 1 : 0))
hb_1 = hidden_buy[1] == true ? 1.0 : 0.0
hb_2 = hidden_buy[2] == true ? 1.0 : 0.0
hb_3 = hidden_buy[3] == true ? 1.0 : 0.0
recent_hidden_buys = hb_1 + hb_2 + hb_3
hidden_base_accum = recent_hidden_buys >= 1

// MODULE 9: TOM WILLIAMS VSA ENGINE
atr_val = ta.atr(14)
tw_bar_spread = high - low
tw_spread_ratio = tw_bar_spread / (atr_val > 0.0 ? atr_val : 1.0)
tw_close_pos = tw_bar_spread > 0.0 ? (close - low) / tw_bar_spread : 0.5
tw_vol_ratio = volume / (vol_avg > 0.0 ? vol_avg : 1.0)
tw_bar_bull = close >= open
tw_bar_bear = close < open
tw_vol_is_low = tw_vol_ratio < tw_vol_low_mult
tw_vol_is_high = tw_vol_ratio > tw_vol_high_mult
tw_spread_is_narrow = tw_spread_ratio < tw_spread_narrow
tw_spread_is_wide = tw_spread_ratio > tw_spread_wide
tw_close_near_hi = tw_close_pos >= tw_close_high
tw_close_near_lo = tw_close_pos <= tw_close_low
local_support = ta.lowest(low, tw_support_lb)[1]
local_resistance = ta.highest(high, tw_support_lb)[1]

// Buying Climax detection for No Demand gate
var bool bc_detected = false
bc_detected := false
for w = 1 to tw_weakness_lb
    bc_bar_spread = high[w] - low[w]
    bc_close_pos = bc_bar_spread > 0.0 ? (close[w] - low[w]) / bc_bar_spread : 0.5
    bc_spread_rat = atr_val[w] > 0.0 ? bc_bar_spread / atr_val[w] : 0.0
    if close[w] > open[w] and volume[w] > vol_avg[w] * 2.0 and bc_spread_rat > 1.2 and bc_close_pos < 0.40
        bc_detected := true

// End of Rising detection for No Demand gate
var bool eor_detected = false
eor_detected := false
for w = 1 to tw_weakness_lb
    eor_bar_spread = high[w] - low[w]
    eor_prior_spread = high[w+1] - low[w+1]
    eor_close_pos = eor_bar_spread > 0.0 ? (close[w] - low[w]) / eor_bar_spread : 0.5
    if close[w] > open[w] and volume[w] > vol_avg[w] * 1.5 and eor_bar_spread < eor_prior_spread and eor_close_pos < 0.50
        eor_detected := true

prior_weakness = bc_detected or eor_detected

no_supply = tw_bar_bear and tw_vol_is_low and tw_spread_is_narrow and tw_close_near_hi
no_demand = tw_bar_bull and tw_vol_is_low and tw_spread_is_narrow and tw_close_near_lo and (bc_detected or eor_detected)
shakeout = low < local_support and close > local_support and tw_vol_is_high and tw_close_near_hi and tw_spread_is_wide
upthrust = high > local_resistance and close < local_resistance and tw_close_near_lo and tw_spread_is_wide

tw_score = 0
tw_score := tw_score + (no_supply ? 2 : 0)
tw_score := tw_score + (shakeout ? 3 : 0)
tw_score := tw_score - (no_demand ? 2 : 0)
tw_score := tw_score - (upthrust ? 3 : 0)
tw_score := math.max(tw_score, -5)

// GAP-AWARE VSA SIGNS OF STRENGTH AND WEAKNESS
vsa_gap_size = math.abs(open - close[1])
vsa_total_spread = tw_bar_spread + vsa_gap_size
vsa_spread_ratio = vsa_total_spread / (atr_val > 0.0 ? atr_val : 1.0)
vsa_total_hi = math.max(high, close[1])
vsa_total_lo = math.min(low, close[1])
vsa_total_rng = vsa_total_hi - vsa_total_lo
vsa_full_pos = vsa_total_rng > 0.0 ? (close - vsa_total_lo) / vsa_total_rng : tw_close_pos
vsa_spread_contracting = vsa_total_spread < (math.abs(close[1] - close[2]) + (high[1] - low[1]))

// Signs of Strength
vsa_sc = tw_bar_bear and tw_vol_ratio > 1.3 and vsa_spread_ratio > 0.9 and vsa_full_pos > 0.55
vsa_sv_bar1_spd = high[2] - low[2]
vsa_sv_bar2_spd = high[1] - low[1]
vsa_sv_bar3_spd = high - low
vsa_sv_spread_dec = vsa_sv_bar1_spd > vsa_sv_bar2_spd and vsa_sv_bar2_spd > vsa_sv_bar3_spd
vsa_sv_vol_inc = volume[2] < volume[1] and volume[1] < volume
vsa_sv_all_dn = close[2] < open[2] and close[1] < open[1] and tw_bar_bear
vsa_sv = vsa_sv_all_dn and vsa_sv_spread_dec and vsa_sv_vol_inc and vsa_full_pos > 0.40 and not vsa_sc
vsa_br = tw_bar_bear and tw_vol_ratio > 1.1 and vsa_full_pos > 0.60 and not vsa_sc and not vsa_sv
vsa_prior_flush = (close[1] < open[1]) and (volume[1] > vol_avg[1] * 1.3) and ((close[1] - low[1]) / math.max(high[1] - low[1], 0.001) > 0.40)
vsa_bh = tw_bar_bull and tw_vol_ratio > 1.2 and vsa_full_pos > 0.60 and vsa_prior_flush
vsa_sa = tw_bar_bull and tw_vol_ratio > 1.3 and vsa_spread_ratio < 1.1 and vsa_full_pos >= 0.30 and vsa_full_pos <= 0.80

// Signs of Weakness
vsa_bc = tw_bar_bull and tw_vol_ratio > 1.3 and vsa_spread_ratio > 0.9 and vsa_full_pos < 0.45
vsa_eor = tw_bar_bull and tw_vol_ratio > 1.3 and vsa_spread_contracting and vsa_full_pos < 0.50 and not vsa_bc
vsa_tr = tw_bar_bull and tw_vol_ratio > 1.1 and vsa_full_pos < 0.40 and not vsa_bc and not vsa_eor
vsa_sod = tw_bar_bear and volume > volume[1] * 1.1 and close[1] >= open[1] and vsa_full_pos < 0.40
vsa_da = tw_bar_bear and tw_vol_ratio > 1.3 and vsa_spread_ratio < 1.1 and vsa_full_pos >= 0.20 and vsa_full_pos <= 0.70

// ========================================
// BARS-AGO TRACKING (NEW in v3.1)
// Tracks recency of every VSA signal
// ========================================
var int ago_sc = 999
var int ago_sv = 999
var int ago_br = 999
var int ago_bh = 999
var int ago_sa = 999
var int ago_bc = 999
var int ago_eor = 999
var int ago_tr = 999
var int ago_sod = 999
var int ago_da = 999
var int ago_ns = 999
var int ago_shk = 999
var int ago_ut = 999
var int ago_nd = 999
var int ago_hb = 999
var int ago_hs = 999

ago_sc := vsa_sc ? 0 : ago_sc + 1
ago_sv := vsa_sv ? 0 : ago_sv + 1
ago_br := vsa_br ? 0 : ago_br + 1
ago_bh := vsa_bh ? 0 : ago_bh + 1
ago_sa := vsa_sa ? 0 : ago_sa + 1
ago_bc := vsa_bc ? 0 : ago_bc + 1
ago_eor := vsa_eor ? 0 : ago_eor + 1
ago_tr := vsa_tr ? 0 : ago_tr + 1
ago_sod := vsa_sod ? 0 : ago_sod + 1
ago_da := vsa_da ? 0 : ago_da + 1
ago_ns := no_supply ? 0 : ago_ns + 1
ago_shk := shakeout ? 0 : ago_shk + 1
ago_ut := upthrust ? 0 : ago_ut + 1
ago_nd := no_demand ? 0 : ago_nd + 1
ago_hb := hidden_buy ? 0 : ago_hb + 1
ago_hs := hidden_sell ? 0 : ago_hs + 1

// Best recent strength signal
best_sos_ago = math.min(ago_sc, math.min(ago_sv, math.min(ago_br, math.min(ago_bh, math.min(ago_sa, math.min(ago_ns, ago_shk))))))
best_sos_name = ago_sc == best_sos_ago ? "SC" : (ago_sv == best_sos_ago ? "SV" : (ago_shk == best_sos_ago ? "SHK" : (ago_br == best_sos_ago ? "BR" : (ago_bh == best_sos_ago ? "BH" : (ago_sa == best_sos_ago ? "SA" : (ago_ns == best_sos_ago ? "NS" : "---"))))))

// Best recent weakness signal
best_sow_ago = math.min(ago_bc, math.min(ago_eor, math.min(ago_tr, math.min(ago_sod, math.min(ago_da, math.min(ago_ut, ago_nd))))))
best_sow_name = ago_bc == best_sow_ago ? "BC" : (ago_eor == best_sow_ago ? "EoR" : (ago_ut == best_sow_ago ? "UT" : (ago_tr == best_sow_ago ? "TR" : (ago_sod == best_sow_ago ? "SoD" : (ago_da == best_sow_ago ? "DA" : (ago_nd == best_sow_ago ? "ND" : "---"))))))

// COMPOSITE SCORE (28 pts max)
raw_score = evr_score + close_score + absorption_score + vol_char_score + vol_rank_score + spread_score + cvd_total_score + hidden_score + tw_score
raw_score := math.max(raw_score, 0)
max_score = 28
bq_pct = raw_score * 100.0 / max_score
is_accumulation = bq_pct >= 70
is_likely_accum = (bq_pct >= 50) and (bq_pct < 70)
is_uncertain = (bq_pct >= 35) and (bq_pct < 50)
is_exhaustion = bq_pct < 35

// LATCHED SCORES (captured at breakout bar)
var float latch_bq_pct = 0.0
var int latch_raw_score = 0
var float latch_evr_ratio = 0.0
var int latch_evr_score = 0
var float latch_close_pct = 0.0
var int latch_close_score = 0
var int latch_absorption = 0
var float latch_vol_surge = 0.0
var int latch_vol_char = 0
var bool latch_vol_highest = false
var int latch_vol_rank = 0
var float latch_spread_vs_avg = 0.0
var int latch_spread_score = 0
var bool latch_cvd_confirms = false
var bool latch_cvd_diverges = false
var bool latch_cvd_stealth = false
var int latch_cvd_total = 0
var float latch_dv_ratio = 0.0
var int latch_hidden_score = 0
var bool latch_hidden_buy = false
var bool latch_hidden_sell = false
var int latch_tw_score = 0
var bool latch_no_supply = false
var bool latch_shakeout = false
var bool latch_no_demand = false
var bool latch_upthrust = false
var bool latch_bc = false
var bool latch_eor = false
var bool latch_is_accum = false
var bool latch_is_likely = false
var bool latch_is_uncertain = false
var bool latch_is_exhaust = false
var string latch_date = "No breakout yet"

if breakout_bar
    latch_bq_pct := bq_pct
    latch_raw_score := raw_score
    latch_evr_ratio := evr_ratio
    latch_evr_score := evr_score
    latch_close_pct := close_pct
    latch_close_score := close_score
    latch_absorption := absorption_score
    latch_vol_surge := vol_surge_magnitude
    latch_vol_char := vol_char_score
    latch_vol_highest := vol_is_highest
    latch_vol_rank := vol_rank_score
    latch_spread_vs_avg := spread_vs_avg
    latch_spread_score := spread_score
    latch_cvd_confirms := cvd_confirms
    latch_cvd_diverges := cvd_diverges
    latch_cvd_stealth := cvd_stealth_accum
    latch_cvd_total := cvd_total_score
    latch_dv_ratio := dv_ratio
    latch_hidden_score := hidden_score
    latch_hidden_buy := hidden_buy
    latch_hidden_sell := hidden_sell
    latch_tw_score := tw_score
    latch_no_supply := no_supply
    latch_shakeout := shakeout
    latch_no_demand := no_demand
    latch_upthrust := upthrust
    latch_bc := bc_detected
    latch_eor := eor_detected
    latch_is_accum := is_accumulation
    latch_is_likely := is_likely_accum
    latch_is_uncertain := is_uncertain
    latch_is_exhaust := is_exhaustion
    latch_date := str.format("{0,date,MMM dd yyyy}", time)

// FOLLOW-THROUGH
var int bars_since_bo = 100
bars_since_bo := breakout_bar ? 0 : (bars_since_bo + 1)
in_followthrough = (bars_since_bo <= ft_days) and (bars_since_bo > 0)
ft_holding = close > pivot_high
ft_vol_sustained = volume > (vol_avg * 0.8)
ft_close_strong = close_pct > 0.50
ft_s1 = ft_holding ? 1 : 0
ft_s2 = ft_vol_sustained ? 1 : 0
ft_s3 = ft_close_strong ? 1 : 0
ft_score = ft_s1 + ft_s2 + ft_s3

// =====================================================================
// NEW in v3.2 — HTF CONTEXT ENGINE (MTF stable-snapshot technique)
//
// A condensed, self-contained engine mirroring Modules 1, 2, 4 and 9
// of the chart-timeframe engine above. Module 9 here is built GAP-AWARE
// (matching the fix already applied to the vsa_* signals above, after
// SNOW's earnings gap-up bars failed to trigger signals) since HTF bars
// are, if anything, MORE likely than daily bars to span an earnings
// gap. The bc/eor lookback loop that gates No Demand is left
// non-gap-aware, matching the original tw_* implementation, to keep
// this addition narrowly scoped to the specific current-bar problem
// that was already documented and fixed elsewhere in this script.
// Modules 3 (CVD), 7 (absorption) and 8 (hidden signal) are
// intentionally left out of the HTF read to keep it fast and
// self-contained — extend f_bqEngineHTF_core below if you want fuller
// parity later.
//
// _commit exists purely so this function can be reused for the
// non-repainting HTF snapshot below: it is always called with
// _commit = true, and the wrapper's [1] offset (not _commit) is what
// actually prevents repainting.
// =====================================================================
f_bqEngineHTF_core(bool _commit) =>
    htf_vol_avg = ta.sma(volume, vol_avg_len)
    htf_spread = high - low
    htf_avg_spread = ta.sma(htf_spread, vol_avg_len)
    htf_pivot_high = ta.highest(high, htf_bo_lookback)[1]
    htf_is_breakout = (close > htf_pivot_high) and (close[1] <= htf_pivot_high)
    htf_bo_vol_ok = volume > (htf_vol_avg * htf_vol_mult)
    htf_breakout_bar = htf_is_breakout and htf_bo_vol_ok

    // Module 1: Effort vs Result
    htf_effort = volume / htf_vol_avg
    htf_result = htf_spread / htf_avg_spread
    htf_evr_ratio = htf_effort > 0 ? (htf_result / htf_effort) : 0.0
    htf_evr_score = htf_evr_ratio > 1.2 ? 3 : (htf_evr_ratio > 0.9 ? 2 : (htf_evr_ratio > 0.6 ? 1 : 0))

    // Module 2: Close Position (non-gap, matches original Module 2)
    htf_close_pct = htf_spread > 0 ? ((close - low) / htf_spread) : 0.5
    htf_close_score = htf_close_pct > 0.75 ? 3 : (htf_close_pct > 0.60 ? 2 : (htf_close_pct > 0.40 ? 1 : 0))

    // Module 4: Volume Character Change
    htf_avg_vol_pre = ta.sma(volume, absorption_len)[1]
    htf_vol_surge = htf_avg_vol_pre > 0 ? (volume / htf_avg_vol_pre) : 1.0
    htf_vc_score = htf_vol_surge > 2.5 ? 3 : (htf_vol_surge > 1.8 ? 2 : (htf_vol_surge > 1.3 ? 1 : 0))

    // Module 9: Tom Williams VSA Engine (gap-aware)
    htf_atr = ta.atr(14)
    htf_gap_size = math.abs(open - close[1])
    htf_total_spread = htf_spread + htf_gap_size
    htf_gap_spread_ratio = htf_total_spread / (htf_atr > 0.0 ? htf_atr : 1.0)
    htf_total_hi = math.max(high, close[1])
    htf_total_lo = math.min(low, close[1])
    htf_total_rng = htf_total_hi - htf_total_lo
    htf_gap_close_pos = htf_total_rng > 0.0 ? (close - htf_total_lo) / htf_total_rng : 0.5
    htf_vol_ratio = volume / (htf_vol_avg > 0.0 ? htf_vol_avg : 1.0)
    htf_bar_bull = close >= open
    htf_bar_bear = close < open
    htf_vol_is_low = htf_vol_ratio < tw_vol_low_mult
    htf_vol_is_high = htf_vol_ratio > tw_vol_high_mult
    htf_spread_is_narrow = htf_gap_spread_ratio < tw_spread_narrow
    htf_spread_is_wide = htf_gap_spread_ratio > tw_spread_wide
    htf_close_near_hi = htf_gap_close_pos >= tw_close_high
    htf_close_near_lo = htf_gap_close_pos <= tw_close_low
    htf_local_support = ta.lowest(low, tw_support_lb)[1]
    htf_local_resistance = ta.highest(high, tw_support_lb)[1]

    htf_bc_detected = false
    for w = 1 to tw_weakness_lb
        w_bar_spread = high[w] - low[w]
        w_close_pos = w_bar_spread > 0.0 ? (close[w] - low[w]) / w_bar_spread : 0.5
        w_spread_rat = htf_atr[w] > 0.0 ? w_bar_spread / htf_atr[w] : 0.0
        if close[w] > open[w] and volume[w] > htf_vol_avg[w] * 2.0 and w_spread_rat > 1.2 and w_close_pos < 0.40
            htf_bc_detected := true

    htf_eor_detected = false
    for w = 1 to tw_weakness_lb
        w_bar_spread2 = high[w] - low[w]
        w_prior_spread = high[w+1] - low[w+1]
        w_close_pos2 = w_bar_spread2 > 0.0 ? (close[w] - low[w]) / w_bar_spread2 : 0.5
        if close[w] > open[w] and volume[w] > htf_vol_avg[w] * 1.5 and w_bar_spread2 < w_prior_spread and w_close_pos2 < 0.50
            htf_eor_detected := true

    htf_no_supply = htf_bar_bear and htf_vol_is_low and htf_spread_is_narrow and htf_close_near_hi
    htf_no_demand = htf_bar_bull and htf_vol_is_low and htf_spread_is_narrow and htf_close_near_lo and (htf_bc_detected or htf_eor_detected)
    htf_shakeout = low < htf_local_support and close > htf_local_support and htf_vol_is_high and htf_close_near_hi and htf_spread_is_wide
    htf_upthrust = high > htf_local_resistance and close < htf_local_resistance and htf_close_near_lo and htf_spread_is_wide

    htf_tw_score = 0
    htf_tw_score := htf_tw_score + (htf_no_supply ? 2 : 0)
    htf_tw_score := htf_tw_score + (htf_shakeout ? 3 : 0)
    htf_tw_score := htf_tw_score - (htf_no_demand ? 2 : 0)
    htf_tw_score := htf_tw_score - (htf_upthrust ? 3 : 0)
    htf_tw_score := math.max(htf_tw_score, -5)

    // Composite (0-14): EVR(0-3) + Close(0-3) + VolChar(0-3) + max(TW,0)(0-5)
    htf_raw_score_pre = htf_evr_score + htf_close_score + htf_vc_score + math.max(htf_tw_score, 0)
    htf_raw_score = math.max(htf_raw_score_pre, 0)
    htf_max_score = 14
    htf_bq_pct = htf_raw_score * 100.0 / htf_max_score
    htf_is_accum = htf_bq_pct >= 70
    htf_is_likely = (htf_bq_pct >= 50) and (htf_bq_pct < 70)
    htf_is_uncertain = (htf_bq_pct >= 35) and (htf_bq_pct < 50)
    htf_verdict = htf_is_accum ? 1 : (htf_is_likely ? 2 : (htf_is_uncertain ? 3 : 4))

    // Persistent recency tracking - only advances when _commit
    var int htf_ago_shk = 999
    var int htf_ago_ns = 999
    var int htf_ago_ut = 999
    var int htf_ago_nd = 999
    var int htf_bars_since_bo = 999
    if _commit
        htf_ago_shk := htf_shakeout ? 0 : htf_ago_shk + 1
        htf_ago_ns := htf_no_supply ? 0 : htf_ago_ns + 1
        htf_ago_ut := htf_upthrust ? 0 : htf_ago_ut + 1
        htf_ago_nd := htf_no_demand ? 0 : htf_ago_nd + 1
        htf_bars_since_bo := htf_breakout_bar ? 0 : htf_bars_since_bo + 1

    [htf_breakout_bar, htf_evr_ratio, htf_evr_score, htf_close_pct, htf_close_score, htf_vc_score, htf_no_supply, htf_shakeout, htf_no_demand, htf_upthrust, htf_tw_score, htf_raw_score, htf_bq_pct, htf_verdict, htf_ago_shk, htf_ago_ns, htf_ago_ut, htf_ago_nd, htf_bars_since_bo]

// The MTF stable-snapshot wrapper itself: force _commit = true, then
// offset EVERY returned field by [1]. This is the entire trick.
f_bqEngineHTF() =>
    [bo, evrR, evrS, cp, cS, vcS, ns, shk, nd, ut, tw, rs, bqp, verdict, agoShk, agoNs, agoUt, agoNd, bsb] = f_bqEngineHTF_core(true)
    [bo[1], evrR[1], evrS[1], cp[1], cS[1], vcS[1], ns[1], shk[1], nd[1], ut[1], tw[1], rs[1], bqp[1], verdict[1], agoShk[1], agoNs[1], agoUt[1], agoNd[1], bsb[1]]

// Guard against an HTF input that isn't actually higher than the
// chart timeframe (request.security with tf <= chart tf is a
// different, unintended use). Falls back to the chart timeframe
// itself (a harmless no-op reading) rather than erroring, and the
// table below flags it clearly.
htf_seconds = timeframe.in_seconds(htf_tf)
chart_seconds = timeframe.in_seconds(timeframe.period)
htf_valid = htf_seconds > chart_seconds
htf_tf_safe = htf_valid ? htf_tf : timeframe.period

[htf_breakout_bar, htf_evr_ratio, htf_evr_score, htf_close_pct, htf_close_score, htf_vc_score, htf_no_supply, htf_shakeout, htf_no_demand, htf_upthrust, htf_tw_score, htf_raw_score, htf_bq_pct, htf_verdict, htf_ago_shk, htf_ago_ns, htf_ago_ut, htf_ago_nd, htf_bars_since_bo] = request.security(syminfo.tickerid, htf_tf_safe, f_bqEngineHTF(), lookahead = barmerge.lookahead_on)

// Alignment check: does the higher timeframe corroborate the LAST
// evaluated breakout's verdict? This is Panel-2-internal confluence,
// one level below the "all three panels must align" rule.
// 0 = HTF off/invalid, 1 = confirms bullish, 2 = conflicts,
// 3 = confirms bearish/avoid, 4 = neutral/mixed
htf_bull_read = htf_verdict == 1 or htf_verdict == 2
htf_bear_read = htf_verdict == 4
chart_bull_latch = latch_is_accum or latch_is_likely
chart_bear_latch = latch_is_exhaust
htf_alignment = (not htf_enable or not htf_valid) ? 0 : (chart_bull_latch and htf_bull_read) ? 1 : (chart_bull_latch and htf_bear_read) ? 2 : (chart_bear_latch and htf_bear_read) ? 3 : 4
// ================== END NEW v3.2 HTF ENGINE BLOCK ===================

// PLOTTING
bq_show = breakout_bar ? bq_pct : na
bq_color = is_accumulation ? color.new(#00E676, 0) : (is_likely_accum ? color.new(#2196F3, 0) : (is_uncertain ? color.new(#FF9800, 0) : color.new(#F44336, 0)))
plot(bq_show, "Breakout Quality %", color=bq_color, style=plot.style_columns, linewidth=4)
ft_show = in_followthrough ? ft_score * 20.0 : na
ft_color = ft_score >= 2 ? color.new(#00E676, 40) : (ft_score == 1 ? color.new(#FF9800, 40) : color.new(#F44336, 40))
plot(ft_show, "Follow-Through", color=ft_color, style=plot.style_columns, linewidth=2)
h75 = hline(75, "Accumulation Zone", color=color.new(#00E676, 70), linestyle=hline.style_dotted)
h50 = hline(50, "Neutral Zone", color=color.new(#FF9800, 70), linestyle=hline.style_dotted)
h35 = hline(35, "Exhaustion Zone", color=color.new(#F44336, 70), linestyle=hline.style_dotted)
hline(0, "", color=color.new(#333333, 80))
fill(h75, h50, color=color.new(#00E676, 93))
fill(h50, h35, color=color.new(#FF9800, 95))
evr_plot = evr_ratio * 25.0
plot(evr_plot, "Effort vs Result", color=color.new(#E040FB, 50), linewidth=1)
dv_plot = dv_ratio * 50.0
plot(dv_plot, "DV Ratio (x50)", color=color.new(#00BCD4, 60), linewidth=1)
cvd_norm = bar_spread_cvd > 0 ? ((close - low) / bar_spread_cvd - 0.5) * 50.0 : 0.0
plot(cvd_norm + 25.0, "CVD Bar Delta", color=color.new(#FFEB3B, 60), linewidth=1)

// VERDICT + VSA LABELS
if show_labels and breakout_bar
    v_str = is_accumulation ? "ACCUM" : (is_likely_accum ? "LIKELY" : (is_uncertain ? "UNSURE" : "EXHAUST"))
    v_clr = is_accumulation ? color.new(#00E676, 0) : (is_likely_accum ? color.new(#2196F3, 0) : (is_uncertain ? color.new(#FF9800, 0) : color.new(#F44336, 0)))
    label.new(bar_index, bq_pct + 8, v_str, color=v_clr, textcolor=color.white, style=label.style_label_down, size=size.small)
// NEW in v3.2: small HTF confirmation tag above the verdict label
if show_labels and breakout_bar and htf_enable and htf_valid and htf_alignment != 0
    htf_tag = htf_alignment == 1 ? "HTF: OK" : htf_alignment == 2 ? "HTF: NO" : htf_alignment == 3 ? "HTF: OK (avoid)" : ""
    if htf_tag != ""
        htf_tag_clr = htf_alignment == 1 ? color.new(#00E676, 0) : color.new(#F44336, 0)
        label.new(bar_index, bq_pct + 16, htf_tag, color=htf_tag_clr, textcolor=color.white, style=label.style_label_down, size=size.tiny)
if show_labels and hidden_buy
    label.new(bar_index, 10, "HB", color=color.new(#00E676, 30), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if show_labels and hidden_sell
    label.new(bar_index, 90, "HS", color=color.new(#F44336, 30), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if show_vsa_labels
    if vsa_sc
        label.new(bar_index, 8, "SC", color=color.new(#00E676, 0), textcolor=color.white, style=label.style_label_up, size=size.normal)
    if vsa_sv
        label.new(bar_index, 15, "SV", color=color.new(#00E676, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
    if vsa_br
        label.new(bar_index, 22, "BR", color=color.new(#00BCD4, 10), textcolor=color.white, style=label.style_label_up, size=size.small)
    if vsa_bh
        label.new(bar_index, 29, "BH", color=color.new(#00BCD4, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
    if vsa_sa
        label.new(bar_index, 36, "SA", color=color.new(#76FF03, 10), textcolor=color.white, style=label.style_label_up, size=size.small)
    if vsa_bc
        label.new(bar_index, 92, "BC", color=color.new(#F44336, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)
    if vsa_eor
        label.new(bar_index, 85, "EoR", color=color.new(#F44336, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
    if vsa_tr
        label.new(bar_index, 78, "TR", color=color.new(#FF6D00, 10), textcolor=color.white, style=label.style_label_down, size=size.small)
    if vsa_sod
        label.new(bar_index, 71, "SoD", color=color.new(#FF6D00, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
    if vsa_da
        label.new(bar_index, 64, "DA", color=color.new(#FF6D00, 30), textcolor=color.white, style=label.style_label_down, size=size.small)
    if no_supply
        label.new(bar_index, 3, "NS", color=color.new(#00E676, 30), textcolor=color.white, style=label.style_label_up, size=size.tiny)
    if shakeout
        label.new(bar_index, 3, "SHK", color=color.new(#00C853, 0), textcolor=color.white, style=label.style_label_up, size=size.normal)
    if no_demand
        label.new(bar_index, 97, "ND", color=color.new(#F44336, 30), textcolor=color.white, style=label.style_label_down, size=size.tiny)
    if upthrust
        label.new(bar_index, 97, "UT", color=color.new(#D50000, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)

bgcolor(show_vsa_bg and shakeout ? color.new(#00E676, 88) : na, title="Shakeout BG")
bgcolor(show_vsa_bg and no_supply ? color.new(#00E676, 93) : na, title="No Supply BG")
bgcolor(show_vsa_bg and upthrust ? color.new(#F44336, 85) : na, title="Upthrust BG")
bgcolor(show_vsa_bg and no_demand ? color.new(#F44336, 93) : na, title="No Demand BG")

// =========================================================
// SCORECARD TABLE (3-column layout with rebuilt VSA column)
// =========================================================
var tbl = table.new(position.top_right, 6, 13, bgcolor=color.new(#1a1a2e, 0), border_width=1, border_color=color.new(#333355, 0), frame_width=2, frame_color=color.new(#4444aa, 0))

// Helper: format bars-ago as string
f_ago_str(int bars) =>
    bars == 0 ? "NOW" : bars < 100 ? (str.tostring(bars) + "d ago") : "---"

// Helper: color by recency (bullish signal)
f_ago_bull(int bars) =>
    bars <= 2 ? #00E676 : (bars <= 5 ? #4CAF50 : (bars <= 10 ? #FF9800 : #555577))

// Helper: color by recency (bearish signal)
f_ago_bear(int bars) =>
    bars <= 2 ? #F44336 : (bars <= 5 ? #E57373 : (bars <= 10 ? #FF9800 : #555577))

if show_bo_table and barstate.islast

    // --- COLUMN HEADERS (row 0) ---
    table.cell(tbl, 0, 0, "LIVE TAPE READER", text_color=#FFD700, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(tbl, 1, 0, "NOW", text_color=#FFD700, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0))
    table.cell(tbl, 2, 0, "LAST BREAKOUT", text_color=#00E676, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(tbl, 3, 0, latch_date, text_color=#00E676, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0))
    table.cell(tbl, 4, 0, "VSA RECENCY", text_color=#E040FB, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(tbl, 5, 0, "BARS AGO", text_color=#E040FB, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0))

    // =========================================================
    // COLUMN 1: LIVE TAPE READER (rows 1-9)
    // =========================================================
    live_bar_dir = close >= open ? "UP" : "DOWN"
    live_vol_ch = tw_vol_is_high ? "HIGH vol" : (tw_vol_is_low ? "LOW vol" : "avg vol")
    live_spd_ch = tw_spread_is_wide ? "WIDE" : (tw_spread_is_narrow ? "NARROW" : "avg spd")
    live_cls_ch = tw_close_near_hi ? "close HI" : (tw_close_near_lo ? "close LO" : "close MID")
    live_bar_clr = (close >= open and tw_close_near_hi) ? #00E676 : ((close < open and tw_close_near_lo) ? #F44336 : #FF9800)
    table.cell(tbl, 0, 1, "Bar", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 1, live_bar_dir + " " + live_vol_ch, text_color=live_bar_clr, text_size=size.tiny)
    table.cell(tbl, 0, 2, "Spread/Close", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 2, live_spd_ch + " " + live_cls_ch, text_color=live_bar_clr, text_size=size.tiny)
    live_evr_str = str.tostring(evr_ratio, "#.##") + " (" + str.tostring(evr_score) + "/3)"
    live_evr_clr = evr_score >= 2 ? #00E676 : (evr_score >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 0, 3, "Effort/Result", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 3, live_evr_str, text_color=live_evr_clr, text_size=size.tiny)
    live_vr_str = str.tostring(tw_vol_ratio, "#.##") + "x avg"
    live_vr_clr = tw_vol_is_high ? #00E676 : (tw_vol_is_low ? #F44336 : #FF9800)
    table.cell(tbl, 0, 4, "Volume", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 4, live_vr_str, text_color=live_vr_clr, text_size=size.tiny)
    live_cp_str = str.tostring(close_pct * 100, "#.0") + "% range"
    live_cp_clr = tw_close_near_hi ? #00E676 : (tw_close_near_lo ? #F44336 : #FF9800)
    table.cell(tbl, 0, 5, "Close Pos", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 5, live_cp_str, text_color=live_cp_clr, text_size=size.tiny)
    live_dv_str = str.tostring(dv_ratio * 100, "#.0") + "% buy"
    live_dv_flag = hidden_sell ? " HS!" : (hidden_buy ? " HB!" : "")
    live_dv_clr = hidden_sell ? #F44336 : (hidden_buy ? #00E676 : (dv_ratio > 0.55 ? #00E676 : (dv_ratio > 0.45 ? #FF9800 : #F44336)))
    table.cell(tbl, 0, 6, "DV Flow", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 6, live_dv_str + live_dv_flag, text_color=live_dv_clr, text_size=size.tiny)
    live_cvd_str = cvd_confirms ? "CONFIRMS" : (cvd_diverges ? "DIVERGES!" : "Neutral")
    live_cvd_clr = cvd_confirms ? #00E676 : (cvd_diverges ? #F44336 : #FF9800)
    table.cell(tbl, 0, 7, "CVD", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 7, live_cvd_str, text_color=live_cvd_clr, text_size=size.tiny)
    live_ctx_str = (bc_detected or eor_detected) ? "BC/EoR ARMED" : "Neutral ctx"
    live_ctx_clr = (bc_detected or eor_detected) ? #FF9800 : #666688
    table.cell(tbl, 0, 8, "Background", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 8, live_ctx_str, text_color=live_ctx_clr, text_size=size.tiny)
    bo_live_str = breakout_bar ? "BREAKOUT!" : (bars_since_bo <= 5 ? ("FT Day " + str.tostring(bars_since_bo)) : "---")
    bo_live_clr = breakout_bar ? #00E676 : (bars_since_bo <= 5 ? #2196F3 : #555577)
    table.cell(tbl, 0, 9, "Breakout", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 9, bo_live_str, text_color=bo_live_clr, text_size=size.tiny)

    // =========================================================
    // COLUMN 2: LAST BREAKOUT SCORECARD (rows 1-12)
    // =========================================================
    v_str2 = latch_is_accum ? "ACCUMULATION" : (latch_is_likely ? "LIKELY ACCUM" : (latch_is_uncertain ? "UNCERTAIN" : (latch_is_exhaust ? "EXHAUSTION" : "No BO yet")))
    v_clr2 = latch_is_accum ? #00E676 : (latch_is_likely ? #2196F3 : (latch_is_uncertain ? #FF9800 : #F44336))
    table.cell(tbl, 2, 1, "Verdict", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 1, v_str2, text_color=v_clr2, text_size=size.tiny)
    comp_str = str.tostring(latch_raw_score) + "/28 (" + str.tostring(latch_bq_pct, "#") + "%)"
    comp_clr = latch_is_accum ? #00E676 : (latch_is_likely ? #2196F3 : (latch_is_uncertain ? #FF9800 : #F44336))
    table.cell(tbl, 2, 2, "COMPOSITE", text_color=#ffffff, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#0d0d1a, 0))
    table.cell(tbl, 3, 2, comp_str, text_color=comp_clr, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0))
    evr_str = str.tostring(latch_evr_ratio, "#.##") + " (" + str.tostring(latch_evr_score) + "/3)"
    evr_clr = latch_evr_score >= 2 ? #00E676 : (latch_evr_score >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 3, "Effort/Result", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 3, evr_str, text_color=evr_clr, text_size=size.tiny)
    cp_str = str.tostring(latch_close_pct * 100, "#.0") + "% (" + str.tostring(latch_close_score) + "/3)"
    cp_clr = latch_close_score >= 2 ? #00E676 : (latch_close_score >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 4, "Close Pos", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 4, cp_str, text_color=cp_clr, text_size=size.tiny)
    abs_str = str.tostring(latch_absorption) + "/3"
    abs_clr = latch_absorption >= 2 ? #00E676 : (latch_absorption >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 5, "Absorption", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 5, abs_str, text_color=abs_clr, text_size=size.tiny)
    vc_str = str.tostring(latch_vol_surge, "#.#") + "x (" + str.tostring(latch_vol_char) + "/3)"
    vc_clr = latch_vol_char >= 2 ? #00E676 : (latch_vol_char >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 6, "Vol Surge", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 6, vc_str, text_color=vc_clr, text_size=size.tiny)
    vr_str = latch_vol_highest ? "HIGHEST 20d" : "Not highest"
    vr_clr = latch_vol_rank >= 2 ? #00E676 : (latch_vol_rank >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 7, "Vol Rank", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 7, vr_str, text_color=vr_clr, text_size=size.tiny)
    sq_str = str.tostring(latch_spread_vs_avg, "#.##") + "x avg"
    sq_clr = latch_spread_score >= 2 ? #00E676 : (latch_spread_score >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 8, "Spread", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 8, sq_str, text_color=sq_clr, text_size=size.tiny)
    cvd_str = latch_cvd_confirms ? "CONFIRMS" : (latch_cvd_diverges ? "DIVERGES" : "Neutral")
    cvd_extra = latch_cvd_stealth ? " +stealth" : ""
    cvd_display = cvd_str + cvd_extra + " (" + str.tostring(latch_cvd_total) + "/3)"
    cvd_clr = latch_cvd_total >= 2 ? #00E676 : (latch_cvd_total >= 1 ? #FF9800 : #F44336)
    table.cell(tbl, 2, 9, "CVD", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 9, cvd_display, text_color=cvd_clr, text_size=size.tiny)
    dv_pct_str = str.tostring(latch_dv_ratio * 100, "#.0") + "% buy"
    hs_flag = latch_hidden_sell ? " HS" : (latch_hidden_buy ? " HB" : "")
    hidden_display = dv_pct_str + hs_flag + " (" + str.tostring(latch_hidden_score) + "/3)"
    hidden_clr = latch_hidden_score >= 2 ? #00E676 : (latch_hidden_score >= 1 ? #FF9800 : #F44336)
    hidden_bg = latch_hidden_sell ? color.new(#F44336, 70) : (latch_hidden_buy ? color.new(#00E676, 70) : color.new(#1a1a2e, 0))
    table.cell(tbl, 2, 10, "Hidden Signal", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 10, hidden_display, text_color=hidden_clr, text_size=size.tiny, bgcolor=hidden_bg)
    ft_day_str = str.tostring(bars_since_bo)
    ft_str = bars_since_bo <= 10 ? (str.tostring(ft_score) + "/3 D" + ft_day_str) : "N/A"
    ft_clr2 = ft_score >= 2 ? #00E676 : (ft_score >= 1 ? #FF9800 : #F44336)
    ft_tbl_clr = bars_since_bo <= ft_days ? ft_clr2 : #666688
    table.cell(tbl, 2, 11, "Follow-Thru", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 11, ft_str, text_color=ft_tbl_clr, text_size=size.tiny)
    tw_net_str = (latch_tw_score > 0 ? "+" : "") + str.tostring(latch_tw_score) + " pts"
    tw_net_clr = latch_tw_score > 0 ? #00E676 : (latch_tw_score < 0 ? #F44336 : #666688)
    table.cell(tbl, 2, 12, "TW VSA Net", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 3, 12, tw_net_str, text_color=tw_net_clr, text_size=size.tiny)

    // =========================================================
    // COLUMN 3: VSA RECENCY (REBUILT in v3.1)
    // Shows bars-ago for every signal with color-coded recency
    // =========================================================

    // Row 1: Best recent SoS
    sos_ago_str = best_sos_name + " " + f_ago_str(best_sos_ago)
    sos_ago_clr = f_ago_bull(best_sos_ago)
    table.cell(tbl, 4, 1, "Best Strength", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 1, sos_ago_str, text_color=sos_ago_clr, text_size=size.tiny, bgcolor=best_sos_ago <= 2 ? color.new(#00E676, 80) : color.new(#1a1a2e, 0))

    // Row 2: Best recent SoW
    sow_ago_str = best_sow_name + " " + f_ago_str(best_sow_ago)
    sow_ago_clr = f_ago_bear(best_sow_ago)
    table.cell(tbl, 4, 2, "Best Weakness", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 2, sow_ago_str, text_color=sow_ago_clr, text_size=size.tiny, bgcolor=best_sow_ago <= 2 ? color.new(#F44336, 80) : color.new(#1a1a2e, 0))

    // Row 3: SC | SV
    table.cell(tbl, 4, 3, "SC | SV", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 3, f_ago_str(ago_sc) + " | " + f_ago_str(ago_sv), text_color=f_ago_bull(math.min(ago_sc, ago_sv)), text_size=size.tiny)

    // Row 4: BR | BH | SA
    table.cell(tbl, 4, 4, "BR | BH | SA", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 4, f_ago_str(ago_br) + " | " + f_ago_str(ago_bh) + " | " + f_ago_str(ago_sa), text_color=f_ago_bull(math.min(ago_br, math.min(ago_bh, ago_sa))), text_size=size.tiny)

    // Row 5: NS | SHK
    table.cell(tbl, 4, 5, "NS | SHK", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 5, f_ago_str(ago_ns) + " | " + f_ago_str(ago_shk), text_color=f_ago_bull(math.min(ago_ns, ago_shk)), text_size=size.tiny)

    // Row 6: BC | EoR
    table.cell(tbl, 4, 6, "BC | EoR", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 6, f_ago_str(ago_bc) + " | " + f_ago_str(ago_eor), text_color=f_ago_bear(math.min(ago_bc, ago_eor)), text_size=size.tiny)

    // Row 7: TR | SoD | DA
    table.cell(tbl, 4, 7, "TR | SoD | DA", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 7, f_ago_str(ago_tr) + " | " + f_ago_str(ago_sod) + " | " + f_ago_str(ago_da), text_color=f_ago_bear(math.min(ago_tr, math.min(ago_sod, ago_da))), text_size=size.tiny)

    // Row 8: UT | ND
    table.cell(tbl, 4, 8, "UT | ND", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 8, f_ago_str(ago_ut) + " | " + f_ago_str(ago_nd), text_color=f_ago_bear(math.min(ago_ut, ago_nd)), text_size=size.tiny)

    // Row 9: HB | HS
    table.cell(tbl, 4, 9, "HB | HS", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    hb_clr = ago_hb < ago_hs ? f_ago_bull(ago_hb) : f_ago_bear(ago_hs)
    table.cell(tbl, 5, 9, f_ago_str(ago_hb) + " | " + f_ago_str(ago_hs), text_color=hb_clr, text_size=size.tiny)

    // Row 10: Bias summary
    sos_recent = best_sos_ago <= 5
    sow_recent = best_sow_ago <= 5
    bias_str = (sos_recent and not sow_recent) ? "BULL BIAS" : ((sow_recent and not sos_recent) ? "BEAR BIAS" : ((sos_recent and sow_recent) ? "CONTESTED" : "NEUTRAL"))
    bias_clr = (sos_recent and not sow_recent) ? #00E676 : ((sow_recent and not sos_recent) ? #F44336 : ((sos_recent and sow_recent) ? #FF9800 : #666688))
    bias_bg = (sos_recent and not sow_recent) ? color.new(#00E676, 80) : ((sow_recent and not sos_recent) ? color.new(#F44336, 80) : color.new(#1a1a2e, 0))
    table.cell(tbl, 4, 10, "VSA BIAS", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 5, 10, bias_str, text_color=bias_clr, text_size=size.tiny, bgcolor=bias_bg)

// =========================================================
// NEW in v3.2 — HTF CONTEXT TABLE (MTF stable-snapshot readout)
// =========================================================
var tblHtf = table.new(position.bottom_left, 2, 9, bgcolor=color.new(#1a1a2e, 0), border_width=1, border_color=color.new(#333355, 0), frame_width=2, frame_color=color.new(#4444aa, 0))

f_verdict_str(int v) =>
    v == 1 ? "ACCUMULATION" : v == 2 ? "LIKELY ACCUM" : v == 3 ? "UNCERTAIN" : v == 4 ? "EXHAUSTION" : "---"

f_verdict_clr(int v) =>
    v == 1 ? #00E676 : v == 2 ? #2196F3 : v == 3 ? #FF9800 : v == 4 ? #F44336 : #666688

f_htf_ago_str(int bars) =>
    bars == 0 ? "NOW" : bars < 900 ? (str.tostring(bars) + " bars ago") : "none seen"

if show_htf_table and barstate.islast
    table.cell(tblHtf, 0, 0, "HTF CONTEXT (" + htf_tf + ")", text_color=#E040FB, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(tblHtf, 1, 0, htf_valid ? "stable snapshot" : "INVALID TF", text_color=htf_valid ? #E040FB : #F44336, text_size=size.tiny, bgcolor=color.new(#0d0d1a, 0))

    table.cell(tblHtf, 0, 1, "Verdict", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 1, f_verdict_str(htf_verdict), text_color=f_verdict_clr(htf_verdict), text_size=size.tiny)

    htf_comp_str = str.tostring(htf_raw_score) + "/14 (" + str.tostring(htf_bq_pct, "#") + "%)"
    table.cell(tblHtf, 0, 2, "Composite", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 2, htf_comp_str, text_color=f_verdict_clr(htf_verdict), text_size=size.tiny)

    htf_tw_str = (htf_tw_score > 0 ? "+" : "") + str.tostring(htf_tw_score) + " pts"
    htf_tw_clr = htf_tw_score > 0 ? #00E676 : (htf_tw_score < 0 ? #F44336 : #666688)
    table.cell(tblHtf, 0, 3, "TW VSA Net", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 3, htf_tw_str, text_color=htf_tw_clr, text_size=size.tiny)

    htf_best_strength_ago = math.min(htf_ago_shk, htf_ago_ns)
    htf_best_strength_name = htf_ago_shk <= htf_ago_ns ? "SHK" : "NS"
    table.cell(tblHtf, 0, 4, "Best Strength", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 4, htf_best_strength_name + " " + f_htf_ago_str(htf_best_strength_ago), text_color=htf_best_strength_ago <= 2 ? #00E676 : #666688, text_size=size.tiny)

    htf_best_weak_ago = math.min(htf_ago_ut, htf_ago_nd)
    htf_best_weak_name = htf_ago_ut <= htf_ago_nd ? "UT" : "ND"
    table.cell(tblHtf, 0, 5, "Best Weakness", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 5, htf_best_weak_name + " " + f_htf_ago_str(htf_best_weak_ago), text_color=htf_best_weak_ago <= 2 ? #F44336 : #666688, text_size=size.tiny)

    table.cell(tblHtf, 0, 6, "HTF Breakout", text_color=#aaaacc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 6, htf_bars_since_bo == 0 ? "THIS BAR" : f_htf_ago_str(htf_bars_since_bo), text_color=#aaaacc, text_size=size.tiny)

    align_str = htf_alignment == 1 ? "CONFIRMS" : htf_alignment == 2 ? "CONFLICTS!" : htf_alignment == 3 ? "CONFIRMS (avoid)" : htf_alignment == 4 ? "NEUTRAL" : "OFF"
    align_clr = htf_alignment == 1 ? #00E676 : htf_alignment == 2 ? #F44336 : htf_alignment == 3 ? #F44336 : #666688
    align_bg = htf_alignment == 2 ? color.new(#F44336, 70) : (htf_alignment == 1 ? color.new(#00E676, 80) : color.new(#1a1a2e, 0))
    table.cell(tblHtf, 0, 7, "Alignment", text_color=#ccccdd, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 7, align_str, text_color=align_clr, text_size=size.tiny, bgcolor=align_bg)

    table.cell(tblHtf, 0, 8, "vs Last Breakout", text_color=#666688, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tblHtf, 1, 8, latch_date, text_color=#666688, text_size=size.tiny)

// ALERTS
alertcondition(breakout_bar and is_accumulation, title="Accumulation Breakout", message="BQ WYCKOFF: Accumulation breakout on {{ticker}}")
alertcondition(breakout_bar and is_exhaustion, title="Exhaustion Breakout", message="BQ WYCKOFF: Exhaustion breakout on {{ticker}} - avoid")
alertcondition(breakout_bar and hidden_sell, title="Hidden Sell on Breakout", message="BQ WYCKOFF: HIDDEN SELL on breakout of {{ticker}}")
alertcondition(breakout_bar and cvd_diverges, title="CVD Divergence on Breakout", message="BQ WYCKOFF: CVD divergence on breakout of {{ticker}}")
alertcondition(in_followthrough and (ft_score < 2), title="Weak Follow-Through", message="BQ WYCKOFF: Weak follow-through on {{ticker}}")
alertcondition(hidden_buy, title="Hidden Buy Detected", message="BQ WYCKOFF: Hidden Buy on {{ticker}}")
alertcondition(hidden_sell, title="Hidden Sell Detected", message="BQ WYCKOFF: Hidden Sell on {{ticker}}")
alertcondition(shakeout, title="Shakeout Detected", message="BQ WYCKOFF v3: SHAKEOUT on {{ticker}}")
alertcondition(no_supply, title="No Supply Detected", message="BQ WYCKOFF v3: NO SUPPLY on {{ticker}}")
alertcondition(upthrust, title="Upthrust Detected", message="BQ WYCKOFF v3: UPTHRUST on {{ticker}}")
alertcondition(breakout_bar and upthrust, title="Upthrust on Breakout Bar", message="BQ WYCKOFF v3: UPTHRUST on breakout of {{ticker}}")
alertcondition(no_demand, title="No Demand Detected", message="BQ WYCKOFF v3: NO DEMAND on {{ticker}}")
// NEW in v3.2
alertcondition(breakout_bar and is_accumulation and htf_enable and htf_valid and (htf_verdict == 1 or htf_verdict == 2), title="HTF-Confirmed Accumulation Breakout", message="BQ WYCKOFF: Accumulation breakout on {{ticker}} CONFIRMED by HTF context")
// END
````
