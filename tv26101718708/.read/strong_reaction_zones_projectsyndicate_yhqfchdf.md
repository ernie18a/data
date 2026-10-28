# Strong Reaction Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/YhqfCHDF-Strong-Reaction-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;3721234e5cb046f8a69ac882347168f3
- version: 1.0

## Description

[b]Strong Reaction Zones maps how far price has stretched from session balance and power-ranks the zones where it is most likely to snap back. Every session it anchors a Balance Zone — the auction center the day trades around — and projects escalating reaction tiers above and below it: Low, Normal, High, Very High and Extreme, drawn as clean equal-height shaded zones. Each tier is scored 0–10 for reaction strength, so you instantly see which stretch is most likely to reject price back toward balance and which is just trend doing its job. The whole tool runs on one idea from auction theory: the further price travels from the Balance Zone, the heavier the pull back to it — and the Extreme tier is where that reversion tends to be sharpest.[/b]

🎯 Reaction-Strength Power-Ranking (0–10) — every tier earns a live grade from four principled factors, each with a fixed directional sign: Tier Extremity (distance from the Balance Zone — the primary driver, since outer stretches mean-revert harder), Volatility Context (a compressed session vs its ADR baseline makes the outer tiers genuine extremes; an expanding session de-rates them), Range Regime (an efficiency-ratio read — choppy / mean-reverting conditions favor reactions, strong trends suppress them), and Trend Alignment (with-trend zones — support in an uptrend, resistance in a downtrend — react more reliably). All four weights and their lookbacks are adjustable. The score is a descriptive auction-logic framework for ranking which zone deserves attention — not a backtested signal.

🏷️ In-Zone Strength Labels — each zone carries its grade inside the band: the tier name with a ▲ / ▼ side marker, stars, the X.X/10 score, and a tier word (FORMING → WEAK → MODERATE → STRONG → ELITE). Quality reads instantly without a separate panel.

🧲 The Balance Zone (auction center) — the gravitational center each session auctions around, plotted from the prior session's OHLC4 by default (HLC3, Mid, or a non-repainting Daily SMA optional). It is the magnet every reaction targets — the destination of a reversion from any extreme, and the primary take-profit reference for a fade.

📊 Five Escalating Reaction Tiers — Low, Normal, High, Very High and Extreme, mirrored above (resistance) and below (support) the Balance Zone. Spacing is ADR-scaled so the ladder adapts to each instrument's volatility, with a global width multiplier and per-tier offsets if you want to reshape the geometry. The Extreme tier marks the outer edge of the session's expected auction — the highest-conviction fade-and-revert zone.

⚙️ Uniform ATR Zone Height — every tier and the Balance Zone share one identical ADR-based thickness, centered on its level, for a clean, consistent look on any symbol or timeframe.

🎨 Strength-Shaded Fill — stronger zones render more opaque while weak ones stay faint, so the chart shows which extremes carry weight before you read a number. Resistance tiers shade green, support tiers maroon, and the Balance Zone a neutral gray.

🧹 Score Filter & Tier Toggles — hide every zone below a score threshold, or switch individual tiers on and off, so the chart only carries the levels that earned their place.

🔒 Non-Repainting — each session's Balance Zone, tiers and scores lock in from the completed prior session and never change intraday. Zones span exactly one session and close cleanly at the day boundary — no bleed into the next session. The last N sessions are kept (default 10) and older ones are removed automatically.

🔔 Native Alerts — a touch alert for any reaction zone, a touch alert for a STRONG zone (≥ your threshold, default 7/10), and a dedicated alert the moment price reaches an EXTREME tier — the highest-conviction reversion trigger.

🔧 Fully Customizable — Balance-Zone source, ADR length, global width multiplier and per-tier offsets, zone thickness, the four scoring weights and their regime / volatility lookbacks, the score filter, label text / size / visibility, colors, transparency and the strength-opacity span — all adjustable.

🎯 Why this is different — most band and envelope tools draw static lines and leave you guessing which edge matters. Strong Reaction Zones frames the session as an auction around a Balance center and tells you, tier by tier, how strong the snap-back from each stretch should be — so an ELITE Extreme zone is a fade-to-balance trade, while a de-rated zone in a trending regime is a warning that price may keep running. You read the destination (balance) and the conviction (the score) at a glance.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto and Indices on any intraday timeframe.

