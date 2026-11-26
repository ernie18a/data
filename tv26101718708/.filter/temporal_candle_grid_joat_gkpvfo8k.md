# Temporal Candle Grid [JOAT]

- url: https://www.tradingview.com/script/gkPVFo8k-Temporal-Candle-Grid-JOAT/
- type: indicator
- pine_id: PUB;4dd35c6e618448af80c9a854ae3bab7a
- version: 1.0

## Description

[b]Temporal Candle Grid [JOAT][/b]

[b]Overview[/b]

Temporal Candle Grid is a multi-timeframe structural confluence indicator that automatically pairs the current chart timeframe with a logical higher timeframe (HTF), fetches the HTF's open, high, low, and close series using non-repainting request.security() calls, and renders the resulting HTF candle geometry as a precision box overlay on the lower timeframe chart. Confirmation counters, buy-side/sell-side liquidity labels, and Fair Value Gap detection operate on confirmed bars only, giving traders a clean, lag-aware view of where HTF price structure begins and ends.

[image]https://www.tradingview.com/x/UveXDzHD/[/image]

[b]Intelligent Auto-Pairing[/b]

The indicator contains a timeframe pairing table that maps the current chart to a contextually appropriate higher timeframe without any manual configuration:

- 1m chart → 15m HTF
- 5m chart → 1H HTF
- 15m chart → 4H HTF
- 1H chart → Daily HTF
- 4H chart → Weekly HTF
- Daily chart → Monthly HTF

This auto-pairing logic ensures the HTF candle shown is always meaningfully larger than the current view — avoiding the degenerate case of pairing a 5m chart with a 10m HTF, which provides almost no additional information.

Users may override the auto-pair by specifying a custom HTF via input.

[b]Non-Repainting HTF Data[/b]

Four separate request.security() calls retrieve HTF open, high, low, and close using:
- close[1] offset on the HTF series (current-bar data from the HTF is never used)
- barmerge.lookahead_off

This combination guarantees that the HTF values shown were already fixed before the current bar opened — making the indicator safe for signal generation and alert use without lookahead contamination.

[b]HTF Candle Box Rendering[/b]

The HTF candle is rendered as a transparent box spanning the full high-to-low range, with an inner body box (open-to-close) rendered in the candle direction colour (teal for bullish, red for bearish). At each HTF boundary (detected via ta.change() on the HTF open), the previous candle's boxes are finalised and new boxes begin drawing. This creates a visual grid of HTF candles overlaid on the lower timeframe, making the internal structure of each HTF bar immediately visible.

[b]Confirmation Counter for HTF Range Breaks[/b]

Rather than signalling the moment price crosses an HTF boundary, the engine counts consecutive closes above the HTF high (for bullish breaks) or below the HTF low (for bearish breaks). A break is only confirmed after the count reaches a configurable threshold (default 2 consecutive closes). This eliminates wick-driven false breaks that resolve within the same HTF session.

[b]Buy-Side / Sell-Side Liquidity Labels (BSL / SSL)[/b]

When a confirmed HTF high break occurs, the BSL (buy-side liquidity) level is marked with an upward label at the HTF high. When a confirmed HTF low break occurs, an SSL (sell-side liquidity) label is stamped at the HTF low. These labels persist and serve as reference levels for future pullbacks — common targets in institutional liquidity analysis.

[b]Fair Value Gap Detection[/b]

Running on the current timeframe, the FVG engine identifies three-bar price gaps:

- [b]Bullish FVG:[/b] Current bar's low is above the high from two bars ago — a gap in downside coverage indicating aggressive buying
- [b]Bearish FVG:[/b] Current bar's high is below the low from two bars ago — a gap in upside coverage indicating aggressive selling

FVG boxes are drawn spanning the gap range and extend forward for 30 bars, rendering as reference zones for expected price return.

[b]HTF Candle Projection[/b]

On the last bar (barstate.islast), the current in-progress HTF candle is projected forward as a semi-transparent dashed box, giving traders a visual reference for the current HTF session's range as it develops in real time.

[b]Dashboard[/b]

