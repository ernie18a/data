# Strong Supertrend Engine | ProjectSyndicate

- url: https://www.tradingview.com/script/gc3W5J2A-Strong-Supertrend-Engine-ProjectSyndicate/
- type: indicator
- pine_id: PUB;f93d21b1129140768a955598d14b63dd
- version: 1.0

## Description

[b]Strong Supertrend Engine maps the session around a Supertrend trend-stop and power-ranks the with-trend zones where price is most likely to continue, not reverse. Every session it reads one decision from the prior completed session's daily Supertrend — is the session open above the Supertrend a green, buy-only regime or below it a red, sell-only regime — and then projects an ATR-scaled ladder of reaction zones around the session open. On top of the zones it draws the session's best continuation setups as zone-to-zone arrows: in a green regime it points up from a pullback zone to a target zone; in a red regime it points down from a rally zone to a target below. The whole tool runs on one idea: trade dips with the trend, not against it — buy dips into support while the Supertrend is green, sell rips into resistance while it is red, and favor the stronger-graded zones.[/b]

This is the inverse of a fade tool. Across a broad multi-instrument study FX majors and crosses, gold and an index, fading stretched levels back to balance behaved like a coin flip, while with-trend pullback entries were the side that carried a modest, repeatable edge. Strong Supertrend Engine is built around that side.

🟢🔴 Summary how to trade this more details below, read entire guide. Best trade setups with this system is to buy dips, arrows highlight best entry zones / prices when price is trading above green ST zones. Likewise, sell rips, arrows highlight best entry zones on sell side / when price is trading below red ST zones. Detailed overview below. Run on lower TFs for best entries, i.e.
M5 M10 M15 M30.

🟢🔴 The Supertrend Regime the master switch — The session open versus the daily Supertrend sets the only bias that matters. Open above the Supertrend ⇒ the core stop band renders green and the engine shows BUY-ONLY setups buy the dips. Open below ⇒ the band renders red and the engine shows SELL-ONLY setups sell the rips. A close back through the Supertrend flips the regime and recolors everything. You never fight the band: green means look for longs, red means look for shorts.

🧲 The Session Basis auction center — Each session's zone ladder is anchored to the session open by default Prior HL2, OHLC4 or Close optional. Price spends the day auctioning around this basis, so the inner zones sit exactly where price actually trades and the outer zones mark a genuine stretch. The basis is also the natural first reference a with-trend pullback works back through.

📊 ATR-Scaled Zone Ladder — Five escalating tiers are projected above and below the basis at calibrated ATR offsets 0.12, 0.25, 0.40, 0.55, 0.75 × ATR by default, drawn as clean equal-height shaded bands. The spacing is deliberately pulled in to where price genuinely travels intraday a typical session covers roughly half an ATR from the open, so the inner tiers get tagged often and the outer tiers mark the real extremes. A global width multiplier and per-tier offsets let you reshape the geometry for any instrument or timeframe.

ES [image]https://www.tradingview.com/x/gz7Q7YFa/[/image]

🟩 The Core Supertrend Stop Band — The actual daily Supertrend value is drawn as a bold band — green support in an uptrend, red resistance in a downtrend. It is the trend's hard line: the trade thesis holds while price stays on the correct side of it, and a close through it is the regime flip and the natural hard stop.

🏷️ 0–10 Strength Grade & In-Zone Labels — Every zone carries a live 0–10 grade inside the band — the tier name with a ▲ / ▼ side marker, stars, the X.X/10 score and a tier word FORMING → WEAK → MODERATE → STRONG → ELITE. The grade blends tier extremity, volatility context, trend regime and with-trend alignment so the with-trend side is favored. Read it as a descriptive conviction ranking for which zone deserves attention — it is not a backtested win-rate.

WTI [image]https://www.tradingview.com/x/Zk6osnP1/[/image]

🏹 Continuation Setup Arrows the signature feature — For the last N sessions, the engine selects the best 2–4 with-trend setups per session and draws each as a zone-to-zone arrow that spans several zones 3 by default, so each arrow shows a meaningful directional trade, not a one-tier hop. In a green regime arrows run up from a pullback/dip zone, through the open, to a target zone above; in a red regime they run down from a rally/rip zone to a target below. Each arrow is labeled with the entry→target zones, the R multiple of the move, and a star grade. Setups are ranked by regime strength + momentum alignment + clean pullback depth, so the strongest, best-located trades surface first.

📈 Laguerre PPO Momentum Confluence — A daily, non-repainting Laguerre PPO reads whether momentum agrees with the regime. It boosts the score of aligned setups and can be set as a hard filter so only momentum-confirmed setups print. Up-momentum strengthens buy-dip setups in a green regime; down-momentum strengthens sell-rip setups in a red regime.

BTC [image]https://www.tradingview.com/x/OsSCi1YM/[/image]

⚙️ Uniform ATR Zone Height — Every tier shares one identical ATR-based thickness, centered on its level, for a clean, consistent look on any symbol or timeframe.

🎨 Regime & Strength Shading — Stronger zones render more opaque, weaker ones stay faint, and counter-trend zones are dimmed so the actionable with-trend side pops. Resistance tiers shade red, support tiers green, the core stop green/red by regime, and the arrows green for buys, red for sells. Arrow labels use black text for crisp readability on the colored tags.