🎯 How To Trade It — Two Approaches

Everything hinges on the question the score answers: is this stretch likely to revert to balance, or keep extending? High-rated outer zones in a ranging / compressed regime favor reversion; de-rated zones in a trending / expanding regime favor continuation.

◾ 1) Reversion from Extreme → Balance Zone (fade the stretch) — use on STRONG / ELITE outer tiers (≥7), especially High / Very High / Extreme
This is the indicator's core thesis. When price pushes out to a High, Very High or Extreme reaction zone rated STRONG or ELITE — most reliable when the Range Regime read is low (choppy) and Volatility Context is high (compressed) — the auction is statistically over-extended and the pull is back toward the Balance Zone.

▪️ Wait for price to tag the rated outer zone and print rejection — a wick or reversal candle back inside the tier rather than a decisive close beyond it.
▪️ Entry: on the reversal back inside the zone, facing the Balance Zone.
▪️ Stop: just beyond the next tier out (fading Very High → stop beyond Extreme). If price pushes through the outer tier and holds, the over-extension thesis is wrong — stand aside or flip to Approach 2.
▪️ Targets: step in toward balance — the next inner tier first, then the Balance Zone as the primary magnet, and the opposite-side inner tier if momentum carries through.

⚖️ The cleanest version of the trade: price spikes into the Extreme zone, fails to hold, and rotates back down through Very High → High → Normal → into the Balance Zone. That full reversion from the extreme to balance is the move this tool is built to frame. Use the Touch EXTREME / Touch STRONG alerts to catch the stretch the moment it prints.

◾ 2) Expansion / Trend Break → Trade With the Move — use when the outer tiers are de-rated or the regime is trending
When the score de-rates the outer tiers — a high efficiency ratio (strong trend), an expanding session (Volatility Context low), or the trend side carrying lower grades against the move — reversion is the wrong bet. A clean break and hold beyond the outer tier is the auction expanding, not exhausting.

▪️ Wait for a decisive close beyond the High / Very High / Extreme tier on expansion (not a single wick), with the zone failing to reject.
▪️ Entry: in the direction of the break, on the close beyond the tier or on a retest of the broken zone.
▪️ Stop: back inside the broken tier, toward the Balance Zone.
▪️ Targets: the next session's range / measured move, trailing as the move extends. A broken upper tier often flips to support; a broken lower tier flips to resistance, and the old zone becomes the retest entry.

Rule of thumb: ⭐ STRONG / ELITE outer tier in a ranging / compressed regime → expect a reaction, fade it back to the Balance Zone. ⭐ De-rated tier on expansion or in a trend → expect follow-through, trade the break.

⚠️ IMPORTANT NOTICE: Strong Reaction Zones frames how far price has stretched from session balance and ranks where reversion is most likely. The 0–10 score is a descriptive, auction-logic framework, not a backtested signal, and it should NOT be used as a standalone trade trigger. Always combine it with your own strategy, price-action analysis and risk management to confirm setups. Past behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Reaction Zones", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

grpS       = "Session / Plotting"
tf         = input.timeframe("D", "Zone Timeframe (session)", group=grpS, tooltip="Each new bar of this timeframe opens a fresh set of reaction zones. 'D' = daily zones.")
daysStr    = input.string("10", "Sessions of Zones to Keep", options=["1","2","3","4","5","6","10"], group=grpS, tooltip="How many recent completed sessions keep their zones drawn. Older sessions are removed.")
maxDays    = int(str.tonumber(daysStr))
extendBars = input.int(0, "Extend Latest Session (bars)", minval=0, maxval=200, group=grpS)

grpF   = "Balance Zone (auction center)"
bzSrc  = input.string("Prior Session OHLC4", "Balance Zone Source", options=["Prior Session OHLC4","Prior Session HLC3","Prior Session Mid","Daily SMA"], group=grpF, tooltip="The center the day auctions around. OHLC4/HLC3/Mid use the prior completed session; Daily SMA uses a non-repainting daily average.")
smaLen = input.int(20, "Daily SMA Length", minval=1, maxval=400, group=grpF, tooltip="Used only when Balance Zone Source = Daily SMA.")
showBZ = input.bool(true, "Show Balance Zone", group=grpF)

