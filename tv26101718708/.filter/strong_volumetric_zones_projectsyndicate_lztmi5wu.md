# Strong Volumetric Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/lzTmi5wU-Strong-Volumetric-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;1d45d910f4704e2da78130c483ccd6ad
- version: 1.0

## Description

Strong Volumetric Zones carves the chart's true supply and demand from actual transacted volume — not from pivots, not from moving averages, not from projected lines — then power-ranks every zone so you know which ones are institutional footprint and which ones are noise. It pulls lower-timeframe order-flow data for every candle in the lookback window, builds a full volume-at-price histogram with buy/sell decomposition, isolates the high-volume nodes that dominate their neighborhood, extends each one into a bounded zone using a fractional-volume cutoff, and grades all of them 0–10. The whole tool runs on one idea: price alone is a story half-told — a level where the auction deposited enormous volume, where delta confirms one side was defending, where every test has been rejected, and that stands fresh and unchallenged is a different animal from a thin blot of retail churn, and it should not look the same on your chart.

BTCUSD
[image]https://www.tradingview.com/x/hgN5GCRW/[/image]

This is an order-flow reaction matrix, not a signal generator. It tells you where the auction has parked real liquidity, whether that liquidity is supply-side or demand-side, how many times price has tested it and held, how hard price was rejected on each hold, and which zone is the strongest one on the chart right now. The read is directional in the sense that you can see, at a glance, whether the session's volume structure is stacked with supply above or demand below — and whether the current candle is absorbing, exhausting, or stacking imbalance in real time.

🟢🔴 Summary how to trade this — more details below, read entire guide. Two clean approaches: react at the zone, or trade the break of it. Prefer STRONG / EXTREME grades and zones with high hold rates — the shallow low-graded zones tag constantly and mean little. The dashboard's Nearest ▲ / Nearest ▼ and Zone Status tell you instantly whether price is inside a volumetric wall or in open air. Runs on any timeframe with intrabar data available.

🧱 The Volume Core — the only source of truth. Every zone in this tool descends from a confirmed high-volume node in the actual volume-at-price histogram, never from a price-only pivot, never from an indicator line, never from a projected level. The engine requests lower-timeframe bars — auto-scaled from 1-second up to 5-minute depending on your chart — and decomposes each candle's range into volume-by-price bins. Buy volume and sell volume are tracked independently from the close-vs-open direction of every intrabar tick. The profile lookback is 300 bars by default and the bin resolution scales dynamically with ATR200, so the histogram adapts to the instrument's volatility without manual tuning. Nothing is drawn from a guess.

🔭 Lower-Timeframe Decomposition — Six granularity slots, auto-selected by default, running from 1-tick to 5-minute. Each confirmed chart candle is exploded into its internal sub-bars; volume is assigned to price bins based on the actual range covered by each sub-bar, not from a proportional tick-close estimate. Buy/sell classification follows the candle direction of the sub-bar itself. This is the reconstruction layer that separates a volume profile built from order flow from one built from assumptions. When the chart is on H4, the engine still reads M1 structure inside every bar.

◆ High-Volume Node Isolation — the signature carve. Within the global histogram, a bin must dominatepeakRadius neighbours on both sides (default 2) to qualify as a high-volume node — it is the local maximum of its neighborhood. A floor filter (minPeakPct of the POC volume, default 18%) eliminates statistical noise. All qualifying peaks are then sorted by absolute volume, strongest first, and the engine attempts to carve up tomaxZones zones (default 8), skipping any whose range overlaps an already-accepted zone. This is where the tool separates from a blob of undifferentiated volume bars: instead of forty equal-weighted histogram rows, you get a handful of bounded zones ranked by the actual liquidity parked inside them.

📐 Zone Edge Extension — Each confirmed node becomes a seed, and the zone expands outward bin-by-bin while neighbouring bins retain at leastnodeCut (default 40%) of the node's volume. Expansion halts atmaxSpan bins (default 2) to prevent overgrowth. The result is a bounded rectangular zone with a defined top, bottom, and mid-line — not a single price point, not an infinite band. The zone's width reflects the actual spread of significant volume around the node, not an arbitrary ATR multiple. Overlapping zones are rejected outright; only the strongest node survives at any price level.

🏷️ The 0–10 Strength Engine — Every zone carries a live grade with stars and a tier word WEAK → MODERATE → STRONG → VERY STRONG → EXTREME. The score is a weighted blend of five independently measurable properties, all derived from real volume and real price action:
▪️ Volume Share 3.5 — how much of the profile's total volume sits inside this zone, normalized against the strongest zone. The dominant term. A zone that holds 30% of the auction is not the same as one holding 3%.
▪️ Touch Count 2.5 — how many times price has entered and exited the zone across the full lookback. Normalized against 6 touches. A zone tested repeatedly has been confirmed by the market.
▪️ Hold Win Rate 2.0 — of all completed tests, what percentage resulted in a hold (rejection) rather than a break. A zone that defends itself 80% of the time is structurally different from one that folds on the first touch.
▪️ Freshness 1.0 — how recently the zone was last tested, normalized against the profile lookback. A zone untouched for 200 bars is fresher than one poked five bars ago.
▪️ Delta Skew 1.0 — the absolute buy-vs-sell imbalance inside the zone, normalized against a 35% threshold. A demand zone with 70% buy volume has institutional sponsorship; a 51/49 split does not.
Read the grade as a descriptive conviction ranking for which zone deserves your attention — it is not a backtested win-rate. A score filter hides everything below a level you choose, and a minimum-touch filter strips zones that have never been tested, so you can strip the chart down to STRONG and EXTREME only.

USDJPY
[image]https://www.tradingview.com/x/gxYQgSJm/[/image]

🔬 Per-Candle Strength Score — Independently, every confirmed candle receives its own 0–10 order-flow strength score, built from five micro-structural inputs: relative volume vs the 20-bar average, delta dominance (absolute delta / total volume), POC concentration (how much volume sits in the single busiest row), stacked imbalance run length, and value-area tightness. This is the engine that powers the Flow Signals — Absorption, Exhaustion, and Stacked Imbalance — and the dashboard's live candle readout. It tells you whether the bar you are looking at right now has order-flow weight behind it or is thin air.

🧬 In-Zone Statistics — Each zone is labeled at its center with its star grade, SUPPLY-SIDE or DEMAND-SIDE designation, the numeric score and tier, the volume share as a percentage of total profile volume, the number of completed tests, the hold win rate, the average reaction magnitude in multiples of ATR, and the buy/sell bias split. A typical label reads:★★★☆☆ DEMAND-SIDE · 6.2/10 STR · VOL 12% · TESTS 4 · HOLD 75% · REACT 2×ATR · DEMAND 68/32. Labels can be restricted by score and touch filters, or the text can be turned off entirely for a pure heatmap look. Four label sizes. Price tags at the right edge show the zone mid-line and score at a glance.

📊 Volume-At-Price Histogram — A full horizontal histogram drawn at the right side of the chart, extending beyond the zones. Each bar's width is proportional to the volume at that price level; color follows buy/sell dominance (demand vs supply palette), with the Master POC row highlighted in the dedicated POC color. A minimum-bin filter hides statistical dust. The histogram is the raw material from which every zone is carved — you see the mountain range and the zones simultaneously.

📐 Master POC & Value Area — The Point of Control (the single highest-volume price in the profile) is drawn as a continuous line spanning the full zone range and extending through the histogram, tagged with its exact price. The Value Area High and Value Area Low (default 70% of total volume) are drawn as dashed lines with labels. Together these three references give you the fair-value anchor for the entire lookback: price above VAH is in premium territory, price below VAL is at a discount, price inside the value area is at equilibrium.

