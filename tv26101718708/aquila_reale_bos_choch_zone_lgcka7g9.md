# Aquila Reale BOS CHoCH + Zone

- url: https://www.tradingview.com/script/LGcka7g9/
- type: indicator
- pine_id: PUB;992e4ca9be8c49a59477b4825d874333
- version: 1.0

## Description

🦅 Aquila Reale BOS CHoCH + Zone

A simple, lightweight tool for traders who follow Smart Money Concepts (SMC) or price action. It marks market structure shifts — Break of Structure (BoS) and Change of Character (CHoCH) — and highlights untouched Fair Value Gaps as liquidity zones.

What it does
The script tracks swing highs and lows to detect when structure breaks. A BoS confirms trend continuation; a CHoCH flags a possible reversal. Each event is drawn directly on the chart with a clean bracket and label, using the structure color you choose.
It also plots liquidity zones from unmitigated Fair Value Gaps (the imbalance left when price moves away fast without filling the gap). These yellow areas are, in my own trading, one of the most useful parts of the tool if you work with SMC or price action — they show where price may return to rebalance before continuing.

Built-in alerts — and why they matter
This is the part I really want to highlight. The script comes with ready-to-use alerts for every structure event:

CHoCH LONG / CHoCH SHORT (possible reversals)
BoS LONG / BoS SHORT (continuation)

If you trade across multiple assets, you simply cannot watch every chart at once — not on your own. The alerts let you set the indicator on all the instruments you follow and get notified the moment structure breaks, instead of staring at screens all day. For a solo trader covering several markets, this is what makes the whole thing actually usable. Set them once per asset and let them do the watching for you.

Swing Lookback presets
Detection sensitivity depends on a Swing Lookback value. To keep things easy I've added presets per timeframe:

Auto — picks the lookback automatically based on the chart timeframe
Daily (60), 4H (30), 1H (15), 15m (8), 5m (5), Scalping 1–3m (2)
Manual — set your own value, very simple

Presets are a starting point, not gospel. It's always better to check the result on your own chart and adjust the lookback until the structure marked matches what you actually see. Different instruments and conditions behave differently.
Other settings

Minimum zone width filter (× ATR) to ignore tiny, noisy gaps
Choose whether a zone is removed on partial touch (wick) or only when fully crossed
Option to never delete zones, if you prefer the full history
Max structures on screen — keeps the chart clean and works smoothly on every timeframe, from Daily down to the lowest scalping TFs
Optional label showing the active lookback value

How I use it
I follow SMC / price action: I wait for a CHoCH to signal a potential shift, then look for price to react at an untouched zone before taking a setup. Structure plus liquidity, plus alerts so I never miss it on the other charts.

Disclaimer
This indicator is provided for educational and informational purposes only. It is not financial, investment, or trading advice, and it is not a recommendation to buy or sell any instrument. BoS, CHoCH and FVG zones are based on historical price and do not predict future movements. Trading carries a high level of risk and you can lose part or all of your capital. Always do your own analysis and risk management, and never trade with money you cannot afford to lose. The author accepts no responsibility for any losses incurred from the use of this tool.

🦅 Royal Eagles — born to fly, born to dare!

## Source Code

````pine
//@version=6
indicator("Aquila Reale BOS CHoCH + Zone", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// === STRUCTURE ===
showStruct = input.bool(true, "Show BoS / CHoCH", group="Structure")

// --- Swing Lookback presets per timeframe ---
preset = input.string("Auto (follow TF)", "Swing Lookback preset",
     options=["Auto (follow TF)", "Daily (60)", "4 hours (30)", "1 hour (15)", "15 min (8)", "5 min (5)", "Scalping 1-3 min (2)", "Manual"],
     group="Structure",
     tooltip="Auto = picks the lookback based on the chart timeframe.\nThe others force a fixed value.\nManual = uses the number below.")
lenMan = input.int(8, "  ↳ Manual Lookback", minval=2, group="Structure", tooltip="Used only if Preset = Manual.")

// max structures on screen (avoids hitting the 500-object limit on low TFs)
maxStruct = input.int(30, "Max structures on screen", minval=5, maxval=160, group="Structure", tooltip="Keeps only the last N structures (BoS/CHoCH). Older ones are removed in a controlled way.\nEach structure uses 3 lines + 1 label, so the maximum is 160 (160 x 3 = 480, below the 500 limit).\nLow value = cleaner chart; high value = more history visible.")

col = input.color(color.black, "Structure color", group="Structure")

// === ZONES (untouched FVG) ===
showZone  = input.bool(true, "Show yellow zones", group="Zones")
zoneMin   = input.float(0.25, "Minimum width (x ATR)", step=0.05, group="Zones")
noDelete  = input.bool(false, "Never delete zones", group="Zones")
mitigMode = input.string("Even partially (wick)", "Delete zone when price returns into it:", options=["Even partially (wick)", "Only if fully crossed"], group="Zones")
colZona   = input.color(color.new(color.yellow, 50), "Zone color", group="Zones")

// === ALERTS (optional) ===
showInfo = input.bool(false, "Show active lookback (label)", group="Info", tooltip="Shows in the top-right the Swing Lookback value currently in use.")

// resolve lookback based on preset / current TF
f_autoLen() =>
    tfm = timeframe.in_seconds() / 60
    timeframe.isdaily ? 60 : tfm >= 240 ? 30 : tfm >= 60 ? 15 : tfm >= 15 ? 8 : tfm >= 5 ? 5 : 2

len = preset == "Daily (60)" ? 60 : preset == "4 hours (30)" ? 30 : preset == "1 hour (15)" ? 15 : preset == "15 min (8)" ? 8 : preset == "5 min (5)" ? 5 : preset == "Scalping 1-3 min (2)" ? 2 : preset == "Manual" ? lenMan : f_autoLen()

atr = ta.atr(50)
ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)

