<!-- tradingview-pine-id: PUB;fcfc5eef89a24e279e4a96b1d3c2fe77 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Keltner Rings [Quantum Algo]

Source: https://www.tradingview.com/script/FlGt0Lmk-Keltner-Rings-Quantum-Algo/

## Description

Keltner Rings [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Keltner Rings is a complete reading system built on Keltner Channels — volatility bands placed around an exponential moving average, with width set by the Average True Range. Three nested rings form a gradient volatility field around price, a regime classifier determines what kind of market you are actually in, and the dashboard translates it into plain instructions: when riding the upper band is strength, and when the very same touch is fade material.

That distinction is the heart of this tool. The most common way traders lose money with any channel indicator is applying range logic in a trend — shorting an upper-band touch while price is band-walking higher. Keltner Rings classifies the regime first, interprets every touch accordingly, generates three distinct signal families, and scores each family's historical performance on your exact symbol and timeframe.

═══════════════════════════════════════════════

🔶 WHAT ARE KELTNER CHANNELS?

Keltner Channels are volatility-based bands around a moving average. The concept originates with Chester W. Keltner (1960); the modern formulation — an exponential moving average with bands offset by multiples of the Average True Range — was popularized by Linda Bradford Raschke. Because the Average True Range expands and contracts with real movement, the channel breathes with the market: wide in storms, tight in calm.

This tool extends the classic single channel into three rings — inner, middle and outer — creating a graded map of how far price has traveled from its average in volatility-adjusted terms.

═══════════════════════════════════════════════

🔶 WHAT IS A BAND WALK?

In a genuine trend, price does not oscillate politely around its average — it presses against the channel and rides it, closing beyond the inner ring bar after bar. This is the band walk, and it is the single most misread behavior in channel trading: it looks overbought, and it is actually strength. Keltner Rings detects the walk explicitly (a configurable count of consecutive closes beyond the inner ring), paints the walking bars in full trend color, and marks the walk's beginning as a continuation signal rather than a fade.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Regime-aware interpretation. The classifier combines average slope, band-walk state, squeeze condition and the channel's own width percentile into four regimes — Trend Up, Trend Down, Range, Squeeze — and the dashboard's "How To Read It" row states, live, how touches should be interpreted right now. The tool teaches its own correct usage.

2. Three signal families, separated on purpose. W marks the start of a band walk with the trend (continuation). R marks a middle-ring rejection in a range regime only (reversion, exactly where reversion belongs). S marks a squeeze release through the inner ring (expansion). One tool, three behaviors, never confused with each other.

3. Per-family statistics on your chart. Every family's ten-bar outcomes are tracked in first-in-first-out samples, shrunk toward neutral at small sizes, with Wilson lower bounds. Each signal's tooltip quotes its own family record on the current symbol at the moment it prints — and the dashboard shows all three records side by side.

4. The width cone. Channel width is ranked as a percentile inside its own recent history, so "tight" and "wide" are defined by this symbol's behavior, never by fixed numbers.

5. The squeeze, credited and integrated. Bollinger Bands closing inside the Keltner ring — the compression concept popularized by John F. Carter — is detected with duration tracking, gold coil markers on the average, and directional release signals.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— The exponential average and Average True Range build three rings at configurable widths; five gradient fills render the volatility field between them.
— Average slope, walk counters, squeeze state and width percentile feed the regime classifier every bar.
— Signals: W fires when the walk count is reached with the trend; R fires on middle-ring rejections in range regimes; S fires when a mature squeeze releases through the inner ring.
— Each family's outcomes feed its own statistics; the dashboard and tooltips report them with sample counts.

All signals are evaluated on confirmed bars and do not repaint. All drawings are capped for performance.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Read the regime row first, then the guidance row — they tell you which of the three signal families is currently in its natural habitat.
— In trends: treat inner-ring pullbacks as entries in the trend direction, and let the painted band walk carry the position; the walk ending is your first warning.
— In ranges: middle-ring touches with rejection candles target the average — the R family's record shows how this symbol has respected that logic.
— In squeezes: the coil duration and width percentile tell you how compressed the spring is; the S release gives the direction, and the family record tells you how trustworthy releases have been here.
— Works on all markets and timeframes; every threshold is volatility-adjusted or percentile-based, so nothing needs retuning per symbol.

═══════════════════════════════════════════════

🔶 SETTINGS

— Keltner Channels: exponential average length, Average True Range length, three ring widths.
— Regime & Signals: trend slope threshold, band-walk bar count, width history window, cooldown, squeeze ring width.
— Statistics: sample cap, minimum samples, shrinkage strength, Wilson z-score.
— Visuals and dashboard: full color control, band-walk painting toggle, position and text size.

═══════════════════════════════════════════════

🔶 ALERTS

— Squeeze Started — compression began.
— Squeeze Release Up / Down — compression resolved through the inner ring.
— Band Walk Started — consecutive closes locked beyond the inner ring with the trend.
— Reversion Signal — middle-ring rejection in a range regime.

═══════════════════════════════════════════════

🔶 FAQ

Q: How is this different from standard Keltner Channels?
A: The standard indicator draws one channel and leaves interpretation to you — including the fatal ambiguity of what an upper-band touch means. This tool adds the regime classifier, the three-ring field, the band-walk engine, explicit signal families for continuation, reversion and expansion, and per-family statistics, so every touch arrives with its context and its track record.

Q: Does it repaint?
A: No. All signals are evaluated on confirmed closes; a printed signal never changes.

Q: Keltner Channels or Bollinger Bands?
A: They answer different questions. Bollinger Bands use standard deviation and react sharply to close-to-close variance; Keltner Channels use the Average True Range and breathe more smoothly with the full bar range. This tool uses both — the channel as the structure, and the Bollinger relationship as the squeeze detector.

Q: What do the family percentages mean?
A: The share of past signals in that family after which price had moved favorably ten bars later, on the current symbol and timeframe, shrunk toward fifty percent at small samples. They describe history — they are not predictions.

Q: Which settings matter most?
A: Band Walk Bars (higher = stricter walks, fewer W signals) and the ring widths — the defaults of one, two and three Average True Ranges follow common practice and suit most markets.

═══════════════════════════════════════════════

🔶 CREDITS

The original channel concept is by Chester W. Keltner (1960); the modern exponential-average and Average True Range formulation was popularized by Linda Bradford Raschke. The Average True Range is by J. Welles Wilder Jr. (1978). Bollinger Bands are by John Bollinger, and the band-compression squeeze concept was popularized by John F. Carter. The Wilson score interval is by Edwin B. Wilson (1927). The regime classifier, three-ring field, band-walk engine, signal families, per-symbol statistics and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— Regime classification is descriptive, not predictive: regimes are identified as they form, and transitions are only visible once underway.
— Reversion logic is disabled by design outside range regimes; traders who want to fade trends will not find those signals here.
— Statistics describe the current chart's history only; past frequencies never guarantee future outcomes.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

---

## Source Code

````pine
//@version=6
indicator("Keltner Rings [Quantum Algo]", overlay = true, max_labels_count = 200, max_lines_count = 60, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  KELTNER RINGS
//  Volatility bands around an exponential moving average, width
//  set by the Average True Range — extended into a full reading
//  system. The engine's core insight: a band touch means OPPOSITE
//  things in different regimes. In a trend, riding the upper band
//  is strength (the band walk); in a range, the same touch is
//  fade material. This tool classifies the regime first, then
//  interprets every touch accordingly — and scores each of its
//  three signal families on your exact symbol.
//
//  Concept credits: the original channel concept by Chester W.
//  Keltner (1960); the modern exponential-average and Average
//  True Range formulation popularized by Linda Bradford Raschke;
//  Average True Range by J. Welles Wilder Jr. (1978); Bollinger
//  Bands by John Bollinger; the band-compression squeeze concept
//  popularized by John F. Carter; the Wilson score interval by
//  Edwin B. Wilson (1927). The regime classifier, band-walk
//  engine, graded signal families, per-symbol statistics and all
//  code are original work — no third-party or open-source script
//  code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpK = "Keltner Channels"
emaLen = input.int(20, "Exponential Average Length", minval = 5, group = grpK)
atrLen = input.int(14, "Average True Range Length", minval = 5, group = grpK)
m1 = input.float(1.0, "Inner Ring Width", step = 0.25, minval = 0.25, group = grpK)
m2 = input.float(2.0, "Middle Ring Width", step = 0.25, minval = 0.5, group = grpK)
m3 = input.float(3.0, "Outer Ring Width", step = 0.25, minval = 0.75, group = grpK)

grpR = "Regime & Signals"
slopeTh = input.float(0.05, "Trend Slope Threshold (Average True Range)", step = 0.01, minval = 0.0, group = grpR)
walkN   = input.int(3, "Band Walk Bars", minval = 2, maxval = 10, group = grpR, tooltip = "Consecutive closes beyond the inner ring that qualify as a band walk — the trend-riding state where upper-band touches are strength, not weakness.")
widthWin = input.int(300, "Width History Window (Bars)", minval = 100, maxval = 480, group = grpR)
cooldown = input.int(8, "Signal Cooldown (Bars)", minval = 2, group = grpR)
sqzMult  = input.float(1.5, "Squeeze Ring Width", step = 0.25, minval = 0.5, group = grpR)

grpX = "Statistics"
cap     = input.int(300, "Samples Per Family (FIFO Cap)", minval = 50, maxval = 1000, group = grpX)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, group = grpX)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpX)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpX)