🔬 Per-Candle Footprint — An optional intrabar footprint drawn inside the most recent N candles (default 10). Each row shows block-character bars proportional to volume or delta at that price level, color-coded by buy/sell dominance. Rows outside the candle's value area are muted; the POC row is highlighted. A value-area outline box frames the candle's internal equilibrium. On high-strength candles (score above a configurable threshold), the tier abbreviation is printed directly inside the footprint. This is the microscope — you see exactly where the volume parked inside the bar you just traded.

🎯 Naked POC Tracking — Optionally, every candle whose internal strength score exceeds a threshold spawns a dotted POC line that extends right until price actually trades through it. Once tested, the line is deleted. A cap on active naked POCs (default 8) keeps the chart clean. These are untested fair-value anchors — price tends to return to them, and their persistence means the auction has not yet cleared that liquidity.

NQ
[image]https://www.tradingview.com/x/INn47IN6/[/image]

⚡ Order-Flow Signals — Three micro-structural signals fire on confirmed bars:
▪️ ABS — Absorption. Delta dominance is high (>35%), but the candle body is small (<30% of range) and relative volume is elevated (>1.2×). One side absorbed the other's aggression without moving price. The direction hint points opposite to the absorbed delta: if selling was absorbed, the signal is bullish.
▪️ EXH — Exhaustion. Relative volume is elevated (>1.3×), delta is flat (<12%), and price closed near the high or low. Aggression was spent without conviction. The direction hint points away from the extreme: exhaustion at the high is bearish.
▪️ STK — Stacked Imbalance. Three or more consecutive rows of one-sided imbalance (buy vs adjacent sell, or vice versa, at the configured ratio, default 3×). A directional imbalance stack is a footprint of institutional execution.
Signals appear as tiny labeled markers at the high or low of the candle, color-coded by direction. They are not zone entries — they are real-time flow readings that confirm or deny what the zones are telling you.

📋 Live Command Dashboard — A compact panel that answers the questions you actually ask a volume-zone tool, organized into four sections:
▪️ LIVE ORDER FLOW — Bar Delta with a fill meter, Buy/Sell split with a dual-tone bar, Cumulative Volume Delta with trend arrows, Session Delta, Candle Score with tier, and the active Flow Signal with direction tag. This is the real-time pulse: who is hitting whom right now.
▪️ VOLUME PROFILE — Master POC price and position relative to close, Value Area range with a width meter, VA Location (inside or outside), and Profile Depth (bars processed, bins, zones carved). This is the structural map: where is fair value, how wide is it, how deep is the data.
▪️ REACTION ZONE RADAR — Up to six zones ranked by strength score, each showing price, star grade, score, bias (DEMAND / SUPPLY / BATTLE), test count, and hold win rate. The strongest zone on the chart is always row one. This is the hit list.
▪️ REGIME — Volatility state (COMPRESSED / NORMAL / EXPANSION) based on ATR14 vs ATR100, Zone Status (IN SUPPLY / IN DEMAND / OPEN AIR) with the in-zone score, and Nearest Supply / Nearest Demand with star grades. This is the tactical read: are you in a wall, are you in open air, how far to the next wall.

🔒 Non-Repainting — Lower-timeframe data is requested on confirmed bars only. Volume is accumulated into the histogram only after the chart bar closes. Zones are carved on the last bar of the chart from the completed histogram and then projected — they do not shift, flicker, or disappear retroactively within their lookback window. The candle strength score updates on confirmation. This is the honest tradeoff of order-flow structure: you wait for the bar to close, and in exchange the reading is real.

🔔 Native Alerts — Five condition alerts:
▪️ Volumetric Zone Entry — price enters any displayed zone.
▪️ Strong Volumetric Zone Entry — price enters a zone scoring 7+ (VERY STRONG / EXTREME). The one alert most people will actually run.
▪️ Volumetric Zone Exit — price leaves a zone.
▪️ High-Strength Candle — a confirmed candle scores 7+ on the order-flow engine.
▪️ Order-Flow Signal — an Absorption, Exhaustion, or Stacked Imbalance signal fires on any confirmed bar.

🎨 Five Theme Palettes — Obsidian Aurora (teal/coral/purple), Obsidian Gold (emerald/vermillion/gold), Deep Ocean (cyan/rose/indigo), Midnight Ember (mint/ember/amber), and Graphite Mono (silver/steel/white). Every palette is engineered for a pure-black chart background: deep, saturated, never toxic. Full custom override is available for demand, supply, POC, and accent colors. Zone shading scales opacity directly off the score — weak zones stay faint, extreme zones render solid. You read conviction with your peripheral vision before you read a single number.

Silver
[image]https://www.tradingview.com/x/GyeZZLyN/[/image]

🔧 Fully Customizable — Intrabar granularity (auto or manual), profile lookback, bin resolution, max zones, node isolation radius, min node volume, zone edge cutoff, max zone width, min tests and min score filters, right extension, zone text and price tag toggles, text size, mid-line width and fade, histogram toggle/width/floor, Master POC toggle, Value Area toggle and percentage, footprint toggle/bars/rows/type/max-length/candle-VA/strength-text/threshold, naked POC toggle/min-score/cap, signal toggle and imbalance ratio, dashboard toggle/position/size, theme selection, custom colors, and all five scoring weights for both zones and candles — all adjustable.

🎯 Why this is different — Most volume tools dump a histogram on your chart and leave you guessing which rows matter. Most zone tools draw every pivot they find with no weighting, no testing, no delta, no bias. This one reconstructs the order flow, carves zones from confirmed high-volume nodes, tracks how many times price tested each one and whether it held, measures the reaction magnitude, reads the buy/sell sponsorship inside the zone, and grades the result 0–10. You read the zone, the volume behind it, the delta skew, the hold rate, and the conviction score — at a glance. The chart itself does the filtering.

🚀 Apply to Gold XAUUSD, Silver, Forex, Crypto and Indices on any timeframe with intrabar data.

🎯 How To Trade It — Two Approaches

Everything hinges on the grade and the hold rate. A WEAK zone with no tests is noise you can see; a STRONG or EXTREME zone with a 70%+ hold rate and demand-side bias is where institutional volume has already defended. Trade the graded zones, and use the dashboard's Zone Status and Volatility Regime to confirm the trade has the right environment.

◾ 1 REACT at the zone — trade the rejection
This is the tool's core use. Price arrives at a high-graded zone and you fade the touch back toward the opposite side of the ladder.
▪️ Setup: wait for price to reach a STRONG / VERY STRONG / EXTREME zone — ideally one with a high hold rate and a clear DEMAND or SUPPLY bias. Check the dashboard: is it the top-ranked zone on the radar? Is the Volatility Regime in NORMAL or EXPANSION (not compressed — compressed means no fuel for a reaction)? Is the Candle Score on the approach bar showing Absorption or Stacked Imbalance in your direction?
▪️ Entry: on rejection out of the zone, with your own confirmation — a wick, an engulfing close, a lower-timeframe structure break, or an order-flow signal that validates the rejection. The zone is the location; it is not the trigger.
▪️ Stop: on the far side of the zone band. The zone has real width derived from the volume distribution — use it. A decisive close through the zone means the volume was cleared and the thesis is wrong.
▪️ Targets: the Nearest ▼ demand or Nearest ▲ supply on the opposite side, then step through the radar tier by tier, banking partials at each graded zone.
⚖️ The cleanest version: price runs into an EXTREME demand zone with 80% hold rate, the Candle Score on the approach prints ABS (absorption), the Volatility Regime shows EXPANSION, and price rejects on the first touch. First touches of fresh high-graded zones with order-flow confirmation are the setup; the fifth retest of the same zone is not.