// ---------- STRUCTURE ----------
var int   trend = 0
var float refHigh = na
var int   refHighx = na
var float refLow  = na
var int   refLowx = na

// structure object memory, for controlled removal of the oldest ones
var line[]  sLines  = array.new<line>()
var label[] sLabels = array.new<label>()

if not na(ph)
    refHigh := ph
    refHighx := bar_index - len
if not na(pl)
    refLow := pl
    refLowx := bar_index - len

// removes the oldest structure (3 lines + 1 label) when the limit is exceeded
f_trim() =>
    while array.size(sLines) > maxStruct * 3
        line.delete(array.shift(sLines))
    while array.size(sLabels) > maxStruct
        label.delete(array.shift(sLabels))

drawS(int bx, float lvl, int rx, bool up, string txt) =>
    h = atr * 0.20
    e = up ? lvl + h : lvl - h
    array.push(sLines, line.new(bx, lvl, bx, e, color=col, width=1))
    array.push(sLines, line.new(bx, e, rx, e, color=col, width=1))
    array.push(sLines, line.new(rx, e, rx, lvl, color=col, width=1))
    array.push(sLabels, label.new(math.round((bx+rx)/2), e, txt, style=label.style_none, textcolor=col, size=size.normal, textalign=text.align_center))
    f_trim()

bosUp = false
bosDn = false
chochUp = false
chochDn = false

if not na(refHigh) and close > refHigh
    if trend == -1
        if showStruct
            drawS(refHighx, refHigh, bar_index, true, "CHoCH")
        chochUp := true
        trend := 1
    else if trend == 1
        if showStruct
            drawS(refHighx, refHigh, bar_index, true, "BoS")
        bosUp := true
    else
        trend := 1
    refHigh := na

if not na(refLow) and close < refLow
    if trend == 1
        if showStruct
            drawS(refLowx, refLow, bar_index, false, "CHoCH")
        chochDn := true
        trend := -1
    else if trend == -1
        if showStruct
            drawS(refLowx, refLow, bar_index, false, "BoS")
        bosDn := true
    else
        trend := -1
    refLow := na

// ---------- FVG ZONES (untouched gap) ----------
var box[]   zBox = array.new<box>()
var float[] zTop = array.new<float>()
var float[] zBot = array.new<float>()

if showZone
    bull = low > high[2]
    bear = high < low[2]
    gap  = bull ? low - high[2] : bear ? low[2] - high : 0.0
    if (bull or bear) and gap > atr * zoneMin
        t = bull ? low : low[2]
        b = bull ? high[2] : high
        zbx = box.new(bar_index[2], t, bar_index, b, border_color=na, bgcolor=colZona, extend=extend.right)
        array.push(zBox, zbx)
        array.push(zTop, t)
        array.push(zBot, b)

    if not noDelete
        i = 0
        while i < array.size(zBox)
            t  = array.get(zTop, i)
            b  = array.get(zBot, i)
            bx = array.get(zBox, i)
            partial = high >= b and low <= t
            full    = high >= t and low <= b
            taken = mitigMode == "Even partially (wick)" ? partial : full
            if taken and bar_index > box.get_left(bx) + 2
                box.delete(bx)
                array.remove(zBox, i)
                array.remove(zTop, i)
                array.remove(zBot, i)
            else
                i += 1

// ---------- ACTIVE LOOKBACK INFO ----------
var label infoLbl = na
if showInfo and barstate.islast
    label.delete(infoLbl)
    infoLbl := label.new(bar_index, high, "Lookback: " + str.tostring(len), style=label.style_label_down, color=color.new(color.black, 20), textcolor=color.white, size=size.small)

// ---------- ALERTS ----------
alertcondition(chochUp, "CHoCH LONG",  "Aquila Reale: bullish CHoCH (possible LONG reversal)")
alertcondition(chochDn, "CHoCH SHORT", "Aquila Reale: bearish CHoCH (possible SHORT reversal)")
alertcondition(bosUp,   "BoS LONG",    "Aquila Reale: bullish BoS (LONG continuation)")
alertcondition(bosDn,   "BoS SHORT",   "Aquila Reale: bearish BoS (SHORT continuation)")
````
