# Rejection Blocks+ (M1D)

- url: https://www.tradingview.com/script/grLDJs7l-Rejection-Blocks-M1D/
- type: indicator
- pine_id: PUB;dd521f6c78e540f1be2cd894af94f7a2
- version: 1.0

## Description

Rejection Blocks+ 
Rejection blocks: the wick a swing leaves behind when price runs the liquidity resting beyond it and turns. It reads them on the chart's own timeframe and on up to three higher timeframes, and draws nothing else.

[b]The definition it follows[/b]

Bearish below; bullish mirrors.

[b]A confirmed swing high.[/b] A candle whose high stands above the candles either side of it, confirmed once the set number of candles have closed after it.

[b]Long upper wicks past the bodies.[/b] At that high, the wick reaches well beyond the candle bodies to run the buy stops resting above. By default the wick band must be at least one and a half times the swing candle's own body.

[b]Price holds beneath the midpoint.[/b] The candles after the raid close below the block's midpoint, its consequent encroachment. A raid that price keeps closing back into is not a rejection.

[b]The block is the wick.[/b] From the wick high down to the top of the body, whatever the candle's colour. The "Wick + body" range takes the body in as well; detection is the same either way.

[b]Equal bodies count too.[/b] Two or more candles at the swing that close at the same price form a block on their own, with the wicks beyond them as the block. The caption reads EQ.

The bullish rejection block mirrors it: a confirmed swing low, lower wicks running the sell stops beneath, price holding above the midpoint, and the block from the wick low up to the bottom of the body.

These are established Inner Circle Trader concepts. This script is original in its implementation of them.

[b]What it draws[/b]

[b]The zone.[/b] One box per block, blue for bullish, red for bearish, from the raid candle to just past the live candle, with a width 1 border so the wick tips it was drawn from stay visible.

[b]The levels.[/b] The 25%, 50% and 75% lines inside the block, dotted; the 50% line is the consequent encroachment. The 0% and 100% lines and a name for each level are available in the settings.

[b]The caption.[/b] RJB+ or RJB- beside the zone, past its right edge. A higher timeframe block carries its timeframe first, such as 1H · RJB+.

[b]Higher timeframes.[/b] The 5 minute, 15 minute and 1 hour by default, each with its own colours. A higher timeframe is read only when it is higher than the chart.

[b]Why the chart stays clean[/b]

[b]Failure erases.[/b] A close through the far extreme of the block removes it.

[b]The higher timeframe wins.[/b] When two blocks on the same side overlap, only the one from the higher timeframe is drawn.

[b]The deeper wick stays.[/b] Two overlapping blocks on the same timeframe keep the one whose wick reached further.

[b]Two per side, per timeframe.[/b] The newest two bullish and two bearish blocks on each timeframe. Older blocks also expire after a set age.

[b]Method and repainting[/b]

All detection runs on closed candles. Higher timeframe values come from closed candles only, so a block never appears and then disappears. Swing points confirm the set number of candles after they print, which is inherent to swing detection.

Four alerts: a new bullish block, a new bearish block, and a run through either block's body that closes back out. They fire once per bar close, inside up to three time windows; 9:30 to 16:00 New York is on by default, and with every window off they fire at any time.

[b]Settings[/b]

General: swing strength, blocks per side on each timeframe, only blocks whose raid candle closed in the block's direction, and the block range (wick only or wick plus body).

Detection: the wick to body ratio, the optional stricter filter where the wick must run the previous swing and close back inside it, the midpoint hold, equal body blocks and their tolerance, block expiry, and whether a higher timeframe block hides the lower ones it overlaps.

Timeframes: the chart timeframe and three higher timeframes, each on or off with its own colours, and the timeframe caption's size and colour.

Style: fill or no fill, fill transparency, border width, style and transparency, right offset, and each of the five levels with its own colour, style, width and name.

Alerts: three time windows and their timezone.

[b]Analytics only[/b]

This is a study tool. It marks where a swing rejected and the wick that rejection left behind. It contains no buy or sell signals, and its alerts announce that a block formed or was run; they are notifications, not trade instructions.