◾ 2 TRADE THE BREAK — the zone flips role
The mirror case, and the one that saves you when approach 1 fails.
▪️ Setup: a decisive close through a high-graded zone — especially one with a strong hold rate — is meaningful information. It took real volume displacement to clear a level that the market had been defending. Check the delta inside the zone on the break bar: if the breaking candle has strong delta in the break direction, the liquidity was genuinely absorbed, not just pierced.
▪️ Entry: on the retest of the broken zone from the other side, once it has flipped from supply to demand or demand to supply. Wait for price to return to the zone and show respect — a wick, a small-body candle, an absorption signal.
▪️ Stop: back on the original side of the zone. If price reclaims it, the break failed and the original bias holds.
▪️ Targets: the next graded zone in the direction of travel, then the next. Use the radar: if all remaining zones in the direction are weak and untested, structure is thin and the move may extend.
⚖️ Watch the top-ranked zone on the radar. When the strongest zone on the chart breaks and holds as a flip, that is the session's structural event. The naked POCs ahead become magnets.

Rule of thumb: ⭐ First touch of a fresh STRONG / EXTREME zone with high hold rate and Volatility in NORMAL or EXPANSION → look for the rejection trade. ⭐ Decisive close through a high-graded zone confirmed by Candle Score and delta → stop fading it, wait for the retest and trade the flip. ⭐ Low grades, no tests, compressed volatility, or a zone already tested repeatedly → no trade. The score exists to tell you when to do nothing.

⚠️ IMPORTANT NOTICE: Strong Volumetric Zones maps and ranks volume-derived supply and demand zones from reconstructed lower-timeframe order flow. The 0–10 zone score is a descriptive conviction ranking built from volume share, touch count, hold win rate, freshness and delta skew — it is not a backtested win-rate, and this indicator tracks no trade outcomes and reports no performance statistics. The 0–10 candle strength score is built from relative volume, delta dominance, POC concentration, stacked imbalance and value-area tightness — also a descriptive reading, not a signal with a verified edge. Zones are locations, not entries. Volume accumulation occurs only on confirmed bars. These zones are decision support, not a standalone trade trigger. Always combine them with your own strategy, price-action confirmation and risk management. Past behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Volumetric Zones", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, calc_bars_count = 1000)

gE          = "◆ 1 · Volume Engine"
granInput   = input.string("Auto", "Intrabar Granularity", options = ["Auto", "1 Tick", "1 Second", "5 Second", "15 Second", "1 Minute", "5 Minute"], group = gE, tooltip = "Lower timeframe used to reconstruct each candle's internal order flow. Auto scales to the chart timeframe.")
profileBars = input.int(300, "Profile Lookback (bars)", minval = 50, maxval = 900, step = 25, group = gE, tooltip = "How many confirmed bars feed the volume-at-price histogram the zones are carved from.")
binPct      = input.float(10.0, "Bin Size (% of ATR200)", minval = 2.0, maxval = 50.0, step = 1.0, group = gE, tooltip = "Price resolution of the histogram. Smaller = finer nodes, more zones.")

