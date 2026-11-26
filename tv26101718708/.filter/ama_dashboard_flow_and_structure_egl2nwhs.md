# AMA Dashboard: Flow and Structure

- url: https://www.tradingview.com/script/Egl2nwHS-AMA-Dashboard-Flow-and-Structure/
- type: indicator
- pine_id: PUB;7cfd805021714c93911aca323e03fde0
- version: 1.0

## Description

AMA Dashboard reads the trend from two adaptive moving averages and puts the chart into plain words: which side price is on, how steep the move is, how far it has run, and one grade. Then it grades its own grades on the chart you load it on, and prints the result in the panel.

WHAT IS DRAWN

The AMA, length 120, coloured by the trend: gold when price is above both AMAs, blue when it is below both, grey in between. The long AMA, length 999, drawn faint, with the space between the two filled by side. The protected high or low, drawn from the swing that made it, and the range from that level to the far end of its leg, with its 50 line. Each is one line that moves when the structure changes. A small triangle on the close of any bar where the structure flips.

THE PANEL

TREND. Bullish above both AMAs, Bearish below both, Neutral between them. Nothing is graded while the trend reads Neutral. STRENGTH. The slope of the AMA in ATRs per bar, shown as an angle: 45 degrees is one ATR per bar on any symbol. Strong from 13 degrees, Moderate from 6.7. A slope against the trend reads Counter. MOMENTUM. Whether the move is building or slowing, read on the trend's side, for example Weakly Weakening. FLOW. Net volume as a share of all volume, only where the symbol has volume. Where it has none, as on TVC:GOLD, the row reads No volume and the grade leaves it out. ROC. Rate of change, in percent. LOCATION. How far price sits from the AMA, in ATRs. GRADE. A++, A+, A, B+ or B, from a score that is a share of what the chart can score, so a letter means the same on any symbol, with volume or without. SETUP. One line in plain words when the conditions line up, for example BEARISH SETUP · A · AT THE AMA, and NO SETUP otherwise. It describes the chart. It is not an instruction to trade.

GRADED ON THIS CHART

Every graded bar is checked as the chart moves on. From its close, does price travel one ATR on the trend's side before it travels one ATR against it, within 20 bars? The panel shows how often that happened for each grade and for the setups, beside the same count for every bar. The count starts once both AMAs have their full window, covers every bar the chart has loaded, and is never reset.

WHAT WE MEASURED ON GOLD

On gold's 2 hour chart (TVC:GOLD), 29 April 2020 to 7 October 2026, the higher grades leaned the right way without clearing our significance bar: A grades reached the target first 51.9 times in 100, B grades 49.8 (z 1.41). Setups reached it first 48.3 times in 100, every bar 50.4. Read the grade as context for your own process, and read your own chart's panel before leaning on any letter. Past figures describe the past only.

HOW TO USE IT

Start with TREND and LOCATION: which side the chart sits on, and whether price is stretched from its mean. Take your levels from the structure lines and the range's 50. Treat the grade as a summary of the panel, and the ledger as the chart telling you what each letter has been worth on it.

SETTINGS

The two AMA lengths (120 and 999), the panel's position and size, and the colours. The defaults are set for gold and read the same on any symbol, because every distance is measured in ATRs.

Runs on any symbol and timeframe. Our own maths and code, written from scratch. Free and open source.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bradleypve
//@version=6
indicator("AMA Dashboard: Flow and Structure", shorttitle = "AMA Dashboard", overlay = true, max_bars_back = 1000,
     max_lines_count = 20)

//  AMA Dashboard: Flow and Structure · version 6.1

// ─────────────────────────────────────────────── inputs
string G_AMA = "THE AMA"
int   amaLen  = input.int(120, "Length", minval = 2, maxval = 999, group = G_AMA)
float fastEnd = input.float(2.0, "Fast end", minval = 0.1, maxval = 30.0, group = G_AMA)
float slowEnd = input.float(60.0, "Slow end", minval = 0.1, maxval = 200.0, group = G_AMA)
int   longLen = input.int(999, "Long AMA", minval = 2, maxval = 999, group = G_AMA)

