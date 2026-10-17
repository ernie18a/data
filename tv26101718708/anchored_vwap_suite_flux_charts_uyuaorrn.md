# Anchored VWAP Suite | Flux Charts

- url: https://www.tradingview.com/script/UYUaORRN-Anchored-VWAP-Suite-Flux-Charts/
- type: indicator
- pine_id: PUB;79c7f5e4243f45efb6946fe629dd595c
- version: 1.0

## Description

[b]GENERAL OVERVIEW[/b]
The Anchored VWAP Suite is an all-in-one anchored VWAP toolkit designed to plot every meaningful VWAP a trader needs from a single indicator. Instead of dropping a stand-alone anchored VWAP each time the chart prints a new swing high, swing low, daily extreme, or session boundary, the indicator does that work automatically and keeps every line on the chart managed, color-coded, and labeled.

The main goal of this indicator is to give traders a clean, automatic read on where the volume-weighted average sits from every important reference point in the market — without having to manually anchor anything. Every line you see on the chart represents the average price the market has traded at since a moment that mattered: a swing high, a session open, today’s low, and so on.

It plots six different families of anchored VWAPs simultaneously: Swing High/Low, Lookback High/Low, Daily Open/High/Low, Weekly Open/High/Low, Monthly Open/High/Low, and Session High/Low (Asia, London, NY). Every family is independently configurable — you can enable only the ones you use, set the price source for each, and control the color, line style, and how many of each type stay on the chart.

The indicator also smartly merges overlapping VWAP labels at the right edge of the chart. When two or more VWAPs converge to the same level, you see one combined label like "Daily High & Swing Low" instead of multiple stacked labels fighting for space.

This indicator was developed for traders who already use anchored VWAPs as part of their workflow and want every important anchor — swing, session, daily, weekly, monthly — drawn for them automatically and kept clean even when many are active at once.

[SCREENSHOT: Chart with multiple anchored VWAPs from different sources, session boxes, and right-edge labels]
https://www.tradingview.com/x/XHxNlP6p/ 

[b]WHAT IS THE THEORY BEHIND THIS INDICATOR?[/b]
An anchored VWAP plots the average price weighted by volume, starting from a specific bar — the "anchor." Once anchored, the line continues forward and updates each bar, showing the volume-weighted average price of everyone who has traded since that anchor was set.
Why traders use it: the anchor point is usually a moment of decision in the market — a swing high where supply showed up, a daily open where the session began, or the start of a major session. Everyone who entered around that anchor is now positioned relative to the VWAP. When price reclaims or rejects the line, it tells you whether those traders are in profit or in loss as a group, and the line itself often acts as dynamic support or resistance.

The challenge with anchored VWAPs is that there are many useful anchor points. A serious trader might want VWAPs from the last swing high, the last swing low, today’s open, today’s high, today’s low, the previous week’s high, the start of the NY session, and so on. Manually anchoring all of those — and re-anchoring them every time a new extreme prints — is tedious and error-prone.

The Anchored VWAP Suite handles this automatically. It detects every meaningful anchor point on the chart, draws the VWAP from that anchor, keeps it updated as new extremes print, retires old VWAPs as they age out, and presents the whole set in a way that stays readable even when ten or more lines are on the chart at once.

[SCREENSHOT: Example showing price reacting to an anchored VWAP from a recent swing high]
https://www.tradingview.com/x/MUc2kfmi/ 

[b]ANCHORED VWAP SUITE FEATURES[/b]
The Anchored VWAP Suite includes 7 main features:
[list=1]
[*]Session Anchors
[*]Swing Anchors
[*]Lookback Anchors
[*]Daily Anchors
[*]Weekly Anchors
[*]Monthly Anchors
[*]Customization Options
[/list]