gZ          = "◆ 2 · Volumetric Zones"
maxZones    = input.int(8, "Max Zones", minval = 1, maxval = 14, group = gZ)
peakRadius  = input.int(2, "Node Isolation (bins)", minval = 1, maxval = 6, group = gZ, tooltip = "A bin must dominate this many neighbours on both sides to qualify as a high-volume node.")
minPeakPct  = input.float(18.0, "Min Node Volume (% of POC)", minval = 2.0, maxval = 80.0, step = 2.0, group = gZ)
nodeCut     = input.float(0.40, "Zone Edge Cut-off", minval = 0.10, maxval = 0.90, step = 0.05, group = gZ, tooltip = "The zone grows outward from its node while neighbouring bins hold at least this fraction of the node's volume.")
maxSpan     = input.int(2, "Max Zone Half-Width (bins)", minval = 1, maxval = 20, group = gZ)
minTouches  = input.int(0, "Min Tests To Display", minval = 0, maxval = 10, group = gZ)
minScore    = input.float(0.0, "Min Strength To Display", minval = 0, maxval = 10, step = 0.5, group = gZ)
extendBars  = input.int(60, "Extend Right (bars)", minval = 5, maxval = 240, group = gZ)
showZoneTxt = input.bool(true, "Zone Statistics Text", group = gZ)
showZonePx  = input.bool(true, "Zone Price Tags", group = gZ)
zoneTxtSize = input.string("Small", "Zone Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = gZ)
zoneLnWidth = input.int(1, "Zone Mid-Line Width", minval = 0, maxval = 4, group = gZ, tooltip = "Thickness of the line running through the middle of each zone. Set to 0 to hide it entirely.")
zoneLnFade  = input.int(35, "Zone Mid-Line Fade", minval = 0, maxval = 90, step = 5, group = gZ, tooltip = "Higher = fainter line, so the zone statistics text reads cleanly on top of it.")

gP          = "◆ 3 · Volume Profile"
showHist    = input.bool(true, "Volume-At-Price Histogram", group = gP)
histWidth   = input.int(40, "Histogram Width (bars)", minval = 10, maxval = 120, group = gP)
histMinPct  = input.float(4.0, "Histogram Min Bin %", minval = 0.5, maxval = 30.0, step = 0.5, group = gP)
showMPOC    = input.bool(true, "Master POC Line", group = gP)
showVAL     = input.bool(true, "Value Area High / Low", group = gP)
vaPercent   = input.float(70, "Value Area %", minval = 40, maxval = 95, step = 5, group = gP)

gF           = "◆ 4 · Intrabar Footprint"
showFP       = input.bool(false, "Per-Candle Footprint", group = gF, tooltip = "Block-character volume/delta bars drawn inside the most recent candles.")
fpBars       = input.int(10, "Footprint Candles", minval = 1, maxval = 25, group = gF)
profType     = input.string("Volume", "Footprint Basis", options = ["Volume", "Delta"], group = gF)
rows         = input.int(12, "Footprint Rows", minval = 5, maxval = 30, group = gF)
maxBlocks    = input.int(10, "Max Bar Length", minval = 5, maxval = 20, group = gF)
showCandleVA = input.bool(true, "Candle Value-Area Outline", group = gF)
showFPText   = input.bool(true, "Strength Text In Strong Candles", group = gF)
fpTextMin    = input.float(5.0, "Strength Text Min Score", minval = 0, maxval = 10, step = 0.5, group = gF)

gN          = "◆ 5 · Naked POC & Signals"
showNaked   = input.bool(false, "Track Untested Candle POCs", group = gN)
nakedMin    = input.float(6.0, "Naked POC Min Score", minval = 0, maxval = 10, step = 0.5, group = gN)
nakedMax    = input.int(8, "Max Active Naked POCs", minval = 1, maxval = 20, group = gN)
showSignals = input.bool(false, "Order-Flow Signal Markers", group = gN)
imbRatio    = input.float(3.0, "Imbalance Ratio", minval = 1.5, maxval = 10, step = 0.5, group = gN)

gD          = "◆ 6 · Dashboard & Theme"
showDash    = input.bool(true, "Show Command Dashboard", group = gD)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Bottom Left", "Top Left"], group = gD)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
themeInput  = input.string("Obsidian Aurora", "Color Theme", options = ["Obsidian Aurora", "Obsidian Gold", "Deep Ocean", "Midnight Ember", "Graphite Mono"], group = gD, tooltip = "Every palette is engineered for a pure-black chart background: deep, saturated, never toxic.")
useCustom   = input.bool(false, "Use Custom Colors", group = gD)
cuSup       = input.color(#00E5C0, "Demand", group = gD, inline = "cc1")
cuRes       = input.color(#FF2D78, "Supply", group = gD, inline = "cc1")
cuPoc       = input.color(#FFD166, "POC", group = gD, inline = "cc2")
cuAcc       = input.color(#B388FF, "Accent", group = gD, inline = "cc2")

color thSup = switch themeInput
    "Obsidian Aurora" => #00E5C0
    "Obsidian Gold"   => #2FBF9E
    "Deep Ocean"      => #3FC1C9
    "Midnight Ember"  => #7BD389
    => #D0D6DE

color thRes = switch themeInput
    "Obsidian Aurora" => #FF2D78
    "Obsidian Gold"   => #E0554F
    "Deep Ocean"      => #F45B69
    "Midnight Ember"  => #FF6B4A
    => #7A8391

color thPoc = switch themeInput
    "Obsidian Aurora" => #FFD166
    "Obsidian Gold"   => #FFE08A
    "Deep Ocean"      => #FFD97D
    "Midnight Ember"  => #FFE066
    => #FFFFFF

color thAcc = switch themeInput
    "Obsidian Aurora" => #B388FF
    "Obsidian Gold"   => #C9A227
    "Deep Ocean"      => #6C8AE4
    "Midnight Ember"  => #FFB86B
    => #A8B2C1

color thPanel = switch themeInput
    "Obsidian Aurora" => #0D1117
    "Obsidian Gold"   => #0C0C0E
    "Deep Ocean"      => #0A0F14
    "Midnight Ember"  => #100C0C
    => #0E0E10

color SUP   = useCustom ? cuSup : thSup
color RES   = useCustom ? cuRes : thRes
color POCC  = useCustom ? cuPoc : thPoc
color ACC   = useCustom ? cuAcc : thAcc
color PANEL = thPanel
color TXT   = #E6EDF3
color MUT   = #8B949E
color NEUT  = #58606C

var string tfAuto = "1S"
if barstate.isfirst
    int cs = timeframe.in_seconds()
    tfAuto := cs >= 14400 ? "15" : cs >= 3600 ? "5" : cs >= 900 ? "1" : cs >= 300 ? "15S" : cs >= 60 ? "5S" : "1S"

string tf = switch granInput
    "Auto"      => tfAuto
    "1 Tick"    => "1T"
    "1 Second"  => "1S"
    "5 Second"  => "5S"
    "15 Second" => "15S"
    "1 Minute"  => "1"
    "5 Minute"  => "5"
    => "1S"

var map<int, float> mVol  = map.new<int, float>()
var map<int, float> mBuy  = map.new<int, float>()
var map<int, float> mSell = map.new<int, float>()

var array<float> hH = array.new_float()
var array<float> hL = array.new_float()
var array<float> hC = array.new_float()

var array<box>   zBoxes  = array.new<box>()
var array<line>  zLines  = array.new<line>()
var array<label> zLabels = array.new<label>()
var array<box>   hBoxes  = array.new<box>()
var array<box>   liveFP  = array.new<box>()

var array<float> azTop = array.new_float()
var array<float> azBot = array.new_float()
var array<float> azMid = array.new_float()
var array<float> azScr = array.new_float()
var array<bool>  azRes = array.new_bool()

var array<float> dzPrice  = array.new_float()
var array<float> dzScore  = array.new_float()
var array<int>   dzTests  = array.new_int()
var array<float> dzWin    = array.new_float()
var array<float> dzBuyPct = array.new_float()
var array<bool>  dzIsRes  = array.new_bool()

var float binSize   = na
var float masterPOC = na
var float gVAH      = na
var float gVAL      = na
var float gTotal    = 0.0
var int   gBins     = 0
var int   zCount    = 0

clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
safeDiv(float a, float b) => b == 0.0 ? 0.0 : a / b
fmtV(float v) => str.tostring(v, format.volume)
fmtP(float v) => str.tostring(v, format.mintick)

binAt(int k)  => nz(map.get(mVol, k))
buyAt(int k)  => nz(map.get(mBuy, k))
sellAt(int k) => nz(map.get(mSell, k))

addBin(int k, float v, bool isUp) =>
    map.put(mVol, k, nz(map.get(mVol, k)) + v)
    float b = isUp ? v : 0.0
    float s = isUp ? 0.0 : v
    map.put(mBuy,  k, nz(map.get(mBuy,  k)) + b)
    map.put(mSell, k, nz(map.get(mSell, k)) + s)

szOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

tierShort(float sc) => sc >= 8.5 ? "EXT" : sc >= 7 ? "V.STR" : sc >= 5 ? "STR" : sc >= 3 ? "MOD" : "WK"
tierName(float sc)  => sc >= 8.5 ? "EXTREME" : sc >= 7 ? "VERY STRONG" : sc >= 5 ? "STRONG" : sc >= 3 ? "MODERATE" : "WEAK"
biasName(float buyPct) => buyPct >= 60 ? "DEMAND" : buyPct <= 40 ? "SUPPLY" : "BATTLE"

makeBlocks(int n) =>
    int c = math.max(1, math.min(n, maxBlocks))
    string s = ""
    for i = 1 to c
        s := s + "█"
    s

meter(float pct, int cells) =>
    int f = int(math.round(clamp(pct, 0, 100) / 100.0 * cells))
    string s = ""
    for i = 0 to cells - 1
        s := s + (i < f ? "▰" : "▱")
    s

splitMeter(float buyPct, int cells) =>
    int f = int(math.round(clamp(buyPct, 0, 100) / 100.0 * cells))
    string s = ""
    for i = 0 to cells - 1
        s := s + (i < f ? "█" : "▒")
    s

stars(float sc) =>
    int f = int(math.round(clamp(sc, 0, 10) / 2.0))
    string s = ""
    for i = 0 to 4
        s := s + (i < f ? "★" : "☆")
    s

sessionName() =>
    int h = hour(time, "GMT")
    h < 7 ? "ASIA" : h < 12 ? "LONDON" : h < 16 ? "LDN×NY" : h < 21 ? "NEW YORK" : "ASIA"

scoreColor(bool isRes, float sc) =>
    color b = isRes ? RES : SUP
    color.from_gradient(clamp(sc, 0, 10), 0, 10, color.new(b, 58), b)

zoneStats(float zTop, float zBot) =>
    int n       = array.size(hH)
    int touches = 0
    int holds   = 0
    int brks    = 0
    float sumR  = 0.0
    int lastT   = -1
    bool wasIn  = false
    int side    = 0
    if n > 1
        for i = 0 to n - 1
            float bh = array.get(hH, i)
            float bl = array.get(hL, i)
            float bc = array.get(hC, i)
            bool inside = bh >= zBot and bl <= zTop
            if inside and not wasIn
                float pc = bc
                if i > 0
                    pc := array.get(hC, i - 1)
                side    := pc < zBot ? 1 : pc > zTop ? -1 : 0
                wasIn   := true
                lastT   := i
                touches += 1
            else if not inside and wasIn
                wasIn := false
                bool exAbove = bc > zTop
                bool exBelow = bc < zBot
                bool isHold = (side == 1 and exBelow) or (side == -1 and exAbove)
                if isHold
                    holds += 1
                    float ext = 0.0
                    int jEnd = math.min(n - 1, i + 10)
                    for j = i to jEnd
                        float mv = side == 1 ? zBot - array.get(hL, j) : array.get(hH, j) - zTop
                        ext := math.max(ext, mv)
                    sumR := sumR + ext
                else
                    brks += 1
    float avgR = holds > 0 ? sumR / holds : 0.0
    int since  = lastT >= 0 ? n - 1 - lastT : profileBars
    [touches, holds, brks, avgR, since]

type NakedPOC
    line ln
    float price
    int born
var array<NakedPOC> npocs = array.new<NakedPOC>()

[ltH, ltL, ltC, ltO, ltV] = request.security_lower_tf(syminfo.tickerid, tf, [high, low, close, open, volume])
int nSub = array.size(ltV)

float atr14  = ta.atr(14)
float atr100 = ta.atr(100)
float atr200 = ta.atr(200)
float avgVol = ta.sma(volume, 20)

if na(binSize) and bar_index > 30 and not na(atr200) and atr200 > 0
    binSize := math.max(syminfo.mintick, atr200 * binPct / 100.0)

bool inWin   = bar_index >= last_bar_index - profileBars
bool accumOK = inWin and barstate.isconfirmed and not na(binSize) and binSize > 0

var float dScore = na
var string dTier = "—"
var string dSig  = "BALANCED"
var int dSigDir  = 0

if barstate.islast
    while array.size(liveFP) > 0
        box.delete(array.pop(liveFP))

float barBuy  = 0.0
float barSell = 0.0

if nSub > 0 and high > low
    float rng  = high - low
    float step = rng / rows
    array<float> vol  = array.new_float(rows, 0.0)
    array<float> buy  = array.new_float(rows, 0.0)
    array<float> sell = array.new_float(rows, 0.0)

    for i = 0 to nSub - 1
        float sh  = array.get(ltH, i)
        float sl  = array.get(ltL, i)
        float sv  = array.get(ltV, i)
        float scl = array.get(ltC, i)
        float sop = array.get(ltO, i)
        bool  su  = scl >= sop

        if su
            barBuy := barBuy + sv
        else
            barSell := barSell + sv

        int bot = int(clamp(math.floor((sl - low) / step), 0, rows - 1))
        int top = int(clamp(math.floor((sh - low) / step), 0, rows - 1))
        float share = sv / (top - bot + 1)
        for x = bot to top
            array.set(vol, x, array.get(vol, x) + share)
            if su
                array.set(buy, x, array.get(buy, x) + share)
            else
                array.set(sell, x, array.get(sell, x) + share)

        if accumOK
            int kLo = int(math.floor(sl / binSize))
            int kHi = int(math.floor(sh / binSize))
            int kSpan = kHi - kLo + 1
            if kSpan > 60
                addBin(int(math.floor(scl / binSize)), sv, su)
            else
                float kShare = sv / kSpan
                for k = kLo to kHi
                    addBin(k, kShare, su)

    float maxVol   = array.max(vol)
    float minVol   = array.min(vol)
    float totalVol = array.sum(vol)
    int   pocIdx   = array.indexof(vol, maxVol)
    float pocPrice = low + step * (pocIdx + 0.5)

    int vahIdx = pocIdx
    int valIdx = pocIdx
    float accum = maxVol
    float target = totalVol * vaPercent / 100.0
    int upI = pocIdx + 1
    int dnI = pocIdx - 1
    for z = 1 to rows
        if accum >= target
            break
        if upI > rows - 1 and dnI < 0
            break
        float uV = -1.0
        float dV = -1.0
        if upI <= rows - 1
            uV := array.get(vol, upI)
        if dnI >= 0
            dV := array.get(vol, dnI)
        if uV >= dV
            accum := accum + uV
            vahIdx := upI
            upI := upI + 1
        else
            accum := accum + dV
            valIdx := dnI
            dnI := dnI - 1
    float vah = low + step * (vahIdx + 1)
    float val = low + step * valIdx

    int curB = 0
    int curS = 0
    int maxStk = 0
    int stkDir = 0
    for i = 0 to rows - 1
        bool bImb = false
        bool sImb = false
        if i > 0
            float ps = array.get(sell, i - 1)
            if array.get(buy, i) > 0 and array.get(buy, i) > math.max(ps, 1e-9) * imbRatio
                bImb := true
        if i < rows - 1
            float nb = array.get(buy, i + 1)
            if array.get(sell, i) > 0 and array.get(sell, i) > math.max(nb, 1e-9) * imbRatio
                sImb := true
        if bImb
            curB := curB + 1
            curS := 0
        else if sImb
            curS := curS + 1
            curB := 0
        else
            curB := 0
            curS := 0
        if curB > maxStk
            maxStk := curB
            stkDir := 1
        if curS > maxStk
            maxStk := curS
            stkDir := -1

    float bVol    = barBuy + barSell
    float bDelta  = barBuy - barSell
    float relVol  = safeDiv(bVol, nz(avgVol, bVol))
    float dDom    = safeDiv(math.abs(bDelta), bVol)
    float pocConc = safeDiv(maxVol, totalVol)
    float vaTight = clamp(1 - safeDiv(vah - val, rng), 0, 1)
    float score   = clamp(2.6 * clamp((relVol - 0.8) / 1.7, 0, 1) + 2.6 * clamp(dDom, 0, 1) + 2.2 * clamp((pocConc - 0.10) / 0.40, 0, 1) + 1.4 * clamp(maxStk / 4.0, 0, 1) + 1.2 * vaTight, 0, 10)

    bool atHigh = close >= high - rng * 0.30
    bool atLow  = close <= low + rng * 0.30
    float body  = math.abs(close - open)
    string sig = "BALANCED"
    int sdir = 0
    if dDom > 0.35 and body < rng * 0.30 and relVol > 1.2
        sig := "ABSORPTION"
        sdir := bDelta > 0 ? -1 : 1
    else if relVol > 1.3 and dDom < 0.12 and (atHigh or atLow)
        sig := "EXHAUSTION"
        sdir := atHigh ? -1 : 1
    else if maxStk >= 3
        sig := "STACKED IMB"
        sdir := stkDir

    bool fpWin  = bar_index > last_bar_index - fpBars
    bool fpDraw = showFP and fpWin and (barstate.isconfirmed or barstate.islast)
    bool isLive = barstate.islast and not barstate.isconfirmed

    if fpDraw
        color tint = close >= open ? SUP : RES
        float dMax = 0.0
        if profType == "Delta"
            for j = 0 to rows - 1
                dMax := math.max(dMax, math.abs(array.get(buy, j) - array.get(sell, j)))
        for i = 0 to rows - 1
            float lvlBot = low + step * i
            float lvlTop = lvlBot + step
            float metric    = profType == "Delta" ? math.abs(array.get(buy, i) - array.get(sell, i)) : array.get(vol, i)
            float metricMax = profType == "Delta" ? dMax : maxVol
            float metricMin = profType == "Delta" ? 0.0 : minVol
            float mRange = metricMax - metricMin
            int norm = mRange > 0 ? int(math.round(1 + (metric - metricMin) * (maxBlocks - 1) / mRange)) : 1
            string blocks = makeBlocks(norm)
            bool inVA = i >= valIdx and i <= vahIdx

            color col = na
            if profType == "Delta"
                float d = array.get(buy, i) - array.get(sell, i)
                color dt = d >= 0 ? SUP : RES
                col := color.from_gradient(norm, 1, maxBlocks, color.new(dt, 62), dt)
            else
                col := color.from_gradient(norm, 1, maxBlocks, color.new(tint, 62), tint)
            if not inVA
                col := color.new(NEUT, 25)
            if i == pocIdx
                col := POCC

            string cellText = blocks
            if showFPText and i == pocIdx and score >= fpTextMin
                cellText := blocks + "  " + str.tostring(score, "#.0") + " " + tierShort(score)

            box fb = box.new(bar_index, lvlTop, bar_index + 1, lvlBot, text = cellText, text_halign = text.align_left, text_valign = text.align_center, bgcolor = #00000000, border_color = color(na), text_color = col, text_size = size.tiny)
            if isLive
                array.push(liveFP, fb)

        if showCandleVA
            box vb = box.new(bar_index, vah, bar_index + 1, val, bgcolor = color(na), border_color = color.new(ACC, 58), border_width = 1)
            if isLive
                array.push(liveFP, vb)

    if showSignals and sig != "BALANCED" and barstate.isconfirmed and inWin
        string ab = sig == "ABSORPTION" ? "ABS" : sig == "EXHAUSTION" ? "EXH" : "STK"
        color scol = sdir == 1 ? SUP : RES
        label.new(bar_index, sdir == 1 ? low : high, ab, yloc = yloc.price, style = sdir == 1 ? label.style_label_up : label.style_label_down, color = color.new(scol, 20), textcolor = #FFFFFF, size = size.tiny, tooltip = sig + (sdir == 1 ? " (bullish)" : " (bearish)"))

    if showNaked and barstate.isconfirmed and score >= nakedMin and inWin
        line nl = line.new(bar_index, pocPrice, bar_index + 1, pocPrice, color = color.new(POCC, 35), width = 1, style = line.style_dotted)
        array.push(npocs, NakedPOC.new(nl, pocPrice, bar_index))
        while array.size(npocs) > nakedMax
            NakedPOC old = array.shift(npocs)
            line.delete(old.ln)

    if barstate.islast
        dScore  := score
        dTier   := tierName(score)
        dSig    := sig
        dSigDir := sdir

float barVol   = barBuy + barSell
float barDelta = barBuy - barSell

var float cvd = 0.0
cvd := (barstate.isfirst ? 0.0 : nz(cvd[1])) + barDelta
bool newDay = timeframe.change("D")
var float sessDelta = 0.0
sessDelta := (newDay ? 0.0 : nz(sessDelta[1])) + barDelta

if inWin and barstate.isconfirmed
    array.push(hH, high)
    array.push(hL, low)
    array.push(hC, close)
    if array.size(hH) > profileBars
        array.shift(hH)
        array.shift(hL)
        array.shift(hC)

if showNaked and array.size(npocs) > 0
    for i = array.size(npocs) - 1 to 0
        if i < array.size(npocs)
            NakedPOC n = array.get(npocs, i)
            if bar_index > n.born and high >= n.price and low <= n.price
                line.delete(n.ln)
                array.remove(npocs, i)
            else
                line.set_x2(n.ln, bar_index + 1)

if barstate.islast
    while array.size(zBoxes) > 0
        box.delete(array.pop(zBoxes))
    while array.size(zLines) > 0
        line.delete(array.pop(zLines))
    while array.size(zLabels) > 0
        label.delete(array.pop(zLabels))
    while array.size(hBoxes) > 0
        box.delete(array.pop(hBoxes))

    array.clear(azTop)
    array.clear(azBot)
    array.clear(azMid)
    array.clear(azScr)
    array.clear(azRes)
    array.clear(dzPrice)
    array.clear(dzScore)
    array.clear(dzTests)
    array.clear(dzWin)
    array.clear(dzBuyPct)
    array.clear(dzIsRes)

    zCount    := 0
    masterPOC := na
    gVAH      := na
    gVAL      := na
    gTotal    := 0.0

    array<int> keys = map.keys(mVol)
    int nb = array.size(keys)
    gBins := nb

    if nb > 0 and not na(binSize)
        float maxV = 0.0
        int pocK = 0
        for i = 0 to nb - 1
            int k = array.get(keys, i)
            float v = binAt(k)
            gTotal := gTotal + v
            if v > maxV
                maxV := v
                pocK := k

        if maxV > 0
            masterPOC := (pocK + 0.5) * binSize

            int vahK = pocK
            int valK = pocK
            float acc = maxV
            float tgt = gTotal * vaPercent / 100.0
            int uK = pocK + 1
            int dK = pocK - 1
            for i = 1 to nb * 2
                if acc >= tgt
                    break
                float uv = binAt(uK)
                float dv = binAt(dK)
                if uv >= dv
                    acc  := acc + uv
                    vahK := uK
                    uK   := uK + 1
                else
                    acc  := acc + dv
                    valK := dK
                    dK   := dK - 1
            gVAH := (vahK + 1) * binSize
            gVAL := valK * binSize

            array<int> pkK = array.new_int()
            array<float> pkV = array.new_float()
            float floorV = maxV * minPeakPct / 100.0
            for i = 0 to nb - 1
                int k = array.get(keys, i)
                float v = binAt(k)
                if v < floorV
                    continue
                bool isPeak = true
                for j = 1 to peakRadius
                    if binAt(k + j) > v or binAt(k - j) > v
                        isPeak := false
                        break
                if isPeak
                    array.push(pkK, k)
                    array.push(pkV, v)

            int np = array.size(pkK)
            if np > 1
                for i = 0 to np - 2
                    for j = i + 1 to np - 1
                        if array.get(pkV, j) > array.get(pkV, i)
                            int tk = array.get(pkK, i)
                            float tv = array.get(pkV, i)
                            array.set(pkK, i, array.get(pkK, j))
                            array.set(pkV, i, array.get(pkV, j))
                            array.set(pkK, j, tk)
                            array.set(pkV, j, tv)

            array<int> accK   = array.new_int()
            array<int> accTop = array.new_int()
            array<int> accBot = array.new_int()

            if np > 0
                for i = 0 to np - 1
                    if array.size(accK) >= maxZones
                        break
                    int k = array.get(pkK, i)
                    float v = array.get(pkV, i)
                    float cut = v * nodeCut

                    int kTop = k
                    for s = 1 to maxSpan
                        if binAt(k + s) >= cut
                            kTop := k + s
                        else
                            break
                    int kBot = k
                    for s = 1 to maxSpan
                        if binAt(k - s) >= cut
                            kBot := k - s
                        else
                            break

                    bool ok = true
                    if array.size(accK) > 0
                        for a = 0 to array.size(accK) - 1
                            if not (kBot > array.get(accTop, a) + 1 or kTop < array.get(accBot, a) - 1)
                                ok := false
                                break
                    if ok
                        array.push(accK, k)
                        array.push(accTop, kTop)
                        array.push(accBot, kBot)

            int nAcc = array.size(accK)

            float bestVol = 0.0
            if nAcc > 0
                for a = 0 to nAcc - 1
                    float sm = 0.0
                    for k = array.get(accBot, a) to array.get(accTop, a)
                        sm := sm + binAt(k)
                    bestVol := math.max(bestVol, sm)

            float atrRef = nz(atr14, syminfo.mintick * 10)
            int x1 = math.max(0, bar_index - profileBars)
            int x2 = bar_index + extendBars

            if nAcc > 0
                for a = 0 to nAcc - 1
                    int kC = array.get(accK, a)
                    int kT = array.get(accTop, a)
                    int kB = array.get(accBot, a)

                    float zVol  = 0.0
                    float zBuy  = 0.0
                    float zSell = 0.0
                    for k = kB to kT
                        zVol  := zVol + binAt(k)
                        zBuy  := zBuy + buyAt(k)
                        zSell := zSell + sellAt(k)

                    float zTop = (kT + 1) * binSize
                    float zBot = kB * binSize
                    float zMid = (kC + 0.5) * binSize

                    [tch, hld, brk, avgR, since] = zoneStats(zTop, zBot)
                    int tests = hld + brk
                    float winR = tests > 0 ? float(hld) / float(tests) * 100.0 : 0.0
                    float buyPct = safeDiv(zBuy, zVol) * 100.0
                    float volPct = safeDiv(zVol, gTotal) * 100.0

                    float sVol   = 3.5 * clamp(safeDiv(zVol, bestVol), 0, 1)
                    float sTouch = 2.5 * clamp(tch / 6.0, 0, 1)
                    float sWin   = 2.0 * clamp((winR - 30.0) / 60.0, 0, 1)
                    float sFresh = 1.0 * clamp(1.0 - safeDiv(since, profileBars), 0, 1)
                    float sDelta = 1.0 * clamp(safeDiv(math.abs(zBuy - zSell), zVol) / 0.35, 0, 1)
                    float sc     = clamp(sVol + sTouch + sWin + sFresh + sDelta, 0, 10)

                    if tch < minTouches or sc < minScore
                        continue

                    bool isRes = zMid > close
                    color zc = scoreColor(isRes, sc)

                    array.push(zBoxes, box.new(x1, zTop, x2, zBot, border_color = color.new(zc, 45), border_width = 1, bgcolor = color.new(zc, 88)))
                    if zoneLnWidth > 0
                        array.push(zLines, line.new(x1, zMid, x2, zMid, color = color.new(zc, zoneLnFade), width = zoneLnWidth))

                    zCount += 1
                    array.push(azTop, zTop)
                    array.push(azBot, zBot)
                    array.push(azMid, zMid)
                    array.push(azScr, sc)
                    array.push(azRes, isRes)

                    array.push(dzPrice, zMid)
                    array.push(dzScore, sc)
                    array.push(dzTests, tests)
                    array.push(dzWin, winR)
                    array.push(dzBuyPct, buyPct)
                    array.push(dzIsRes, isRes)

                    if showZoneTxt
                        string wTxt = tests > 0 ? str.tostring(winR, "#") + "%" : "—"
                        string rTxt = hld > 0 ? str.tostring(safeDiv(avgR, atrRef), "#.0") + "×ATR" : "—"
                        string txt = stars(sc) + "   " + (isRes ? "SUPPLY-SIDE" : "DEMAND-SIDE") + "  ·  " + str.tostring(sc, "#.0") + "/10 " + tierShort(sc) + "  ·  VOL " + str.tostring(volPct, "#.0") + "%  ·  TESTS " + str.tostring(tests) + "  ·  HOLD " + wTxt + "  ·  REACT " + rTxt + "  ·  " + biasName(buyPct) + " " + str.tostring(buyPct, "#") + "/" + str.tostring(100.0 - buyPct, "#")
                        int sx = x1 + int(math.round((x2 - x1) * 0.28))
                        array.push(zLabels, label.new(sx, zMid, txt, color = color.new(zc, 78), textcolor = TXT, style = label.style_label_center, size = szOf(zoneTxtSize), textalign = text.align_left))

                    if showZonePx
                        array.push(zLabels, label.new(x2, zMid, fmtP(zMid) + "   " + str.tostring(sc, "#.0"), color = color.new(zc, 20), textcolor = #FFFFFF, style = label.style_label_left, size = size.small))

            if showHist
                int hx = bar_index + extendBars + 6
                float hFloor = maxV * histMinPct / 100.0
                int drawn = 0
                for i = 0 to nb - 1
                    if drawn >= 160
                        break
                    int k = array.get(keys, i)
                    float v = binAt(k)
                    if v < hFloor
                        continue
                    float bp = safeDiv(buyAt(k), v) * 100.0
                    color bc = k == pocK ? POCC : bp >= 50 ? SUP : RES
                    int ln = int(math.round(1 + safeDiv(v, maxV) * histWidth))
                    int tr = int(math.round(82 - safeDiv(v, maxV) * 52))
                    array.push(hBoxes, box.new(hx, (k + 1) * binSize, hx + ln, k * binSize, border_color = color.new(bc, 72), border_width = 1, bgcolor = color.new(bc, tr)))
                    drawn += 1

            int px = bar_index + extendBars + histWidth + 8
            if showMPOC
                array.push(zLines, line.new(x1, masterPOC, px, masterPOC, color = color.new(POCC, 20), width = 1))
                array.push(zLabels, label.new(px, masterPOC, "MASTER POC  " + fmtP(masterPOC), color = color.new(POCC, 12), textcolor = #000000, style = label.style_label_left, size = size.small))
            if showVAL
                array.push(zLines, line.new(x1, gVAH, x2, gVAH, color = color.new(ACC, 35), width = 1, style = line.style_dashed))
                array.push(zLines, line.new(x1, gVAL, x2, gVAL, color = color.new(ACC, 35), width = 1, style = line.style_dashed))
                array.push(zLabels, label.new(x2, gVAH, "VAH " + fmtP(gVAH), color = color.new(ACC, 40), textcolor = TXT, style = label.style_label_left, size = size.tiny))
                array.push(zLabels, label.new(x2, gVAL, "VAL " + fmtP(gVAL), color = color.new(ACC, 40), textcolor = TXT, style = label.style_label_left, size = size.tiny))

float nearResPx = na
float nearResSc = 0.0
float nearSupPx = na
float nearSupSc = 0.0
bool  inZone    = false
float inZoneSc  = 0.0
bool  inZoneRes = false

if array.size(azMid) > 0
    for i = 0 to array.size(azMid) - 1
        float m = array.get(azMid, i)
        float t = array.get(azTop, i)
        float b = array.get(azBot, i)
        float s = array.get(azScr, i)
        if close <= t and close >= b and (not inZone or s > inZoneSc)
            inZone    := true
            inZoneSc  := s
            inZoneRes := array.get(azRes, i)
        if m > close
            if na(nearResPx) or m < nearResPx
                nearResPx := m
                nearResSc := s
        else
            if na(nearSupPx) or m > nearSupPx
                nearSupPx := m
                nearSupSc := s

string dpos = switch dashPos
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Top Left"     => position.top_left
    => position.top_right

string dsz = szOf(dashSize)

var table dash = table.new(dpos, 3, 30, bgcolor = color.new(PANEL, 6), frame_color = color.new(ACC, 45), frame_width = 1, border_color = color.new(PANEL, 40), border_width = 1)
var bool dashBuilt = false

setC(int c, int r, string t, color fg, color bg, string al) =>
    table.cell(dash, c, r, t, text_color = fg, bgcolor = bg, text_size = dsz, text_halign = al)

row3(int r, string lbl, string mid, string val, color lblC, color midC, color valC) =>
    setC(0, r, lbl, lblC, na, text.align_left)
    setC(1, r, mid, midC, na, text.align_center)
    setC(2, r, val, valC, na, text.align_right)

if barstate.islast and showDash
    if not dashBuilt
        for r = 0 to 29
            for c = 0 to 2
                table.cell(dash, c, r, "", text_size = dsz)
        table.merge_cells(dash, 0, 0,  2, 0)
        table.merge_cells(dash, 0, 1,  2, 1)
        table.merge_cells(dash, 0, 2,  2, 2)
        table.merge_cells(dash, 0, 3,  2, 3)
        table.merge_cells(dash, 1, 9,  2, 9)
        table.merge_cells(dash, 0, 10, 2, 10)
        table.merge_cells(dash, 0, 11, 2, 11)
        table.merge_cells(dash, 0, 16, 2, 16)
        table.merge_cells(dash, 0, 17, 2, 17)
        table.merge_cells(dash, 0, 24, 2, 24)
        table.merge_cells(dash, 0, 25, 2, 25)

        table.cell(dash, 0, 0, "⚡  S T R O N G   V O L U M E T R I C   Z O N E S", text_color = TXT, bgcolor = color.new(ACC, 72), text_size = dsz, text_halign = text.align_center)
        table.cell(dash, 0, 2,  "──────────────────────────────", text_color = color.new(ACC, 62), text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 0, 10, "──────────────────────────────", text_color = color.new(ACC, 62), text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 0, 16, "──────────────────────────────", text_color = color.new(ACC, 62), text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 0, 24, "──────────────────────────────", text_color = color.new(ACC, 62), text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 0, 3,  "◤ LIVE ORDER FLOW ◢",      text_color = ACC, bgcolor = color.new(ACC, 88), text_size = dsz, text_halign = text.align_center)
        table.cell(dash, 0, 11, "◤ VOLUME PROFILE ◢",       text_color = ACC, bgcolor = color.new(ACC, 88), text_size = dsz, text_halign = text.align_center)
        table.cell(dash, 0, 17, "◤ REACTION ZONE RADAR ◢",  text_color = ACC, bgcolor = color.new(ACC, 88), text_size = dsz, text_halign = text.align_center)
        table.cell(dash, 0, 25, "◤ REGIME ◢",               text_color = ACC, bgcolor = color.new(ACC, 88), text_size = dsz, text_halign = text.align_center)
        dashBuilt := true

    float buyPct   = safeDiv(barBuy, barVol) * 100.0
    float sellPct  = 100.0 - buyPct
    color dCol     = barDelta >= 0 ? SUP : RES
    color cvdCol   = cvd >= 0 ? SUP : RES
    string cvdArr  = cvd >= nz(cvd[5], cvd) ? "▲ ▲ ▲" : "▼ ▼ ▼"
    color sdCol    = sessDelta >= 0 ? SUP : RES
    float scNow    = nz(dScore)
    color scoreCol = scNow >= 7 ? SUP : scNow >= 5 ? POCC : scNow >= 3 ? MUT : NEUT
    color sigCol   = dSig == "BALANCED" ? MUT : dSigDir == 1 ? SUP : RES
    string sigTxt  = dSig + (dSig == "BALANCED" ? "" : dSigDir == 1 ? "  ▲" : "  ▼")
    float vaW      = safeDiv(nz(gVAH) - nz(gVAL), close) * 100.0
    float volPct   = clamp(safeDiv(atr14, nz(atr100, atr14)) * 50.0, 0, 100)
    string volSt   = volPct < 40 ? "COMPRESSED" : volPct > 65 ? "EXPANSION" : "NORMAL"
    float depth    = clamp(float(array.size(hH)) / math.max(profileBars, 1) * 100.0, 0, 100)

    table.cell(dash, 0, 1, syminfo.ticker + "  •  " + timeframe.period + "  •  LTF " + tf + "  •  " + sessionName(), text_color = MUT, text_size = size.tiny, text_halign = text.align_center)

    row3(4, "Delta",        meter(math.abs(safeDiv(barDelta, barVol)) * 100.0, 8), (barDelta > 0 ? "+" : "") + fmtV(barDelta), MUT, dCol, dCol)
    row3(5, "Buy / Sell",   splitMeter(buyPct, 8), str.tostring(buyPct, "#") + " / " + str.tostring(sellPct, "#") + "%", MUT, buyPct >= 50 ? SUP : RES, TXT)
    row3(6, "CVD",          cvdArr, fmtV(cvd), MUT, cvdCol, cvdCol)
    row3(7, "Session Δ",    meter(clamp(math.abs(safeDiv(sessDelta, math.max(barVol * 10.0, 1.0))) * 100.0, 0, 100), 8), (sessDelta > 0 ? "+" : "") + fmtV(sessDelta), MUT, sdCol, sdCol)
    row3(8, "Candle Score", meter(scNow * 10.0, 8), str.tostring(scNow, "#.0") + "/10  " + dTier, MUT, scoreCol, scoreCol)
    setC(0, 9, "Flow Signal", MUT, na, text.align_left)
    table.cell(dash, 1, 9, sigTxt, text_color = sigCol, bgcolor = color.new(sigCol, 86), text_size = dsz, text_halign = text.align_center)

    row3(12, "Master POC",    na(masterPOC) ? "—" : close >= masterPOC ? "ABOVE" : "BELOW", na(masterPOC) ? "—" : fmtP(masterPOC), MUT, na(masterPOC) ? MUT : close >= masterPOC ? SUP : RES, POCC)
    row3(13, "Value Area",    meter(clamp(vaW * 20.0, 0, 100), 8), na(gVAH) ? "—" : fmtP(gVAL) + " ‥ " + fmtP(gVAH), MUT, ACC, TXT)
    row3(14, "VA Location",   na(gVAH) ? "—" : close <= gVAH and close >= gVAL ? "INSIDE" : "OUTSIDE", str.tostring(vaW, "#.00") + "% wide", MUT, na(gVAH) ? MUT : close <= gVAH and close >= gVAL ? ACC : POCC, MUT)
    row3(15, "Profile Depth", meter(depth, 8), str.tostring(array.size(hH)) + "b · " + str.tostring(gBins) + " bins · " + str.tostring(zCount) + "z", MUT, ACC, MUT)

    int shown = 0
    int nzd = array.size(dzPrice)
    if nzd > 0
        array<int> ord = array.new_int()
        for i = 0 to nzd - 1
            array.push(ord, i)
        if nzd > 1
            for i = 0 to nzd - 2
                for j = i + 1 to nzd - 1
                    if array.get(dzScore, array.get(ord, j)) > array.get(dzScore, array.get(ord, i))
                        int tmp = array.get(ord, i)
                        array.set(ord, i, array.get(ord, j))
                        array.set(ord, j, tmp)
        for q = 0 to nzd - 1
            if shown >= 6
                break
            int zi   = array.get(ord, q)
            float p  = array.get(dzPrice, zi)
            float s  = array.get(dzScore, zi)
            bool isR = array.get(dzIsRes, zi)
            float bp = array.get(dzBuyPct, zi)
            int te   = array.get(dzTests, zi)
            float wr = array.get(dzWin, zi)
            color zc = scoreColor(isR, s)
            int rr = 18 + shown
            table.cell(dash, 0, rr, (isR ? "▲ " : "▼ ") + fmtP(p), text_color = TXT, bgcolor = color.new(zc, 80), text_size = dsz, text_halign = text.align_left)
            table.cell(dash, 1, rr, stars(s), text_color = zc, bgcolor = color.new(zc, 90), text_size = dsz, text_halign = text.align_center)
            table.cell(dash, 2, rr, str.tostring(s, "#.0") + " · " + biasName(bp) + " · T" + str.tostring(te) + " · " + (te > 0 ? str.tostring(wr, "#") + "%" : "—"), text_color = zc, bgcolor = color.new(zc, 90), text_size = size.tiny, text_halign = text.align_right)
            shown += 1
    if shown == 0
        row3(18, "—", "no qualifying zones", "—", MUT, MUT, MUT)
        shown := 1
    if shown < 6
        for r = 18 + shown to 23
            row3(r, "", "", "", MUT, MUT, MUT)

    row3(26, "Volatility",  meter(volPct, 8), volSt, MUT, volPct > 65 ? POCC : ACC, volPct > 65 ? POCC : ACC)
    row3(27, "Zone Status", inZone ? meter(inZoneSc * 10.0, 8) : "▱▱▱▱▱▱▱▱", inZone ? "IN " + (inZoneRes ? "SUPPLY" : "DEMAND") + " " + str.tostring(inZoneSc, "#.0") : "OPEN AIR", MUT, inZone ? inZoneRes ? RES : SUP : NEUT, inZone ? inZoneRes ? RES : SUP : MUT)
    row3(28, "Nearest ▲",   na(nearResPx) ? "—" : stars(nearResSc), na(nearResPx) ? "—" : fmtP(nearResPx), MUT, RES, RES)
    row3(29, "Nearest ▼",   na(nearSupPx) ? "—" : stars(nearSupSc), na(nearSupPx) ? "—" : fmtP(nearSupPx), MUT, SUP, SUP)

bool aEnterZone   = inZone and not inZone[1]
bool aEnterStrong = aEnterZone and inZoneSc >= 7
bool aLeaveZone   = not inZone and inZone[1]
bool aStrongBar   = barstate.isconfirmed and not na(dScore) and dScore >= 7
bool aFlowSignal  = barstate.isconfirmed and dSig != "BALANCED"

alertcondition(aEnterZone,   "Volumetric Zone Entry",        "Strong Volumetric Zones: price entered a volumetric zone.")
alertcondition(aEnterStrong, "Strong Volumetric Zone Entry", "Strong Volumetric Zones: price entered a high-strength (7+) volumetric zone.")
alertcondition(aLeaveZone,   "Volumetric Zone Exit",         "Strong Volumetric Zones: price left a volumetric zone.")
alertcondition(aStrongBar,   "High-Strength Candle",         "Strong Volumetric Zones: high-strength order-flow candle (score >= 7).")
alertcondition(aFlowSignal,  "Order-Flow Signal",            "Strong Volumetric Zones: absorption / exhaustion / stacked-imbalance signal fired.")

plot(barDelta,   "Bar Delta",     color = barDelta >= 0 ? SUP : RES,   display = display.data_window)
plot(cvd,        "CVD",           color = cvd >= 0 ? SUP : RES,        display = display.data_window)
plot(sessDelta,  "Session Delta", color = sessDelta >= 0 ? SUP : RES,  display = display.data_window)
plot(nz(dScore), "Candle Score",  color = ACC,                         display = display.data_window)
````
