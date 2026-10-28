# NIMBUS [ThrowMaster]

- url: https://www.tradingview.com/script/WbRuRjIm/
- type: indicator
- pine_id: PUB;7a3cbb10e7dd45dbab73915e3f64191b
- version: 1.0

## Description

[b]NIMBUS — Ichimoku, Reimagined[/b]

Classic Ichimoku is brilliant at one question: "Where is the market right now — above, below, or inside equilibrium?" It is far weaker at a second question every trader actually asks: "What is the market about to do?" NIMBUS keeps the timeless Ichimoku framework intact and adds three dimensions built to close that gap — while staying, above all, honest about what it is: a context compass, not a signal service.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]WHAT NIMBUS ADDS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

⭐ Kumo Calendar — Twist Countdown
[image]https://www.tradingview.com/x/HkVVlaCG/[/image]
Here is a fact most traders overlook: the cloud in front of price is already fully drawn. It is built entirely from bars that have ALREADY closed, then shifted forward. That means the next Kumo twist — the moment Senkou Span A and B swap places — is knowable in advance. NIMBUS scans the forward cloud and counts the exact number of bars until that twist reaches price, and warns you when a thin (weak-support) section is approaching. Ichimoku's most-criticised trait, its lag, becomes a schedule you can read ahead of time.

🩵 Breath — Volume-Reactive Cloud
[image]https://www.tradingview.com/x/ONjgBQ6l/[/image]
A traditional cloud shows only price geometry; two identical-looking clouds can hide wildly different conviction. NIMBUS makes the cloud breathe: it grows more solid on high-participation bars and fainter on quiet ones, using a rolling volume percentile. Strength becomes something you feel at a glance, not something you have to calculate. (If a symbol reports no volume, the cloud simply falls back to a fixed opacity — no errors, no false readings.)

🎯 Tenkan / Kijun Cross Clarity
[image]https://www.tradingview.com/x/nnnrABDF/[/image]
The Tenkan–Kijun cross is one of Ichimoku's core events, yet on most charts it hides in a tangle of lines. NIMBUS marks it precisely: a teal circle at the exact price and bar of a bullish cross, coral for bearish. No hunting, no guessing.

◈ Alignment Hints
[image]https://www.tradingview.com/x/4Nbz8ypA/[/image]
When four independent Ichimoku dimensions agree — price vs cloud, Tenkan vs Kijun, cloud colour, and the lagging read — AND price reclaims or loses the cloud on a confirmed bar, NIMBUS prints a small diamond. Think of it as a puzzle-game hint: a nudge to look at the right place at the right time. It is deliberately NOT a buy or sell command, and it never gives a target.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW IT WORKS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

