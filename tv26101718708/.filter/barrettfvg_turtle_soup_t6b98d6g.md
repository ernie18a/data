# BarrettFVG Turtle Soup

- url: https://www.tradingview.com/script/t6B98D6g-BarrettFVG-Turtle-Soup/
- type: indicator
- pine_id: PUB;9298232b46e44ea48ad8381230361644
- version: 1.0

## Description

OVERVIEW
BarrettFVG Turtle Soup finds swing levels that get swept and rejected in the same candle, tracks them across five timeframes at once, and then waits for a displacement gap before calling it a trade. Every signal carries a stop, a breakeven, a target, and a contract count worked out from your own risk.
A turtle soup is a failed breakout. Price pushes through a prior swing high or low, takes the orders resting beyond it, and closes back on the original side of the level — the break is rejected within the candle that made it. On its own that is a context clue, not an entry. This script treats it as the first half of a setup and requires a fair value gap or an inversion in the rejection direction before anything is marked as tradeable.
It is a decision-support tool. It does not predict direction and it does not place orders.

HOW THE MODEL WORKS
LEVEL TRACKING
Each scanned timeframe maintains its own list of unbroken swing highs and lows, confirmed by pivot length. A level stays on the list until price trades through it, at which point it is consumed and cannot be swept twice.
THE SWEEP AND REJECTION
When a confirmed bar trades beyond a tracked level but closes back on the original side, that level is marked as swept. The marker line runs from the swing that created the level to the candle that rejected it, so the chart shows what was taken and when.
Where several levels are taken in one candle, the most recently formed is used. A sweep that reaches through old structure has taken the near level too, and the near level is the one price is reacting to.
A higher-timeframe marker is drawn at the CLOSE of the bar that produced it rather than at that bar's timestamp, which is its open. The rejection is not confirmed until the candle closes, and placing the marker at the open leaves it a full higher-timeframe bar to the left of the point the setup actually becomes live.
INVALIDATION
A marked soup is removed if a later confirmed close on its own source timeframe finishes on the wrong side of the level — unless it has already produced an entry. Invalidation exists to clear sweeps that failed before they did anything; applied after the fact it would delete the marker while its entry label stayed, leaving a signal on the chart with nothing visible behind it.
MULTI-TIMEFRAME SCANNING
Five higher-timeframe slots run alongside the chart timeframe, each scanning inside its own bars rather than approximating from chart data. Higher-timeframe results are read one bar back with lookahead enabled, which is the non-repainting idiom: a higher-timeframe soup appears only once its bar has closed and never moves afterwards.
Markers are prefixed with the timeframe they came from, so a 4-hour sweep is visibly different from a 5-minute one.

ENTRIES
A soup alone does not produce a signal. After one is marked, the script watches for a fair value gap or an inverse fair value gap in the rejection direction, and all of the following must hold:
The gap forms within the entry window, counted in chart bars from the soup.
The gap is at least the configured multiple of ATR(14). This is what separates displacement from a one-bar artifact and is the main selectivity control in the script.
The gap sits entirely clear of the swept level, in the rejection direction, by the configured clearance. A gap still straddling the level is price churning at it, not leaving it.
The bar is inside a session window.
A soup is consumed by the entry it produces, so one sweep yields at most one signal. Where several soups are eligible when a gap forms, the most recent is used.
Inversions count as entries in their own right. A gap that gets traded through becomes an inverse gap pointing the other way, and an inversion forming in the rejection direction after a soup is as valid as a fresh gap — often it is the cleaner of the two, because the level has already been tested once.
While a soup can still produce an entry, its swept level is carried forward across the chart. The line stops where the soup stopped being eligible, so the right end of a level marks the moment it expired or fired. A signal with no live level reaching it did not come from a soup still in play.

DELIVERY (CISD)
A delivery leg is a run of consecutive same-direction closes. Its OPENING is the reference: price closing back through it means whatever was delivering that way has stopped and the other side is in control. The most recent change of state is marked with a line at the reclaimed opening.
A run only becomes a reference once it is long enough to be delivery rather than a single candle, which is what keeps the state from flipping on every alternating bar.
Used as a filter, this holds entries rather than blocking them. A turtle soup is a counter-trend entry and its main way of failing is that the breakout it faded was real, so a signal fired while delivery still runs the other way is parked and released once delivery changes state, or dropped if the hold window expires.
A body level a few candles back is used rather than a swing break on purpose. A swing is wherever the last swing happens to be, does not exist until its pivot confirms, and is usually a long way from a sweep — so confirming against one costs a great deal of stop distance. The opening of the leg that just moved price is close to it.

STOPS, BREAKEVEN AND TARGET
The stop is anchored to the sweep extreme — how far price actually ran past the swept level — plus a tick buffer. Not to the level itself, which price traded through by definition, and not to the entry candle.
That reference keeps extending. Each eligible soup carries a running excursion extreme that pushes further out every bar until a gap fires it, so if price digs deeper past the level while the setup is pending, the stop follows. It only ever widens and is read once, at entry, so a stop is never placed inside ground price has already covered. A held signal extends it too, for the same reason.
The target is a multiple of that measured risk, defaulting to 1R. A turtle soup is a snap-back off a defended level rather than a trend entry, and the target follows the setup's own size rather than a fixed point value.
Breakeven is a fraction of the distance to target rather than a fixed R, so it keeps meaning the same thing if the target multiple is changed. When price reaches it, the stop line physically relocates to entry, its label is renamed, and the breakeven line is removed — a line left sitting there would read as a level still waiting to be reached.
Breakeven is evaluated before the stop. A bar that reaches breakeven and then trades back through entry is reported as a scratch, not a loss. If a bar trades through both stop and target, the stop counts.
One set of levels is drawn at a time and the most recent entry signal owns it.

POSITION SIZE ON THE LABEL
Each entry label carries the timeframe of the soup behind it and the number of contracts its stop distance allows at a configured dollar risk, worked out from the instrument's own point value.
This is arithmetic, not a judgement about the setup. But it is the difference the chart does not otherwise show: two signals that look identical can be a full position and a quarter of one, because the stop follows how far the sweep actually ran. A stop too wide to take even one contract at the configured risk reads as "<1" rather than zero, because that is a fact about the trade and not a fault in the sum.
Each entry is also linked by a line back to the swept level that produced it. A marker sits at its level's PRICE, which for a slower timeframe can be far above or below where the entry fires and therefore outside the visible chart. The link always points at it.

CONTEXT LEVELS
NEXT LIQUIDITY
The nearest unbroken swing high above price and swing low below it, for each enabled timeframe — the closest places a soup could next form. Only the nearest either side per timeframe is drawn; every tracked level would be hundreds of lines.
Each is drawn from the swing that created it, so its length shows how long that level has stood. Where several timeframes land on the same price they share one line and one label naming all of them, because that is one level with several names rather than several levels.
This is the only part of the script that says anything before the event rather than after it.
PREVIOUS DAY AND WEEK HIGH / LOW
Drawn across the chart with their labels set clear of the line end.

SESSIONS AND ALERTS
Two configurable session windows gate output. Levels, sweeps and gaps are tracked around the clock, so a soup that forms overnight is correct the moment a window opens; what the gate stops is output. No entry is marked outside the windows and no alert of any kind is sent outside them.
All events are carried on a single dynamic message, so one alert set to "Any alert() function call" covers the whole model: both entry directions, breakeven, and all three exit types. The entry message names the gap type, the timeframe whose soup produced it, and whether it was held for delivery. Named conditions remain available for isolating a single event.
Alerts evaluate on bar close.

SETTINGS
General — maximum sweeps displayed, chart and higher-timeframe pivot lengths kept separate, maximum active swing levels per timeframe.
Timeframes — the chart timeframe scan and five independent higher-timeframe slots, each with its own toggle.
Appearance — marker visibility, colour, text, line style, label size, timeframe prefix, and whether a swept level is carried forward while armed.
FVG / IFVG — gap and inversion visibility, minimum ATR multiplier, maximum active zones, overlap filter, zone extension, colours and text sizes, entry window, entry gap clearance, entry label controls.
Delivery (CISD) — line visibility, minimum run length, reclaim clearance, label offset, the hold filter and its window.
Trade Levels — SL / BE / TP visibility, stop buffer, take profit in R, breakeven fraction, contract count and risk per trade, source timeframe on the label, and the link back to each entry's soup.
Next Liquidity, Sessions, Session Levels and Alerts each group their own controls.

HOW TO USE IT
Set the two session windows to the hours you trade.
Pivot length is the setting most worth understanding. It defaults to 1 on both the chart and higher timeframes, and that is deliberate rather than lazy: a level does not exist until its pivot confirms, so a longer pivot length is structurally blind to a swing that forms and gets swept a few bars later — which is most of them. Selectivity is meant to come from the ATR minimum on gap size, not from here.
The ATR multiplier is the dial to reach for if signals are arriving too thickly. Raising it demands more displacement before a rejection counts as a trade.
There is no time-based lookback. Each timeframe keeps its unbroken swing highs and lows up to the active-level cap, and a level leaves that list only when price trades through it or when the cap pushes the oldest off the end. How far back the script reaches is therefore a consequence of how quickly levels form and get broken, not a setting: on a fast timeframe with a short pivot length the oldest surviving level may be an hour or two old, while on the 4-hour the same cap can reach back months.
Read the contract count before the setup. Scanning five timeframes at once is not the same as trading five timeframes, and the number on the label is where that shows: a sweep that ran a long way produces a stop to match, and the position it allows may be too small to be worth the attention regardless of how the pattern looks.

LIMITATIONS AND SHORTCOMINGS
The entry window is counted in chart bars, not in bars of the timeframe that produced the soup. A 4-hour soup therefore gets the same handful of chart bars to produce its gap as a 1-minute soup does, and in practice the slower slots mark up reliably but convert to entry signals far less often. Counting it in the source timeframe's own bars instead was tried and is worse: a higher-timeframe soup then stays armed for hours and fires on a gap that has nothing to do with it.
A higher-timeframe soup is also read one bar back, so it registers at the open of the bar after the one that rejected the level. The window therefore opens after the rejection candle has already closed.
Stops anchored to a higher-timeframe sweep extreme can be very wide. A 4-hour candle's extreme may be a long way from a 1-minute entry, and a fixed contract count will not produce consistent risk across setups. This is the single biggest practical limitation of the script and the reason the contract count is drawn on the label at all.
With pivot length at 1 and several timeframes enabled, a great many levels are tracked and a great many sweeps are marked. Most of them will not produce entries. This is the intended behaviour of a responsive setting, but the chart will look busy, and the sweep display limit exists because of it.
Only the most recent entry signal keeps managed levels. A signal that replaces an earlier one abandons it rather than resolving it, so no stop or target alert will follow for the replaced setup.
Where both a long and a short signal land on the same bar, which is possible when a fresh gap and an opposing inversion coincide, the long is tracked. There is no basis in the model for preferring either.
The delivery filter delays entries, and a delayed entry is further from a stop that has not moved. It should improve the quality of what gets taken and will certainly worsen the reward-to-risk of each one; which effect dominates is not something the script can tell you.
Signals and level touches evaluate on bar close and do not repaint. Zones, levels and trade lines extend forward as a setup develops, which is expected behaviour rather than repainting of the signals themselves. Because touches are reported at the close of the bar in which they occurred, a breakeven or stop notification arrives up to one bar after the price event.
The script contains no order placement, no position tracking across trades, and no backtest statistics. Nothing here is a complete trading system on its own.

