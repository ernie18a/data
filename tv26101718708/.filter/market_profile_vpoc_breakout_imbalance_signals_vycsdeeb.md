# Market Profile VPOC Breakout - Imbalance Signals

- url: https://www.tradingview.com/script/VYCSdeeB-Market-Profile-VPOC-Breakout-Imbalance-Signals/
- type: indicator
- pine_id: PUB;8310d9b19fff4d5dae9bbdd66e7ffb3f
- version: 1.0

## Description

A breakout setup does not fail because the setup is bad. It fails because it was taken in the wrong market phase. Roughly 70 % of the time price is INSIDE the higher-timeframe balance — inside fair value — and there a breakout has almost no edge. In the remaining ~30 %, when the market is OUT OF BALANCE, the identical trigger becomes one of the highest-probability trades there is. That combination shows up about ONCE PER DAY.

Market Profile VPOC Breakout automates that location-first workflow end to end: weekly and daily volume/TPO profiles, the value areas, the VPOC sequence, the transferred prior-day value-area edge, single prints, the P / b micro-profile proof, the entry trigger, the risk model and ready-to-use webhook JSON — all on one chart, with an explanation attached to every single object.

═══════════════════════════════
THE 7 CONFIRMATIONS
═══════════════════════════════

The panel walks you through them live, top to bottom, and nothing below step 1 matters while the market is in balance.

① WEEKLY LOCATION — the previous week's value area is the equilibrium. Price inside it = the 70 % phase → stand down. Price above VAH or below VAL = imbalance → hunt. The shaded zone on the chart is that balance; the background wash tells you at a glance which phase you are in (mint = imbalance up, red = imbalance down, gold = balance).

② EQUILIBRIUM TEST + REJECTION — the week opened outside the balance, price came back to TEST the weekly value area and was aggressively traded away from it again. That rejection is the proof that the market no longer wants to be in equilibrium.

③ TREND OF EQUILIBRIUM — the sequence of daily VPOCs. Rising VPOCs mean fair value itself is migrating up: the distribution of the participants' equilibrium is trending, which is exactly what a fast trade WITH the trend needs. Flat or overlapping VPOCs = balance = no trade. Drawn as a staircase over the session VPOCs.

④ PRIOR-DAY VALUE AREA BREAK — the previous session's value-area edge is transferred onto the execution timeframe as a thick green line. Price has to ACCELERATE through it, not drift.

⑤ SINGLE PRINTS — the indicator reads the running session's TPO grid and counts price rows that only ONE bar ever touched. Those rows are marked as a cyan SINGLE PRINT zone: the market moved so fast that no business was done there = aggressive buyers or sellers, not passive rotation.

⑥ P / b MICRO SHAPE — the micro profile of impulse + the small balance that forms on it is measured. POC in the upper part = P (aggressive buyers shifting equilibrium up) → long. POC in the lower part = b (sellers shifting it down) → short. A symmetric D is skipped. This is the P/b/D profile-shape logic used by two-time World Cup Championship of Futures Trading winner Patrick Nill.

⑦ TRIGGER — two variants, both switchable:
• BREAK-IN — price dips back into the P/b balance and is instantly bought / sold again (the aggressive, earlier entry, trend-continuing).
• BREAKOUT — a CLOSE beyond the balance edge with a higher (long) or lower (short) close. Never a wick.

═══════════════════════════════
RISK MODEL
═══════════════════════════════
Stop behind the structural invalidation (micro-balance edge, impulse origin or the reference level) plus an ATR buffer. TP1 in R multiples moves the stop to break-even, TP2 lets the runner work. And the rule that keeps this model alive: a TIME STOP. If the move does not run within N bars, get out — a failing breakout reverses just as fast as it was supposed to run. Risk and reward are drawn as blocks so the geometry is readable at a glance. One signal per session by default, because the model only exists about once a day.

═══════════════════════════════
WHAT IS ON THE CHART
═══════════════════════════════
• Session volume/TPO profiles with value area, VPOC and shape letter (P / b / D)
• Naked VPOC rays that keep running right as magnets
• Weekly profile + the prior-week balance zone projected into the current week
• The thick green transferred value-area edge with its own explanation
• Daily VPOC staircase and the imbalance gauge in the panel
• Single-print zones, micro-balance boxes with the big P / b letter
• BUY / SELL pills, the full numbered reason stack printed next to the signal, entry / SL / TP1 / TP2 rails, risk and reward blocks, TP / SL / BE / TIME exit tags
• A permanent BEGINNER CARD on the chart plus a HOW TO READ manual — every pill, zone, rail, letter and panel row also has its own hover explanation, so nothing on this chart is unexplained
• Two colour modes: Design (navy, mint / cyan / gold) or Original TPO (the classic grey market-profile look with red VPOC rays and a white profile curve)

═══════════════════════════════
AUTOMATION
═══════════════════════════════
Create ONE alert with the condition "Any alert() function call" and paste your webhook URL. Every BUY, SELL, TP1_HIT, TP2_HIT, SL_HIT, BE_EXIT, TIME_STOP and ARMED event posts ready-to-use JSON containing id, symbol, action, setup, shape, qty, price, entry, sl, tp1, tp2, pdvah, pdval, timeframe and time — connect it to any bridge or bot without touching the code. Separate alertconditions for BUY, SELL and "any signal" are also available.

═══════════════════════════════
HOW TO USE IT
═══════════════════════════════
Built for an intraday execution timeframe: 1m to 15m, exactly like the original workflow (locate on the weekly and daily profiles, execute on a 1-minute chart). Index futures and index CFDs are the natural home (NQ, ES, DAX, Nikkei), but the profile engine derives its bin size from the average daily range, so gold, FX and crypto work out of the box. For index futures switch on "cash session only" and set the exchange session so the overnight trade does not smear the profiles.

Every input is documented with a tooltip that explains what it does and why it exists. Start with the defaults, then loosen step 2 or step 3 if you want more signals — and be aware that every filter you switch off moves you back towards the 70 % phase where this trigger simply does not pay.

═══════════════════════════════
NOTES
═══════════════════════════════
The entry logic is mechanical and reproducible. Stop distances, targets and the time stop are parameters, not gospel: size them to the instrument you trade. Profiles are built from the bars of the chart you are on, so a finer timeframe gives a finer profile. Hit rates quoted in the educational material behind this model refer to the full workflow including discretionary session context — treat the signals as a structured, disciplined framework, not a guarantee, and always validate on your own data before risking capital.

Open source. Feedback and improvement ideas are welcome.


WHY THESE PARTS BELONG TOGETHER

The point of control and the breakout trigger are combined because a breakout setup does not fail
because the setup is bad, it fails because it was taken in the wrong market phase. The VPOC locates
that phase: a break away from a freshly built point of control is a different trade from a break
back into an old one. The imbalance measurement is the third piece - it tells you whether the move
away from the VPOC was one-sided enough to be worth following.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════════
//  IMBALANCE BREAKOUT PRO  v1.0
//  1:1 rebuild of Tom Vorwald's "Die einfachste Trading-Strategie (80-90 % Trefferquote)"
//  (Trade The Traders, 2026-06-23) as a TradingView indicator -  design.
//
//  THE VIDEO IN ONE SENTENCE
//  A breakout only works in the ~30 % of market phases that are OUT OF BALANCE.
//  In the ~70 % balance phases the very same setup fails. So the whole edge is
//  LOCATION FIRST, trigger second - and that happens roughly ONCE PER DAY.
//
//  THE 7 CONFIRMATIONS (all mechanical, all shown in the panel checklist)
//   1 WEEKLY LOCATION   previous week's value area = the equilibrium. Price INSIDE
//                       = stand down. Price ABOVE VAH / BELOW VAL = imbalance = hunt.
//   2 EQ TEST + REJECT  the week opened outside, came back to TEST the weekly value
//                       area and was aggressively traded away from it again.
//   3 VPOC TREND        the sequence of daily VPOCs (cash session) rises / falls:
//                       "the distribution of equilibrium itself is trending".
//   4 PD VA BREAK       previous day's value-area edge is transferred to the entry
//                       timeframe and taken out with acceleration.
//   5 SINGLE PRINT      the impulse leg leaves prices that only ONE bar/TPO touched =
//                       aggressive buyers/sellers, nobody did business there.
//   6 P / b MICRO SHAPE the impulse + the small balance on top of it print a P (long)
//                       or a b (short): "aggressive buyers shifting equilibrium up".
//   7 TRIGGER           BREAK-IN (trend-continuation re-entry into the P/b balance) or
//                       BREAKOUT of the balance edge WITH A HIGHER/LOWER CLOSE.
//
//  Everything on this chart explains itself - hover any pill, rail, letter, zone,
//  panel row or the HOW TO READ label.
// ═══════════════════════════════════════════════════════════════════════════════════
indicator("Market Profile VPOC Breakout", "VPOC BREAKOUT", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 1000)

// ───────────────────────────────── PALETTE ─────────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)
color COL_PANEL  = color.rgb(10, 29, 46)
color COL_PANEL2 = color.rgb(15, 44, 66)
color COL_BULL   = color.rgb(126, 224, 208)
color COL_BEAR   = color.rgb(244, 44, 58)
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_GOLD2  = color.rgb(255, 236, 130)
color COL_GOLD3  = color.rgb(238, 190, 30)
color COL_GOLD4  = color.rgb(210, 160, 20)
color COL_GOLD5  = color.rgb(170, 125, 12)
color COL_GOLD6  = color.rgb(112, 82, 6)
color COL_GLINT  = color.rgb(255, 252, 214)
color COL_PINK   = color.rgb(255, 62, 130)
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)

// ───────────────────────────────── INPUTS ─────────────────────────────────────────
grpW = "1 - Location: weekly balance (video step 1+2)"
useWeek    = input.bool(true,  "Require weekly IMBALANCE (price outside prior-week value area)", group = grpW, tooltip = "The core message of the video: 'you must learn to read when the 70 % are present and when the 30 % are' - a breakout setup only works OUTSIDE the higher-timeframe balance. Price inside the previous week's value area = equilibrium = stand down.")
reqWkOpen  = input.bool(false, "Also require the WEEK to have OPENED outside", group = grpW, tooltip = "Video, NKD example: 'the trading open of this week took place ABOVE the equilibrium of this profile'. Strict mode - turn it on for the textbook version, off to also take mid-week breakouts.")
reqWkTest  = input.bool(true,  "Require TEST + aggressive REJECTION of the weekly value area", group = grpW, tooltip = "Video: 'in addition we tested the so-called value area ... he ran down here and was then aggressively traded back up'. That rejection is the proof that the market does not want to be in equilibrium any more.")
wkTestATR  = input.float(0.60, "Rejection strength (bar range in ATR)", minval = 0.1, step = 0.05, group = grpW, tooltip = "How aggressive the candle that leaves the weekly value area again has to be, measured in ATR(14) of the entry timeframe.")

grpV = "2 - Trend of equilibrium: daily VPOC sequence (video step 3)"
useVpoc    = input.bool(true, "Require a trending daily VPOC sequence", group = grpV, tooltip = "Video: 'the VPOC keeps rising ... so the distribution of the participants' equilibrium has a strongly rising tendency, the market is trending up. That is the information we need if we want fast trades WITH the trend.'")
vpN        = input.int(4, "VPOCs compared", minval = 2, maxval = 10, group = grpV, tooltip = "How many completed daily VPOCs are compared. 4 VPOCs = 3 steps of the staircase.")
vpStrict   = input.bool(false, "Strict (every step must be higher / lower)", group = grpV, tooltip = "Strict = a perfect staircase like in the video. Off = a 2/3 majority of the steps is enough, which is how real sessions usually look.")

