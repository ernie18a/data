# Liquidity Delta Engine 3D [NeBlok]

- url: https://www.tradingview.com/script/DtdFUUcf-Liquidity-Delta-Engine-3D-NeBlok/
- type: indicator
- pine_id: PUB;2993816773b54520b42c03922a3a2844
- version: 1.0

## Description

LIQUIDITY DELTA ENGINE 3D [NeBlok]

Liquidity Delta Engine 3D maps where liquidity sits on the chart, measures who was aggressive inside it (buyers or sellers), and flags four types of order-flow reversal signals. Every signal is graded automatically in an on-chart performance table, so you can see how each one has behaved on the symbol and timeframe you trade.

Everything is drawn in solid neon colors with an optional 3D extrusion effect. Labels and boxes are sized large so they stay readable on busy charts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS

1) THE DELTA ENGINE
Delta is the difference between aggressive buying volume and aggressive selling volume.

By default, the script requests lower-timeframe (intrabar) data. It classifies each sub-bar's volume as buying or selling, which gives a much more accurate delta than estimating from the chart bar alone. The intrabar timeframe is picked automatically:
- 1-minute data on charts up to 15m
- 5-minute on charts up to 4H
- 15-minute on charts up to 1D
- 60-minute above that

You can override it in the settings.

If intrabar data isn't available, the script falls back to a Bar Approximation, which splits volume based on where the bar closed within its range. The bottom row of the performance table always shows which delta source is active.

The script also builds Cumulative Delta (CVD), a running total of delta. It is used for divergence detection and can be viewed in the Data Window.

2) LIQUIDITY ZONES
Zones form at confirmed swing highs (supply, red) and swing lows (demand, aqua). A swing must have at least average volume to qualify. Each zone is sized from the wick of the pivot candle, with its height kept between a minimum and maximum ATR multiple so zones stay readable and proportional.

Each zone is split into horizontal rows that form a mini delta profile. Every row shows the net delta traded at that price during the swing.
- Bright rows: delta favored the zone's side (selling in supply, buying in demand)
- Dim rows: delta went against the zone's side

The tag on the right side of each zone shows two numbers:
- % = LIQUIDITY REMAINING. 100% means price has not touched the zone. As price trades into it, the percentage drops, showing how much of the zone has been consumed.
- Δ = the net delta traded inside the zone while it formed

When price closes through the far side of a zone, the zone is marked broken. It stops extending and fades out, or it is removed entirely if you turn off "Keep Broken Zones."

3) REVERSAL SIGNALS
ABS (Absorption): Aggressive flow spikes at a local high or low, but price closes against it. Example: heavy buying at a new high, yet the bar closes in its lower half. Passive sellers absorbed the buyers.

EXH (Exhaustion): Price prints a new local high or low on weak delta after a stretch of sustained pressure in that direction. The move is running out of participants.

DIV (Delta Divergence): Price makes a higher high or lower low, but Cumulative Delta does not confirm it.

REJ (Zone Rejection): Price wicks into an active liquidity zone and closes back outside it, with delta agreeing with the zone. Example: wick into demand, close above it, positive delta.

Green labels below bars are bullish. Magenta labels above bars are bearish. Hover over any label for a short explanation of why it fired.

4) PERFORMANCE TABLE
Each signal is evaluated a set number of bars after it fires (default: 10). It counts as a win if price has moved in the signal's direction from the close of the signal bar. You can require a minimum favorable move measured in ATR, so small drifts don't count as wins.

The table shows total signals, wins, and win rate for each signal type. It lets you judge which signals are worth trusting on your instrument and timeframe before you rely on them.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO USE IT

1. Start with context. Active zones with a high liquidity-remaining % are untested areas where a reaction is more likely. Zones that are already down to a low % have been heavily consumed and are more likely to break.

2. Read the rows. A demand zone full of bright rows was built on real buying. A zone full of dim rows formed against the flow and deserves less confidence.

3. Wait for a signal at a level. Signals carry the most weight when they fire at or near an active zone. A single signal in the middle of nowhere is weaker than one that lines up with a level.

4. Look for stacking. An ABS or EXH that fires at a zone and is followed by a REJ of that same zone is a stronger read than any single label.