string G_TR = "TREND AND MOMENTUM"
int   lookback = input.int(10, "Angle lookback", minval = 1, maxval = 200, group = G_TR)
float strongA  = input.float(13.0, "Strong angle (degrees)", minval = 0.1, group = G_TR,
     tooltip = "The slope in ATRs per bar, as an angle: 45 degrees is one ATR a bar.")
float modA     = input.float(6.7, "Moderate angle (degrees)", minval = 0.1, group = G_TR)
int   momP     = input.int(5, "Momentum period", minval = 2, maxval = 50, group = G_TR)
float consThr  = input.float(0.7, "Momentum consistency", minval = 0.0, maxval = 1.0, group = G_TR)
int   rocP     = input.int(14, "ROC period", minval = 1, maxval = 500, group = G_TR)

string G_FL = "FLOW · needs volume"
int   volLen  = input.int(20, "Flow length", minval = 1, maxval = 500, group = G_FL)
float maxRel  = input.float(2.0, "Relative volume cap", minval = 1.0, group = G_FL)
float flowThr = input.float(0.25, "Strong flow", minval = 0.0, group = G_FL,
     tooltip = "Net volume as a share of all volume over the flow length, times relative volume, capped.")

string G_LOC = "LOCATION"
float r1     = input.float(1.0, "At the AMA within (ATR)", minval = 0.0, group = G_LOC)
float r2     = input.float(2.0, "Stretched within (ATR)", minval = 0.0, group = G_LOC)
int   riskVL = input.int(14, "Volatility length", minval = 1, maxval = 500, group = G_LOC)

string G_W = "WEIGHTS"
float tw       = input.float(1.0, "Trend strength", group = G_W)
float mw       = input.float(1.0, "Momentum", group = G_W)
float fw       = input.float(1.0, "Flow", group = G_W)
float rocBonus = input.float(0.5, "ROC with the trend", group = G_W)
float fsf      = input.float(1.0, "Flow strength", group = G_W)

string G_ST = "STRUCTURE"
int  swingLen   = input.int(2, "Swing bars each side", minval = 1, maxval = 50, group = G_ST)
bool showLevels = input.bool(true, "Protected level", group = G_ST)
bool showRange  = input.bool(true, "The range and its 50", group = G_ST)
bool showFlips  = input.bool(true, "Flip marks", group = G_ST)

string G_LED = "LEDGER"
bool  ledOn = input.bool(true, "Grade the grades on this chart", group = G_LED)
float ledK  = input.float(1.0, "Target and stop (ATR)", minval = 0.1, group = G_LED)
int   ledH  = input.int(20, "Within (bars)", minval = 1, maxval = 200, group = G_LED)