A compact table at the bottom right displays:
- Current chart TF and detected HTF
- HTF candle direction (BULL / BEAR)
- Current break confirmation count
- Number of active BSL / SSL levels
- FVG status (open / filled) for the most recent gap

[b]Inputs Reference[/b]

- Custom HTF Override — leave blank for auto-pair, enter a TF string (e.g., "60") to override
- Confirmation Bars Required (2) — consecutive closes beyond HTF range before break is confirmed
- Show HTF Candle Boxes — toggles the HTF overlay
- Show BSL / SSL Labels — toggles liquidity sweep labels
- Show FVG Boxes — toggles fair value gap boxes
- FVG Lookback (50) — how many bars back to scan for active FVGs
- Max BSL / SSL Labels (10) — prevents label accumulation over long sessions
- Theme: Dark, Light, Auto

[b]How to Use[/b]

1. Apply on a 5m, 15m, or 1H chart. The indicator auto-detects the appropriate HTF.
2. The HTF candle boxes show the full range of each higher-timeframe session. Price tends to respect the HTF open, high, and low as decision levels.
3. Wait for the confirmation counter to reach the threshold before treating a HTF range break as confirmed.
4. BSL labels above prior HTF highs and SSL labels below prior HTF lows indicate pools of resting orders — common institutional sweep targets.
5. FVG boxes within the current HTF candle body often act as intra-session return targets.

[b]Non-Repainting Design[/b]

All HTF data uses close[1] with lookahead_off. Break signals require barstate.isconfirmed. FVG detection is based entirely on confirmed historical bars. The projection box at barstate.islast is explicitly marked as in-progress and does not generate signals.

[b]Limitations[/b]

- Auto-pairing is based on standard timeframe relationships. Non-standard chart intervals (e.g., 3m, 7m) default to the nearest logical pair.
- The confirmation counter approach adds 1–2 bars of lag to break signals. This is intentional and necessary for non-repainting accuracy.
- On very fast-moving instruments, HTF candle boxes may be violated frequently, limiting their utility as structural references.
- FVG relevance degrades significantly on very high timeframes (Daily+) where gaps are rare and may take weeks to fill.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Multi-timeframe structure analysis describes historical price behaviour and does not guarantee any specific future market outcome. Conduct your own analysis and use proper risk management at all times.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Temporal Candle Grid [JOAT]", shorttitle="TCG [JOAT]", overlay=true,
          max_boxes_count=300, max_lines_count=300, max_labels_count=100)

// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_H  = "HTF Settings"
var GRP_S  = "Signal Settings"
var GRP_V  = "Visual"

i_autoTF    = input.bool  (true,   "Auto-Pair Timeframe",     group=GRP_H)
i_manualTF  = input.string("60",   "Manual HTF (if no auto)", group=GRP_H)
i_numCdl    = input.int   (10,     "HTF Candles to Project",  group=GRP_H, minval=3, maxval=20)
i_cdlWidth  = input.int   (5,      "Candle Width (bars)",     group=GRP_H, minval=2, maxval=15)
i_showFVG   = input.bool  (true,   "Show HTF FVGs",           group=GRP_H)
i_showBSL   = input.bool  (true,   "Show BSL / SSL Labels",   group=GRP_H)

i_confBars  = input.int   (2,      "Confirmation Closes",     group=GRP_S, minval=1, maxval=10)
i_showSig   = input.bool  (true,   "Show Signal Labels",      group=GRP_S)
i_slAtr     = input.float (1.5,    "SL Buffer (ATR x)",       group=GRP_S, minval=0.5, step=0.25)
i_tpAtr     = input.float (3.0,    "TP Distance (ATR x)",     group=GRP_S, minval=1.0,  step=0.25)