grpP = "3 - Profile engine (value area 70 %, cash session)"
binsPerDay = input.int(40, "Price rows per average day range", minval = 12, maxval = 80, group = grpP, tooltip = "Bin size is derived from the average daily range, so the same setting works on DAX, NQ, Gold, FX and crypto. 60 rows is about the granularity of an exchange TPO profile.")
vaPct      = input.float(70, "Value area %", minval = 50, maxval = 90, step = 1, group = grpP, tooltip = "The value area holds ~70 % of the period's volume around the POC - the standard market-profile definition used in the video.")
useRTH     = input.bool(false, "Build profiles from cash session only", group = grpP, tooltip = "Video 03:22: 'here I only display the CASH SESSION'. Turn it on for index futures so the overnight session does not smear the profiles.")
sessStr    = input.session("0900-1730", "Cash session", group = grpP, tooltip = "Exchange time of the symbol. DAX/FDAX 0900-1730, ES/NQ 0930-1600, Nikkei 0900-1515.")
showWkProf = input.bool(true,  "Draw weekly profiles + balance zone", group = grpP, tooltip = "The LEFT pane of the video: one volume/TPO profile per week with its value area and VPOC. This is the higher-timeframe balance you locate the trade against.")
showPdProf = input.bool(true,  "Draw daily profiles (cash-session TPO look)", group = grpP, tooltip = "The RIGHT pane of the video: one profile per session with value area, VPOC and shape letter.")
histDays   = input.int(3, "Daily profiles drawn", minval = 1, maxval = 8, group = grpP, tooltip = "How many completed sessions keep their profile on the chart. Older ones are removed so the drawing budget stays free for signals.")
histWeeks  = input.int(1, "Weekly profiles drawn", minval = 1, maxval = 3, group = grpP, tooltip = "TradingView allows 500 boxes per script. Every profile row is one box, so keep the number of drawn profiles low enough that the signal graphics always have room.")
showVpocLn = input.bool(true,  "Draw the daily VPOC staircase", group = grpP, tooltip = "The staircase Tom draws over the rising VPOCs - the visual proof of a trending equilibrium.")
showPocRay = input.bool(true,  "Naked VPOC rays (extend every daily VPOC to the right)", group = grpP, tooltip = "The red horizontal lines in the video: every session's VPOC keeps running to the right as a magnet until price trades back into it.")
showDayLet = input.bool(true,  "P / b / D letter per session", group = grpP, tooltip = "The shape of each completed session: P = impulse up + balance on top, b = impulse down + balance at the bottom, D = symmetric balance day.")
profW      = input.float(0.13, "Histogram width (fraction of the period)", minval = 0.05, maxval = 0.6, step = 0.01, group = grpP, tooltip = "Keep it small so the profile never covers the candles.")
profStyle  = input.string("Design", "Profile colours", options = ["Design", "Original TPO (video look)"], group = grpP, tooltip = "Design = navy chart with mint / cyan / gold profiles (the  house style).\nOriginal TPO = the exact look of the market-profile platform in the video: dark grey chart, light grey TPO rows, blue value area, RED VPOC rays and a white profile curve.")
showCurve  = input.bool(true, "White profile curve (volume outline)", group = grpP, tooltip = "The thin outline that traces the shape of the profile - the line you actually read the P / b / D shape from.")
showOpenMk = input.bool(true, "Session open marker (green initial-balance bar)", group = grpP, tooltip = "The green vertical bar at the left edge of every session profile in the video: the opening range of the session.")

grpE = "4 - Execution: impulse, single print, P/b, trigger (video step 4-7)"
refMode    = input.string("Prior day value area", "Breakout reference level", options = ["Prior day value area", "Prior week value area", "Wider of both"], group = grpE, tooltip = "The level that gets transferred onto the entry timeframe. Video: 'we transfer this balance into the corresponding timeframe' - the previous day's value-area edge.")
impBars    = input.int(12, "Impulse window - bars", minval = 2, maxval = 40, group = grpE, tooltip = "How many bars the acceleration leg may take. Video: 'wait until the market can accelerate strongly'.")
impATR     = input.float(0.9, "Impulse size - x ATR", minval = 0.3, step = 0.1, group = grpE, tooltip = "How far the leg has to travel inside that window, in ATR(14). This is the 'boom' in the video.")
balMin     = input.int(3,  "Micro balance - min bars", minval = 2, maxval = 30, group = grpE, tooltip = "The small balance that forms on top of the impulse needs at least this many bars before it counts as balance.")
balMax     = input.int(45, "Micro balance - max bars", minval = 5, maxval = 200, group = grpE, tooltip = "If nothing breaks out within this many bars the setup goes stale and is discarded - the market lost its dynamic.")
balATR     = input.float(2.2, "Micro balance - max height x ATR", minval = 0.2, step = 0.1, group = grpE, tooltip = "A balance is a CONTAINED range. If it grows beyond this it is not a P/b structure any more and the setup is dropped.")
pocUpper   = input.float(0.57, "P-shape: POC above this fraction of the window", minval = 0.5, maxval = 0.85, step = 0.01, group = grpE, tooltip = "P = impulse up, balance ON TOP: the point of control sits in the upper part of the impulse+balance window. 0.57 = upper 43 %.")
pocLower   = input.float(0.43, "b-shape: POC below this fraction of the window", minval = 0.15, maxval = 0.5, step = 0.01, group = grpE, tooltip = "b = impulse down, balance AT THE BOTTOM. Anything between the two thresholds is a D (plain balance) and is not traded.")
reqSP      = input.bool(true, "Require SINGLE PRINTS in the impulse leg", group = grpE, tooltip = "Video 07:42: 'we see trading open here - SINGLE PRINT. That means aggressive buyers have entered the market.' A single print is a price row that only ONE bar / TPO ever touched.")
spMaxTouch = input.int(1, "Single print = row touched by max N bars", minval = 1, maxval = 3, group = grpE)
spMinBins  = input.int(2, "Minimum single-print rows ", minval = 1, maxval = 40, group = grpE)
useBreakIn = input.bool(true, "Trigger A: BREAK-IN (trend continuation)", group = grpE, tooltip = "Video 09:14: 'trend-continuing was exactly this BREAK-IN here'. Price dips back into the P/b balance and is bought / sold again immediately - the aggressive, earlier entry.")
useBreakOut= input.bool(true, "Trigger B: BREAKOUT with higher / lower close", group = grpE, tooltip = "Video 09:25: 'BREAKOUT I have here - with the higher closing price, and then I see how the market keeps climbing.' The confirmed entry: a CLOSE beyond the balance edge, never a wick.")
maxTrades  = input.int(2, "Max signals per session", minval = 1, maxval = 10, group = grpE, tooltip = "Video 00:05: 'unfortunately this model only works about ONCE A DAY'. Keep it at 1 for the original.")

grpR = "5 - Risk & management"
slMode     = input.string("Micro balance edge", "Stop loss at", options = ["Micro balance edge", "Impulse origin", "Reference level"], group = grpR, tooltip = "Balance edge = tightest, the structural invalidation. Impulse origin = the start of the acceleration leg. Reference level = the transferred prior value-area edge.")
slBufAtr   = input.float(0.25, "SL buffer (ATR multiple)", minval = 0.0, step = 0.05, group = grpR)
tp1R       = input.float(1.0, "TP1 (R multiple)", minval = 0.2, step = 0.1, group = grpR, tooltip = "First target in multiples of the initial risk. The stop then jumps to break-even.")
tp2R       = input.float(2.0, "TP2 (R multiple)", minval = 0.5, step = 0.1, group = grpR)
beAtTP1    = input.bool(true, "Move SL to break-even at TP1", group = grpR)
maxHold    = input.int(15, "Time stop (bars) - exit if it does not run", minval = 0, maxval = 500, group = grpR, tooltip = "Video 01:39: 'if you do not get out of the market IMMEDIATELY when it does not work, you very quickly get the exact opposite - a fast move against your direction.' 0 disables the time stop.")
showTrade  = input.bool(true, "Draw entry / SL / TP lines", group = grpR)
showRR     = input.bool(true, "Draw the risk / reward zones", group = grpR, tooltip = "Red block = the 1R risk, mint block = the reward to TP2. Instant read of the trade geometry.")

grpD = "6 - Design"
useTheme   = input.bool(true, "Dark chart theme (navy + mint/red candles)", group = grpD)
useRegime  = input.bool(true, "Regime tint (mint = imbalance up, red = down, gold = balance)", group = grpD, tooltip = "A very subtle background wash that tells you at a glance which of the two market phases you are in. This is step 1 of the video, painted onto the chart.")
showDaySep = input.bool(true, "Day separators", group = grpD)
showPanel  = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos   = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)
showReason = input.bool(true, "Print the reason stack on the chart", group = grpD, tooltip = "Writes the numbered WHY next to every signal directly on the chart - no hovering needed.")
showArmed  = input.bool(true, "Show SETUP ARMED marker while a P/b balance forms", group = grpD)
showLegend = input.bool(true, "HOW TO READ label", group = grpD)
teachMode  = input.bool(true, "TEACH MODE - permanent beginner legend on the chart", group = grpD, tooltip = "Prints a always-visible explanation card on the chart: what every colour, zone, line and letter means, and the 7 steps in order. Switch it off once you know the model by heart.")

grpA = "7 - Alerts & webhook (automation)"
alSignals  = input.bool(true, "Alert on BUY / SELL (webhook JSON)", group = grpA, tooltip = "Create ONE alert with condition 'Any alert() function call' and paste your webhook URL. Every event posts ready-to-use JSON.")
alManage   = input.bool(true, "Alert on TP1 / TP2 / SL / BE / TIME", group = grpA)
alArmed    = input.bool(false, "Alert when a setup gets ARMED (pre-signal)", group = grpA, tooltip = "Video 11:12: 'you can lay yourself a SIGNAL, and when the signal comes you watch the market'. This is that early warning.")
whId       = input.string("IMBALANCE-BREAKOUT-PRO", "Webhook strategy ID", group = grpA)
whQty      = input.float(1.0, "Webhook quantity field", minval = 0.0, step = 0.01, group = grpA)

// ───────────────────────────────── BASICS ─────────────────────────────────────────
float atr14 = ta.atr(14)
bool intradayOK = timeframe.in_seconds() <= 3600 and not timeframe.isdwm
bool inSess = not useRTH or not na(time(timeframe.period, sessStr))

// Bin size calibrates itself on the PREVIOUS session's range - no external request,
// so it is correct on futures, FX, gold and crypto alike and can never degenerate.

// ── profile palette: dark house style, or the original market-profile look ──────────
bool vidMode  = profStyle == "Original TPO (video look)"
color C_BGX   = vidMode ? color.rgb(40, 40, 40) : COL_BG
color C_ROW   = vidMode ? color.rgb(208, 208, 208) : COL_GREY
color C_ROWVA = vidMode ? color.rgb(120, 158, 210) : COL_CYAN
color C_POC   = vidMode ? color.rgb(232, 58, 58) : COL_GOLD
color C_RAY   = vidMode ? color.rgb(232, 58, 58) : COL_BEAR
color C_CURVE = vidMode ? color.rgb(242, 242, 242) : COL_CYAN
color C_OPEN  = vidMode ? color.rgb(52, 200, 92) : COL_BULL
color C_UP    = vidMode ? color.rgb(190, 208, 228) : COL_BULL
color C_DN    = vidMode ? color.rgb(214, 74, 74) : COL_BEAR

bgcolor(useTheme ? color.new(C_BGX, 0) : na, title = "Theme background")
bgcolor(showDaySep and timeframe.change("D") ? color.new(COL_CYAN, 86) : na, title = "Session separator")
barcolor(useTheme ? (close >= open ? C_UP : C_DN) : na, title = "Theme candles")

