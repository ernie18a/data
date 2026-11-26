# Strong Squeeze Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/39xlboDh-Strong-Squeeze-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;e0b49fc9093743f988495abc38c350ab
- version: 1.0

## Description

[b]Strong Squeeze Signals catches the moment a genuine volatility coil releases — and instead of treating every flat patch as a setup, it waits for a real squeeze to fire, tags the direction from momentum, and ranks the release 0–10 with a star score. A market that has been compressing for a stretch of bars — its Bollinger Band wound tightly inside its Keltner Channel — has to actually expand back out, in the direction of momentum, before a signal arms. Every setup gets a structural stop beyond the coil that just broke and fixed R-based targets, and is tracked live on a full statistics dashboard so you can see how the logic behaves on the exact symbol and timeframe you trade.[/b]

🧠 Squeeze-Release Core — the core idea. The engine measures volatility compression directly from two bands. When a Bollinger Band contracts entirely inside a Keltner Channel, the market is coiling: range is shrinking and energy is building. A signal fires on the release — the bar where the band expands back outside the channel — and the direction is set by a linear-regression momentum oscillator that measures how far price sits from a composite centreline. Momentum above zero on the release fires a long; below zero fires a short. The longer and tighter the coil before it lets go, the more it counts. Signals are evaluated on the bar's close and are fixed once that bar closes — the release does not repaint.

📈 Coil Mapping & Tightness — while a squeeze is active, the engine continuously tracks how many bars it has been compressing, the high and low extent of the coil, and how tight it became — the Bollinger half-width as a fraction of the Keltner half-width. A long coil that wound down to a very tight ratio is a loaded spring; both the duration and the tightness feed directly into the strength score. A minimum-coil filter ignores fleeting micro-squeezes, and an optional Strict Fire setting demands a confirmed expansion on the release bar rather than just the end of the coil.

🎯 Structural Stop + R-Based Targets — the stop is placed just beyond the coil that just broke, with an ATR buffer: below the coil's low for a long, above the coil's high for a short — then capped and floored by ATR so it can never balloon into a wide stop or collapse into a meaningless one. TP1, TP2, and TP3 are set at clean R multiples and default to 0.5R / 0.75R / 1.25R — a tighter, hit-rate-leaning profile out of the box, and fully adjustable to whatever reward-to-risk you prefer. Every signal plots its complete Entry / SL / TP1 / TP2 / TP3 line set, labeled price levels, and filled TP / SL zone boxes, with a result label on exit.

🎚️ Coil-Conviction Controls — two inputs set how serious a squeeze must be before its release counts: Minimum Coil Bars To Arm how long the spring must compress and Minimum Strength the 0–10 gate. Tighten them for fewer, higher-quality fires; loosen them for more frequent signals. This is your main dial for conviction versus frequency.

🧭 HTF Trend Alignment Filter — an optional higher-timeframe EMA filter blocks counter-trend fires, keeping you on the dominant side of the market: longs only above it, shorts only below. The higher-timeframe value is read without lookahead. A signal cooldown spaces out entries so a single impulsive expansion doesn't stack multiple tickets.

⭐ 0–10 Setup-Quality Score — every release is scored and labeled with 1–5 stars and a tier FORMING → WEAK → MODERATE → STRONG → VERY STRONG → ELITE across nine squeeze-native factors: coil length stored energy, coil tightness how far the band compressed inside the channel, momentum magnitude at release, momentum acceleration in the fire direction, volume confirmation, expansion-candle body and range, band-width widening on the break, higher-timeframe alignment, and RSI agreement. Treat the score as a confluence / cleanliness read for ranking and thinning setups — it describes how textbook a squeeze release is, not a guaranteed outcome. A Minimum Strength / Only Strong gate lets you display and alert on stronger setups only, while the dashboard keeps tracking every tier in the background.

📊 Live Statistics Dashboard — a non-intrusive panel tracks, in real time on your chart: the current squeeze state coiling / fired / expanded / no squeeze, live coil-bar count, the momentum reading, current status and the active trade, the last signal with its star score, total signals, win rate, closed trades, profit factor, average R per trade, best-performing direction, long vs short win rate, current and max win/loss streaks, and a TP1 / TP2 / TP3 / SL hit breakdown. These are computed live from the signals on your current symbol and timeframe — so you can judge the settings yourself rather than trusting a number printed in a description.

🎨 Clean Themed Visuals — an institutional colour palette shades each zone by direction and score: bullish coils run a teal family that deepens as the score climbs, bearish coils a red-to-magenta-to-purple family, so quality reads at a glance. The compression zone is drawn over the bars where the coil formed and labeled with FIRE plus its star score; the TP and SL zones are harmonized to the same palette. Four lighting themes drive the lines, labels, and dashboard; an optional faint background tint marks active coils, and optional state dots can sit under the chart. A Max Zone Width control caps how far the SL / TP / Entry zones extend to the right, so long trades never stretch into oversized towers across the chart.

