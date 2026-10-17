# Fib OTE + FVG Confluence [Viprasol]

- url: https://www.tradingview.com/script/YAsO2ohM-Fib-OTE-FVG-Confluence-Viprasol/
- type: indicator
- pine_id: PUB;4bcd666aa8e24657b65c98872b329458
- version: 1.0

## Description

Fib OTE + FVG Confluence [Viprasol] — high-probability ICT entries where two edges agree

═══════════════════════════════════════════════════════════
THE IDEA
═══════════════════════════════════════════════════════════

A Fair Value Gap is a good entry zone. An OTE (Optimal Trade Entry) retracement is a
good entry zone. But an FVG that sits INSIDE the OTE — that's the setup ICT traders
actually wait for. This tool maps the higher-timeframe OTE / premium-discount zone,
detects Fair Value Gaps, and does the one thing that matters: it highlights and ALERTS
you when price taps an FVG that lands inside the OTE.

═══════════════════════════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════════════════════════

1. HTF OTE MAP — From the previous candle range of your chosen higher timeframe
   (non-repainting), it builds the Fibonacci map: the OTE band (default 0.618-0.786),
   the equilibrium line (0.5) that splits premium from discount, and a directional bias
   (Auto from the last HTF candle, or force Long/Short). In a long bias the OTE sits in
   discount (below equilibrium) — where you want to buy; in a short bias it sits in
   premium.

2. FAIR VALUE GAPS — Standard 3-candle imbalances (bullish `low > high[2]`, bearish
   `high < low[2]`), with an optional displacement filter and a minimum-size filter to
   cut noise. Each gap is drawn as a box and tracked until filled (Wick / Close /
   Average mitigation).

3. CONFLUENCE — the point of the tool. A gap is "confluent" when it overlaps the OTE
   band (strict) or, in the looser mode, when a bullish gap sits in discount / a bearish
   gap sits in premium. Confluent gaps are highlighted with a ★. Turn on "Show ONLY
   Confluent FVGs" and the chart reduces to just the high-probability zones.

4. ALERTS — Get notified when price TAPS a confluent FVG (and optionally when one
   forms). One alert, delivered via app / email / SMS / webhook (Text or JSON message).

═══════════════════════════════════════════════════════════
ALERTS SETUP
═══════════════════════════════════════════════════════════

Create one alert → Condition: "Fib OTE + FVG Confluence" → "Any alert() function call",
then pick your delivery (app/email/SMS/webhook) in the dialog. Switch Message Format to
"JSON (webhook)" for bot/automation-friendly output. Messages carry direction, event
(FORMED/TAPPED), and the gap's price range.

═══════════════════════════════════════════════════════════
SETTINGS
═══════════════════════════════════════════════════════════

• HTF Fibonacci / OTE: timeframe, bias (Auto/Long/Short), OTE start/end, show map, colors.
• Fair Value Gaps: min gap %, displacement filter, fill mode, show-only-confluent, colors, box extend.
• Confluence & Alerts: confluence rule (Inside OTE / Favored half), highlight color, form/tap
  alert toggles, frequency (once-per-bar-close = no repaint), Text/JSON.

═══════════════════════════════════════════════════════════
HOW TO USE
═══════════════════════════════════════════════════════════

1. Set the OTE higher timeframe (e.g. Daily on an intraday chart).
2. Let Auto bias pick direction, or force Long/Short to your plan.
3. Enable "Show ONLY Confluent FVGs" to see just gaps inside the OTE.
4. Create the alert and wait for a tap of a ★ confluent gap — that's your cue to do
   your own analysis and manage risk.

═══════════════════════════════════════════════════════════
LIMITATIONS — PLEASE READ
═══════════════════════════════════════════════════════════

• This is an awareness / confluence tool, not a strategy or signal service — no buy/sell
  calls. A confluent tap is a location of interest, not a guarantee.
• The OTE map uses the previous HTF candle range and updates as new HTF candles form;
  it reflects current context, not a fixed historical grid.
• FVGs are detected on the chart timeframe; confluence is judged against the OTE active
  when each gap forms.
• Not financial advice. Trade at your own risk.

═══════════════════════════════════════════════════════════
CREDITS & ORIGINALITY
═══════════════════════════════════════════════════════════

Fair Value Gaps, OTE, and premium/discount are public ICT concepts. All code here — the
non-repainting HTF OTE map, the FVG detection and mitigation, the confluence logic, and
the alert engine — is original Viprasol work written from the standard definitions. No
third-party Pine code is reused.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// (c) Viprasol
//
// FIB OTE + FVG CONFLUENCE — high-probability ICT entries where two edges agree
//
// Combines a higher-timeframe Fibonacci OTE / premium-discount map with Fair Value Gap
// detection, and does the one thing that actually matters: it flags and ALERTS when
// price taps an FVG that sits inside the OTE zone. An FVG in the discount OTE (or
// premium OTE for shorts) is a textbook ICT confluence — this tool finds and watches
// them for you, per your settings.
//
// FVG, OTE, and premium/discount are public ICT concepts. All code is original Viprasol
// work written from the standard definitions. No third-party Pine code is reused.