// navy fill for the empty area right of the last candle. Bounded on purpose:
// oversized drawings stretch TradingView's auto price scale and flatten the chart.
var box marginBox = na
float mTop = ta.highest(high, 300) + (ta.highest(high, 300) - ta.lowest(low, 300)) * 0.6
float mBot = ta.lowest(low, 300) - (ta.highest(high, 300) - ta.lowest(low, 300)) * 0.6
if useTheme and na(marginBox)
    marginBox := box.new(bar_index + 1, mTop, bar_index + 300, mBot, border_color = color.new(C_BGX, 0), border_width = 1, bgcolor = color.new(C_BGX, 0))
if useTheme and not na(marginBox) and barstate.islast
    box.set_left(marginBox, bar_index + 1)
    box.set_right(marginBox, bar_index + 300)
    box.set_top(marginBox, mTop)
    box.set_bottom(marginBox, mBot)

var label tfWarn = na
if not intradayOK and na(tfWarn) and barstate.islast
    tfWarn := label.new(bar_index, close, "IMBALANCE BREAKOUT PRO\nUse an intraday timeframe (1m - 15m).\nThe video trades this on a 1-minute entry chart;\nthe weekly and daily profiles are built from intraday bars.", style = label.style_label_left, color = color.new(COL_PANEL, 0), textcolor = COL_GOLD, size = size.normal)
// ─────────────────────── PROFILE ENGINE (pure functions) ──────────────────────────
// Range-based bins over the period's own high/low: the classic volume/TPO profile.
// Returns the row volumes, the TPO touch count per row, POC, value-area edges and
// the row height, so everything downstream (drawing, shape, single prints) agrees.
f_prof(array<float> aHi, array<float> aLo, array<float> aVo, int nB, float pLo, float pHi, float vaP) =>
    array<float> vols = array.new_float(nB, 0.0)
    array<int> touch = array.new_int(nB, 0)
    float rng = pHi - pLo
    float binSz = rng > 0 ? rng / nB : na
    int n = array.size(aHi)
    if rng > 0 and n > 0
        for i = 0 to n - 1
            float h = array.get(aHi, i)
            float l = array.get(aLo, i)
            float v = array.get(aVo, i)
            int j0 = math.max(0, math.min(nB - 1, int(math.floor((l - pLo) / binSz))))
            int j1 = math.max(0, math.min(nB - 1, int(math.floor((h - pLo) / binSz))))
            float per = v / (j1 - j0 + 1)
            for j = j0 to j1
                array.set(vols, j, array.get(vols, j) + per)
                array.set(touch, j, array.get(touch, j) + 1)
    float total = 0.0
    int poc = 0
    float pv = -1.0
    for i = 0 to nB - 1
        float vv = array.get(vols, i)
        total += vv
        if vv > pv
            pv := vv
            poc := i
    float acc = pv
    int up = poc + 1
    int dn = poc - 1
    while acc < total * vaP / 100 and (up < nB or dn >= 0)
        float vu = up < nB ? array.get(vols, up) : -1.0
        float vd = dn >= 0 ? array.get(vols, dn) : -1.0
        if vu >= vd
            acc += vu
            up += 1
        else
            acc += vd
            dn -= 1
    [vols, touch, poc, math.max(0, dn + 1), math.min(nB - 1, up - 1), total, pv, binSz]

// micro profile of the last winLen bars -> P / b / D
f_micro(int winLen, int nB, float pUp, float pDn, float vaP) =>
    array<float> mh = array.new_float()
    array<float> ml = array.new_float()
    array<float> mv = array.new_float()
    float wh = na
    float wl = na
    for i = 0 to winLen - 1
        float h = high[i]
        float l = low[i]
        array.push(mh, h)
        array.push(ml, l)
        array.push(mv, nz(volume[i], 0) <= 0 ? 1.0 : volume[i])
        wh := na(wh) ? h : math.max(wh, h)
        wl := na(wl) ? l : math.min(wl, l)
    string shp = "-"
    float pos = na
    float pocPx = na
    if not na(wh) and wh > wl
        [vols, touch, poc, vaLo, vaHi, tot, pv, bs] = f_prof(mh, ml, mv, nB, wl, wh, vaP)
        pocPx := wl + (poc + 0.5) * bs
        pos := (pocPx - wl) / (wh - wl)
        shp := pos >= pUp ? "P" : pos <= pDn ? "b" : "D"
    [shp, pocPx, wh, wl, pos]

// single prints: rows of the running session that only N bar(s) ever touched,
// counted inside the impulse leg
f_singlePrint(array<float> aHi, array<float> aLo, int nB, float pLo, float pHi, float legLo, float legHi, int maxTouch) =>
    int cnt = 0
    float bot = na
    float top = na
    float rng = pHi - pLo
    if rng > 0 and array.size(aHi) > 0
        float bs = rng / nB
        array<int> touch = array.new_int(nB, 0)
        int n = array.size(aHi)
        for i = 0 to n - 1
            int j0 = math.max(0, math.min(nB - 1, int(math.floor((array.get(aLo, i) - pLo) / bs))))
            int j1 = math.max(0, math.min(nB - 1, int(math.floor((array.get(aHi, i) - pLo) / bs))))
            for j = j0 to j1
                array.set(touch, j, array.get(touch, j) + 1)
        int k0 = math.max(0, math.min(nB - 1, int(math.floor((legLo - pLo) / bs))))
        int k1 = math.max(0, math.min(nB - 1, int(math.floor((legHi - pLo) / bs))))
        for k = k0 to k1
            int c = array.get(touch, k)
            if c > 0 and c <= maxTouch
                cnt += 1
                bot := na(bot) ? pLo + k * bs : math.min(bot, pLo + k * bs)
                top := na(top) ? pLo + (k + 1) * bs : math.max(top, pLo + (k + 1) * bs)
    [cnt, bot, top]

f_vpocTrend(array<float> a, int n, bool strict) =>
    int sz = array.size(a)
    int steps = 0
    int upS = 0
    int dnS = 0
    if sz >= 2
        int take = math.min(n, sz)
        for i = sz - take + 1 to sz - 1
            float p = array.get(a, i - 1)
            float c = array.get(a, i)
            steps += 1
            if c > p
                upS += 1
            else if c < p
                dnS += 1
    int need = strict ? steps : math.max(1, int(math.ceil(steps * 0.66)))
    bool up = steps > 0 and upS >= need
    bool dn = steps > 0 and dnS >= need
    [up, dn, upS, dnS, steps]

// ─────────────────────────── PERIOD COLLECTORS ────────────────────────────────────
// timeframe.change() is session-aware and works on futures, FX and crypto alike;
// ta.change(time("D")) silently fails on symbols with an extended session.
bool newDay = timeframe.change("D")
bool newWeek = timeframe.change("W")

var array<float> cHi = array.new_float()
var array<float> cLo = array.new_float()
var array<float> cVo = array.new_float()
var array<float> kHi = array.new_float()
var array<float> kLo = array.new_float()
var array<float> kVo = array.new_float()

var float dHi = na
var float dLo = na
var int dStart = na
var int dBars = 0
var float wHi = na
var float wLo = na
var int wStart = na
var int wBars = 0

var float pdVAH = na
var float pdVAL = na
var float pdPOC = na
var float pwVAH = na
var float pwVAL = na
var float pwPOC = na
var array<float> vpocs = array.new_float()

var string wkOpenLoc = "-"
var bool wkTestUp = false
var bool wkTestDn = false
var bool wkTouchUp = false
var bool wkTouchDn = false
var int tradesToday = 0

var array<box> dayBoxes = array.new<box>()
var array<int> dayBoxN = array.new_int()
var array<box> wkBoxes = array.new<box>()
var array<int> wkBoxN = array.new_int()
var array<line> pocRays = array.new<line>()
var array<line> curveLn = array.new<line>()
var array<int> curveN = array.new_int()
var array<label> dayTags = array.new<label>()
var array<label> vpDots = array.new<label>()
var line refLine = na
var label refLbl = na
var bool vpBiasUp = false
var bool vpBiasDn = false
var box wkZone = na
var line wkPocLn = na
var line pdVAHln = na
var line pdVALln = na
var line pdPOCln = na
var label pdVAHlb = na
var label pdVALlb = na
var label pdPOClb = na
var int lastVpX = na
var float lastVpY = na

// keep only the last `keep` periods of drawings on the chart
f_trimBoxes(array<box> boxes, array<int> counts, int keep) =>
    while array.size(counts) > keep
        int n = array.shift(counts)
        for i = 1 to n
            if array.size(boxes) > 0
                box.delete(array.shift(boxes))

f_trimLineGroups(array<line> lns, array<int> counts, int keep) =>
    while array.size(counts) > keep
        int n = array.shift(counts)
        for i = 1 to n
            if array.size(lns) > 0
                line.delete(array.shift(lns))

f_trimLines(array<line> a, int keep) =>
    while array.size(a) > keep
        line.delete(array.shift(a))

f_trimLabels(array<label> a, int keep) =>
    while array.size(a) > keep
        label.delete(array.shift(a))

// ══════════════════════════ WEEK CLOSE - weekly profile ═══════════════════════════
if newWeek and intradayOK and wBars > 5 and not na(wHi) and wHi > wLo
    [wVols, wTouch, wPoc, wVaLo, wVaHi, wTot, wMaxV, wBs] = f_prof(kHi, kLo, kVo, binsPerDay, wLo, wHi, vaPct)
    pwPOC := wLo + (wPoc + 0.5) * wBs
    pwVAH := math.min(wLo + (wVaHi + 1) * wBs, wHi)
    pwVAL := math.max(wLo + wVaLo * wBs, wLo)
    if showWkProf and wMaxV > 0
        int wStartX = bar_index
        int wid = math.max(3, math.min(60, math.round(dBars * profW * 1.2)))
        int added = 0
        for i = 0 to binsPerDay - 1
            float v = array.get(wVols, i) / wMaxV
            if v > 0.07
                float bBot = wLo + i * wBs
                float bMid = bBot + wBs / 2
                bool isPoc = i == wPoc
                bool inVA = i >= wVaLo and i <= wVaHi
                color rc = isPoc ? C_POC : inVA ? C_ROWVA : C_ROW
                array.push(wkBoxes, box.new(wStartX, bBot + wBs, wStartX + math.max(1, math.round(v * wid)), bBot, border_color = color.new(rc, vidMode ? 40 : 80), border_width = 1, bgcolor = color.new(rc, isPoc ? 20 : inVA ? (vidMode ? 45 : 66) : (vidMode ? 55 : 82))))
                added += 1
        array.push(wkBoxN, added)
        f_trimBoxes(wkBoxes, wkBoxN, histWeeks)