[b]Disclaimer[/b]

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
//@version=6
// © mayb1dayy
indicator("Rejection Blocks+ (M1D)", shorttitle = "RJB+", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// A rejection block is the wick that ran the liquidity and reversed. At a confirmed swing high,
// long upper wick(s) reach past the candle BODIES to run buyside liquidity, then price declines;
// the block is the raid candle's wick alone, from its wick high down to the top of its body,
// whatever the candle's colour (the "Wick + body" range takes the body in as well). Price later
// trading above the body and closing back beneath it is the block doing its job. The lows mirror
// it. The block's midpoint (consequent encroachment) is the defensive line: a block traded through
// its far extreme on a close has failed and is removed.
//
// Blocks are read on the chart timeframe and on up to three higher timeframes. A higher timeframe
// block carries its timeframe in the caption and hides any lower timeframe block on the same side
// that it overlaps. Every border is width 1 by default, so it never covers the wick tips the block
// was drawn from; the width is a setting.

// ════════════════════════════════════════════════════════════════════════════════════════════
//  PALETTE
// ════════════════════════════════════════════════════════════════════════════════════════════
const color C_BULL = #1d4ed8
const color C_BEAR = #f23645
const color INK    = #000000

// ════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════════════════════════════════
string G_GEN = "General"
string swingStr = input.string("Normal", "Swing strength", options = ["Sensitive", "Normal", "Strong"], group = G_GEN,
     tooltip = "How many candles either side must sit inside a swing before it is confirmed. Sensitive = 3 chart candles (1 higher timeframe candle), Normal = 5 (2), Strong = 8 (3). A block appears that many candles after the candle that made it.")
int maxVis = input.int(2, "Max blocks per side, each timeframe", minval = 1, maxval = 10, group = G_GEN,
     tooltip = "The newest blocks kept on EACH side, on each timeframe: 2 means up to 2 bullish and 2 bearish per timeframe. Older ones are removed as new ones form.")
bool onlyDir = input.bool(false, "Only blocks closing in trade direction", group = G_GEN,
     tooltip = "A bullish block only where the raid candle closed up (close above open), a bearish block only where it closed down.")
string rangeMode = input.string("Wick only (M1D)", "Block range", options = ["Wick only (M1D)", "Wick + body"], group = G_GEN,
     tooltip = "Wick only: the block runs from the wick extreme to the body (M1D's reading). Wick + body: the block runs from the wick extreme across the whole candle body. Detection is the same either way; only the drawn range changes.")

string G_DET = "Detection"
float rejWickMult = input.float(1.5, "Wick is x the body", minval = 0.2, maxval = 10.0, step = 0.1, group = G_DET,
     tooltip = "How long the rejected wick band must be against the swing candle's own body. The band runs from the highest body in the formation out to the wick extreme (the lowest body to the wick low for a bullish block). Higher values keep only the clearest rejections.")
bool needSweep = input.bool(false, "Wick must run a prior swing", group = G_DET,
     tooltip = "Stricter: a swing high only forms a block when its wick runs above the previous swing high AND the candle closes back at or below it (a swing low mirrors it). This keeps only failed breakouts, so in a trending leg it passes almost nothing; off by default.")
bool needHold = input.bool(true, "Next candles close beyond the C.E.", group = G_DET,
     tooltip = "The candles after the raid candle must all close below the block's midpoint (above it for a bullish block) up to the bar that confirms the swing. A raid that price keeps closing back into is not a rejection.")
bool useEqBody = input.bool(true, "Equal body candles form a RJB", group = G_DET,
     tooltip = "Two or more candles at the swing that CLOSE at the same price form a rejection block on their own, with the wicks beyond them as the block, whatever the wick-to-body ratio. The caption reads EQ.")
int eqTicks = input.int(1, "Equal body tolerance (ticks)", minval = 0, maxval = 100, group = G_DET,
     tooltip = "How close two closes must be to count as equal, in ticks of the instrument.")
int eqReach = input.int(1, "Equal bodies within (bars of the swing)", minval = 1, maxval = 10, group = G_DET,
     tooltip = "The equal body candles must sit this close to the swing candle.")
int maxAge = input.int(1000, "Chart blocks expire after (bars)", minval = 20, maxval = 5000, group = G_DET,
     tooltip = "A chart timeframe block older than this is removed.")
int htfAge = input.int(240, "HTF blocks expire after (their candles)", minval = 10, maxval = 2000, group = G_DET,
     tooltip = "A higher timeframe block older than this many of its own candles is removed.")
bool htfHides = input.bool(true, "HTF block hides lower blocks it overlaps", group = G_DET,
     tooltip = "When two blocks on the same side overlap, only the one from the higher timeframe is drawn.")

string G_TF = "Timeframes"
bool  curOn   = input.bool(true, "Current timeframe", inline = "tf0", group = G_TF)
color curBull = input.color(C_BULL, "", inline = "tf0", group = G_TF, active = curOn)
color curBear = input.color(C_BEAR, "", inline = "tf0", group = G_TF, active = curOn)
bool   h1On   = input.bool(true, "HTF 1", inline = "tf1", group = G_TF)
string h1Tf   = input.timeframe("5", "", inline = "tf1", group = G_TF, active = h1On)
color  h1Bull = input.color(C_BULL, "", inline = "tf1", group = G_TF, active = h1On)
color  h1Bear = input.color(C_BEAR, "", inline = "tf1", group = G_TF, active = h1On)
bool   h2On   = input.bool(true, "HTF 2", inline = "tf2", group = G_TF)
string h2Tf   = input.timeframe("15", "", inline = "tf2", group = G_TF, active = h2On)
color  h2Bull = input.color(C_BULL, "", inline = "tf2", group = G_TF, active = h2On)
color  h2Bear = input.color(C_BEAR, "", inline = "tf2", group = G_TF, active = h2On)
bool   h3On   = input.bool(true, "HTF 3", inline = "tf3", group = G_TF,
     tooltip = "Each higher timeframe is read only when it is higher than the chart; one at or below the chart timeframe draws nothing. Each row: on/off, timeframe, bullish colour, bearish colour.")
string h3Tf   = input.timeframe("60", "", inline = "tf3", group = G_TF, active = h3On)
color  h3Bull = input.color(C_BULL, "", inline = "tf3", group = G_TF, active = h3On)
color  h3Bear = input.color(C_BEAR, "", inline = "tf3", group = G_TF, active = h3On)
bool   tfLblOn  = input.bool(true, "Timeframe label", inline = "lbl", group = G_TF)
string tfLblSz  = input.string("small", "", options = ["tiny", "small", "normal", "large"], inline = "lbl", group = G_TF, active = tfLblOn)
color  tfLblCol = input.color(INK, "", inline = "lbl", group = G_TF, active = tfLblOn,
     tooltip = "The caption beside each block (timeframe, direction, EQ), its text size and colour. Level labels use the same size and colour.")

string G_VIS = "Visual"
bool   noFill   = input.bool(false, "Remove box fill", group = G_VIS)
int    fillOpac = input.int(88, "Fill transparency", minval = 0, maxval = 100, group = G_VIS, active = not noFill)
bool   bdrOn    = input.bool(true, "Border", inline = "bdr", group = G_VIS)
int    bdrW     = input.int(1, "", minval = 1, maxval = 4, inline = "bdr", group = G_VIS, active = bdrOn)
string bdrSty   = input.string("Solid", "", options = ["Solid", "Dotted", "Dashed"], inline = "bdr", group = G_VIS, active = bdrOn)
int    bdrOpac  = input.int(0, "Transparency", minval = 0, maxval = 100, inline = "bdr", group = G_VIS, active = bdrOn,
     tooltip = "The block's outline: width, style and transparency. It takes the block's own bullish or bearish colour. Width 1 keeps the wick tips the block was drawn from visible.")
int    runway   = input.int(2, "Right offset (bars)", minval = 0, maxval = 100, group = G_VIS,
     tooltip = "How many bars past the live candle blocks and their levels run before the caption. Raise it to park the captions clear of the candles still printing.")
string LV_TIP = "Each row: on/off, colour, style, width, label. 0% is the wick extreme, 100% the far edge of the drawn block. In Wick only, 50% is the wick's consequent encroachment; in Wick + body it is the midpoint of wick and body together. Level labels sit at the block's left end, clear of live price."
bool   l0On  = input.bool(false, "0%", inline = "l0", group = G_VIS)
color  l0Col = input.color(color.gray, "", inline = "l0", group = G_VIS, active = l0On)
string l0Sty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "l0", group = G_VIS, active = l0On)
int    l0W   = input.int(1, "", minval = 1, maxval = 4, inline = "l0", group = G_VIS, active = l0On)
bool   l0Lbl = input.bool(false, "Label", inline = "l0", group = G_VIS, active = l0On)
bool   l1On  = input.bool(true, "25%", inline = "l1", group = G_VIS)
color  l1Col = input.color(color.gray, "", inline = "l1", group = G_VIS, active = l1On)
string l1Sty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "l1", group = G_VIS, active = l1On)
int    l1W   = input.int(1, "", minval = 1, maxval = 4, inline = "l1", group = G_VIS, active = l1On)
bool   l1Lbl = input.bool(false, "Label", inline = "l1", group = G_VIS, active = l1On)
bool   l2On  = input.bool(true, "50%", inline = "l2", group = G_VIS)
color  l2Col = input.color(color.gray, "", inline = "l2", group = G_VIS, active = l2On)
string l2Sty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "l2", group = G_VIS, active = l2On)
int    l2W   = input.int(1, "", minval = 1, maxval = 4, inline = "l2", group = G_VIS, active = l2On)
bool   l2Lbl = input.bool(false, "Label", inline = "l2", group = G_VIS, active = l2On)
bool   l3On  = input.bool(true, "75%", inline = "l3", group = G_VIS)
color  l3Col = input.color(color.gray, "", inline = "l3", group = G_VIS, active = l3On)
string l3Sty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "l3", group = G_VIS, active = l3On)
int    l3W   = input.int(1, "", minval = 1, maxval = 4, inline = "l3", group = G_VIS, active = l3On)
bool   l3Lbl = input.bool(false, "Label", inline = "l3", group = G_VIS, active = l3On)
bool   l4On  = input.bool(false, "100%", inline = "l4", group = G_VIS)
color  l4Col = input.color(color.gray, "", inline = "l4", group = G_VIS, active = l4On)
string l4Sty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "l4", group = G_VIS, active = l4On)
int    l4W   = input.int(1, "", minval = 1, maxval = 4, inline = "l4", group = G_VIS, active = l4On)
bool   l4Lbl = input.bool(false, "Label", inline = "l4", group = G_VIS, active = l4On, tooltip = LV_TIP)