grpV = "Visuals"
bullCol = input.color(#00897b, "Bullish", group = grpV)
bearCol = input.color(#e4002b, "Bearish", group = grpV)
goldCol = input.color(#c77800, "Squeeze / Accent", group = grpV)
silvCol = input.color(#37474f, "Neutral", group = grpV)
paintWalk = input.bool(true, "Paint Band-Walk Bars", group = grpV)

grpD = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpD)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpD)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)
dashTitleBg = input.color(color.new(#ef9a13, 0), "Title Band", group = grpD)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpD)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpD)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpD)
dashHeadTxt = input.color(color.new(#1a1207, 0), "Header Text", group = grpD)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpD)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpD)

// ─── SHARED ─────────────────────────────────────────────────────
f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"
f_meter(float x, int slots) =>
    k = math.min(slots, math.max(0, int(x * slots + 0.5)))
    f_rep("▮", k) + f_rep("▭", slots - k)

// ─── THE CHANNEL SYSTEM ────────────────────────────────────────
emaC = ta.ema(close, emaLen)
atrV = ta.atr(atrLen)
u1 = emaC + atrV * m1
l1 = emaC - atrV * m1
u2 = emaC + atrV * m2
l2 = emaC - atrV * m2
u3 = emaC + atrV * m3
l3 = emaC - atrV * m3
emaSlope = (emaC - emaC[3]) / atrV
trendUp = emaSlope > slopeTh
trendDn = emaSlope < -slopeTh
emaCol = trendUp ? bullCol : trendDn ? bearCol : silvCol

pU3 = plot(u3, "Outer Ring Upper", color = color.new(bearCol, 55))
pU2 = plot(u2, "Middle Ring Upper", color = color.new(bearCol, 35))
pU1 = plot(u1, "Inner Ring Upper", color = color.new(silvCol, 40))
pM  = plot(emaC, "Exponential Average", color = color.new(emaCol, 0), linewidth = 2)
pL1 = plot(l1, "Inner Ring Lower", color = color.new(silvCol, 40))
pL2 = plot(l2, "Middle Ring Lower", color = color.new(bullCol, 35))
pL3 = plot(l3, "Outer Ring Lower", color = color.new(bullCol, 55))
fill(pU3, pU2, color = color.new(bearCol, 82), title = "Upper Outer Field")
fill(pU2, pU1, color = color.new(bearCol, 90), title = "Upper Inner Field")
fill(pU1, pL1, color = color.new(silvCol, 95), title = "Core Field")
fill(pL1, pL2, color = color.new(bullCol, 90), title = "Lower Inner Field")
fill(pL2, pL3, color = color.new(bullCol, 82), title = "Lower Outer Field")

// ─── WIDTH CONE + SQUEEZE ──────────────────────────────────────
chWidth = (u2 - l2) / emaC * 100
var array<float> wHist = array.new<float>()
if barstate.isconfirmed
    wHist.push(chWidth)
    if wHist.size() > widthWin
        wHist.shift()
widthPct = 50.0
if wHist.size() >= 50
    int below = 0
    for i = 0 to wHist.size() - 1
        if wHist.get(i) < chWidth
            below += 1
    widthPct := below * 100.0 / wHist.size()
bbBasis = ta.sma(close, 20)
bbDev = 2.0 * ta.stdev(close, 20)
squeeze = bbBasis + bbDev < emaC + atrV * sqzMult and bbBasis - bbDev > emaC - atrV * sqzMult
var int sqzDur = 0
sqzDur := squeeze ? sqzDur + 1 : 0
sqzRelease = barstate.isconfirmed and not squeeze and squeeze[1]
plotshape(squeeze ? emaC : na, "Squeeze Coil", shape.circle, location.absolute, color.new(goldCol, 0), size = size.tiny)

// ─── BAND WALK ENGINE ──────────────────────────────────────────
var int walkUp = 0
var int walkDn = 0
walkUp := close > u1 ? walkUp + 1 : 0
walkDn := close < l1 ? walkDn + 1 : 0
walkingUp = walkUp >= walkN
walkingDn = walkDn >= walkN
barcolor(paintWalk and walkingUp ? bullCol : paintWalk and walkingDn ? bearCol : na, title = "Band Walk Paint")

// regime: 0 Range · 1 Trend Up · -1 Trend Dn · 2 Squeeze
regime = squeeze and sqzDur >= 5 ? 2 : trendUp and (walkingUp or widthPct >= 40) ? 1 : trendDn and (walkingDn or widthPct >= 40) ? -1 : 0
regName = regime == 2 ? "SQUEEZE" : regime == 1 ? "Trend ▲" : regime == -1 ? "Trend ▼" : "Range"
guide = regime == 2 ? "Coiled · await the release" : regime == 1 ? "Ride the upper band · buy inner-ring dips" : regime == -1 ? "Ride the lower band · sell inner-ring rallies" : "Fade middle-ring touches toward the average"

// ─── SIGNAL FAMILIES ───────────────────────────────────────────
var int lastSigBar = -10000
cooled = bar_index - lastSigBar >= cooldown
// W · band-walk continuation (the walk begins with the trend)
wBuy  = barstate.isconfirmed and cooled and walkUp == walkN and trendUp
wSell = barstate.isconfirmed and cooled and walkDn == walkN and trendDn
// R · reversion from the middle ring against a flat average
rBuy  = barstate.isconfirmed and cooled and regime == 0 and low <= l2 and close > l2 and close > open
rSell = barstate.isconfirmed and cooled and regime == 0 and high >= u2 and close < u2 and close < open
// S · squeeze release through the inner ring
sBuy  = sqzRelease and close > u1
sSell = sqzRelease and close < l1
if wBuy or wSell or rBuy or rSell or sBuy or sSell
    lastSigBar := bar_index

// ─── STATISTICS ────────────────────────────────────────────────
var array<float> fW = array.new<float>()
var array<float> fR = array.new<float>()
var array<float> fS = array.new<float>()
pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()
f_feed(array<float> a, bool condB, bool condS) =>
    if barstate.isconfirmed and bar_index > 10
        if condB[10]
            pushF(a, close / close[10] - 1)
        if condS[10]
            pushF(a, 1 - close / close[10])
f_feed(fW, wBuy, wSell)
f_feed(fR, rBuy, rSell)
f_feed(fS, sBuy, sSell)
statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    if n > 0
        int w = 0
        for i = 0 to n - 1
            if a.get(i) > 0
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
    [pS_, wLB, n]

// ─── SIGNAL LABELS · one-letter house style ────────────────────
var array<label> sigLbs = array.new<label>()
f_sig(bool cond, bool isBuy, string ltr, string desc, array<float> fam) =>
    if cond
        [p10, w10, n10] = statsOf(fam)
        sigLbs.push(label.new(bar_index, isBuy ? low : high, ltr, style = isBuy ? label.style_label_up : label.style_label_down, color = color.new(ltr == "S" ? goldCol : isBuy ? bullCol : bearCol, 0), textcolor = ltr == "S" ? #231a08 : color.white, size = size.small, tooltip = desc + " on " + syminfo.ticker + " " + timeframe.period + (n10 >= minN ? "\nFamily record · favorable 10 bars: " + fw(p10) + " · Wilson " + fw(w10) + " · ×" + str.tostring(n10) : "\nCollecting history (" + str.tostring(n10) + "/" + str.tostring(minN) + ")")))
        while sigLbs.size() > 24
            label.delete(sigLbs.shift())
f_sig(wBuy, true, "W", "Band walk begins — trend continuation. Closes locked beyond the inner ring with a rising average.", fW)
f_sig(wSell, false, "W", "Band walk begins — trend continuation. Closes locked beyond the inner ring with a falling average.", fW)
f_sig(rBuy, true, "R", "Reversion — middle-ring rejection in a range regime, targeting the average.", fR)
f_sig(rSell, false, "R", "Reversion — middle-ring rejection in a range regime, targeting the average.", fR)
f_sig(sBuy, true, "S", "Squeeze release upward — compression resolved through the inner ring.", fS)
f_sig(sSell, false, "S", "Squeeze release downward — compression resolved through the inner ring.", fS)

// ─── PREMIUM DASHBOARD · three columns, golden title ───────────
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small
var table tb = table.new(dPos, 3, 9, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)
if showDash and barstate.islast
    [pW, wW, nW] = statsOf(fW)
    [pR, wR, nR] = statsOf(fR)
    [pS, wS, nS] = statsOf(fS)
    chPos = math.min(1.0, math.max(-1.0, (close - emaC) / (atrV * m2)))
    titleSize = dashSize == "Tiny" ? size.small : dashSize == "Small" ? size.normal : dashSize == "Normal" ? size.large : size.huge
    table.cell(tb, 0, 0, "◈ KELTNER RINGS · " + syminfo.ticker, bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = titleSize, text_halign = text.align_center)
    table.cell(tb, 1, 0, "", bgcolor = dashTitleBg)
    table.cell(tb, 2, 0, "", bgcolor = dashTitleBg)
    table.merge_cells(tb, 0, 0, 2, 0)
    table.cell(tb, 0, 1, "Regime", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, regime == 2 ? "◉" : regime == 1 ? "⇈" : regime == -1 ? "⇊" : "≈", text_color = regime == 2 ? goldCol : regime == 1 ? bullCol : regime == -1 ? bearCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 1, regName, text_color = regime == 2 ? goldCol : regime == 1 ? bullCol : regime == -1 ? bearCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 2, "How To Read It", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, "▸", text_color = goldCol, text_size = bodySize)
    table.cell(tb, 2, 2, guide, text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Channel Position", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, f_meter((chPos + 1) / 2, 6), text_color = chPos > 0.5 ? bearCol : chPos < -0.5 ? bullCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 3, str.tostring(chPos * 100, "#") + "% of middle ring", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 4, "Width", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, f_meter(widthPct / 100, 6), text_color = widthPct <= 20 ? goldCol : widthPct >= 80 ? bearCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 4, str.tostring(widthPct, "#") + "th percentile", text_color = widthPct <= 20 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Squeeze", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, squeeze ? "◉" : "—", text_color = squeeze ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 5, squeeze ? "Coiled · " + str.tostring(sqzDur) + " bars" : "Open", text_color = squeeze ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Walk W", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, nW >= minN ? f_meter(pW, 6) : "—", text_color = nW >= minN and pW >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 6, nW > 0 ? fw(pW) + " ×" + str.tostring(nW) : "—", text_color = nW >= minN and pW >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Reversion R · Release S", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 7, "", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 7, (nR > 0 ? fw(pR) + " ×" + str.tostring(nR) : "—") + " · " + (nS > 0 ? fw(pS) + " ×" + str.tostring(nS) : "—"), text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 8, "Shrunk win rates · this chart only", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 8, "", text_size = size.tiny)
    table.cell(tb, 2, 8, "", text_size = size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(squeeze and not squeeze[1], "Squeeze Started", "Bollinger Bands closed inside the Keltner squeeze ring — compression began.")
alertcondition(sBuy, "Squeeze Release Up", "Compression resolved upward through the inner ring.")
alertcondition(sSell, "Squeeze Release Down", "Compression resolved downward through the inner ring.")
alertcondition(wBuy or wSell, "Band Walk Started", "Consecutive closes locked beyond the inner ring with the trend.")
alertcondition(rBuy or rSell, "Reversion Signal", "Middle-ring rejection in a range regime.")
````