🔹 Method
Method controls how each new bar affects a VWAP after its anchor is set. Three modes are available:
◇ Standard: every bar from the anchor counts equally. This is the classic anchored VWAP — older bars carry the same weight as the most recent ones. The line becomes steadily slower to respond as the anchor moves further into the past.
◇ EMA: recent bars are weighted more heavily, using a 2/(N+1) coefficient. The VWAP responds faster to new price action while still tracking back to the anchor point.
◇ RMA: also weights recent bars more, but with a slower 1/N coefficient (Wilder's smoothing). Smoother than EMA, but lags more.
The default is RMA, which produces a responsive line that behaves consistently whether the anchor is recent or far back.

🔹 Period
Period sets the length used by the EMA and RMA modes. Larger values smooth more — the line moves less. Smaller values make the line more reactive but jumpier. Period is ignored when Method is set to Standard, since Standard treats every bar equally regardless of length.
The default is 20.

🔹 Max VWAP Length
Max VWAP Length caps how far back a single VWAP can anchor before it's dropped from the chart. The default of 5,000 bars covers most use cases. Raise it if you need to keep very old anchored VWAPs visible — for example, swing VWAPs from far back in history. Lower it if you find the indicator slowing down on heavy charts; a smaller cap means less work to render and a snappier response when many VWAPs are active at once.

This cap also applies when a new VWAP is first drawn: anchors older than the configured limit are not created, so every line on the chart always fits inside the configured length.

[b]COMMON ANCHOR SETTINGS: SOURCE & COUNT[/b]
Beyond the General Configuration above, two settings — Source and Count — appear in nearly every anchor family. Because they work the same way across all of them, they are explained here once and then referenced inside each anchor family below.

🔹 Source
Source controls which price each bar contributes to the VWAP after the anchor is set, but it does not change the anchor itself. The anchor bar is always pinned to its defining extreme: a Swing High VWAP anchors at the actual high of the swing-high candle, a Daily Open VWAP anchors at the actual open of the day, a Daily Low VWAP anchors at the actual low, and so on. From the bar after that, the Source you choose decides which price gets fed into the volume-weighted calculation.

Available sources:
◇ High — only the high of each bar contributes
◇ Low — only the low of each bar contributes
◇ Close — only the close of each bar contributes
◇ Open — only the open of each bar contributes
◇ HLC3 — average of high, low, and close (the classic "typical price")
◇ HL2 — midpoint of high and low
◇ OHLC4 — average of open, high, low, and close

In practice, most traders leave Source at the default for each anchor type: High for "high" anchors, Low for "low" anchors, Open for open-based anchors. Switching to HLC3, HL2, or OHLC4 produces a smoother VWAP that's less sensitive to long wicks, while sticking with High, Low, or Close keeps the line tight to a single price point on every bar.

🔹 Count
Count controls how many VWAPs of a given type are kept on the chart at once. As new anchors form, older ones drop off automatically — so a Count of 3 on Daily Open VWAPs means the indicator always shows the three most recent daily-open VWAPs and quietly drops anything older.

Set Count to 1 for a clean chart that only shows the latest anchor of each type. Raise it when you want a side-by-side view of how price has interacted with multiple historical anchors of the same kind.

[SCREENSHOT: Swing Anchors VWAPs with Count set to 3, showing the three most recent swing high & low anchors running across the chart]
https://www.tradingview.com/x/uSLqKJQQ/ 

[b]SESSION ANCHORS[/b]
🔹 What Are Session Anchors?
Session anchors are VWAPs anchored to the session high and session low of the three major intraday sessions: Asia, London, and New York. They appear as each session develops and lock in once the session closes.

🔹 Default Session Times (New York Time)
◇ Asia: 20:00 – 22:00
◇ London: 02:00 – 04:00
◇ New York: 10:00 – 12:00

🔹 Live Re-Anchoring
While a session is open, the high and low VWAPs re-anchor automatically each time price prints a new extreme inside that session. The moment the session ends, the final anchors are confirmed and stay on the chart, giving traders a clean record of where the session’s volume-weighted averages sit relative to current price.

[SCREENSHOT: Asia, London, and NY session boxes with session high and low VWAPs anchored inside each one]
https://www.tradingview.com/x/Hq380RJ6/ 

🔹 Session Boxes and Labels
Each session is also drawn as a colored box that expands as price moves. The box contains the full high-to-low range of the session and is labeled with the session name (Asia, London, NY) along its top edge. Boxes from previous sessions are kept on the chart so you can quickly see the prior session’s range alongside the live one.

🔹 Customization Options
[list]
[*]Show / Hide toggle for each session (Asia, London, NY)
[*]High and Low source for each session
[*]High color and Low color for each session
[*]Show / Hide Session Boxes toggle and box color
[*]Show / Hide Session Labels toggle
[*]Line style (Solid, Dotted, Dashed) and width for session VWAPs
[/list]

[b]SWING ANCHORS[/b]
🔹 What Are Swing Anchors?
Swing anchors are VWAPs drawn from the last confirmed swing high or swing low on the chart. A swing high is a candle whose high stands above the highs of the bars surrounding it; a swing low is the opposite. Both make natural anchor points because they often mark the moment supply or demand showed up in size.

🔹 How the Indicator Detects Swings
The indicator looks for pivots using two confirmation windows: a "Swing Bars Left" count and a "Swing Bars Right" count. The current pivot must be the most extreme bar over both windows before the swing is locked in, and a VWAP is anchored to it. Larger values catch only the more meaningful swings; smaller values catch more frequent (but noisier) ones. The default is 10 bars left and 10 bars right.

[SCREENSHOT: Swing High and Swing Low VWAPs anchored to recent pivots, with price interacting with each line]
https://www.tradingview.com/x/TIZ7reH5/ 

🔹 Count
Up to 10 swing-high VWAPs and 10 swing-low VWAPs can be kept on the chart at once. As new swings form, older ones drop off automatically.

🔹 Extend All Toggle
When Extend All is on, every kept swing VWAP keeps drawing forward to the current bar — useful for studying how price interacts with multiple historical anchors at once. When off, each swing VWAP stops where the next one of the same direction begins, keeping the chart cleaner.

🔹 Customization Options
[list]
[*]Show / Hide toggle for Swing High VWAPs and Swing Low VWAPs
[*]Count for each (1–10)
[*]Price source for each (High, Low, Close, Open, HLC3, HL2, OHLC4)
[*]Swing Bars Left and Right (1–50)
[*]Line style (Solid, Dotted, Dashed) and width (1–5)
[*]Color for swing high and swing low
[*]Extend All toggle
[/list]

LOOKBACK ANCHORS
🔹 What Are Lookback Anchors?
A lookback anchor is a VWAP that re-anchors automatically every time the price prints a new extreme over a rolling window. The Highest High VWAP re-anchors whenever the current bar’s high tops the highest high of the previous N bars. The Lowest Low VWAP works the same way for new lows.

🔹 How It Helps
Where a swing anchor needs confirmation bars before it locks in, a lookback anchor responds the moment a new extreme is made. This makes lookback VWAPs useful for tracking the most aggressive recent move — they always reflect the volume-weighted average from the most recent breakout high or breakdown low.

[SCREENSHOT: Highest High and Lowest Low VWAPs]
https://www.tradingview.com/x/0jsUhTE4/ 

🔹 Customization Options
[list]
[*]Show / Hide toggles for Highest High and Lowest Low
[*]Price source for each
[*]Color for each
[*]Lookback Length (2–500, default 50)
[*]Line style and width
[/list]

[b]DAILY ANCHORS[/b]
🔹 What Are Daily Anchors?
Daily anchors are VWAPs anchored to the current trading day’s Open, High, and Low bars. They appear as the day develops and re-anchor live whenever a new daily extreme prints. At the end of the day, the active anchors are confirmed, and a fresh set begins the next day.

🔹 The Three Daily VWAPs
◇ Daily Open VWAP: anchored to the bar that opened today’s session. Tracks the volume-weighted average from the start of the day.
◇ Daily High VWAP: anchored to today’s high bar. Re-anchors when a new daily high prints.
◇ Daily Low VWAP: anchored to today’s low bar. Re-anchors when a new daily low prints.

🔹 Why It Matters
The daily open is one of the most-watched intraday levels. A VWAP from it tells you immediately whether the average trader who entered today is in profit or loss. The daily high and low VWAPs do the same for the people who entered at the day’s extremes — useful for spotting reaction zones around prior swing points.

[SCREENSHOT: Daily Open, Daily High, and Daily Low VWAPs running across an intraday chart]
https://www.tradingview.com/x/4crrvafz/ 

🔹 Customization Options
[list]
[*]Show / Hide toggles for Daily Open, Daily High, Daily Low
[*]Count for each (1–50, lets you keep historical daily VWAPs on the chart)
[*]Price source for each
[*]Color for each
[*]Line style and width
[*]Extend All toggle
[/list]

WEEKLY ANCHORS
🔹 What Are Weekly Anchors?
Weekly anchors work the same way as daily anchors, but for the current trading week’s Open, High, and Low. They appear as the week develops and re-anchor when new weekly extremes print. At the start of each new week, the previous week’s anchors are confirmed and the next week begins.
🔹 The Three Weekly VWAPs
◇ Weekly Open VWAP: anchored to the bar that opened this week.
◇ Weekly High VWAP: anchored to the week’s high bar so far.
◇ Weekly Low VWAP: anchored to the week’s low bar so far.
🔹 Why It Matters
Weekly VWAPs are useful for swing traders and for anyone watching how price holds up against bigger structural references. A break and hold above the Weekly Open VWAP often confirms the bullish case for the week; a break below confirms the bearish one.

[SCREENSHOT: Weekly Open, Weekly High, and Weekly Low VWAPs]
https://www.tradingview.com/x/gKlLJ3bL/ 

🔹 Customization Options
[list]
[*]Show / Hide toggles for Weekly Open, Weekly High, Weekly Low
[*]Count for each (1–50)
[*]Price source for each
[*]Color for each
[*]Line style and width
[*]Extend All toggle
[/list]

MONTHLY ANCHORS
🔹 What Are Monthly Anchors?
Monthly anchors plot VWAPs from the current month’s Open, High, and Low. Like the daily and weekly versions, they re-anchor as new monthly extremes print and confirm at the end of the month.

🔹 The Three Monthly VWAPs
◇ Monthly Open VWAP: anchored to the first bar of the current calendar month.
◇ Monthly High VWAP: anchored to the month’s high bar so far.
◇ Monthly Low VWAP: anchored to the month’s low bar so far.

🔹 Why It Matters
Monthly anchors give a longer-term read that’s especially helpful on higher-timeframe trades. They often line up with major structural levels and can highlight institutional positioning over multi-week windows.

[SCREENSHOT: Monthly Open, Monthly High, and Monthly Low VWAPs]
https://www.tradingview.com/x/SwgJJAkc/ 

🔹 Customization Options
[list]
[*]Show / Hide toggles for Monthly Open, Monthly High, Monthly Low
[*]Count for each (1–50)
[*]Price source for each
[*]Color for each
[*]Line style and width
[*]Extend All toggle
[/list]

[b]SMART RIGHT-EDGE LABELS[/b]
🔹 What the Labels Show
Every VWAP on the chart can display a small text tag at its right edge, naming what that VWAP is anchored to — for example "Swing High," "Daily Open," or "London Low." This makes it instantly clear what each line on the chart represents without needing to memorize colors.

🔹 Auto-Merging at Confluence Zones
When two or more VWAPs converge to the same price at the same bar, the indicator automatically merges their labels into one combined tag using an "&" separator. For example, if the Daily Open VWAP and a Swing Low VWAP land on the same price, the right edge shows a single label that reads "Daily Open & Swing Low" instead of two stacked labels overlapping each other.

This keeps the chart readable even when many VWAPs are active and converging at confluence zones.

[SCREENSHOT: Right edge of the chart showing several individual VWAP labels, plus one merged "Daily High & Swing Low" label]
https://www.tradingview.com/x/DMothit6/ 

🔹 Customization Options
[list]
[*]Show / Hide VWAP Labels toggle (global)
[/list]

[b]IMPORTANT NOTES[/b]
The Anchored VWAP Suite is designed to run on intraday timeframes for the session anchors to function. Session boxes and session VWAPs are automatically hidden on Daily, Weekly, and Monthly charts. Daily, Weekly, and Monthly anchor families work on any timeframe at or below their period.

The Max VWAP Length setting controls how far back a single VWAP can anchor before it’s dropped from the chart. The default of 5,000 bars covers most use cases. If you need to keep extremely old anchored VWAPs visible, raise the value; if you find the indicator is slow on large symbols, lower it.

Live anchors (the developing daily, weekly, monthly, and session anchors) update intra-bar so the line keeps pace with price. Historical bars never repaint after they close.
When Extend All is off (default for Swing, Daily, Weekly, and Monthly families), each VWAP of a given type stops where the next one of the same type begins. This keeps the chart from looking cluttered when many historical anchors are kept.

[b]UNIQUENESS[/b]
The Anchored VWAP Suite is unique because it consolidates every anchor family a serious anchored VWAP user would draw — swing, lookback, daily, weekly, monthly, and session — into a single managed indicator. Each family has its own price source, color, line style, count, and extend mode, which means the same script can render dozens of independently configured VWAPs at once without users needing to load multiple separate scripts. Live anchors automatically re-anchor as new extremes print during the in-progress period and lock in the moment the period closes, so the chart always reflects the most current set of meaningful anchors. Three smoothing modes — Standard, EMA, and RMA — give traders a choice between the classic cumulative anchored VWAP and faster, more responsive variants that stay usable even when the anchor is very far back. The smart right-edge label system automatically merges overlapping labels at confluence zones, which keeps the chart readable even when many VWAPs are active and crossing at the same price. By unifying all of these capabilities into one indicator with consistent styling, shared smoothing logic, and automatic anchor management, the Anchored VWAP Suite removes the need to drop and manually maintain many separate anchored VWAPs and produces a clean, deterministic read on every important VWAP across the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©fluxchart

//@version=6
indicator("Anchored VWAP Suite | Flux Charts", overlay = true, max_polylines_count = 100, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500)

//#region CONSTANTS
disp = display.none

string grpGeneral = "General Configuration"
string grpSwing = "Swing Anchors"
string grpLookback = "Lookback Anchors"
string grpDaily = "Daily Anchors"
string grpWeekly = "Weekly Anchors"
string grpMonthly = "Monthly Anchors"
string grpSession = "Session Anchors"

string tipSwing = "How many bars of confirmation are needed before a swing high or low is locked in. Larger values catch only the more meaningful swings; smaller values catch more frequent, noisier ones."
string tipLookback = "How many bars back to scan for new highs and lows. A new VWAP anchors as soon as the current bar's high tops the highest high of the prior N bars (or the low breaks the prior N-bar low)."
string tipDaily = "Anchors VWAPs to the prior day's open, high, and low bars. They appear as the day develops and re-anchor when new extremes print."
string tipWeekly = "Anchors VWAPs to the prior week's open, high, and low bars. They appear as the week develops and re-anchor when new extremes print."
string tipMonthly = "Anchors VWAPs to the prior month's open, high, and low bars. They appear as the month develops and re-anchor when new extremes print."
string tipSource = "Which price the VWAP uses on bars after the anchor. The anchor bar itself is always pinned to its defining extreme (high, low, or open)."
string tipCount = "How many of this VWAP type to keep on the chart. Older ones drop off as new ones form."
string tipExtendAll = "On: every kept VWAP keeps drawing forward to the current bar. Off: each VWAP stops extending when the next one of the same type starts."
string tipVwapLabels = "Show a small text tag on the right end of each VWAP (for example \"Swing High\" or \"Daily Open\")."
string tipSmoothing = "How each new bar affects the VWAP. \nStandard: every bar from the anchor counts equally — the classic anchored VWAP. \nEMA: recent bars weigh more (2/(N+1) coefficient). \nRMA: same idea but heavier-lagging (1/N coefficient, Wilder's smoothing). \nPeriod sets the length used by EMA and RMA — larger values smooth more. Period is ignored when Method is Standard."
string tipMaxPoints = "This limits how far a single VWAP can extend before it gets dropped from the chart. Pine Script has a hard ceiling on points per polyline, so this cap exists to prevent script errors. Larger values let VWAPs run further into history but use more memory and may slow the indicator; smaller values save resources but cut off long-running VWAPs sooner."

const string sesTz = "America/New_York"
const string sesAsia = "2000-2200"
const string sesLondon = "0200-0400"
const string sesNy = "1000-1200"

string styleSolid = "Solid"
string styleDotted = "Dotted"
string styleDashed = "Dashed"

string srcHigh = "High"
string srcLow = "Low"
string srcClose = "Close"
string srcOpen = "Open"
string srcHlc3 = "HLC3"
string srcHl2 = "HL2"
string srcOhlc4 = "OHLC4"

string smStandard = "Standard"
string smEMA = "EMA"
string smRMA = "RMA"
//#endregion CONSTANTS

//#region INPUTS
// General
string smoothingMethod = input.string(smRMA, "Method", options = [smStandard, smEMA, smRMA], inline = "gcc", group = grpGeneral, display = disp)
int smoothingPeriod = input.int(20, "Period", minval = 1, maxval = 500, tooltip = tipSmoothing, inline = "gcc", group = grpGeneral, display = disp)
int maxPolylinePoints = input.int(5000, "Max VWAP Length", minval = 100, maxval = 9999, tooltip = tipMaxPoints, group = grpGeneral, display = disp)
bool showVwapLabels = input.bool(true, "VWAP Labels", tooltip = tipVwapLabels, group = grpGeneral, display = disp)
int maxAnchorBarsBack = maxPolylinePoints - 1

// Session Anchors
bool showAsia = input.bool(true, "Asia", inline = "asia", group = grpSession, display = disp)
string asiaHSource = input.string(srcHigh, "High Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "asia", group = grpSession, display = disp)
string asiaLSource = input.string(srcLow, "Low Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "asia", group = grpSession, display = disp)

bool showLondon = input.bool(true, "London", inline = "london", group = grpSession, display = disp)
string londonHSource = input.string(srcHigh, "High Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "london", group = grpSession, display = disp)
string londonLSource = input.string(srcLow, "Low Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "london", group = grpSession, display = disp)

bool showNy = input.bool(true, "NY", inline = "ny", group = grpSession, display = disp)
string nyHSource = input.string(srcHigh, "High Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "ny", group = grpSession, display = disp)
string nyLSource = input.string(srcLow, "Low Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "ny", group = grpSession, display = disp)

color asiaHColor = input.color(color.teal, "Asia High", inline = "asiaC", group = grpSession, display = disp)
color asiaLColor = input.color(color.maroon, "Low", inline = "asiaC", group = grpSession, display = disp)
color londonHColor = input.color(color.blue, "London High", inline = "londonC", group = grpSession, display = disp)
color londonLColor = input.color(color.orange, "Low", inline = "londonC", group = grpSession, display = disp)
color nyHColor = input.color(color.purple, "NY High", inline = "nyC", group = grpSession, display = disp)
color nyLColor = input.color(color.green, "Low", inline = "nyC", group = grpSession, display = disp)

bool showSessionBoxes = input.bool(true, "Session Boxes", inline = "sbx", group = grpSession, display = disp)
color sesBoxCol = input.color(color.new(color.blue, 85), "", inline = "sbx", group = grpSession, display = disp)
bool showSessionLabels = input.bool(true, "Labels ", inline = "sbx", group = grpSession, display = disp)

string sessionLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "sesst", group = grpSession, display = disp)
int sessionLineWidth = input.int(1, "Width", minval = 1, inline = "sesst", group = grpSession, display = disp)

// Swing Anchors
bool showSwingHigh = input.bool(true, "Swing High VWAPs", inline = "swh", group = grpSwing, display = disp)
int swingHighCount = input.int(1, "Count", minval = 1, maxval = 10, tooltip = tipCount, inline = "swh", group = grpSwing, display = disp)
string swingHighSource = input.string(srcHigh, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "swh", group = grpSwing, display = disp)

bool showSwingLow = input.bool(true, "Swing Low VWAPs", inline = "swl", group = grpSwing, display = disp)
int swingLowCount = input.int(1, "Count", minval = 1, maxval = 10, tooltip = tipCount, inline = "swl", group = grpSwing, display = disp)
string swingLowSource = input.string(srcLow, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "swl", group = grpSwing, display = disp)

int swingLeft = input.int(10, "Swing Bars Left", minval = 1, maxval = 50, tooltip = tipSwing, inline = "swp", group = grpSwing, display = disp)
int swingRight = input.int(10, "Right", minval = 1, maxval = 50, inline = "swp", group = grpSwing, display = disp)

string swingLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "swst", group = grpSwing, display = disp)
int swingLineWidth = input.int(1, "Width", minval = 1, inline = "swst", group = grpSwing, display = disp)

color swingHighColor = input.color(color.red, "Swing High", inline = "swclr", group = grpSwing, display = disp)
color swingLowColor = input.color(color.lime, "Swing Low", inline = "swclr", group = grpSwing, display = disp)

bool swingExtendAll = input.bool(false, "Extend all", tooltip = tipExtendAll, group = grpSwing, display = disp)

// Lookback Anchors
bool showHighestHigh = input.bool(true, "Highest High", inline = "hh", group = grpLookback, display = disp)
string highestHighSource = input.string(srcHigh, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "hh", group = grpLookback, display = disp)
color highestHighColor = input.color(color.orange, "Color", inline = "hh", group = grpLookback, display = disp)

bool showLowestLow = input.bool(true, "Lowest Low", inline = "ll", group = grpLookback, display = disp)
string lowestLowSource = input.string(srcLow, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "ll", group = grpLookback, display = disp)
color lowestLowColor = input.color(color.aqua, "Color", inline = "ll", group = grpLookback, display = disp)

int lookbackLen = input.int(50, "Lookback Length", minval = 2, maxval = 500, tooltip = tipLookback, group = grpLookback, display = disp)
string lookbackLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "lbst", group = grpLookback, display = disp)
int lookbackLineWidth = input.int(1, "Width", minval = 1, inline = "lbst", group = grpLookback, display = disp)

// Daily Anchors
bool showDyO = input.bool(true, "Daily Open", tooltip = tipDaily, inline = "dyo", group = grpDaily, display = disp)
int dyOCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "dyo", group = grpDaily, display = disp)
string dyOSource = input.string(srcOpen, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "dyo2", group = grpDaily, display = disp)
color dyOColor = input.color(#FFD54F, "Color", inline = "dyo2", group = grpDaily, display = disp)

bool showDyH = input.bool(true, "Daily High", inline = "dyh", group = grpDaily, display = disp)
int dyHCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "dyh", group = grpDaily, display = disp)
string dyHSource = input.string(srcHigh, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "dyh2", group = grpDaily, display = disp)
color dyHColor = input.color(#EF5350, "Color", inline = "dyh2", group = grpDaily, display = disp)

bool showDyL = input.bool(true, "Daily Low", inline = "dyl", group = grpDaily, display = disp)
int dyLCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "dyl", group = grpDaily, display = disp)
string dyLSource = input.string(srcLow, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "dyl2", group = grpDaily, display = disp)
color dyLColor = input.color(#66BB6A, "Color", inline = "dyl2", group = grpDaily, display = disp)

string dailyLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "dyst", group = grpDaily, display = disp)
int dailyLineWidth = input.int(1, "Width", minval = 1, inline = "dyst", group = grpDaily, display = disp)

bool dailyExtendAll = input.bool(false, "Extend all", tooltip = tipExtendAll, group = grpDaily, display = disp)

// Weekly Anchors
bool showWkO = input.bool(false, "Weekly Open", tooltip = tipWeekly, inline = "wko", group = grpWeekly, display = disp)
int wkOCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "wko", group = grpWeekly, display = disp)
string wkOSource = input.string(srcOpen, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "wko2", group = grpWeekly, display = disp)
color wkOColor = input.color(#FFB74D, "Color", inline = "wko2", group = grpWeekly, display = disp)

bool showWkH = input.bool(false, "Weekly High", inline = "wkh", group = grpWeekly, display = disp)
int wkHCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "wkh", group = grpWeekly, display = disp)
string wkHSource = input.string(srcHigh, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "wkh2", group = grpWeekly, display = disp)
color wkHColor = input.color(#E57373, "Color", inline = "wkh2", group = grpWeekly, display = disp)

bool showWkL = input.bool(false, "Weekly Low", inline = "wkl", group = grpWeekly, display = disp)
int wkLCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "wkl", group = grpWeekly, display = disp)
string wkLSource = input.string(srcLow, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "wkl2", group = grpWeekly, display = disp)
color wkLColor = input.color(#81C784, "Color", inline = "wkl2", group = grpWeekly, display = disp)

string weeklyLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "wkst", group = grpWeekly, display = disp)
int weeklyLineWidth = input.int(1, "Width", minval = 1, inline = "wkst", group = grpWeekly, display = disp)

bool weeklyExtendAll = input.bool(false, "Extend all", tooltip = tipExtendAll, group = grpWeekly, display = disp)

// Monthly Anchors
bool showMoO = input.bool(false, "Monthly Open", tooltip = tipMonthly, inline = "moo", group = grpMonthly, display = disp)
int moOCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "moo", group = grpMonthly, display = disp)
string moOSource = input.string(srcOpen, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "moo2", group = grpMonthly, display = disp)
color moOColor = input.color(#FF9800, "Color", inline = "moo2", group = grpMonthly, display = disp)

bool showMoH = input.bool(false, "Monthly High", inline = "moh", group = grpMonthly, display = disp)
int moHCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "moh", group = grpMonthly, display = disp)
string moHSource = input.string(srcHigh, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "moh2", group = grpMonthly, display = disp)
color moHColor = input.color(#D32F2F, "Color", inline = "moh2", group = grpMonthly, display = disp)

bool showMoL = input.bool(false, "Monthly Low", inline = "mol", group = grpMonthly, display = disp)
int moLCount = input.int(1, "Count", minval = 1, maxval = 50, tooltip = tipCount, inline = "mol", group = grpMonthly, display = disp)
string moLSource = input.string(srcLow, "Source", options = [srcHigh, srcLow, srcClose, srcOpen, srcHlc3, srcHl2, srcOhlc4], tooltip = tipSource, inline = "mol2", group = grpMonthly, display = disp)
color moLColor = input.color(#388E3C, "Color", inline = "mol2", group = grpMonthly, display = disp)

string monthlyLineStyle = input.string(styleSolid, "Style", options = [styleSolid, styleDotted, styleDashed], inline = "most", group = grpMonthly, display = disp)
int monthlyLineWidth = input.int(1, "Width", minval = 1, inline = "most", group = grpMonthly, display = disp)

bool monthlyExtendAll = input.bool(false, "Extend all", tooltip = tipExtendAll, group = grpMonthly, display = disp)
//#endregion INPUTS

//#region UDTs
type Anchor
    int startBar
    int endBar
    string kind
    color col
    float sumPV
    float sumV
    int lastBar
    array<chart.point> pts
    polyline pl
    bool live

type SessionState
    bool active
    int startTime
    int startBar
    float hi
    int hiBar
    float lo
    int loBar
    box curBox
    label curLbl
    array<box> archBoxes
    array<label> archLbls
//#endregion UDTs

//#region VARIABLES
float bv = nz(volume, 0)

// Smoothing
var float gSmoothingWeight = smoothingMethod == smEMA ? 2.0 / (math.max(1, smoothingPeriod) + 1) : smoothingMethod == smRMA ? 1.0 / math.max(1, smoothingPeriod) : 0.0

// Day, week, month trackers 
var int dyOpenBar = na
var int dyHighBar = na
var float dyHigh = na
var int dyLowBar = na
var float dyLow = na

var int wkOpenBar = na
var int wkHighBar = na
var float wkHigh = na
var int wkLowBar = na
var float wkLow = na

var int moOpenBar = na
var int moHighBar = na
var float moHigh = na
var int moLowBar = na
var float moLow = na

var SessionState asiaSes = SessionState.new(false, na, na, na, na, na, na, na, na, array.new_box(), array.new_label())
var SessionState londonSes = SessionState.new(false, na, na, na, na, na, na, na, na, array.new_box(), array.new_label())
var SessionState nySes = SessionState.new(false, na, na, na, na, na, na, na, na, array.new_box(), array.new_label())

float ph = ta.pivothigh(swingLeft, swingRight)
float pvl = ta.pivotlow(swingLeft, swingRight)
float hhPrev = ta.highest(high[1], lookbackLen)
float llPrev = ta.lowest(low[1], lookbackLen)

bool newSH = not na(ph)
bool newSL = not na(pvl)
bool newHH = bar_index > lookbackLen and not na(hhPrev) and high > hhPrev
bool newLL = bar_index > lookbackLen and not na(llPrev) and low < llPrev

bool newDay = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMonth = ta.change(time("M")) != 0
//#endregion VARIABLES

//#region ARRAYS
var array<Anchor> anchors = array.new<Anchor>()
var array<label> vwapLbls = array.new_label()
//#endregion ARRAYS

//#region FUNCTION DECLARATIONS
// True when an anchor's polyline has reached the maximum allowed point count.
anchorHasTooManyPoints(Anchor a) =>
    a.pts.size() >= maxPolylinePoints

// Display name for a VWAP
labelTextForKind(string kind) =>
    switch kind
        "SH"  => "Swing High"
        "SL"  => "Swing Low"
        "HH"  => "Highest High"
        "LL"  => "Lowest Low"
        "DyO" => "Daily Open"
        "DyH" => "Daily High"
        "DyL" => "Daily Low"
        "WkO" => "Weekly Open"
        "WkH" => "Weekly High"
        "WkL" => "Weekly Low"
        "MoO" => "Monthly Open"
        "MoH" => "Monthly High"
        "MoL" => "Monthly Low"
        "AsH" => "Asia High"
        "AsL" => "Asia Low"
        "LnH" => "London High"
        "LnL" => "London Low"
        "NyH" => "NY High"
        "NyL" => "NY Low"
        => ""

deleteAnchorArtifacts(Anchor a) =>
    if not na(a.pl)
        a.pl.delete()
        a.pl := na

removeLiveAnchor(string kind) =>
    int sz = anchors.size()
    if sz > 0
        for i = sz - 1 to 0
            Anchor a = anchors.get(i)
            if a.kind == kind and a.live
                deleteAnchorArtifacts(a)
                anchors.remove(i)
                break

promoteLiveAnchors(string kind) =>
    int sz = anchors.size()
    if sz > 0
        for i = 0 to sz - 1
            Anchor a = anchors.get(i)
            if a.kind == kind and a.live
                a.live := false

liveAnchorBar(string kind) =>
    int result = na
    int sz = anchors.size()
    if sz > 0
        for i = 0 to sz - 1
            Anchor a = anchors.get(i)
            if a.kind == kind and a.live
                result := a.startBar
                break
    result

// line-style 
lineStyleForKind(string kind) =>
    if kind == "SH" or kind == "SL"
        switch swingLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else if kind == "HH" or kind == "LL"
        switch lookbackLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else if kind == "DyO" or kind == "DyH" or kind == "DyL"
        switch dailyLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else if kind == "WkO" or kind == "WkH" or kind == "WkL"
        switch weeklyLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else if kind == "MoO" or kind == "MoH" or kind == "MoL"
        switch monthlyLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else if kind == "AsH" or kind == "AsL" or kind == "LnH" or kind == "LnL" or kind == "NyH" or kind == "NyL"
        switch sessionLineStyle
            styleDotted => line.style_dotted
            styleDashed => line.style_dashed
            => line.style_solid
    else
        line.style_solid

// Line width 
lineWidthForKind(string kind) =>
    if kind == "SH" or kind == "SL"
        swingLineWidth
    else if kind == "HH" or kind == "LL"
        lookbackLineWidth
    else if kind == "DyO" or kind == "DyH" or kind == "DyL"
        dailyLineWidth
    else if kind == "WkO" or kind == "WkH" or kind == "WkL"
        weeklyLineWidth
    else if kind == "MoO" or kind == "MoH" or kind == "MoL"
        monthlyLineWidth
    else if kind == "AsH" or kind == "AsL" or kind == "LnH" or kind == "LnL" or kind == "NyH" or kind == "NyL"
        sessionLineWidth
    else
        1

// How many anchors to keep on the chart.
maxForKind(string kind) =>
    switch kind
        "SH" => swingHighCount
        "SL" => swingLowCount
        "HH" => 1
        "LL" => 1
        "DyO" => dyOCount
        "DyH" => dyHCount
        "DyL" => dyLCount
        "WkO" => wkOCount
        "WkH" => wkHCount
        "WkL" => wkLCount
        "MoO" => moOCount
        "MoH" => moHCount
        "MoL" => moLCount
        "AsH" => 1
        "AsL" => 1
        "LnH" => 1
        "LnL" => 1
        "NyH" => 1
        "NyL" => 1
        => 1

// Whether kept anchors should keep extending to the current bar instead of stopping at the next anchor.
extendAllForKind(string kind) =>
    switch kind
        "SH" => swingExtendAll
        "SL" => swingExtendAll
        "DyO" => dailyExtendAll
        "DyH" => dailyExtendAll
        "DyL" => dailyExtendAll
        "WkO" => weeklyExtendAll
        "WkH" => weeklyExtendAll
        "WkL" => weeklyExtendAll
        "MoO" => monthlyExtendAll
        "MoH" => monthlyExtendAll
        "MoL" => monthlyExtendAll
        "AsH" => true
        "AsL" => true
        "LnH" => true
        "LnL" => true
        "NyH" => true
        "NyL" => true
        "HH" => false
        "LL" => false
        => false

srcFromOption(string src, int barsBack) =>
    switch src
        srcHigh => high[barsBack]
        srcLow => low[barsBack]
        srcClose => close[barsBack]
        srcOpen => open[barsBack]
        srcHlc3 => hlc3[barsBack]
        srcHl2 => hl2[barsBack]
        srcOhlc4 => ohlc4[barsBack]
        => hlc3[barsBack]

// VWAP source price 
srcForKind(string kind, int barsBack) =>
    switch kind
        "SH" => srcFromOption(swingHighSource, barsBack)
        "SL" => srcFromOption(swingLowSource, barsBack)
        "HH" => srcFromOption(highestHighSource, barsBack)
        "LL" => srcFromOption(lowestLowSource, barsBack)
        "DyO" => srcFromOption(dyOSource, barsBack)
        "DyH" => srcFromOption(dyHSource, barsBack)
        "DyL" => srcFromOption(dyLSource, barsBack)
        "WkO" => srcFromOption(wkOSource, barsBack)
        "WkH" => srcFromOption(wkHSource, barsBack)
        "WkL" => srcFromOption(wkLSource, barsBack)
        "MoO" => srcFromOption(moOSource, barsBack)
        "MoH" => srcFromOption(moHSource, barsBack)
        "MoL" => srcFromOption(moLSource, barsBack)
        "AsH" => srcFromOption(asiaHSource, barsBack)
        "AsL" => srcFromOption(asiaLSource, barsBack)
        "LnH" => srcFromOption(londonHSource, barsBack)
        "LnL" => srcFromOption(londonLSource, barsBack)
        "NyH" => srcFromOption(nyHSource, barsBack)
        "NyL" => srcFromOption(nyLSource, barsBack)
        => hlc3[barsBack]

calcSrcForKind(string kind, int barsBack, int anchorBack) =>
    switch kind
        "SH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(swingHighSource, barsBack)
        "SL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(swingLowSource, barsBack)
        "HH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(highestHighSource, barsBack)
        "LL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(lowestLowSource, barsBack)
        "DyO" => barsBack == anchorBack ? open[barsBack] : srcFromOption(dyOSource, barsBack)
        "DyH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(dyHSource, barsBack)
        "DyL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(dyLSource, barsBack)
        "WkO" => barsBack == anchorBack ? open[barsBack] : srcFromOption(wkOSource, barsBack)
        "WkH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(wkHSource, barsBack)
        "WkL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(wkLSource, barsBack)
        "MoO" => barsBack == anchorBack ? open[barsBack] : srcFromOption(moOSource, barsBack)
        "MoH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(moHSource, barsBack)
        "MoL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(moLSource, barsBack)
        "AsH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(asiaHSource, barsBack)
        "AsL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(asiaLSource, barsBack)
        "LnH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(londonHSource, barsBack)
        "LnL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(londonLSource, barsBack)
        "NyH" => barsBack == anchorBack ? high[barsBack] : srcFromOption(nyHSource, barsBack)
        "NyL" => barsBack == anchorBack ? low[barsBack] : srcFromOption(nyLSource, barsBack)
        => srcForKind(kind, barsBack)

redraw(Anchor a) =>
    if not na(a.pl)
        a.pl.delete()
        a.pl := na
    if a.pts.size() >= 2 and a.pts.size() <= maxPolylinePoints
        a.pl := polyline.new(a.pts, xloc = xloc.bar_index, line_color = a.col, line_width = lineWidthForKind(a.kind), line_style = lineStyleForKind(a.kind))

// Rebuilds labels each bar, merging anchors that share the same value into a single combined label.
rebuildLabels() =>
    if not showVwapLabels
        if vwapLbls.size() > 0
            for i = 0 to vwapLbls.size() - 1
                label ol = vwapLbls.get(i)
                if not na(ol)
                    ol.delete()
            vwapLbls.clear()
    else
        float tol = syminfo.mintick

        array<int> gIdx = array.new_int()
        array<float> gPrice = array.new_float()
        array<string> gText = array.new_string()
        array<color> gCol = array.new_color()

        int szA = anchors.size()
        if szA > 0
            for i = 0 to szA - 1
                Anchor a = anchors.get(i)
                if a.pts.size() > 0
                    chart.point tail = a.pts.get(a.pts.size() - 1)
                    string txt = labelTextForKind(a.kind)

                    bool merged = false
                    int szG = gIdx.size()
                    if szG > 0
                        for g = 0 to szG - 1
                            if gIdx.get(g) == tail.index and math.abs(gPrice.get(g) - tail.price) <= tol
                                gText.set(g, gText.get(g) + " & " + txt)
                                merged := true
                                break

                    if not merged
                        gIdx.push(tail.index)
                        gPrice.push(tail.price)
                        gText.push(txt)
                        gCol.push(a.col)

        int needed = gIdx.size()
        int have = vwapLbls.size()

        if needed > 0
            for g = 0 to needed - 1
                int xi = gIdx.get(g)
                float yp = gPrice.get(g)
                string tx = gText.get(g)
                color cl = gCol.get(g)

                if g < have
                    label lb = vwapLbls.get(g)
                    lb.set_xy(xi, yp)
                    lb.set_text(tx)
                    lb.set_textcolor(cl)
                else
                    label lb = label.new(xi, yp, tx, xloc = xloc.bar_index, style = label.style_label_left, textcolor = cl, color = color.new(color.black, 100), size = size.small)
                    vwapLbls.push(lb)

        while vwapLbls.size() > needed
            label ol = vwapLbls.pop()
            if not na(ol)
                ol.delete()
    0

truncateToEnd(Anchor a) =>
    if not na(a.endBar)
        while a.pts.size() > 0
            last = a.pts.get(a.pts.size() - 1)
            if last.index > a.endBar
                a.pts.pop()
            else
                break
        if barstate.islast
            redraw(a)

// Keeps only the N most recent anchors
trimKind(string kind) =>
    int cap = maxForKind(kind)
    int sz = anchors.size()
    if sz > 0
        int count = 0
        for i = sz - 1 to 0
            a = anchors.get(i)
            if a.kind == kind
                if anchorHasTooManyPoints(a)
                    deleteAnchorArtifacts(a)
                    anchors.remove(i)
                else
                    count += 1
                    if count > cap
                        deleteAnchorArtifacts(a)
                        anchors.remove(i)

anchorIsTooOld(int backFill) =>
    backFill > maxAnchorBarsBack

createAnchor(int backFill, string kind, color col, bool isLive) =>
    if anchorIsTooOld(backFill)
        na
    else
        int anchorBar = bar_index - backFill
        pts = array.new<chart.point>()
        float sPV = 0.0
        float sV = 0.0
        bool smoothed = gSmoothingWeight > 0.0

        for i = backFill to 0
            float price = calcSrcForKind(kind, i, backFill)
            float vol = nz(volume[i], 0)
            float pvBar = price * vol

            if i == backFill
                sPV := pvBar
                sV := vol
            else if smoothed
                sPV += gSmoothingWeight * (pvBar - sPV)
                sV  += gSmoothingWeight * (vol - sV)
            else
                sPV += pvBar
                sV  += vol

            float vwapPt = sV > 0 ? sPV / sV : price
            pts.push(chart.point.from_index(bar_index - i, vwapPt))

        if pts.size() > maxPolylinePoints
            na
        else
            a = Anchor.new(anchorBar, na, kind, col, sPV, sV, bar_index, pts, na, isLive)
            anchors.push(a)

            // Close the previous same-kind anchor at this bar when "Extend all" is off.
            if not extendAllForKind(kind)
                int szA = anchors.size()
                if szA > 1
                    for i = 0 to szA - 2
                        prev = anchors.get(i)
                        if prev.kind == kind and na(prev.endBar)
                            prev.endBar := anchorBar
                            truncateToEnd(prev)

            if barstate.islast
                redraw(a)
            trimKind(kind)

maintainLiveAnchor(string kind, int targetBar, color col, bool enabled) =>
    if enabled
        int curBar = liveAnchorBar(kind)
        if na(curBar) or curBar != targetBar
            removeLiveAnchor(kind)
            createAnchor(bar_index - targetBar, kind, col, true)

// Builds VWAP 
updateActive() =>
    int sz = anchors.size()
    if sz > 0
        for i = sz - 1 to 0
            Anchor a = anchors.get(i)

            if anchorHasTooManyPoints(a)
                deleteAnchorArtifacts(a)
                anchors.remove(i)
            else
                if na(a.endBar)
                    float src = srcForKind(a.kind, 0)
                    float vw = na

                    if a.lastBar < bar_index
                        float pvNow = src * bv
                        float nextPV = a.sumPV
                        float nextV = a.sumV

                        if gSmoothingWeight > 0.0
                            nextPV += gSmoothingWeight * (pvNow - a.sumPV)
                            nextV  += gSmoothingWeight * (bv - a.sumV)
                        else
                            nextPV += pvNow
                            nextV  += bv

                        vw := nextV > 0 ? nextPV / nextV : src
                        if barstate.isconfirmed
                            a.sumPV := nextPV
                            a.sumV := nextV
                            a.lastBar := bar_index
                    else
                        vw := a.sumV > 0 ? a.sumPV / a.sumV : src

                    bool replacingLast = a.pts.size() > 0 and a.pts.get(a.pts.size() - 1).index == bar_index
                    if replacingLast
                        a.pts.pop()

                    if a.pts.size() < maxPolylinePoints
                        a.pts.push(chart.point.from_index(bar_index, vw))
                    else
                        deleteAnchorArtifacts(a)
                        anchors.remove(i)

    if barstate.islast
        int sz2 = anchors.size()
        if sz2 > 0
            for i = 0 to sz2 - 1
                Anchor a = anchors.get(i)
                redraw(a)
        rebuildLabels()
    0

method clearAll(SessionState self) =>
    if not na(self.curBox)
        box.delete(self.curBox)
        self.curBox := na
    if not na(self.curLbl)
        label.delete(self.curLbl)
        self.curLbl := na
    if self.archBoxes.size() > 0
        for i = 0 to self.archBoxes.size() - 1
            box ob = self.archBoxes.get(i)
            if not na(ob)
                box.delete(ob)
        self.archBoxes.clear()
    if self.archLbls.size() > 0
        for i = 0 to self.archLbls.size() - 1
            label ol = self.archLbls.get(i)
            if not na(ol)
                label.delete(ol)
        self.archLbls.clear()
    self.active := false

// Moves a session tracker forward one bar, firing anchors at session end and maintaining its visible box / label.
method process(SessionState self, bool enabled, string name, string sessionStr, color boxCol, color hiCol, color loCol, string hiKind, string loKind) =>
    bool inSes = enabled and timeframe.isintraday and not na(time(timeframe.period, sessionStr, sesTz))
    bool start = inSes and not inSes[1]
    bool stop = not inSes and inSes[1]

    if not enabled or not timeframe.isintraday
        self.clearAll()
    else
        if start and not self.active
            self.active := true
            self.startTime := time
            self.startBar := bar_index
            self.hi := high
            self.hiBar := bar_index
            self.lo := low
            self.loBar := bar_index
            if showSessionBoxes
                self.curBox := box.new(self.startTime, self.hi, time, self.lo, xloc = xloc.bar_time, bgcolor = boxCol, border_color = na)
                if showSessionLabels
                    self.curLbl := label.new(self.startTime, self.hi, name, xloc = xloc.bar_time, style = label.style_label_down, textcolor = color.white, color = color.new(color.black, 100), size = size.small)

        if inSes and self.active
            if high > self.hi
                self.hi := high
                self.hiBar := bar_index
            if low < self.lo
                self.lo := low
                self.loBar := bar_index
            if not na(self.curBox)
                box.set_right(self.curBox, time)
                box.set_top(self.curBox, self.hi)
                box.set_bottom(self.curBox, self.lo)
            if not na(self.curLbl)
                int tMid = self.startTime + int(math.round((time - self.startTime) * 0.5))
                label.set_x(self.curLbl, tMid)
                label.set_y(self.curLbl, self.hi)
            maintainLiveAnchor(hiKind, self.hiBar, hiCol, true)
            maintainLiveAnchor(loKind, self.loBar, loCol, true)

        if stop and self.active and not na(self.hiBar) and barstate.isconfirmed
            promoteLiveAnchors(hiKind)
            promoteLiveAnchors(loKind)
            trimKind(hiKind)
            trimKind(loKind)

            if not na(self.curBox)
                self.archBoxes.push(self.curBox)
                self.curBox := na
            if not na(self.curLbl)
                self.archLbls.push(self.curLbl)
                self.curLbl := na
            while self.archBoxes.size() > 1
                box ob = self.archBoxes.shift()
                if not na(ob)
                    box.delete(ob)
            while self.archLbls.size() > 1
                label ol = self.archLbls.shift()
                if not na(ol)
                    label.delete(ol)

            self.active := false
//#endregion FUNCTION DECLARATIONS

//#region CALCULATIONS
updateActive()

asiaSes.process(showAsia, "Asia", sesAsia, sesBoxCol, asiaHColor, asiaLColor, "AsH", "AsL")
londonSes.process(showLondon, "London", sesLondon, sesBoxCol, londonHColor, londonLColor, "LnH", "LnL")
nySes.process(showNy, "NY", sesNy, sesBoxCol, nyHColor, nyLColor, "NyH", "NyL")

if barstate.isconfirmed
    if showSwingHigh and newSH
        createAnchor(swingRight, "SH", swingHighColor, false)
    if showSwingLow and newSL
        createAnchor(swingRight, "SL", swingLowColor, false)
    if showHighestHigh and newHH
        createAnchor(0, "HH", highestHighColor, false)
    if showLowestLow and newLL
        createAnchor(0, "LL", lowestLowColor, false)

    if newDay and not na(dyOpenBar)
        promoteLiveAnchors("DyH")
        promoteLiveAnchors("DyL")
        promoteLiveAnchors("DyO")
        trimKind("DyH")
        trimKind("DyL")
        trimKind("DyO")

    if newDay or na(dyOpenBar)
        dyOpenBar := bar_index
        dyHigh := high
        dyHighBar := bar_index
        dyLow := low
        dyLowBar := bar_index
    else
        if high > dyHigh
            dyHigh := high
            dyHighBar := bar_index
        if low < dyLow
            dyLow := low
            dyLowBar := bar_index

    maintainLiveAnchor("DyO", dyOpenBar, dyOColor, showDyO)
    maintainLiveAnchor("DyH", dyHighBar, dyHColor, showDyH)
    maintainLiveAnchor("DyL", dyLowBar, dyLColor, showDyL)

    // Weekly
    if newWeek and not na(wkOpenBar)
        promoteLiveAnchors("WkH")
        promoteLiveAnchors("WkL")
        promoteLiveAnchors("WkO")
        trimKind("WkH")
        trimKind("WkL")
        trimKind("WkO")

    if newWeek or na(wkOpenBar)
        wkOpenBar := bar_index
        wkHigh := high
        wkHighBar := bar_index
        wkLow := low
        wkLowBar := bar_index
    else
        if high > wkHigh
            wkHigh := high
            wkHighBar := bar_index
        if low < wkLow
            wkLow := low
            wkLowBar := bar_index

    maintainLiveAnchor("WkO", wkOpenBar, wkOColor, showWkO)
    maintainLiveAnchor("WkH", wkHighBar, wkHColor, showWkH)
    maintainLiveAnchor("WkL", wkLowBar, wkLColor, showWkL)

    // Monthly
    if newMonth and not na(moOpenBar)
        promoteLiveAnchors("MoH")
        promoteLiveAnchors("MoL")
        promoteLiveAnchors("MoO")
        trimKind("MoH")
        trimKind("MoL")
        trimKind("MoO")

    if newMonth or na(moOpenBar)
        moOpenBar := bar_index
        moHigh := high
        moHighBar := bar_index
        moLow := low
        moLowBar := bar_index
    else
        if high > moHigh
            moHigh := high
            moHighBar := bar_index
        if low < moLow
            moLow := low
            moLowBar := bar_index

    maintainLiveAnchor("MoO", moOpenBar, moOColor, showMoO)
    maintainLiveAnchor("MoH", moHighBar, moHColor, showMoH)
    maintainLiveAnchor("MoL", moLowBar, moLColor, showMoL)
//#endregion CALCULATIONS
````