string G_ALR = "Alerts"
bool   w1On  = input.bool(true, "Window 1", inline = "w1", group = G_ALR)
string w1    = input.session("0930-1600", "", inline = "w1", group = G_ALR, active = w1On)
bool   w2On  = input.bool(false, "Window 2", inline = "w2", group = G_ALR)
string w2    = input.session("0200-0500", "", inline = "w2", group = G_ALR, active = w2On)
bool   w3On  = input.bool(false, "Window 3", inline = "w3", group = G_ALR)
string w3    = input.session("2000-0000", "", inline = "w3", group = G_ALR, active = w3On)
string alrTzIn = input.string("New York", "Window timezone", options = ["New York", "Chicago", "London", "UTC", "Exchange"],
     group = G_ALR, active = w1On or w2On or w3On,
     tooltip = "Alerts fire only inside the windows switched on. With every window off, alerts fire at any time. Blocks are drawn at all hours either way. Exchange uses the chart symbol's own timezone.")

// ════════════════════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════════════════════
//@function Resolves a size input to a size constant.
//@param s (string) The input value.
//@returns (string) A size.* constant.
f_lblSize(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

//@function Resolves a style input to a line style constant.
//@param s (string) The input value.
//@returns (string) A line.style_* constant.
f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

//@function Short timeframe name for a caption prefix.
//@param tf (string) A timeframe string.
//@returns (string) e.g. "30s · ", "5m · ", "1H · ", "D · ", "W · ", "M · ", "3M · ".
//      A month is not a whole number of days in seconds (M = 2,628,003 s), so months are
//      counted by rounding, and every count is a rounded int so no caption shows a decimal.
f_tfTag(string tf) =>
    int s = timeframe.in_seconds(tf)
    int mo = int(math.round(s / 2629800.0))
    int wk = int(math.round(s / 604800.0))
    int dy = int(math.round(s / 86400.0))
    string n = s >= 2419200 ? (mo == 1 ? "M" : str.tostring(mo) + "M") :
         s >= 604800 ? (wk == 1 ? "W" : str.tostring(wk) + "W") :
         s >= 86400 ? (dy == 1 ? "D" : str.tostring(dy) + "D") :
         s >= 3600 and s % 3600 == 0 ? str.tostring(int(s / 3600)) + "H" :
         s >= 60 ? str.tostring(int(math.round(s / 60.0))) + "m" : str.tostring(s) + "s"
    n + " · "

string LBL_SZ    = f_lblSize(tfLblSz)
int    chartSecs = timeframe.in_seconds(timeframe.period)
int    msPerBar  = chartSecs * 1000
bool   wickBody  = rangeMode == "Wick + body"
int    pivotLen  = swingStr == "Sensitive" ? 3 : swingStr == "Strong" ? 8 : 5
int    htfPivot  = swingStr == "Sensitive" ? 1 : swingStr == "Strong" ? 3 : 2
float  eqTol     = eqTicks * syminfo.mintick
string BDR_STY   = f_lineStyle(bdrSty)
string alrTz     = switch alrTzIn
    "Chicago"  => "America/Chicago"
    "London"   => "Europe/London"
    "UTC"      => "UTC"
    "Exchange" => syminfo.timezone
    =>            "America/New_York"

// The block levels, 0% at the wick extreme.
var array<float>  LV_PCT = array.from(0.0, 0.25, 0.5, 0.75, 1.0)
var array<string> LV_TXT = array.from("0%", "25%", "50%", "75%", "100%")
var array<bool>   LV_ON  = array.from(l0On, l1On, l2On, l3On, l4On)
var array<color>  LV_COL = array.from(l0Col, l1Col, l2Col, l3Col, l4Col)
var array<string> LV_STY = array.from(f_lineStyle(l0Sty), f_lineStyle(l1Sty), f_lineStyle(l2Sty), f_lineStyle(l3Sty), f_lineStyle(l4Sty))
var array<int>    LV_W   = array.from(l0W, l1W, l2W, l3W, l4W)
var array<bool>   LV_LBL = array.from(l0Lbl, l1Lbl, l2Lbl, l3Lbl, l4Lbl)

type Rjb
    bool  bull
    float top
    float bot
    float runLvl
    int   originTime
    int   madeBar
    int   tfMs
    bool  ran = false
    bool  htf = false
    box   bx
    array<line>  lvls
    array<label> tags
    label cap

// One timeframe the blocks are read on: slot 0 is the chart, slots 1-3 the higher timeframes.
// The HTF slots keep the last few closed candles, oldest first, with the chart bar time at which
// each candle's high and low actually printed, so a block starts on the real candle.
type Slot
    int    secs
    bool   on
    bool   htf
    color  cBull
    color  cBear
    string tag
    array<float> o
    array<float> h
    array<float> l
    array<float> c
    array<int>   hiT
    array<int>   loT
    float  runHi  = na
    float  runLo  = na
    int    runHiT = na
    int    runLoT = na
    float  prevPH = na
    float  prevPL = na
    array<Rjb> bulls
    array<Rjb> bears

//@function Builds a timeframe slot.
//@param tf (string) The timeframe.
//@param on (bool) Whether the user switched it on.
//@param isHtf (bool) True for a higher timeframe slot.
//@param cBull (color) Bullish colour.
//@param cBear (color) Bearish colour.
//@returns (Slot) The slot; a higher timeframe at or below the chart's is switched off.
f_slot(string tf, bool on, bool isHtf, color cBull, color cBear) =>
    int s = isHtf ? timeframe.in_seconds(tf) : chartSecs
    Slot.new(secs = s, on = on and (not isHtf or s > chartSecs), htf = isHtf, cBull = cBull, cBear = cBear,
         tag = f_tfTag(isHtf ? tf : timeframe.period), o = array.new<float>(), h = array.new<float>(),
         l = array.new<float>(), c = array.new<float>(), hiT = array.new<int>(), loT = array.new<int>(),
         bulls = array.new<Rjb>(), bears = array.new<Rjb>())

var array<Slot> slots = array.from(f_slot(timeframe.period, curOn, false, curBull, curBear),
     f_slot(h1Tf, h1On, true, h1Bull, h1Bear), f_slot(h2Tf, h2On, true, h2Bull, h2Bear),
     f_slot(h3Tf, h3On, true, h3Bull, h3Bear))

//@function Creates one rejection block and its drawings.
//@param isBull (bool) True for a bullish block.
//@param top (float) Upper edge of the block.
//@param bot (float) Lower edge of the block.
//@param runLvl (float) The body edge a liquidity run trades beyond.
//@param t (int) Bar time of the swing candle.
//@param eqBody (bool) True when the block was formed by equal body candles.
//@param sl (Slot) The timeframe it was read on.
//@returns (Rjb) The new block.
f_make(bool isBull, float top, float bot, float runLvl, int t, bool eqBody, Slot sl) =>
    color base   = isBull ? sl.cBull : sl.cBear
    int   rightT = time + runway * msPerBar
    float h      = top - bot
    box bx = box.new(t, top, rightT, bot, xloc = xloc.bar_time, border_color = color.new(base, bdrOn ? bdrOpac : 100),
         border_width = bdrW, border_style = BDR_STY,
         bgcolor = color.new(base, noFill ? 100 : fillOpac))
    array<line>  lvls = array.new<line>()
    array<label> tags = array.new<label>()
    for i = 0 to 4
        if LV_ON.get(i)
            float y = isBull ? bot + h * LV_PCT.get(i) : top - h * LV_PCT.get(i)
            lvls.push(line.new(t, y, rightT, y, xloc = xloc.bar_time, color = LV_COL.get(i),
                 width = LV_W.get(i), style = LV_STY.get(i)))
            // Named at the block's LEFT end, so the text never lands on the live candles.
            if LV_LBL.get(i)
                label tg = label.new(t, y, LV_TXT.get(i), xloc = xloc.bar_time, style = label.style_label_right,
                     color = color.new(#FFFFFF, 100), textcolor = tfLblCol, size = LBL_SZ, textalign = text.align_right)
                label.set_text_font_family(tg, font.family_monospace)
                tags.push(tg)
    label cap = na
    if tfLblOn
        cap := label.new(rightT, bot + h * 0.5, sl.tag + (isBull ? "RJB+" : "RJB-") + (eqBody ? " · EQ" : ""),
             xloc = xloc.bar_time, style = label.style_label_left, color = color.new(#FFFFFF, 100),
             textcolor = tfLblCol, size = LBL_SZ, textalign = text.align_left)
        label.set_text_font_family(cap, font.family_monospace)
    Rjb.new(bull = isBull, top = top, bot = bot, runLvl = runLvl, originTime = t, madeBar = bar_index,
         tfMs = sl.secs * 1000, htf = sl.htf, bx = bx, lvls = lvls, tags = tags, cap = cap)

//@function Deletes every drawing a block owns.
//@param z (Rjb) The block.
f_kill(Rjb z) =>
    box.delete(z.bx)
    if z.lvls.size() > 0
        for i = 0 to z.lvls.size() - 1
            line.delete(z.lvls.get(i))
    if z.tags.size() > 0
        for i = 0 to z.tags.size() - 1
            label.delete(z.tags.get(i))
    label.delete(z.cap)

//@function Moves a block's right edge, its levels and its caption to a new bar time.
//@param z (Rjb) The block.
//@param rightT (int) The new right edge.
f_extend(Rjb z, int rightT) =>
    box.set_right(z.bx, rightT)
    if z.lvls.size() > 0
        for i = 0 to z.lvls.size() - 1
            line.set_x2(z.lvls.get(i), rightT)
    if not na(z.cap)
        label.set_x(z.cap, rightT)

// ════════════════════════════════════════════════════════════════════════════════════════════
//  MANAGEMENT
// ════════════════════════════════════════════════════════════════════════════════════════════
//@function Removes failed or expired blocks and flags the first run through each block's body.
//@param arr (array<Rjb>) The blocks of one side and one timeframe.
//@param isBull (bool) True for bullish blocks.
//@returns (bool) True when a run printed on this bar.
f_manage(array<Rjb> arr, bool isBull) =>
    bool ran = false
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Rjb z = arr.get(i)
            bool old  = z.htf ? time - z.originTime > htfAge * z.tfMs : bar_index - z.madeBar > maxAge
            bool fail = isBull ? close < z.bot : close > z.top
            if fail or old
                f_kill(z)
                arr.remove(i)
            else if not z.ran and bar_index > z.madeBar and (isBull ? low < z.runLvl and close > z.runLvl : high > z.runLvl and close < z.runLvl)
                z.ran := true
                ran   := true
    ran

//@function Checks whether a set already holds a same-side block overlapping a span whose wick reaches at least as far.
//@param arr (array<Rjb>) The blocks of one side and one timeframe.
//@param isBull (bool) True for bullish blocks.
//@param top (float) Upper edge of the span.
//@param bot (float) Lower edge of the span.
//@returns (bool) True when a deeper block from earlier already covers it.
f_deeper(array<Rjb> arr, bool isBull, float top, float bot) =>
    bool hit = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            Rjb o = arr.get(i)
            if o.bot <= top and o.top >= bot and (isBull ? o.bot <= bot : o.top >= top)
                hit := true
    hit

//@function Removes every block in a set that overlaps a price span.
//@param arr (array<Rjb>) The blocks of one side and one timeframe.
//@param top (float) Upper edge of the span.
//@param bot (float) Lower edge of the span.
f_clear(array<Rjb> arr, float top, float bot) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Rjb o = arr.get(i)
            if o.bot <= top and o.top >= bot
                f_kill(o)
                arr.remove(i)

//@function Checks whether any block in a set overlaps a price span.
//@param arr (array<Rjb>) The blocks of one side and one timeframe.
//@param top (float) Upper edge of the span.
//@param bot (float) Lower edge of the span.
//@returns (bool) True when one overlaps.
f_overlaps(array<Rjb> arr, float top, float bot) =>
    bool hit = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            Rjb o = arr.get(i)
            if o.bot <= top and o.top >= bot
                hit := true
    hit

//@function Validates a swing and, when it qualifies, adds its block to the slot.
//      A same-side block that overlaps it on a higher timeframe hides it; a block from earlier on the
//      same timeframe whose wick reached at least as far keeps its place; anything shallower that
//      it overlaps on its own or a lower timeframe is replaced.
//@param all (array<Slot>) Every timeframe slot.
//@param sl (Slot) The timeframe the swing was read on.
//@param isBull (bool) True for a swing low (bullish block).
//@param ext (float) The swing's wick extreme.
//@param o (float) The swing candle's open.
//@param c (float) The swing candle's close.
//@param band (float) The wick band past the formation's bodies.
//@param eqB (bool) True when equal closes formed the block.
//@param swept (bool) The sweep gate's result.
//@param held (bool) The C.E. hold gate's result.
//@param t (int) Bar time to start the block at.
//@returns (bool) True when a block was added.
f_try(array<Slot> all, Slot sl, bool isBull, float ext, float o, float c, float band, bool eqB, bool swept, bool held, int t) =>
    float edge  = isBull ? math.min(o, c) : math.max(o, c)
    float far   = isBull ? math.max(o, c) : math.min(o, c)
    float top   = isBull ? (wickBody ? far : edge) : ext
    float bot   = isBull ? ext : (wickBody ? far : edge)
    bool  dirOk = not onlyDir or (isBull ? c > o : c < o)
    bool  formOk = (isBull ? edge > ext : ext > edge) and band > 0 and (band >= math.abs(c - o) * rejWickMult or eqB)
    bool  added = false
    if sl.on and swept and held and dirOk and formOk
        array<Rjb> mine = isBull ? sl.bulls : sl.bears
        bool under = false
        if htfHides
            for k = 0 to all.size() - 1
                Slot s2 = all.get(k)
                if s2.on and s2.secs > sl.secs and f_overlaps(isBull ? s2.bulls : s2.bears, top, bot)
                    under := true
        if not under and not f_deeper(mine, isBull, top, bot)
            f_clear(mine, top, bot)
            if htfHides
                for k = 0 to all.size() - 1
                    Slot s2 = all.get(k)
                    if s2.secs < sl.secs
                        f_clear(isBull ? s2.bulls : s2.bears, top, bot)
            mine.push(f_make(isBull, top, bot, edge, t, eqB, sl))
            while mine.size() > maxVis
                f_kill(mine.shift())
            added := true
    added

// ════════════════════════════════════════════════════════════════════════════════════════════
//  CHART TIMEFRAME DETECTION
// ════════════════════════════════════════════════════════════════════════════════════════════
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

// The formation is every candle in the swing's window, so a wick cluster over several candles is
// measured from the highest body among them (the lowest body for a swing low).
int   winLen = 2 * pivotLen + 1
float bodyHi = ta.highest(math.max(open, close), winLen)
float bodyLo = ta.lowest(math.min(open, close), winLen)
int   eqR    = math.min(eqReach, pivotLen)

//@function Counts the candles beside the swing candle that CLOSE together at its extreme.
//      Only closes are compared: a candle opens where the one before it closed, so body edges
//      shared through a open match by construction and say nothing.
//@param isHigh (bool) True for a swing high (highest close), false for a swing low (lowest close).
//@returns (int) How many candles closed within the tolerance of that extreme close.
f_eqCount(bool isHigh) =>
    float ref = na
    for k = pivotLen - eqR to pivotLen + eqR
        ref := na(ref) ? close[k] : isHigh ? math.max(ref, close[k]) : math.min(ref, close[k])
    int n = 0
    for k = pivotLen - eqR to pivotLen + eqR
        if math.abs(close[k] - ref) <= eqTol
            n += 1
    n

//@function Checks that every candle after the swing candle closed on the rejected side of the block's midpoint.
//@param isHigh (bool) True for a bearish block (closes must sit at or below the midpoint).
//@param ce (float) The wick's midpoint.
//@returns (bool) True when every close after the swing candle held.
f_holdCE(bool isHigh, float ce) =>
    bool ok = true
    for k = 0 to pivotLen - 1
        if isHigh ? close[k] > ce : close[k] < ce
            ok := false
    ok

// ════════════════════════════════════════════════════════════════════════════════════════════
//  HIGHER TIMEFRAME CANDLES
// ════════════════════════════════════════════════════════════════════════════════════════════
// The previous candle of each higher timeframe, one tuple request each, with a one-candle offset
// and lookahead on: the values only ever describe a CLOSED candle, so a block never repaints.
[o1, hi1, lo1, c1, t1] = request.security(syminfo.tickerid, h1Tf, [open[1], high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)
[o2, hi2, lo2, c2, t2] = request.security(syminfo.tickerid, h2Tf, [open[1], high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)
[o3, hi3, lo3, c3, t3] = request.security(syminfo.tickerid, h3Tf, [open[1], high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)

// time(tf) is a plain built-in, not a request: it buckets chart bars by higher timeframe candle.
int  bk1   = time(h1Tf)
int  bk2   = time(h2Tf)
int  bk3   = time(h3Tf)
bool roll1 = not na(bk1) and bk1 != bk1[1]
bool roll2 = not na(bk2) and bk2 != bk2[1]
bool roll3 = not na(bk3) and bk3 != bk3[1]

int htfWin = 2 * htfPivot + 1
int htfEqR = math.min(eqReach, htfPivot)

//@function Tests the middle HTF candle of a slot's window for a swing high or low.
//@param sl (Slot) The slot.
//@param isHigh (bool) True for a swing high.
//@returns (bool) True when the middle candle's high (low) is beyond every other in the window.
f_htfPivot(Slot sl, bool isHigh) =>
    bool ok = sl.h.size() == htfWin
    if ok
        float mid = isHigh ? sl.h.get(htfPivot) : sl.l.get(htfPivot)
        for i = 0 to htfWin - 1
            if i != htfPivot
                float v = isHigh ? sl.h.get(i) : sl.l.get(i)
                if isHigh ? (i < htfPivot ? v > mid : v >= mid) : (i < htfPivot ? v < mid : v <= mid)
                    ok := false
    ok

//@function Highest (or lowest) body end across a slot's window.
//@param sl (Slot) The slot.
//@param isHigh (bool) True for the highest body top, false for the lowest body bottom.
//@returns (float) The body extreme.
f_htfBody(Slot sl, bool isHigh) =>
    float r = na
    for i = 0 to htfWin - 1
        float b = isHigh ? math.max(sl.o.get(i), sl.c.get(i)) : math.min(sl.o.get(i), sl.c.get(i))
        r := na(r) ? b : isHigh ? math.max(r, b) : math.min(r, b)
    r

//@function Counts HTF candles beside the swing that close together at its extreme close.
//@param sl (Slot) The slot.
//@param isHigh (bool) True for a swing high.
//@returns (int) How many closed within tolerance of the extreme close.
f_htfEqCount(Slot sl, bool isHigh) =>
    float ref = na
    for i = htfPivot - htfEqR to htfPivot + htfEqR
        float c = sl.c.get(i)
        ref := na(ref) ? c : isHigh ? math.max(ref, c) : math.min(ref, c)
    int n = 0
    for i = htfPivot - htfEqR to htfPivot + htfEqR
        if math.abs(sl.c.get(i) - ref) <= eqTol
            n += 1
    n

//@function Checks that every HTF candle after the swing candle closed on the rejected side of the wick's midpoint.
//@param sl (Slot) The slot.
//@param isHigh (bool) True for a bearish block.
//@param ce (float) The wick's midpoint.
//@returns (bool) True when every close after the swing candle held.
f_htfHoldCE(Slot sl, bool isHigh, float ce) =>
    bool ok = true
    for i = htfPivot + 1 to htfWin - 1
        float c = sl.c.get(i)
        if isHigh ? c > ce : c < ce
            ok := false
    ok

//@function On a new HTF candle, files the one that just closed and reads the window for blocks;
//      otherwise tracks where the forming candle's extremes print on the chart. Off slots are skipped.
//@param all (array<Slot>) Every timeframe slot.
//@param sl (Slot) The higher timeframe slot.
//@param roll (bool) True on the first chart bar of a new HTF candle.
//@param pO (float) Previous HTF candle open.
//@param pH (float) Previous HTF candle high.
//@param pL (float) Previous HTF candle low.
//@param pC (float) Previous HTF candle close.
//@param pT (int) Previous HTF candle open time.
//@returns ([bool, bool]) New bullish block, new bearish block.
f_htfStep(array<Slot> all, Slot sl, bool roll, float pO, float pH, float pL, float pC, int pT) =>
    bool nBull = false
    bool nBear = false
    // A slot that is off, or at or below the chart timeframe, does no work at all.
    if sl.on
        if roll
            if not na(pT)
                // A tracked extreme short of the HTF one means history began mid-candle; fall back
                // to the HTF candle's own open time.
                sl.o.push(pO)
                sl.h.push(pH)
                sl.l.push(pL)
                sl.c.push(pC)
                sl.hiT.push(not na(sl.runHi) and sl.runHi >= pH ? sl.runHiT : pT)
                sl.loT.push(not na(sl.runLo) and sl.runLo <= pL ? sl.runLoT : pT)
                while sl.o.size() > htfWin
                    sl.o.shift()
                    sl.h.shift()
                    sl.l.shift()
                    sl.c.shift()
                    sl.hiT.shift()
                    sl.loT.shift()
                if sl.h.size() == htfWin
                    float swO = sl.o.get(htfPivot)
                    float swC = sl.c.get(htfPivot)
                    if f_htfPivot(sl, true)
                        float top   = sl.h.get(htfPivot)
                        bool  swept = not needSweep or (not na(sl.prevPH) and top > sl.prevPH and swC <= sl.prevPH)
                        bool  held  = not needHold or f_htfHoldCE(sl, true, (top + math.max(swO, swC)) / 2)
                        bool  eqB   = useEqBody and f_htfEqCount(sl, true) >= 2
                        nBear := f_try(all, sl, false, top, swO, swC, top - f_htfBody(sl, true), eqB, swept, held, sl.hiT.get(htfPivot))
                        sl.prevPH := top
                    if f_htfPivot(sl, false)
                        float bot   = sl.l.get(htfPivot)
                        bool  swept = not needSweep or (not na(sl.prevPL) and bot < sl.prevPL and swC >= sl.prevPL)
                        bool  held  = not needHold or f_htfHoldCE(sl, false, (bot + math.min(swO, swC)) / 2)
                        bool  eqB   = useEqBody and f_htfEqCount(sl, false) >= 2
                        nBull := f_try(all, sl, true, bot, swO, swC, f_htfBody(sl, false) - bot, eqB, swept, held, sl.loT.get(htfPivot))
                        sl.prevPL := bot
            sl.runHi  := high
            sl.runLo  := low
            sl.runHiT := time
            sl.runLoT := time
        else
            if na(sl.runHi) or high > sl.runHi
                sl.runHi  := high
                sl.runHiT := time
            if na(sl.runLo) or low < sl.runLo
                sl.runLo  := low
                sl.runLoT := time
    [nBull, nBear]

// ════════════════════════════════════════════════════════════════════════════════════════════
//  PER BAR
// ════════════════════════════════════════════════════════════════════════════════════════════
bool newBull = false
bool newBear = false
bool bullRun = false
bool bearRun = false

if barstate.isconfirmed
    // Manage what already exists before adding anything new.
    for k = 0 to slots.size() - 1
        Slot s = slots.get(k)
        if f_manage(s.bears, false)
            bearRun := true
        if f_manage(s.bulls, true)
            bullRun := true

    // Chart timeframe: a bearish block is the raid candle's upper wick, a bullish one its lower wick.
    Slot cur = slots.get(0)
    if not na(ph)
        bool swept = not needSweep or (not na(cur.prevPH) and ph > cur.prevPH and close[pivotLen] <= cur.prevPH)
        bool held  = not needHold or f_holdCE(true, (ph + math.max(open[pivotLen], close[pivotLen])) / 2)
        bool eqB   = useEqBody and f_eqCount(true) >= 2
        if f_try(slots, cur, false, ph, open[pivotLen], close[pivotLen], ph - bodyHi, eqB, swept, held, time[pivotLen])
            newBear := true
        cur.prevPH := ph
    if not na(pl)
        bool swept = not needSweep or (not na(cur.prevPL) and pl < cur.prevPL and close[pivotLen] >= cur.prevPL)
        bool held  = not needHold or f_holdCE(false, (pl + math.min(open[pivotLen], close[pivotLen])) / 2)
        bool eqB   = useEqBody and f_eqCount(false) >= 2
        if f_try(slots, cur, true, pl, open[pivotLen], close[pivotLen], bodyLo - pl, eqB, swept, held, time[pivotLen])
            newBull := true
        cur.prevPL := pl

    // Higher timeframes, read exactly as the chart timeframe is read.
    [b1, e1] = f_htfStep(slots, slots.get(1), roll1, o1, hi1, lo1, c1, t1)
    [b2, e2] = f_htfStep(slots, slots.get(2), roll2, o2, hi2, lo2, c2, t2)
    [b3, e3] = f_htfStep(slots, slots.get(3), roll3, o3, hi3, lo3, c3, t3)
    newBull := newBull or b1 or b2 or b3
    newBear := newBear or e1 or e2 or e3

// Live blocks run a few bars past the current candle, their captions just beyond.
if barstate.islast
    int rightT = time + runway * msPerBar
    for k = 0 to slots.size() - 1
        Slot s = slots.get(k)
        if s.bears.size() > 0
            for i = 0 to s.bears.size() - 1
                f_extend(s.bears.get(i), rightT)
        if s.bulls.size() > 0
            for i = 0 to s.bulls.size() - 1
                f_extend(s.bulls.get(i), rightT)

// ════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════
bool anyWin = w1On or w2On or w3On
bool inWin  = not anyWin or (w1On and not na(time(timeframe.period, w1, alrTz))) or
     (w2On and not na(time(timeframe.period, w2, alrTz))) or (w3On and not na(time(timeframe.period, w3, alrTz)))

alertcondition(newBull and inWin, "New bullish RJB", "Bullish rejection block formed on {{ticker}} {{interval}}")
alertcondition(newBear and inWin, "New bearish RJB", "Bearish rejection block formed on {{ticker}} {{interval}}")
alertcondition(bullRun and inWin, "Bullish RJB run", "Price ran below a bullish rejection block's candle body and closed back above on {{ticker}} {{interval}}")
alertcondition(bearRun and inWin, "Bearish RJB run", "Price ran above a bearish rejection block's candle body and closed back below on {{ticker}} {{interval}}")
````