//@version=6
indicator("Fib OTE + FVG Confluence [Viprasol]", shorttitle = "VP - OTE+FVG", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 200)

// ══════════════════════════════════════════════════════════════
// Inputs — HTF Fibonacci / OTE
// ══════════════════════════════════════════════════════════════
gO = "HTF Fibonacci / OTE"
htf     = input.timeframe("D", "OTE Higher Timeframe", group = gO, tooltip = "The Fib/OTE map is drawn from the previous candle range of this timeframe.")
biasMode = input.string("Auto", "Directional Bias", options = ["Auto","Long (discount OTE)","Short (premium OTE)"], group = gO, tooltip = "Auto = derive from the last HTF candle's direction. Long = watch the discount OTE for buys. Short = watch the premium OTE for sells.")
ote1    = input.float(0.618, "OTE Start", minval = 0.1, maxval = 0.9, step = 0.001, group = gO)
ote2    = input.float(0.786, "OTE End", minval = 0.1, maxval = 0.99, step = 0.001, group = gO)
showFibs = input.bool(true, "Show OTE Zone + Key Levels", group = gO)
oteCol  = input.color(color.new(#ffb300, 80), "OTE Zone Color", group = gO)
eqCol   = input.color(color.new(#787b86, 0), "Equilibrium (0.5) Color", group = gO)

// ══════════════════════════════════════════════════════════════
// Inputs — FVG
// ══════════════════════════════════════════════════════════════
gF = "Fair Value Gaps"
minGapPct = input.float(0.0, "Min Gap Size (%)", minval = 0.0, step = 0.05, group = gF)
useDisp   = input.bool(true, "Require Displacement", group = gF, tooltip = "Middle candle must close beyond the gap edge (filters weak gaps).")
mitig     = input.string("Wick", "Fill Mode", options = ["Wick","Close","Average"], group = gF)
onlyConf  = input.bool(false, "Show ONLY Confluent FVGs", group = gF, tooltip = "Hide FVGs that are not inside the OTE / favored location — keeps the chart to just the high-probability ones.")
bullCol   = input.color(#089981, "Bullish FVG", group = gF)
bearCol   = input.color(#f23645, "Bearish FVG", group = gF)
extendBars = input.int(15, "Box Extend (bars)", minval = 1, group = gF)

// ══════════════════════════════════════════════════════════════
// Inputs — Confluence & Alerts
// ══════════════════════════════════════════════════════════════
gC = "Confluence & Alerts"
confMode = input.string("Inside OTE zone", "Confluence Rule", options = ["Inside OTE zone","Favored half (disc/prem)"], group = gC, tooltip = "Inside OTE = FVG overlaps the OTE band (strict). Favored half = bull FVG in discount / bear FVG in premium (looser).")
confCol  = input.color(#ffd54f, "Confluent Highlight", group = gC)
aForm    = input.bool(false, "Alert: Confluent FVG formed", group = gC)
aTap     = input.bool(true,  "Alert: Price taps Confluent FVG", group = gC)
freqSel  = input.string("Once per bar close", "Alert Frequency", options = ["Once per bar close","Once per bar"], group = gC)
msgFmt   = input.string("Text", "Message Format", options = ["Text","JSON (webhook)"], group = gC)
freq = freqSel == "Once per bar close" ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

// ══════════════════════════════════════════════════════════════
// HTF range → OTE / equilibrium (non-repainting)
// ══════════════════════════════════════════════════════════════
[hO, hH, hL, hC] = request.security(syminfo.tickerid, htf, [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

bull = biasMode == "Long (discount OTE)" ? true : biasMode == "Short (premium OTE)" ? false : hC >= hO
rng = hH - hL
eq = math.avg(hH, hL)

float oteTop = na
float oteBot = na
if not na(rng) and rng > 0
    if bull
        oteTop := hH - rng * ote1
        oteBot := hH - rng * ote2
    else
        oteBot := hL + rng * ote1
        oteTop := hL + rng * ote2

// Track current HTF bar start for drawing anchor
var int htfStart = na
if timeframe.change(htf)
    htfStart := time

// ══════════════════════════════════════════════════════════════
// FVG type & state
// ══════════════════════════════════════════════════════════════
type FVG
    float top
    float bot
    bool  isBull
    bool  conf
    bool  tapped
    box   bx

var array<FVG> gaps = array.new<FVG>()

isConfluent(bool isBull_, float top, float bot) =>
    bool res = false
    if not na(oteTop) and not na(oteBot)
        if confMode == "Inside OTE zone"
            res := top >= oteBot and bot <= oteTop
        else
            mid = math.avg(top, bot)
            res := isBull_ ? mid < eq : mid > eq
    res

// ══════════════════════════════════════════════════════════════
// Messages
// ══════════════════════════════════════════════════════════════
mkMsg(bool isBull_, string evt, float top, float bot) =>
    dir = isBull_ ? "BULL" : "BEAR"
    msgFmt == "JSON (webhook)" ? str.format('{"ticker":"{0}","setup":"FVG-in-OTE","dir":"{1}","event":"{2}","top":{3},"bottom":{4},"price":{5}}', syminfo.ticker, dir, evt, str.tostring(top, format.mintick), str.tostring(bot, format.mintick), str.tostring(close, format.mintick)) : str.format("{0} | FVG in OTE | {1} | {2} | {3}-{4}", syminfo.ticker, dir, evt, str.tostring(bot, format.mintick), str.tostring(top, format.mintick))

// ══════════════════════════════════════════════════════════════
// FVG detection (chart timeframe)
// ══════════════════════════════════════════════════════════════
bullFVG = low > high[2] and (not useDisp or close[1] > high[2])
bearFVG = high < low[2] and (not useDisp or close[1] < low[2])

addGap(bool cond, bool isBull_, float top, float bot, color col) =>
    if cond and bot > 0 and (top - bot) / bot * 100 >= minGapPct and barstate.isconfirmed
        conf = isConfluent(isBull_, top, bot)
        if conf or not onlyConf
            useCol = conf ? confCol : col
            rightT = time + timeframe.in_seconds(timeframe.period) * 1000 * extendBars
            b = box.new(left = bar_index - 2, top = top, right = bar_index + extendBars, bottom = bot, border_color = conf ? color.new(confCol, 10) : color.new(col, 55), bgcolor = color.new(useCol, conf ? 65 : 82), text = conf ? "OTE ★" : "", text_size = size.tiny, text_color = confCol, text_halign = text.align_left)
            array.push(gaps, FVG.new(top, bot, isBull_, conf, false, b))
            if conf and aForm
                alert(mkMsg(isBull_, "FORMED", top, bot), freq)

addGap(bullFVG, true,  low, high[2], bullCol)
addGap(bearFVG, false, high, low[2], bearCol)

// ══════════════════════════════════════════════════════════════
// Per bar: extend boxes, detect tap / fill, fire confluent-tap alert
// ══════════════════════════════════════════════════════════════
if array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        g = array.get(gaps, i)
        mid = math.avg(g.top, g.bot)
        box.set_right(g.bx, bar_index + extendBars)

        inZone = low <= g.top and high >= g.bot
        if inZone and not g.tapped and barstate.isconfirmed
            g.tapped := true
            box.set_bgcolor(g.bx, color.new(g.conf ? confCol : (g.isBull ? bullCol : bearCol), 90))
            if g.conf and aTap
                alert(mkMsg(g.isBull, "TAPPED", g.top, g.bot), freq)

        filled = g.isBull ? (mitig == "Close" ? close < g.bot : mitig == "Average" ? low <= mid : low <= g.bot) : (mitig == "Close" ? close > g.top : mitig == "Average" ? high >= mid : high >= g.top)
        if filled and barstate.isconfirmed
            box.delete(g.bx)
            array.remove(gaps, i)

// ══════════════════════════════════════════════════════════════
// Draw OTE zone + equilibrium + key levels (current HTF range)
// ══════════════════════════════════════════════════════════════
var box oteBox = box.new(na, na, na, na, xloc = xloc.bar_time, border_color = na)
var line eqLine = line.new(na, na, na, na, xloc = xloc.bar_time, color = eqCol, style = line.style_dashed)
var line l1 = line.new(na, na, na, na, xloc = xloc.bar_time, color = eqCol, style = line.style_dotted)
var line l2 = line.new(na, na, na, na, xloc = xloc.bar_time, color = eqCol, style = line.style_dotted)
var label oteLbl = label.new(na, na, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(#ffb300, 100), textcolor = #ffb300, size = size.small)

if barstate.islast and showFibs and not na(htfStart) and not na(oteTop)
    rightT = time + (time - time[1]) * extendBars
    box.set_lefttop(oteBox, htfStart, oteTop)
    box.set_rightbottom(oteBox, rightT, oteBot)
    box.set_bgcolor(oteBox, oteCol)
    line.set_xy1(eqLine, htfStart, eq)
    line.set_xy2(eqLine, rightT, eq)
    line.set_xy1(l1, htfStart, oteTop)
    line.set_xy2(l1, rightT, oteTop)
    line.set_xy1(l2, htfStart, oteBot)
    line.set_xy2(l2, rightT, oteBot)
    label.set_xy(oteLbl, rightT, math.avg(oteTop, oteBot))
    label.set_text(oteLbl, (bull ? "Discount OTE" : "Premium OTE") + " " + str.tostring(ote1) + "-" + str.tostring(ote2))
````
