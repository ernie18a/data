# Strong Liquidity Outlook | ProjectSyndicate

- url: https://www.tradingview.com/script/XMMe9gLh-Strong-Liquidity-Outlook-ProjectSyndicate/
- type: indicator
- pine_id: PUB;bd16d6822651452c89c1219acda42e4d
- version: 1.0

## Description

Strong Liquidity Outlook tracks the two opposed states of liquidity — the voids price must fill and the order shelves price must sweep — scores them on a single 0–10 scale, merges them where they agree, and projects a forward route through them. Every number on the panel is measured, not invented.

[image]https://www.tradingview.com/x/VtHA814o/[/image]

🟥🟩 IMPORTANT INFO: Because zone height, reach and distance are all ATR-derived, the engine self-calibrates to each symbol. Start on M5–H1. On daily charts raise Min Gap Size (%), as intraday voids become noise.

🧲 Two Draw Engines, One Scoreboard — the core of this tool. Most level tools track one thing. This one tracks the two opposed states of liquidity and forces them to compete on the same 0–10 scale. Imbalance zones are the voids — bar-to-bar gaps where no trade occurred, an absence price is drawn back to fill. Stop-pool zones are the opposite — dense shelves of resting orders sitting above swing highs and below swing lows, ATR-sized and volume-weighted. A gap is a vacuum; a pool is a wall. Both pull price, for opposite reasons, and until now you had to run two indicators to see them together.

🎯 Confluence Merging — where the real levels come from. Overlapping same-side zones do not stack into visual mush. They fuse. When a gap opens into the same pocket a stop pool already occupies, the two merge into one confluence zone, their volume mass adds, their scores compound, and the zone is tagged ×2 or ×3 on the chart. The levels that survive this merge are the ones two independent mechanisms agree on — and they rise to the top of the ranked panel automatically. No manual confluence hunting.

[image]https://www.tradingview.com/x/0EADMxh9/[/image]

⭐ 0–10 Zone Strength Score. Every zone is graded on a transparent weighted blend of five factors: volume pressure at formation, zone size relative to ATR, number of tests it has survived, confluence depth, and proximity to current price. Optional idle decay bleeds a zone's score toward a floor while price ignores it, so a stale level cannot masquerade as a live one. Strong zones render sharp and opaque; weak ones fade. Every weight is exposed in settings.

♻️ Live Zone Lifecycle — INTACT → CONSUMED % → FILLED / SWEPT. A zone above price is eaten from its floor upward. A zone below price is eaten from its ceiling down. The script renders that literally: the bright remainder is the unworked part of the void, the dimmed slice behind it is what price has already consumed, and the label reports the exact percentage. When price closes fully through, an imbalance is marked FILLED and a pool is marked SWEPT. Every fresh re-entry — not just the first — counts as a new test and feeds the score.

🗺️ Scenario Builder — the powerful new part. This is not a hand-drawn arrow. The script walks your live zone map forward from the last bar and assembles a route from surveyed levels:
1 · TRIGGER — the nearest qualifying zone in the trigger direction. Price runs the stops first.
2 · REVERSE — a retrace of that leg. If a real zone sits within your ATR tolerance of that level, the waypoint snaps onto it and is flagged ⚑.
3 · RETEST — a partial recovery that deliberately fails short of the trigger extreme.
4 · TARGET — the strongest-scoring zone on the far side of price. Not the flashiest, not the furthest. The highest-graded one.
5 · EXTENSION — the next zone beyond target, if one exists.
Trigger direction defaults to Auto, taken from the live net-pull bias. Bars-per-leg are allocated proportionally to price travel, so steep legs stay steep and the path never looks synthetic.

🧮 Honest Path Confidence (0–100), never a fake "chance". Here is the rule the entire script is built on: if a leg is not anchored to a real, scored zone, it is drawn hollow and labelled as projected. If no zone exists on the far side, the target falls back to a measured move — and it says so, the vertex is drawn unfilled, and the confidence meter is cut. An unsnapped reverse waypoint is dimmed. Path Confidence is the mean of the trigger and target zone scores, penalized for anything unanchored. It is labelled confidence in the levels, not probability of the path. You will never see an invented "87% chance price reaches this target." The path is level geometry rendered forward. It re-solves every tick as zones score up, decay, or get swept — a current-state projection, not a committed forecast.

[image]https://www.tradingview.com/x/fhyoyNBb/[/image]

📊 Five-Slide Dashboard — every figure measured. A compact panel that auto-rotates (or pins to one slide) with ●○○○○ position pips.
OVERVIEW — regime, live zone counts by side, elite count, a tug-of-war net-pull meter, and the nearest zone above and below with strength bars and real distance.
TOP ZONES — the eight highest-scored live zones, ranked, each with type icon, confluence multiplier, price, and a score meter.
STATISTICS — this is the part nobody else ships. Gap fill rate, pool sweep rate, average bars to resolution, and post-resolution reaction rate, each with its own meter and its raw hits / total count exposed beside it.
PRESSURE — zone mass by side, estimated volume split, net delta above and below, and how many zones are partially eaten.
SCENARIO — the full waypoint list with prices, move-to-target in % and ATR, an approximate R multiple, the confidence meter, and an explicit anchoring readout.

📐 Statistics That Cannot Lie To You. Every zone ever detected stays in the denominator. Retiring a stale zone from the chart never removes it from the fill-rate sample. The reaction test — did price travel back n × ATR within n bars after a fill or sweep? — scores each resolution exactly once, hit or miss, and both numbers are shown. Samples under 20 events are flagged THIN — read with care rather than dressed up as a rate. Volume and delta figures are derived from bar geometry, not tick data, and the panel states that on its own row.

🔬 Non-Repainting By Construction. Gaps are read off closed bars only. Pivot-confirmed pools lag by your Pivot Right setting — that is confirmation lag, not repainting, and nothing is ever redrawn backwards once a zone is placed. All state mutations happen on bar close.

🎨 Clean Themed Visuals. Dashed borders on imbalance zones, solid on stop pools, so you read the type at a glance. Midlines on elite zones. Nearest-zone rails extending to current price. The scenario path renders as a three-pass polyline — two soft glow layers under a crisp core — with diamond waypoint markers, a terminal arrowhead, and dotted trigger/target rails.

🔔 Built-In Alerts. New imbalance zone, new stop-pool zone, zone tested, imbalance filled, stop pool swept, elite zone approach, and scenario trigger reached — each firing on bar close, formatted for manual or automated use.

🔧 Fully Customizable. Both detectors toggle independently. Gap size floors in both % and ATR. Pivot sensitivity, pool height and offset. All five score weights, decay rate and floor. Merge threshold, stale-zone retirement, reaction window and size. The complete scenario filter set — path detail, trigger direction, waypoint score floor, projection length, retrace and retest ratios, snap tolerance. Plus every colour, label, meter and panel option.

