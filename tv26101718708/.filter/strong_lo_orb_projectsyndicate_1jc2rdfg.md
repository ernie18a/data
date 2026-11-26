# Strong LO ORB | ProjectSyndicate

- url: https://www.tradingview.com/script/1JC2rdFg-Strong-LO-ORB-ProjectSyndicate/
- type: indicator
- pine_id: PUB;ece5fbcde43c4903a14b11d22ab95a65
- version: 1.0

## Description

Strong LO ORB — London Opening Range Breakout catches the moment the London session resolves its opening range — and instead of treating every push past a line as a trade, it waits for a genuine close beyond the range, tags the direction, and ranks the breakout 0–10 with a star score. The first block of the London session builds a range; price then has to actually close outside it, in agreement with momentum and the higher-timeframe trend, before a signal arms. Every setup gets a structural stop beyond the range that just broke and fixed R-based targets, and is tracked live on a full statistics dashboard — including end-of-session time-stops — so you can see exactly how the logic behaves on the pair and timeframe you trade.

🧠 Opening-Range Core — the core idea. At the start of the London session the engine records the high and low of a configurable opening window, 08:00–09:00 by default. That band is the opening range: the session's first agreed value area. A signal fires on the release — the bar that closes beyond the range high for a long or the range low for a short inside the trade window — and the direction is set by that break. Sessions are evaluated in Europe/London wall-clock time, so the BST/GMT shift is handled automatically and the range always anchors to the real London open regardless of your data feed's server time. Signals are evaluated on the bar's close and are fixed once that bar closes — the range and the break do not repaint.

📈 Range Mapping & ADR Context — while the opening window is live, the engine continuously tracks the developing high, low, and width of the range, then freezes it the moment the window ends. The finished range is measured in pips and expressed as a percentage of the pair's Average Daily Range, a non-repainting daily read, so you instantly see whether the session is coiling tightly or has already burned its move. A clean, proportionate range is a loaded session; an over-wide one is a day that has already spent itself — and the engine treats them differently in both the gate and the score.

🎯 Structural Stop + R-Based Targets — the stop is anchored to the range that just broke: below the range low for a long, above the range high for a short, each with an ATR buffer, or against the range midline or a pure ATR distance if you prefer — then capped and floored by ATR so it can never balloon into a wide stop or collapse into a meaningless one. TP1, TP2, and TP3 are set at clean R multiples and default to a balanced 1R / 2R / 3R, fully adjustable to whatever reward-to-risk you trade. Every signal plots its complete Entry / SL / TP1 / TP2 / TP3 line set, labeled levels, and filled TP / SL zone boxes, with a result label on exit. Optional measured-move guides project the range width ×1 and ×2 beyond each edge for a classic ORB target read.

🎚️ Conviction Controls — a small set of dials sets how serious a breakout must be before it counts: the 0–10 Minimum Strength gate, an optional Only Strong filter, a Range-vs-ADR window that skips days whose range is too tight or too wide, an optional break-buffer that demands the candle close a set ATR fraction past the edge rather than just nicking it, and Max Breakouts / Day. Tighten them for fewer, higher-quality fires; loosen them for more activity. This is your main dial for conviction versus frequency.

🧭 HTF Trend Alignment + Session Gating — an optional higher-timeframe EMA filter blocks counter-trend fires, keeping you on the dominant side: longs only above it, shorts only below. The higher-timeframe value is read without lookahead. Entries are confined to a configurable trade window after the range forms, and a per-day cap spaces out tickets so one volatile session can't stack trades. Anything still open at the close of the trade window is flattened by an end-of-session time-stop — and that exit is booked and counted honestly, never quietly dropped.

⭐ 0–10 Setup-Quality Score — every release is scored and labeled with 1–5 stars and a tier FORMING → WEAK → MODERATE → STRONG → VERY STRONG → ELITE across breakout-native factors: expansion-candle body strength, candle range vs ATR, momentum alignment over short and medium lookbacks, volume confirmation, clean penetration beyond the range edge, RSI agreement, higher-timeframe EMA alignment, intraday bias of close versus the session open, a first-break-of-the-day premium, and a range-vs-ADR coil check. Treat the score as a confluence / cleanliness read for ranking and thinning setups — it describes how textbook a breakout is, not a guaranteed outcome. The Minimum Strength / Only Strong gate restricts what is displayed and alerted, while the dashboard keeps tracking every tier in the background.

📊 Live Statistics Dashboard — a non-intrusive Bloomberg-amber panel tracks, in real time on your chart: the current session state of waiting / forming OR / range set / armed / trade active, the live opening-range size and its ADR percentage, the pair's ADR, current status and the active trade, the last signal with its star score, total signals, win rate, closed trades, profit factor, average R per trade, best-performing direction, long vs short win rate, current and max win/loss streaks, and a TP1 / TP2 / TP3 / SL / EOD outcome breakdown. Every filled trade that reaches an outcome is counted — winners, stop-outs, and time-stops alike — so the numbers are computed live from the real signals on your current symbol and timeframe rather than a figure printed in a description.

🎨 Clean Themed Visuals — a Bloomberg Amber institutional palette, with Ice Blue, Emerald, and Mono alternates, shades the opening-range box, the ORH / ORL / midline levels, the per-trade SL / TP ladder, and the dashboard to one coherent look, so quality and direction read at a glance. The range box is drawn over the window where it formed and projected forward with pip-labeled edges; long and short trades are color-keyed; an optional faint tint marks the active opening window. A projection-length and max-drawn-trades control keep the chart clean — the right-edge zones never stretch into oversized towers, and only the most recent N tickets stay drawn while the statistics remain cumulative over the whole history.