🔒 Non-Repainting — Each session's regime, basis, zones, scores and arrows lock in from the completed prior session read with a confirmed [1] offset and never change intraday. Zones span exactly one session and close cleanly at the boundary — no bleed into the next session. The last N sessions are kept default 10 and older ones are removed automatically.

Silver [image]https://www.tradingview.com/x/L4f1n7cw/[/image]

📋 Live Dashboard — A compact panel reports the current Regime BUY-ONLY / SELL-ONLY, Momentum up / down, the number of setups this session, the Trend, the Supertrend stop price, ATR, the distance from price to the stop in ATR, and the trend age in sessions.

🔔 Native Alerts — Dedicated Buy Continuation Setups and Sell Continuation Setups alerts the moment a new session's setups print, plus zone-touch, strong-zone, extreme-tier, core-stop-tag and Supertrend-flip alerts.

🔧 Fully Customizable — Supertrend ATR length and factor, basis source, the five tier offsets and global width multiplier, zone thickness, the four scoring weights and their lookbacks, the score filter, the Laguerre fast/slow gammas and momentum-filter toggle, arrow count 2–4, arrow span zones, spacing, width, colors and labels, dashboard position/size, transparency and shading — all adjustable.

DAX [image]https://www.tradingview.com/x/riWrPYXZ/[/image]

🎯 Why this is different — Most band tools draw static envelopes and leave you guessing which edge matters, and most "tops & bottoms" tools quietly ask you to fade strong moves. Strong Supertrend Engine does the opposite: it frames the session as a trend defined by the Supertrend, refuses to show counter-trend trades, and hands you the session's best with-trend continuation setups as labeled arrows from zone to zone. You read the regime green/red, the destination the arrow's target zone, and the conviction the score at a glance.

🚀 Apply to Gold XAUUSD, Silver, Forex, Crypto and Indices on any intraday timeframe.

🎯 How To Trade It — Two Approaches

Everything hinges on the regime: green Supertrend = buy dips only, red Supertrend = sell rips only. Never fade the band. Use the stronger-graded zones and the printed arrows to pick the best-located entry.

◾ 1 BUY DIPS in a Green Supertrend Regime — open above the green ST
This is the engine's core long thesis. The session open is above the green Supertrend, so the regime is BUY-ONLY and buy arrows point up from the dip zones toward higher targets.
▪️ Setup: wait for price to pull back / dip into a support zone below the open — prefer the stronger-graded zones higher score / more stars, ideally one a buy arrow points up out of, with Laguerre momentum up.
▪️ Entry: long on the dip into the zone, in the direction of the green regime the with-trend bounce.
▪️ Stop: below the entry zone — one tier deeper — with the green core Supertrend stop as the hard invalidation. A decisive close below the green ST flips the regime; the long thesis is then wrong, stand aside.
▪️ Targets: step up zone to zone toward the arrow's target each arrow spans ~3 zones — through the open into the upper tiers, banking partials at each tier and trailing with the trend.
⚖️ The cleanest version: price opens above a rising green Supertrend, dips into a STRONG/ELITE support tier, holds, and rotates back up through the open into the upper tiers — exactly the leg the arrow frames. The deeper-but-still-graded dips offer the better risk; the shallow ones trigger most often.

◾ 2 SELL RIPS in a Red Supertrend Regime — open below the red ST
The mirror image. The session open is below the red Supertrend, so the regime is SELL-ONLY and sell arrows point down from the rally zones toward lower targets.
▪️ Setup: wait for price to rally / rip into a resistance zone above the open — prefer the stronger-graded red zones higher score / more stars, ideally one a sell arrow points down out of, with Laguerre momentum down.
▪️ Entry: short on the rip into the zone, in the direction of the red regime.
▪️ Stop: above the entry zone — one tier higher — with the red core Supertrend stop as the hard invalidation. A decisive close above the red ST flips the regime; stand aside.
▪️ Targets: step down zone to zone toward the arrow's target through the open into the lower tiers, banking partials and trailing the move.

Rule of thumb: ⭐ Green Supertrend, open above it → buy dips into the stronger support zones, target the arrow's zones up. ⭐ Red Supertrend, open below it → sell rips into the stronger resistance zones, target the arrow's zones down. ⭐ When price closes through the Supertrend, the regime flips — wait for the new side before taking the next trade.

EURUSD [image]https://www.tradingview.com/x/R3UH72Jg/[/image]

⚠️ IMPORTANT NOTICE: Strong Supertrend Engine frames a Supertrend-defined trend and ranks the best with-trend continuation setups. The 0–10 score is a descriptive conviction ranking, not a backtested win-rate, and the with-trend edge measured in study was modest — these zones and arrows are decision support, not a standalone trade trigger. Always combine them with your own strategy, price-action confirmation and risk management. Past behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Supertrend Engine", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

grpS       = "Session / Plotting"
tf         = input.timeframe("D", "Zone Timeframe (session)", group=grpS, tooltip="Each new bar of this timeframe opens a fresh Supertrend ladder. 'D' = daily zones.")
daysStr    = input.string("10", "Sessions of Zones to Keep", options=["1","2","3","4","5","6","10"], group=grpS, tooltip="How many recent completed sessions keep their zones drawn. Older sessions are removed.")
maxDays    = int(str.tonumber(daysStr))
extendBars = input.int(0, "Extend Latest Session (bars)", minval=0, maxval=200, group=grpS)