ORIGINALITY
Sweep markers are common. What is specific to this script is that a swept level is treated as half a setup rather than a signal, and that everything downstream of it is built out.
The entry requirement. A marked soup produces nothing until a fair value gap or an inversion forms in the rejection direction, sized against ATR, inside a window, and positioned entirely clear of the swept level. The soup is then consumed, so one sweep cannot produce a stream of signals from the same level.
Inversions as first-class entries, tracked through the full lifecycle of each zone — gap, inversion, mitigation.
The stop reference. Anchored to the sweep extreme rather than the swept level, and extended every bar while the setup is pending or held, so a stop is never placed inside ground price has already covered. Read once, at entry.
Proportional breakeven that physically relocates the stop line rather than only announcing it, with a stop hit after breakeven reported separately from one hit before it.
Position size on the signal. The contract count a stop allows at a stated dollar risk, on the label, at the moment of the signal — because the size a setup permits is a property of the trade that a stop line alone does not communicate.
Entry-to-soup links, so a signal is always traceable to the sweep that caused it even when that sweep sits off the visible chart.
Next-liquidity levels: the nearest unbroken swing per timeframe, drawn from its origin, merged where timeframes agree.
Genuine multi-timeframe level tracking, each timeframe scanning inside its own bars, with pivot lengths separated for chart and higher timeframes.
Session gating on output rather than on the model, so levels and sweeps stay correct through the night and only notifications are withheld.
The underlying concepts — liquidity sweeps, failed breakouts, fair value gaps, inversions, change in the state of delivery — are publicly taught market structure ideas and are not claimed as original here. The implementation is.

DISCLAIMER
This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any instrument.
No performance is claimed or implied. Historical behaviour does not indicate future results. Trading futures, forex and other leveraged instruments carries substantial risk of loss and is not suitable for every investor.
All settings shown are defaults and are not recommendations. The risk-per-trade setting is a display input used to calculate a contract count; it is arithmetic, not position-sizing advice, and it does not account for your account size, risk tolerance, costs or circumstances. Any levels, stops or targets the script draws are calculated outputs, not advice.
You are solely responsible for your own trading decisions and for testing any tool on your own data before relying on it. Use of this script implies agreement with TradingView's Terms of Use and House Rules.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("BarrettFVG Turtle Soup", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// --- Inputs ---
maxSweepsInput = input.int(50, "Max Sweeps Displayed", minval = 1, maxval = 200, tooltip = "Maximum number of active Turtle Soup markers retained on the chart.", group = "General")
chartPivotLenInput = input.int(1, "Chart TF Pivot Length", minval = 1, maxval = 50, tooltip = "Bars either side needed to confirm a swing on the CHART timeframe.\n\n1 is the most responsive setting and is the default for a reason: a level does not exist until its pivot CONFIRMS, so a longer length is structurally blind to a swing that forms and gets swept a few bars later — which is most of them.\n\nSelectivity comes from the gap requirement and from how many levels are retained, not from here.", group = "General")
htfPivotLenInput = input.int(1, "HTF Pivot Length", minval = 1, maxval = 50, tooltip = "Bars either side on each HIGHER timeframe, kept separate so the two can be tuned apart.\n\nThe scan runs inside each timeframe's own bars, so the same number means very different things: 1 bar either side is two minutes of context on the 1-minute and half a day on the 4-hour.", group = "General")
maxActiveLevelsInput = input.int(80, "Max Active Swing Levels", minval = 10, maxval = 300, tooltip = "How many unbroken swing highs and lows each timeframe tracks. Higher values can reveal older liquidity levels.", group = "General")

showCurrentInput = input.bool(false, "Show Current TF", tooltip = "Scan the chart timeframe for confirmed sweep-and-reject events.\n\nOff by default. On a 1-minute chart with a pivot length of 1 this produces a very large number of soups, most of them noise; the higher-timeframe scans below are the useful context.", group = "Timeframes")
showHtf1Input = input.bool(true, "Show HTF 1", tooltip = "Enable the first higher-timeframe scan.", group = "Timeframes", inline = "htf1")
htf1Input = input.timeframe("5", "", tooltip = "First higher timeframe to scan.", group = "Timeframes", inline = "htf1")
showHtf2Input = input.bool(true, "Show HTF 2", tooltip = "Enable the second higher-timeframe scan.", group = "Timeframes", inline = "htf2")
htf2Input = input.timeframe("15", "", tooltip = "Second higher timeframe to scan.", group = "Timeframes", inline = "htf2")
showHtf3Input = input.bool(true, "Show HTF 3", tooltip = "Enable the third higher-timeframe scan.", group = "Timeframes", inline = "htf3")
htf3Input = input.timeframe("30", "", tooltip = "Third higher timeframe to scan.", group = "Timeframes", inline = "htf3")
showHtf4Input = input.bool(true, "Show HTF 4", tooltip = "Enable the fourth higher-timeframe scan.", group = "Timeframes", inline = "htf4")
htf4Input = input.timeframe("60", "", tooltip = "Fourth higher timeframe to scan.", group = "Timeframes", inline = "htf4")
showHtf5Input = input.bool(true, "Show HTF 5", tooltip = "Enable the fifth higher-timeframe scan.", group = "Timeframes", inline = "htf5")
htf5Input = input.timeframe("240", "", tooltip = "Fifth higher timeframe to scan.", group = "Timeframes", inline = "htf5")

showMarkersInput = input.bool(true, "Show Turtle Soups", tooltip = "Show the level line and marker for each detected rejection.", group = "Appearance")
markerColorInput = input.color(#30333E, "Marker Color", tooltip = "Color used for sweep lines and marker text.", group = "Appearance")
markerTextInput = input.string("🐢", "Marker Text", tooltip = "Text or emoji displayed at the swept swing level.", group = "Appearance")
lineStyleInput = input.string("Dotted", "Sweep Line Style", options = ["Solid", "Dashed", "Dotted"], tooltip = "Line style used between the swing origin and rejection candle.", group = "Appearance")
labelSizeInput = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], tooltip = "Size of the Turtle Soup marker.", group = "Appearance")
labelTimeframeInput = input.bool(true, "Label HTF Timeframe", tooltip = "Prefix higher-timeframe marker text with its timeframe.", group = "Appearance")
extendSoupLineInput = input.bool(true, "Extend Level While Armed", tooltip = "Carry each swept level forward for as long as that soup can still produce an entry. The line stops where the soup stopped being eligible — because it expired, or because a gap fired from it.\n\nThis is what makes an entry traceable to the soup behind it: if a signal fires with no live level reaching it, it did not come from a soup you can see.", group = "Appearance")