🔔 Detailed Alerts — fires on long / short opening-range breakouts, plus TP3, partial-TP, SL, and end-of-session exit events, formatted for manual or automated use. The minimum-strength setting can restrict alerts to higher-conviction setups.

🔧 Fully Customizable — every component is exposed: the session timezone, opening-range window, and trade window; the ATR length and 0–10 strength gate with Only-Strong filter; the ADR lookback and min/max range-vs-ADR band; the break-buffer and max-breakouts-per-day; the stop basis of range opposite / midline / ATR with buffer and risk cap/floor; the three R targets; projection length, OR-days kept, and max drawn trades; the HTF alignment filter and timeframe; the pip definition for non-standard feeds; all four themes; and every label, dashboard, zone, and measured-move toggle.

🎯 Why this is different — most ORB tools just draw two lines at a fixed clock time and leave everything after that to you. This one anchors the range to the real London open in exchange time with automatic DST, sizes the break against the pair's own ADR so a tight coil and a blown-out day aren't treated alike, demands momentum, volume, penetration, and trend confirmation before it fires, anchors the stop to the range that actually broke, then layers an objective 0–10 ranking and a live, honest statistics panel — one that counts stop-outs and end-of-session exits in full — so you are tuning and judging the system on real, current data instead of a marketing figure.

🚀 Where to use it — built and validated for Forex, with particular strength on London-driven pairs: GBP, EUR, and USD majors and crosses such as GBPUSD, GBPJPY, GBPCAD, GBPNZD, and EURUSD, on intraday timeframes around M5 / M10 / M15. It is pip-aware for both 5-digit and 3-digit JPY pairs, and the ATR-based stop and ADR sizing adapt to each pair's volatility automatically. The session windows can be re-pointed for the New York or Asian open if you want to run the same engine on a different session.

🎯 How to trade it