5. Check the table. If a signal type shows a poor win rate on your symbol and timeframe, turn it off or tighten its settings. Different markets behave differently. Let the stats guide you instead of assuming every signal works everywhere.

6. Manage risk your own way. The script does not generate stops or targets. A common approach is to place stops beyond the far edge of the zone the signal reacted from.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS GUIDE

Delta Engine
- Delta Source: Intrabar (recommended) or Bar Approximation
- Intrabar Timeframe: leave blank for auto, or set your own

Liquidity Zones
- Pivot Strength: bars on each side needed to confirm a swing. Higher = fewer, more significant zones.
- Profile Rows: number of delta rows per zone (1 to 10)
- Min / Max Zone Height: zone thickness limits in ATR
- Min Pivot Volume: a swing needs this multiple of average volume to create a zone. Set to 0 to disable.
- Max Zones: cap on zones kept on the chart
- Project Right: how far active zones extend past the current bar
- Break On: a zone breaks on a candle Close or a Wick through it
- Keep Broken Zones / Show Row Delta / Show Net Delta: display toggles

Reversal Signals
- Toggle each signal type on or off
- Extreme Lookback: bars used to define a local high or low for ABS and EXH
- ABS Delta Spike / Volume Spike: how unusual the flow must be. Higher = fewer, stronger signals.
- EXH Max Delta: how weak delta must be at the new extreme. Lower = stricter.
- DIV Pivot Length / Max Bars Between Pivots: divergence sensitivity
- Cooldown: minimum bars between repeats of the same signal
- Max Signal Labels: limits chart clutter

Performance Table
- Evaluate After: bars until a signal is graded
- Min Favorable Move (ATR): the move required to count as a win
- Position: where the table sits on the chart

Style
- Neon colors for zones, signals, and the table
- 3D Extrusion on/off, plus depth in bars and ATR
- Separate size controls for signal labels, zone tags, row text, and the table

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS

Alerts are built in for bullish and bearish versions of all four signals. They fire once per bar close. To use them:
1. Create an alert on this indicator.
2. Choose "Any alert() function call."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IMPORTANT NOTES

- Volume data is required. This script will not work properly on symbols without volume, such as some cash indices. Use futures, stocks, ETFs, or crypto.
- Intrabar history is limited. TradingView caps how much lower-timeframe data a script can load. On long charts, the oldest bars may run on Bar Approximation, which affects older zone profiles and performance stats.
- ABS signals need intrabar data. Under Bar Approximation, delta is derived from where the bar closed, so the "heavy flow but closed against it" condition cannot occur.
- Zones and divergences confirm with a delay. A swing is only confirmed after "Pivot Strength" bars have closed, and a divergence after "DIV Pivot Length" bars. When they confirm, zones and DIV labels are drawn back at the original pivot bar. They did not exist in real time until confirmation.
- ABS, EXH, and REJ are evaluated on bar close and do not repaint once the bar closes.
- The performance table is a simple directional measurement, not a full backtest. It does not include commissions, slippage, stops, or position sizing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument.

Trading involves substantial risk of loss and is not suitable for every investor. Futures and leveraged products carry additional risk, and you can lose more than your initial investment.

Past performance, including any statistics shown in this script's performance table, does not guarantee future results. Signals can and will be wrong.