🎯 Why this is different. Most liquidity tools show you one kind of level and attach a fabricated probability to it. This one tracks both kinds — the voids and the walls — scores them on one honest scale, merges them where they agree, then projects a route through them and tells you which parts of that route are real. Then it grades its own zones against history and shows you the fill rate, the sweep rate, and the reaction rate, with the raw counts, including when the sample is too thin to trust.

🧭 How to trade it. Read the panel before the chart. The net-pull meter tells you which side the field is leaning. The TOP ZONES slide tells you which levels have actually earned attention. Treat the scenario trigger as where liquidity gets taken and the target as the logical objective — and check the anchoring row first. A solid, snapped path into a high-scored target is a clean roadmap. A hollow TARGET (projected) vertex means the market has no graded level behind that move, and you should size accordingly. Cross-check the STATISTICS slide for your symbol: if gaps on your instrument fill 38% of the time, trade them like a 38% event.

⚠️ Important. This is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Everything it displays is descriptive of current zone strength, real distance, and measured historical behaviour. Path Confidence is a read on the quality of the levels involved, not a forecast of price. Volume-pressure figures are geometric estimates, not tick data. Historical rates describe what has happened on the loaded chart and do not predict what will happen next; thin samples are flagged for exactly that reason. Behaviour varies by symbol, timeframe, and configuration. Always combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6
indicator("Strong Liquidity Outlook", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100, max_bars_back = 5000)

int DRAW_MAX = 4000

gEng = "═══ Engine ═══"
useGaps    = input.bool(true,  "Imbalance Zones (gaps)",   group = gEng)
usePools   = input.bool(true,  "Stop-Pool Zones (swings)", group = gEng)
maxMagnets = input.int(28, "Max Live Zones", minval = 4, maxval = 60, group = gEng, tooltip = "Oldest resolved zones are recycled first once the cap is reached.")
lookback   = input.int(3000, "Lookback (bars, 0 = all)", minval = 0, group = gEng)
extRight   = input.int(18, "Zone Extension (bars)", minval = 0, maxval = 200, group = gEng)
atrLen     = input.int(200, "ATR Length", minval = 5, maxval = 500, group = gEng)
volLen     = input.int(50, "Volume Baseline Length", minval = 5, group = gEng)

gGap = "═══ Imbalance Zones ═══"
minGapPct = input.float(0.0,  "Min Gap Size (% of price)", minval = 0.0, step = 0.01, group = gGap)
minGapAtr = input.float(0.05, "Min Gap Size (ATR mult)",   minval = 0.0, step = 0.01, group = gGap, tooltip = "Both filters must pass. Raise on noisy intraday charts.")
rthOnly   = input.bool(false, "Regular Session Gaps Only", group = gGap)

gPool = "═══ Stop-Pool Zones ═══"
leftBars  = input.int(12, "Pivot Left",  minval = 1, maxval = 100, group = gPool)
rightBars = input.int(4,  "Pivot Right", minval = 1, maxval = 50,  group = gPool)
poolH     = input.float(0.45, "Pool Height (ATR mult)", minval = 0.05, maxval = 5.0, step = 0.05, group = gPool, tooltip = "Depth of the liquidity shelf projected beyond the swing extreme.")
poolBuf   = input.float(0.03, "Pool Offset Beyond Swing (ATR mult)", minval = 0.0, maxval = 1.0, step = 0.01, group = gPool)

gScore = "═══ Scoring (0–10) ═══"
minScore  = input.float(0.0, "Hide Zones Below Score", minval = 0.0, maxval = 10.0, step = 0.5, group = gScore)
eliteThr  = input.float(8.0, "Elite Threshold", minval = 5.0, maxval = 10.0, step = 0.5, group = gScore)
sizeNorm  = input.float(1.20, "Height For Full Size Score (ATR)", minval = 0.1, step = 0.05, group = gScore)
volNorm   = input.float(1.40, "Volume For Full Volume Score (x baseline)", minval = 0.1, step = 0.1, group = gScore)
testNorm  = input.float(3.0,  "Tests For Full Test Score", minval = 1.0, step = 0.5, group = gScore)
confNorm  = input.float(2.0,  "Confluence For Full Conf. Score", minval = 1.0, step = 0.5, group = gScore)
proxNorm  = input.float(6.0,  "Proximity Range (ATR)", minval = 0.5, step = 0.5, group = gScore)
wVol      = input.float(0.25, "Weight: Volume Pressure",  minval = 0, maxval = 1, step = 0.05, group = gScore)
wSize     = input.float(0.20, "Weight: Zone Size",        minval = 0, maxval = 1, step = 0.05, group = gScore)
wTest     = input.float(0.20, "Weight: Tests / Reactions", minval = 0, maxval = 1, step = 0.05, group = gScore)
wConf     = input.float(0.20, "Weight: Confluence",       minval = 0, maxval = 1, step = 0.05, group = gScore)
wProx     = input.float(0.15, "Weight: Proximity",        minval = 0, maxval = 1, step = 0.05, group = gScore)
useDecay  = input.bool(true, "Decay Score While Untouched", group = gScore)
decayBars = input.int(400, "Full Decay Over (idle bars)", minval = 20, maxval = 5000, group = gScore)
decayFloor= input.float(0.60, "Decay Floor", minval = 0.1, maxval = 1.0, step = 0.05, group = gScore)

gConf = "═══ Confluence & Lifecycle ═══"
mergeOn   = input.bool(true, "Merge Overlapping Zones", group = gConf, tooltip = "Overlapping same-side zones fuse into one confluence zone (score and pressure add).")
overlapThr= input.int(15, "Merge Overlap Threshold (%)", minval = 1, maxval = 100, group = gConf)
staleDev  = input.float(6.0, "Retire Zone When Price Deviates (%)", minval = -1.0, step = 0.5, group = gConf, tooltip = "-1 keeps every zone forever. Otherwise a zone is retired once price travels this far away from it.")
keepDone  = input.bool(true, "Keep Resolved Zones On Chart", group = gConf, tooltip = "Purely cosmetic. Statistics always count every event regardless of this setting.")
reactBars = input.int(20, "Reaction Window (bars)", minval = 2, maxval = 200, group = gConf)
reactMult = input.float(1.0, "Reaction Size (ATR mult)", minval = 0.1, step = 0.1, group = gConf, tooltip = "After a fill/sweep, price must travel this far back to count as a reaction.")