Apply it to a liquid pair on an intraday timeframe and let the dashboard populate. Read the live win rate, profit factor, and average R for your symbol and timeframe before committing — if the logic doesn't suit that pair, you'll see it.
Keep the HTF Trend Alignment filter on so you only take breakouts in the direction of the larger trend, and keep the Range-vs-ADR gate on to skip dead or already-spent sessions.
Wait for a LO ORB LONG / LO ORB SHORT label — it marks a confirmed close beyond the opening range, with the star score and Entry, SL, and TP1/2/3 already plotted.
Manage the trade with the plotted levels: the structural SL defines your risk, TP1/2/3 sit at your chosen R multiples, and any position still open at the trade-window close is flattened by the time-stop. Bank or trail however suits your style.
Use Minimum Strength, the break-buffer, and Max Breakouts / Day to set your tempo — stricter for fewer, cleaner releases; looser for more activity — and use the star score and Only-Strong gate to focus on the cleanest setups.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Default settings were chosen on historical data and behavior will vary by pair, timeframe, session, and configuration; the dashboard's statistics are historical and descriptive, not a forecast. The trade model includes an end-of-session time-stop, so some trades close at the session boundary at a fraction of a target rather than a full win or loss — these are counted in full, which is honest but means win rate alone is misleading; always weigh it together with average R and profit factor, and resize the R targets to your own risk profile. Signals confirm on the closed bar, so always wait for the labeled release on a closed candle. Always combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6
indicator("Strong LO ORB", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

gSess = "01 · London Session"
tzIn       = input.string("Europe/London", "Session Timezone", options = ["Europe/London", "America/New_York", "Asia/Tokyo", "UTC", "Exchange"], group = gSess, tooltip = "Wall-clock zone the opening-range and trade windows are evaluated in. Europe/London auto-handles BST/GMT.")
orSess     = input.session("0800-0900", "Opening Range Window", group = gSess, tooltip = "First block of the London session that forms the range. 0800-0900 = first hour, 0800-0830 = first 30 min.")
tradeSess  = input.session("0900-1600", "Breakout Trade Window", group = gSess, tooltip = "Window in which breakouts are taken. Any open trade is flattened at its close.")

gStr = "02 · Strength Engine"
atrLen     = input.int(14,  "ATR Length", minval = 1, group = gStr)
minStr     = input.float(4.0, "Min Strength To Signal (0-10)", minval = 0, maxval = 10, step = 0.5, group = gStr, tooltip = "Reject breakouts scoring below this on the 0-10 conviction engine.")
onlyStrong = input.bool(false, "Only Take Strong Breakouts", group = gStr)
strongThr  = input.float(7.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)

gFilt = "03 · Filters"
useHtf     = input.bool(true, "HTF Trend Alignment", group = gFilt, tooltip = "Only longs above the HTF EMA, only shorts below it.")
htfTF      = input.timeframe("60", "HTF Timeframe", group = gFilt)
htfEmaLen  = input.int(50, "HTF EMA Length", minval = 5, maxval = 500, group = gFilt)
useAdrGate = input.bool(true, "Range-vs-ADR Gate", group = gFilt, tooltip = "Skip days whose opening range is too tight or too wide relative to the average daily range.")
adrDays    = input.int(14, "ADR Lookback (days)", minval = 3, maxval = 60, group = gFilt)
minOrPct   = input.float(8.0,  "Min OR (% of ADR)", minval = 0, maxval = 100, step = 1, group = gFilt)
maxOrPct   = input.float(55.0, "Max OR (% of ADR)", minval = 5, maxval = 200, step = 1, group = gFilt)
maxPerDay  = input.int(1, "Max Breakouts / Day", minval = 1, maxval = 5, group = gFilt)
retestReq  = input.bool(false, "Require Close Beyond OR by Buffer", group = gFilt, tooltip = "Demand the breakout candle close at least an ATR fraction past the range edge.")
breakBuf   = input.float(0.05, "Break Buffer (× ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = gFilt)

gTrade = "04 · Trade Model"
slMode     = input.string("OR Opposite", "Stop Basis", options = ["OR Opposite", "OR Mid", "ATR"], group = gTrade, tooltip = "Where the protective stop is anchored before risk caps are applied.")
slBufAtr   = input.float(0.20, "Stop Buffer (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gTrade)
slAtrMult  = input.float(1.20, "ATR Stop Distance (× ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = gTrade, tooltip = "Only used when Stop Basis = ATR.")
maxRiskAtr = input.float(4.0, "Max Risk (× ATR) — cap", minval = 0.5, maxval = 12.0, step = 0.1, group = gTrade)
minRiskAtr = input.float(0.4, "Min Risk (× ATR) — floor", minval = 0.1, maxval = 6.0, step = 0.1, group = gTrade)
tp1R       = input.float(1.0, "TP1 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTrade)
tp2R       = input.float(2.0, "TP2 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTrade)
tp3R       = input.float(3.0, "TP3 (R)", minval = 0.3, maxval = 50, step = 0.1, group = gTrade)
maxHist    = input.int(25, "Max Drawn Trades", minval = 1, maxval = 80, group = gTrade)

gVis = "05 · Visuals"
theme      = input.string("Bloomberg Amber", "Color Theme", options = ["Bloomberg Amber", "Ice Blue", "Emerald", "Mono"], group = gVis)
showORBox  = input.bool(true, "Show OR Box", group = gVis)
showORExt  = input.bool(true, "Show OR Projection Lines", group = gVis)
showMid    = input.bool(true, "Show OR Midline", group = gVis)
showTargets= input.bool(true, "Show Measured-Move Guides", group = gVis)
projLen    = input.int(60, "Projection Length (bars)", minval = 5, maxval = 400, group = gVis)
orDays     = input.int(8, "OR Days Kept", minval = 1, maxval = 40, group = gVis)
orTransp   = input.int(88, "OR Fill Transparency", minval = 60, maxval = 98, group = gVis)
showSignal = input.bool(true, "Show Signal Labels", group = gVis)
showStars  = input.bool(true, "Show ★ Rank", group = gVis)
showLines  = input.bool(true, "Show SL / TP Lines", group = gVis)
showBoxes  = input.bool(true, "Show SL / TP Zones", group = gVis)
showLevel  = input.bool(true, "Label Trade Levels", group = gVis)
showExit   = input.bool(true, "Show Result Labels", group = gVis)
lblSizeOpt = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)
shadeSess  = input.bool(true, "Shade OR Window", group = gVis)

gDash = "06 · Dashboard"
showDash   = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt= input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showHeat   = input.bool(true, "Show Outcome Breakdown", group = gDash)
pipMult    = input.int(10, "Pip = mintick ×", minval = 1, maxval = 100, group = gDash, tooltip = "10 for 5-digit FX and 3-digit JPY pairs.")

amber   = color.rgb(255, 176, 0)
amberHi = color.rgb(255, 201, 77)
amberLo = color.rgb(184, 134, 43)
longCol  = theme == "Ice Blue" ? color.rgb(0, 190, 255) : theme == "Emerald" ? color.rgb(0, 200, 120) : theme == "Mono" ? color.rgb(225, 225, 225) : amber
shortCol = theme == "Ice Blue" ? color.rgb(255, 110, 70) : theme == "Emerald" ? color.rgb(235, 64, 64) : theme == "Mono" ? color.rgb(120, 120, 120) : color.rgb(255, 78, 60)
tpFill   = theme == "Ice Blue" ? color.rgb(0, 90, 130) : theme == "Emerald" ? color.rgb(0, 96, 60) : theme == "Mono" ? color.rgb(70, 70, 70) : color.rgb(120, 84, 0)
slFill   = theme == "Ice Blue" ? color.rgb(150, 30, 70) : theme == "Emerald" ? color.rgb(150, 22, 30) : theme == "Mono" ? color.rgb(50, 50, 50) : color.rgb(150, 40, 18)
accent   = theme == "Bloomberg Amber" ? amber : longCol

color panelBg     = #0a0a0a
color panelBgAlt  = #14110a
color panelHdr    = #1c1407
color panelBorder = #3a2c0a
color txtHi       = #f3ead4
color txtLo       = #9a8f74
color neutralCol  = #7a715a
color goodCol     = #3ad17a
color badCol      = #ff4d4d

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

f_stars(float sc) => sc >= 8.5 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5.5 ? "★★★" : sc >= 4 ? "★★" : sc >= 2.5 ? "★" : "·"
f_tier(float sc)  => sc >= 8.5 ? "ELITE" : sc >= 7 ? "VERY STRONG" : sc >= 5.5 ? "STRONG" : sc >= 4 ? "MODERATE" : sc >= 2.5 ? "WEAK" : "FORMING"
f_signedR(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

string tzUse = tzIn == "Exchange" ? syminfo.timezone : tzIn
float pipSize = syminfo.mintick * pipMult
f_pips(float d) => pipSize > 0 ? str.tostring(math.abs(d) / pipSize, "#.#") : "—"

atr      = ta.atr(atrLen)
rsi      = ta.rsi(close, 14)
volSma   = ta.sma(volume, 20)
volRatio = volSma > 0 ? volume / volSma : 1.0
candleRng = high - low
bodyRatio = candleRng > 0 ? math.abs(close - open) / candleRng : 0.5
atrRatio  = atr > 0 ? candleRng / atr : 0.0
mom3 = close - close[3]
mom5 = close - close[5]

htfEma = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLen)[1], lookahead = barmerge.lookahead_off)
adr    = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrDays)[1], lookahead = barmerge.lookahead_off)

type oViz
    box   bx
    line  hl
    line  ll
    line  hp
    line  lp
    line  ml
    line  u1
    line  u2
    line  d1
    line  d2
    label hlb
    label llb
    label mlb
    label u1b
    label u2b
    label d1b
    label d2b

type tViz
    line  en
    line  sl
    line  t1
    line  t2
    line  t3
    box   tb
    box   sb
    label sg
    label le
    label ls
    label l1
    label l2
    label l3
    label ex

var array<oViz> orHist = array.new<oViz>()
var array<tViz> trHist = array.new<tViz>()

inOR    = not na(time(timeframe.period, orSess, tzUse))
inTrade = not na(time(timeframe.period, tradeSess, tzUse))
orOpen  = inOR and not inOR[1]
orClose = not inOR and inOR[1]
trClose = not inTrade and inTrade[1]

var float orH = na
var float orL = na
var float orMid = na
var float orRange = na
var float dayOpen = na
var bool  orFormed = false
var int   orStartBar = na
var int   tradesToday = 0
var int   dirToday = 0
var float adrAtOpen = na

if orOpen
    orH := high
    orL := low
    orStartBar := bar_index
    orFormed := false
    tradesToday := 0
    dirToday := 0
    dayOpen := open
    adrAtOpen := adr

if inOR and not orOpen and not na(orH)
    orH := math.max(orH, high)
    orL := math.min(orL, low)

bool justFormed = false
if orClose and not na(orH)
    orMid := (orH + orL) / 2
    orRange := orH - orL
    orFormed := true
    justFormed := true

f_orb_strength(bool isLong, float pen, float bdy, float atrR, float volR, float m3, float m5, float rsiv, bool htfOk, bool biasOk, bool firstOfDay, float orR, float adrV) =>
    s = 0.0
    s += bdy >= 0.85 ? 1.5 : bdy >= 0.70 ? 1.1 : bdy >= 0.55 ? 0.6 : 0.2
    s += atrR >= 2.0 ? 1.5 : atrR >= 1.4 ? 1.0 : atrR >= 1.0 ? 0.6 : 0.2
    s += volR >= 2.0 ? 1.5 : volR >= 1.5 ? 1.0 : volR >= 1.2 ? 0.5 : 0.0
    m3ok = (isLong and m3 > 0) or (not isLong and m3 < 0)
    m5ok = (isLong and m5 > 0) or (not isLong and m5 < 0)
    s += m3ok and m5ok ? 1.5 : m3ok or m5ok ? 0.7 : -0.4
    s += pen >= 0.5 ? 1.0 : pen >= 0.25 ? 0.6 : pen >= 0.1 ? 0.3 : 0.0
    rsiOk = (isLong and rsiv > 52) or (not isLong and rsiv < 48)
    s += rsiOk ? 0.5 : 0.0
    s += htfOk ? 1.0 : 0.0
    s += biasOk ? 0.5 : 0.0
    s += firstOfDay ? 1.0 : 0.0
    coil = adrV > 0 ? orR / adrV : 0.0
    s += coil >= 0.12 and coil <= 0.45 ? 0.5 : 0.0
    math.max(0.0, math.min(10.0, math.round(s * 10) / 10))

var bool  tradeActive = false
var int   tradeSide = 0
var int   tradeBar = na
var float tEntry = na
var float tStop = na
var float tTp1 = na
var float tTp2 = na
var float tTp3 = na
var float tRisk = na
var float tScore = na
var int   bestStage = 0

var int   lastSide = 0
var float lastScore = na

var line  aEn = na
var line  aSl = na
var line  aT1 = na
var line  aT2 = na
var line  aT3 = na
var box   aTb = na
var box   aSb = na
var label aSg = na
var label aLe = na
var label aLs = na
var label aL1 = na
var label aL2 = na
var label aL3 = na
var label aEx = na

var int   sTotal = 0
var int   sClosed = 0
var int   sWins = 0
var float sR = 0.0
var float sGW = 0.0
var float sGL = 0.0
var int   sLong = 0
var int   sLongW = 0
var int   sShort = 0
var int   sShortW = 0
var int   sTp1 = 0
var int   sTp2 = 0
var int   sTp3 = 0
var int   sSl = 0
var int   sEod = 0
var int   sCurW = 0
var int   sCurL = 0
var int   sMaxW = 0
var int   sMaxL = 0
var int   sStreak = 0

orRightProj = na(orStartBar) ? bar_index : orStartBar + projLen

if tradeActive
    int rightNow = na(tradeBar) ? bar_index : math.min(bar_index, tradeBar + projLen)
    if showLines
        if not na(aEn)
            line.set_x2(aEn, rightNow)
        if not na(aSl)
            line.set_x2(aSl, rightNow)
        if not na(aT1)
            line.set_x2(aT1, rightNow)
        if not na(aT2)
            line.set_x2(aT2, rightNow)
        if not na(aT3)
            line.set_x2(aT3, rightNow)
    if showBoxes
        if not na(aTb)
            box.set_right(aTb, rightNow)
        if not na(aSb)
            box.set_right(aSb, rightNow)

closedTp3 = false
closedSl  = false
closedTp  = false
closedEod = false

if tradeActive
    bool tp1Hit = tradeSide == 1 ? high >= tTp1 : low <= tTp1
    bool tp2Hit = tradeSide == 1 ? high >= tTp2 : low <= tTp2
    bool tp3Hit = tradeSide == 1 ? high >= tTp3 : low <= tTp3
    bool slHit  = tradeSide == 1 ? low  <= tStop : high >= tStop

    int stage = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
    bool sameBarSl = slHit and stage > 0
    if stage > bestStage and not sameBarSl
        bestStage := stage

    bool finalTp3 = not sameBarSl and bestStage == 3
    bool finalSl  = slHit and (bestStage == 0 or sameBarSl)
    bool finalTp  = slHit and not sameBarSl and bestStage > 0 and bestStage < 3
    bool finalEod = trClose and not (finalTp3 or finalSl or finalTp)

    if finalTp3 or finalSl or finalTp or finalEod
        float markR = tRisk > 0 ? (tradeSide == 1 ? (close - tEntry) / tRisk : (tEntry - close) / tRisk) : 0.0
        float eodR  = math.max(-1.0, math.min(tp3R, markR))
        float resR  = finalTp3 ? tp3R : finalTp and bestStage == 2 ? tp2R : finalTp and bestStage == 1 ? tp1R : finalSl ? -1.0 : eodR
        bool isWin = resR > 0

        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        closedEod := finalEod

        sClosed += 1
        sR += resR
        if isWin
            sWins += 1
            sGW += resR
            sCurW += 1
            sCurL := 0
            sMaxW := math.max(sMaxW, sCurW)
            sStreak := sCurW
        else
            sGL += math.abs(resR)
            sCurL += 1
            sCurW := 0
            sMaxL := math.max(sMaxL, sCurL)
            sStreak := -sCurL
        if tradeSide == 1
            sLong += 1
            sLongW += isWin ? 1 : 0
        else
            sShort += 1
            sShortW += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
        else if finalTp and bestStage == 2
            sTp2 += 1
        else if finalTp and bestStage == 1
            sTp1 += 1
        else if finalSl
            sSl += 1
        else
            sEod += 1

        int closeEdge = na(tradeBar) ? bar_index : math.max(tradeBar + 3, bar_index)
        if showLines
            if not na(aEn)
                line.set_x2(aEn, closeEdge)
            if not na(aSl)
                line.set_x2(aSl, closeEdge)
            if not na(aT1)
                line.set_x2(aT1, closeEdge)
            if not na(aT2)
                line.set_x2(aT2, closeEdge)
            if not na(aT3)
                line.set_x2(aT3, closeEdge)
        if showBoxes
            if not na(aTb)
                box.set_right(aTb, closeEdge)
            if not na(aSb)
                box.set_right(aSb, closeEdge)
        if showLevel
            if not na(aLe)
                label.set_x(aLe, closeEdge)
            if not na(aLs)
                label.set_x(aLs, closeEdge)
            if not na(aL1)
                label.set_x(aL1, closeEdge)
            if not na(aL2)
                label.set_x(aL2, closeEdge)
            if not na(aL3)
                label.set_x(aL3, closeEdge)

        float resPrice = finalTp3 ? tTp3 : finalTp and bestStage == 2 ? tTp2 : finalTp and bestStage == 1 ? tTp1 : finalSl ? tStop : close
        string resTxt = finalTp3 ? "TP3 ✔ " + f_signedR(resR) : finalTp ? "TP" + str.tostring(bestStage) + " ✔ " + f_signedR(resR) : finalSl ? "SL ✘ -1R" : "EOD ⏱ " + f_signedR(resR)
        color resCol = resR >= 0 ? longCol : shortCol
        string resStyle0 = tradeSide == 1 ? (resR >= 0 ? "down" : "up") : (resR >= 0 ? "up" : "down")
        if showExit
            aEx := label.new(closeEdge, resPrice, resTxt, style = resStyle0 == "down" ? label.style_label_down : label.style_label_up, color = color.new(resCol, 0), textcolor = color.white, size = f_size(lblSizeOpt))

        tViz tv = tViz.new(aEn, aSl, aT1, aT2, aT3, aTb, aSb, aSg, aLe, aLs, aL1, aL2, aL3, aEx)
        array.push(trHist, tv)
        while array.size(trHist) > maxHist
            tViz old = array.shift(trHist)
            if not na(old.en)
                line.delete(old.en)
            if not na(old.sl)
                line.delete(old.sl)
            if not na(old.t1)
                line.delete(old.t1)
            if not na(old.t2)
                line.delete(old.t2)
            if not na(old.t3)
                line.delete(old.t3)
            if not na(old.tb)
                box.delete(old.tb)
            if not na(old.sb)
                box.delete(old.sb)
            if not na(old.sg)
                label.delete(old.sg)
            if not na(old.le)
                label.delete(old.le)
            if not na(old.ls)
                label.delete(old.ls)
            if not na(old.l1)
                label.delete(old.l1)
            if not na(old.l2)
                label.delete(old.l2)
            if not na(old.l3)
                label.delete(old.l3)
            if not na(old.ex)
                label.delete(old.ex)

        aEn := na
        aSl := na
        aT1 := na
        aT2 := na
        aT3 := na
        aTb := na
        aSb := na
        aSg := na
        aLe := na
        aLs := na
        aL1 := na
        aL2 := na
        aL3 := na
        aEx := na

        tradeActive := false
        tradeSide := 0
        tradeBar := na
        tEntry := na
        tStop := na
        tTp1 := na
        tTp2 := na
        tTp3 := na
        tRisk := na
        bestStage := 0

bool crossUp = orFormed and inTrade and not na(orH) and close > orH and close[1] <= orH
bool crossDn = orFormed and inTrade and not na(orL) and close < orL and close[1] >= orL

float penUp = atr > 0 ? (close - orH) / atr : 0.0
float penDn = atr > 0 ? (orL - close) / atr : 0.0

bool bufOkUp = not retestReq or (close - orH) >= breakBuf * atr
bool bufOkDn = not retestReq or (orL - close) >= breakBuf * atr

bool htfOkUp = not useHtf or close > htfEma
bool htfOkDn = not useHtf or close < htfEma

float coilPct = adrAtOpen > 0 ? orRange / adrAtOpen * 100.0 : na
bool adrOkUp = not useAdrGate or (not na(coilPct) and coilPct >= minOrPct and coilPct <= maxOrPct)
bool adrOkDn = adrOkUp

bool biasUp = not na(dayOpen) and close > dayOpen
bool biasDn = not na(dayOpen) and close < dayOpen
bool firstUp = tradesToday == 0
bool firstDn = tradesToday == 0

float scUp = crossUp ? f_orb_strength(true,  penUp, bodyRatio, atrRatio, volRatio, mom3, mom5, rsi, htfOkUp, biasUp, firstUp, orRange, adrAtOpen) : 0.0
float scDn = crossDn ? f_orb_strength(false, penDn, bodyRatio, atrRatio, volRatio, mom3, mom5, rsi, htfOkDn, biasDn, firstDn, orRange, adrAtOpen) : 0.0

bool dirAllowedUp = dirToday == 0 or maxPerDay > 1
bool dirAllowedDn = dirToday == 0 or maxPerDay > 1

bool sigLong  = crossUp and bufOkUp and htfOkUp and adrOkUp and dirAllowedUp and scUp >= minStr and (not onlyStrong or scUp >= strongThr)
bool sigShort = crossDn and bufOkDn and htfOkDn and adrOkDn and dirAllowedDn and scDn >= minStr and (not onlyStrong or scDn >= strongThr)
sigShort := sigShort and not sigLong

bool gateDay = tradesToday < maxPerDay and not tradeActive
bool closedAny = closedTp3 or closedSl or closedTp or closedEod
bool takeLong  = sigLong  and gateDay and not closedAny and not na(atr)
bool takeShort = sigShort and gateDay and not closedAny and not na(atr)

if takeLong or takeShort
    bool isLong = takeLong
    int side = isLong ? 1 : -1
    float sc = isLong ? scUp : scDn
    float entv = close
    float rawStop = slMode == "ATR" ? (isLong ? entv - atr * slAtrMult : entv + atr * slAtrMult) : slMode == "OR Mid" ? (isLong ? orMid - atr * slBufAtr : orMid + atr * slBufAtr) : (isLong ? orL - atr * slBufAtr : orH + atr * slBufAtr)
    float risk0 = math.abs(entv - rawStop)
    float maxR = atr * maxRiskAtr
    float minR = atr * minRiskAtr
    float risk = math.min(math.max(risk0, minR), maxR)
    float stopv = isLong ? entv - risk : entv + risk
    float t1 = isLong ? entv + risk * tp1R : entv - risk * tp1R
    float t2 = isLong ? entv + risk * tp2R : entv - risk * tp2R
    float t3 = isLong ? entv + risk * tp3R : entv - risk * tp3R

    tradeActive := true
    tradeSide := side
    tradeBar := bar_index
    tEntry := entv
    tStop := stopv
    tTp1 := t1
    tTp2 := t2
    tTp3 := t3
    tRisk := risk
    bestStage := 0
    tScore := sc
    lastSide := side
    lastScore := sc
    sTotal += 1
    tradesToday += 1
    dirToday := side

    color c = isLong ? longCol : shortCol
    int xr = bar_index + math.min(projLen, 30)

    if showSignal
        string head = isLong ? "LO ORB LONG" : "LO ORB SHORT"
        string txt = showStars ? head + "\n" + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_tier(sc) : head
        aSg := label.new(bar_index, isLong ? low : high, txt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 6), textcolor = color.white, size = f_size(lblSizeOpt))

    if showBoxes
        float tpTop = isLong ? t3 : entv
        float tpBot = isLong ? entv : t3
        float slTop = isLong ? entv : stopv
        float slBot = isLong ? stopv : entv
        aTb := box.new(bar_index, tpTop, xr, tpBot, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 82), border_color = color.new(c, 40), border_width = 1)
        aSb := box.new(bar_index, slTop, xr, slBot, xloc = xloc.bar_index, bgcolor = color.new(slFill, 82), border_color = color.new(shortCol, 50), border_width = 1)

    if showLines
        aEn := line.new(bar_index, entv,  xr, entv,  xloc = xloc.bar_index, color = color.new(c, 0), width = 2, style = line.style_solid)
        aSl := line.new(bar_index, stopv, xr, stopv, xloc = xloc.bar_index, color = color.new(shortCol, 10), width = 1, style = line.style_dashed)
        aT1 := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(c, 12), width = 1, style = line.style_solid)
        aT2 := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(c, 32), width = 1, style = line.style_solid)
        aT3 := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(c, 50), width = 1, style = line.style_solid)
        if showLevel
            string dw = isLong ? "LONG" : "SHORT"
            aLe := label.new(xr, entv,  dw + " @ " + str.tostring(entv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 0), textcolor = color.white, size = f_size(lblSizeOpt))
            aLs := label.new(xr, stopv, "SL @ " + str.tostring(stopv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aL1 := label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 12), textcolor = color.white, size = f_size(lblSizeOpt))
            aL2 := label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 28), textcolor = color.white, size = f_size(lblSizeOpt))
            aL3 := label.new(xr, t3, "TP3 " + str.tostring(tp3R, "#.#") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 44), textcolor = color.white, size = f_size(lblSizeOpt))