// ══════════════════════════ DAY CLOSE - session profile ═══════════════════════════
if newDay and intradayOK and dBars > 5 and not na(dHi) and dHi > dLo
    [qVols, qTouch, qPoc, qVaLo, qVaHi, qTot, qMaxV, qBs] = f_prof(cHi, cLo, cVo, binsPerDay, dLo, dHi, vaPct)
    float qPocPx = dLo + (qPoc + 0.5) * qBs
    pdPOC := qPocPx
    pdVAH := math.min(dLo + (qVaHi + 1) * qBs, dHi)
    pdVAL := math.max(dLo + qVaLo * qBs, dLo)
    array.push(vpocs, qPocPx)
    if array.size(vpocs) > 30
        array.shift(vpocs)
    int dsx = math.max(nz(dStart, bar_index), bar_index - 4000)
    int midX = dsx + math.max(1, dBars) / 2
    // the VPOC staircase - Tom's red steps over the rising VPOCs
    if showVpocLn
        if not na(lastVpX)
            line.new(lastVpX, lastVpY, midX, qPocPx, color = qPocPx > lastVpY ? color.new(COL_BULL, 45) : qPocPx < lastVpY ? color.new(COL_BEAR, 45) : color.new(COL_GOLD, 55), width = 1, style = line.style_dashed)
        array.push(vpDots, label.new(midX, qPocPx, "", style = label.style_circle, color = color.new(qPocPx > nz(lastVpY, qPocPx) ? COL_BULL : COL_BEAR, 25), size = size.tiny, tooltip = "DAILY VPOC " + str.tostring(qPocPx, format.mintick) + "\nThe price where this session did the most business.\nA rising sequence of VPOCs means the equilibrium itself is\ntrending up - the green light for fast trades WITH the trend\n(video step 3). Flat or overlapping VPOCs = balance = stand down."))
        f_trimLabels(vpDots, histDays)
    lastVpX := midX
    lastVpY := qPocPx
    // shape of the completed session
    float dRng = dHi - dLo
    float pocPos = (qPocPx - dLo) / dRng
    string dShape = pocPos >= pocUpper ? "P" : pocPos <= pocLower ? "b" : "D"
    color shCol = dShape == "P" ? COL_BULL : dShape == "b" ? COL_BEAR : COL_GOLD
    if showPdProf and qMaxV > 0
        int wid = math.max(3, math.round(dBars * profW))
        int added = 0
        int curved = 0
        float prevTipX = na
        float prevTipY = na
        for i = 0 to binsPerDay - 1
            float v = array.get(qVols, i) / qMaxV
            if v > 0.06
                float bBot = dLo + i * qBs
                float bMid = bBot + qBs / 2
                bool isPoc = i == qPoc
                bool inVA = i >= qVaLo and i <= qVaHi
                color rc = isPoc ? C_POC : inVA ? (vidMode ? C_ROWVA : shCol) : C_ROW
                int tipX = dsx + math.max(1, math.round(v * wid))
                array.push(dayBoxes, box.new(dsx, bBot + qBs, tipX, bBot, border_color = color.new(rc, vidMode ? 40 : 78), border_width = 1, bgcolor = color.new(rc, isPoc ? 18 : inVA ? (vidMode ? 45 : 66) : (vidMode ? 55 : 84))))
                added += 1
                if showCurve and not na(prevTipX)
                    array.push(curveLn, line.new(int(prevTipX), prevTipY, tipX, bMid, color = color.new(C_CURVE, 30), width = 1))
                    curved += 1
                prevTipX := tipX
                prevTipY := bMid
        array.push(dayBoxes, box.new(dsx, pdVAH, bar_index - 1, pdVAL, border_color = color.new(shCol, 60), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(shCol, 96), text = "VALUE AREA " + str.tostring(vaPct, "#") + "%", text_size = size.tiny, text_color = color.new(shCol, 55), text_halign = text.align_right, text_valign = text.align_bottom))
        added += 1
        if showOpenMk
            array.push(dayBoxes, box.new(dsx, pdVAH, dsx, pdVAL, border_color = color.new(C_OPEN, 20), border_width = 3, bgcolor = color.new(C_OPEN, 100)))
            added += 1
        array.push(dayBoxN, added)
        f_trimBoxes(dayBoxes, dayBoxN, histDays)
        if showCurve
            array.push(curveN, curved)
            f_trimLineGroups(curveLn, curveN, math.min(histDays, 3))
    // naked VPOC ray - the red magnet line
    if showPocRay
        array.push(pocRays, line.new(dsx, qPocPx, bar_index + 3, qPocPx, color = color.new(C_RAY, 30), style = line.style_solid, width = 1))
        f_trimLines(pocRays, histDays)
    // session shape letter
    if showDayLet
        array.push(dayTags, label.new(midX, dShape == "b" ? dLo - dRng * 0.06 : dHi + dRng * 0.06, dShape, style = label.style_none, textcolor = color.new(shCol, 25), size = size.large, tooltip = dShape == "P" ? "P SESSION - impulse UP, balance ON TOP.\nBuyers shifted their equilibrium upwards: the thin tail below is the\nsingle-print impulse nobody traded in. Long bias for the next session." : dShape == "b" ? "b SESSION - impulse DOWN, balance AT THE BOTTOM.\nSellers shifted their equilibrium downwards. Short bias for the next session." : "D SESSION - symmetric balance, fat POC in the middle.\nBoth sides are happy, fair price found. This is the 70 % market phase:\nbreakout setups do NOT pay here - stand down and wait for imbalance."))
        f_trimLabels(dayTags, histDays)

// ───────────────────── NEW WEEK: rearm the location filter ────────────────────────
if newWeek and intradayOK
    array.clear(kHi)
    array.clear(kLo)
    array.clear(kVo)
    wHi := na
    wLo := na
    wStart := na
    wBars := 0
    wkTestUp := false
    wkTestDn := false
    wkTouchUp := false
    wkTouchDn := false
    wkOpenLoc := na(pwVAH) ? "-" : open > pwVAH ? "ABOVE" : open < pwVAL ? "BELOW" : "INSIDE"
    if not na(pwVAH) and showWkProf
        color zc = wkOpenLoc == "INSIDE" ? COL_GOLD : wkOpenLoc == "ABOVE" ? COL_BULL : COL_BEAR
        wkZone := box.new(bar_index, pwVAH, bar_index + 1, pwVAL, border_color = color.new(zc, 45), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(zc, 94), text = "PRIOR WEEK BALANCE - VALUE AREA " + str.tostring(vaPct, "#") + "%", text_size = size.tiny, text_color = color.new(zc, 40), text_halign = text.align_right, text_valign = text.align_top)
        wkPocLn := line.new(bar_index, pwPOC, bar_index + 1, pwPOC, color = color.new(COL_GOLD, 35), style = line.style_dashed, width = 1)
        label.new(bar_index, pwVAH, wkOpenLoc == "INSIDE" ? "WEEK OPENED INSIDE - BALANCE - NO TRADE" : "WEEK OPENED " + wkOpenLoc + " - IMBALANCE - HUNT " + (wkOpenLoc == "ABOVE" ? "LONGS" : "SHORTS"), style = label.style_label_down, color = color.new(COL_PANEL, 15), textcolor = zc, size = size.small, tooltip = "VIDEO STEP 1 - LOCATION.\nThe shaded zone is LAST WEEK'S VALUE AREA = the equilibrium,\nthe gold dashed line is its VPOC.\n\nPrice INSIDE the zone  = the 70 % market phase. A breakout setup\n                         has a low probability here, so stand down.\nPrice ABOVE / BELOW it = the 30 % market phase = imbalance.\n                         Only here do fast breakout trades pay.\n\n'You must learn to read when the 70 % are present and when the\n30 % are - that is the game changer for extremely high hit rates.'")

// ─────────────────────── NEW DAY: rearm the day engine ────────────────────────────
if newDay and intradayOK
    array.clear(cHi)
    array.clear(cLo)
    array.clear(cVo)
    dHi := na
    dLo := na
    dStart := na
    dBars := 0
    tradesToday := 0
    if not na(pdVAH)
        // yesterday's tags would otherwise pile up day after day
        if not na(pdVAHlb)
            label.delete(pdVAHlb)
            label.delete(pdVALlb)
            label.delete(pdPOClb)
        if not na(refLbl)
            label.delete(refLbl)
        pdVAHln := line.new(bar_index, pdVAH, bar_index + 1, pdVAH, color = color.new(COL_BULL, 25), style = line.style_dashed, width = 2)
        pdVALln := line.new(bar_index, pdVAL, bar_index + 1, pdVAL, color = color.new(COL_BEAR, 25), style = line.style_dashed, width = 2)
        pdPOCln := line.new(bar_index, pdPOC, bar_index + 1, pdPOC, color = color.new(COL_GOLD, 40), style = line.style_dotted, width = 1)
        pdVAHlb := label.new(bar_index + 1, pdVAH, "PD VAH", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_BULL, size = size.tiny, tooltip = "PREVIOUS DAY VALUE AREA HIGH - the transferred balance edge.\nVideo step 4: 'we transfer this balance into the corresponding\ntimeframe' and wait for the market to LEAVE it upwards with\nacceleration. This is the level a long breakout has to clear.")
        pdVALlb := label.new(bar_index + 1, pdVAL, "PD VAL", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_BEAR, size = size.tiny, tooltip = "PREVIOUS DAY VALUE AREA LOW - the mirror level for shorts.\nA break DOWN through here with acceleration + single prints +\na b-shape is the short version of the setup.")
        // ── THE transferred balance edge: the thick green line of the video ──
        bool longBias = vpBiasUp or (not vpBiasDn and close > pdPOC)
        float rl = longBias ? pdVAH : pdVAL
        refLine := line.new(bar_index, rl, bar_index + 1, rl, color = color.rgb(0, 230, 90), style = line.style_solid, width = 3)
        refLbl := label.new(bar_index + 1, rl, (longBias ? "▲ " : "▼ ") + "TRANSFERRED BALANCE EDGE · PRIOR DAY VA " + (longBias ? "HIGH" : "LOW") + " " + str.tostring(rl, format.mintick), style = label.style_label_left, color = color.new(COL_PANEL, 10), textcolor = color.rgb(0, 230, 90), size = size.small, tooltip = "VIDEO STEP 4 - THE LINE EVERYTHING HAPPENS AT.\n'We transfer this balance into the corresponding timeframe' - the edge of\nyesterday's value area, drawn onto the entry chart exactly like the thick\ngreen line in the video.\n\nFOR BEGINNERS: below this line the market is still inside yesterday's\nfair-price area = normal, boring, two-sided trade. The moment price\nACCELERATES through it and then builds a small balance on the other side,\nthe market has left fair value: that is the only place where a breakout\nhas an 80-90 % hit rate.\nWhat you wait for: acceleration through the line, single prints in the leg,\na P (long) or b (short) micro balance, then a CLOSE beyond that balance.")
        pdPOClb := label.new(bar_index + 1, pdPOC, "PD VPOC", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_GOLD, size = size.tiny, tooltip = "PREVIOUS DAY VPOC - yesterday's fair price.\nIts sequence day after day is the 'trend of equilibrium' (step 3):\nrising VPOCs = long bias, falling = short bias,\nflat or overlapping = balance = stand down.")

// collect this bar into the session and week buffers
if intradayOK and inSess
    if na(dStart)
        dStart := bar_index
    if na(wStart)
        wStart := bar_index
    dHi := math.max(nz(dHi, high), high)
    dLo := math.min(nz(dLo, low), low)
    wHi := math.max(nz(wHi, high), high)
    wLo := math.min(nz(wLo, low), low)
    float vv = nz(volume, 0) <= 0 ? 1.0 : volume
    array.push(cHi, high)
    array.push(cLo, low)
    array.push(cVo, vv)
    array.push(kHi, high)
    array.push(kLo, low)
    array.push(kVo, vv)
    dBars += 1
    wBars += 1

if not na(pdVAHln) and not newDay
    line.set_x2(pdVAHln, bar_index)
    line.set_x2(pdVALln, bar_index)
    line.set_x2(pdPOCln, bar_index)
    label.set_x(pdVAHlb, bar_index)
    label.set_x(pdVALlb, bar_index)
    label.set_x(pdPOClb, bar_index)
if not na(refLine) and not newDay
    line.set_x2(refLine, bar_index + 2)
    label.set_x(refLbl, bar_index + 2)
if not na(wkZone) and not newWeek
    box.set_right(wkZone, bar_index)
    line.set_x2(wkPocLn, bar_index)

// naked VPOC rays keep running to the right
if showPocRay and barstate.islast and array.size(pocRays) > 0
    for i = 0 to array.size(pocRays) - 1
        line.set_x2(array.get(pocRays, i), bar_index + 3)