gSty = "═══ Style ═══"
buyCol    = input.color(#22d3a6, "Zone Below Price (demand pull)", group = gSty)
sellCol   = input.color(#e957d6, "Zone Above Price (supply pull)", group = gSty)
zoneTr    = input.int(84, "Zone Transparency", minval = 60, maxval = 96, group = gSty)
doneTr    = input.int(93, "Resolved Transparency", minval = 60, maxval = 99, group = gSty)
showTags  = input.bool(true, "Zone Labels", group = gSty)
tagSizeS  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = gSty)
showMid   = input.bool(true, "Midlines On Elite Zones", group = gSty)
showRail  = input.bool(true, "Nearest-Zone Rails", group = gSty, tooltip = "Extends the closest active zone above and below price.")

gScen = "═══ Scenario Builder ═══"
scenOn    = input.bool(true, "Build Forward Scenario", group = gScen, tooltip = "Projects a path from the last bar that walks the live zones in sequence. This is a geometric outlook built from current levels — not a forecast.")
scenShape = input.string("Standard", "Path Detail", options = ["Simple", "Standard", "Extended"], group = gScen, tooltip = "Simple: trigger → target.  Standard: adds a reverse and a retest leg.  Extended: adds a continuation leg beyond target.")
scenDir   = input.string("Auto (net pull)", "Trigger Direction", options = ["Auto (net pull)", "Up First", "Down First"], group = gScen)
scenMinSc = input.float(2.0, "Min Waypoint Score", minval = 0.0, maxval = 10.0, step = 0.5, group = gScen)
projBars  = input.int(70, "Projection Length (bars)", minval = 12, maxval = 400, group = gScen)
revPct    = input.float(55.0, "Reverse Retrace (% of trigger leg)", minval = 10.0, maxval = 95.0, step = 5.0, group = gScen)
retestPct = input.float(55.0, "Retest Recovery (% of reverse leg)", minval = 10.0, maxval = 95.0, step = 5.0, group = gScen)
snapAtr   = input.float(0.75, "Snap Waypoint To Zone Within (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = gScen)
scenCol   = input.color(#ffb020, "Path Color", group = gScen)
scenGlow  = input.bool(true, "Glow", group = gScen)
scenLabs_ = input.bool(true, "Waypoint Labels", group = gScen)
scenRails = input.bool(true, "Trigger / Target Rails", group = gScen)

gDash = "═══ Dashboard ═══"
showDash  = input.bool(true, "Show Dashboard", group = gDash)
slideMode = input.string("Auto-Rotate", "Slide Mode", options = ["Auto-Rotate", "Manual"], group = gDash)
slidePick = input.string("Overview", "Manual Slide", options = ["Overview", "Top Zones", "Statistics", "Pressure", "Scenario"], group = gDash)
rotSecs   = input.int(6, "Auto-Rotate Every (seconds)", minval = 2, maxval = 60, group = gDash, tooltip = "Rotation advances on live ticks; on a closed market the panel holds one slide.")
dashPosS  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gDash)
dashSizeS = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)

gAlert = "═══ Alerts ═══"
proxAtr = input.float(0.35, "Approach Distance (ATR)", minval = 0.05, step = 0.05, group = gAlert)

var color D_BG   = #0b0e15
var color D_HDR  = #151a26
var color D_ROW  = #101521
var color D_ALT  = #0d121c
var color D_EDGE = #2a3446
var color D_GOLD = #e8b339
var color D_TXT  = #e6ecf5
var color D_DIM  = #7f8b9e
var color D_TEAL = #22d3a6
var color D_MAG  = #e957d6

f_tsize(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_dpos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        => position.top_right

f_stars(float sc) => sc >= 8.0 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5.0 ? "★★" : sc >= 3.0 ? "★" : "·"
f_tier(float sc)  => sc >= 8.0 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5.0 ? "MODERATE" : sc >= 3.0 ? "WEAK" : "FORMING"

f_meter(float pct, int cells) =>
    int fill = math.round(math.min(math.max(pct, 0.0), 100.0) / 100.0 * cells)
    string s = ""
    for i = 1 to cells
        s := s + (i <= fill ? "█" : "░")
    s

f_tug(float leftShare, int cells) =>
    int l = math.round(math.min(math.max(leftShare, 0.0), 1.0) * cells)
    string s = ""
    for i = 1 to cells
        s := s + (i <= l ? "◀" : "▶")
    s

f_pctStr(float v) => str.tostring(v, "#.0") + "%"

f_ageF(int age) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(age / math.max(decayBars, 1), 1.0), decayFloor)

float atrv    = nz(ta.atr(atrLen), high - low)
float volBase = nz(ta.sma(volume, volLen), 0.0)
int   legLen  = leftBars + rightBars

float rng  = high - low
float dvol = rng > 0 ? volume * (close - open) / rng : 0.0

float legVolAbs = math.sum(volume, legLen)
float legVolDir = math.sum(dvol,   legLen)
float gapVolAbs = math.sum(volume, 2)
float gapVolDir = math.sum(dvol,   2)

float ema50  = ta.ema(close, 50)
float ema200 = ta.ema(close, 200)
string regime = ema50 > ema200 and close > ema50 ? "BULL TREND" : ema50 < ema200 and close < ema50 ? "BEAR TREND" : "ROTATION"
color  regCol = regime == "BULL TREND" ? D_TEAL : regime == "BEAR TREND" ? D_MAG : D_GOLD

bool inWindow = lookback == 0 or (last_bar_index - bar_index) <= lookback
bool sessOK   = not rthOnly or session.ismarket

type magnet
    box   bx      = na
    box   cx      = na
    label tag     = na
    line  ln      = na
    int   kind    = 0
    int   dir     = 0
    float top     = na
    float bot     = na
    float top0    = na
    float bot0    = na
    int   bornBar = 0
    int   lastBar = 0
    int   tests   = 0
    float volAbs  = 0.0
    float volDir  = 0.0
    int   conf    = 1
    int   phase   = 0
    float score   = 0.0
    float pen     = 0.0
    bool  inside  = false
    bool  alive   = true

type pending
    int   dir  = 0
    float px   = 0.0
    float atr0 = 0.0
    int   bar  = 0

var array<magnet>  mags  = array.new<magnet>()
var array<pending> pends = array.new<pending>()

var int   gapTot = 0, var int gapFilled = 0, var int gapBarsSum = 0
var int   poolTot = 0, var int poolSwept = 0, var int poolBarsSum = 0
var int   partialTot = 0
var int   reactTot = 0, var int reactHit = 0

f_kill(magnet m) =>
    box.delete(m.bx)
    box.delete(m.cx)
    label.delete(m.tag)
    line.delete(m.ln)

f_prune() =>
    while array.size(mags) > maxMagnets
        int victim = 0
        bool found = false
        for i = 0 to array.size(mags) - 1
            if array.get(mags, i).phase == 2
                victim := i
                found  := true
                break
        if not found
            victim := 0
        f_kill(array.get(mags, victim))
        array.remove(mags, victim)

f_ov(float t1, float b1, float t2, float b2) =>
    float ov   = math.min(t1, t2) - math.max(b1, b2)
    float minH = math.min(t1 - b1, t2 - b2)
    ov > 0 and minH > 0 ? ov / minH : 0.0

f_score(magnet m, int n, float px) =>
    float h     = m.top0 - m.bot0
    float sizeF = atrv > 0 ? math.min(h / (atrv * sizeNorm), 1.0) : 0.0
    float vBase = volBase * legLen
    float volF  = vBase > 0 ? math.min(math.abs(m.volAbs) / (vBase * volNorm), 1.0) : 0.0
    float testF = math.min(m.tests / math.max(testNorm, 1.0), 1.0)
    float confF = math.min((m.conf - 1) / math.max(confNorm, 1.0), 1.0)
    float dist  = math.abs(math.avg(m.top0, m.bot0) - px)
    float proxF = atrv > 0 ? math.max(1.0 - dist / (atrv * proxNorm), 0.0) : 0.0
    float wSum  = wVol + wSize + wTest + wConf + wProx
    float raw   = wSum > 0 ? (volF * wVol + sizeF * wSize + testF * wTest + confF * wConf + proxF * wProx) / wSum : 0.0
    math.min(math.max(raw * 10.0 * f_ageF(n - m.lastBar), 0.0), 10.0)

f_zoneCol(magnet m) => m.dir > 0 ? sellCol : buyCol

f_tagTxt(magnet m, float px) =>
    string k    = m.kind == 0 ? "IMBALANCE" : "STOP POOL"
    string arw  = m.dir > 0 ? "▲" : "▼"
    string cf   = m.conf > 1 ? " ×" + str.tostring(m.conf) : ""
    float  dPct = px > 0 ? math.abs(math.avg(m.top0, m.bot0) - px) / px * 100.0 : 0.0
    string st   = m.phase == 2 ? (m.kind == 0 ? "FILLED" : "SWEPT")
                 : m.phase == 1 ? "CONSUMED " + str.tostring(m.pen * 100.0, "#") + "%"
                 : str.tostring(dPct, "#.00") + "% away"
    k + " " + arw + cf + "   " + f_stars(m.score) + " " + str.tostring(m.score, "#.0") + "/10  ·  " + st

f_draw(magnet m, int n, float px) =>
    color  c    = f_zoneCol(m)
    int    tr   = m.phase == 2 ? doneTr : zoneTr
    bool   vis  = m.score >= minScore or m.phase == 2
    int    lEdge= math.max(m.bornBar, n - DRAW_MAX)
    int    rEdge= m.phase == 2 ? math.max(m.lastBar, lEdge) : n + extRight

    box.set_lefttop(m.bx, lEdge, m.top)
    box.set_rightbottom(m.bx, rEdge, m.bot)
    box.set_bgcolor(m.bx, vis ? color.new(c, tr) : na)
    box.set_border_color(m.bx, vis and m.phase != 2 ? color.new(c, 40) : na)

    if not na(m.cx)
        float ct = m.dir > 0 ? m.bot : m.top0
        float cb = m.dir > 0 ? m.bot0 : m.top
        bool  shade = m.phase == 1 and vis and ct > cb
        box.set_lefttop(m.cx, lEdge, math.max(ct, cb))
        box.set_rightbottom(m.cx, rEdge, math.min(ct, cb))
        box.set_bgcolor(m.cx, shade ? color.new(c, math.min(tr + 8, 98)) : na)
        box.set_border_color(m.cx, na)

    if showTags and not na(m.tag)
        label.set_xy(m.tag, rEdge, math.avg(m.top0, m.bot0))
        label.set_text(m.tag, vis ? f_tagTxt(m, px) : "")
        label.set_textcolor(m.tag, vis ? (m.phase == 2 ? color.new(c, 45) : c) : na)
        label.set_color(m.tag, na)
        label.set_size(m.tag, f_tsize(tagSizeS))

    if showMid and not na(m.ln)
        bool elite = vis and m.phase != 2 and m.score >= eliteThr
        line.set_xy1(m.ln, lEdge, math.avg(m.top0, m.bot0))
        line.set_xy2(m.ln, rEdge, math.avg(m.top0, m.bot0))
        line.set_color(m.ln, elite ? color.new(c, 25) : na)

f_spawn(int kind, int dir, float top, float bot, int bBar, float vAbs, float vDir) =>
    bool merged = false
    if mergeOn and array.size(mags) > 0
        for i = array.size(mags) - 1 to 0
            magnet e = array.get(mags, i)
            if e.phase != 2 and e.dir == dir and f_ov(e.top0, e.bot0, top, bot) >= overlapThr / 100.0
                e.top0   := math.max(e.top0, top)
                e.bot0   := math.min(e.bot0, bot)
                e.top    := math.max(e.top, top)
                e.bot    := math.min(e.bot, bot)
                e.volAbs += vAbs
                e.volDir += vDir
                e.conf   += 1
                e.lastBar := bBar
                merged := true
                break
    if not merged
        magnet m = magnet.new()
        m.kind    := kind
        m.dir     := dir
        m.top     := top
        m.bot     := bot
        m.top0    := top
        m.bot0    := bot
        m.bornBar := bBar
        m.lastBar := bBar
        m.volAbs  := vAbs
        m.volDir  := vDir
        m.bx      := box.new(bBar, top, bBar, bot, border_width = 1, border_style = kind == 0 ? line.style_dashed : line.style_solid, bgcolor = na, border_color = na)
        m.cx      := box.new(bBar, top, bBar, bot, border_width = 0, bgcolor = na, border_color = na)
        m.tag     := showTags ? label.new(bBar, math.avg(top, bot), "", style = label.style_label_left, color = na, textcolor = na, size = f_tsize(tagSizeS)) : na
        m.ln      := showMid ? line.new(bBar, math.avg(top, bot), bBar, math.avg(top, bot), color = na, style = line.style_dotted, width = 1) : na
        array.push(mags, m)
        f_prune()
    merged

int n = bar_index

bool rawGapUp = bar_index > 2 and low[1]  > high[2]
bool rawGapDn = bar_index > 2 and high[1] < low[2]
float gapSize = rawGapUp ? low[1] - high[2] : rawGapDn ? low[2] - high[1] : 0.0
bool  gapBig  = gapSize > 0 and gapSize >= atrv * minGapAtr and (close[1] > 0 ? gapSize / close[1] * 100.0 >= minGapPct : false)
bool  newGapU = useGaps and inWindow and sessOK and rawGapUp and gapBig
bool  newGapD = useGaps and inWindow and sessOK and rawGapDn and gapBig

float ph = ta.pivothigh(high, leftBars, rightBars)
float pl = ta.pivotlow(low,  leftBars, rightBars)
bool  newPoolU = usePools and inWindow and not na(ph)
bool  newPoolD = usePools and inWindow and not na(pl)

bool spawnedGap  = false
bool spawnedPool = false

if barstate.isconfirmed
    if newGapU
        f_spawn(0, -1, low[1], high[2], n - 1, gapVolAbs, gapVolDir)
        gapTot += 1
        spawnedGap := true
    if newGapD
        f_spawn(0, 1, low[2], high[1], n - 1, gapVolAbs, gapVolDir)
        gapTot += 1
        spawnedGap := true
    if newPoolU
        float base = ph + atrv * poolBuf
        f_spawn(1, 1, base + atrv * poolH, base, n - rightBars, legVolAbs, legVolDir)
        poolTot += 1
        spawnedPool := true
    if newPoolD
        float base = pl - atrv * poolBuf
        f_spawn(1, -1, base, base - atrv * poolH, n - rightBars, legVolAbs, legVolDir)
        poolTot += 1
        spawnedPool := true

bool evFill  = false
bool evSweep = false
bool evTest  = false
bool evElite = false

if barstate.isconfirmed and array.size(mags) > 0
    for i = array.size(mags) - 1 to 0
        magnet m = array.get(mags, i)
        if n - m.bornBar > DRAW_MAX
            m.alive := false
        if m.phase != 2 and m.alive
            float h = m.top0 - m.bot0
            bool touching = m.dir > 0 ? high >= m.bot0 : low <= m.top0
            if touching
                float p = 1.0
                if h > 0
                    p := m.dir > 0 ? math.min((high - m.bot0) / h, 1.0) : math.min((m.top0 - low) / h, 1.0)
                if p > m.pen
                    m.pen := p
                    if m.dir > 0
                        m.bot := math.min(m.bot0 + p * h, m.top0)
                    else
                        m.top := math.max(m.top0 - p * h, m.bot0)
                if not m.inside
                    m.tests    += 1
                    partialTot += 1
                    evTest     := true
                m.inside  := true
                m.lastBar := n
                m.phase   := (m.dir > 0 ? high >= m.top0 : low <= m.bot0) ? 2 : 1
            else
                m.inside := false

            if m.phase == 2
                m.lastBar := n
                int life = n - m.bornBar
                if m.kind == 0
                    gapFilled  += 1
                    gapBarsSum += life
                    evFill := true
                else
                    poolSwept   += 1
                    poolBarsSum += life
                    evSweep := true
                array.push(pends, pending.new(m.dir, close, atrv, n))
                if not keepDone
                    m.alive := false

            if staleDev >= 0 and m.phase != 2
                float mid = math.avg(m.top0, m.bot0)
                if mid > 0 and math.abs(close - mid) / mid * 100.0 > staleDev
                    m.alive := false

            m.score := f_score(m, n, close)
            if m.score >= eliteThr and m.phase != 2 and atrv > 0
                float d = m.dir > 0 ? m.bot0 - high : low - m.top0
                if d <= atrv * proxAtr and d >= 0
                    evElite := true

        if not m.alive
            f_kill(m)
            array.remove(mags, i)

if barstate.isconfirmed and array.size(pends) > 0
    for i = array.size(pends) - 1 to 0
        pending p = array.get(pends, i)
        bool done = false
        if p.dir > 0 and close <= p.px - p.atr0 * reactMult
            reactHit += 1
            reactTot += 1
            done := true
        else if p.dir < 0 and close >= p.px + p.atr0 * reactMult
            reactHit += 1
            reactTot += 1
            done := true
        else if n - p.bar >= reactBars
            reactTot += 1
            done := true
        if done
            array.remove(pends, i)

float massUp = 0.0, float massDn = 0.0
int   cntUp  = 0,   int   cntDn  = 0
float nearUp = na,  float nearDn = na
float nearUpS = 0.0, float nearDnS = 0.0
int   eliteN = 0

if array.size(mags) > 0
    for i = 0 to array.size(mags) - 1
        magnet m = array.get(mags, i)
        if m.phase != 2 and m.score >= minScore
            float mid = math.avg(m.top0, m.bot0)
            float w   = m.score * (1.0 + math.log(1.0 + math.abs(m.volAbs) / math.max(volBase * legLen, 1.0)))
            if m.score >= eliteThr
                eliteN += 1
            if m.dir > 0
                massUp += w
                cntUp  += 1
                if na(nearUp) or mid < nearUp
                    nearUp  := mid
                    nearUpS := m.score
            else
                massDn += w
                cntDn  += 1
                if na(nearDn) or mid > nearDn
                    nearDn  := mid
                    nearDnS := m.score

float massTot  = massUp + massDn
float shareUp  = massTot > 0 ? massUp / massTot : 0.5
float pullBias = (shareUp - 0.5) * 200.0
string pullTxt = math.abs(pullBias) < 8 ? "BALANCED" : pullBias > 0 ? "▲ UPSIDE PULL" : "▼ DOWNSIDE PULL"
color  pullCol = math.abs(pullBias) < 8 ? D_GOLD : pullBias > 0 ? D_MAG : D_TEAL

var line railU = na
var line railD = na
if showRail and barstate.islast
    if na(railU)
        railU := line.new(n, close, n, close, extend = extend.right, color = na, style = line.style_dashed, width = 1)
        railD := line.new(n, close, n, close, extend = extend.right, color = na, style = line.style_dashed, width = 1)
    line.set_xy1(railU, n - 1, nz(nearUp, close))
    line.set_xy2(railU, n, nz(nearUp, close))
    line.set_color(railU, na(nearUp) ? na : color.new(sellCol, 55))
    line.set_xy1(railD, n - 1, nz(nearDn, close))
    line.set_xy2(railD, n, nz(nearDn, close))
    line.set_color(railD, na(nearDn) ? na : color.new(buyCol, 55))

if array.size(mags) > 0
    for i = 0 to array.size(mags) - 1
        f_draw(array.get(mags, i), n, close)

f_pick(float lvl, int side, bool byScore) =>
    float best = na
    float bsc  = 0.0
    if array.size(mags) > 0
        for i = 0 to array.size(mags) - 1
            magnet m = array.get(mags, i)
            if m.phase != 2 and m.score >= scenMinSc
                float mid = math.avg(m.top0, m.bot0)
                bool ok = side > 0 ? mid > lvl : mid < lvl
                if ok
                    bool better = na(best) or (byScore ? m.score > bsc : (side > 0 ? mid < best : mid > best))
                    if better
                        best := mid
                        bsc  := m.score
    [best, bsc]

f_snap(float lvl) =>
    float best = na
    float bsc  = 0.0
    float tol  = atrv * snapAtr
    if tol > 0 and array.size(mags) > 0
        for i = 0 to array.size(mags) - 1
            magnet m = array.get(mags, i)
            if m.phase != 2 and m.score >= scenMinSc
                float mid = math.avg(m.top0, m.bot0)
                if math.abs(mid - lvl) <= tol and (na(best) or math.abs(mid - lvl) < math.abs(best - lvl))
                    best := mid
                    bsc  := m.score
    [best, bsc]

var array<polyline> scPolys = array.new<polyline>()
var array<label>    scLabs  = array.new<label>()
var array<line>     scRails = array.new<line>()

float scTrig = na, float scRev = na, float scRet = na, float scTgt = na, float scExt = na
float scTrigS = 0.0, float scTgtS = 0.0
int   scDir = 0
bool  scAnchored = false
bool  scSnapped  = false
float scConf = 0.0
int   scLegs = 0

if barstate.islast
    for p in scPolys
        polyline.delete(p)
    array.clear(scPolys)
    for l in scLabs
        label.delete(l)
    array.clear(scLabs)
    for r in scRails
        line.delete(r)
    array.clear(scRails)

if scenOn and barstate.islast
    scDir := scenDir == "Up First" ? 1 : scenDir == "Down First" ? -1 : (pullBias >= 0 ? 1 : -1)

    [t1, t1s] = f_pick(close, scDir, false)
    scTrig  := t1
    scTrigS := t1s

    if not na(scTrig)
        [tg, tgs] = f_pick(close, -scDir, true)
        scAnchored := not na(tg)
        scTgt := scAnchored ? tg : close - scDir * math.abs(scTrig - close)
        scTgtS := nz(tgs)

        float legTrig = math.abs(scTrig - close)
        float revRaw  = scTrig - scDir * legTrig * (revPct / 100.0)
        [snapPx, snapSc] = f_snap(revRaw)
        scSnapped := not na(snapPx)
        scRev := scSnapped ? snapPx : revRaw

        scRet := scRev + scDir * math.abs(scTrig - scRev) * (retestPct / 100.0)

        if scenShape == "Extended"
            [ex, exs] = f_pick(scTgt, -scDir, false)
            scExt := ex

        array<float>  ys = array.from(close, scTrig)
        array<string> nm = array.from("", "TRIGGER")
        if scenShape != "Simple"
            array.push(ys, scRev)
            array.push(nm, scSnapped ? "REVERSE ⚑" : "REVERSE")
            array.push(ys, scRet)
            array.push(nm, "RETEST")
        array.push(ys, scTgt)
        array.push(nm, scAnchored ? "TARGET" : "TARGET (projected)")
        if scenShape == "Extended" and not na(scExt)
            array.push(ys, scExt)
            array.push(nm, "EXTENSION")

        scLegs := array.size(ys) - 1

        float sumD = 0.0
        for k = 1 to scLegs
            sumD += math.abs(array.get(ys, k) - array.get(ys, k - 1))

        array<chart.point> pts = array.new<chart.point>()
        array<int> xs = array.new<int>()
        int x = n
        array.push(pts, chart.point.from_index(x, close))
        array.push(xs, x)
        for k = 1 to scLegs
            float d = math.abs(array.get(ys, k) - array.get(ys, k - 1))
            int   b = math.max(4, sumD > 0 ? math.round(projBars * d / sumD) : 6)
            x := math.min(x + b, n + 480)
            array.push(pts, chart.point.from_index(x, array.get(ys, k)))
            array.push(xs, x)

        if scenGlow
            array.push(scPolys, polyline.new(pts, line_color = color.new(scenCol, 88), line_width = 7, xloc = xloc.bar_index))
            array.push(scPolys, polyline.new(pts, line_color = color.new(scenCol, 75), line_width = 4, xloc = xloc.bar_index))
        array.push(scPolys, polyline.new(pts, line_color = scenCol, line_width = 2, xloc = xloc.bar_index))

        for k = 1 to scLegs
            int   px = array.get(xs, k)
            float py = array.get(ys, k)
            bool  last = k == scLegs
            bool  solid = k == 1 ? true : (last ? scAnchored : scSnapped)
            color wc = solid ? scenCol : color.new(scenCol, 45)

            array.push(scLabs, label.new(px, py, "", style = label.style_diamond, color = wc, size = size.tiny))
            if last
                bool dnLeg = py < array.get(ys, k - 1)
                array.push(scLabs, label.new(px, py, "", style = dnLeg ? label.style_arrowdown : label.style_arrowup, color = wc, size = size.small))
            if scenLabs_
                float dPct = close > 0 ? (py - close) / close * 100.0 : 0.0
                string txt = array.get(nm, k) + "  " + str.tostring(py, format.mintick) + "   (" + (dPct >= 0 ? "+" : "") + str.tostring(dPct, "#.00") + "%)"
                array.push(scLabs, label.new(px, py, txt, style = label.style_label_left, color = #00000000, textcolor = wc, size = size.small))

        if scenRails
            array.push(scRails, line.new(n, scTrig, array.get(xs, scLegs), scTrig, color = color.new(scenCol, 60), style = line.style_dotted, width = 1))
            array.push(scRails, line.new(n, scTgt,  array.get(xs, scLegs), scTgt,  color = color.new(scenCol, 60), style = line.style_dotted, width = 1))

        float baseC = (scTrigS + (scAnchored ? scTgtS : 0.0)) / 2.0 * 10.0
        scConf := math.min(baseC * (scAnchored ? 1.0 : 0.55) * (scSnapped ? 1.0 : 0.85), 100.0)

bool scHit = scenOn and not na(scTrig) and barstate.isconfirmed and (scDir > 0 ? high >= scTrig : low <= scTrig)

f_row(table t, int r, string k, string v, color vc, color bg, string ts) =>
    table.cell(t, 0, r, k, text_color = D_DIM, bgcolor = bg, text_size = ts, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc,    bgcolor = bg, text_size = ts, text_halign = text.align_right)

var table dash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_dpos(dashPosS), 2, 13, bgcolor = D_BG, border_color = D_EDGE, border_width = 1, frame_color = D_GOLD, frame_width = 1)
    table.clear(dash, 0, 0, 1, 12)

    string ts = dashSizeS == "Tiny" ? size.tiny : dashSizeS == "Normal" ? size.normal : size.small
    int nSlides = scenOn ? 5 : 4
    int slide = slideMode == "Manual"
                 ? (slidePick == "Overview" ? 0 : slidePick == "Top Zones" ? 1 : slidePick == "Statistics" ? 2 : slidePick == "Pressure" ? 3 : 4)
                 : int(math.floor(timenow / (rotSecs * 1000)) % nSlides)
    if slide == 4 and not scenOn
        slide := 0

    string sName = slide == 0 ? "OVERVIEW" : slide == 1 ? "TOP ZONES" : slide == 2 ? "STATISTICS" : slide == 3 ? "PRESSURE" : "SCENARIO"
    string pips  = ""
    for i = 0 to nSlides - 1
        pips := pips + (i == slide ? "●" : "○")

    table.cell(dash, 0, 0, "STRONG LIQUIDITY OUTLOOK", text_color = D_GOLD, bgcolor = D_HDR, text_size = ts, text_halign = text.align_left)
    table.cell(dash, 1, 0, pips, text_color = D_GOLD, bgcolor = D_HDR, text_size = ts, text_halign = text.align_right)
    table.cell(dash, 0, 1, sName, text_color = D_TXT, bgcolor = D_HDR, text_size = ts, text_halign = text.align_left)
    table.cell(dash, 1, 1, syminfo.ticker + " · " + timeframe.period, text_color = D_DIM, bgcolor = D_HDR, text_size = ts, text_halign = text.align_right)

    if slide == 0
        float dUp = na(nearUp) ? na : (nearUp - close) / close * 100.0
        float dDn = na(nearDn) ? na : (close - nearDn) / close * 100.0
        f_row(dash, 2,  "Regime",          regime, regCol, D_ROW, ts)
        f_row(dash, 3,  "Live Zones",    str.tostring(cntUp + cntDn) + "  (" + str.tostring(cntUp) + "▲ / " + str.tostring(cntDn) + "▼)", D_TXT, D_ALT, ts)
        f_row(dash, 4,  "Elite (≥" + str.tostring(eliteThr, "#.#") + ")", str.tostring(eliteN), eliteN > 0 ? D_GOLD : D_DIM, D_ROW, ts)
        f_row(dash, 5,  "Net Pull",        pullTxt, pullCol, D_ALT, ts)
        f_row(dash, 6,  "Pull Meter",      f_tug(1.0 - shareUp, 10), pullCol, D_ROW, ts)
        f_row(dash, 7,  "Nearest Above",   na(nearUp) ? "—" : str.tostring(nearUp, format.mintick) + "  " + f_pctStr(dUp), na(nearUp) ? D_DIM : D_MAG, D_ALT, ts)
        f_row(dash, 8,  "  ↳ Strength",    na(nearUp) ? "—" : f_meter(nearUpS * 10, 6) + " " + str.tostring(nearUpS, "#.0"), D_MAG, D_ROW, ts)
        f_row(dash, 9,  "Nearest Below",   na(nearDn) ? "—" : str.tostring(nearDn, format.mintick) + "  " + f_pctStr(dDn), na(nearDn) ? D_DIM : D_TEAL, D_ALT, ts)
        f_row(dash, 10, "  ↳ Strength",    na(nearDn) ? "—" : f_meter(nearDnS * 10, 6) + " " + str.tostring(nearDnS, "#.0"), D_TEAL, D_ROW, ts)
        f_row(dash, 11, "ATR(" + str.tostring(atrLen) + ")", str.tostring(atrv, format.mintick), D_TXT, D_ALT, ts)
        f_row(dash, 12, "Resolved",        str.tostring(gapFilled + poolSwept) + " of " + str.tostring(gapTot + poolTot), D_DIM, D_ROW, ts)

    if slide == 1
        table.cell(dash, 0, 2, "RANKED BY SCORE", text_color = D_DIM, bgcolor = D_ROW, text_size = ts, text_halign = text.align_left)
        table.cell(dash, 1, 2, "PRICE · SCORE", text_color = D_DIM, bgcolor = D_ROW, text_size = ts, text_halign = text.align_right)

        array<float> pool = array.new<float>()
        array<int>   idx  = array.new<int>()
        if array.size(mags) > 0
            for i = 0 to array.size(mags) - 1
                magnet m = array.get(mags, i)
                if m.phase != 2 and m.score >= minScore
                    array.push(pool, m.score)
                    array.push(idx, i)

        int shown = 0
        for k = 0 to 7
            if shown >= 8 or array.size(pool) == 0
                break
            int best = 0
            for j = 0 to array.size(pool) - 1
                if array.get(pool, j) > array.get(pool, best)
                    best := j
            if array.get(pool, best) < 0.0
                break
            magnet m = array.get(mags, array.get(idx, best))
            color  c = f_zoneCol(m)
            string ic = (m.kind == 0 ? "◧ GAP " : "▤ POOL ") + (m.dir > 0 ? "▲" : "▼") + (m.conf > 1 ? " ×" + str.tostring(m.conf) : "")
            float  mid = math.avg(m.top0, m.bot0)
            string rhs = str.tostring(mid, format.mintick) + "  " + f_meter(m.score * 10, 5) + " " + str.tostring(m.score, "#.0")
            table.cell(dash, 0, 3 + shown, ic, text_color = c, bgcolor = shown % 2 == 0 ? D_ALT : D_ROW, text_size = ts, text_halign = text.align_left)
            table.cell(dash, 1, 3 + shown, rhs, text_color = D_TXT, bgcolor = shown % 2 == 0 ? D_ALT : D_ROW, text_size = ts, text_halign = text.align_right)
            array.set(pool, best, -1.0)
            shown += 1
        if shown == 0
            table.cell(dash, 0, 3, "No live zones", text_color = D_DIM, bgcolor = D_ALT, text_size = ts, text_halign = text.align_left)
            table.cell(dash, 1, 3, "—", text_color = D_DIM, bgcolor = D_ALT, text_size = ts, text_halign = text.align_right)

    if slide == 2
        float fillRate  = gapTot  > 0 ? 100.0 * gapFilled / gapTot : 0.0
        float sweepRate = poolTot > 0 ? 100.0 * poolSwept / poolTot : 0.0
        float avgFill   = gapFilled > 0 ? gapBarsSum / float(gapFilled) : 0.0
        float avgSweep  = poolSwept > 0 ? poolBarsSum / float(poolSwept) : 0.0
        float reactRate = reactTot > 0 ? 100.0 * reactHit / reactTot : 0.0
        bool  thin      = (gapTot + poolTot) < 20

        f_row(dash, 2,  "Gap Fill Rate",   f_pctStr(fillRate) + "  (" + str.tostring(gapFilled) + "/" + str.tostring(gapTot) + ")", fillRate >= 50 ? D_TEAL : D_GOLD, D_ROW, ts)
        f_row(dash, 3,  "  ↳ Meter",       f_meter(fillRate, 10), D_TEAL, D_ALT, ts)
        f_row(dash, 4,  "Avg Bars To Fill", gapFilled > 0 ? str.tostring(avgFill, "#") : "—", D_TXT, D_ROW, ts)
        f_row(dash, 5,  "Pool Sweep Rate", f_pctStr(sweepRate) + "  (" + str.tostring(poolSwept) + "/" + str.tostring(poolTot) + ")", sweepRate >= 50 ? D_MAG : D_GOLD, D_ALT, ts)
        f_row(dash, 6,  "  ↳ Meter",       f_meter(sweepRate, 10), D_MAG, D_ROW, ts)
        f_row(dash, 7,  "Avg Bars To Sweep", poolSwept > 0 ? str.tostring(avgSweep, "#") : "—", D_TXT, D_ALT, ts)
        f_row(dash, 8,  "Reaction Rate",   reactTot > 0 ? f_pctStr(reactRate) + "  (" + str.tostring(reactHit) + "/" + str.tostring(reactTot) + ")" : "—", reactRate >= 50 ? D_TEAL : D_GOLD, D_ROW, ts)
        f_row(dash, 9,  "  ↳ Meter",       f_meter(reactRate, 10), D_GOLD, D_ALT, ts)
        f_row(dash, 10, "Reaction Test",   str.tostring(reactMult, "#.#") + "×ATR in " + str.tostring(reactBars) + "b", D_DIM, D_ROW, ts)
        f_row(dash, 11, "Zone Tests Logged", str.tostring(partialTot), D_TXT, D_ALT, ts)
        f_row(dash, 12, "Sample",          thin ? "THIN — read with care" : "OK  (" + str.tostring(gapTot + poolTot) + " zones)", thin ? D_MAG : D_DIM, D_ROW, ts)

    if slide == 3
        float dirUp = 0.0, float dirDn = 0.0, float volU = 0.0, float volD = 0.0
        int   part  = 0
        if array.size(mags) > 0
            for i = 0 to array.size(mags) - 1
                magnet m = array.get(mags, i)
                if m.phase == 1
                    part += 1
                if m.phase != 2
                    if m.dir > 0
                        volU  += math.abs(m.volAbs)
                        dirUp += m.volDir
                    else
                        volD  += math.abs(m.volAbs)
                        dirDn += m.volDir
        float volTot = volU + volD
        float volShareUp = volTot > 0 ? volU / volTot * 100.0 : 0.0

        f_row(dash, 2,  "Zone Mass ▲",  str.tostring(massUp, "#.0"), D_MAG, D_ROW, ts)
        f_row(dash, 3,  "Zone Mass ▼",  str.tostring(massDn, "#.0"), D_TEAL, D_ALT, ts)
        f_row(dash, 4,  "Tug Of War",     f_tug(1.0 - shareUp, 12), pullCol, D_ROW, ts)
        f_row(dash, 5,  "Pull Bias",      str.tostring(math.abs(pullBias), "#") + "% " + (pullBias > 0 ? "up" : "down"), pullCol, D_ALT, ts)
        f_row(dash, 6,  "Est. Volume ▲",  str.tostring(volU, format.volume), D_MAG, D_ROW, ts)
        f_row(dash, 7,  "Est. Volume ▼",  str.tostring(volD, format.volume), D_TEAL, D_ALT, ts)
        f_row(dash, 8,  "Volume Split",   f_meter(volShareUp, 10) + " " + str.tostring(volShareUp, "#") + "%▲", D_TXT, D_ROW, ts)
        f_row(dash, 9,  "Net Δ Above",    str.tostring(dirUp, format.volume), dirUp >= 0 ? D_TEAL : D_MAG, D_ALT, ts)
        f_row(dash, 10, "Net Δ Below",    str.tostring(dirDn, format.volume), dirDn >= 0 ? D_TEAL : D_MAG, D_ROW, ts)
        f_row(dash, 11, "Partially Eaten", str.tostring(part) + " zone" + (part == 1 ? "" : "s"), part > 0 ? D_GOLD : D_DIM, D_ALT, ts)
        f_row(dash, 12, "Δ Note",         "geometry estimate, not ticks", D_DIM, D_ROW, ts)

    if slide == 4
        if na(scTrig)
            f_row(dash, 2, "Status", "No live zone in trigger direction", D_DIM, D_ROW, ts)
            f_row(dash, 3, "Hint",   "lower Min Waypoint Score", D_DIM, D_ALT, ts)
        else
            float mv    = close > 0 ? math.abs(scTgt - close) / close * 100.0 : 0.0
            float mvAtr = atrv > 0 ? math.abs(scTgt - scTrig) / atrv : 0.0
            float risk  = atrv * 0.5
            float rr    = risk > 0 ? math.abs(scTrig - scTgt) / risk : 0.0
            color dirC  = scDir > 0 ? D_MAG : D_TEAL
            color cnfC  = scConf >= 60 ? D_TEAL : scConf >= 35 ? D_GOLD : D_MAG

            f_row(dash, 2,  "Trigger Dir",  scDir > 0 ? "▲ RUN HIGHS FIRST" : "▼ RUN LOWS FIRST", dirC, D_ROW, ts)
            f_row(dash, 3,  "1 · Trigger",  str.tostring(scTrig, format.mintick) + "  " + f_meter(scTrigS * 10, 4), dirC, D_ALT, ts)
            f_row(dash, 4,  "2 · Reverse",  scenShape == "Simple" ? "—" : str.tostring(scRev, format.mintick) + (scSnapped ? "  ⚑ snapped" : "  retrace"), scSnapped ? D_GOLD : D_DIM, D_ROW, ts)
            f_row(dash, 5,  "3 · Retest",   scenShape == "Simple" ? "—" : str.tostring(scRet, format.mintick), D_DIM, D_ALT, ts)
            f_row(dash, 6,  "4 · Target",   str.tostring(scTgt, format.mintick) + "  " + (scAnchored ? f_meter(scTgtS * 10, 4) : "projected"), scAnchored ? (scDir > 0 ? D_TEAL : D_MAG) : D_DIM, D_ROW, ts)
            f_row(dash, 7,  "5 · Extension", na(scExt) ? "—" : str.tostring(scExt, format.mintick), na(scExt) ? D_DIM : D_TXT, D_ALT, ts)
            f_row(dash, 8,  "Move To Target", f_pctStr(mv) + "  ·  " + str.tostring(mvAtr, "#.0") + "×ATR", D_TXT, D_ROW, ts)
            f_row(dash, 9,  "Trigger→Target", str.tostring(rr, "#.0") + "R  (½ATR risk)", rr >= 2 ? D_TEAL : D_GOLD, D_ALT, ts)
            f_row(dash, 10, "Path Confidence", f_meter(scConf, 10) + " " + str.tostring(scConf, "#") + "%", cnfC, D_ROW, ts)
            f_row(dash, 11, "Anchoring",    (scAnchored ? "target on zone" : "target projected") + " · " + str.tostring(scLegs) + " legs", scAnchored ? D_DIM : D_MAG, D_ALT, ts)
            f_row(dash, 12, "Note",         "level geometry, not a forecast", D_DIM, D_ROW, ts)

alertcondition(scHit, "Scenario Trigger Reached", "Strong Liquidity Outlook: price reached the scenario trigger level")
alertcondition(spawnedGap,  "New Imbalance Zone", "Strong Liquidity Outlook: a new imbalance zone formed")
alertcondition(spawnedPool, "New Stop-Pool Zone", "Strong Liquidity Outlook: a new stop-pool zone formed")
alertcondition(evTest,      "Zone Tested",        "Strong Liquidity Outlook: price has tapped a draw zone")
alertcondition(evFill,      "Imbalance Filled",     "Strong Liquidity Outlook: an imbalance zone was fully filled")
alertcondition(evSweep,     "Stop Pool Swept",      "Strong Liquidity Outlook: a stop-pool zone was swept")
alertcondition(evElite,     "Elite Zone Approach","Strong Liquidity Outlook: price is approaching an elite zone")

if evFill
    alert("Strong Liquidity Outlook: imbalance filled at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if evSweep
    alert("Strong Liquidity Outlook: stop pool swept at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if evElite
    alert("Strong Liquidity Outlook: elite zone approach at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