if justFormed and not na(orH)
    int xr = orStartBar + projLen
    int orEndBar = bar_index - 1
    color cz = accent
    box bx0 = na
    line hl0 = na
    line ll0 = na
    line hp0 = na
    line lp0 = na
    line ml0 = na
    line u10 = na
    line u20 = na
    line d10 = na
    line d20 = na
    label hlb0 = na
    label llb0 = na
    label mlb0 = na
    label u1b0 = na
    label u2b0 = na
    label d1b0 = na
    label d2b0 = na

    if showORBox
        bx0 := box.new(orStartBar, orH, orEndBar, orL, xloc = xloc.bar_index, bgcolor = color.new(cz, orTransp), border_color = color.new(cz, 45), border_width = 1)
    hl0 := line.new(orStartBar, orH, orEndBar, orH, xloc = xloc.bar_index, color = color.new(cz, 0), width = 2, style = line.style_solid)
    ll0 := line.new(orStartBar, orL, orEndBar, orL, xloc = xloc.bar_index, color = color.new(cz, 0), width = 2, style = line.style_solid)
    if showORExt
        hp0 := line.new(orEndBar, orH, xr, orH, xloc = xloc.bar_index, color = color.new(cz, 25), width = 1, style = line.style_dashed)
        lp0 := line.new(orEndBar, orL, xr, orL, xloc = xloc.bar_index, color = color.new(cz, 25), width = 1, style = line.style_dashed)
    if showMid
        ml0 := line.new(orStartBar, orMid, xr, orMid, xloc = xloc.bar_index, color = color.new(amberLo, 30), width = 1, style = line.style_dotted)
    string rngTxt = "  (" + f_pips(orRange) + "p)"
    hlb0 := label.new(xr, orH, "ORH " + str.tostring(orH, format.mintick) + rngTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cz, 80), textcolor = cz, size = f_size(lblSizeOpt))
    llb0 := label.new(xr, orL, "ORL " + str.tostring(orL, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cz, 80), textcolor = cz, size = f_size(lblSizeOpt))
    if showMid
        mlb0 := label.new(xr, orMid, "MID " + str.tostring(orMid, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(amberLo, 85), textcolor = amberLo, size = size.tiny)
    if showTargets
        float u1 = orH + orRange * 1.0
        float u2 = orH + orRange * 2.0
        float d1 = orL - orRange * 1.0
        float d2 = orL - orRange * 2.0
        u10 := line.new(orEndBar, u1, xr, u1, xloc = xloc.bar_index, color = color.new(longCol, 55), width = 1, style = line.style_dotted)
        u20 := line.new(orEndBar, u2, xr, u2, xloc = xloc.bar_index, color = color.new(longCol, 65), width = 1, style = line.style_dotted)
        d10 := line.new(orEndBar, d1, xr, d1, xloc = xloc.bar_index, color = color.new(shortCol, 55), width = 1, style = line.style_dotted)
        d20 := line.new(orEndBar, d2, xr, d2, xloc = xloc.bar_index, color = color.new(shortCol, 65), width = 1, style = line.style_dotted)
        u1b0 := label.new(xr, u1, "MM ×1", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(longCol, 88), textcolor = longCol, size = size.tiny)
        u2b0 := label.new(xr, u2, "MM ×2", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(longCol, 88), textcolor = longCol, size = size.tiny)
        d1b0 := label.new(xr, d1, "MM ×1", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 88), textcolor = shortCol, size = size.tiny)
        d2b0 := label.new(xr, d2, "MM ×2", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 88), textcolor = shortCol, size = size.tiny)

    oViz ov = oViz.new(bx0, hl0, ll0, hp0, lp0, ml0, u10, u20, d10, d20, hlb0, llb0, mlb0, u1b0, u2b0, d1b0, d2b0)
    array.push(orHist, ov)
    while array.size(orHist) > orDays
        oViz od = array.shift(orHist)
        if not na(od.bx)
            box.delete(od.bx)
        if not na(od.hl)
            line.delete(od.hl)
        if not na(od.ll)
            line.delete(od.ll)
        if not na(od.hp)
            line.delete(od.hp)
        if not na(od.lp)
            line.delete(od.lp)
        if not na(od.ml)
            line.delete(od.ml)
        if not na(od.u1)
            line.delete(od.u1)
        if not na(od.u2)
            line.delete(od.u2)
        if not na(od.d1)
            line.delete(od.d1)
        if not na(od.d2)
            line.delete(od.d2)
        if not na(od.hlb)
            label.delete(od.hlb)
        if not na(od.llb)
            label.delete(od.llb)
        if not na(od.mlb)
            label.delete(od.mlb)
        if not na(od.u1b)
            label.delete(od.u1b)
        if not na(od.u2b)
            label.delete(od.u2b)
        if not na(od.d1b)
            label.delete(od.d1b)
        if not na(od.d2b)
            label.delete(od.d2b)