// ════════════════════ STEP 1+2: weekly location & rejection ═══════════════════════
float tolW = atr14 * 0.15
if intradayOK and not na(pwVAH)
    if close[1] > pwVAH and low <= pwVAH + tolW
        wkTouchUp := true
    if close[1] < pwVAL and high >= pwVAL - tolW
        wkTouchDn := true
    if wkTouchUp and close > pwVAH and close > open and (high - low) >= atr14 * wkTestATR
        wkTestUp := true
    if wkTouchDn and close < pwVAL and close < open and (high - low) >= atr14 * wkTestATR
        wkTestDn := true

bool wkImbUp = not na(pwVAH) and close > pwVAH
bool wkImbDn = not na(pwVAL) and close < pwVAL
string wkLoc = na(pwVAH) ? "-" : wkImbUp ? "IMBALANCE UP" : wkImbDn ? "IMBALANCE DOWN" : "BALANCE (70 %)"

bgcolor(useTheme and useRegime and not na(pwVAH) ? color.new(wkImbUp ? COL_BULL : wkImbDn ? COL_BEAR : COL_GOLD, 95) : na, title = "Regime tint")

bool g1Up = not useWeek or (wkImbUp and (not reqWkOpen or wkOpenLoc == "ABOVE"))
bool g1Dn = not useWeek or (wkImbDn and (not reqWkOpen or wkOpenLoc == "BELOW"))
bool g2Up = not reqWkTest or wkTestUp
bool g2Dn = not reqWkTest or wkTestDn

// ══════════════════════ STEP 3: trend of equilibrium (VPOC) ═══════════════════════
[vpUp, vpDn, vpUpS, vpDnS, vpSteps] = f_vpocTrend(vpocs, vpN, vpStrict)
vpBiasUp := vpUp
vpBiasDn := vpDn
bool g3Up = not useVpoc or vpUp
bool g3Dn = not useVpoc or vpDn

// ═══════════════ STEP 4: the transferred reference level (prior VA edge) ══════════
float refUp = refMode == "Prior week value area" ? pwVAH : refMode == "Wider of both" ? (na(pdVAH) ? pwVAH : na(pwVAH) ? pdVAH : math.max(pdVAH, pwVAH)) : pdVAH
float refDn = refMode == "Prior week value area" ? pwVAL : refMode == "Wider of both" ? (na(pdVAL) ? pwVAL : na(pwVAL) ? pdVAL : math.min(pdVAL, pwVAL)) : pdVAL
bool g4Up = not na(refUp) and close > refUp
bool g4Dn = not na(refDn) and close < refDn

// ════════════════ STEP 5-7: impulse - single print - P/b - trigger ═══════════════
var int st = 0
var int stDir = 0
var float impLow = na
var float impHigh = na
var float balHi = na
var float balLo = na
var int balStart = na
var int balN = 0
var string micShape = "-"
var int spCnt = 0
var float spBot = na
var float spTop = na
var label armLab = na
var bool armedAlert = false

var int tDir = 0
var float tEntry = na
var float tSL = na
var float tTP1 = na
var float tTP2 = na
var bool tp1Done = false
var int tBar = na
var string tSetup = "-"
var string sigTxt = "FLAT - SCANNING"
var int winCnt = 0
var int lossCnt = 0

bool buySig = false
bool sellSig = false
bool tp1Ev = false
bool tp2Ev = false
bool slEv = false
bool timeEv = false
bool armEv = false

float hiN = ta.highest(high, impBars)
float loN = ta.lowest(low, impBars)
float rngN = hiN - loN
bool impUp = rngN >= atr14 * impATR and close >= loN + rngN * 0.65
bool impDn = rngN >= atr14 * impATR and close <= loN + rngN * 0.35

f_reasons(int dirI, string trig, string shp, int sp, string wkL, int steps1, int steps, float lvl) =>
    "WHY THIS " + (dirI == 1 ? "BUY" : "SELL") + "?   Tom Vorwald model - 80-90 % hit rate - about 1x per day\n" +
     "1 LOCATION      " + wkL + ": price is OUTSIDE last week's value area, so we\n" +
     "                are in the 30 % market phase where breakouts actually work.\n" +
     "2 EQ TEST       the weekly equilibrium was tested and " + (dirI == 1 ? "aggressively bought" : "aggressively sold") + " away again.\n" +
     "3 VPOC TREND    " + str.tostring(steps1) + "/" + str.tostring(steps) + " daily VPOC steps " + (dirI == 1 ? "UP" : "DOWN") + ": the equilibrium itself is trending.\n" +
     "4 LEVEL         prior value-area edge " + str.tostring(lvl, format.mintick) + " left with acceleration.\n" +
     "5 SINGLE PRINT  " + str.tostring(sp) + " price rows touched by one bar only = aggressive " + (dirI == 1 ? "buyers" : "sellers") + ".\n" +
     "6 SHAPE         " + shp + ": impulse plus balance " + (dirI == 1 ? "ON TOP" : "AT THE BOTTOM") + " - they are shifting\n" +
     "                equilibrium " + (dirI == 1 ? "upwards" : "downwards") + " (the PBD concept).\n" +
     "7 TRIGGER       " + trig + "\n" +
     "RISK            this is a FAST trade. No follow-through = out immediately."