grpB   = "Reaction Bands (auction tiers)"
adrLen = input.int(14, "ADR Length (sessions)", minval=2, maxval=200, group=grpB, tooltip="Average session range — sizes every band and acts as the volatility baseline.")
gMult  = input.float(1.0, "Global Width Multiplier", minval=0.05, maxval=10.0, step=0.05, group=grpB)
zoneHt = input.float(0.05, "Zone Thickness (× ADR)", minval=0.01, maxval=2.0, step=0.01, group=grpB, tooltip="Thickness of each shaded band, centered on its tier level.")
oLow   = input.float(0.10, "Tier 1 · Low offset (× ADR)",        minval=0.0, step=0.02, group=grpB)
oNorm  = input.float(0.22, "Tier 2 · Normal offset (× ADR)",     minval=0.0, step=0.02, group=grpB)
oHigh  = input.float(0.36, "Tier 3 · High offset (× ADR)",       minval=0.0, step=0.02, group=grpB)
oVHigh = input.float(0.52, "Tier 4 · Very High offset (× ADR)",  minval=0.0, step=0.02, group=grpB)
oExt   = input.float(0.70, "Tier 5 · Extreme offset (× ADR)",    minval=0.0, step=0.02, group=grpB)
shLow  = input.bool(true,  "Show Tier 1 · Low",       group=grpB)
shNorm = input.bool(true,  "Show Tier 2 · Normal",    group=grpB)
shHigh = input.bool(true,  "Show Tier 3 · High",      group=grpB)
shVHigh= input.bool(true,  "Show Tier 4 · Very High", group=grpB)
shExt  = input.bool(true,  "Show Tier 5 · Extreme",   group=grpB)

grpR     = "Reaction Strength (0–10)"
wE       = input.float(0.40, "Weight: Tier Extremity",     minval=0, maxval=1, step=0.05, group=grpR, tooltip="Further from the balance zone = stronger expected mean-reversion. Primary driver.")
wV       = input.float(0.20, "Weight: Volatility Context", minval=0, maxval=1, step=0.05, group=grpR, tooltip="Compressed volatility vs the ADR baseline makes outer zones genuine extremes (stronger). Expansion weakens them.")
wR       = input.float(0.25, "Weight: Range Regime",       minval=0, maxval=1, step=0.05, group=grpR, tooltip="Choppy / mean-reverting regime (low efficiency ratio) favors reactions. Strong trends weaken them.")
wD       = input.float(0.15, "Weight: Trend Alignment",    minval=0, maxval=1, step=0.05, group=grpR, tooltip="With-trend zones (support in an uptrend, resistance in a downtrend) react more reliably.")
erLen    = input.int(10, "Regime / Trend Lookback (sessions)", minval=3, maxval=60, group=grpR)
volShort = input.int(3,  "Volatility Window (sessions)",       minval=1, maxval=30, group=grpR)
strongTh = input.float(7.0, "Strong-zone Alert Threshold", minval=3.0, maxval=10.0, step=0.5, group=grpR)
minScore = input.float(0.0, "Hide Zones Below Score", minval=0.0, maxval=10.0, step=0.5, group=grpR)

grpL       = "Labels"
showLabels = input.bool(true, "Show Labels", group=grpL)
latestOnly = input.bool(false, "Labels on Latest Session Only", group=grpL, tooltip="Off = every kept session is labeled (default). On = only the newest session is annotated.")
showStars  = input.bool(true, "Show Stars & Tier", group=grpL)
labelSz    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grpL)