string G_LOOK = "LOOK"
color  cUp   = input.color(#E0A93B, "Bullish", group = G_LOOK)
color  cDn   = input.color(#6F9CF2, "Bearish", group = G_LOOK)
color  cMute = input.color(#8A94A6, "Muted", group = G_LOOK)
color  cInk  = input.color(#F3EFE6, "Panel text", group = G_LOOK)
color  cBg   = input.color(#0B1730, "Panel colour", group = G_LOOK)
string posIn = input.string("Top right", "Panel position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = G_LOOK)

// ─────────────────────────────────────────────── the AMA (Kaufman's efficiency ratio), seeded where its window fills
f_ama(float src, int len, float fe, float se) =>
    float chg = math.abs(src - src[len])
    float vol = math.sum(math.abs(src - src[1]), len)
    float er  = na(chg) or na(vol) ? na : vol > 0 ? chg / vol : 0.0
    float fsc = 2.0 / (fe + 1.0)
    float ssc = 2.0 / (se + 1.0)
    float sc  = na(er) ? na : math.pow(er * (fsc - ssc) + ssc, 2.0)
    var float a = na
    a := na(sc) or na(a) ? src : a + sc * (src - a)
    a

float price = hlc3
float ama   = f_ama(price, amaLen, fastEnd, slowEnd)
float amaL  = f_ama(price, longLen, fastEnd, slowEnd)
float atr   = ta.atr(14)
bool  warm  = bar_index >= math.max(amaLen, longLen)              // both AMAs have their windows
int   dir   = not warm ? 0 : close > ama and close > amaL ? 1 : close < ama and close < amaL ? -1 : 0   // bullish above both, bearish below both

// ─────────────────────────────────────────────── trend strength: the angle of the slope in ATRs per bar, with the trend
float ang = math.atan((price - price[lookback]) / lookback / atr) * 180.0 / math.pi
f_strength(float a, float aPrev, int d) =>
    string r = "Weak"
    if d == 0
        r := "·"
    else if d * a <= 0
        r := "Counter"
    else
        float ab = math.abs(a)
        bool rising = ab > math.abs(aPrev)
        r := ab > strongA and rising ? "Very Strong" : ab > strongA ? "Strong" : ab > modA and rising ? "Improving Moderate" :
             ab > modA ? "Moderate" : rising ? "Improving Weak" : "Weak"
    r
string strength = f_strength(ang, ang[1], dir)

// ─────────────────────────────────────────────── momentum: the angle's change with the trend, and how consistent it is
float chg  = dir * (ang - ang[momP])
float pchg = dir * (ang[1] - ang[momP + 1])
float cons = 0.0
for i = 0 to momP - 1
    cons += math.sign(dir * (ang[i] - ang[i + 1]))
cons := cons / momP
f_momentum(float ch, float pch, float cs) =>
    string r = "Stable"
    if not na(ch) and not na(pch) and not na(cs)
        float c2 = ch < 0 ? -cs : cs
        bool acc = math.abs(ch) > math.abs(pch)
        bool st  = c2 > consThr
        bool md  = c2 > 0 and c2 <= consThr
        if ch > 0
            r := acc and st ? "Strongly Strengthening" : st ? "Strengthening" : md ? "Weakly Strengthening" : "Stable"
        else if ch < 0
            r := acc and st ? "Strongly Weakening" : st ? "Weakening" : md ? "Weakly Weakening" : "Stable"
    r
string momentum = dir == 0 ? "·" : f_momentum(chg, pchg, cons)
float roc = (close - close[rocP]) / close[rocP] * 100.0

// ─────────────────────────────────────────────── flow: net volume as a share of volume, only where the chart has volume
var bool hasVol = false
if not na(volume) and volume > 0
    hasVol := true
float rngHL  = high - low
float locBar = rngHL > 0 ? (close - low) / rngHL : 0.5
float vAvg   = ta.sma(nz(volume), volLen)
float netRaw = ta.sma(nz(volume) * (2.0 * locBar - 1.0), volLen)
float netF   = vAvg > 0 ? netRaw / vAvg : 0.0
float relV   = vAvg > 0 ? nz(volume) / vAvg : 0.0
float flowS  = math.abs(netF) * math.min(relV, maxRel)
float vwapV  = ta.vwap(hlc3)
string flow = "No volume"
if hasVol
    flow := netF > 0 and close > vwapV ? (locBar > 0.8 ? "Strong Buying" : "Accumulation") :
             netF < 0 and close < vwapV ? (locBar < 0.2 ? "Strong Selling" : "Distribution") : "Neutral"

// ─────────────────────────────────────────────── the grade
f_strScore(string s) =>
    switch s
        "Very Strong"        => 3.5
        "Strong"             => 2.5
        "Improving Moderate" => 2.0
        "Moderate"           => 1.5
        "Improving Weak"     => 1.0
        "Weak"               => 0.5
        => 0.0
f_momScore(string m) =>
    switch m
        "Strongly Strengthening" => 3.5
        "Strengthening"          => 2.5
        "Weakly Strengthening"   => 2.0
        "Stable"                 => 1.5
        "Weakly Weakening"       => 1.0
        "Weakening"              => 0.5
        => 0.0
bool  flowWith = (dir == 1 and (flow == "Strong Buying" or flow == "Accumulation")) or (dir == -1 and (flow == "Strong Selling" or flow == "Distribution"))
bool  flowAgst = (dir == 1 and (flow == "Strong Selling" or flow == "Distribution")) or (dir == -1 and (flow == "Strong Buying" or flow == "Accumulation"))
bool  flowHard = flow == "Strong Buying" or flow == "Strong Selling"
float flowSc   = not hasVol ? 0.0 : (flowWith ? (flowHard ? 3.0 : 2.0) : flowAgst ? 0.5 : 1.0) * fw + (flowWith ? (flowS > flowThr ? 1.0 : 0.5) : 0.0) * fsf
float score    = f_strScore(strength) * tw + f_momScore(momentum) * mw + (math.sign(roc) == dir ? rocBonus : 0.0) + flowSc
float maxSc    = 3.5 * tw + 3.5 * mw + rocBonus + (hasVol ? 3.0 * fw + 1.0 * fsf : 0.0)
float frac     = maxSc > 0 ? score / maxSc : na
float vr      = ta.atr(riskVL) / ta.sma(ta.atr(riskVL), riskVL)
bool  ready   = warm and not na(ang) and not na(ang[momP + 1]) and not na(atr) and not na(vr) and dir != 0
int   gIdx     = not ready or na(frac) ? -1 : frac >= 9.5 / 11.5 ? 0 : frac >= 8.0 / 11.5 ? 1 : frac >= 6.5 / 11.5 ? 2 : frac >= 5.0 / 11.5 ? 3 : 4
var array<string> GN = array.from("A++", "A+", "A", "B+", "B")
string grade = gIdx >= 0 ? array.get(GN, gIdx) : "·"

// ─────────────────────────────────────────────── location and the setup
float nd    = math.abs(close - ama) / atr
string loc  = nd <= r1 * vr ? "AT THE AMA" : nd <= r2 * vr ? "STRETCHED" : "FAR"
int  setupK = gIdx < 0 or na(vr) ? 0 : loc == "AT THE AMA" and nd <= 1.0 and gIdx <= 2 ? 1 : loc == "STRETCHED" and nd <= 1.5 and gIdx <= 3 ? 2 : 0
string setupTxt = not warm ? "THE AMAS NEED " + str.tostring(math.max(amaLen, longLen)) + " BARS" : dir == 0 ? "BETWEEN THE AMAS" :
     setupK == 0 ? "NO SETUP" : (dir == 1 ? "BULLISH SETUP · " : "BEARISH SETUP · ") + grade + " · " + (setupK == 1 ? "AT THE AMA" : "STRETCHED")

// ─────────────────────────────────────────────── structure: confirmed swings, protected levels, flips
f_pivH(int k) =>
    float v = high[k]
    bool ok = bar_index >= 2 * k
    for i = 0 to 2 * k
        if i != k and high[i] >= v
            ok := false
    ok ? v : na
f_pivL(int k) =>
    float v = low[k]
    bool ok = bar_index >= 2 * k
    for i = 0 to 2 * k
        if i != k and low[i] <= v
            ok := false
    ok ? v : na
float ph = f_pivH(swingLen)
float pl = f_pivL(swingLen)

var float lastH = na
var float lastL = na
var int   lastHT = na                                  // the bar each swing was made on
var int   lastLT = na
var bool  brokeH = false
var bool  brokeL = false
var int   state = 0
var float protH = na
var float protL = na
var int   protHT = na
var int   protLT = na
var float rngH = na
var float rngL = na
var int   rngHT = na
var int   rngLT = na
int flip = 0
if not na(ph)
    lastH := ph
    lastHT := bar_index - swingLen
    brokeH := false
if not na(pl)
    lastL := pl
    lastLT := bar_index - swingLen
    brokeL := false
bool upH = not na(lastH) and not brokeH and close > lastH
bool dnL = not na(lastL) and not brokeL and close < lastL
if state == 0
    if upH and not na(lastL)
        state := 1
        flip := 1
        brokeH := true
        protL := lastL
        protLT := lastLT
        protH := na
        rngL := lastL
        rngLT := lastLT
        rngH := lastH
        rngHT := lastHT
    else if dnL and not na(lastH)
        state := -1
        flip := -1
        brokeL := true
        protH := lastH
        protHT := lastHT
        protL := na
        rngL := lastL
        rngLT := lastLT
        rngH := lastH
        rngHT := lastHT
else if state == 1
    if not na(protL) and close < protL and not na(lastH)
        state := -1
        flip := -1
        rngL := protL
        rngLT := protLT
        rngH := lastH
        rngHT := lastHT
        protH := lastH
        protHT := lastHT
        protL := na
        brokeL := brokeL or dnL
    else if upH
        brokeH := true
        if not na(lastL)
            protL := lastL
            protLT := lastLT
            rngL := lastL
            rngLT := lastLT
            rngH := lastH
            rngHT := lastHT
else
    if not na(protH) and close > protH and not na(lastL)
        state := 1
        flip := 1
        rngL := lastL
        rngLT := lastLT
        rngH := protH
        rngHT := protHT
        protL := lastL
        protLT := lastLT
        protH := na
        brokeH := brokeH or upH
    else if dnL
        brokeL := true
        if not na(lastH)
            protH := lastH
            protHT := lastHT
            rngL := lastL
            rngLT := lastLT
            rngH := lastH
            rngHT := lastHT

// ─────────────────────────────────────────────── the ledger: target first or stop first, one ATR each way, within N bars
// cells 0 to 4 are the grades A++ to B, cell 5 the bars that showed a setup, cell 6 every graded bar
var array<int>   pG = array.new_int(0)
var array<int>   pK = array.new_int(0)
var array<int>   pD = array.new_int(0)
var array<float> pT = array.new_float(0)
var array<float> pS = array.new_float(0)
var array<int>   pB = array.new_int(0)
var array<float> lT = array.new_float(7, 0.0)      // target first
var array<float> lS = array.new_float(7, 0.0)      // stop first
var array<float> lN = array.new_float(7, 0.0)      // neither within N bars
f_count(array<float> arr, int gi, int sk) =>
    array.set(arr, gi, array.get(arr, gi) + 1)
    if sk > 0
        array.set(arr, 5, array.get(arr, 5) + 1)
    array.set(arr, 6, array.get(arr, 6) + 1)
if ledOn and barstate.isconfirmed
    int k = array.size(pG) - 1
    while k >= 0
        int   d  = array.get(pD, k)
        float tg = array.get(pT, k)
        float st = array.get(pS, k)
        bool hitS = d > 0 ? low <= st : high >= st
        bool hitT = d > 0 ? high >= tg : low <= tg
        int  done = hitS ? -1 : hitT ? 1 : bar_index - array.get(pB, k) >= ledH ? 0 : 9
        if done != 9
            int gi = array.get(pG, k)
            int sk = array.get(pK, k)
            if done == 1
                f_count(lT, gi, sk)
            else if done == -1
                f_count(lS, gi, sk)
            else
                f_count(lN, gi, sk)
            array.remove(pG, k)
            array.remove(pK, k)
            array.remove(pD, k)
            array.remove(pT, k)
            array.remove(pS, k)
            array.remove(pB, k)
        k -= 1
    if gIdx >= 0 and not na(atr)
        array.push(pG, gIdx)
        array.push(pK, setupK)
        array.push(pD, dir)
        array.push(pT, close + dir * ledK * atr)
        array.push(pS, close - dir * ledK * atr)
        array.push(pB, bar_index)

// ─────────────────────────────────────────────── drawing
color cDir = dir == 1 ? cUp : dir == -1 ? cDn : cMute
float amaD  = bar_index >= amaLen ? ama : na               // drawn once the AMA has its window
float amaLD = bar_index >= longLen ? amaL : na
plot(amaD, "AMA glow", color.new(cDir, 82), 7, editable = false, display = display.pane)
pAma  = plot(amaD, "AMA", cDir, 2)
pLong = plot(amaLD, "Long AMA", color.new(cMute, 40), 1)
fill(pAma, pLong, color.new(cDir, 93), "Between the AMAs")

var line lvl  = na
var line rTop = na
var line rBot = na
var line rmid = na
var linefill rFill = na
color cLvl = state == 1 ? cUp : cDn
float lvlY = state == 1 ? protL : state == -1 ? protH : na
int   lvlT = state == 1 ? protLT : state == -1 ? protHT : na
if showLevels and not na(lvlY) and not na(lvlT)
    if na(lvl)
        lvl := line.new(lvlT, lvlY, bar_index, lvlY, extend = extend.right, color = color.new(cLvl, 15), width = 2)
    line.set_xy1(lvl, lvlT, lvlY)
    line.set_xy2(lvl, bar_index, lvlY)
    line.set_color(lvl, color.new(cLvl, 15))
else if not na(lvl)
    line.delete(lvl)
    lvl := na
int rngT = math.min(rngHT, rngLT)                          // the range starts where its leg began
if showRange and not na(rngH) and not na(rngL) and not na(rngT)
    float mid = (rngH + rngL) / 2.0
    if na(rTop)
        rTop  := line.new(rngT, rngH, bar_index, rngH, extend = extend.right, color = color.new(cMute, 70))
        rBot  := line.new(rngT, rngL, bar_index, rngL, extend = extend.right, color = color.new(cMute, 70))
        rmid  := line.new(rngT, mid, bar_index, mid, extend = extend.right, color = color.new(cMute, 30), style = line.style_dashed)
        rFill := linefill.new(rTop, rBot, color.new(cMute, 94))
    line.set_xy1(rTop, rngT, rngH)
    line.set_xy2(rTop, bar_index, rngH)
    line.set_xy1(rBot, rngT, rngL)
    line.set_xy2(rBot, bar_index, rngL)
    line.set_xy1(rmid, rngT, mid)
    line.set_xy2(rmid, bar_index, mid)
plotshape(showFlips and barstate.isconfirmed and flip == 1, "Bullish flip", shape.triangleup, location.belowbar, color.new(cUp, 10), size = size.tiny)
plotshape(showFlips and barstate.isconfirmed and flip == -1, "Bearish flip", shape.triangledown, location.abovebar, color.new(cDn, 10), size = size.tiny)

// ─────────────────────────────────────────────── the panel
f_pos(string p) =>
    p == "Top right" ? position.top_right : p == "Bottom right" ? position.bottom_right : p == "Top left" ? position.top_left : position.bottom_left
var table tb = table.new(f_pos(posIn), 3, 18, bgcolor = color.new(cBg, 6), border_color = color.new(cInk, 88), border_width = 1, frame_color = color.new(cInk, 80), frame_width = 1)
f_row(int r, string a, string b, color cb, string c) =>
    table.cell(tb, 0, r, a, text_color = cMute, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, b, text_color = cb, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, r, c, text_color = cMute, text_size = size.small, text_halign = text.align_right)
f_pct(float a, float b) =>
    a + b > 0 ? str.tostring(100.0 * a / (a + b), "0.0") : "·"
f_tf() =>
    string s = timeframe.period
    if timeframe.isminutes
        int m = timeframe.multiplier
        s := m % 60 == 0 ? str.tostring(m / 60, "#") + "H" : str.tostring(m) + "m"
    s
if barstate.isfirst
    table.merge_cells(tb, 0, 0, 1, 0)
    table.merge_cells(tb, 0, 8, 2, 8)
    table.merge_cells(tb, 0, 9, 2, 9)
    table.merge_cells(tb, 0, 10, 2, 10)
if barstate.islast
    table.cell(tb, 0, 0, "AMA DASHBOARD", text_color = cUp, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, 0, f_tf(), text_color = cMute, text_size = size.small, text_halign = text.align_right)
    color cS = dir == 1 ? cUp : dir == -1 ? cDn : cMute
    f_row(1, "TREND", dir == 1 ? "BULLISH" : dir == -1 ? "BEARISH" : "NEUTRAL", cS, "")
    f_row(2, "STRENGTH", strength, strength == "Counter" ? cMute : cInk, str.tostring(ang, "0.0") + "°")
    f_row(3, "MOMENTUM", momentum, str.contains(momentum, "Strengthening") ? cS : str.contains(momentum, "Weakening") ? cMute : cInk, "")
    f_row(4, "FLOW", flow, flowWith ? cS : flowAgst ? cMute : cInk, hasVol ? str.tostring(flowS, "0.00") : "")
    f_row(5, "ROC", (roc >= 0 ? "+" : "") + str.tostring(roc, "0.00") + "%", math.sign(roc) == dir ? cS : cMute, "")
    f_row(6, "LOCATION", loc, loc == "FAR" ? cMute : cInk, str.tostring(nd, "0.0") + " ATR")
    table.cell(tb, 0, 7, "GRADE", text_color = cMute, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 7, grade, text_color = gIdx >= 0 and gIdx <= 2 ? cS : cInk, text_size = size.large, text_halign = text.align_left)
    table.cell(tb, 2, 7, gIdx < 0 or na(frac) ? "" : str.tostring(100.0 * frac, "0") + " of 100", text_color = cMute, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 8, setupTxt, text_color = setupK > 0 ? cS : cMute, text_size = size.small, text_halign = text.align_left)
    if ledOn
        table.cell(tb, 0, 9, "GRADED ON THIS CHART", text_color = cUp, text_size = size.tiny, text_halign = text.align_left)
        table.cell(tb, 0, 10, str.tostring(ledK, "0.##") + " ATR TARGET FIRST, " + str.tostring(ledH) + " BARS", text_color = cMute, text_size = size.tiny, text_halign = text.align_left)
        for i = 0 to 6
            float t_ = array.get(lT, i)
            float s_ = array.get(lS, i)
            string nm = i < 5 ? array.get(GN, i) : i == 5 ? "SETUPS" : "EVERY BAR"
            color cr = i < 5 ? cInk : cMute
            table.cell(tb, 0, 11 + i, nm, text_color = cr, text_size = size.small, text_halign = text.align_left)
            table.cell(tb, 1, 11 + i, f_pct(t_, s_), text_color = cr, text_size = size.small, text_halign = text.align_left)
            table.cell(tb, 2, 11 + i, str.tostring(t_ + s_, "#,##0") + " bars", text_color = cMute, text_size = size.tiny, text_halign = text.align_right)

// ─────────────────────────────────────────────── alerts, on the bar's close
bool newSetup = barstate.isconfirmed and setupK > 0 and (setupK[1] == 0 or dir != dir[1])
alertcondition(newSetup and dir == 1, "Bullish setup", "AMA Dashboard: a bullish setup, on the close.")
alertcondition(newSetup and dir == -1, "Bearish setup", "AMA Dashboard: a bearish setup, on the close.")
alertcondition(barstate.isconfirmed and flip != 0, "Structure flip", "AMA Dashboard: the structure flipped, on the close.")
````