🔔 Detailed Alerts — fires on strong long / short squeeze releases, plus squeeze-on new coil forming, squeeze-released, partial-TP, TP3, and SL events, including direction and score, formatted for manual or automated use. The minimum-strength setting can restrict alerts to higher-conviction setups.

🔧 Fully Customizable — every component is exposed: Bollinger and Keltner lengths and multipliers, the true-range toggle, minimum coil bars and Strict Fire confirmation, the 0–10 strength gate and Only-Strong filter, ATR length, the structural-stop buffer with risk cap/floor, the three R targets, level-shelf length and Max Zone Width, the HTF alignment filter, the signal cooldown, plus the full institutional box palette, all four themes, and every label, dashboard, and zone-shading option.

🎯 Why this is different — most squeeze tools just print a histogram or drop a dot when the bands let go and leave everything after that to you. This one classifies the release direction from momentum, requires a real coil rather than a momentary flat spot measuring both how long and how tightly it compressed, demands momentum, acceleration, volume, and expansion confirmation, anchors the stop to the coil that actually broke, then layers an objective 0–10 ranking and a live, on-chart statistics panel on top — so you are tuning and judging the system on real, current data instead of a marketing figure.

🚀 Where to use it — markets that coil and expand: Forex, Gold XAUUSD, indices, and crypto, on intraday and swing timeframes M10/M15/M30/H1 and up. The ATR-based stop and R targets adapt to each asset's volatility automatically.

🎯 How to trade it