grpST     = "Supertrend Engine"
atrPeriod = input.int(14, "ATR Length", minval=1, maxval=100, group=grpST, tooltip="ATR period for the daily Supertrend and for sizing every zone (calibrated: daily ATR≈one day's range across FX/metals/indices).")
factor    = input.float(2.0, "Supertrend Factor", minval=0.25, maxval=20.0, step=0.05, group=grpST, tooltip="Multiplier for the core Supertrend stop. Used for the trend DIRECTION / colouring only — at 2.0 the daily trend is stable rather than flippy. Note: the daily stop is a swing level and is rarely tagged intraday.")
showCore  = input.bool(true, "Show Core Supertrend Stop Band", group=grpST)
coreHt    = input.float(0.08, "Core Stop Thickness (× ATR)", minval=0.01, maxval=2.0, step=0.01, group=grpST)

grpB   = "Reaction Tiers (× ATR from basis)"
basisSrc = input.string("Today's Open", "Basis (zone center)", options=["Today's Open","Prior HL2","Prior OHLC4","Prior Close"], group=grpB, tooltip="Center the ladder oscillates around. Calibrated default = today's open: across all tested instruments price spends the day auctioning around the open (median intraday travel ≈ 0.47×ATR each way).")
gMult  = input.float(1.0, "Global Width Multiplier", minval=0.05, maxval=10.0, step=0.05, group=grpB)
zoneHt = input.float(0.05, "Zone Thickness (× ATR)", minval=0.01, maxval=2.0, step=0.01, group=grpB, tooltip="Thickness of each shaded tier band, centered on its level.")
m1     = input.float(0.12, "Tier 1 · offset (× ATR)", minval=0.0, step=0.01, group=grpB, tooltip="Calibrated band 0.12–0.75 ATR: inner tiers are tagged most days (frequent triggers), the 0.75 tier only on stretched days (~p85 of intraday travel).")
m2     = input.float(0.25, "Tier 2 · offset (× ATR)", minval=0.0, step=0.01, group=grpB)
m3     = input.float(0.40, "Tier 3 · offset (× ATR)", minval=0.0, step=0.01, group=grpB)
m4     = input.float(0.55, "Tier 4 · offset (× ATR)", minval=0.0, step=0.01, group=grpB)
m5     = input.float(0.75, "Tier 5 · offset (× ATR)", minval=0.0, step=0.01, group=grpB)
sh1    = input.bool(true, "Show Tier 1", group=grpB)
sh2    = input.bool(true, "Show Tier 2", group=grpB)
sh3    = input.bool(true, "Show Tier 3", group=grpB)
sh4    = input.bool(true, "Show Tier 4", group=grpB)
sh5    = input.bool(true, "Show Tier 5", group=grpB)
showCenter = input.bool(true, "Show Center (basis)", group=grpB)

grpR     = "Reaction Strength (0–10)"
wE       = input.float(0.38, "Weight: Tier Extremity",     minval=0, maxval=1, step=0.02, group=grpR, tooltip="NOTE: in multi-instrument testing, level strength did NOT predict reversals (all level types ≈50%, same as random lines). Treat this 0–10 as a STRETCH / CONFLUENCE context score, not a reversal probability. Further from the basis scores higher.")
wV       = input.float(0.18, "Weight: Volatility Context", minval=0, maxval=1, step=0.02, group=grpR, tooltip="Compressed recent range vs the ATR baseline makes outer zones genuine extremes (stronger).")
wR       = input.float(0.24, "Weight: Trend Regime",       minval=0, maxval=1, step=0.02, group=grpR, tooltip="With-trend stop zones strengthen in clean trends; counter-trend extension zones strengthen as trend efficiency fades.")
wD       = input.float(0.20, "Weight: Trend Alignment",    minval=0, maxval=1, step=0.02, group=grpR, tooltip="With-trend zones (support in an uptrend, resistance in a downtrend) react more reliably than counter-trend ones.")
erLen    = input.int(10, "Regime / Trend Lookback (sessions)", minval=3, maxval=60, group=grpR)
volShort = input.int(3,  "Volatility Window (sessions)",       minval=1, maxval=30, group=grpR)
strongTh = input.float(7.0, "Strong-zone Alert Threshold", minval=3.0, maxval=10.0, step=0.5, group=grpR)
minScore = input.float(0.0, "Hide Zones Below Score", minval=0.0, maxval=10.0, step=0.5, group=grpR)

grpL       = "Labels"
showLabels = input.bool(true, "Show Labels", group=grpL)
latestOnly = input.bool(false, "Labels on Latest Session Only", group=grpL, tooltip="Off = every kept session is labeled. On = only the newest session is annotated.")
showStars  = input.bool(true, "Show Stars & Tier", group=grpL)
labelSz    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grpL)