f_tradeLines(int dirI, float e, float s, float t1, float t2) =>
    if showRR
        box.new(bar_index, dirI == 1 ? e : s, bar_index + 30, dirI == 1 ? s : e, border_color = color.new(COL_BEAR, 55), border_width = 1, bgcolor = color.new(COL_BEAR, 88), text = "RISK 1R", text_size = size.tiny, text_color = color.new(COL_BEAR, 25), text_halign = text.align_right, text_valign = dirI == 1 ? text.align_bottom : text.align_top)
        box.new(bar_index, dirI == 1 ? t2 : e, bar_index + 30, dirI == 1 ? e : t2, border_color = color.new(COL_BULL, 55), border_width = 1, bgcolor = color.new(COL_BULL, 90), text = "REWARD " + str.tostring(tp2R, "#.#") + "R", text_size = size.tiny, text_color = color.new(COL_BULL, 20), text_halign = text.align_right, text_valign = dirI == 1 ? text.align_top : text.align_bottom)
    line.new(bar_index, e, bar_index + 30, e, color = COL_GOLD, style = line.style_solid, width = 2)
    line.new(bar_index, s, bar_index + 30, s, color = COL_PINK, style = line.style_dashed, width = 1)
    line.new(bar_index, t1, bar_index + 30, t1, color = COL_BULL, style = line.style_dashed, width = 1)
    line.new(bar_index, t2, bar_index + 30, t2, color = COL_CYAN, style = line.style_dashed, width = 2)
    label.new(bar_index + 30, e, "ENTRY", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_GOLD, size = size.tiny, tooltip = "ENTRY = close of the trigger candle (break-in, or breakout with a higher / lower close).")
    label.new(bar_index + 30, s, "SL", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_PINK, size = size.tiny, tooltip = "STOP = structural invalidation (micro-balance edge / impulse origin /\nreference level) plus an ATR buffer. If this trades, the proof from\nthe video is gone and the idea was simply wrong.")
    label.new(bar_index + 30, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_BULL, size = size.tiny, tooltip = "TP1 = first R multiple. The stop jumps to break-even here, so the runner is risk-free.")
    label.new(bar_index + 30, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R", style = label.style_label_left, color = color.new(COL_PANEL, 15), textcolor = COL_CYAN, size = size.tiny, tooltip = "TP2 = the explosive extension the model hunts:\n'then it explosively makes my trade available'.")

f_signalDraw(int dirI, string setup, float e, float s, float t1, float t2, string why, float sBot, float sTop, int bStart, float bHi, float bLo, string shp) =>
    if not na(sBot) and not na(sTop) and sTop > sBot
        box.new(math.max(0, bStart - impBars), sTop, bar_index, sBot, border_color = color.new(COL_CYAN, 50), border_width = 1, bgcolor = color.new(COL_CYAN, 88), text = "SINGLE PRINT", text_size = size.tiny, text_color = color.new(COL_CYAN, 20), text_halign = text.align_left, text_valign = text.align_center)
    box.new(bStart, bHi, bar_index, bLo, border_color = color.new(dirI == 1 ? COL_BULL : COL_BEAR, 20), border_width = 2, bgcolor = color.new(dirI == 1 ? COL_BULL : COL_BEAR, 92))
    label.new(bStart + math.max(1, (bar_index - bStart) / 2), dirI == 1 ? bHi : bLo, shp, style = label.style_none, textcolor = dirI == 1 ? COL_BULL : COL_BEAR, size = size.huge, tooltip = shp == "P" ? "P-SHAPE - 'and he gives us a wonderful P'.\nFast impulse UP, then the balance sits ON TOP of it.\nThe thin tail underneath are the single prints: nobody did business\nthere. Aggressive buyers have shifted their equilibrium upwards -\nthat is real purchasing power and dynamic.\n\nThis is the PBD concept - the model Patrick Nill won the World Cup\nChampionship of Futures Trading with twice." : "b-SHAPE - the mirror image.\nFast impulse DOWN, balance AT THE BOTTOM, single prints above.\nAggressive sellers have shifted their equilibrium downwards.")
    string body = dirI == 1 ? "  BUY ▲  \n" + setup : "  SELL ▼  \n" + setup
    string tip = why + "\n-----------------\nEntry " + str.tostring(e, format.mintick) + "\nSL " + str.tostring(s, format.mintick) + "\nTP1 " + str.tostring(t1, format.mintick) + "\nTP2 " + str.tostring(t2, format.mintick)
    label.new(bar_index, dirI == 1 ? low : high, body, style = dirI == 1 ? label.style_label_up : label.style_label_down, color = dirI == 1 ? COL_BUYBG : COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = tip)
    if showReason
        label.new(bar_index + 3, dirI == 1 ? low : high, why, style = dirI == 1 ? label.style_label_upper_left : label.style_label_lower_left, color = color.new(COL_PANEL, 8), textcolor = COL_TXT, size = size.tiny, tooltip = "The complete reason stack of this signal - the 7 confirmations of the video, in order.")
        // the two captions Tom writes on his charts, on the exact spots he writes them
        label.new(bStart, dirI == 1 ? bHi : bLo, "IDEA · the market is about to get FAST", style = label.style_label_down, color = color.new(COL_TXT, 5), textcolor = COL_BG, size = size.small, tooltip = "Video 09:37: 'And exactly through this combination I have the IDEA that the\nmarket will move quickly, because I have summarised all the factors for myself.'\nThe idea comes from LOCATION: weekly imbalance + trending VPOCs + the\nprior value-area edge. That is a hypothesis, nothing more - which is why\nstep 7 exists.")
        label.new(bar_index, dirI == 1 ? high : low, "PROOF · through a BREAK-OUT setup", style = dirI == 1 ? label.style_label_down : label.style_label_up, color = color.new(COL_TXT, 5), textcolor = COL_BG, size = size.small, tooltip = "Video 09:51: 'and I have the PROOF through a breakout setup that my idea is\nalso traded by the relevant market participants exactly as I expect - namely\nwith fast, aggressive speed.'\nThe single print + the P/b shape + the close beyond the balance edge ARE\nthat proof. No proof = no trade, no matter how good the location looks.")
    if showTrade
        f_tradeLines(dirI, e, s, t1, t2)

if barstate.isconfirmed and intradayOK and inSess
    // ── running setup: shape, single prints, arming, triggers ─────────────────────
    if st == 1
        int winLen = math.min(400, balN + impBars)
        [shp, mPoc, mHi, mLo, mPos] = f_micro(winLen, math.max(8, binsPerDay / 2), pocUpper, pocLower, vaPct)
        micShape := shp
        [sc, sb, stp] = f_singlePrint(cHi, cLo, binsPerDay, nz(dLo, low), nz(dHi, high), impLow, impHigh, spMaxTouch)
        spCnt := sc
        spBot := sb
        spTop := stp
        bool spOK = not reqSP or spCnt >= spMinBins
        bool ctxUp = g1Up and g2Up and g3Up and g4Up and spOK and micShape == "P" and tradesToday < maxTrades and tDir == 0
        bool ctxDn = g1Dn and g2Dn and g3Dn and g4Dn and spOK and micShape == "b" and tradesToday < maxTrades and tDir == 0
        if showArmed and balN >= balMin and (ctxUp or ctxDn)
            if na(armLab)
                armLab := label.new(bar_index, stDir == 1 ? balLo : balHi, "⌘ SETUP ARMED · " + micShape, style = stDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(COL_PANEL, 20), textcolor = COL_GOLD, size = size.tiny, tooltip = "All location filters are green and the micro balance is printing a letter.\nNow the market has to deliver the PROOF: a break-in, or a breakout of\nthe balance edge with a higher / lower close.\n\nVideo 11:12: 'you can lay yourself a signal - and when the signal comes\nyou watch the market and see whether it gives you exactly the proof\nyou need.'")
            else
                label.set_xy(armLab, bar_index, stDir == 1 ? balLo : balHi)
                label.set_text(armLab, "⌘ SETUP ARMED · " + micShape)
            if not armedAlert
                armedAlert := true
                armEv := true
        bool fired = false
        if stDir == 1 and ctxUp and balN >= balMin
            bool boUp = useBreakOut and close > balHi and close > open
            bool biUp = useBreakIn and low <= balLo + (balHi - balLo) * 0.25 and close > balLo + (balHi - balLo) * 0.5 and close > open and close > refUp
            if boUp or biUp
                fired := true
                tDir := 1
                tSetup := boUp ? "BREAKOUT - HIGHER CLOSE" : "BREAK-IN - TREND CONT."
                tEntry := close
                float slRaw = slMode == "Impulse origin" ? impLow : slMode == "Reference level" ? math.min(refUp, balLo) : balLo
                tSL := slRaw - atr14 * slBufAtr
                float risk = math.max(tEntry - tSL, syminfo.mintick)
                tTP1 := tEntry + risk * tp1R
                tTP2 := tEntry + risk * tp2R
                tp1Done := false
                tBar := bar_index
                tradesToday += 1
                buySig := true
                sigTxt := "BUY " + str.tostring(close, format.mintick) + " - " + tSetup
                f_signalDraw(1, tSetup, tEntry, tSL, tTP1, tTP2, f_reasons(1, boUp ? "close " + str.tostring(close, format.mintick) + " ABOVE the P-balance high " + str.tostring(balHi, format.mintick) + " - a higher close, not a wick." : "break-in: price dipped back into the P-balance and was bought instantly.", micShape, spCnt, wkLoc, vpUpS, vpSteps, refUp), spBot, spTop, balStart, balHi, balLo, micShape)
        if stDir == -1 and ctxDn and balN >= balMin
            bool boDn = useBreakOut and close < balLo and close < open
            bool biDn = useBreakIn and high >= balHi - (balHi - balLo) * 0.25 and close < balHi - (balHi - balLo) * 0.5 and close < open and close < refDn
            if boDn or biDn
                fired := true
                tDir := -1
                tSetup := boDn ? "BREAKOUT - LOWER CLOSE" : "BREAK-IN - TREND CONT."
                tEntry := close
                float slRaw = slMode == "Impulse origin" ? impHigh : slMode == "Reference level" ? math.max(refDn, balHi) : balHi
                tSL := slRaw + atr14 * slBufAtr
                float risk = math.max(tSL - tEntry, syminfo.mintick)
                tTP1 := tEntry - risk * tp1R
                tTP2 := tEntry - risk * tp2R
                tp1Done := false
                tBar := bar_index
                tradesToday += 1
                sellSig := true
                sigTxt := "SELL " + str.tostring(close, format.mintick) + " - " + tSetup
                f_signalDraw(-1, tSetup, tEntry, tSL, tTP1, tTP2, f_reasons(-1, boDn ? "close " + str.tostring(close, format.mintick) + " BELOW the b-balance low " + str.tostring(balLo, format.mintick) + " - a lower close, not a wick." : "break-in: price popped back into the b-balance and was sold instantly.", micShape, spCnt, wkLoc, vpDnS, vpSteps, refDn), spBot, spTop, balStart, balHi, balLo, micShape)
        if fired
            st := 0
            stDir := 0
            armedAlert := false
            if not na(armLab)
                label.delete(armLab)
                armLab := na
        else
            balHi := math.max(balHi, high)
            balLo := math.min(balLo, low)
            balN += 1
            bool tooWide = (balHi - balLo) > atr14 * balATR
            bool broken = stDir == 1 ? close < impLow : close > impHigh
            if tooWide or broken or balN > balMax
                st := 0
                stDir := 0
                armedAlert := false
                if not na(armLab)
                    label.delete(armLab)
                    armLab := na

    // ── detect a fresh impulse leg that clears the reference level ────────────────
    if st == 0 and tDir == 0 and tradesToday < maxTrades
        bool clearUp = not na(refUp) and loN < refUp and close > refUp
        bool clearDn = not na(refDn) and hiN > refDn and close < refDn
        if impUp and clearUp and g1Up
            st := 1
            stDir := 1
            impLow := loN
            impHigh := hiN
            balStart := bar_index
            balHi := high
            balLo := low
            balN := 1
            micShape := "-"
            armedAlert := false
        else if impDn and clearDn and g1Dn
            st := 1
            stDir := -1
            impLow := loN
            impHigh := hiN
            balStart := bar_index
            balHi := high
            balLo := low
            balN := 1
            micShape := "-"
            armedAlert := false

    // ── trade management ─────────────────────────────────────────────────────────
    if tDir == 1
        if not tp1Done and high >= tTP1
            tp1Done := true
            tp1Ev := true
            if beAtTP1
                tSL := tEntry
            label.new(bar_index, high, " TP1 ", style = label.style_label_down, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "TP1 reached (" + str.tostring(tp1R, "#.##") + "R). Stop to break-even - from here the trade is free.")
        if high >= tTP2
            tp2Ev := true
            tDir := 0
            winCnt += 1
            sigTxt := "TP2 HIT - " + tSetup
            label.new(bar_index, high, " TP2 ✔ ", style = label.style_label_down, color = color.new(COL_BULL, 0), textcolor = COL_BG, size = size.small, tooltip = "TP2 reached (" + str.tostring(tp2R, "#.##") + "R) - the explosive continuation this setup was built for.")
        else if low <= tSL
            slEv := true
            tDir := 0
            if tp1Done
                winCnt += 1
            else
                lossCnt += 1
            sigTxt := (tp1Done ? "BE EXIT - " : "SL HIT - ") + tSetup
            label.new(bar_index, low, tp1Done ? " BE " : " SL ✖ ", style = label.style_label_up, color = color.new(tp1Done ? COL_CYAN : COL_BEAR, 15), textcolor = tp1Done ? COL_BG : COL_TXT, size = size.small, tooltip = tp1Done ? "BREAK-EVEN EXIT - TP1 already paid, the runner came back to entry.\nA risk-free trade." : "STOP - the proof failed. Video: 'if you do not get out immediately\nwhen it does not work, you very quickly get the exact opposite:\na fast move against your direction.'")
        else if maxHold > 0 and bar_index - tBar >= maxHold and not tp1Done
            timeEv := true
            tDir := 0
            sigTxt := "TIME STOP - " + tSetup
            label.new(bar_index, low, " TIME ", style = label.style_label_up, color = color.new(COL_GOLD, 20), textcolor = COL_BG, size = size.small, tooltip = "TIME STOP - " + str.tostring(maxHold) + " bars and no follow-through.\nThe entire edge of this model is SPEED. No speed = no trade.")
    else if tDir == -1
        if not tp1Done and low <= tTP1
            tp1Done := true
            tp1Ev := true
            if beAtTP1
                tSL := tEntry
            label.new(bar_index, low, " TP1 ", style = label.style_label_up, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "TP1 reached (" + str.tostring(tp1R, "#.##") + "R). Stop to break-even.")
        if low <= tTP2
            tp2Ev := true
            tDir := 0
            winCnt += 1
            sigTxt := "TP2 HIT - " + tSetup
            label.new(bar_index, low, " TP2 ✔ ", style = label.style_label_up, color = color.new(COL_BULL, 0), textcolor = COL_BG, size = size.small, tooltip = "TP2 reached (" + str.tostring(tp2R, "#.##") + "R) - full extension.")
        else if high >= tSL
            slEv := true
            tDir := 0
            if tp1Done
                winCnt += 1
            else
                lossCnt += 1
            sigTxt := (tp1Done ? "BE EXIT - " : "SL HIT - ") + tSetup
            label.new(bar_index, high, tp1Done ? " BE " : " SL ✖ ", style = label.style_label_down, color = color.new(tp1Done ? COL_CYAN : COL_BEAR, 15), textcolor = tp1Done ? COL_BG : COL_TXT, size = size.small, tooltip = tp1Done ? "BREAK-EVEN EXIT - risk-free trade." : "STOP - the proof failed. Get out fast, do not argue with the market.")
        else if maxHold > 0 and bar_index - tBar >= maxHold and not tp1Done
            timeEv := true
            tDir := 0
            sigTxt := "TIME STOP - " + tSetup
            label.new(bar_index, high, " TIME ", style = label.style_label_down, color = color.new(COL_GOLD, 20), textcolor = COL_BG, size = size.small, tooltip = "TIME STOP - no speed, no trade.")

plotshape(sellSig, "SELL arrow", shape.triangledown, location.abovebar, COL_BEAR, size = size.small, display = display.pane)
plotshape(buySig, "BUY arrow", shape.triangleup, location.belowbar, COL_BULL, size = size.small, display = display.pane)

// ───────────────────── HOW TO READ (the on-chart manual) ───────────────────────────
var label legendLab = na
if showLegend and barstate.islast
    string man = "HOW TO READ  IMBALANCE BREAKOUT PRO\n" +
     "----------------------------------------------\n" +
     "THE IDEA (Tom Vorwald): a breakout setup has an 80-90 % hit rate - but only\n" +
     "in the ~30 % of market phases that are OUT OF BALANCE. In the ~70 % balance\n" +
     "phases the identical setup fails. So: LOCATION first, trigger second.\n" +
     "That combination shows up roughly ONCE PER DAY.\n" +
     "----------------------------------------------\n" +
     "SHADED ZONE + GOLD DASH  last week's value area + VPOC = the equilibrium.\n" +
     "     price inside  = BALANCE   = stand down (the 70 % phase)\n" +
     "     price outside = IMBALANCE = hunt breakouts (the 30 % phase)\n" +
     "BACKGROUND WASH          mint = imbalance up, red = imbalance down, gold = balance.\n" +
     "GREY/CYAN HISTOGRAM      the completed weekly profile.\n" +
     "MINT HISTOGRAM           yesterday's daily profile (value area mint, POC gold).\n" +
     "DASHED RAILS PD VAH/VAL  yesterday's value-area edges transferred into this\n" +
     "     session - the levels the breakout has to clear (video step 4).\n" +
     "STAIRCASE + DOTS         the sequence of daily VPOCs. Rising = the equilibrium\n" +
     "     itself is trending up = green light for longs (video step 3).\n" +
     "CYAN BOX SINGLE PRINT    price rows the impulse touched with ONE bar only =\n" +
     "     aggressive buyers / sellers, nobody did business there (step 5).\n" +
     "MINT/RED BOX + BIG P/b   the micro balance on top of / underneath the impulse.\n" +
     "     P = buyers shift equilibrium up, b = sellers shift it down (step 6).\n" +
     "SETUP ARMED              every filter is green, now the market must deliver\n" +
     "     the proof. This is the signal you lay for yourself.\n" +
     "----------------------------------------------\n" +
     "PILLS   BUY / SELL with the trigger name; the text block next to them lists\n" +
     "     all 7 confirmations. Hover anything on this chart for more.\n" +
     "ZONES   red block = the 1R risk, mint block = the reward to TP2.\n" +
     "LINES   gold ENTRY - pink SL - mint TP1 (then break-even) - cyan TP2.\n" +
     "EXITS   TP1 / TP2 WIN / SL / BE / TIME (no speed = no trade).\n" +
     "----------------------------------------------\n" +
     "TRIGGERS   BREAK-IN = trend-continuing re-entry into the P/b balance.\n" +
     "           BREAKOUT = a CLOSE beyond the balance edge - never a wick.\n" +
     "AUTOMATION one alert, condition 'Any alert() function call', your webhook URL.\n" +
     "PANEL      the checklist mirrors the video step by step - hover every row."
    if na(legendLab)
        legendLab := label.new(bar_index + 34, high, "ⓘ  HOW TO READ", style = label.style_label_left, color = color.new(COL_PANEL, 0), textcolor = COL_CYAN, size = size.small, tooltip = man)
    else
        label.set_xy(legendLab, bar_index + 34, high)
        label.set_tooltip(legendLab, man)

// ───────────── TEACH MODE: permanent beginner card printed on the chart ───────────
var label teachLab = na
if teachMode and barstate.islast
    string tcard = "IMBALANCE BREAKOUT PRO   ·   BEGINNER CARD\n" +
     "═══════════════════════════════════════════\n" +
     "WHY THIS WORKS:  a breakout pays in only ~30 % of market phases -\n" +
     "the ones OUT OF BALANCE.  In the other ~70 % (inside balance) the\n" +
     "identical setup fails.  So you FIRST locate, THEN pull the trigger.\n" +
     "That combination appears about ONCE PER DAY.\n" +
     "───────────────────────────────────────────\n" +
     "WHAT YOU SEE ON THIS CHART\n" +
     "· Histogram bars beside each session = that session's VOLUME PROFILE.\n" +
     "  Long row = a lot of business done at that price.\n" +
     "· Gold row + red line = VPOC (the fairest price of the session).\n" +
     "  It keeps running right as a magnet until price returns to it.\n" +
     "· Dotted box = VALUE AREA " + str.tostring(vaPct, "#") + " % of the volume = 'fair value'.\n" +
     "· Shaded wide zone = LAST WEEK'S value area = the equilibrium.\n" +
     "  Price inside it -> stand down.  Outside it -> hunt.\n" +
     "· Background wash: mint = imbalance up, red = imbalance down, gold = balance.\n" +
     "· P / b / D above each session = its shape (P buyers, b sellers, D balance).\n" +
     "· THICK GREEN LINE = yesterday's value-area edge transferred into today.\n" +
     "  This is the line the breakout has to CLOSE beyond.\n" +
     "· Cyan box 'SINGLE PRINT' = prices only one bar ever touched:\n" +
     "  the market ran through so fast that nobody traded there = aggression.\n" +
     "· Mint / red box with the big P or b = the micro balance after the impulse.\n" +
     "───────────────────────────────────────────\n" +
     "THE 7 STEPS  (the panel shows them live)\n" +
     "1 weekly location: OUTSIDE last week's value area\n" +
     "2 that value area was tested and aggressively rejected\n" +
     "3 the daily VPOCs are climbing (or falling) - the trend of fair value\n" +
     "4 price accelerates through yesterday's value-area edge\n" +
     "5 the impulse leaves SINGLE PRINTS\n" +
     "6 a P (long) or b (short) micro balance forms on the impulse\n" +
     "7 trigger: BREAK-IN, or a CLOSE beyond the balance edge\n" +
     "───────────────────────────────────────────\n" +
     "MANAGING IT:  stop behind the balance edge, TP1 " + str.tostring(tp1R, "#.#") + "R -> stop to\n" +
     "break-even, TP2 " + str.tostring(tp2R, "#.#") + "R.  If it does not run within " + str.tostring(maxHold) + " bars, get out:\n" +
     "this model lives on SPEED, and a failing breakout reverses fast.\n" +
     "───────────────────────────────────────────\n" +
     "Hover ANY pill, line, zone, letter or panel row for its own explanation."
    string vcard = "BEGINNER CARD · READ THE CHART\n" +
     "─────────────────────────────\n" +
     "Histogram = session volume profile · gold row = VPOC (fair price)\n" +
     "Red ray = naked VPOC (magnet) · dotted box = value area " + str.tostring(vaPct, "#") + "%\n" +
     "Wide shaded zone = LAST WEEK'S value area = the equilibrium\n" +
     "   inside it = 70 % phase → NO breakout trades\n" +
     "   outside it = 30 % phase → this is where breakouts pay\n" +
     "THICK GREEN LINE = yesterday's VA edge, transferred into today\n" +
     "Cyan box = SINGLE PRINT (only one bar traded there = aggression)\n" +
     "Big P / b = micro balance on the impulse (P buyers, b sellers)\n" +
     "Pill = entry + the 7 reasons · red block = 1R risk · mint = reward\n" +
     "─────────────────────────────\n" +
     "1 outside weekly balance → 2 balance tested + rejected →\n" +
     "3 daily VPOCs trending → 4 accelerate through the green line →\n" +
     "5 single prints → 6 P / b micro balance → 7 CLOSE beyond it\n" +
     "Stop behind the balance · TP1 " + str.tostring(tp1R, "#.#") + "R → break-even · TP2 " + str.tostring(tp2R, "#.#") + "R\n" +
     "No follow-through within " + str.tostring(maxHold) + " bars → get out. This model lives on speed.\n" +
     "hover anything for the full explanation"
    if na(teachLab)
        teachLab := label.new(bar_index + 3, close, vcard, style = label.style_label_left, color = color.new(COL_PANEL, 8), textcolor = COL_TXT, size = size.small, tooltip = tcard)
    else
        label.set_xy(teachLab, bar_index + 3, close)
        label.set_text(teachLab, vcard)
        label.set_tooltip(teachLab, tcard)

// ──────────────────────────── ALERTS / WEBHOOK ────────────────────────────────────
f_json(string action) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","setup":"' + tSetup +
     '","shape":"' + micShape + '","qty":' + str.tostring(whQty) +
     ',"price":' + str.tostring(close, format.mintick) +
     ',"entry":' + str.tostring(na(tEntry) ? close : tEntry, format.mintick) +
     ',"sl":' + str.tostring(na(tSL) ? close : tSL, format.mintick) +
     ',"tp1":' + str.tostring(na(tTP1) ? close : tTP1, format.mintick) +
     ',"tp2":' + str.tostring(na(tTP2) ? close : tTP2, format.mintick) +
     ',"pdvah":' + str.tostring(nz(pdVAH, 0), format.mintick) +
     ',"pdval":' + str.tostring(nz(pdVAL, 0), format.mintick) +
     ',"tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and buySig
    alert(f_json("BUY"), alert.freq_once_per_bar_close)
if alSignals and sellSig
    alert(f_json("SELL"), alert.freq_once_per_bar_close)
if alManage and tp1Ev
    alert(f_json("TP1_HIT"), alert.freq_once_per_bar_close)
if alManage and tp2Ev
    alert(f_json("TP2_HIT"), alert.freq_once_per_bar_close)
if alManage and slEv
    alert(f_json(tp1Done ? "BE_EXIT" : "SL_HIT"), alert.freq_once_per_bar_close)
if alManage and timeEv
    alert(f_json("TIME_STOP"), alert.freq_once_per_bar_close)
if alArmed and armEv
    alert(f_json("ARMED"), alert.freq_once_per_bar_close)

alertcondition(buySig, "BUY Signal", "Imbalance Breakout Pro: BUY {{ticker}} @ {{close}}")
alertcondition(sellSig, "SELL Signal", "Imbalance Breakout Pro: SELL {{ticker}} @ {{close}}")
alertcondition(buySig or sellSig, "Any Signal", "Imbalance Breakout Pro: signal on {{ticker}} {{interval}}")

varip int tickN = 0
if barstate.isrealtime
    tickN += 1

f_pos() =>
    switch panelPos
        "Middle Left" => position.middle_left
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Middle Right" => position.middle_right
        => position.bottom_right

f_spacer(table t, int r) =>
    table.cell(t, 0, r, "", bgcolor = color.new(COL_BG, 0), text_size = size.tiny)

f_check(table t, int r, string num, string title, string sub, string status, color stCol, string tip) =>
    table.cell(t, 0, r, num, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, tooltip = tip)
    table.cell(t, 1, r, title + "\n" + sub, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, tooltip = tip)
    table.cell(t, 7, r, status, text_color = stCol, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right, tooltip = tip)

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 11, 24, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 90), border_width = 1)
        for r = 0 to 23
            for c = 0 to 10
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.cell(pan, 0, 1, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 1, 7, 1)
        table.cell(pan, 0, 2, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 2, 7, 2)
        table.merge_cells(pan, 0, 4, 10, 4)
        table.merge_cells(pan, 0, 6, 10, 6)
        table.merge_cells(pan, 0, 7, 4, 7)
        table.merge_cells(pan, 5, 7, 10, 7)
        table.merge_cells(pan, 0, 8, 4, 8)
        table.merge_cells(pan, 5, 8, 10, 8)
        table.merge_cells(pan, 0, 9, 10, 9)
        for r = 10 to 16
            table.merge_cells(pan, 1, r, 6, r)
            table.merge_cells(pan, 7, r, 10, r)
        for r = 17 to 23
            table.merge_cells(pan, 0, r, 10, r)
    int gcol = tickN % 11
    int phase = tickN / 3 % 6
    // row 6: brushed gold divider
    for c = 0 to 10
        table.cell(pan, c, 0, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // header
    // row 9: animated chevrons
    for c = 0 to 10
        table.cell(pan, c, 3, tDir == -1 ? "▼" : "▲", text_color = c == gcol ? COL_GOLD : color.new(tDir == -1 ? COL_BEAR : COL_BULL, 40), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, tooltip = "The gold chevron sweeps on live ticks - market-open indicator.")
    // row 10: the location chip - the heart of the whole model
    color locCol = na(pwVAH) ? COL_GREY : wkLoc == "BALANCE (70 %)" ? COL_GOLD : wkImbUp ? COL_BULL : COL_BEAR
    string locTxt = na(pwVAH) ? "COLLECTING FIRST WEEK" : wkLoc == "BALANCE (70 %)" ? "BALANCE · STAND DOWN" : "IMBALANCE · " + (wkImbUp ? "HUNT LONGS" : "HUNT SHORTS")
    table.cell(pan, 0, 4, locTxt, text_color = locCol, text_size = size.normal, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = "STEP 1 - LOCATION, the whole edge of the video.\nInside last week's value area = the 70 % balance phase: a breakout\nsetup has a LOW probability there, no matter how good it looks.\nOutside = the 30 % imbalance phase: this is where fast breakout\ntrades produce the 80-90 % hit rate.\n\nPrior week VA:   " + (na(pwVAH) ? "-" : str.tostring(pwVAL, format.mintick) + "  ...  " + str.tostring(pwVAH, format.mintick)) + "\nPrior week VPOC: " + (na(pwPOC) ? "-" : str.tostring(pwPOC, format.mintick)))
    // row 11: imbalance gauge
    float vaH = na(pwVAH) ? na : pwVAH - pwVAL
    float dev = na(pwVAH) or na(vaH) or vaH <= 0 ? 0.0 : (close > pwVAH ? (close - pwVAH) / vaH : close < pwVAL ? -(pwVAL - close) / vaH : 0.0)
    int filled = math.min(5, math.round(math.abs(dev) * 5))
    for c = 0 to 10
        int dist = math.abs(c - 5)
        bool lit = dev > 0 ? (c > 5 and dist <= filled) : dev < 0 ? (c < 5 and dist <= filled) : c == 5
        color gc = c == 5 ? COL_GOLD : lit ? (dev > 0 ? COL_BULL : COL_BEAR) : color.new(COL_PANEL2, 0)
        table.cell(pan, c, 5, "", bgcolor = gc, text_size = size.tiny, tooltip = "IMBALANCE GAUGE - how far price has travelled beyond last week's value\narea, measured in value-area heights. The gold centre cell is the\nequilibrium; every lit cell is another 20 % of a value-area height\ninto imbalance territory.\nCurrent: " + str.tostring(dev, "#.##") + " VA heights.")
    // info grid
    table.cell(pan, 0, 6, "PROFILE  " + str.tostring(binsPerDay) + " rows · VA " + str.tostring(vaPct, "#") + "% · " + (useRTH ? "cash session" : "full session") + " · " + str.tostring(histDays) + "D/" + str.tostring(histWeeks) + "W drawn", text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, tooltip = "Profile engine: every period is split into " + str.tostring(binsPerDay) + " rows across its OWN\nhigh-low range - the classic volume / TPO profile, so DAX, NQ, gold, FX and\ncrypto all get a correct resolution automatically.\n" + (useRTH ? "Cash session only: " + sessStr + " - as in the video." : "Full session. Switch on 'cash session only' for index futures."))
    table.cell(pan, 0, 7, "WEEK OPEN\n" + wkOpenLoc + " prior VA", text_color = wkOpenLoc == "INSIDE" ? COL_GOLD : wkOpenLoc == "-" ? COL_GREY : COL_BULL, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, tooltip = "Where did THIS week open relative to last week's value area?\nVideo, NKD example: 'the trading open of this week took place\nABOVE the equilibrium of this profile' - that was confirmation 1.")
    table.cell(pan, 5, 7, "SIGNALS\n" + str.tostring(tradesToday) + "/" + str.tostring(maxTrades) + " today · W" + str.tostring(winCnt) + " L" + str.tostring(lossCnt), text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, tooltip = "Video 00:05: 'unfortunately this model only works about ONCE A DAY.'\nThat is why the engine stops after " + str.tostring(maxTrades) + " signal(s) per session.\nW / L counts TP2 (or break-even after TP1) against full stops on this chart.")
    table.cell(pan, 0, 8, "PD VAH\n" + (na(pdVAH) ? "-" : str.tostring(pdVAH, format.mintick)), text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, tooltip = "Yesterday's transferred levels (the dashed rails on the chart):\nVAH  " + (na(pdVAH) ? "-" : str.tostring(pdVAH, format.mintick)) + "\nVPOC " + (na(pdPOC) ? "-" : str.tostring(pdPOC, format.mintick)) + "\nVAL  " + (na(pdVAL) ? "-" : str.tostring(pdVAL, format.mintick)) + "\nThe breakout has to leave this value area with acceleration.")
    table.cell(pan, 5, 8, "PD VAL\n" + (na(pdVAL) ? "-" : str.tostring(pdVAL, format.mintick)), text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, tooltip = "The short-side rail. Both edges are drawn as dashed lines on the chart\nand carry the same explanations there.")
    // checklist
    table.cell(pan, 0, 9, "THE 7 CONFIRMATIONS (VIDEO ORDER)", text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, tooltip = "Read top to bottom. Nothing below step 1 matters while the market is\nin balance. Hover each row for the exact rule and the quote behind it.")
    f_check(pan, 10, "①", "WEEKLY LOCATION", na(pwVAH) ? "collecting the first weekly profile" : wkLoc == "BALANCE (70 %)" ? "inside prior-week value area" : "outside prior-week value area", na(pwVAH) ? "·· " : wkLoc == "BALANCE (70 %)" ? "BAL " : wkImbUp ? "OUT ↑ " : "OUT ↓ ", na(pwVAH) ? COL_GREY : wkLoc == "BALANCE (70 %)" ? COL_GOLD : COL_BULL, "STEP 1 - 'You must learn to read when the 70 % are present and when\nthe 30 % are.' Inside the prior week's value area the market is in\nequilibrium: the probability of a fast abrupt move is small.\nOnly ABOVE or BELOW that balance does a breakout setup pay.")
    f_check(pan, 11, "②", "EQ TEST + REJECT", wkTestUp ? "value area tested, bought back up" : wkTestDn ? "value area tested, sold back down" : wkTouchUp or wkTouchDn ? "tested - waiting for the reaction" : "no test yet this week", wkTestUp ? "OK ↑ " : wkTestDn ? "OK ↓ " : "·· ", wkTestUp or wkTestDn ? COL_BULL : COL_GREY, "STEP 2 - 'In addition we tested the so-called value area ... he ran down\nhere and was then AGGRESSIVELY traded back up.'\nThat rejection is the proof that the market does not want to be in\nequilibrium any more and is tending towards imbalance.")
    f_check(pan, 12, "③", "VPOC TREND (DAILY)", vpSteps == 0 ? "need at least 2 completed days" : str.tostring(vpUpS) + " up / " + str.tostring(vpDnS) + " down of " + str.tostring(vpSteps) + " steps", vpUp ? "RISE " : vpDn ? "FALL " : vpSteps == 0 ? "·· " : "FLAT ", vpUp ? COL_BULL : vpDn ? COL_BEAR : COL_GOLD, "STEP 3 - 'The VPOC keeps rising ... so the distribution of the\nparticipants' equilibrium has a strongly rising tendency, the market\nis trending up.' That is the information you need if you want fast\ntrades WITH the trend, i.e. breakout trades.\nFlat or overlapping VPOCs = balance = stand down.")
    f_check(pan, 13, "④", "PD VALUE AREA BREAK", na(refUp) ? "waiting for the first daily profile" : g4Up ? "above the transferred VA edge" : g4Dn ? "below the transferred VA edge" : "inside yesterday's value area", na(refUp) ? "·· " : g4Up ? "OK ↑ " : g4Dn ? "OK ↓ " : "IN ", na(refUp) ? COL_GREY : g4Up or g4Dn ? COL_BULL : COL_GOLD, "STEP 4 - 'We locate a price range, wait for the market to accelerate\nstrongly and arrive right above the PREVIOUS DAY'S VALUE AREA.'\nThe prior VA edge is transferred onto the entry timeframe; leaving it\nupwards (long) or downwards (short) is the location of the trade.")
    f_check(pan, 14, "⑤", "SINGLE PRINT", st == 1 ? str.tostring(spCnt) + " rows touched by " + str.tostring(spMaxTouch) + " bar(s) or less" : "no impulse leg in progress", st == 1 ? (spCnt >= spMinBins ? "OK " : str.tostring(spCnt) + "/" + str.tostring(spMinBins) + " ") : "·· ", st == 1 and spCnt >= spMinBins ? COL_CYAN : COL_GREY, "STEP 5 - 'We see trading open here: SINGLE PRINT. That means\naggressive buyers have entered the market.'\nA single print is a price row that only ONE bar / TPO ever touched -\nprice ran through it so fast that nobody did business there.")
    f_check(pan, 15, "⑥", "P / b MICRO SHAPE", st == 1 ? (micShape == "-" ? "measuring the micro profile" : micShape == "P" ? "balance ON TOP of the impulse" : micShape == "b" ? "balance UNDER the impulse" : "symmetric D - not tradable") : "waiting for an impulse + balance", st == 1 ? micShape + " " : "·· ", st != 1 ? COL_GREY : micShape == "P" ? COL_BULL : micShape == "b" ? COL_BEAR : COL_GOLD, "STEP 6 - 'And he gives us a wonderful P. A P means there are aggressive\nbuyers here who are shifting their equilibrium upwards.'\nThe engine measures the micro profile of impulse + balance:\nPOC in the upper part = P, in the lower part = b, in the middle = D (skip).\nThis is the PBD concept - the model Patrick Nill won the World Cup\nChampionship of Futures Trading with twice.")
    f_check(pan, 16, "⑦", "TRIGGER", tDir != 0 ? tSetup : st == 1 and balN >= balMin ? "armed - waiting for the close" : "no setup armed", tDir != 0 ? "FIRE " : st == 1 and balN >= balMin ? "ARM " : "·· ", tDir != 0 ? COL_GOLD : st == 1 and balN >= balMin ? COL_CYAN : COL_GREY, "STEP 7 - 'Trend-continuing was exactly this BREAK-IN here. BREAKOUT I\nhave here - with the HIGHER CLOSING PRICE - and then I see how the\nmarket keeps climbing.'\nBREAK-IN  = price dips back into the P/b balance and is bought / sold\n            instantly (the aggressive, earlier entry).\nBREAKOUT  = a CLOSE beyond the balance edge, never a wick.")
    // position + signal
    string posTxt = tDir == 0 ? "NO POSITION" : (tDir == 1 ? "LONG " : "SHORT ") + str.tostring(tEntry, format.mintick) + "  SL " + str.tostring(tSL, format.mintick) + "  TP " + str.tostring(tTP2, format.mintick)
    table.cell(pan, 0, 17, posTxt, text_color = tDir == 0 ? COL_GREY : tDir == 1 ? COL_BULL : COL_PINK, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = "The indicator's virtual position for signal tracking and the webhook.\nEntry - current stop (jumps to break-even at TP1) - final target.")
    color bigCol = str.contains(sigTxt, "TP2") ? COL_BULL : str.contains(sigTxt, "SL HIT") ? COL_BEAR : str.contains(sigTxt, "TIME") ? COL_GOLD : tDir != 0 ? COL_GOLD : COL_GREY
    table.cell(pan, 0, 18, sigTxt, text_color = bigCol, text_size = size.large, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = "Latest signal / trade status.\nGold = running or time stop, mint = TP2, red = stop hit.")
    table.cell(pan, 0, 19, "IMPULSE " + str.tostring(impATR, "#.#") + "× ATR · BALANCE ≤ " + str.tostring(balATR, "#.#") + "× ATR · " + str.tostring(balN) + "/" + str.tostring(balMax) + " bars · TIME STOP " + str.tostring(maxHold), text_color = color.new(COL_GREY, 20), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, tooltip = "Execution geometry. The balance must stay contained; if it widens, breaks\nthe impulse origin, or goes stale, the setup is discarded.\nThe time stop enforces the core risk rule: this model lives on SPEED -\n'if you do not get out immediately when it does not work, you very\nquickly get a fast move against your direction.'")
    table.cell(pan, 0, 20, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 20, 7, 20)
    table.cell(pan, 0, 21, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 21, 7, 21)
    table.cell(pan, 0, 22, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 22, 7, 22)
    table.cell(pan, 0, 23, (tickN % 2 == 0 ? "●" : "○") + " LIVE · webhook JSON ready", text_color = color.new(COL_BULL, 25), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, tooltip = "AUTOMATION: create ONE alert, condition 'Any alert() function call',\npaste your webhook URL. Every BUY / SELL / TP1 / TP2 / SL / BE /\nTIME_STOP / ARMED event posts ready-to-use JSON:\nid, symbol, action, setup, shape, qty, price, entry, sl, tp1, tp2,\npdvah, pdval, tf, time.")
````