Apply it to a market that produces real volatility cycles and let the dashboard populate. Read the live win rate, profit factor, and average R for your symbol and timeframe before committing — if the logic doesn't suit that market, you'll see it.
Keep the HTF Trend Alignment filter on so you only take releases in the direction of the larger trend.
Wait for a STRONG LONG FIRE / STRONG SHORT FIRE label — it marks a confirmed coil release, with the star score and Entry, SL, and TP1/2/3 already plotted.
Manage the trade with the plotted levels: with the default sub-1R targets a common approach is to bank TP1 quickly, then trail or hold the remainder toward TP2/TP3; the structural SL defines your risk on the trade. If you prefer a higher reward-to-risk profile, widen the R targets in the inputs.
Use Minimum Coil Bars and Minimum Strength to set your style — stricter for fewer, cleaner releases; looser for more activity — and use the star score and Only-Strong gate to focus on the cleanest setups.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Default settings were chosen on historical data and behavior will vary by symbol, timeframe, and configuration; the dashboard's statistics are historical and descriptive, not a forecast. Note the default targets are sub-1R 0.5R / 0.75R / 1.25R: tight targets tend to raise the raw hit rate while lowering the reward-to-risk on each trade, so win rate read on its own is misleading — always weigh it together with average R and profit factor, and resize the targets to your own risk profile. Signals confirm on the closed bar, so always wait for the labeled release on a closed candle. Always combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6
indicator("Strong Squeeze Signals", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)
gEng = "01 · Squeeze Engine"
lenBB    = input.int(20,  "BB Length",        minval = 2, maxval = 200, group = gEng, tooltip = "Bollinger Band lookback (conventional default 20).")
multBB   = input.float(2.0, "BB Mult",        minval = 0.5, maxval = 6.0, step = 0.1, group = gEng, tooltip = "Bollinger Band standard-deviation multiplier.")
lenKC    = input.int(20,  "KC Length",        minval = 2, maxval = 200, group = gEng, tooltip = "Keltner Channel lookback. Also the momentum (linreg) window.")
multKC   = input.float(1.5, "KC Mult",        minval = 0.5, maxval = 6.0, step = 0.1, group = gEng, tooltip = "Keltner Channel range multiplier (conventional default 1.5).")
useTR    = input.bool(true, "Use TrueRange (KC)", group = gEng, tooltip = "Use True Range for the Keltner width instead of High-Low.")
strictFire = input.bool(false, "Strict Fire (require expansion)", group = gEng, tooltip = "Require a confirmed volatility expansion on the release bar, not just the end of the coil.")
minCoil  = input.int(4, "Min Coil Bars To Arm", minval = 1, maxval = 100, group = gEng, tooltip = "A squeeze must have coiled at least this many bars before a release counts as a signal. Filters out micro-squeezes.")
gStr = "02 · Strength Filter"
minStr     = input.int(4, "Min Strength To Signal (0-10)", minval = 0, maxval = 10, group = gStr, tooltip = "Reject squeeze fires scoring below this on the 0-10 engine.")
onlyStrong = input.bool(false, "Only Show Strong Signals", group = gStr, tooltip = "Extra filter on top of Min Strength.")
strongThr  = input.float(7.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
gTrade = "03 · Trade Levels"
atrLen     = input.int(14, "ATR Length", minval = 1, group = gTrade)
slBufAtr   = input.float(0.30, "Stop Buffer Beyond Coil (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gTrade, tooltip = "Stop sits beyond the coil extreme by this ATR cushion.")
maxRiskAtr = input.float(4.0, "Max Risk (ATR) — stop cap",  minval = 0.5, maxval = 12.0, step = 0.1, group = gTrade, tooltip = "Hard cap on stop distance so a structural stop never becomes a 'wide stop'.")
minRiskAtr = input.float(0.6, "Min Risk (ATR) — stop floor", minval = 0.1, maxval = 6.0,  step = 0.1, group = gTrade, tooltip = "Floor on stop distance so the 1R target never becomes a 'tight TP'.")
tp1R       = input.float(0.5,  "TP1 (R)", minval = 0.1, maxval = 50, step = 0.05, group = gTrade)
tp2R       = input.float(0.75, "TP2 (R)", minval = 0.1, maxval = 50, step = 0.05, group = gTrade)
tp3R       = input.float(1.25, "TP3 (R)", minval = 0.1, maxval = 50, step = 0.05, group = gTrade)
levelLen   = input.int(12, "Level Shelf (bars)", minval = 2, maxval = 500, group = gTrade, tooltip = "Forward shelf length for the live SL/TP labels. On close the ticket snaps back to the exit bar.")
maxZonePct = input.float(20.0, "Max Zone Width (% of trade span)", minval = 2, maxval = 100, step = 1, group = gTrade, tooltip = "Caps how far the SL/TP/Entry zones extend right, as a % of bars since entry. 100% = extend fully to the current bar.")
showLines    = input.bool(true, "Show SL / TP Lines", group = gTrade)
showBoxes    = input.bool(true, "Show SL / TP Zones", group = gTrade)
showLevelLbl = input.bool(true, "Label Level Prices", group = gTrade)
showExitLbl  = input.bool(true, "Show Trade Result Labels", group = gTrade)
maxHist      = input.int(30, "Max Historical Trades", minval = 1, maxval = 80, group = gTrade)
gFilt = "04 · Filters"
useHtf      = input.bool(true,  "HTF Trend Alignment (block counter-trend)", group = gFilt, tooltip = "Only LONG fires above the HTF EMA, only SHORT below it.")
htfTF       = input.timeframe("240", "HTF Timeframe", group = gFilt)
htfEmaLen   = input.int(50, "HTF EMA Length", minval = 5, maxval = 500, group = gFilt)
useCooldown = input.bool(true, "Use Signal Cooldown", group = gFilt)
cooldownBars= input.int(8, "Cooldown Bars", minval = 1, maxval = 500, group = gFilt, tooltip = "Minimum bars between consecutive fires.")
gVis = "05 · Visuals"
theme        = input.string("Emerald", "Color Theme", options = ["Emerald", "Ice Blue", "Gold Black", "Aqua Violet"], group = gVis)
showSignal   = input.bool(true, "Show Signal Labels", group = gVis)
showStars    = input.bool(true, "Show ★ Ranking On Labels", group = gVis)
showCoilZone = input.bool(true, "Show Compression (coil) Zone", group = gVis)
showZoneLbl  = input.bool(true, "Label Coil Zone (FIRE + score)", group = gVis)
showSqzTint  = input.bool(false, "Tint Background While Coiling", group = gVis)
showSqzDots  = input.bool(false, "Squeeze State Dots (bottom)", group = gVis)
lblSizeOpt   = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)
gBox = "06 · Zone Box Colors"
bullColor1 = input.color(#26a69a, "Bull · Low (4-6)",  group = gBox, inline = "bull")
bullColor2 = input.color(#00897b, "Mid (7-8)",         group = gBox, inline = "bull")
bullColor3 = input.color(#004d40, "High (9-10)",       group = gBox, inline = "bull")
bearColor1 = input.color(#b71c1c, "Bear · Low (4-6)",  group = gBox, inline = "bear")
bearColor2 = input.color(#880e4f, "Mid (7-8)",         group = gBox, inline = "bear")
bearColor3 = input.color(#4a148c, "High (9-10)",       group = gBox, inline = "bear")
bgTransp   = input.int(80, "Zone Fill Transparency", group = gBox, minval = 40, maxval = 96, tooltip = "Lower = more solid fill. The fill colour deepens automatically as the signal score rises.")
gDash = "07 · Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showHeatRow = input.bool(true, "Show Per-Target Breakdown", group = gDash)
longCol  = theme == "Ice Blue" ? color.rgb(0, 190, 255)  : theme == "Gold Black" ? color.rgb(255, 196, 48) : theme == "Aqua Violet" ? color.rgb(0, 230, 200) : color.rgb(0, 200, 120)
shortCol = theme == "Ice Blue" ? color.rgb(255, 120, 70) : theme == "Gold Black" ? color.rgb(255, 78, 60)  : theme == "Aqua Violet" ? color.rgb(180, 110, 255) : color.rgb(235, 64, 64)
coilCol  = theme == "Ice Blue" ? color.rgb(120, 170, 220): theme == "Gold Black" ? color.rgb(220, 200, 120): theme == "Aqua Violet" ? color.rgb(150, 160, 220): color.rgb(120, 200, 180)
f_zoneCol(bool bull, float sc) =>
    bull ? (sc >= 8.5 ? bullColor3 : sc >= 7 ? bullColor2 : bullColor1) : (sc >= 8.5 ? bearColor3 : sc >= 7 ? bearColor2 : bearColor1)
color panelBg     = #0a0c12
color panelBgAlt  = #0f131c
color panelHdr    = #161b27
color panelBorder = #2c3342
color txtHi       = #ebeef5
color txtLo       = #8791a2
color neutralCol  = #69748a
color goodCol     = #21c87a
color badCol      = #e6435a
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
float bbMid = ta.sma(close, lenBB)
float bbDev = multBB * ta.stdev(close, lenBB)
float kcMid = ta.sma(close, lenKC)
float kcDev = multKC * ta.sma(useTR ? ta.tr : high - low, lenKC)
bool compressed = (bbMid - bbDev > kcMid - kcDev) and (bbMid + bbDev < kcMid + kcDev)
bool expanded   = (bbMid - bbDev < kcMid - kcDev) and (bbMid + bbDev > kcMid + kcDev)
float compRatio = kcDev > 0 ? bbDev / kcDev : 1.0
float rangeMid = math.avg(ta.highest(high, lenKC), ta.lowest(low, lenKC))
float centre   = math.avg(rangeMid, kcMid)
float mom      = ta.linreg(close - centre, lenKC, 0)
bool  momRising = mom > nz(mom[1])
atr       = ta.atr(atrLen)
rsi       = ta.rsi(close, 14)
volSma    = ta.sma(volume, 20)
volRatio  = volSma > 0 ? volume / volSma : 1.0
candleRng = high - low
bodyRatio = candleRng > 0 ? math.abs(close - open) / candleRng : 0.5
atrRatio  = atr > 0 ? candleRng / atr : 0.0
bandWidth = 2 * bbDev
bbExpand  = ta.sma(bandWidth, 20) > 0 ? bandWidth / ta.sma(bandWidth, 20) : 1.0
absMomMax = ta.highest(math.abs(mom), 100)
htfEma = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLen)[1], lookahead = barmerge.lookahead_off)
var int   coilBars  = 0
var float coilHi    = na
var float coilLo    = na
var float coilTight = na
if compressed
    if not compressed[1]
        coilBars  := 1
        coilHi    := high
        coilLo    := low
        coilTight := compRatio
    else
        coilBars  += 1
        coilHi    := math.max(nz(coilHi, high), high)
        coilLo    := math.min(nz(coilLo, low), low)
        coilTight := math.min(nz(coilTight, compRatio), compRatio)
released = compressed[1] and not compressed
expandOk = not strictFire or expanded
fireRaw  = released and expandOk and coilBars[1] >= minCoil
int fireDir = mom > 0 ? 1 : mom < 0 ? -1 : (nz(mom[1]) >= 0 ? 1 : -1)
f_squeeze_strength(int coil, float tight, float momNorm, float accelNorm, float volR, float bdy, float atrR, float bbExp, bool htfAlign, bool rsiOk) =>
    s = 0.0
    s += coil >= 30 ? 2.0 : coil >= 20 ? 1.6 : coil >= 12 ? 1.2 : coil >= 7 ? 0.8 : coil >= 4 ? 0.4 : 0.0
    s += tight <= 0.50 ? 1.0 : tight <= 0.65 ? 0.7 : tight <= 0.80 ? 0.4 : 0.1
    s += momNorm >= 0.80 ? 1.5 : momNorm >= 0.60 ? 1.1 : momNorm >= 0.40 ? 0.8 : momNorm >= 0.20 ? 0.4 : 0.1
    s += accelNorm >= 0.50 ? 1.5 : accelNorm >= 0.25 ? 1.0 : accelNorm >= 0.05 ? 0.5 : accelNorm >= -0.05 ? 0.2 : -0.4
    s += volR >= 2.5 ? 1.5 : volR >= 2.0 ? 1.1 : volR >= 1.5 ? 0.7 : volR >= 1.3 ? 0.4 : 0.0
    s += (bdy >= 0.70 and atrR >= 1.5) ? 1.0 : (bdy >= 0.55 or atrR >= 1.2) ? 0.6 : 0.2
    s += bbExp >= 1.5 ? 1.0 : bbExp >= 1.2 ? 0.6 : bbExp >= 1.0 ? 0.3 : 0.0
    s += htfAlign ? 0.5 : 0.0
    s += rsiOk ? 0.5 : 0.0
    math.max(0.0, math.min(10.0, math.round(s * 10) / 10))
bool isBullFire = fireDir == 1
float momNorm   = absMomMax > 0 ? math.abs(mom) / absMomMax : 0.0
float accelSign = isBullFire ? (mom - nz(mom[1])) : (nz(mom[1]) - mom)
float accelNorm = absMomMax > 0 ? accelSign / absMomMax : 0.0
bool  htfAlign  = not useHtf or na(htfEma) or (isBullFire ? close > htfEma : close < htfEma)
bool  rsiOk     = isBullFire ? rsi >= 52 : rsi <= 48
float fireScore = fireRaw ? f_squeeze_strength(coilBars[1], nz(coilTight, compRatio), momNorm, accelNorm, volRatio, bodyRatio, atrRatio, bbExpand, htfAlign, rsiOk) : 0.0
var bool  tradeActive = false
var int   tradeSide   = 0
var int   tradeBar    = na
var float tEntry      = na
var float tStop       = na
var float tTp1        = na
var float tTp2        = na
var float tTp3        = na
var int   bestStage   = 0
var float tradeScore  = na
var int   lastSigBar  = na
var int   lastSigSide = 0
cooldownOk = not useCooldown or na(lastSigBar) or (bar_index - lastSigBar >= cooldownBars)
passStr = fireScore >= minStr and (not onlyStrong or fireScore >= strongThr)
okFire  = fireRaw and passStr and htfAlign and cooldownOk and not tradeActive and not na(atr)
sigLong  = okFire and isBullFire
sigShort = okFire and not isBullFire
var line  aEntry = na
var line  aSl    = na
var line  aT1    = na
var line  aT2    = na
var line  aT3    = na
var box   aTpBox = na
var box   aSlBox = na
var box   aZone  = na
var label aSig   = na
var label aLEntry= na
var label aLSl   = na
var label aLT1   = na
var label aLT2   = na
var label aLT3   = na
var label aZlbl  = na
var label aExit  = na
type tradeViz
    line  e  = na
    line  s  = na
    line  t1 = na
    line  t2 = na
    line  t3 = na
    box   tb = na
    box   sb = na
    box   zb = na
    label sg = na
    label le = na
    label ls = na
    label l1 = na
    label l2 = na
    label l3 = na
    label zl = na
    label ex = na
var array<tradeViz> history = array.new<tradeViz>()
var int   sClosed   = 0
var int   sTp1      = 0
var int   sTp2      = 0
var int   sTp3      = 0
var int   sSl       = 0
var int   sWins     = 0
var float sR        = 0.0
var float sGrossWin = 0.0
var float sGrossLos = 0.0
var int   sMaxWin   = 0
var int   sMaxLos   = 0
var int   sCurWin   = 0
var int   sCurLos   = 0
var int   sStreak   = 0
var int   sLong     = 0
var int   sLongWin  = 0
var int   sShort    = 0
var int   sShortWin = 0
var int   sTotalSig = 0
int _liveSpan = tradeActive and not na(tradeBar) ? bar_index - tradeBar : 0
int _liveCap  = int(math.round(_liveSpan * maxZonePct / 100))
aRight = tradeActive and not na(tradeBar) ? tradeBar + math.max(levelLen, _liveCap) : na
if tradeActive
    if showLines
        if not na(aEntry)
            line.set_x2(aEntry, aRight)
        if not na(aSl)
            line.set_x2(aSl, aRight)
        if not na(aT1)
            line.set_x2(aT1, aRight)
        if not na(aT2)
            line.set_x2(aT2, aRight)
        if not na(aT3)
            line.set_x2(aT3, aRight)
        if showLevelLbl
            if not na(aLEntry)
                label.set_x(aLEntry, aRight)
            if not na(aLSl)
                label.set_x(aLSl, aRight)
            if not na(aLT1)
                label.set_x(aLT1, aRight)
            if not na(aLT2)
                label.set_x(aLT2, aRight)
            if not na(aLT3)
                label.set_x(aLT3, aRight)
    if showBoxes
        if not na(aTpBox)
            box.set_right(aTpBox, aRight)
        if not na(aSlBox)
            box.set_right(aSlBox, aRight)
    if showCoilZone and not na(aZone)
        box.set_right(aZone, aRight)
closedTp3 = false
closedSl  = false
closedTp  = false
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
    if finalTp3 or finalSl or finalTp
        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        float resR = finalTp3 ? tp3R : finalTp and bestStage == 2 ? tp2R : finalTp and bestStage == 1 ? tp1R : -1.0
        bool isWin = resR > 0
        sClosed += 1
        sR      += resR
        if isWin
            sWins   += 1
            sGrossWin += resR
            sCurWin += 1
            sCurLos := 0
            sMaxWin := math.max(sMaxWin, sCurWin)
            sStreak := sCurWin
        else
            sGrossLos += 1.0
            sCurLos += 1
            sCurWin := 0
            sMaxLos := math.max(sMaxLos, sCurLos)
            sStreak := -sCurLos
        if tradeSide == 1
            sLong += 1
            sLongWin += isWin ? 1 : 0
        else
            sShort += 1
            sShortWin += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
        else if finalTp and bestStage == 2
            sTp2 += 1
        else if finalTp and bestStage == 1
            sTp1 += 1
        else if finalSl
            sSl += 1
        int _clSpan   = not na(tradeBar) ? bar_index - tradeBar : 0
        int _clCap    = int(math.round(_clSpan * maxZonePct / 100))
        int closeEdge = tradeBar + math.max(3, _clCap)
        if showLines
            if not na(aEntry)
                line.set_x2(aEntry, closeEdge)
            if not na(aSl)
                line.set_x2(aSl, closeEdge)
            if not na(aT1)
                line.set_x2(aT1, closeEdge)
            if not na(aT2)
                line.set_x2(aT2, closeEdge)
            if not na(aT3)
                line.set_x2(aT3, closeEdge)
        if showBoxes
            if not na(aTpBox)
                box.set_right(aTpBox, closeEdge)
            if not na(aSlBox)
                box.set_right(aSlBox, closeEdge)
        if showCoilZone and not na(aZone)
            box.set_right(aZone, closeEdge)
        if showLevelLbl
            if not na(aLEntry)
                label.set_x(aLEntry, closeEdge)
            if not na(aLSl)
                label.set_x(aLSl, closeEdge)
            if not na(aLT1)
                label.set_x(aLT1, closeEdge)
            if not na(aLT2)
                label.set_x(aLT2, closeEdge)
            if not na(aLT3)
                label.set_x(aLT3, closeEdge)
        int    rStage   = finalTp3 ? 3 : finalTp ? bestStage : 0
        float  resPrice = finalTp3 ? tTp3 : finalTp and rStage == 2 ? tTp2 : finalTp and rStage == 1 ? tTp1 : tStop
        string resTxt   = finalTp3 ? "TP3 ✔ WIN " + f_signedR(resR) : finalTp ? "TP" + str.tostring(rStage) + " ✔ WIN " + f_signedR(resR) : "SL ✘ LOSS -1R"
        color  resCol   = resR >= 0 ? longCol : shortCol
        string resStyle = tradeSide == 1 ? (resR >= 0 ? label.style_label_down : label.style_label_up) : (resR >= 0 ? label.style_label_up : label.style_label_down)
        if showExitLbl
            aExit := label.new(closeEdge, resPrice, resTxt, style = resStyle, color = color.new(resCol, 0), textcolor = color.white, size = size.small)
        tradeViz tv = tradeViz.new(aEntry, aSl, aT1, aT2, aT3, aTpBox, aSlBox, aZone, aSig, aLEntry, aLSl, aLT1, aLT2, aLT3, aZlbl, aExit)
        array.push(history, tv)
        while array.size(history) > maxHist
            tradeViz old = array.shift(history)
            line.delete(old.e)
            line.delete(old.s)
            line.delete(old.t1)
            line.delete(old.t2)
            line.delete(old.t3)
            box.delete(old.tb)
            box.delete(old.sb)
            box.delete(old.zb)
            label.delete(old.sg)
            label.delete(old.le)
            label.delete(old.ls)
            label.delete(old.l1)
            label.delete(old.l2)
            label.delete(old.l3)
            label.delete(old.zl)
            label.delete(old.ex)
        aEntry := na
        aSl := na
        aT1 := na
        aT2 := na
        aT3 := na
        aTpBox := na
        aSlBox := na
        aZone := na
        aSig := na
        aLEntry := na
        aLSl := na
        aLT1 := na
        aLT2 := na
        aLT3 := na
        aZlbl := na
        aExit := na
        tradeActive := false
        tradeSide   := 0
        tradeBar    := na
        tEntry := na
        tStop := na
        tTp1 := na
        tTp2 := na
        tTp3 := na
        bestStage := 0
takeSig = (sigLong or sigShort) and not tradeActive and not closedTp3 and not closedSl and not closedTp
if takeSig
    bool  isLong  = sigLong
    int   side    = isLong ? 1 : -1
    float sc      = fireScore
    int   coilN   = coilBars[1]
    int   zStart  = bar_index - math.max(1, coilN)
    float cHi     = nz(coilHi, high)
    float cLo     = nz(coilLo, low)
    float entv    = close
    float rawStop = isLong ? cLo - atr * slBufAtr : cHi + atr * slBufAtr
    float risk0   = math.abs(entv - rawStop)
    float maxR    = atr * maxRiskAtr
    float minR    = atr * minRiskAtr
    float risk    = math.min(math.max(risk0, minR), maxR)
    float stopv   = isLong ? entv - risk : entv + risk
    float t1      = isLong ? entv + risk * tp1R : entv - risk * tp1R
    float t2      = isLong ? entv + risk * tp2R : entv - risk * tp2R
    float t3      = isLong ? entv + risk * tp3R : entv - risk * tp3R
    tradeActive := true
    tradeSide   := side
    tradeBar    := bar_index
    tEntry      := entv
    tStop       := stopv
    tTp1        := t1
    tTp2        := t2
    tTp3        := t3
    bestStage   := 0
    tradeScore  := sc
    lastSigBar  := bar_index
    lastSigSide := side
    sTotalSig   += 1
    color c   = isLong ? longCol : shortCol
    int   xr  = bar_index + levelLen
    bool  isElite = sc >= 8.5
    if showCoilZone
        color zc = f_zoneCol(isLong, sc)
        aZone := box.new(zStart, cHi, xr, cLo, xloc = xloc.bar_index, bgcolor = color.new(zc, bgTransp), border_color = color.new(zc, 30), border_width = 1)
        if showZoneLbl
            string zt = "FIRE  " + f_stars(sc) + " " + str.tostring(math.round(sc * 10) / 10) + "/10  · coil " + str.tostring(coilN)
            aZlbl := label.new(math.round((zStart + bar_index) / 2), (cHi + cLo) / 2, zt, xloc = xloc.bar_index, style = label.style_label_center, color = color.new(zc, 100), textcolor = color.white, size = f_size(lblSizeOpt), textalign = text.align_center)
    if showSignal
        string head = (isLong ? "STRONG LONG FIRE" : "STRONG SHORT FIRE") + (isElite ? "  ⚡ELITE" : "")
        string txt  = showStars ? head + "\n" + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_tier(sc) : head
        aSig := label.new(bar_index, isLong ? low : high, txt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 6), textcolor = color.white, size = f_size(lblSizeOpt))
    if showBoxes
        float tpTop = isLong ? t3 : entv
        float tpBot = isLong ? entv : t3
        float slTop = isLong ? entv : stopv
        float slBot = isLong ? stopv : entv
        color tpC = f_zoneCol(isLong, sc)
        color slC = bearColor1
        int   boxFillT = int(math.min(95, bgTransp + 8))
        aTpBox := box.new(bar_index, tpTop, xr, tpBot, xloc = xloc.bar_index, bgcolor = color.new(tpC, boxFillT), border_color = color.new(tpC, 40), border_width = 1)
        aSlBox := box.new(bar_index, slTop, xr, slBot, xloc = xloc.bar_index, bgcolor = color.new(slC, boxFillT), border_color = color.new(slC, 45), border_width = 1)
    if showLines
        aEntry := line.new(bar_index, entv,  xr, entv,  xloc = xloc.bar_index, color = color.new(c, 0),  width = 2, style = line.style_solid)
        aSl    := line.new(bar_index, stopv, xr, stopv, xloc = xloc.bar_index, color = color.new(shortCol, 10), width = 1, style = line.style_dashed)
        aT1    := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(c, 12), width = 1, style = line.style_solid)
        aT2    := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(c, 30), width = 1, style = line.style_solid)
        aT3    := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(c, 48), width = 1, style = line.style_solid)
        if showLevelLbl
            string dw = isLong ? "LONG" : "SHORT"
            aLEntry := label.new(xr, entv,  dw + " @ " + str.tostring(entv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 0), textcolor = color.white, size = f_size(lblSizeOpt))
            aLSl    := label.new(xr, stopv, "SL @ " + str.tostring(stopv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT1    := label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.##") + "R @ " + str.tostring(t1, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT2    := label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.##") + "R @ " + str.tostring(t2, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 26), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT3    := label.new(xr, t3, "TP3 " + str.tostring(tp3R, "#.##") + "R @ " + str.tostring(t3, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 42), textcolor = color.white, size = f_size(lblSizeOpt))
color tintCol = compressed ? color.new(coilCol, 92) : na
bgcolor(showSqzTint ? tintCol : na, title = "Squeeze Tint")
color dotCol = compressed ? color.new(neutralCol, 0) : expanded ? color.new(coilCol, 30) : color.new(longCol, 20)
plotshape(showSqzDots, title = "Squeeze State", style = shape.circle, location = location.bottom, color = dotCol, size = size.tiny)
winRate = sClosed > 0 ? sWins / sClosed * 100.0 : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGrossLos > 0 ? sGrossWin / sGrossLos : sGrossWin > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? sLongWin  / sLong  * 100.0 : 0.0
shortWR = sShort > 0 ? sShortWin / sShort * 100.0 : 0.0
tp1Rate = sClosed > 0 ? sTp1 / sClosed * 100.0 : 0.0
tp2Rate = sClosed > 0 ? sTp2 / sClosed * 100.0 : 0.0
tp3Rate = sClosed > 0 ? sTp3 / sClosed * 100.0 : 0.0
slRate  = sClosed > 0 ? sSl  / sClosed * 100.0 : 0.0
bestDir = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
streakTxt = sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—"
pfTxt = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")
sqzStateTxt = compressed ? "ON · COILING" : released ? "FIRED" : expanded ? "OFF · EXPANDED" : "NO SQZ"
color sqzStateC = compressed ? color.rgb(230, 190, 70) : released ? longCol : expanded ? neutralCol : color.rgb(120, 170, 255)
coilTxt = str.tostring(compressed ? coilBars : coilBars[1])
momTxt  = (momRising ? "▲ " : "▼ ") + str.tostring(mom, "#.###")
color momC = mom > 0 ? (momRising ? longCol : color.new(longCol, 45)) : (momRising ? color.new(shortCol, 45) : shortCol)
statusTxt = tradeActive ? "TRADE ACTIVE" : "WAITING"
activeTxt = tradeActive ? (tradeSide == 1 ? "LONG" : "SHORT") : "—"
lastTxt   = lastSigSide == 1 ? "LONG" : lastSigSide == -1 ? "SHORT" : "—"
lastScoreTxt = na(tradeScore) ? "—" : f_stars(tradeScore) + " " + str.tostring(math.round(tradeScore * 10) / 10) + "/10"
color statusC = tradeActive ? longCol : neutralCol
color wrC     = winRate >= 55 ? goodCol : winRate >= 45 ? color.rgb(230, 190, 70) : badCol
color pfC     = pf >= 1.5 ? goodCol : pf >= 1.0 ? color.rgb(230, 190, 70) : badCol
var int dashRows = 16
var table dash = table.new(f_pos(dashPosOpt), 2, dashRows, frame_color = color.new(panelBorder, 0), frame_width = 1, border_width = 1, border_color = color.new(panelBorder, 30))
if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 1, dashRows - 1)
    table.cell(dash, 0, 0, "STRONG SQUEEZE", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
    table.cell(dash, 1, 0, "SIGNALS", text_color = longCol, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    table.cell(dash, 0, 1, "Squeeze State", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 1, sqzStateTxt, text_color = sqzStateC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 2, "Coil Bars", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 2, coilTxt, text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 3, "Momentum", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 3, momTxt, text_color = momC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 4, "Status", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 4, statusTxt, text_color = statusC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 5, "Active Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 5, activeTxt, text_color = tradeSide == 1 ? longCol : tradeSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 6, "Last Signal", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 6, lastTxt + "  " + lastScoreTxt, text_color = lastSigSide == 1 ? longCol : lastSigSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 7, "Total Signals", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 7, str.tostring(sTotalSig), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 8, "Win Rate", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 8, str.tostring(winRate, "#.#") + "%", text_color = wrC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 9, "Closed Trades", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 9, str.tostring(sClosed), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 10, "Profit Factor", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 10, pfTxt, text_color = pfC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 11, "Avg R / Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 11, f_signedR(avgR), text_color = avgR >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 12, "Best Direction", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 12, bestDir, text_color = bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 0, 13, "L / S Win%", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 13, str.tostring(longWR, "#.#") + " / " + str.tostring(shortWR, "#.#"), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 0, 14, "Streak", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 14, streakTxt + "  (max W" + str.tostring(sMaxWin) + "/L" + str.tostring(sMaxLos) + ")", text_color = sStreak >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    if showHeatRow
        table.cell(dash, 0, 15, "TP1/2/3 · SL", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, 15, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + " · " + str.tostring(slRate, "#") + "%", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    else
        table.cell(dash, 0, 15, "", bgcolor = panelHdr)
        table.cell(dash, 1, 15, "", bgcolor = panelHdr)
newSqueeze = compressed and not compressed[1]
alertcondition(sigLong,   "Strong Long Squeeze Fire",  "Strong Squeeze Signals: STRONG LONG fire on {{ticker}} {{interval}}.")
alertcondition(sigShort,  "Strong Short Squeeze Fire", "Strong Squeeze Signals: STRONG SHORT fire on {{ticker}} {{interval}}.")
alertcondition(newSqueeze,"Squeeze On (new coil)",     "Strong Squeeze Signals: squeeze ON (coil forming) on {{ticker}} {{interval}}.")
alertcondition(released,  "Squeeze Released",          "Strong Squeeze Signals: squeeze released on {{ticker}} {{interval}}.")
alertcondition(closedTp3, "TP3 Hit",                   "Strong Squeeze Signals: TP3 hit on {{ticker}} {{interval}}.")
alertcondition(closedTp,  "Partial TP Exit",           "Strong Squeeze Signals: protected TP exit on {{ticker}} {{interval}}.")
alertcondition(closedSl,  "SL Hit",                    "Strong Squeeze Signals: SL hit on {{ticker}} {{interval}}.")
````