You are solely responsible for your own trading decisions. Always do your own research, test thoroughly, and consult a licensed financial professional before making any investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
indicator("Liquidity Delta Engine 3D [NeBlok]", "LDE 3D [NeBlok]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 500)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════
string G_D = "Delta Engine"
string deltaMode = input.string("Intrabar (LTF)", "Delta Source", options = ["Intrabar (LTF)", "Bar Approximation"], group = G_D, tooltip = "Intrabar: classifies each lower-timeframe bar's volume as buy or sell (much more accurate). Bar Approximation: splits volume by where the close sits in the bar's range. ABS signals need intrabar data to fire.")
string ltfIn     = input.timeframe("", "Intrabar Timeframe (blank = auto)", group = G_D)

string G_Z = "Liquidity Zones"
int    pvLen      = input.int(10, "Pivot Strength", minval = 2, maxval = 50, group = G_Z)
int    nRows      = input.int(5, "Profile Rows", minval = 1, maxval = 10, group = G_Z)
float  minH       = input.float(0.35, "Min Zone Height (ATR)", minval = 0.05, step = 0.05, group = G_Z)
float  maxH       = input.float(1.2, "Max Zone Height (ATR)", minval = 0.1, step = 0.05, group = G_Z)
float  zVolMult   = input.float(0.8, "Min Pivot Volume (x avg)", minval = 0.0, step = 0.1, group = G_Z)
int    maxZones   = input.int(30, "Max Zones", minval = 2, maxval = 40, group = G_Z)
int    projBars   = input.int(20, "Project Right (bars)", minval = 0, maxval = 200, group = G_Z)
string breakOn    = input.string("Close", "Break On", options = ["Close", "Wick"], group = G_Z)
bool   keepBroken = input.bool(true, "Keep Broken Zones (faded)", group = G_Z)
bool   showRowTx  = input.bool(true, "Show Row Delta", group = G_Z)
bool   showZDelta = input.bool(true, "Show Net Delta On Tag", group = G_Z)

string G_S = "Reversal Signals"
bool   showAbs = input.bool(true, "Absorption (ABS)", group = G_S, inline = "s1")
bool   showExh = input.bool(true, "Exhaustion (EXH)", group = G_S, inline = "s1")
bool   showDiv = input.bool(true, "Delta Divergence (DIV)", group = G_S, inline = "s2")
bool   showRej = input.bool(true, "Zone Rejection (REJ)", group = G_S, inline = "s2")
int    sigLen  = input.int(20, "Extreme Lookback", minval = 5, group = G_S)
float  absMult = input.float(1.5, "ABS: Delta Spike (x avg)", minval = 0.5, step = 0.1, group = G_S)
float  volMult = input.float(1.2, "ABS: Volume Spike (x avg)", minval = 0.5, step = 0.1, group = G_S)
float  exhMult = input.float(0.6, "EXH: Max Delta (x avg)", minval = 0.1, step = 0.05, group = G_S)
int    divLen  = input.int(5, "DIV: Pivot Length", minval = 2, group = G_S)
int    divGap  = input.int(60, "DIV: Max Bars Between Pivots", minval = 5, group = G_S)
int    coolDn  = input.int(5, "Cooldown (bars, per signal)", minval = 0, group = G_S)
int    maxSigs = input.int(120, "Max Signal Labels", minval = 10, maxval = 150, group = G_S)

string G_P = "Performance Table"
bool   showTbl  = input.bool(true, "Show Table", group = G_P)
int    evalBars = input.int(10, "Evaluate After (bars)", minval = 1, group = G_P)
float  winAtr   = input.float(0.0, "Min Favorable Move (ATR)", minval = 0.0, step = 0.1, group = G_P)
string tblPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_P)