i_theme     = input.string("Auto", "Theme",["Dark","Light","Auto"], group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL   = color.rgb(0, 245, 212)
C_BEAR   = color.rgb(255, 68, 102)
C_GOLD   = color.rgb(255, 215, 0)
C_PURP   = color.rgb(155, 89, 182)
C_SLATE  = color.rgb(96, 112, 128)
C_FVG_B  = color.rgb(0, 180, 140)
C_FVG_R  = color.rgb(200, 50, 80)
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT    = _isDark ? color.white : color.black

// ─── AUTO-PAIR TIMEFRAME ─────────────────────────────────────────────
f_autoHTF() =>
    switch timeframe.period
        "1"   => "15"
        "3"   => "30"
        "5"   => "60"
        "10"  => "120"
        "15"  => "240"
        "30"  => "240"
        "60"  => "D"
        "120" => "D"
        "240" => "W"
        "D"   => "W"
        => "D"

htfTF = i_autoTF ? f_autoHTF() : i_manualTF

// ─── HTF DATA (series — access with [k] offset) ──────────────────────
htfO = request.security(syminfo.tickerid, htfTF, open,  lookahead=barmerge.lookahead_off)
htfH = request.security(syminfo.tickerid, htfTF, high,  lookahead=barmerge.lookahead_off)
htfL = request.security(syminfo.tickerid, htfTF, low,   lookahead=barmerge.lookahead_off)
htfC = request.security(syminfo.tickerid, htfTF, close, lookahead=barmerge.lookahead_off)

atr14 = ta.atr(14)

// ─── SIGNAL LOGIC — current price vs confirmed HTF levels ─────────────
// Use [1] offset for non-repainting confirmed HTF bar
htfH1  = htfH[1]
htfL1  = htfL[1]
htfMid = (htfH1 + htfL1) * 0.5
htfO1  = htfO[1]

// Confirmation counters for each key HTF level
var int confH    = 0   // bars closed above HTF high
var int confL    = 0   // bars closed below HTF low
var int confM_U  = 0   // bars closed above HTF mid
var int confM_D  = 0   // bars closed below HTF mid

// Update confirmation counters (reset if level changes)
var float prevHTFH = na
var float prevHTFL = na
var float prevHTFM = na

if prevHTFH != htfH1
    confH   := 0
    prevHTFH := htfH1
else
    confH := close > htfH1 ? confH + 1 : 0

if prevHTFL != htfL1
    confL   := 0
    prevHTFL := htfL1
else
    confL := close < htfL1 ? confL + 1 : 0

if prevHTFM != htfMid
    confM_U := 0
    confM_D := 0
    prevHTFM := htfMid
else
    confM_U := close > htfMid ? confM_U + 1 : 0
    confM_D := close < htfMid ? confM_D + 1 : 0

bullBrkH  = confH   == i_confBars and barstate.isconfirmed
bearBrkL  = confL   == i_confBars and barstate.isconfirmed
bullBrkM  = confM_U == i_confBars and barstate.isconfirmed
bearBrkM  = confM_D == i_confBars and barstate.isconfirmed

anySig = bullBrkH or bearBrkL or bullBrkM or bearBrkM

// ─── SIGNAL LABELS ───────────────────────────────────────────────────
if i_showSig and bullBrkH
    sl = close - atr14 * i_slAtr
    tp = close + atr14 * i_tpAtr
    label.new(bar_index, low, "HTF H BREAK\nTP: " + str.tostring(math.round(tp, 4)),
         color=color.new(C_BULL, 55), textcolor=color.white,
         style=label.style_label_up, size=size.small)
if i_showSig and bearBrkL
    sl = close + atr14 * i_slAtr
    tp = close - atr14 * i_tpAtr
    label.new(bar_index, high, "HTF L BREAK\nTP: " + str.tostring(math.round(tp, 4)),
         color=color.new(C_BEAR, 55), textcolor=color.white,
         style=label.style_label_down, size=size.small)
if i_showSig and bullBrkM
    label.new(bar_index, low, "HTF MID+",
         color=color.new(C_BULL, 65), textcolor=color.white,
         style=label.style_label_up, size=size.tiny)
if i_showSig and bearBrkM
    label.new(bar_index, high, "HTF MID-",
         color=color.new(C_BEAR, 65), textcolor=color.white,
         style=label.style_label_down, size=size.tiny)

// ─── RT DRAWING OBJECTS ──────────────────────────────────────────────
var array<box>   rtBodies  = array.new<box>()
var array<line>  rtWicks   = array.new<line>()
var array<line>  rtLevels  = array.new<line>()
var array<label> rtLabels  = array.new<label>()
var array<box>   rtFVGs    = array.new<box>()

// ─── DELETE ALL RT OBJECTS ───────────────────────────────────────────
f_flushRT() =>
    for b in rtBodies
        box.delete(b)
    for l in rtWicks
        line.delete(l)
    for lv in rtLevels
        line.delete(lv)
    for lb in rtLabels
        label.delete(lb)
    for fv in rtFVGs
        box.delete(fv)
    rtBodies.clear()
    rtWicks.clear()
    rtLevels.clear()
    rtLabels.clear()
    rtFVGs.clear()

// ─── REBUILD HTF CANDLES ON LAST BAR ─────────────────────────────────
if barstate.islast
    f_flushRT()

    maxSH = float(na)
    maxSL = float(na)
    shBar = int(na)
    slBar = int(na)
    trackH = float(na)
    trackL = float(na)

    startX = bar_index + 3
    n      = math.min(i_numCdl, 20)

    for k = n - 1 to 0
        o  = htfO[k]
        h  = htfH[k]
        l  = htfL[k]
        c  = htfC[k]
        if na(o) or na(h) or na(l) or na(c)
            continue
        isBull  = c >= o
        bodyTop = math.max(o, c)
        bodyBot = math.min(o, c)
        xLeft   = startX + (n - 1 - k) * (i_cdlWidth + 1)
        xRight  = xLeft + i_cdlWidth
        clr     = isBull ? C_BULL : C_BEAR
        // Candle body
        b = box.new(xLeft, bodyTop, xRight, bodyBot,
            bgcolor=color.new(clr, 55), border_color=color.new(clr, 30), border_width=1)
        rtBodies.push(b)
        // Upper wick
        midX = xLeft + int(i_cdlWidth / 2)
        wu = line.new(midX, h, midX, bodyTop, color=color.new(clr, 30), width=1)
        wd = line.new(midX, bodyBot, midX, l,  color=color.new(clr, 30), width=1)
        rtWicks.push(wu)
        rtWicks.push(wd)
        // FVG detection on projected candles
        if i_showFVG and k >= 2
            prevH2 = htfH[k + 2]
            prevL2 = htfL[k + 2]
            if not na(prevH2) and not na(prevL2)
                if isBull and l > prevH2  // bull FVG
                    xf   = startX + (n - 1 - (k + 2)) * (i_cdlWidth + 1)
                    fvg  = box.new(xf, l, xRight + 10, prevH2,
                           bgcolor=color.new(C_FVG_B, 82), border_color=na)
                    rtFVGs.push(fvg)
                else if not isBull and h < prevL2  // bear FVG
                    xf   = startX + (n - 1 - (k + 2)) * (i_cdlWidth + 1)
                    fvg  = box.new(xf, prevL2, xRight + 10, h,
                           bgcolor=color.new(C_FVG_R, 82), border_color=na)
                    rtFVGs.push(fvg)
        // Track swing highs/lows for BSL/SSL
        trackH := na(trackH) ? h : math.max(trackH, h)
        trackL := na(trackL) ? l : math.min(trackL, l)

    // HTF level lines extending from last projected candle
    if n > 0
        rightX = startX + (n - 1) * (i_cdlWidth + 1) + i_cdlWidth + 15
        // Last confirmed HTF high line
        lH = line.new(startX, htfH1, rightX, htfH1,
             color=color.new(C_BEAR, 25), width=1, style=line.style_dotted)
        lL = line.new(startX, htfL1, rightX, htfL1,
             color=color.new(C_BULL, 25), width=1, style=line.style_dotted)
        lM = line.new(startX, htfMid, rightX, htfMid,
             color=color.new(C_GOLD, 35), width=1, style=line.style_dashed)
        rtLevels.push(lH)
        rtLevels.push(lL)
        rtLevels.push(lM)
        // Level labels
        lb1 = label.new(rightX, htfH1, "HTF H",
              color=color.new(C_BEAR, 50), textcolor=color.white,
              style=label.style_label_left, size=size.tiny)
        lb2 = label.new(rightX, htfL1, "HTF L",
              color=color.new(C_BULL, 50), textcolor=color.white,
              style=label.style_label_left, size=size.tiny)
        lb3 = label.new(rightX, htfMid, "HTF M",
              color=color.new(C_GOLD, 55), textcolor=color.black,
              style=label.style_label_left, size=size.tiny)
        rtLabels.push(lb1)
        rtLabels.push(lb2)
        rtLabels.push(lb3)
        // BSL / SSL labels on swing extremes
        if i_showBSL and not na(trackH)
            lb4 = label.new(startX + int(n * (i_cdlWidth + 1) / 2), trackH, "BSL",
                  color=color.new(C_PURP, 40), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
            rtLabels.push(lb4)
        if i_showBSL and not na(trackL)
            lb5 = label.new(startX + int(n * (i_cdlWidth + 1) / 2), trackL, "SSL",
                  color=color.new(C_PURP, 40), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
            rtLabels.push(lb5)

// ─── HTF LEVEL LINES ON PRICE CHART ──────────────────────────────────
plot(htfH1,  "HTF High",  color=color.new(C_BEAR, 40), linewidth=1, style=plot.style_stepline)
plot(htfL1,  "HTF Low",   color=color.new(C_BULL, 40), linewidth=1, style=plot.style_stepline)
plot(htfMid, "HTF Mid",   color=color.new(C_GOLD, 50), linewidth=1, style=plot.style_stepline)

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(bullBrkH, "TCG HTF High Break Bull [JOAT]", "Temporal Candle Grid: Confirmed close above HTF High")
alertcondition(bearBrkL, "TCG HTF Low Break Bear [JOAT]",  "Temporal Candle Grid: Confirmed close below HTF Low")
alertcondition(bullBrkM, "TCG HTF Mid Break Bull [JOAT]",  "Temporal Candle Grid: Confirmed close above HTF Mid")
alertcondition(bearBrkM, "TCG HTF Mid Break Bear [JOAT]",  "Temporal Candle Grid: Confirmed close below HTF Mid")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.bottom_center, 6, 3,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if barstate.islast
    table.cell(dash, 0, 0, "TCG [JOAT]",
         bgcolor=color.new(C_PURP, 35), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "HTF: " + htfTF,
         bgcolor=color.new(C_PURP, 35), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "HTF H",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 3, 0, str.tostring(math.round(htfH1, 4)),
         text_color=C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 4, 0, "Conf H", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 5, 0, str.tostring(confH) + "/" + str.tostring(i_confBars),
         text_color=close > htfH1 ? C_BULL : C_SLATE, text_size=size.small, bgcolor=C_PANEL)

    table.cell(dash, 0, 1, "HTF L",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 1, str.tostring(math.round(htfL1, 4)),
         text_color=C_BULL, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 2, 1, "Conf L", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 3, 1, str.tostring(confL) + "/" + str.tostring(i_confBars),
         text_color=close < htfL1 ? C_BEAR : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 4, 1, "HTF Mid", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 5, 1, str.tostring(math.round(htfMid, 4)),
         text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)

    sigStr = bullBrkH ? "BULL H" : bearBrkL ? "BEAR L" : bullBrkM ? "BULL M" : bearBrkM ? "BEAR M" : "WATCHING"
    sigClr = (bullBrkH or bullBrkM) ? C_BULL : (bearBrkL or bearBrkM) ? C_BEAR : C_SLATE
    table.cell(dash, 0, 2, "Signal", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 2, sigStr,  text_color=sigClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 2, 2, "Position",text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    posStr = close > htfH1 ? "ABOVE H" : close < htfL1 ? "BELOW L" : close > htfMid ? "PREM" : "DISC"
    posClr = close > htfH1 ? C_BULL : close < htfL1 ? C_BEAR : close > htfMid ? C_BEAR : C_BULL
    table.cell(dash, 3, 2, posStr,  text_color=posClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 4, 2, "ATR",   text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 5, 2, str.tostring(math.round(atr14, 4)),
         text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)
````