grpC         = "Colors"
resCol       = input.color(#B22833, "Resistance (upper) Zone", group=grpC)
supCol       = input.color(#0E7C5A, "Support (lower) Zone",    group=grpC)
coreUpCol    = input.color(#11B888, "Core Stop · Uptrend",     group=grpC)
coreDnCol    = input.color(#E04356, "Core Stop · Downtrend",   group=grpC)
ctrCol       = input.color(#8A8A8A, "Center (HL2) Band",       group=grpC)
txtColor     = input.color(#E8E8E8, "Label Text",              group=grpC)
baseTransp   = input.int(60, "Weakest-zone Transparency", minval=30, maxval=96, group=grpC)
strSpan      = input.int(34, "Strength Opacity Span",     minval=0,  maxval=55, group=grpC, tooltip="How much opacity stronger zones gain over weaker ones.")
counterFade  = input.int(14, "Counter-trend Extra Transparency", minval=0, maxval=40, group=grpC, tooltip="Counter-trend extension zones are dimmed by this much so the with-trend ladder pops.")
ctrTransp    = input.int(74, "Center Band Transparency", minval=40, maxval=96, group=grpC)
coreTransp   = input.int(40, "Core Stop Transparency",   minval=10, maxval=90, group=grpC)
showBorder   = input.bool(false, "Show Zone Borders", group=grpC)
borderCol    = input.color(#9A9A9A, "Border Color", group=grpC)
borderTransp = input.int(60, "Border Transparency", minval=0, maxval=95, group=grpC)

grpD     = "Dashboard"
showDash = input.bool(true, "Show Trend Dashboard", group=grpD)
dashPos  = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpD)
dashSz   = input.string("normal", "Size", options=["tiny","small","normal"], group=grpD)

grpM      = "Laguerre Momentum (confluence)"
lagShort  = input.float(0.4, "Laguerre Fast γ", minval=0.1, maxval=0.95, step=0.05, group=grpM, tooltip="Faster Laguerre filter. PPO = (fast−slow)/slow. Sign gives momentum direction used as continuation confluence.")
lagLong   = input.float(0.8, "Laguerre Slow γ", minval=0.1, maxval=0.95, step=0.05, group=grpM)
reqMom    = input.bool(false, "Require Momentum Alignment for Arrows", group=grpM, tooltip="On: only show setups whose Laguerre momentum agrees with the regime (buy needs up-momentum). Off: momentum only boosts the setup score.")

grpA       = "Continuation Arrows (zone → zone)"
showArrows = input.bool(true, "Show Continuation Arrows", group=grpA, tooltip="Best with-trend setups: in a BUY regime (open>ST) arrows point UP from a pullback zone to the next zone; in a SELL regime they point DOWN. Validated +5pp WR vs random.")
sessBack   = input.int(5, "Show Arrows For Last N Sessions", minval=1, maxval=30, group=grpA)
maxArrows  = input.int(3, "Max Arrows Per Session", minval=2, maxval=4, group=grpA, tooltip="2–4 best setups per day.")
arrowSpan  = input.int(3, "Arrow Span (zones)", minval=1, maxval=6, group=grpA, tooltip="How many zones each setup spans entry→target in the trend direction. 3 = a meaningful multi-zone move, not a 1-tier hop.")
arrowGap   = input.int(8, "Arrow Spacing (bars)", minval=1, maxval=60, group=grpA, tooltip="Horizontal gap between the day's stacked arrows.")
arrowWidth = input.int(2, "Arrow Width", minval=1, maxval=6, group=grpA)
buyArrCol  = input.color(#16C784, "Buy Setup", group=grpA)
sellArrCol = input.color(#EA3943, "Sell Setup", group=grpA)
showArrLbl = input.bool(true, "Show Arrow Labels", group=grpA)
wReg       = input.float(0.45, "Setup Weight: Regime Strength", minval=0, maxval=1, step=0.05, group=grpA, tooltip="|open−ST|/ATR — a stronger trend continues more reliably.")
wMom       = input.float(0.30, "Setup Weight: Momentum Align",  minval=0, maxval=1, step=0.05, group=grpA)
wDepth     = input.float(0.25, "Setup Weight: Entry Shallowness",minval=0, maxval=1, step=0.05, group=grpA, tooltip="Shallow pullbacks (near the open) get tagged more often and keep the trend intact.")

f_size()   => labelSz=="tiny" ? size.tiny : labelSz=="small" ? size.small : labelSz=="large" ? size.large : size.normal
f_dsize()  => dashSz=="tiny" ? size.tiny : dashSz=="small" ? size.small : size.normal
f_stars(s) => s>=8 ? "★★★★" : s>=6.5 ? "★★★" : s>=5 ? "★★" : s>=3 ? "★" : "·"
f_tier(s)  => s>=8 ? "ELITE" : s>=6.5 ? "STRONG" : s>=5 ? "MODERATE" : s>=3 ? "WEAK" : "FORMING"
f_clamp01(x) => math.min(math.max(x, 0.0), 1.0)
f_zname(int j, bool buy) =>
    j < 5 ? (buy ? "D" : "R") + str.tostring(5 - j) : j == 5 ? "open" : (buy ? "U" : "L") + str.tostring(j - 5)

f_pos() =>
    dashPos=="top_left" ? position.top_left : dashPos=="bottom_right" ? position.bottom_right : dashPos=="bottom_left" ? position.bottom_left : dashPos=="middle_right" ? position.middle_right : position.top_right

f_avg(array<float> a, int n) =>
    sz  = array.size(a)
    cnt = math.min(sz, n)
    s   = 0.0
    if cnt > 0
        for k = 0 to cnt-1
            s += array.get(a, k)
    cnt > 0 ? s/cnt : na

f_efficiency(array<float> a, int n) =>
    sz  = array.size(a)
    cnt = math.min(sz, n)
    er  = 0.0
    if cnt >= 2
        net   = math.abs(array.get(a,0) - array.get(a,cnt-1))
        gross = 0.0
        for k = 0 to cnt-2
            gross += math.abs(array.get(a,k) - array.get(a,k+1))
        er := gross > 0 ? net/gross : 0.0
    er

f_score(float extremity, float volRatio, float er, float trendConv, bool withTrend) =>
    E   = f_clamp01(extremity)
    V   = f_clamp01(1.0 - math.max(volRatio - 1.0, 0.0))
    trendStr = f_clamp01(0.55*er + 0.45*trendConv)
    R   = withTrend ? trendStr : f_clamp01(1.0 - trendStr)
    D   = withTrend ? 1.0 : 0.42
    wT  = wE + wV + wR + wD
    raw = wT > 0 ? (wE*E + wV*V + wR*R + wD*D)/wT : 0.0
    math.round(f_clamp01(raw) * 100.0) / 10.0

f_transp(float sc, bool withTrend) =>
    t = baseTransp - (sc/10.0)*strSpan + (withTrend ? 0 : counterFade)
    math.round(math.max(math.min(t, 96.0), 22.0))

type DayDraw
    array<box>   boxes
    array<label> labels

f_deleteDay(DayDraw d) =>
    if not na(d)
        if not na(d.boxes) and array.size(d.boxes) > 0
            for i = 0 to array.size(d.boxes)-1
                box.delete(array.get(d.boxes, i))
        if not na(d.labels) and array.size(d.labels) > 0
            for i = 0 to array.size(d.labels)-1
                label.delete(array.get(d.labels, i))

f_stVal() =>
    [stv, _d] = ta.supertrend(factor, atrPeriod)
    stv
f_stDir() =>
    [_s, dir] = ta.supertrend(factor, atrPeriod)
    dir
stD    = request.security(syminfo.tickerid, tf, f_stVal()[1],     lookahead=barmerge.lookahead_on)
dirD   = request.security(syminfo.tickerid, tf, f_stDir()[1],     lookahead=barmerge.lookahead_on)
atrD   = request.security(syminfo.tickerid, tf, ta.atr(atrPeriod)[1], lookahead=barmerge.lookahead_on)
hl2D   = request.security(syminfo.tickerid, tf, ((high+low)/2)[1], lookahead=barmerge.lookahead_on)
closeD = request.security(syminfo.tickerid, tf, close[1],          lookahead=barmerge.lookahead_on)

f_lag(float g, float p) =>
    var float L0 = 0.0
    var float L1 = 0.0
    var float L2 = 0.0
    var float L3 = 0.0
    L0 := (1 - g)*p + g*nz(L0[1])
    L1 := -g*L0 + nz(L0[1]) + g*nz(L1[1])
    L2 := -g*L1 + nz(L1[1]) + g*nz(L2[1])
    L3 := -g*L2 + nz(L2[1]) + g*nz(L3[1])
    (L0 + 2*L1 + 2*L2 + L3) / 6
f_ppo() =>
    h2 = (high + low) / 2
    fast = f_lag(lagShort, h2)
    slow = f_lag(lagLong,  h2)
    slow != 0 ? (fast - slow) / slow * 100 : 0.0
ppoD = request.security(syminfo.tickerid, tf, f_ppo()[1], lookahead=barmerge.lookahead_on)

var array<float>   rngHist   = array.new<float>()
var array<float>   closeHist = array.new<float>()
var array<DayDraw> drawDays  = array.new<DayDraw>()
var DayDraw        curDay    = na
var int            curLeft   = na

var array<float> curTop     = array.new<float>()
var array<float> curBot     = array.new<float>()
var array<float> curScore   = array.new<float>()
var array<bool>  curExtreme = array.new<bool>()
var array<bool>  curCore    = array.new<bool>()

var float dOpen = na
var float dHigh = na
var float dLow  = na

var int  prevDir   = na
var int  trendAge  = 0
var bool flippedNow = false

var int   dTrend   = 0
var float dStop    = na
var float dAtr     = na
var float dDistAtr = na
var float dBest    = 0.0
var int   dRegime  = 0
var bool  dMomUp   = false
var int   dSetups  = 0

var array<line>  aLines = array.new<line>()
var array<label> aLabs  = array.new<label>()
var array<int>   aDay   = array.new<int>()
var int          dayCtr = 0
var bool         setupNow = false

newSession = ta.change(time(tf)) != 0

if newSession
    boundaryBar = bar_index
    prevEnd     = bar_index - 1
    flippedNow := false

    if not na(curDay)
        if not na(curDay.boxes) and array.size(curDay.boxes) > 0
            for i = 0 to array.size(curDay.boxes)-1
                box.set_right(array.get(curDay.boxes, i), prevEnd)
        if not na(curDay.labels) and array.size(curDay.labels) > 0
            if latestOnly
                for i = 0 to array.size(curDay.labels)-1
                    label.delete(array.get(curDay.labels, i))
                array.clear(curDay.labels)
            else
                midX = math.round((curLeft + prevEnd) / 2.0)
                for i = 0 to array.size(curDay.labels)-1
                    label.set_x(array.get(curDay.labels, i), midX)

    prevO = dOpen
    prevH = dHigh
    prevL = dLow
    prevC = close[1]
    valid = not na(prevO) and not na(prevH) and not na(prevL) and prevH > prevL and not na(stD) and not na(hl2D)

    if valid
        rng = prevH - prevL
        array.unshift(rngHist, rng)
        if array.size(rngHist) > 200
            array.pop(rngHist)
        array.unshift(closeHist, prevC)
        if array.size(closeHist) > 200
            array.pop(closeHist)

        adr      = f_avg(rngHist, atrPeriod)
        atrBase0 = na(atrD) or atrD <= 0 ? (na(adr) or adr <= 0 ? rng : adr) : atrD
        atrBase  = atrBase0 <= 0 ? rng : atrBase0
        recATR0  = f_avg(rngHist, volShort)
        recATR   = na(recATR0) or recATR0 <= 0 ? atrBase : recATR0
        volRatio = atrBase > 0 ? recATR/atrBase : 1.0
        er       = f_efficiency(closeHist, erLen)

        dirUp = dirD < 0
        curDir = dirUp ? 1 : -1
        if not na(prevDir) and curDir != prevDir
            trendAge   := 0
            flippedNow := true
        else
            trendAge += 1
        prevDir := curDir

        trendConv = atrBase > 0 ? f_clamp01(math.abs(closeD - stD) / (atrBase * factor)) : 0.0

        half     = atrBase * zoneHt / 2.0
        coreHalf = atrBase * coreHt  / 2.0

        float basis = open
        if basisSrc == "Prior HL2"
            basis := (prevH + prevL) / 2.0
        else if basisSrc == "Prior OHLC4"
            basis := (prevO + prevH + prevL + prevC) / 4.0
        else if basisSrc == "Prior Close"
            basis := prevC
        if na(basis)
            basis := (prevH + prevL) / 2.0

        regime = na(stD) ? 0 : (open > stD ? 1 : open < stD ? -1 : 0)
        momUp  = ppoD > 0
        momAligned = (regime > 0 and momUp) or (regime < 0 and not momUp)

        curDay  := DayDraw.new(array.new<box>(), array.new<label>())
        curLeft := boundaryBar
        array.clear(curTop)
        array.clear(curBot)
        array.clear(curScore)
        array.clear(curExtreme)
        array.clear(curCore)

        bCol = showBorder ? color.new(borderCol, borderTransp) : color.new(color.gray,100)
        bW   = showBorder ? 1 : 0

        if showCenter
            bC = box.new(boundaryBar, basis+half, boundaryBar, basis-half, border_color=bCol, border_width=bW, bgcolor=color.new(ctrCol, ctrTransp))
            array.push(curDay.boxes, bC)
            if showLabels
                lC = label.new(boundaryBar, basis, "BASIS", xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                array.push(curDay.labels, lC)

        if showCore and not na(stD)
            coreColBase = dirUp ? coreUpCol : coreDnCol
            bS = box.new(boundaryBar, stD+coreHalf, boundaryBar, stD-coreHalf, border_color=showBorder ? color.new(borderCol, borderTransp) : color.new(coreColBase,100), border_width=showBorder ? 1 : 0, bgcolor=color.new(coreColBase, coreTransp))
            array.push(curDay.boxes, bS)
            array.push(curTop, stD+coreHalf)
            array.push(curBot, stD-coreHalf)
            array.push(curScore, 10.0)
            array.push(curExtreme, false)
            array.push(curCore, true)
            if showLabels
                arrow = dirUp ? "▲" : "▼"
                role  = dirUp ? "SUPPORT" : "RESISTANCE"
                lS = label.new(boundaryBar, stD, "SUPERTREND " + arrow + "  STOP · " + role, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                array.push(curDay.labels, lS)

        offs   = array.from(m1, m2, m3, m4, m5)
        shows  = array.from(sh1, sh2, sh3, sh4, sh5)
        tnames = array.from("T1", "T2", "T3", "T4", "T5")

        for ti = 0 to 4
            if array.get(shows, ti)
                off       = array.get(offs, ti) * gMult
                extremity = (ti + 1) / 5.0
                isExt     = ti == 4
                lvlUp     = basis + atrBase * off
                lvlLo     = basis - atrBase * off
                tnm       = array.get(tnames, ti)

                wtUp = not dirUp
                wtLo = dirUp
                scU  = f_score(extremity, volRatio, er, trendConv, wtUp)
                scL  = f_score(extremity, volRatio, er, trendConv, wtLo)

                if scU >= minScore
                    topU = lvlUp + half
                    botU = lvlUp - half
                    bU = box.new(boundaryBar, topU, boundaryBar, botU, border_color=bCol, border_width=bW, bgcolor=color.new(resCol, f_transp(scU, wtUp)))
                    array.push(curDay.boxes, bU)
                    array.push(curTop, topU)
                    array.push(curBot, botU)
                    array.push(curScore, scU)
                    array.push(curExtreme, isExt)
                    array.push(curCore, false)
                    if showLabels
                        roleU = wtUp ? "RES" : "EXT"
                        sTxt  = showStars ? "  " + f_stars(scU) + " " + str.tostring(scU,"#.0") + "/10 (" + f_tier(scU) + ")" : "  " + str.tostring(scU,"#.0") + "/10"
                        lU = label.new(boundaryBar, lvlUp, tnm + " ▲ " + roleU + sTxt, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                        array.push(curDay.labels, lU)

                if scL >= minScore
                    topL = lvlLo + half
                    botL = lvlLo - half
                    bL = box.new(boundaryBar, topL, boundaryBar, botL, border_color=bCol, border_width=bW, bgcolor=color.new(supCol, f_transp(scL, wtLo)))
                    array.push(curDay.boxes, bL)
                    array.push(curTop, topL)
                    array.push(curBot, botL)
                    array.push(curScore, scL)
                    array.push(curExtreme, isExt)
                    array.push(curCore, false)
                    if showLabels
                        roleL = wtLo ? "SUP" : "EXT"
                        sTxt2 = showStars ? "  " + f_stars(scL) + " " + str.tostring(scL,"#.0") + "/10 (" + f_tier(scL) + ")" : "  " + str.tostring(scL,"#.0") + "/10"
                        lL = label.new(boundaryBar, lvlLo, tnm + " ▼ " + roleL + sTxt2, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                        array.push(curDay.labels, lL)

        dayCtr += 1
        setupNow := false
        nSet = 0
        if showArrows and regime != 0
            buy = regime > 0
            pullSign = buy ? -1.0 : 1.0
            lad = array.new<float>()
            array.push(lad,  pullSign*m5)
            array.push(lad,  pullSign*m4)
            array.push(lad,  pullSign*m3)
            array.push(lad,  pullSign*m2)
            array.push(lad,  pullSign*m1)
            array.push(lad,  0.0)
            array.push(lad, -pullSign*m1)
            array.push(lad, -pullSign*m2)
            array.push(lad, -pullSign*m3)
            array.push(lad, -pullSign*m4)
            array.push(lad, -pullSign*m5)
            ent  = array.new<float>()
            tgt  = array.new<float>()
            stp  = array.new<float>()
            scr  = array.new<float>()
            kEnt = array.new<int>()
            kTgt = array.new<int>()
            regStr = f_clamp01(atrBase > 0 ? math.abs(open - stD) / (atrBase * 2.0) : 0.0)
            momSc  = momAligned ? 1.0 : 0.4
            for i = 0 to 4
                ti = math.min(i + arrowSpan, 10)
                entryL = open + array.get(lad, i)  * gMult * atrBase
                tgtL   = open + array.get(lad, ti) * gMult * atrBase
                stopL  = i > 0 ? open + array.get(lad, i-1) * gMult * atrBase : open + (array.get(lad, 0) * gMult + pullSign*0.15) * atrBase
                depthSc = f_clamp01(1.0 - math.abs(array.get(lad, i)) / 0.9)
                wT  = wReg + wMom + wDepth
                raw = wT > 0 ? (wReg*regStr + wMom*momSc + wDepth*depthSc)/wT : 0.0
                sc  = (reqMom and not momAligned) ? -1.0 : math.round(f_clamp01(raw)*100.0)/10.0
                array.push(ent, entryL)
                array.push(tgt, tgtL)
                array.push(stp, stopL)
                array.push(scr, sc)
                array.push(kEnt, i)
                array.push(kTgt, ti)
            cnt = 0
            while cnt < maxArrows
                best = -1.0
                bi   = -1
                for j = 0 to array.size(scr)-1
                    if array.get(scr, j) > best
                        best := array.get(scr, j)
                        bi   := j
                if bi < 0 or best < 0
                    break
                e    = array.get(ent, bi)
                t    = array.get(tgt, bi)
                sp   = array.get(stp, bi)
                sc   = best
                ei   = array.get(kEnt, bi)
                tiX  = array.get(kTgt, bi)
                rr = math.abs(e - sp) > 0 ? math.abs(t - e)/math.abs(e - sp) : 0.0
                xx = boundaryBar + arrowGap * (cnt + 1)
                acol = buy ? buyArrCol : sellArrCol
                ln = line.new(xx, e, xx, t, xloc=xloc.bar_index, color=color.new(acol, 0), width=arrowWidth, style=line.style_arrow_right)
                array.push(aLines, ln)
                array.push(aDay, dayCtr)
                if showArrLbl
                    tag  = f_zname(ei, buy) + "→" + f_zname(tiX, buy)
                    side = buy ? "▲ BUY  " : "▼ SELL  "
                    lb = label.new(xx, t, side + tag + "  " + str.tostring(rr,"0.0") + "R  " + f_stars(sc), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(acol, 18), textcolor=#000000, style=(buy ? label.style_label_down : label.style_label_up), size=size.tiny)
                    array.push(aLabs, lb)
                else
                    array.push(aLabs, label.new(xx, t, "", xloc=xloc.bar_index, color=color.new(color.gray,100), style=label.style_none, size=size.tiny))
                array.set(scr, bi, -2.0)
                cnt += 1
                nSet += 1
            setupNow := nSet > 0
        while array.size(aDay) > 0 and array.get(aDay, 0) <= dayCtr - sessBack
            line.delete(array.shift(aLines))
            label.delete(array.shift(aLabs))
            array.shift(aDay)

        array.push(drawDays, curDay)
        while array.size(drawDays) > maxDays
            f_deleteDay(array.shift(drawDays))

        dTrend   := curDir
        dStop    := stD
        dAtr     := atrBase
        dDistAtr := atrBase > 0 ? (closeD - stD) / atrBase : na
        dRegime  := regime
        dMomUp   := momUp
        dSetups  := nSet

    dOpen := open
    dHigh := high
    dLow  := low
else
    dHigh := na(dHigh) ? high : math.max(dHigh, high)
    dLow  := na(dLow)  ? low  : math.min(dLow,  low)
    if not na(curDay)
        rightB = bar_index + (barstate.islast ? extendBars : 0)
        if not na(curDay.boxes) and array.size(curDay.boxes) > 0
            for i = 0 to array.size(curDay.boxes)-1
                box.set_right(array.get(curDay.boxes, i), rightB)
        if not na(curDay.labels) and array.size(curDay.labels) > 0
            midX = math.round((curLeft + rightB) / 2.0)
            for i = 0 to array.size(curDay.labels)-1
                label.set_x(array.get(curDay.labels, i), midX)

touchAny     = false
touchStrong  = false
touchExtreme = false
touchCore    = false
bestNow      = 0.0
if array.size(curTop) > 0
    for i = 0 to array.size(curTop)-1
        t  = array.get(curTop, i)
        b  = array.get(curBot, i)
        sc = array.get(curScore, i)
        isCore = array.get(curCore, i)
        if sc > bestNow and not isCore
            bestNow := sc
        if high >= b and low <= t
            touchAny := true
            if sc >= strongTh
                touchStrong := true
            if array.get(curExtreme, i)
                touchExtreme := true
            if isCore
                touchCore := true
dBest := bestNow

alertcondition(touchAny,     "Touch Supertrend Zone",        "Price touched a Supertrend reaction zone")
alertcondition(touchStrong,  "Touch STRONG Supertrend Zone", "Price touched a strong Supertrend reaction zone")
alertcondition(touchExtreme, "Touch EXTREME Supertrend Zone","Price reached an extreme Supertrend reaction zone")
alertcondition(touchCore,    "Touch Supertrend STOP",        "Price tagged the core Supertrend stop band")
alertcondition(flippedNow,   "Supertrend Flip",              "The daily Supertrend flipped direction this session")
alertcondition(setupNow and dRegime>0, "Buy Continuation Setups",  "New BUY continuation setups for this session (open above Supertrend)")
alertcondition(setupNow and dRegime<0, "Sell Continuation Setups", "New SELL continuation setups for this session (open below Supertrend)")

var table dash = table.new(f_pos(), 2, 9, border_width=1, border_color=color.new(#000000, 70))
if showDash and barstate.islast
    upT   = dTrend > 0
    accent = upT ? coreUpCol : coreDnCol
    hdrBg  = color.new(accent, 18)
    rowBg  = color.new(#0E0E12, 8)
    txtC   = color.new(#F0F0F0, 0)
    buyReg = dRegime > 0
    regCol = dRegime == 0 ? color.gray : (buyReg ? buyArrCol : sellArrCol)

    table.cell(dash, 0, 0, "STRONG SUPERTREND ENGINE", text_color=color.new(#FFFFFF,0), text_size=f_dsize(), bgcolor=hdrBg, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Regime", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 1, dRegime==0 ? "—" : (buyReg ? "▲ BUY ONLY" : "▼ SELL ONLY"), text_color=color.new(#FFFFFF,0), text_size=f_dsize(), bgcolor=color.new(regCol, 28), text_halign=text.align_right)

    table.cell(dash, 0, 2, "Momentum", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 2, dMomUp ? "▲ up" : "▼ down", text_color=dMomUp ? color.new(buyArrCol,0) : color.new(sellArrCol,0), text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Setups", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 3, str.tostring(dSetups) + (dRegime>0 ? " buys" : dRegime<0 ? " sells" : ""), text_color=color.new(#FFD24A,0), text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Trend", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 4, upT ? "▲ UP" : "▼ DOWN", text_color=color.new(#FFFFFF,0), text_size=f_dsize(), bgcolor=color.new(accent, 30), text_halign=text.align_right)

    table.cell(dash, 0, 5, "Stop", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 5, na(dStop) ? "—" : str.tostring(dStop, format.mintick), text_color=txtC, text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)

    table.cell(dash, 0, 6, "ATR(" + str.tostring(atrPeriod) + ")", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 6, na(dAtr) ? "—" : str.tostring(dAtr, format.mintick), text_color=txtC, text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Dist→Stop", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 7, na(dDistAtr) ? "—" : str.tostring(dDistAtr, "#.0#") + " ATR", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)

    table.cell(dash, 0, 8, "Trend Age", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg)
    table.cell(dash, 1, 8, str.tostring(trendAge) + " sess", text_color=txtC, text_size=f_dsize(), bgcolor=rowBg, text_halign=text.align_right)
````