plotshape(takeLong,  title = "Long Breakout",  style = shape.triangleup,   location = location.belowbar, color = longCol,  size = size.small)
plotshape(takeShort, title = "Short Breakout", style = shape.triangledown, location = location.abovebar, color = shortCol, size = size.small)
bgcolor(shadeSess and inOR ? color.new(accent, 94) : na, title = "OR Window Shade")

winRate = sClosed > 0 ? sWins / sClosed * 100.0 : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGL > 0 ? sGW / sGL : sGW > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? sLongW  / sLong  * 100.0 : 0.0
shortWR = sShort > 0 ? sShortW / sShort * 100.0 : 0.0
tp1Rate = sClosed > 0 ? sTp1 / sClosed * 100.0 : 0.0
tp2Rate = sClosed > 0 ? sTp2 / sClosed * 100.0 : 0.0
tp3Rate = sClosed > 0 ? sTp3 / sClosed * 100.0 : 0.0
slRate  = sClosed > 0 ? sSl  / sClosed * 100.0 : 0.0
eodRate = sClosed > 0 ? sEod / sClosed * 100.0 : 0.0

bestDir = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
streakTxt = sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—"
pfTxt = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")

statusTxt = tradeActive ? "TRADE ACTIVE" : orFormed ? (inTrade ? "ARMED" : "RANGE SET") : inOR ? "FORMING OR" : "WAITING"
activeTxt = tradeActive ? (tradeSide == 1 ? "LONG" : "SHORT") : "—"
lastTxt = lastSide == 1 ? "LONG" : lastSide == -1 ? "SHORT" : "—"
lastScoreTxt = na(lastScore) ? "—" : f_stars(lastScore) + " " + str.tostring(math.round(lastScore * 10) / 10) + "/10"
orTxt = na(orRange) ? "—" : f_pips(orRange) + "p"
adrTxt = na(adrAtOpen) ? "—" : f_pips(adrAtOpen) + "p"
coilTxt = na(coilPct) ? "—" : str.tostring(coilPct, "#") + "%"