grpC         = "Colors"
upColor      = input.color(#0D5447, "Upper (resistance) Zone", group=grpC)
bzColor      = input.color(#787878, "Balance Zone",            group=grpC)
loColor      = input.color(#6E1E28, "Lower (support) Zone",    group=grpC)
txtColor     = input.color(#CFCFCF, "Label Text",              group=grpC)
baseTransp   = input.int(58, "Weakest-zone Transparency", minval=30, maxval=96, group=grpC)
strSpan      = input.int(30, "Strength Opacity Span",     minval=0,  maxval=50, group=grpC, tooltip="How much opacity stronger zones gain over weaker ones.")
bzTransp     = input.int(72, "Balance Zone Transparency", minval=40, maxval=96, group=grpC)
showBorder   = input.bool(false, "Show Zone Borders", group=grpC)
borderCol    = input.color(#9A9A9A, "Border Color", group=grpC)
borderTransp = input.int(60, "Border Transparency", minval=0, maxval=95, group=grpC)

f_size()   => labelSz=="tiny" ? size.tiny : labelSz=="small" ? size.small : labelSz=="large" ? size.large : size.normal
f_stars(s) => s>=8 ? "★★★★" : s>=6.5 ? "★★★" : s>=5 ? "★★" : s>=3 ? "★" : "·"
f_tier(s)  => s>=8 ? "ELITE" : s>=6.5 ? "STRONG" : s>=5 ? "MODERATE" : s>=3 ? "WEAK" : "FORMING"

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

f_dirBias(int trendSign, bool isUpper) =>
    trendSign == 0 ? 0.6 : isUpper ? (trendSign < 0 ? 1.0 : 0.35) : (trendSign > 0 ? 1.0 : 0.35)

f_score(float extremity, float volRatio, float er, float dirBias) =>
    E   = math.min(math.max(extremity, 0.0), 1.0)
    V   = math.min(math.max(1.0 - math.max(volRatio - 1.0, 0.0), 0.0), 1.0)
    R   = math.min(math.max(1.0 - er, 0.0), 1.0)
    D   = math.min(math.max(dirBias, 0.0), 1.0)
    wT  = wE + wV + wR + wD
    raw = wT > 0 ? (wE*E + wV*V + wR*R + wD*D)/wT : 0.0
    math.round(math.min(math.max(raw, 0.0), 1.0) * 100.0) / 10.0

f_transp(float sc) =>
    t = baseTransp - (sc/10.0)*strSpan
    math.round(math.max(math.min(t, 96.0), 30.0))

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

var array<float>   rngHist   = array.new<float>()
var array<float>   closeHist = array.new<float>()
var array<DayDraw> drawDays  = array.new<DayDraw>()
var DayDraw        curDay    = na
var int            curLeft   = na

var array<float> curTop     = array.new<float>()
var array<float> curBot     = array.new<float>()
var array<float> curScore   = array.new<float>()
var array<bool>  curExtreme = array.new<bool>()

var float dOpen = na
var float dHigh = na
var float dLow  = na

smaD = request.security(syminfo.tickerid, "D", ta.sma(close, smaLen)[1], lookahead=barmerge.lookahead_on)

newDay = ta.change(time(tf)) != 0

if newDay
    boundaryBar = bar_index
    prevEnd     = bar_index - 1

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
    valid = not na(prevO) and not na(prevH) and not na(prevL) and prevH > prevL and not na(prevC)

    if valid
        rng = prevH - prevL
        array.unshift(rngHist, rng)
        if array.size(rngHist) > 200
            array.pop(rngHist)
        array.unshift(closeHist, prevC)
        if array.size(closeHist) > 200
            array.pop(closeHist)

        adr      = f_avg(rngHist, adrLen)
        adrBase  = na(adr) or adr <= 0 ? rng : adr
        recATR0  = f_avg(rngHist, volShort)
        recATR   = na(recATR0) or recATR0 <= 0 ? adrBase : recATR0
        volRatio = adrBase > 0 ? recATR/adrBase : 1.0
        er       = f_efficiency(closeHist, erLen)

        trendSign = 0
        if array.size(closeHist) > 1
            idx  = math.min(erLen, array.size(closeHist)-1)
            oldC = array.get(closeHist, idx)
            thr  = adrBase * 0.5
            trendSign := prevC > oldC + thr ? 1 : prevC < oldC - thr ? -1 : 0

        float bz = na
        if bzSrc == "Prior Session OHLC4"
            bz := (prevO + prevH + prevL + prevC) / 4.0
        else if bzSrc == "Prior Session HLC3"
            bz := (prevH + prevL + prevC) / 3.0
        else if bzSrc == "Prior Session Mid"
            bz := (prevH + prevL) / 2.0
        else
            bz := smaD
        if na(bz)
            bz := (prevH + prevL + prevC) / 3.0

        half = adrBase * zoneHt / 2.0

        curDay  := DayDraw.new(array.new<box>(), array.new<label>())
        curLeft := boundaryBar
        array.clear(curTop)
        array.clear(curBot)
        array.clear(curScore)
        array.clear(curExtreme)

        if showBZ
            bBZ = box.new(boundaryBar, bz+half, boundaryBar, bz-half, border_color=showBorder ? color.new(borderCol, borderTransp) : color.new(color.gray,100), border_width=showBorder ? 1 : 0, bgcolor=color.new(bzColor, bzTransp))
            array.push(curDay.boxes, bBZ)
            if showLabels
                lBZ = label.new(boundaryBar, bz, "BALANCE ZONE", xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                array.push(curDay.labels, lBZ)

        offs   = array.from(oLow,  oNorm,  oHigh,  oVHigh,  oExt)
        shows  = array.from(shLow, shNorm, shHigh, shVHigh, shExt)
        tnames = array.from("LOW", "NORMAL", "HIGH", "VERY HIGH", "EXTREME")

        for ti = 0 to 4
            if array.get(shows, ti)
                off       = array.get(offs, ti) * gMult
                extremity = (ti + 1) / 5.0
                isExt     = ti == 4
                lvlUp     = bz + adrBase * off
                lvlLo     = bz - adrBase * off
                scU       = f_score(extremity, volRatio, er, f_dirBias(trendSign, true))
                scL       = f_score(extremity, volRatio, er, f_dirBias(trendSign, false))
                tnm       = array.get(tnames, ti)

                if scU >= minScore
                    topU = lvlUp + half
                    botU = lvlUp - half
                    bU = box.new(boundaryBar, topU, boundaryBar, botU, border_color=showBorder ? color.new(borderCol, borderTransp) : color.new(color.gray,100), border_width=showBorder ? 1 : 0, bgcolor=color.new(upColor, f_transp(scU)))
                    array.push(curDay.boxes, bU)
                    array.push(curTop, topU)
                    array.push(curBot, botU)
                    array.push(curScore, scU)
                    array.push(curExtreme, isExt)
                    if showLabels
                        sTxt = showStars ? "  " + f_stars(scU) + " " + str.tostring(scU,"#.0") + "/10 (" + f_tier(scU) + ")" : "  " + str.tostring(scU,"#.0") + "/10"
                        lU = label.new(boundaryBar, lvlUp, tnm + " ▲" + sTxt, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                        array.push(curDay.labels, lU)

                if scL >= minScore
                    topL = lvlLo + half
                    botL = lvlLo - half
                    bL = box.new(boundaryBar, topL, boundaryBar, botL, border_color=showBorder ? color.new(borderCol, borderTransp) : color.new(color.gray,100), border_width=showBorder ? 1 : 0, bgcolor=color.new(loColor, f_transp(scL)))
                    array.push(curDay.boxes, bL)
                    array.push(curTop, topL)
                    array.push(curBot, botL)
                    array.push(curScore, scL)
                    array.push(curExtreme, isExt)
                    if showLabels
                        sTxt2 = showStars ? "  " + f_stars(scL) + " " + str.tostring(scL,"#.0") + "/10 (" + f_tier(scL) + ")" : "  " + str.tostring(scL,"#.0") + "/10"
                        lL = label.new(boundaryBar, lvlLo, tnm + " ▼" + sTxt2, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
                        array.push(curDay.labels, lL)

        array.push(drawDays, curDay)
        while array.size(drawDays) > maxDays
            f_deleteDay(array.shift(drawDays))

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
if array.size(curTop) > 0
    for i = 0 to array.size(curTop)-1
        t = array.get(curTop, i)
        b = array.get(curBot, i)
        if high >= b and low <= t
            touchAny := true
            if array.get(curScore, i) >= strongTh
                touchStrong := true
            if array.get(curExtreme, i)
                touchExtreme := true

alertcondition(touchAny,     "Touch Reaction Zone",        "Price touched a reaction zone")
alertcondition(touchStrong,  "Touch STRONG Reaction Zone", "Price touched a strong reaction zone")
alertcondition(touchExtreme, "Touch EXTREME Reaction Zone","Price reached an extreme auction reaction zone")
````