NIMBUS uses the standard Ichimoku engine — Tenkan (9), Kijun (26), Senkou Span A/B, and the lagging span, all fully adjustable. "Price vs cloud" always compares price to the cloud value formed 25 bars ago — the cloud actually sitting beneath price — so the reading reflects real, settled structure. The Breath layer reads a 100-bar volume percentile. The Twist Countdown walks the already-shifted forward cloud bar by bar. The dashboard summarises everything in one compact, theme-aware panel with a mobile Compact Mode.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW TO USE[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

• Read the cloud for trend context: above = bullish structure, below = bearish, inside = balance/chop.
• Watch the Twist Countdown to anticipate when the cloud's support/resistance character is about to flip — useful for planning, not for firing blind.
• Let Breath tell you whether a move carries participation or is running on fumes.
• Treat Hints as a reason to zoom in and do your own analysis, never as an instruction.
• Combine with your own risk management. NIMBUS describes context; your plan decides the trade.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]ON REPAINTING (honest)[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

Once a bar closes, every Tenkan/Kijun/Span value is fixed and never redrawn. Hints and cross circles are all confirmed on bar close, so a printed mark cannot later disappear. The forward cloud is built only from closed bars, so it is fixed the moment it appears. Like all Ichimoku tools, values on the CURRENT, still-forming bar update in real time until that bar closes — this is inherent to the framework, not hidden repainting, and it is documented directly in the code comments.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]WHAT MAKES IT ORIGINAL[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

NIMBUS is not another line pack bolted onto Ichimoku. The Kumo Calendar reframes the forward cloud as a countdown rather than a static shape; Breath encodes participation into the cloud's opacity; and the whole tool is presented as an explicit, self-aware CONTEXT instrument — it tells you what the market is, and refuses to pretend it knows your trade. The code is fully open for you to read, study, and learn from.

━━━━━━━━━━━━━━━━━━━━━━━━
[b]NOTE[/b]
━━━━━━━━━━━━━━━━━━━━━━━━

No indicator predicts the future or guarantees results, and NIMBUS makes no such claim. It is a decision-support and context tool. Markets involve risk; always use independent judgement and sound risk management. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThrowMaster

//@version=6
// ╔══════════════════════════════════════════════════════════════════════╗
// ║  NIMBUS [ThrowMaster] — FREE EDITION  ·  v1.1                          ║
// ║  Ichimoku Reimagined — a market-context compass, not a signal engine   ║
// ║  by Throwsmith                                                          ║
// ╚══════════════════════════════════════════════════════════════════════╝
// ── NON-REPAINT NOTES ──────────────────────────────────────────────────
//  • Closed-bar Tenkan/Kijun/Span values are immutable — they never repaint.
//  • The live (forming) bar updates in real time; inherent to Ichimoku,
//    NOT harmful repaint. Every HINT and every TK cross is confirmed on bar
//    close, so a printed mark can never vanish.
//  • The future cloud (shifted +25) is computed only from already-closed
//    bars, so it is fixed the moment it appears.
//  • "Price vs Cloud" compares price to the cloud value formed 25 bars ago
//    (the cloud actually sitting under price) — fully non-repainting.
//  • Hints fire only when an internal 4-dimension score crosses a threshold
//    AND price reclaims/loses the cloud on a closed bar. They are NUDGES —
//    NOT buy/sell signals, and there are no TP/SL targets. Context only.
// ────────────────────────────────────────────────────────────────────────
indicator("NIMBUS [ThrowMaster]", "NIMBUS", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// ═══════════════════════ INPUTS ═══════════════════════
gCore = "◈ Ichimoku Core"
conversionPeriods   = input.int(9,  "Conversion · Tenkan", minval=1, group=gCore, tooltip="Fast equilibrium line. Classic = 9.")
basePeriods         = input.int(26, "Base · Kijun",        minval=1, group=gCore, tooltip="Equilibrium anchor line. Classic = 26.")
laggingSpan2Periods = input.int(52, "Lead Span B",         minval=1, group=gCore, tooltip="Slow cloud boundary. Classic = 52.")
displacement        = input.int(26, "Displacement",        minval=1, group=gCore, tooltip="Forward/back time shift. Classic = 26.")
showChikou          = input.bool(true, "Show Chikou (Lagging Span)", group=gCore, tooltip="Classic lagging line. Kept for authenticity; note it carries little extra information beyond price-vs-Kijun.")

gStyle = "◈ Style & Theme"
theme       = input.string("Dark", "Chart Theme", options=["Dark","Light"], group=gStyle, tooltip="Adapts panel & cloud transparency to your background.")
cloudTransp = input.int(85, "Cloud Transparency", minval=55, maxval=95, group=gStyle, tooltip="Higher = more see-through.")
volReactive = input.bool(true, "Volume-Reactive Cloud (Breath)", group=gStyle, tooltip="The cloud grows more solid on high-participation bars and fainter on quiet ones, so you can feel conviction at a glance. Falls back gracefully if the symbol reports no volume.")
showTKcross = input.bool(true, "Tenkan/Kijun Cross Circles", group=gStyle, tooltip="Draws a clean circle exactly where Tenkan crosses Kijun. Teal = bullish cross, Coral = bearish. Confirmed on bar close.")

gCal = "⭐ Kumo Calendar"
showCalendar  = input.bool(true, "Twist Countdown", group=gCal, tooltip="The next 25 bars of cloud are ALREADY known. NIMBUS counts the bars until the next Kumo twist reaches price — turning Ichimoku's famous lag into a schedule you can read ahead of time.")
thinAheadMult = input.float(0.5, "Thin-Cloud Warning (× ATR)", minval=0.1, step=0.1, group=gCal, tooltip="Flags a thin (weak-support) cloud section approaching. A thin cloud is easier for price to slice through.")

gHint = "◈ Alignment Hints"
showHints = input.bool(true, "Show Hints", group=gHint, tooltip="A subtle puzzle-style mark appears only when four independent Ichimoku dimensions agree AND price reclaims or loses the cloud on a confirmed bar. A nudge to look — never a buy/sell call, and never a target.")

gDash = "◈ Dashboard"
showDash    = input.bool(true, "Show Dashboard", group=gDash)
dashSize    = input.string("Normal", "Size", options=["Tiny","Small","Normal","Large"], group=gDash)
dashPos     = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gDash)
compactMode = input.bool(false, "Compact Mode (Mobile)", group=gDash, tooltip="Fewer rows, tuned for phone screens.")

// ═══════════════════════ PALETTE (Throwsmith) ═══════════════════════
CLR_TIFFANY = #0ABAB5
CLR_CORAL   = #FF4D6D
CLR_MINT    = #3DDC97
CLR_AMBER   = #F2B705
CLR_GOLD    = #D4AF37
CLR_VIOLET  = #A78BFA
CLR_SLATE   = #8792A8
txtCol  = theme == "Dark" ? #E8ECF4 : #101828
panelBg = theme == "Dark" ? color.new(#0B0F1A, 10) : color.new(#FFFFFF, 6)
headBg  = color.new(CLR_TIFFANY, 82)
rowBg   = theme == "Dark" ? color.new(#0B0F1A, 20) : color.new(#F4F6FA, 10)

// ═══════════════════════ HELPERS ═══════════════════════
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))
f_pos(p) => p=="Top Left"?position.top_left : p=="Bottom Right"?position.bottom_right : p=="Bottom Left"?position.bottom_left : p=="Middle Right"?position.middle_right : position.top_right
f_size(s) => s=="Tiny"?size.tiny : s=="Small"?size.small : s=="Large"?size.large : size.normal

// ═══════════════════════ CORE CALC ═══════════════════════
conversionLine = donchian(conversionPeriods)
baseLine       = donchian(basePeriods)
leadLine1      = math.avg(conversionLine, baseLine)   // Senkou Span A
leadLine2      = donchian(laggingSpan2Periods)        // Senkou Span B
atr14    = ta.atr(14)
maxAhead = displacement - 1

// Breath — volume percentile modulates cloud opacity (ta.* hoisted, unconditional)
volPctRaw = ta.percentrank(volume, 100)
hasVol  = not na(volume) and volume > 0
volPct  = hasVol ? volPctRaw : 50.0
breathT = volReactive and hasVol ? cloudTransp - (volPct - 50) * 0.20 : cloudTransp
breathT := math.max(60, math.min(95, breathT))
kumoBull     = leadLine1 > leadLine2
cloudFillCol = kumoBull ? color.new(CLR_TIFFANY, int(breathT)) : color.new(CLR_CORAL, int(breathT))

// ═══════════════════════ PLOTS ═══════════════════════
plot(conversionLine, "Tenkan", color=CLR_TIFFANY, linewidth=1)
plot(baseLine,       "Kijun",  color=CLR_AMBER,   linewidth=2)
plot(showChikou ? close : na, "Chikou", color=color.new(CLR_VIOLET, 25), offset=-maxAhead)
pA = plot(leadLine1, "Span A", color=color.new(CLR_TIFFANY, 55), offset=maxAhead)
pB = plot(leadLine2, "Span B", color=color.new(CLR_CORAL,   55), offset=maxAhead)
fill(pA, pB, color=cloudFillCol, title="Kumo")

// ── TK cross circles (on the Kijun, at the exact cross bar) ──
tkCrossUp = ta.crossover(conversionLine, baseLine)
tkCrossDn = ta.crossunder(conversionLine, baseLine)
plot(showTKcross and tkCrossUp ? baseLine : na, "TK Bull halo", color=color.new(CLR_TIFFANY, 55), linewidth=4, style=plot.style_circles)
plot(showTKcross and tkCrossUp ? baseLine : na, "TK Bull cross", color=CLR_TIFFANY, linewidth=2, style=plot.style_circles)
plot(showTKcross and tkCrossDn ? baseLine : na, "TK Bear halo", color=color.new(CLR_CORAL, 55), linewidth=4, style=plot.style_circles)
plot(showTKcross and tkCrossDn ? baseLine : na, "TK Bear cross", color=CLR_CORAL, linewidth=2, style=plot.style_circles)

// ═══════════════════════ PRICE vs CLOUD (non-repaint) ═══════════════════════
cloudTopNow  = math.max(leadLine1[maxAhead], leadLine2[maxAhead])
cloudBotNow  = math.min(leadLine1[maxAhead], leadLine2[maxAhead])
priceAbove   = close > cloudTopNow
priceBelow   = close < cloudBotNow
priceInCloud = not priceAbove and not priceBelow and not na(cloudTopNow)
posTxt = priceAbove ? "▲ Above" : priceBelow ? "▼ Below" : "◆ Inside"
posCol = priceAbove ? CLR_TIFFANY : priceBelow ? CLR_CORAL : CLR_AMBER
tkBull = conversionLine > baseLine

// Internal alignment score (drives hints; NOT displayed — Free keeps the number private)
sPos  = priceAbove ? 1 : priceBelow ? -1 : 0
sTK   = tkBull ? 1 : -1
sKumo = kumoBull ? 1 : -1
sChik = close > close[maxAhead] ? 1 : -1
nimScore = sPos + sTK + sKumo + sChik   // -4 .. +4

// ═══════════════════════ KUMO CALENDAR (deterministic · zero repaint) ═══════════════════════
int   twistAhead = na
bool  twistBull  = false
bool  twistOK    = false
float thinAhead  = na
if bar_index > displacement + laggingSpan2Periods + 2
    int fN = -1
    for n = 0 to maxAhead - 1
        aN = leadLine1[n]   > leadLine2[n]
        aP = leadLine1[n+1] > leadLine2[n+1]
        if aN != aP and n > fN          // largest n = nearest arrival
            fN := n
            twistBull := aN
    if fN >= 0
        twistAhead := maxAhead - fN
        twistOK := true
    if not na(atr14) and atr14 > 0
        int tN = -1
        for n = 0 to maxAhead - 1
            if math.abs(leadLine1[n] - leadLine2[n]) < atr14 * thinAheadMult and n > tN
                tN := n
        if tN >= 0
            thinAhead := maxAhead - tN

// ═══════════════════════ HINTS (puzzle-style · internal score crosses threshold) ═══════════════════════
crossUp = ta.crossover(close, cloudTopNow)
crossDn = ta.crossunder(close, cloudBotNow)
hintBull = showHints and barstate.isconfirmed and crossUp and nimScore >= 3
hintBear = showHints and barstate.isconfirmed and crossDn and nimScore <= -3
plotshape(hintBull, "Bull Hint", shape.diamond, location.belowbar, color.new(CLR_TIFFANY, 0), size=size.tiny)
plotshape(hintBear, "Bear Hint", shape.diamond, location.abovebar, color.new(CLR_CORAL,   0), size=size.tiny)

// ═══════════════════════ ALERTS ═══════════════════════
alertcondition(hintBull, "NIMBUS · Bull Hint", "NIMBUS: price reclaimed the cloud with 4-way bullish alignment")
alertcondition(hintBear, "NIMBUS · Bear Hint", "NIMBUS: price lost the cloud with 4-way bearish alignment")
alertcondition(tkCrossUp, "NIMBUS · TK Bull Cross", "NIMBUS: Tenkan crossed above Kijun")
alertcondition(tkCrossDn, "NIMBUS · TK Bear Cross", "NIMBUS: Tenkan crossed below Kijun")
if showCalendar and twistOK and twistAhead == 1 and barstate.isconfirmed
    alert("NIMBUS: Kumo twist arrives next bar — " + (twistBull ? "bullish" : "bearish"), alert.freq_once_per_bar)

// ═══════════════════════ DASHBOARD (compact · no empty cells) ═══════════════════════
cloudWATR = atr14 > 0 ? math.abs(leadLine1 - leadLine2) / atr14 : na
var table dash = na
if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(f_pos(dashPos), 2, 8, bgcolor=panelBg, border_color=color.new(CLR_TIFFANY, 60), border_width=1, frame_color=color.new(CLR_TIFFANY, 45), frame_width=1)
    ts = f_size(dashSize)
    r = 0
    table.cell(dash, 0, r, "◈ NIMBUS Free", bgcolor=headBg, text_color=CLR_TIFFANY, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, r, timeframe.period, bgcolor=headBg, text_color=txtCol, text_size=ts, text_halign=text.align_right)
    r += 1
    table.cell(dash, 0, r, "Price", bgcolor=rowBg, text_color=CLR_SLATE, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, r, posTxt, bgcolor=rowBg, text_color=posCol, text_size=ts, text_halign=text.align_right)
    r += 1
    table.cell(dash, 0, r, "Kumo", bgcolor=rowBg, text_color=CLR_SLATE, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, r, kumoBull ? "🟢 Bull" : "🔴 Bear", bgcolor=rowBg, text_color=kumoBull ? CLR_TIFFANY : CLR_CORAL, text_size=ts, text_halign=text.align_right)
    r += 1
    twStr = showCalendar and twistOK ? (twistBull ? "🟢 " : "🔴 ") + str.tostring(twistAhead) + "b" : "—"
    table.cell(dash, 0, r, "⭐ Twist", bgcolor=rowBg, text_color=CLR_GOLD, text_size=ts, text_halign=text.align_left)
    table.cell(dash, 1, r, twStr, bgcolor=rowBg, text_color=twistOK ? (twistBull ? CLR_TIFFANY : CLR_CORAL) : CLR_SLATE, text_size=ts, text_halign=text.align_right)
    r += 1
    if not compactMode
        brStr = na(cloudWATR) ? "—" : str.tostring(cloudWATR, "0.0") + "× " + (cloudWATR < 0.6 ? "Thin" : cloudWATR > 1.6 ? "Thick" : "Norm")
        table.cell(dash, 0, r, "Breath", bgcolor=rowBg, text_color=CLR_SLATE, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, r, brStr, bgcolor=rowBg, text_color=txtCol, text_size=ts, text_halign=text.align_right)
        r += 1
        table.cell(dash, 0, r, "T / K", bgcolor=rowBg, text_color=CLR_SLATE, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, r, tkBull ? "🟢 Bull" : "🔴 Bear", bgcolor=rowBg, text_color=tkBull ? CLR_TIFFANY : CLR_CORAL, text_size=ts, text_halign=text.align_right)
        r += 1
        thStr = na(thinAhead) ? "clear" : "⚠ " + str.tostring(thinAhead) + "b"
        table.cell(dash, 0, r, "Thin", bgcolor=rowBg, text_color=CLR_SLATE, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, r, thStr, bgcolor=rowBg, text_color=na(thinAhead) ? CLR_SLATE : CLR_AMBER, text_size=ts, text_halign=text.align_right)
        r += 1
        table.cell(dash, 0, r, "ⓘ context", bgcolor=color.new(#0B0F1A, 30), text_color=color.new(CLR_SLATE, 20), text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, r, "not a signal", bgcolor=color.new(#0B0F1A, 30), text_color=color.new(CLR_SLATE, 20), text_size=size.tiny, text_halign=text.align_right)
````