showFvgsInput = input.bool(true, "Show FVGs", tooltip = "Display detected fair value gap zones.", group = "FVG / IFVG")
showIfvgsInput = input.bool(true, "Show IFVGs", tooltip = "Keep invalidated FVGs as inverse fair value gap zones until mitigated.", group = "FVG / IFVG")
fvgMinAtrInput = input.float(0.5, "FVG Min ATR Multiplier", minval = 0.0, step = 0.1, tooltip = "Minimum three-candle gap size as a multiple of ATR(14). Set to 0 to accept every qualifying gap.", group = "FVG / IFVG")
maxFvgZonesInput = input.int(15, "Max Active FVGs / IFVGs", minval = 1, maxval = 100, tooltip = "Maximum number of FVG and IFVG boxes retained. Oldest inactive zones are removed first.", group = "FVG / IFVG")
filterFvgOverlapInput = input.bool(true, "Filter Overlapping FVGs / IFVGs", tooltip = "Reject a new gap or inversion when it overlaps an existing zone with the same effective direction.", group = "FVG / IFVG")
fvgExtendBarsInput = input.int(5, "Zone Extension (Bars)", minval = 0, maxval = 100, tooltip = "How far each unmitigated FVG or IFVG box extends beyond the latest bar.", group = "FVG / IFVG")
fvgBullColorInput = input.color(color.new(#089981, 80), "Bullish FVG", tooltip = "Fill color for bullish fair value gaps.", group = "FVG / IFVG")
fvgBearColorInput = input.color(color.new(#f23645, 80), "Bearish FVG", tooltip = "Fill color for bearish fair value gaps.", group = "FVG / IFVG")
ifvgBullColorInput = input.color(color.new(#089981, 80), "Bullish IFVG", tooltip = "Fill color for bullish inverse fair value gaps.", group = "FVG / IFVG")
ifvgBearColorInput = input.color(color.new(#f23645, 80), "Bearish IFVG", tooltip = "Fill color for bearish inverse fair value gaps.", group = "FVG / IFVG")
fvgTextColorInput = input.color(color.black, "FVG Text Color", tooltip = "Text color for FVG labels.", group = "FVG / IFVG")
ifvgTextColorInput = input.color(color.black, "IFVG Text Color", tooltip = "Text color for IFVG labels.", group = "FVG / IFVG")
fvgTextSizeInput = input.string("Small", "Zone Label Size", options = ["Tiny", "Small", "Normal"], tooltip = "Text size for FVG and IFVG labels inside each box.", group = "FVG / IFVG")

entryWindowBarsInput = input.int(10, "Entry Window After Turtle Soup (Chart Bars)", minval = 1, maxval = 2000, tooltip = "How many CHART bars a Turtle Soup stays eligible for a later FVG/IFVG entry, whatever timeframe produced it.\n\nThe gap has to be a reaction to the sweep. Counted in the source timeframe's own bars instead, a higher-timeframe soup stays armed for hours and fires on a gap that has nothing to do with it.", group = "FVG / IFVG")
entryClearanceTicksInput = input.int(0, "Entry Gap Clearance (Ticks)", minval = 0, maxval = 1000, tooltip = "The entire entry FVG/IFVG must be this far beyond the swept Turtle Soup level, in the reversal direction.", group = "FVG / IFVG")
showEntryLabelsInput = input.bool(true, "Show Entry Labels", tooltip = "Label only a qualifying FVG/IFVG that forms after a Turtle Soup and clears its swept level in the reversal direction.", group = "FVG / IFVG")
maxEntryLabelsInput = input.int(50, "Max Entry Labels", minval = 1, maxval = 200, tooltip = "Maximum number of FVG/IFVG entry labels retained.", group = "FVG / IFVG")
bullEntryColorInput = input.color(#089981, "Bullish Entry Label", tooltip = "Label background color for long FVG/IFVG entries.", group = "FVG / IFVG")
bearEntryColorInput = input.color(#f23645, "Bearish Entry Label", tooltip = "Label background color for short FVG/IFVG entries.", group = "FVG / IFVG")
entryLabelSizeInput = input.string("Small", "Entry Label Size", options = ["Tiny", "Small", "Normal"], tooltip = "Text size for long and short entry labels.", group = "FVG / IFVG")

grpCisd = "Delivery (CISD)"
showCisdLineInput = input.bool(true, "Show Latest CISD Level", tooltip = "Mark the most recent change in the state of delivery with a dotted line at the level that was reclaimed, extending to the right.", group = grpCisd)
cisdMinRunInput = input.int(2, "Minimum Run Length (Bars)", minval = 1, maxval = 10, tooltip = "How many consecutive same-direction closes count as a delivery leg before its opening becomes a reference.\n\nAt 1 every alternating candle creates a new level and the state flips constantly, which makes the filter below meaningless. Raising it asks for a real leg before anything is reclaimed.", group = grpCisd)
cisdBreakAtrInput = input.float(0.0, "Reclaim Clearance (ATR)", minval = 0.0, step = 0.05, tooltip = "Extra distance beyond the opening the close must clear, as a multiple of ATR(30).\n\nZero by default, and that is the point of CISD: the reference is a body level price is already sitting near, so demanding clearance gives back the speed that makes it worth using. Raise it only if the state flips too readily.", group = grpCisd)
cisdLabelOffsetInput = input.int(2, "    ↳ CISD Label Offset (Bars)", minval = 0, maxval = 60, group = grpCisd)
useCisdFilterInput = input.bool(true, "Hold Entries Against Delivery", tooltip = "A turtle soup is a counter-trend entry, and its main way of failing is that the breakout it faded was real.\n\nWith this on, a signal fired while delivery still runs the other way is HELD rather than taken, and released once delivery changes state. A delay, not a block.\n\nCISD is used here rather than a swing break because its reference sits close to the sweep, so a held trade gives up far less of its stop distance waiting.", group = grpCisd)
holdWindowInput = input.int(30, "    ↳ Hold Window (Bars)", minval = 1, maxval = 500, tooltip = "How long a held signal waits for its condition. Its own budget, counted from the bar it was held, on top of the entry window.\n\nA signal released much later would be using a stop reference from a sweep price has long since left.", group = grpCisd)

grpTrade = "Trade Levels"
showTradeLevelsInput = input.bool(true, "Show SL / BE / TP", tooltip = "Draw a stop, breakeven and target for the tracked entry and manage them bar by bar.\n\nOne set of levels is drawn at a time and the most recent entry signal always owns it. A signal arriving while a trade is still live re-anchors the lines to itself, so what is on the chart is always the setup currently in play — the trade it replaced is abandoned rather than resolved, and no stop or target alert follows for it.", group = grpTrade)
slBufferTicksInput = input.int(8, "Stop Buffer (Ticks)", minval = 0, maxval = 1000, tooltip = "Places the stop this many minimum ticks beyond the sweep extreme.", group = grpTrade)
tpRInput = input.float(1.0, "Take Profit (R)", minval = 0.1, maxval = 10.0, step = 0.1, tooltip = "Target as a multiple of the measured risk. A turtle soup is a snap-back off a swept level rather than a trend entry, so 1R is the default.", group = grpTrade)
showContractsInput = input.bool(true, "Contract Count on Entry Label", tooltip = "Show how many contracts this trade's stop distance allows at the risk below.\n\nIt is arithmetic, not a quality judgement — two signals that look identical can be a full position and a quarter of one, and that difference is invisible from the stop line alone.", group = grpTrade)
showEntryLinkInput = input.bool(true, "Link Entry to Its Turtle Soup", tooltip = "Draw a line from each entry back to the swept level that produced it.\n\nThe turtle is drawn at that level\u2019s PRICE, which for a slower timeframe can be far above or below where the entry fires and therefore off the visible chart. This line always points at it: follow it off the top or bottom of the window and the soup is at the other end.\n\nIf a line ever ends somewhere with no turtle, that is a defect worth reporting.", group = grpTrade)
showEntryTfInput = input.bool(true, "Source Timeframe on Entry Label", tooltip = "Tag each entry with the timeframe of the soup that produced it.\n\nThe turtle is drawn at the SWEPT LEVEL\u2019s price, so a 4-hour soup sits wherever that 4-hour swing was — often far above or below where the entry fires, and out of view on a 1-minute chart. The tag says which turtle to go looking for.", group = grpTrade)
riskPerTradeInput = input.float(250, "    ↳ Risk Per Trade ($)", minval = 1, step = 25, tooltip = "The dollar risk the contract count is worked out from. Uses the instrument's own point value, so it is correct on any symbol.", group = grpTrade)
beFracInput = input.float(0.5, "Breakeven at Fraction of Target", minval = 0.0, maxval = 0.95, step = 0.05, tooltip = "Move the stop to entry once price covers this fraction of the distance to target. Set to 0 to turn breakeven off.\n\nMeasured against the target rather than as a fixed R, so at the default 1R target this sits at 0.5R and still means halfway if the target is changed.", group = grpTrade)

grpSess = "Sessions"
useSessInput = input.bool(true, "Gate by Session", tooltip = "Levels, sweeps and gaps are tracked around the clock, so a soup that forms overnight is correct the moment a window opens.\n\nWhat the gate stops is output: no entry label is drawn outside the windows and no alert of any kind is sent outside them.", group = grpSess)
sess1Input = input.session("1800-0000", "Window 1 (New York)", group = grpSess)
sess2Input = input.session("0700-1600", "Window 2 (New York)", group = grpSess)

grpNext = "Next Liquidity"
showNextLiqInput = input.bool(true, "Show Nearest Unbroken Levels", tooltip = "The nearest unbroken swing high above price and swing low below it, for each enabled timeframe — the closest places a turtle soup could form.\n\nOnly the nearest one either side per timeframe is drawn. Every tracked level would be hundreds of lines; these are the handful price can actually reach next.\n\nThe only part of this indicator that says anything before the event rather than after it.", group = grpNext)
nextLiqColorInput = input.color(color.black, "    ↳ Color", group = grpNext)
nextLiqWidthInput = input.int(2, "    ↳ Line Width", minval = 1, maxval = 4, group = grpNext)
nextLiqStubInput = input.int(12, "    ↳ Extend Past Price (Bars)", minval = 2, maxval = 100, tooltip = "Drawn as a short stub forward from the current bar rather than a line across the chart, so ten of them stay quiet.", group = grpNext)
nextLiqCrowdTicksInput = input.int(12, "    ↳ Crowded Within (Ticks)", minval = 0, maxval = 400, tooltip = "Levels closer together than this are treated as one and share a single line and label, with every contributing timeframe named on it.\n\nSeveral timeframes agreeing on a price is worth seeing — but as one level with three names, not three levels.", group = grpNext)

grpKey = "Session Levels"
showPdInput = input.bool(true, "Previous Day High / Low", group = grpKey)
showPwInput = input.bool(true, "Previous Week High / Low", group = grpKey)
keyColorInput = input.color(#9598a1, "    ↳ Color", group = grpKey)
keyWidthInput = input.int(2, "    ↳ Line Width", minval = 1, maxval = 4, group = grpKey)
keyExtendBarsInput = input.int(3, "    ↳ Extend Past Price (Bars)", minval = 0, maxval = 60, tooltip = "How far past the last bar each level is drawn. The label starts after that, so the two never overlap.", group = grpKey)

grpAlerts = "Alerts"
alertEntriesInput = input.bool(true, "Entry Signals", tooltip = "Carried on one dynamic message, so a single TradingView alert set to \"Any alert() function call\" covers both directions. Named conditions remain available for one side on its own.", group = grpAlerts)
alertBeTapInput = input.bool(true, "Breakeven Reached", tooltip = "Fires when price covers the breakeven fraction, which is the moment the stop should be moved to entry.", group = grpAlerts)
alertBeStopTapInput = input.bool(true, "Stopped at Breakeven", tooltip = "A scratch rather than a loss. Separate from the stop alert because the two are the same event on the chart and completely different to the account.", group = grpAlerts)
alertStopTapInput = input.bool(true, "Stop Loss Touched", group = grpAlerts)
alertTpTapInput = input.bool(true, "Take Profit Touched", group = grpAlerts)

// --- Sessions and session levels ---
bool inSess1 = not na(time(timeframe.period, sess1Input, "America/New_York"))
bool inSess2 = not na(time(timeframe.period, sess2Input, "America/New_York"))
bool inSession = not useSessInput or inSess1 or inSess2

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// --- Storage ---
var array<line> markerLines = array.new<line>()
var array<label> markerLabels = array.new<label>()
var array<float> markerLevels = array.new<float>()
var array<int> markerDirections = array.new<int>()
var array<int> markerSlots = array.new<int>()
var array<int> markerEventTimes = array.new<int>()
// The bar a marker's setup stops being eligible, so its level can be carried
// forward for exactly as long as an entry could still come from it.
var array<int> markerArmedUntil = array.new<int>()
// Whether this soup already produced an entry. One that did is history and is
// never removed afterwards — see the invalidation block.
var array<bool> markerFired = array.new<bool>()
var array<int> setupDirections = array.new<int>()
var array<float> setupLevels = array.new<float>()
var array<float> setupExtremes = array.new<float>()
var array<int> setupCreatedBars = array.new<int>()
var array<int> setupSlots = array.new<int>()
var array<int> setupEventTimes = array.new<int>()
var array<string> setupTimeframes = array.new<string>()
var array<label> entryLabels = array.new<label>()
var array<line> entryLinks = array.new<line>()

type FvgZone
    box zoneBox
    bool isBull
    bool active
    float top
    float bottom

var array<FvgZone> fvgZones = array.new<FvgZone>()

f_fvgOverlap(float zoneTop, float zoneBottom, bool candidateBull, int ignoredIndex) =>
    bool overlaps = false
    if filterFvgOverlapInput and array.size(fvgZones) > 0
        for zoneIndex = 0 to array.size(fvgZones) - 1
            if zoneIndex != ignoredIndex
                FvgZone existingZone = array.get(fvgZones, zoneIndex)
                bool existingBull = existingZone.active ? existingZone.isBull : not existingZone.isBull
                bool intersects = zoneBottom <= existingZone.top and zoneTop >= existingZone.bottom
                if existingBull == candidateBull and intersects
                    overlaps := true
    overlaps

f_removeSetupAt(int setupIndex) =>
    array.remove(setupDirections, setupIndex)
    array.remove(setupLevels, setupIndex)
    array.remove(setupExtremes, setupIndex)
    array.remove(setupCreatedBars, setupIndex)
    array.remove(setupSlots, setupIndex)
    array.remove(setupEventTimes, setupIndex)
    array.remove(setupTimeframes, setupIndex)

f_removeSetupForEvent(int slot, int sourceEventTime) =>
    int setupIndex = array.size(setupDirections) - 1
    while setupIndex >= 0
        bool matchingSetup = array.get(setupSlots, setupIndex) == slot and array.get(setupEventTimes, setupIndex) == sourceEventTime
        if matchingSetup
            f_removeSetupAt(setupIndex)
        setupIndex -= 1

// A soup consumed by an entry is no longer armed, so its level stops here
// rather than running to the end of a window it never reached.
f_disarmMarker(int slot, int sourceEventTime) =>
    int markerIndex = 0
    while markerIndex < array.size(markerSlots)
        if array.get(markerSlots, markerIndex) == slot and array.get(markerEventTimes, markerIndex) == sourceEventTime
            array.set(markerArmedUntil, markerIndex, bar_index)
            array.set(markerFired, markerIndex, true)
        markerIndex += 1

f_registerSetup(int direction, float level, int slot, int sourceEventTime, string tf, float sweepExtreme) =>
    array.push(setupDirections, direction)
    array.push(setupLevels, level)
    // Falls back to the swept level when the source timeframe reported no
    // extreme, so a stop is always anchored to something rather than to na.
    array.push(setupExtremes, na(sweepExtreme) ? level : sweepExtreme)
    array.push(setupCreatedBars, bar_index)
    array.push(setupSlots, slot)
    array.push(setupEventTimes, sourceEventTime)
    array.push(setupTimeframes, tf)
    while array.size(setupDirections) > maxSweepsInput
        f_removeSetupAt(0)

f_findEntrySetup(int entryDirection, float zoneTop, float zoneBottom) =>
    int matchedIndex = -1
    int latestSetupBar = -1
    string matchedTimeframe = ""
    float matchedExtreme = na
    int matchedSlot = -1
    int matchedEventTime = na
    float matchedSoupLevel = na
    float minClearance = entryClearanceTicksInput * syminfo.mintick
    int setupIndex = 0
    while setupIndex < array.size(setupDirections)
        int setupDirection = array.get(setupDirections, setupIndex)
        int setupBar = array.get(setupCreatedBars, setupIndex)
        float setupLevel = array.get(setupLevels, setupIndex)
        int barsSinceSetup = bar_index - setupBar
        bool clearOfSoup = entryDirection == 1 ? zoneBottom > setupLevel + minClearance : zoneTop < setupLevel - minClearance
        bool eligible = setupDirection == entryDirection and barsSinceSetup > 0 and barsSinceSetup <= entryWindowBarsInput and clearOfSoup
        if eligible and setupBar > latestSetupBar
            matchedIndex := setupIndex
            latestSetupBar := setupBar
            matchedTimeframe := array.get(setupTimeframes, setupIndex)
            matchedExtreme := array.get(setupExtremes, setupIndex)
            matchedSlot := array.get(setupSlots, setupIndex)
            matchedEventTime := array.get(setupEventTimes, setupIndex)
            matchedSoupLevel := array.get(setupLevels, setupIndex)
        setupIndex += 1
    [matchedIndex, matchedTimeframe, matchedExtreme, matchedSlot, matchedEventTime, matchedSoupLevel]

// --- Detection ---
f_scanSweeps(simple int pivotLen) =>
    float pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
    float pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
    var array<float> swingHighLevels = array.new<float>()
    var array<int> swingHighTimes = array.new<int>()
    var array<float> swingLowLevels = array.new<float>()
    var array<int> swingLowTimes = array.new<int>()
    int eventDirection = 0
    float eventLevel = na
    int eventOriginTime = na
    int eventTime = na
    // How far the sweep actually ran past the level, measured on the timeframe
    // that produced it. This is the stop reference: the swept level itself is
    // no good, because price traded through it by definition.
    float eventExtreme = na
    if barstate.isconfirmed
        int highIndex = array.size(swingHighLevels) - 1
        while highIndex >= 0
            float level = array.get(swingHighLevels, highIndex)
            int origin = array.get(swingHighTimes, highIndex)
            if high > level
                if close < level and (na(eventOriginTime) or origin > eventOriginTime)
                    eventDirection := -1
                    eventLevel := level
                    eventOriginTime := origin
                    eventTime := time
                    eventExtreme := high
                array.remove(swingHighLevels, highIndex)
                array.remove(swingHighTimes, highIndex)
            highIndex -= 1
        int lowIndex = array.size(swingLowLevels) - 1
        while lowIndex >= 0
            float level = array.get(swingLowLevels, lowIndex)
            int origin = array.get(swingLowTimes, lowIndex)
            if low < level
                if close > level and (na(eventOriginTime) or origin > eventOriginTime)
                    eventDirection := 1
                    eventLevel := level
                    eventOriginTime := origin
                    eventTime := time
                    eventExtreme := low
                array.remove(swingLowLevels, lowIndex)
                array.remove(swingLowTimes, lowIndex)
            lowIndex -= 1
        if not na(pivotHigh)
            array.push(swingHighLevels, pivotHigh)
            array.push(swingHighTimes, time[pivotLen])
            while array.size(swingHighLevels) > maxActiveLevelsInput
                array.shift(swingHighLevels)
                array.shift(swingHighTimes)
        if not na(pivotLow)
            array.push(swingLowLevels, pivotLow)
            array.push(swingLowTimes, time[pivotLen])
            while array.size(swingLowLevels) > maxActiveLevelsInput
                array.shift(swingLowLevels)
                array.shift(swingLowTimes)
    // The closest unbroken level either side of price: where the next sweep on
    // this timeframe would have to happen. Computed outside the confirmed-bar
    // block so it is available on every bar, not only when something changed.
    // Each one's ORIGIN time comes out too, so the level can be drawn from the
    // swing that created it rather than from an arbitrary point beside price.
    float nearestUp = na
    int nearestUpTime = na
    float nearestDn = na
    int nearestDnTime = na
    int upIndex = 0
    while upIndex < array.size(swingHighLevels)
        float lvl = array.get(swingHighLevels, upIndex)
        if lvl > close and (na(nearestUp) or lvl < nearestUp)
            nearestUp := lvl
            nearestUpTime := array.get(swingHighTimes, upIndex)
        upIndex += 1
    int dnIndex = 0
    while dnIndex < array.size(swingLowLevels)
        float lvl = array.get(swingLowLevels, dnIndex)
        if lvl < close and (na(nearestDn) or lvl > nearestDn)
            nearestDn := lvl
            nearestDnTime := array.get(swingLowTimes, dnIndex)
        dnIndex += 1
    [eventDirection, eventLevel, eventOriginTime, eventTime, eventExtreme, nearestUp, nearestUpTime, nearestDn, nearestDnTime]

f_scanPreviousBar(simple int pivotLen) =>
    [direction, level, originTime, eventTime, extreme, up, upT, dn, dnT] = f_scanSweeps(pivotLen)
    [direction[1], level[1], originTime[1], eventTime[1], extreme[1], up[1], upT[1], dn[1], dnT[1]]

f_timeframeLabel(string tf) =>
    float seconds = timeframe.in_seconds(tf)
    string result = tf
    if not na(seconds)
        if seconds < 3600
            result := str.tostring(int(seconds / 60)) + "m"
        else if seconds < 86400
            result := str.tostring(int(seconds / 3600)) + "h"
        else if seconds < 604800
            result := str.tostring(int(seconds / 86400)) + "D"
        else if seconds < 2592000
            result := str.tostring(int(seconds / 604800)) + "W"
        else
            result := str.tostring(int(seconds / 2592000)) + "M"
    result

// The stop reference is passed in rather than read from the global, because the
// label is drawn at the signal site before that global is assigned.
f_addEntryLabel(int direction, float stopRef, string soupTf, float soupLevel, int soupTime) =>
    // Drawn before the label and on its own toggle, so it survives turning the
    // labels off and is the one thing that always ties a signal to its cause.
    if showEntryLinkInput and not na(soupLevel) and not na(soupTime)
        array.push(entryLinks, line.new(soupTime, soupLevel, time, close, xloc = xloc.bar_time, color = color.new(direction == 1 ? bullEntryColorInput : bearEntryColorInput, 45), style = line.style_dotted, width = 1))
        while array.size(entryLinks) > maxEntryLabelsInput
            line.delete(array.shift(entryLinks))
    if showEntryLabelsInput
        color entryColor = direction == 1 ? bullEntryColorInput : bearEntryColorInput
        string entryText = ""
        if showEntryTfInput and soupTf != ""
            entryText := f_timeframeLabel(soupTf)
        if showContractsInput and not na(stopRef)
            // Same arithmetic the trade layer uses, so the number on the label
            // and the stop line drawn beneath it can never disagree.
            float bufferPrice = slBufferTicksInput * syminfo.mintick
            float rawStop = direction == 1 ? stopRef - bufferPrice : stopRef + bufferPrice
            float stopPrice = direction == 1 ? math.min(rawStop, close - syminfo.mintick) : math.max(rawStop, close + syminfo.mintick)
            float riskPerContract = math.abs(close - stopPrice) * syminfo.pointvalue
            if riskPerContract > 0
                float contracts = math.floor(riskPerTradeInput / riskPerContract)
                // Under one contract is not zero contracts, it is a stop too wide
                // to take at this risk. Printed as 0 it reads like a fault in the
                // arithmetic rather than a fact about the trade.
                entryText := entryText + (entryText == "" ? "" : " · ") + (contracts < 1 ? "<1" : str.tostring(contracts, "#"))
        entrySize = entryLabelSizeInput == "Tiny" ? size.tiny : entryLabelSizeInput == "Normal" ? size.normal : size.small
        label entryLabel = label.new(x = bar_index, y = direction == 1 ? low : high, text = entryText, xloc = xloc.bar_index, yloc = direction == 1 ? yloc.belowbar : yloc.abovebar, style = direction == 1 ? label.style_label_up : label.style_label_down, color = entryColor, textcolor = color.white, size = entrySize)
        array.push(entryLabels, entryLabel)
        while array.size(entryLabels) > maxEntryLabelsInput
            label oldestEntry = array.shift(entryLabels)
            label.delete(oldestEntry)

f_addMarker(int direction, float level, int originTime, int sweepTime, string tf, int slot, int sweepCloseOffsetMs) =>
    // A higher-timeframe sweep is not confirmed until its bar CLOSES, but the
    // bar's timestamp is its open. Drawn at the raw timestamp, a 15-minute
    // turtle lands fifteen chart bars left of the point the setup actually goes
    // live, and every entry it produces then looks unrelated to it.
    int markerTime = sweepTime + sweepCloseOffsetMs
    color drawColor = markerColorInput
    lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted
    markerSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge
    string markerText = slot > 0 and labelTimeframeInput ? f_timeframeLabel(tf) + " " + markerTextInput : markerTextInput
    line markerLine = line.new(x1 = originTime, y1 = level, x2 = markerTime, y2 = level, xloc = xloc.bar_time, color = drawColor, style = lineStyle, width = 1)
    label markerLabel = label.new(x = markerTime, y = level, text = markerText, xloc = xloc.bar_time, style = label.style_label_center, color = color.new(drawColor, 100), textcolor = drawColor, size = markerSize)
    array.push(markerLines, markerLine)
    array.push(markerLabels, markerLabel)
    array.push(markerLevels, level)
    array.push(markerDirections, direction)
    array.push(markerSlots, slot)
    array.push(markerEventTimes, sweepTime)
    array.push(markerArmedUntil, bar_index + entryWindowBarsInput)
    array.push(markerFired, false)
    while array.size(markerLines) > maxSweepsInput
        line oldestLine = array.shift(markerLines)
        label oldestLabel = array.shift(markerLabels)
        line.delete(oldestLine)
        label.delete(oldestLabel)
        array.shift(markerLevels)
        array.shift(markerDirections)
        array.shift(markerSlots)
        array.shift(markerEventTimes)
        array.shift(markerArmedUntil)
        array.shift(markerFired)

// --- Scan current timeframe and configured higher timeframes ---
[curDirection, curLevel, curOriginTime, curEventTime, curExtreme, curNextUp, curNextUpTime, curNextDn, curNextDnTime] = f_scanSweeps(chartPivotLenInput)
[htf1Direction, htf1Level, htf1OriginTime, htf1EventTime, htf1Extreme, htf1NextUp, htf1NextUpTime, htf1NextDn, htf1NextDnTime] = request.security(syminfo.tickerid, htf1Input, f_scanPreviousBar(htfPivotLenInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[htf2Direction, htf2Level, htf2OriginTime, htf2EventTime, htf2Extreme, htf2NextUp, htf2NextUpTime, htf2NextDn, htf2NextDnTime] = request.security(syminfo.tickerid, htf2Input, f_scanPreviousBar(htfPivotLenInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[htf3Direction, htf3Level, htf3OriginTime, htf3EventTime, htf3Extreme, htf3NextUp, htf3NextUpTime, htf3NextDn, htf3NextDnTime] = request.security(syminfo.tickerid, htf3Input, f_scanPreviousBar(htfPivotLenInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[htf4Direction, htf4Level, htf4OriginTime, htf4EventTime, htf4Extreme, htf4NextUp, htf4NextUpTime, htf4NextDn, htf4NextDnTime] = request.security(syminfo.tickerid, htf4Input, f_scanPreviousBar(htfPivotLenInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[htf5Direction, htf5Level, htf5OriginTime, htf5EventTime, htf5Extreme, htf5NextUp, htf5NextUpTime, htf5NextDn, htf5NextDnTime] = request.security(syminfo.tickerid, htf5Input, f_scanPreviousBar(htfPivotLenInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

float chartSeconds = timeframe.in_seconds()
// Each higher timeframe's bar length in milliseconds, so a marker can be placed
// at the close of the bar that produced it rather than at its open.
int htf1CloseOffset = int(timeframe.in_seconds(htf1Input)) * 1000
int htf2CloseOffset = int(timeframe.in_seconds(htf2Input)) * 1000
int htf3CloseOffset = int(timeframe.in_seconds(htf3Input)) * 1000
int htf4CloseOffset = int(timeframe.in_seconds(htf4Input)) * 1000
int htf5CloseOffset = int(timeframe.in_seconds(htf5Input)) * 1000

// A soup's stored event time is its source bar's OPEN. The turtle is drawn at
// that bar's close, so anything else pointing at the soup has to apply the same
// shift or it lands a full higher-timeframe bar to the left of the marker.
f_slotMarkerTime(int rawTime, int slot) =>
    int off = slot == 1 ? htf1CloseOffset : slot == 2 ? htf2CloseOffset : slot == 3 ? htf3CloseOffset : slot == 4 ? htf4CloseOffset : slot == 5 ? htf5CloseOffset : 0
    na(rawTime) ? na : rawTime + off

bool useHtf1 = showHtf1Input and timeframe.in_seconds(htf1Input) > chartSeconds
bool useHtf2 = showHtf2Input and timeframe.in_seconds(htf2Input) > chartSeconds
bool useHtf3 = showHtf3Input and timeframe.in_seconds(htf3Input) > chartSeconds
bool useHtf4 = showHtf4Input and timeframe.in_seconds(htf4Input) > chartSeconds
bool useHtf5 = showHtf5Input and timeframe.in_seconds(htf5Input) > chartSeconds
float htf1ConfirmedClose = request.security(syminfo.tickerid, htf1Input, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float htf2ConfirmedClose = request.security(syminfo.tickerid, htf2Input, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float htf3ConfirmedClose = request.security(syminfo.tickerid, htf3Input, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float htf4ConfirmedClose = request.security(syminfo.tickerid, htf4Input, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float htf5ConfirmedClose = request.security(syminfo.tickerid, htf5Input, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
bool htf1Rolled = timeframe.change(htf1Input)
bool htf2Rolled = timeframe.change(htf2Input)
bool htf3Rolled = timeframe.change(htf3Input)
bool htf4Rolled = timeframe.change(htf4Input)
bool htf5Rolled = timeframe.change(htf5Input)

// --- Event deduplication and marker creation ---
var int lastCurEventTime = na
var int lastHtf1EventTime = na
var int lastHtf2EventTime = na
var int lastHtf3EventTime = na
var int lastHtf4EventTime = na
var int lastHtf5EventTime = na

if showCurrentInput and curDirection != 0 and not na(curEventTime) and (na(lastCurEventTime) or curEventTime != lastCurEventTime)
    lastCurEventTime := curEventTime
    if showMarkersInput
        f_addMarker(curDirection, curLevel, curOriginTime, curEventTime, timeframe.period, 0, 0)
    f_registerSetup(curDirection, curLevel, 0, curEventTime, timeframe.period, curExtreme)
if useHtf1 and htf1Direction != 0 and not na(htf1EventTime) and (na(lastHtf1EventTime) or htf1EventTime != lastHtf1EventTime)
    lastHtf1EventTime := htf1EventTime
    if showMarkersInput
        f_addMarker(htf1Direction, htf1Level, htf1OriginTime, htf1EventTime, htf1Input, 1, htf1CloseOffset)
    f_registerSetup(htf1Direction, htf1Level, 1, htf1EventTime, htf1Input, htf1Extreme)
if useHtf2 and htf2Direction != 0 and not na(htf2EventTime) and (na(lastHtf2EventTime) or htf2EventTime != lastHtf2EventTime)
    lastHtf2EventTime := htf2EventTime
    if showMarkersInput
        f_addMarker(htf2Direction, htf2Level, htf2OriginTime, htf2EventTime, htf2Input, 2, htf2CloseOffset)
    f_registerSetup(htf2Direction, htf2Level, 2, htf2EventTime, htf2Input, htf2Extreme)
if useHtf3 and htf3Direction != 0 and not na(htf3EventTime) and (na(lastHtf3EventTime) or htf3EventTime != lastHtf3EventTime)
    lastHtf3EventTime := htf3EventTime
    if showMarkersInput
        f_addMarker(htf3Direction, htf3Level, htf3OriginTime, htf3EventTime, htf3Input, 3, htf3CloseOffset)
    f_registerSetup(htf3Direction, htf3Level, 3, htf3EventTime, htf3Input, htf3Extreme)
if useHtf4 and htf4Direction != 0 and not na(htf4EventTime) and (na(lastHtf4EventTime) or htf4EventTime != lastHtf4EventTime)
    lastHtf4EventTime := htf4EventTime
    if showMarkersInput
        f_addMarker(htf4Direction, htf4Level, htf4OriginTime, htf4EventTime, htf4Input, 4, htf4CloseOffset)
    f_registerSetup(htf4Direction, htf4Level, 4, htf4EventTime, htf4Input, htf4Extreme)
if useHtf5 and htf5Direction != 0 and not na(htf5EventTime) and (na(lastHtf5EventTime) or htf5EventTime != lastHtf5EventTime)
    lastHtf5EventTime := htf5EventTime
    if showMarkersInput
        f_addMarker(htf5Direction, htf5Level, htf5OriginTime, htf5EventTime, htf5Input, 5, htf5CloseOffset)
    f_registerSetup(htf5Direction, htf5Level, 5, htf5EventTime, htf5Input, htf5Extreme)

// --- Remove rejected sweeps if a later confirmed close invalidates the level ---
if barstate.isconfirmed and array.size(markerLines) > 0
    int markerIndex = array.size(markerLines) - 1
    while markerIndex >= 0
        int markerSlot = array.get(markerSlots, markerIndex)
        int markerEventTime = array.get(markerEventTimes, markerIndex)
        int markerDirection = array.get(markerDirections, markerIndex)
        float markerLevel = array.get(markerLevels, markerIndex)
        bool checkClose = markerSlot == 0 or (markerSlot == 1 and htf1Rolled) or (markerSlot == 2 and htf2Rolled) or (markerSlot == 3 and htf3Rolled) or (markerSlot == 4 and htf4Rolled) or (markerSlot == 5 and htf5Rolled)
        float sourceClose = markerSlot == 0 ? close : markerSlot == 1 ? htf1ConfirmedClose : markerSlot == 2 ? htf2ConfirmedClose : markerSlot == 3 ? htf3ConfirmedClose : markerSlot == 4 ? htf4ConfirmedClose : htf5ConfirmedClose
        // A soup that already produced an entry is not removed. Invalidation
        // exists to clear sweeps that failed BEFORE they did anything; applied
        // after the fact it deletes the turtle while its entry label stays put,
        // leaving a signal on the chart with no visible soup behind it.
        bool invalidated = not array.get(markerFired, markerIndex) and checkClose and (markerDirection == 1 ? sourceClose < markerLevel : sourceClose > markerLevel)
        if invalidated
            f_removeSetupForEvent(markerSlot, markerEventTime)
            line.delete(array.get(markerLines, markerIndex))
            label.delete(array.get(markerLabels, markerIndex))
            array.remove(markerLines, markerIndex)
            array.remove(markerLabels, markerIndex)
            array.remove(markerLevels, markerIndex)
            array.remove(markerDirections, markerIndex)
            array.remove(markerSlots, markerIndex)
            array.remove(markerEventTimes, markerIndex)
            array.remove(markerArmedUntil, markerIndex)
            array.remove(markerFired, markerIndex)
        markerIndex -= 1

// --- Carry each armed level forward ---
// The right end of a swept level is where that soup stopped being able to
// produce an entry. A signal with no live level reaching it did not come from
// any soup still on the chart.
if barstate.isconfirmed and extendSoupLineInput and array.size(markerLines) > 0
    int armIndex = 0
    while armIndex < array.size(markerLines)
        if bar_index <= array.get(markerArmedUntil, armIndex)
            line.set_x2(array.get(markerLines, armIndex), time)
        armIndex += 1

// ============================================================
//              CHANGE IN STATE OF DELIVERY
// ============================================================
// A delivery leg is a run of consecutive same-direction closes. Its OPENING is
// the reference: price closing back through it means whatever was delivering
// that way has stopped and the other side is in control.
//
// This is a body level a few candles back rather than a swing extreme, which is
// the whole reason it is used here instead of a break of structure. A swing is
// wherever the last swing happens to be, does not exist until its pivot
// confirms, and is usually a long way from a sweep. The opening of the leg that
// just moved price is close to it, so confirmation costs little stop distance.
//
// Computed before the entry logic so a change printing on this bar is visible to
// the filter on the same bar.
float cisdAtr = ta.atr(30)
var int cisdRunDir = 0
var int cisdRunLen = 0
var float cisdRunOpen = na
var float lastUpLegOpen = na
var float lastDownLegOpen = na
var int cisdState = 0
var int cisdBreakBar = na
var float cisdBreakLevel = na
var line cisdLine = na
var label cisdLabel = na
var int cisdDrawnBar = na

// Track the current leg. A leg only becomes a reference once it is long enough
// to be delivery rather than a single candle.
if barstate.isconfirmed
    int barDir = close > open ? 1 : close < open ? -1 : 0
    if barDir != 0
        if barDir == cisdRunDir
            cisdRunLen += 1
        else
            cisdRunDir := barDir
            cisdRunLen := 1
            cisdRunOpen := open
        if cisdRunLen >= cisdMinRunInput
            if cisdRunDir == 1
                lastUpLegOpen := cisdRunOpen
            else
                lastDownLegOpen := cisdRunOpen

float cisdClearance = cisdAtr * cisdBreakAtrInput
bool bullCisd = barstate.isconfirmed and not na(lastDownLegOpen) and close > lastDownLegOpen + cisdClearance
bool bearCisd = barstate.isconfirmed and not na(lastUpLegOpen) and close < lastUpLegOpen - cisdClearance

// Reclaiming the SAME opening again is the change already recorded, not a new
// one, so the level has to move for the state to re-latch.
if bullCisd and (cisdState != 1 or na(cisdBreakLevel) or lastDownLegOpen != cisdBreakLevel)
    cisdState := 1
    cisdBreakBar := bar_index
    cisdBreakLevel := lastDownLegOpen
else if bearCisd and (cisdState != -1 or na(cisdBreakLevel) or lastUpLegOpen != cisdBreakLevel)
    cisdState := -1
    cisdBreakBar := bar_index
    cisdBreakLevel := lastUpLegOpen

// The line marks the reclaimed opening, the label says which way delivery
// turned. Both are redrawn only when the change itself moves and just tracked
// forward otherwise — recreating them every bar would churn drawing objects for
// no visible difference.
if not showCisdLineInput
    line.delete(cisdLine)
    label.delete(cisdLabel)
    cisdLine := na
    cisdLabel := na
    cisdDrawnBar := na
else if not na(cisdBreakBar) and (na(cisdDrawnBar) or cisdBreakBar != cisdDrawnBar)
    line.delete(cisdLine)
    label.delete(cisdLabel)
    bool cisdUp = cisdState == 1
    color cisdLineColor = cisdUp ? #089981 : #f23645
    cisdLine := line.new(cisdBreakBar, cisdBreakLevel, bar_index + cisdLabelOffsetInput, cisdBreakLevel, xloc = xloc.bar_index, color = cisdLineColor, style = line.style_dotted, width = 2)
    cisdLabel := label.new(bar_index + cisdLabelOffsetInput, cisdBreakLevel, cisdUp ? "CISD ▲" : "CISD ▼", xloc = xloc.bar_index, color = cisdLineColor, textcolor = color.white, style = label.style_label_left, size = size.tiny)
    cisdDrawnBar := cisdBreakBar
else if not na(cisdLine)
    line.set_x2(cisdLine, bar_index + cisdLabelOffsetInput)
    if not na(cisdLabel)
        label.set_x(cisdLabel, bar_index + cisdLabelOffsetInput)

// A signal that qualified but is waiting on the structure filter. One at a time:
// a newer qualifying gap replaces an older held one, the same way the trade
// lines always belong to the most recent signal.
var int holdDir = 0
var int holdBar = na
var float holdStopRef = na
var string holdGapType = ""
var string holdSoupTf = ""
var float holdSoupLevel = na
var int holdSoupTime = na

// Either delivery already agrees, or the opposing leg's opening has been closed
// back through. A change of state the other way satisfies the first test on its
// own, because it flips the state out of opposition.
bool cisdLongOk = not useCisdFilterInput or cisdState != -1 or (not na(cisdBreakLevel) and close > cisdBreakLevel)
bool cisdShortOk = not useCisdFilterInput or cisdState != 1 or (not na(cisdBreakLevel) and close < cisdBreakLevel)

// --- Entry signals, raised here and emitted with the alerts below ---
bool entryWasHeld = false
bool longEntrySignal = false
bool shortEntrySignal = false
string entryGapType = ""
string entrySoupTf = ""
// The stop reference belonging to whichever setup fired, carried out of the
// detection block so the trade layer below does not have to re-find it.
float entryStopRef = na
bool beTapSignal = false
bool beStopTapSignal = false
bool stopTapSignal = false
bool tpTapSignal = false

// --- Release a held signal ---
// The held stop reference extends for the same reason the pending one does: a
// signal can sit held for many bars while price pushes further past the level,
// and releasing it with the reference frozen puts the stop where price was when
// it was held rather than where it actually got to.
if barstate.isconfirmed and holdDir != 0
    if not na(holdStopRef)
        holdStopRef := holdDir == 1 ? math.min(holdStopRef, low) : math.max(holdStopRef, high)
    if not na(holdBar) and bar_index > holdBar
        if bar_index - holdBar > holdWindowInput
            holdDir := 0
            holdBar := na
            holdStopRef := na
        else if (holdDir == 1 ? cisdLongOk : cisdShortOk) and inSession
            f_addEntryLabel(holdDir, holdStopRef, holdSoupTf, holdSoupLevel, holdSoupTime)
            if holdDir == 1
                longEntrySignal := true
            else
                shortEntrySignal := true
            entryGapType := holdGapType
            entrySoupTf := holdSoupTf
            entryStopRef := holdStopRef
            entryWasHeld := true
            holdDir := 0
            holdBar := na
            holdStopRef := na

// --- FVG / IFVG detection and lifecycle ---
float fvgAtr = ta.atr(14)
float bullGapSize = low - high[2]
float bearGapSize = low[2] - high
bool bullishFvg = low > high[2] and bullGapSize > fvgAtr * fvgMinAtrInput
bool bearishFvg = high < low[2] and bearGapSize > fvgAtr * fvgMinAtrInput

if barstate.isconfirmed
    int expiredSetupIndex = array.size(setupDirections) - 1
    while expiredSetupIndex >= 0
        if bar_index - array.get(setupCreatedBars, expiredSetupIndex) > entryWindowBarsInput
            f_removeSetupAt(expiredSetupIndex)
        expiredSetupIndex -= 1

    // Extend each live setup's excursion extreme. Price can run further past the
    // swept level in the bars between the soup confirming and a gap forming, and
    // a stop placed at the original extreme would already be inside covered
    // ground. These only ever move further out, never back in.
    int excursionIndex = 0
    while excursionIndex < array.size(setupDirections)
        float runningExtreme = array.get(setupExtremes, excursionIndex)
        if array.get(setupDirections, excursionIndex) == 1
            array.set(setupExtremes, excursionIndex, na(runningExtreme) ? low : math.min(runningExtreme, low))
        else
            array.set(setupExtremes, excursionIndex, na(runningExtreme) ? high : math.max(runningExtreme, high))
        excursionIndex += 1

    bool bullAccepted = bullishFvg and not f_fvgOverlap(low, high[2], true, -1)
    bool bearAccepted = bearishFvg and not f_fvgOverlap(low[2], high, false, -1)
    if bullAccepted
        [matchedBullSetupIndex, matchedBullSetupTf, matchedBullExtreme, matchedBullSlot, matchedBullEvent, matchedBullSoup] = f_findEntrySetup(1, low, high[2])
        if matchedBullSetupIndex >= 0 and inSession
            // Consumed either way. A soup that produced a qualifying gap has
            // done its job, whether the filter lets the trade through now or
            // parks it.
            f_disarmMarker(matchedBullSlot, matchedBullEvent)
            f_removeSetupAt(matchedBullSetupIndex)
            if cisdLongOk
                f_addEntryLabel(1, matchedBullExtreme, matchedBullSetupTf, matchedBullSoup, f_slotMarkerTime(matchedBullEvent, matchedBullSlot))
                longEntrySignal := true
                entryGapType := "FVG"
                entrySoupTf := matchedBullSetupTf
                entryStopRef := matchedBullExtreme
            else
                holdDir := 1
                holdBar := bar_index
                holdStopRef := matchedBullExtreme
                holdGapType := "FVG"
                holdSoupTf := matchedBullSetupTf
                holdSoupLevel := matchedBullSoup
                holdSoupTime := f_slotMarkerTime(matchedBullEvent, matchedBullSlot)
        color bullFill = showFvgsInput ? fvgBullColorInput : color.new(fvgBullColorInput, 100)
        color bullBorder = showFvgsInput ? color.new(fvgBullColorInput, 50) : color.new(fvgBullColorInput, 100)
        string bullText = showFvgsInput ? "FVG" : ""
        zoneTextSize = fvgTextSizeInput == "Tiny" ? size.tiny : fvgTextSizeInput == "Normal" ? size.normal : size.small
        box bullBox = box.new(left = bar_index - 2, top = low, right = bar_index + fvgExtendBarsInput, bottom = high[2], xloc = xloc.bar_index, border_color = bullBorder, bgcolor = bullFill, text = bullText, text_color = fvgTextColorInput, text_halign = text.align_right, text_valign = text.align_center, text_size = zoneTextSize)
        array.push(fvgZones, FvgZone.new(bullBox, true, true, low, high[2]))
    if bearAccepted
        [matchedBearSetupIndex, matchedBearSetupTf, matchedBearExtreme, matchedBearSlot, matchedBearEvent, matchedBearSoup] = f_findEntrySetup(-1, low[2], high)
        if matchedBearSetupIndex >= 0 and inSession
            f_disarmMarker(matchedBearSlot, matchedBearEvent)
            f_removeSetupAt(matchedBearSetupIndex)
            if cisdShortOk
                f_addEntryLabel(-1, matchedBearExtreme, matchedBearSetupTf, matchedBearSoup, f_slotMarkerTime(matchedBearEvent, matchedBearSlot))
                shortEntrySignal := true
                entryGapType := "FVG"
                entrySoupTf := matchedBearSetupTf
                entryStopRef := matchedBearExtreme
            else
                holdDir := -1
                holdBar := bar_index
                holdStopRef := matchedBearExtreme
                holdGapType := "FVG"
                holdSoupTf := matchedBearSetupTf
                holdSoupLevel := matchedBearSoup
                holdSoupTime := f_slotMarkerTime(matchedBearEvent, matchedBearSlot)
        color bearFill = showFvgsInput ? fvgBearColorInput : color.new(fvgBearColorInput, 100)
        color bearBorder = showFvgsInput ? color.new(fvgBearColorInput, 50) : color.new(fvgBearColorInput, 100)
        string bearText = showFvgsInput ? "FVG" : ""
        zoneTextSizeBear = fvgTextSizeInput == "Tiny" ? size.tiny : fvgTextSizeInput == "Normal" ? size.normal : size.small
        box bearBox = box.new(left = bar_index - 2, top = low[2], right = bar_index + fvgExtendBarsInput, bottom = high, xloc = xloc.bar_index, border_color = bearBorder, bgcolor = bearFill, text = bearText, text_color = fvgTextColorInput, text_halign = text.align_right, text_valign = text.align_center, text_size = zoneTextSizeBear)
        array.push(fvgZones, FvgZone.new(bearBox, false, true, low[2], high))

    while array.size(fvgZones) > maxFvgZonesInput
        int dropIndex = 0
        int scanIndex = 0
        bool foundInactive = false
        while scanIndex < array.size(fvgZones) and not foundInactive
            FvgZone candidateZone = array.get(fvgZones, scanIndex)
            if not candidateZone.active
                dropIndex := scanIndex
                foundInactive := true
            scanIndex += 1
        FvgZone removedZone = array.remove(fvgZones, dropIndex)
        box.delete(removedZone.zoneBox)

    int zoneIndex = array.size(fvgZones) - 1
    while zoneIndex >= 0
        FvgZone zone = array.get(fvgZones, zoneIndex)
        if zone.active
            box.set_right(zone.zoneBox, bar_index + fvgExtendBarsInput)
            bool invalidated = zone.isBull ? close < zone.bottom : close > zone.top
            if invalidated
                bool invertedBull = not zone.isBull
                bool skipInversion = f_fvgOverlap(zone.top, zone.bottom, invertedBull, zoneIndex)
                if not skipInversion
                    int entryDirection = invertedBull ? 1 : -1
                    [matchedIfvgSetupIndex, matchedIfvgSetupTf, matchedIfvgExtreme, matchedIfvgSlot, matchedIfvgEvent, matchedIfvgSoup] = f_findEntrySetup(entryDirection, zone.top, zone.bottom)
                    if matchedIfvgSetupIndex >= 0 and inSession
                        f_disarmMarker(matchedIfvgSlot, matchedIfvgEvent)
                        f_removeSetupAt(matchedIfvgSetupIndex)
                        if entryDirection == 1 ? cisdLongOk : cisdShortOk
                            f_addEntryLabel(entryDirection, matchedIfvgExtreme, matchedIfvgSetupTf, matchedIfvgSoup, f_slotMarkerTime(matchedIfvgEvent, matchedIfvgSlot))
                            if entryDirection == 1
                                longEntrySignal := true
                            else
                                shortEntrySignal := true
                            entryGapType := "IFVG"
                            entrySoupTf := matchedIfvgSetupTf
                            entryStopRef := matchedIfvgExtreme
                        else
                            holdDir := entryDirection
                            holdBar := bar_index
                            holdStopRef := matchedIfvgExtreme
                            holdGapType := "IFVG"
                            holdSoupTf := matchedIfvgSetupTf
                            holdSoupLevel := matchedIfvgSoup
                            holdSoupTime := f_slotMarkerTime(matchedIfvgEvent, matchedIfvgSlot)
                    if showIfvgsInput
                        zone.active := false
                        array.set(fvgZones, zoneIndex, zone)
                        color invertedFill = zone.isBull ? ifvgBearColorInput : ifvgBullColorInput
                        color invertedBorder = color.new(invertedFill, 50)
                        box.set_bgcolor(zone.zoneBox, invertedFill)
                        box.set_border_color(zone.zoneBox, invertedBorder)
                        box.set_text(zone.zoneBox, "IFVG")
                        box.set_text_color(zone.zoneBox, ifvgTextColorInput)
                    else
                        box.delete(zone.zoneBox)
                        array.remove(fvgZones, zoneIndex)
                else
                    box.delete(zone.zoneBox)
                    array.remove(fvgZones, zoneIndex)
        else if not showIfvgsInput
            box.delete(zone.zoneBox)
            array.remove(fvgZones, zoneIndex)
        else
            box.set_right(zone.zoneBox, bar_index + fvgExtendBarsInput)
            bool mitigated = zone.isBull ? close > zone.top : close < zone.bottom
            if mitigated
                box.delete(zone.zoneBox)
                array.remove(fvgZones, zoneIndex)
        zoneIndex -= 1

// ============================================================
//              STOP, BREAKEVEN AND TAKE PROFIT
// ============================================================
// One set of levels is tracked at a time, always belonging to the most recent
// entry signal. The stop is anchored to the sweep extreme — how far price
// actually ran past the swept level — rather than to the level itself, which
// price traded through by definition. The target is a multiple of that measured
// risk, so the distance follows the setup instead of being fixed.
var int tradeDir = 0
var int tradeEntryBar = na
var float tradeEntryPrice = na
var float tradeStopPrice = na
var float tradeTargetPrice = na
var float tradeBePrice = na
var bool tradeBeMoved = false
var line tradeStopLine = na
var line tradeTargetLine = na
var line tradeBeLine = na
var label tradeStopLabel = na
var label tradeTargetLabel = na
var label tradeBeLabel = na

// --- Manage the live trade ---
if barstate.isconfirmed and tradeDir != 0 and not na(tradeEntryBar) and bar_index > tradeEntryBar
    if not na(tradeStopLine)
        line.set_x2(tradeStopLine, bar_index + 5)
        label.set_x(tradeStopLabel, bar_index + 6)
    if not na(tradeTargetLine)
        line.set_x2(tradeTargetLine, bar_index + 5)
        label.set_x(tradeTargetLabel, bar_index + 6)
    if not na(tradeBeLine)
        line.set_x2(tradeBeLine, bar_index + 5)
        label.set_x(tradeBeLabel, bar_index + 6)

    // Breakeven is checked BEFORE the stop, so a bar that reaches it and then
    // trades back through entry reports as a scratch rather than a loss.
    if not tradeBeMoved and not na(tradeBePrice)
        if tradeDir == 1 ? high >= tradeBePrice : low <= tradeBePrice
            tradeBeMoved := true
            beTapSignal := true
            tradeStopPrice := tradeEntryPrice
            if not na(tradeStopLine)
                line.set_y1(tradeStopLine, tradeEntryPrice)
                line.set_y2(tradeStopLine, tradeEntryPrice)
                label.set_y(tradeStopLabel, tradeEntryPrice)
                label.set_text(tradeStopLabel, "SL at BE")
            // The breakeven line has done its job; leaving it would read as a
            // level still waiting to be reached.
            line.delete(tradeBeLine)
            label.delete(tradeBeLabel)
            tradeBeLine := na
            tradeBeLabel := na

    bool stopTouched = tradeDir == 1 ? low <= tradeStopPrice : high >= tradeStopPrice
    bool targetTouched = tradeDir == 1 ? high >= tradeTargetPrice : low <= tradeTargetPrice

    // If both levels trade through in one candle, conservatively count the stop.
    if stopTouched or targetTouched
        if stopTouched and tradeBeMoved
            beStopTapSignal := true
        else if stopTouched
            stopTapSignal := true
        else
            tpTapSignal := true
        line.delete(tradeStopLine)
        line.delete(tradeTargetLine)
        line.delete(tradeBeLine)
        label.delete(tradeStopLabel)
        label.delete(tradeTargetLabel)
        label.delete(tradeBeLabel)
        tradeStopLine := na
        tradeTargetLine := na
        tradeBeLine := na
        tradeStopLabel := na
        tradeTargetLabel := na
        tradeBeLabel := na
        tradeStopPrice := na
        tradeTargetPrice := na
        tradeBePrice := na
        tradeBeMoved := false
        tradeDir := 0
        tradeEntryBar := na
        tradeEntryPrice := na

// --- Open a new tracked trade ---
// The most recent signal always owns the lines. A signal arriving mid-trade
// replaces the one on the chart rather than being ignored, so what is drawn is
// always the setup currently in play. The trade it replaced is abandoned at
// that point, not resolved — no stop or target alert will follow for it.
bool newTradeSignal = longEntrySignal or shortEntrySignal
if barstate.isconfirmed and newTradeSignal and not na(entryStopRef)
    // Clear whatever the previous signal left behind before re-anchoring.
    line.delete(tradeStopLine)
    line.delete(tradeTargetLine)
    line.delete(tradeBeLine)
    label.delete(tradeStopLabel)
    label.delete(tradeTargetLabel)
    label.delete(tradeBeLabel)
    tradeStopLine := na
    tradeTargetLine := na
    tradeBeLine := na
    tradeStopLabel := na
    tradeTargetLabel := na
    tradeBeLabel := na

    // A bullish gap and a bearish inversion can both land on one bar. Long wins
    // the tie; there is no basis in the model for preferring either.
    int newDir = longEntrySignal ? 1 : -1
    float bufferPrice = slBufferTicksInput * syminfo.mintick
    float rawStop = newDir == 1 ? entryStopRef - bufferPrice : entryStopRef + bufferPrice

    tradeDir := newDir
    tradeEntryBar := bar_index
    tradeEntryPrice := close
    // Never on the wrong side of entry, and never closer than one tick, so the
    // risk figure the target is built from can't come out as zero.
    tradeStopPrice := newDir == 1 ? math.min(rawStop, close - syminfo.mintick) : math.max(rawStop, close + syminfo.mintick)
    float tradeRisk = math.abs(close - tradeStopPrice)
    tradeTargetPrice := newDir == 1 ? close + tradeRisk * tpRInput : close - tradeRisk * tpRInput
    tradeBePrice := beFracInput > 0 ? close + (tradeTargetPrice - close) * beFracInput : na
    tradeBeMoved := false

    if showTradeLevelsInput
        tradeStopLine := line.new(bar_index, tradeStopPrice, bar_index + 5, tradeStopPrice, xloc = xloc.bar_index, extend = extend.none, color = #f23645, width = 2)
        tradeTargetLine := line.new(bar_index, tradeTargetPrice, bar_index + 5, tradeTargetPrice, xloc = xloc.bar_index, extend = extend.none, color = #089981, width = 2)
        // Transparent background, so the text sits beside the line without a
        // block of colour competing with the zones behind it.
        tradeStopLabel := label.new(bar_index + 6, tradeStopPrice, "SL", xloc = xloc.bar_index, color = #00000000, textcolor = #f23645, style = label.style_label_left, size = size.small)
        tradeTargetLabel := label.new(bar_index + 6, tradeTargetPrice, "TP " + str.tostring(tpRInput, "#.#") + "R", xloc = xloc.bar_index, color = #00000000, textcolor = #089981, style = label.style_label_left, size = size.small)
        if not na(tradeBePrice)
            tradeBeLine := line.new(bar_index, tradeBePrice, bar_index + 5, tradeBePrice, xloc = xloc.bar_index, extend = extend.none, color = chart.fg_color, width = 2)
            tradeBeLabel := label.new(bar_index + 6, tradeBePrice, "BE", xloc = xloc.bar_index, color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)

// --- Session levels ---
// Drawn from the left edge to a few bars past price, with the label just
// beyond the line end, so neither prints on top of the other.
var array<line> keyLines = array.new<line>()
var array<label> keyLabels = array.new<label>()
f_drawKey(float px, string txt) =>
    if not na(px)
        array.push(keyLines, line.new(bar_index - 500, px, bar_index + keyExtendBarsInput, px, xloc = xloc.bar_index, extend = extend.left, color = keyColorInput, width = keyWidthInput))
        array.push(keyLabels, label.new(bar_index + keyExtendBarsInput + 1, px, txt, xloc = xloc.bar_index, color = #00000000, textcolor = keyColorInput, style = label.style_label_left, size = size.small))
    0
// Short stubs forward from price rather than lines across the chart: ten of
// these have to stay out of the way of everything else already drawn.
//
// Timeframes frequently agree on nearly the same price, and that agreement is
// worth seeing — but stacked at one height the labels sit on top of each other
// and you can read none of them. Each level crowding an earlier one is pushed
// further right instead, so they fan out into a readable row.
// Collected first, drawn second. Which line to keep in a crowded group cannot
// be decided while walking the timeframes one at a time — it depends on levels
// not yet seen.
var array<float> nextPx = array.new<float>()
var array<int> nextStart = array.new<int>()
var array<string> nextTxt = array.new<string>()

f_collectNext(float px, int startTime, string txt) =>
    if not na(px) and not na(startTime)
        array.push(nextPx, px)
        array.push(nextStart, startTime)
        array.push(nextTxt, txt)
    0

// One line AND one label per group of stacked levels. The line starts from the
// member reaching furthest back, since that is the level standing longest, and
// the label names every timeframe that landed there.
//
// Staggering the labels instead does not work: the step is measured in bars and
// the labels are measured in characters, so at any zoom where the text is
// readable it is wider than the gap and they overlap anyway. Levels at the same
// price only need the price printed once.
//
// Drawn in bar TIME rather than bar index, because the swing that created a
// higher-timeframe level sits at a timestamp, not at a chart bar number.
f_drawNextAll() =>
    float crowdTol = nextLiqCrowdTicksInput * syminfo.mintick
    int i = 0
    while i < array.size(nextPx)
        float px = array.get(nextPx, i)
        int startTime = array.get(nextStart, i)
        bool isAnchor = true
        string names = ""
        int j = 0
        while j < array.size(nextPx)
            if math.abs(array.get(nextPx, j) - px) <= crowdTol
                names := names + (names == "" ? "" : "·") + array.get(nextTxt, j)
                if j != i
                    int otherStart = array.get(nextStart, j)
                    // Earliest origin anchors the group; an exact tie goes to
                    // whichever was collected first, so exactly one always wins.
                    if otherStart < startTime or (otherStart == startTime and j < i)
                        isAnchor := false
            j += 1
        if isAnchor
            int endTime = time + int(nextLiqStubInput * chartSeconds * 1000)
            array.push(keyLines, line.new(startTime, px, endTime, px, xloc = xloc.bar_time, color = nextLiqColorInput, width = nextLiqWidthInput, style = line.style_dotted))
            array.push(keyLabels, label.new(endTime, px, names + " (" + str.tostring(px, format.mintick) + ")", xloc = xloc.bar_time, color = #00000000, textcolor = nextLiqColorInput, style = label.style_label_left, size = size.small))
        i += 1
    0

if barstate.islast
    while array.size(keyLines) > 0
        line.delete(array.pop(keyLines))
    while array.size(keyLabels) > 0
        label.delete(array.pop(keyLabels))
    array.clear(nextPx)
    array.clear(nextStart)
    array.clear(nextTxt)
    if showPdInput
        f_drawKey(pdh, "PDH")
        f_drawKey(pdl, "PDL")
    if showPwInput
        f_drawKey(pwh, "PWH")
        f_drawKey(pwl, "PWL")
    if showNextLiqInput
        if showCurrentInput
            f_collectNext(curNextUp, curNextUpTime, f_timeframeLabel(timeframe.period))
            f_collectNext(curNextDn, curNextDnTime, f_timeframeLabel(timeframe.period))
        if useHtf1
            f_collectNext(htf1NextUp, htf1NextUpTime, f_timeframeLabel(htf1Input))
            f_collectNext(htf1NextDn, htf1NextDnTime, f_timeframeLabel(htf1Input))
        if useHtf2
            f_collectNext(htf2NextUp, htf2NextUpTime, f_timeframeLabel(htf2Input))
            f_collectNext(htf2NextDn, htf2NextDnTime, f_timeframeLabel(htf2Input))
        if useHtf3
            f_collectNext(htf3NextUp, htf3NextUpTime, f_timeframeLabel(htf3Input))
            f_collectNext(htf3NextDn, htf3NextDnTime, f_timeframeLabel(htf3Input))
        if useHtf4
            f_collectNext(htf4NextUp, htf4NextUpTime, f_timeframeLabel(htf4Input))
            f_collectNext(htf4NextDn, htf4NextDnTime, f_timeframeLabel(htf4Input))
        if useHtf5
            f_collectNext(htf5NextUp, htf5NextUpTime, f_timeframeLabel(htf5Input))
            f_collectNext(htf5NextDn, htf5NextDnTime, f_timeframeLabel(htf5Input))
        f_drawNextAll()

// ============================================================
//                        ALERTS
// ============================================================
// One dynamic message carries both directions, so a single TradingView alert
// set to "Any alert() function call" covers the model. The message names the
// gap type and the timeframe whose soup it came from — on a multi-timeframe
// tool that is the part worth knowing.
//
// Nothing is sent outside the session windows. Sweeps and gaps keep being
// tracked through the night so the chart is right when a window opens; the
// gate is on the notification, not on the model.
string msg = ""
if alertEntriesInput and longEntrySignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — LONG, " + entryGapType + " after a " + f_timeframeLabel(entrySoupTf) + " turtle soup" + (entryWasHeld ? ", released on structure" : "")
if alertEntriesInput and shortEntrySignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — SHORT, " + entryGapType + " after a " + f_timeframeLabel(entrySoupTf) + " turtle soup" + (entryWasHeld ? ", released on structure" : "")
if alertBeTapInput and beTapSignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — BREAKEVEN REACHED, MOVE SL TO ENTRY"
if alertBeStopTapInput and beStopTapSignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — STOPPED AT BREAKEVEN"
if alertStopTapInput and stopTapSignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — STOP LOSS TOUCHED"
if alertTpTapInput and tpTapSignal
    msg := msg + (msg == "" ? "" : "\n") + syminfo.ticker + " — TAKE PROFIT TOUCHED"
if barstate.isconfirmed and inSession and msg != ""
    alert(msg, alert.freq_once_per_bar_close)

alertcondition(inSession and longEntrySignal, title = "Turtle Soup Long Entry", message = "Turtle Soup long entry: a swing low was swept and rejected, then a bullish FVG or IFVG formed clear of the swept level.")
alertcondition(inSession and shortEntrySignal, title = "Turtle Soup Short Entry", message = "Turtle Soup short entry: a swing high was swept and rejected, then a bearish FVG or IFVG formed clear of the swept level.")
alertcondition(inSession and alertBeTapInput and beTapSignal, title = "Turtle Soup Breakeven Reached", message = "Turtle Soup breakeven level touched. Move the stop to entry.")
alertcondition(inSession and alertBeStopTapInput and beStopTapSignal, title = "Turtle Soup Stopped at Breakeven", message = "Turtle Soup tracked trade was stopped at breakeven. A scratch, not a loss.")
alertcondition(inSession and alertStopTapInput and stopTapSignal, title = "Turtle Soup Stop Loss Touched", message = "Turtle Soup tracked trade stop loss was touched.")
alertcondition(inSession and alertTpTapInput and tpTapSignal, title = "Turtle Soup Take Profit Touched", message = "Turtle Soup tracked trade take profit was touched.")
````