string G_V = "Style"
color  bullZ  = input.color(#00FFD0, "Demand Zone", group = G_V, inline = "z")
color  bearZ  = input.color(#FF1F5A, "Supply Zone", group = G_V, inline = "z")
color  bullS  = input.color(#39FF14, "Bull Signal", group = G_V, inline = "sg")
color  bearS  = input.color(#FF00E6, "Bear Signal", group = G_V, inline = "sg")
color  accent = input.color(#00E5FF, "Table Accent", group = G_V)
bool   use3D  = input.bool(true, "3D Extrusion", group = G_V)
int    depthX = input.int(2, "3D Depth (bars)", minval = 1, maxval = 10, group = G_V)
float  depthY = input.float(0.15, "3D Depth (ATR)", minval = 0.02, step = 0.01, group = G_V)
string sigSz  = input.string("Large", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_V)
string tagSz  = input.string("Large", "Zone Tag Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_V)
string rowSz  = input.string("Normal", "Row Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_V)
string tblSz  = input.string("Normal", "Table Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_V)

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════
toSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

posOf(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Solid darker shade of a neon color (used for 3D extrusion faces, not a gradient)
darken(color c, float k) =>
    color.rgb(color.r(c) * k, color.g(c) * k, color.b(c) * k)

// ═════════════════════════════════════════════════════════════════════════════
// DELTA ENGINE
// ═════════════════════════════════════════════════════════════════════════════
int    tfSec   = timeframe.in_seconds()
string autoLtf = tfSec <= 900 ? "1" : tfSec <= 14400 ? "5" : tfSec <= 86400 ? "15" : "60"
string ltf     = ltfIn == "" ? autoLtf : ltfIn

[lO, lC, lV] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume], ignore_invalid_timeframe = true)

float buyV    = 0.0
float sellV   = 0.0
bool  usedLtf = false
int   nIntra  = lV.size()

if deltaMode == "Intrabar (LTF)" and nIntra > 0
    usedLtf := true
    for i = 0 to nIntra - 1
        float v = nz(lV.get(i))
        float o = lO.get(i)
        float c = lC.get(i)
        if c > o
            buyV += v
        else if c < o
            sellV += v
        else
            buyV  += v * 0.5
            sellV += v * 0.5
else
    float rng = high - low
    float bp  = rng > 0 ? (close - low) / rng : 0.5
    buyV  := nz(volume) * bp
    sellV := nz(volume) * (1.0 - bp)

float delta = buyV - sellV
float cvd   = ta.cum(delta)

// ═════════════════════════════════════════════════════════════════════════════
// STATS
// ═════════════════════════════════════════════════════════════════════════════
float atr    = ta.atr(14)
float volMA  = ta.sma(nz(volume), 20)
float absDMA = ta.sma(math.abs(delta), 20)
float hiN    = ta.highest(high, sigLen)
float loN    = ta.lowest(low, sigLen)
float dPrior = math.sum(delta, 5)[1]
float hiR    = ta.highest(high, pvLen)
float loR    = ta.lowest(low, pvLen)
bool  conf   = barstate.isconfirmed

// ═════════════════════════════════════════════════════════════════════════════
// ZONE OBJECT
// ═════════════════════════════════════════════════════════════════════════════
type Zone
    box        frame
    box        shade
    array<box> rows
    label      tag
    label      tagShade
    float      top
    float      bot
    int        dir
    float      extreme
    float      netDelta
    bool       active

var array<Zone> zones = array.new<Zone>()

method wipe(Zone z) =>
    z.frame.delete()
    if not na(z.shade)
        z.shade.delete()
    for b in z.rows
        b.delete()
    z.tag.delete()
    if not na(z.tagShade)
        z.tagShade.delete()

// Distributes the delta of every bar in the pivot window into the zone's rows,
// weighted by how much of each bar's range overlaps each row.
profileRows(int span, float zt, float zb, int rowsN) =>
    array<float> rd = array.new<float>(rowsN, 0.0)
    float rh = (zt - zb) / rowsN
    for i = 0 to span
        float hi = high[i]
        float lo = low[i]
        float d  = nz(buyV[i]) - nz(sellV[i])
        for k = 0 to rowsN - 1
            float rT = zt - k * rh
            float rB = rT - rh
            float ov = math.max(0.0, math.min(hi, rT) - math.max(lo, rB))
            float f  = hi > lo ? ov / (hi - lo) : (lo <= rT and lo >= rB ? 1.0 : 0.0)
            if f > 0
                rd.set(k, rd.get(k) + d * f)
    rd

// Liquidity remaining: 100% = untouched, 0% = fully consumed
remFrom(int d, float ext, float zt, float zb) =>
    float h = math.max(zt - zb, syminfo.mintick)
    float r = d == 1 ? (ext >= zt ? 1.0 : (ext - zb) / h) : (ext <= zb ? 1.0 : (zt - ext) / h)
    math.max(0.0, math.min(1.0, r))

tagText(float rem, float net) =>
    string t = str.tostring(math.round(rem * 100)) + "%"
    showZDelta ? t + "  Δ " + (net >= 0 ? "+" : "") + str.tostring(net, format.volume) : t

overlapsActive(float t, float b, int d) =>
    bool hit = false
    for z in zones
        if z.active and z.dir == d and b < z.top and t > z.bot
            hit := true
            break
    hit

newZone(int d, int lx, float zt, float zb, float ext) =>
    color zc   = d == 1 ? bullZ : bearZ
    color zd   = darken(zc, 0.3)
    array<float> rd = profileRows(2 * pvLen, zt, zb, nRows)
    float net  = rd.sum()
    int   rx0  = bar_index + projBars
    float dy   = atr * depthY
    float mid  = (zt + zb) / 2
    string txt = tagText(remFrom(d, ext, zt, zb), net)

    // 3D back face (drawn first so it sits behind)
    box sh = na
    if use3D
        sh := box.new(lx + depthX, zt - dy, rx0 + depthX, zb - dy, border_color = zd, border_width = 2, bgcolor = color.new(zd, 15))

    // Delta profile rows
    float rh = (zt - zb) / nRows
    array<box> rows = array.new<box>()
    for k = 0 to nRows - 1
        float rT    = zt - k * rh
        float rB    = rT - rh
        float v     = rd.get(k)
        bool  agree = d == 1 ? v > 0 : v < 0
        rows.push(box.new(lx, rT, rx0, rB, border_color = color.new(zc, 75), border_width = 1, bgcolor = color.new(zc, agree ? 55 : 85), text = showRowTx ? str.tostring(v, format.volume) : "", text_size = toSize(rowSz), text_color = agree ? #FFFFFF : zc, text_halign = text.align_right))

    // Neon front frame
    box fr = box.new(lx, zt, rx0, zb, border_color = zc, border_width = 2, bgcolor = color.new(zc, 100))

    // 3D tag
    label tsh = na
    if use3D
        tsh := label.new(rx0 + 2, mid - dy, txt, style = label.style_label_left, color = zd, textcolor = zd, size = toSize(tagSz))
    label tg = label.new(rx0 + 1, mid, txt, style = label.style_label_left, color = zc, textcolor = #000000, size = toSize(tagSz), tooltip = (d == 1 ? "Demand" : "Supply") + " liquidity zone. % = liquidity remaining (100% = untouched). Δ = net delta traded inside the zone while it formed.")

    zones.push(Zone.new(fr, sh, rows, tg, tsh, zt, zb, d, ext, net, true))

    // Enforce cap: drop oldest broken zone first, else oldest zone
    if zones.size() > maxZones
        int idx = 0
        for j = 0 to zones.size() - 1
            if not zones.get(j).active
                idx := j
                break
        zones.remove(idx).wipe()

// ═════════════════════════════════════════════════════════════════════════════
// UPDATE EXISTING ZONES (+ rejection detection)
// ═════════════════════════════════════════════════════════════════════════════
bool bullRej = false
bool bearRej = false
int  rx      = bar_index + projBars

if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        if z.active
            if z.dir == 1
                z.extreme := math.min(z.extreme, low)
                if low <= z.top and low >= z.bot and close > z.top and delta > 0
                    bullRej := true
                float px = breakOn == "Close" ? close : low
                if px < z.bot
                    z.active := false
            else
                z.extreme := math.max(z.extreme, high)
                if high >= z.bot and high <= z.top and close < z.bot and delta < 0
                    bearRej := true
                float px = breakOn == "Close" ? close : high
                if px > z.top
                    z.active := false

            if not z.active
                if keepBroken
                    color zc = z.dir == 1 ? bullZ : bearZ
                    z.frame.set_right(bar_index)
                    z.frame.set_border_color(color.new(zc, 65))
                    for b in z.rows
                        b.set_right(bar_index)
                        b.set_bgcolor(color.new(zc, 90))
                        b.set_border_color(color.new(zc, 85))
                        b.set_text_color(color.new(zc, 60))
                    if not na(z.shade)
                        z.shade.set_right(bar_index + depthX)
                        z.shade.set_bgcolor(color.new(darken(zc, 0.3), 75))
                        z.shade.set_border_color(color.new(darken(zc, 0.3), 60))
                    z.tag.delete()
                    if not na(z.tagShade)
                        z.tagShade.delete()
                else
                    z.wipe()
                    zones.remove(i)
            else if barstate.islast
                string txt = tagText(remFrom(z.dir, z.extreme, z.top, z.bot), z.netDelta)
                z.frame.set_right(rx)
                for b in z.rows
                    b.set_right(rx)
                if not na(z.shade)
                    z.shade.set_right(rx + depthX)
                z.tag.set_x(rx + 1)
                z.tag.set_text(txt)
                if not na(z.tagShade)
                    z.tagShade.set_x(rx + 2)
                    z.tagShade.set_text(txt)

// ═════════════════════════════════════════════════════════════════════════════
// SIGNAL + PERFORMANCE STATE
// ═════════════════════════════════════════════════════════════════════════════
var array<int>   pBar    = array.new<int>()
var array<float> pPx     = array.new<float>()
var array<int>   pDir    = array.new<int>()
var array<int>   pTyp    = array.new<int>()
var array<float> pAtr    = array.new<float>()
var array<int>   tot     = array.new<int>(4, 0)
var array<int>   wins    = array.new<int>(4, 0)
var array<int>   lastSig = array.new<int>(8, -100000)
var array<label> sigLbls = array.new<label>()

// t: 0 ABS, 1 EXH, 2 DIV, 3 REJ
fire(int t, bool bull, int x, float anchor, string txt, string tip) =>
    int  k     = t * 2 + (bull ? 0 : 1)
    bool fired = false
    if bar_index - lastSig.get(k) > coolDn
        fired := true
        lastSig.set(k, bar_index)
        color  c  = bull ? bullS : bearS
        color  cd = darken(c, 0.3)
        string st = bull ? label.style_label_up : label.style_label_down
        float  y  = bull ? anchor - atr * 0.25 : anchor + atr * 0.25
        float  dy = atr * depthY
        string sz = toSize(sigSz)
        if use3D
            sigLbls.push(label.new(x + 1, y - dy, txt, style = st, color = cd, textcolor = cd, size = sz))
        sigLbls.push(label.new(x, y, txt, style = st, color = c, textcolor = #000000, size = sz, tooltip = tip))
        while sigLbls.size() > maxSigs * 2
            sigLbls.shift().delete()
        // Register for time-based evaluation (entry = close of the confirmation bar, no lookahead)
        pBar.push(bar_index)
        pPx.push(close)
        pDir.push(bull ? 1 : -1)
        pTyp.push(t)
        pAtr.push(atr)
    fired

// ═════════════════════════════════════════════════════════════════════════════
// SIGNAL CONDITIONS
// ═════════════════════════════════════════════════════════════════════════════
// ABS: aggressive flow spikes at a local extreme but price closes against it
bool bearAbsC = showAbs and conf and delta > 0 and delta >= absDMA * absMult and nz(volume) >= volMA * volMult and close <= hl2 and high >= hiN
bool bullAbsC = showAbs and conf and delta < 0 and -delta >= absDMA * absMult and nz(volume) >= volMA * volMult and close >= hl2 and low <= loN

// EXH: new local extreme on weak delta after sustained pressure
bool bullExhC = showExh and conf and low <= loN and math.abs(delta) <= absDMA * exhMult and close >= hl2 and dPrior < 0
bool bearExhC = showExh and conf and high >= hiN and math.abs(delta) <= absDMA * exhMult and close <= hl2 and dPrior > 0

// DIV: price pivot vs CVD pivot disagreement
float dph = ta.pivothigh(high, divLen, divLen)
float dpl = ta.pivotlow(low, divLen, divLen)
var float lastPH    = na
var float lastPHcvd = na
var int   lastPHbar = na
var float lastPL    = na
var float lastPLcvd = na
var int   lastPLbar = na
bool bearDivC = false
bool bullDivC = false
int  divBar   = bar_index - divLen

if not na(dph)
    float c = cvd[divLen]
    if not na(lastPH) and dph > lastPH and c < lastPHcvd and divBar - lastPHbar <= divGap
        bearDivC := showDiv and conf
    lastPH    := dph
    lastPHcvd := c
    lastPHbar := divBar

if not na(dpl)
    float c = cvd[divLen]
    if not na(lastPL) and dpl < lastPL and c > lastPLcvd and divBar - lastPLbar <= divGap
        bullDivC := showDiv and conf
    lastPL    := dpl
    lastPLcvd := c
    lastPLbar := divBar

// REJ: wick into an active zone, close back out, delta agrees
bool bullRejC = showRej and conf and bullRej
bool bearRejC = showRej and conf and bearRej

// ═════════════════════════════════════════════════════════════════════════════
// FIRE SIGNALS (stacked so same-bar labels don't overlap)
// ═════════════════════════════════════════════════════════════════════════════
bool fBullAbs = false
bool fBearAbs = false
bool fBullExh = false
bool fBearExh = false
bool fBullDiv = false
bool fBearDiv = false
bool fBullRej = false
bool fBearRej = false
int  bs = 0
int  ss = 0

if bullAbsC
    fBullAbs := fire(0, true, bar_index, low - bs * atr, "ABS", "Bullish Absorption: heavy sell delta at a local low, but price closed in the upper half. Passive buyers absorbed the selling.")
    bs += fBullAbs ? 1 : 0
if bearAbsC
    fBearAbs := fire(0, false, bar_index, high + ss * atr, "ABS", "Bearish Absorption: heavy buy delta at a local high, but price closed in the lower half. Passive sellers absorbed the buying.")
    ss += fBearAbs ? 1 : 0
if bullExhC
    fBullExh := fire(1, true, bar_index, low - bs * atr, "EXH", "Bullish Exhaustion: new local low printed on weak delta after sustained selling. Sellers are running out.")
    bs += fBullExh ? 1 : 0
if bearExhC
    fBearExh := fire(1, false, bar_index, high + ss * atr, "EXH", "Bearish Exhaustion: new local high printed on weak delta after sustained buying. Buyers are running out.")
    ss += fBearExh ? 1 : 0
if bullRejC
    fBullRej := fire(3, true, bar_index, low - bs * atr, "REJ", "Bullish Rejection: price wicked into an active demand zone and closed back above it with positive delta.")
    bs += fBullRej ? 1 : 0
if bearRejC
    fBearRej := fire(3, false, bar_index, high + ss * atr, "REJ", "Bearish Rejection: price wicked into an active supply zone and closed back below it with negative delta.")
    ss += fBearRej ? 1 : 0
if bullDivC
    fBullDiv := fire(2, true, divBar, low[divLen], "DIV", "Bullish Delta Divergence: price made a lower low but cumulative delta made a higher low.")
if bearDivC
    fBearDiv := fire(2, false, divBar, high[divLen], "DIV", "Bearish Delta Divergence: price made a higher high but cumulative delta made a lower high.")

// ═════════════════════════════════════════════════════════════════════════════
// CREATE NEW ZONES (after updates so a new zone can't trigger on its own bar)
// ═════════════════════════════════════════════════════════════════════════════
float ph    = ta.pivothigh(high, pvLen, pvLen)
float pl    = ta.pivotlow(low, pvLen, pvLen)
bool  volOk = nz(volume[pvLen]) >= nz(volMA[pvLen]) * zVolMult

if not na(pl) and volOk and not na(atr)
    float bodyB = math.min(open[pvLen], close[pvLen])
    float h     = math.max(atr * minH, math.min(atr * maxH, bodyB - pl))
    float zt    = pl + h
    if not overlapsActive(zt, pl, 1)
        newZone(1, bar_index - pvLen, zt, pl, loR)

if not na(ph) and volOk and not na(atr)
    float bodyT = math.max(open[pvLen], close[pvLen])
    float h     = math.max(atr * minH, math.min(atr * maxH, ph - bodyT))
    float zb    = ph - h
    if not overlapsActive(ph, zb, -1)
        newZone(-1, bar_index - pvLen, ph, zb, hiR)

// ═════════════════════════════════════════════════════════════════════════════
// TIME-BASED PERFORMANCE EVALUATION
// ═════════════════════════════════════════════════════════════════════════════
if conf and pBar.size() > 0
    for i = pBar.size() - 1 to 0
        if bar_index - pBar.get(i) >= evalBars
            int   t  = pTyp.get(i)
            float mv = (close - pPx.get(i)) * pDir.get(i)
            tot.set(t, tot.get(t) + 1)
            if mv > winAtr * pAtr.get(i)
                wins.set(t, wins.get(t) + 1)
            pBar.remove(i)
            pPx.remove(i)
            pDir.remove(i)
            pTyp.remove(i)
            pAtr.remove(i)

// ═════════════════════════════════════════════════════════════════════════════
// PERFORMANCE TABLE
// ═════════════════════════════════════════════════════════════════════════════
var table tb     = table.new(posOf(tblPos), 4, 7, bgcolor = #070B14, frame_color = accent, frame_width = 2, border_color = color.new(accent, 60), border_width = 1)
var bool  merged = false

if showTbl and barstate.islast
    string ts    = toSize(tblSz)
    color  bg    = #070B14
    color  hdrBg = #0F1628
    tb.cell(0, 0, "REVERSAL PERFORMANCE · " + str.tostring(evalBars) + " BARS", text_color = accent, text_size = ts, bgcolor = hdrBg)
    tb.cell(0, 6, "Δ SOURCE: " + (usedLtf ? "INTRABAR (" + ltf + ")" : "BAR APPROX"), text_color = usedLtf ? bullS : bearS, text_size = ts, bgcolor = hdrBg)
    if not merged
        tb.merge_cells(0, 0, 3, 0)
        tb.merge_cells(0, 6, 3, 6)
        merged := true
    tb.cell(0, 1, "SIGNAL", text_color = #FFFFFF, text_size = ts, bgcolor = bg)
    tb.cell(1, 1, "TOTAL",  text_color = #FFFFFF, text_size = ts, bgcolor = bg)
    tb.cell(2, 1, "WINS",   text_color = #FFFFFF, text_size = ts, bgcolor = bg)
    tb.cell(3, 1, "WIN %",  text_color = #FFFFFF, text_size = ts, bgcolor = bg)
    array<string> names = array.from("ABS", "EXH", "DIV", "REJ")
    for r = 0 to 3
        int    t  = tot.get(r)
        int    w  = wins.get(r)
        float  wr = t > 0 ? w * 100.0 / t : na
        color  wc = t == 0 ? #FFFFFF : wr >= 50 ? bullS : bearS
        tb.cell(0, r + 2, names.get(r), text_color = accent, text_size = ts, bgcolor = bg)
        tb.cell(1, r + 2, str.tostring(t), text_color = #FFFFFF, text_size = ts, bgcolor = bg)
        tb.cell(2, r + 2, str.tostring(w), text_color = #FFFFFF, text_size = ts, bgcolor = bg)
        tb.cell(3, r + 2, t > 0 ? str.tostring(wr, "#.##") + "%" : "—", text_color = wc, text_size = ts, bgcolor = bg)

// ═════════════════════════════════════════════════════════════════════════════
// DATA WINDOW
// ═════════════════════════════════════════════════════════════════════════════
plot(delta, "Bar Delta", color = delta >= 0 ? bullZ : bearZ, display = display.data_window)
plot(cvd, "Cumulative Delta", color = accent, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS (fire once per bar close)
// ═════════════════════════════════════════════════════════════════════════════
string tk = syminfo.ticker + " @ " + str.tostring(close, format.mintick)
if fBullAbs
    alert("LDE [NeBlok] Bullish ABS on " + tk, alert.freq_once_per_bar_close)
if fBearAbs
    alert("LDE [NeBlok] Bearish ABS on " + tk, alert.freq_once_per_bar_close)
if fBullExh
    alert("LDE [NeBlok] Bullish EXH on " + tk, alert.freq_once_per_bar_close)
if fBearExh
    alert("LDE [NeBlok] Bearish EXH on " + tk, alert.freq_once_per_bar_close)
if fBullDiv
    alert("LDE [NeBlok] Bullish DIV on " + tk, alert.freq_once_per_bar_close)
if fBearDiv
    alert("LDE [NeBlok] Bearish DIV on " + tk, alert.freq_once_per_bar_close)
if fBullRej
    alert("LDE [NeBlok] Bullish REJ on " + tk, alert.freq_once_per_bar_close)
if fBearRej
    alert("LDE [NeBlok] Bearish REJ on " + tk, alert.freq_once_per_bar_close)
````