color statusC = tradeActive ? accent : orFormed ? goodCol : neutralCol
color wrC = winRate >= 55 ? goodCol : winRate >= 45 ? amberHi : badCol
color pfC = pf >= 1.5 ? goodCol : pf >= 1.0 ? amberHi : badCol

var int dashRows = 15
var table dash = table.new(f_pos(dashPosOpt), 2, dashRows, frame_color = color.new(panelBorder, 0), frame_width = 1, border_width = 1, border_color = color.new(panelBorder, 20))

if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 1, dashRows - 1)

    table.cell(dash, 0, 0, "STRONG LO ORB", text_color = #0a0a0a, text_size = ps, text_halign = text.align_left, bgcolor = amber)
    table.cell(dash, 1, 0, "LONDON", text_color = #0a0a0a, text_size = ps, text_halign = text.align_center, bgcolor = amber)

    table.cell(dash, 0, 1, "Status", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 1, statusTxt, text_color = statusC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 2, "Active Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 2, activeTxt, text_color = tradeSide == 1 ? longCol : tradeSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 3, "Last Signal", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 3, lastTxt + "  " + lastScoreTxt, text_color = lastSide == 1 ? longCol : lastSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 4, "OR Range", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 4, orTxt + "  (" + coilTxt + " ADR)", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 5, "ADR (" + str.tostring(adrDays) + "d)", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 5, adrTxt, text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 6, "Total Signals", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 6, str.tostring(sTotal), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 7, "Win Rate", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 7, str.tostring(winRate, "#.#") + "%", text_color = wrC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 8, "Closed Trades", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 8, str.tostring(sClosed), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 9, "Profit Factor", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 9, pfTxt, text_color = pfC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 10, "Avg R / Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 10, f_signedR(avgR), text_color = avgR >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 11, "Best Direction", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 11, bestDir, text_color = bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    table.cell(dash, 0, 12, "L / S Win%", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 12, str.tostring(longWR, "#.#") + " / " + str.tostring(shortWR, "#.#"), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)

    table.cell(dash, 0, 13, "Streak", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 13, streakTxt + "  (max W" + str.tostring(sMaxW) + "/L" + str.tostring(sMaxL) + ")", text_color = sStreak >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)

    if showHeat
        table.cell(dash, 0, 14, "TP1/2/3·SL·EOD", text_color = #0a0a0a, text_size = ps, text_halign = text.align_left, bgcolor = amberLo)
        table.cell(dash, 1, 14, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + "·" + str.tostring(slRate, "#") + "·" + str.tostring(eodRate, "#"), text_color = #0a0a0a, text_size = ps, text_halign = text.align_center, bgcolor = amberLo)
    else
        table.cell(dash, 0, 14, "", bgcolor = panelHdr)
        table.cell(dash, 1, 14, "", bgcolor = panelHdr)

alertcondition(takeLong,   "LO ORB Long",  "Strong LO ORB: LONG breakout of the London opening range on {{ticker}} {{interval}}.")
alertcondition(takeShort,  "LO ORB Short", "Strong LO ORB: SHORT breakout of the London opening range on {{ticker}} {{interval}}.")
alertcondition(closedTp3,  "TP3 Hit",  "Strong LO ORB: TP3 reached on {{ticker}} {{interval}}.")
alertcondition(closedTp,   "Partial TP", "Strong LO ORB: protected TP exit on {{ticker}} {{interval}}.")
alertcondition(closedSl,   "SL Hit",   "Strong LO ORB: stop-loss on {{ticker}} {{interval}}.")
alertcondition(closedEod,  "EOD Exit", "Strong LO ORB: end-of-window flatten on {{ticker}} {{interval}}.")
````
