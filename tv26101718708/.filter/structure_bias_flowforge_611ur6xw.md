# Structure Bias [FlowForge]

- url: https://www.tradingview.com/script/611ur6Xw-Structure-Bias-FlowForge/
- type: indicator
- pine_id: PUB;7ce48a0dc1164c34bd2b39bee82bd8d8
- version: 1.0

## Description

Know the structural direction on two timeframes before you trade.

Structure Bias monitors market structure simultaneously on a higher and a lower timeframe, classifies each structural event in real time, and combines both readings into a single directional verdict. It answers the question most traders try to resolve by eye: are both timeframes pointing the same way?

───────────────────

[b]DUAL-TIMEFRAME STRUCTURE DETECTION[/b]

The indicator evaluates confirmed swings on both configured timeframes independently. Each time price clears a prior confirmed swing, the event is classified by whether it aligns with the existing directional trend or breaks against it. A Break of Structure signals that the prevailing trend is continuing: price has extended beyond a prior swing in the same direction. A Change of Character signals a potential bias shift: price has broken a prior swing against the existing trend for the first time, indicating the directional bias may be reversing. Both readings update independently per timeframe so you always have a clear picture of where each one stands.

[image]https://www.tradingview.com/x/pqOLy7ky/[/image]

───────────────────

[b]ALIGNED BIAS SUMMARY[/b]

The bottom row of the dashboard synthesizes both timeframe readings into a single verdict. When the higher and lower timeframe both report the same structural direction, the row shows a confirmed aligned bias. When they conflict, it shows Mixed, flagging a structurally undecided market where lower-conviction conditions apply. The most recently updated dashboard row is highlighted automatically so you can see at a glance which event is freshest.

[image]https://www.tradingview.com/x/CHHKndgQ/[/image]

───────────────────

[b]LIVE DASHBOARD[/b]

A compact two-column table delivers the complete structural picture without adding clutter to the chart.

✥ Higher timeframe CHoCH: current Change of Character reading and direction
✥ Higher timeframe BOS: current Break of Structure reading and direction
✥ Lower timeframe CHoCH: same for your trading timeframe
✥ Lower timeframe BOS: same for your trading timeframe
✥ Overall Bias: aligned directional read, or Mixed when timeframes conflict
✥ Most recent structural event highlighted automatically

───────────────────

[b]HOW TO USE[/b]

Add the indicator to your chart and configure the two timeframes to match your setup. A common starting point is your trading timeframe as the lower and one step above it as the higher. Read the four structure rows to understand what each timeframe is doing independently. Then look at the Overall Bias row as your directional filter: a confirmed aligned reading means both timeframes agree, which is the condition most traders treat as higher-conviction. A Mixed reading means the two timeframes disagree and the structural context is less clear. Use the CHoCH alerts to be notified when the lower timeframe bias flips; use the BOS alerts when a continuation move is confirmed. Use the Aligned variants when you only want signals under full dual-timeframe agreement.

───────────────────

[b]ALERTS[/b]

Seven alert conditions, all firing on confirmed closed bars only.

✥ Bullish CHoCH: lower timeframe bias flipped to long
✥ Bearish CHoCH: lower timeframe bias flipped to short
✥ Bullish BOS: lower timeframe uptrend continuation confirmed
✥ Bearish BOS: lower timeframe downtrend continuation confirmed
✥ Aligned BOS Bullish: both timeframes aligned, bullish continuation
✥ Aligned BOS Bearish: both timeframes aligned, bearish continuation
✥ Aligned CHoCH: both timeframes aligned, high-confluence bias flip

───────────────────

[b]CUSTOMIZATION[/b]

✥ Higher and lower timeframes: configurable independently
✥ Swing sensitivity: adjustable lookback depth for coarser or finer structure
✥ Dashboard position: four corner options
✥ Text size: four sizes
✥ Twenty color themes

───────────────────

[b]THEMES[/b]

Twenty palettes are available. Four samples are shown below covering the default and three contrasting options. All twenty are accessible from the Theme input in the script settings.

Colorful (default)
[image]https://www.tradingview.com/x/CHHKndgQ/[/image]

Vivid
[image]https://www.tradingview.com/x/GpDSpu3l/[/image]

Copper
[image]https://www.tradingview.com/x/FwzrYc0h/[/image]

Ember
[image]https://www.tradingview.com/x/mt0qGuvs/[/image]

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Structure Bias [FlowForge]
// Break of structure and change of character, intraday bias at a glance
// ══════════════════════════════════════════════════════════════════
indicator("Structure Bias [FlowForge]",
     shorttitle = "Structure Bias [FlowForge]",
     overlay    = true)

// ── Inputs ────────────────────────────────────────────────────────
grp = "Settings"
htfTF    = input.timeframe("15", "Higher Timeframe", group=grp,
     tooltip="Timeframe for the top two rows. Set one step above your trading TF.")
ltfTF    = input.timeframe("5",  "Lower Timeframe",  group=grp,
     tooltip="Your trading timeframe.")
swingLen = input.int(5, "Swing Lookback", group=grp, minval=2, maxval=20,
     tooltip="Bars on each side required to confirm a swing. Higher values track larger structure.")

grpD    = "Dashboard"
dashPos = input.string("Bottom Left", "Position", group=grpD,
     options=["Top Right","Bottom Right","Top Left","Bottom Left"],
     tooltip="Where the dashboard sits on the chart.")
txtSize = input.string("Small", "Text Size", group=grpD,
     options=["Tiny","Small","Medium","Large"],
     tooltip="Font size of the dashboard text.")

// ═══════════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════════
themeChoice = input.string("Colorful", "Theme", group="Theme",
     options=["Colorful","Vivid","Blood","Lava","Coral","Mango","Sunny","Volt","Ember","Champagne","Copper","Forest","Jade","Neon","Sakura","Dusk","Synthwave","Arctic","Slate","Monochrome"],
     tooltip="Choose a colour palette for the dashboard.")

isVivid  = themeChoice == "Vivid"
isCol    = themeChoice == "Colorful"
isBlood  = themeChoice == "Blood"
isLava   = themeChoice == "Lava"
isCoral  = themeChoice == "Coral"
isMango  = themeChoice == "Mango"
isSunny  = themeChoice == "Sunny"
isVolt   = themeChoice == "Volt"
isEmber  = themeChoice == "Ember"
isChamp  = themeChoice == "Champagne"
isCopper = themeChoice == "Copper"
isForest = themeChoice == "Forest"
isJade   = themeChoice == "Jade"
isNeon   = themeChoice == "Neon"
isSakura = themeChoice == "Sakura"
isDusk   = themeChoice == "Dusk"
isSynthwave = themeChoice == "Synthwave"
isArctic = themeChoice == "Arctic"
isSlate  = themeChoice == "Slate"
isMono   = themeChoice == "Monochrome"

T_UP_RAW = isVivid ? color.rgb(0,   200, 83)  : isCol ? color.rgb(38,  166, 154) : isBlood ? color.rgb(220, 30,  30)  : isLava ? color.rgb(255, 80,  0)   : isCoral ? color.rgb(255, 90,  90)  : isMango ? color.rgb(255, 180, 0)   : isSunny ? color.rgb(255, 179, 0)   : isVolt ? color.rgb(220, 255, 0)   : isEmber ? color.rgb(255, 140, 0)   : isChamp ? color.rgb(210, 170, 80)  : isCopper ? color.rgb(200, 120, 60)  : isForest ? color.rgb(40,  160, 80)  : isJade ? color.rgb(0,   180, 150) : isNeon ? color.rgb(0,   255, 136) : isSakura ? color.rgb(230, 80,  150) : isDusk ? color.rgb(244, 143, 177) : isSynthwave ? color.rgb(0,   229, 255) : isArctic ? color.rgb(178, 235, 242) : isSlate ? color.rgb(120, 180, 220) : color.rgb(255, 255, 255)
T_DN_RAW = isVivid ? color.rgb(213, 0,   0)   : isCol ? color.rgb(239, 83,  80)  : isBlood ? color.rgb(100, 100, 100) : isLava ? color.rgb(140, 30,  30)  : isCoral ? color.rgb(0,   180, 200) : isMango ? color.rgb(40,  160, 80)  : isSunny ? color.rgb(191, 54,  12)  : isVolt ? color.rgb(100, 100, 100) : isEmber ? color.rgb(140, 140, 140) : isChamp ? color.rgb(140, 40,  60)  : isCopper ? color.rgb(100, 55,  20)  : isForest ? color.rgb(20,  90,  40)  : isJade ? color.rgb(0,   100, 80)  : isNeon ? color.rgb(255, 0,   85)  : isSakura ? color.rgb(255, 180, 210) : isDusk ? color.rgb(69,  39,  160) : isSynthwave ? color.rgb(255, 0,   229) : isArctic ? color.rgb(1,   87,  155) : isSlate ? color.rgb(50,  90,  140) : color.rgb(66,  66,  66)

// Dashboard palette
FF_BG    = color.new(color.rgb(10,  12,  16),  0)
FF_ROW   = color.new(color.rgb(14,  18,  26),  0)
FF_DIM   = color.new(color.rgb(120, 130, 145), 0)
FF_WARN  = color.new(color.rgb(255, 165,   0), 60)

// ── Text size helper ──────────────────────────────────────────────
_txtSize = txtSize == "Tiny" ? size.tiny : txtSize == "Medium" ? size.normal : txtSize == "Large" ? size.large : size.small

// ── Timeframe label helper ────────────────────────────────────────
// Whole-hour minute timeframes show as 1h, 4h, etc. Sub-hour stays in
// minutes (15m). Day/week/month strings (1D, 1W) are left as is.
fmtTF(simple string tf) =>
    float n = str.tonumber(tf)
    na(n) ? tf : (n >= 60 and n % 60 == 0 ? str.tostring(int(n / 60)) + "h" : str.tostring(int(n)) + "m")

// ── Structure detection (evaluated on the requested timeframe) ─────
// Wrapping the full stateful logic inside request.security makes the
// detection independent of the chart timeframe: the higher rows always
// reflect the higher timeframe, the lower rows always the lower one.
calcStructure() =>
    swHigh = ta.pivothigh(swingLen, swingLen)
    swLow  = ta.pivotlow(swingLen, swingLen)

    var float lastHigh    = float(na)
    var float lastLow     = float(na)
    var int   tfBias      = 0
    var bool  highCrossed = false
    var bool  lowCrossed  = false
    var int   chochBias   = 0
    var int   bosBias     = 0

    if not na(swHigh)
        lastHigh    := swHigh
        highCrossed := false
    if not na(swLow)
        lastLow     := swLow
        lowCrossed  := false

    if not na(lastHigh) and not highCrossed and close > lastHigh
        highCrossed := true
        bool isChoch = tfBias <= 0
        tfBias       := 1
        if isChoch
            chochBias := 1
        else
            bosBias   := 1

    if not na(lastLow) and not lowCrossed and close < lastLow
        lowCrossed  := true
        bool isChoch = tfBias >= 0
        tfBias       := -1
        if isChoch
            chochBias := -1
        else
            bosBias   := -1

    [tfBias, chochBias, bosBias]

[htfBias, htfChochBias, htfBosBias] = request.security(syminfo.tickerid, htfTF, calcStructure(), barmerge.gaps_off, barmerge.lookahead_off)
[ltfBias, ltfChochBias, ltfBosBias] = request.security(syminfo.tickerid, ltfTF, calcStructure(), barmerge.gaps_off, barmerge.lookahead_off)

int hBias  = nz(htfBias)
int lBias  = nz(ltfBias)
int lChoch = nz(ltfChochBias)
int lBos   = nz(ltfBosBias)

// ── Track the chart bar of each latest change (for the highlight) ──
lastChangeBar(v) =>
    var int b    = int(na)
    var int prev = 0
    if v != prev
        b    := bar_index
        prev := v
    b

htfChochBar = lastChangeBar(nz(htfChochBias))
htfBosBar   = lastChangeBar(nz(htfBosBias))
ltfChochBar = lastChangeBar(lChoch)
ltfBosBar   = lastChangeBar(lBos)

// ── Alert change tracking (lower timeframe) ───────────────────────
var int prevLChoch = 0
var int prevLBos   = 0
bool newLtfChochBull = lChoch == 1  and lChoch != prevLChoch
bool newLtfChochBear = lChoch == -1 and lChoch != prevLChoch
bool newLtfBosBull   = lBos   == 1  and lBos   != prevLBos
bool newLtfBosBear   = lBos   == -1 and lBos   != prevLBos
prevLChoch          := lChoch
prevLBos            := lBos

// ── Dashboard helpers ─────────────────────────────────────────────
signalCol(int bias) =>
    bias == 1 ? color.new(T_UP_RAW, 0) : bias == -1 ? color.new(T_DN_RAW, 0) : FF_DIM

signalLbl(int bias) =>
    bias == 1 ? "Bullish ▲" : bias == -1 ? "Bearish ▼" : "Neutral"

rowBg(int barIdx, int mostRecent) =>
    not na(barIdx) and barIdx == mostRecent ? FF_WARN : FF_ROW

// ── Dashboard ─────────────────────────────────────────────────────
if barstate.islast
    _pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

    t = table.new(_pos, 2, 5,
         bgcolor      = FF_BG,
         border_width = 1,
         border_color = color.new(color.rgb(40,45,55), 0))

    int mostRecentBar = math.max(
         math.max(nz(htfChochBar, 0), nz(htfBosBar, 0)),
         math.max(nz(ltfChochBar, 0), nz(ltfBosBar, 0)))

    string htfLbl = fmtTF(htfTF)
    string ltfLbl = fmtTF(ltfTF)

    // Row 0 — HTF CHoCH
    table.cell(t, 0, 0, htfLbl + "  CHoCH", text_color=color.white,                       text_size=_txtSize, bgcolor=rowBg(htfChochBar, mostRecentBar), text_halign=text.align_left)
    table.cell(t, 1, 0, signalLbl(nz(htfChochBias)), text_color=signalCol(nz(htfChochBias)), text_size=_txtSize, bgcolor=rowBg(htfChochBar, mostRecentBar))

    // Row 1 — HTF BOS
    table.cell(t, 0, 1, htfLbl + "  BOS",   text_color=color.white,                       text_size=_txtSize, bgcolor=rowBg(htfBosBar, mostRecentBar),   text_halign=text.align_left)
    table.cell(t, 1, 1, signalLbl(nz(htfBosBias)),  text_color=signalCol(nz(htfBosBias)),   text_size=_txtSize, bgcolor=rowBg(htfBosBar, mostRecentBar))

    // Row 2 — LTF CHoCH
    table.cell(t, 0, 2, ltfLbl + "  CHoCH", text_color=color.white,                       text_size=_txtSize, bgcolor=rowBg(ltfChochBar, mostRecentBar), text_halign=text.align_left)
    table.cell(t, 1, 2, signalLbl(lChoch), text_color=signalCol(lChoch),                   text_size=_txtSize, bgcolor=rowBg(ltfChochBar, mostRecentBar))

    // Row 3 — LTF BOS
    table.cell(t, 0, 3, ltfLbl + "  BOS",   text_color=color.white,                       text_size=_txtSize, bgcolor=rowBg(ltfBosBar, mostRecentBar),   text_halign=text.align_left)
    table.cell(t, 1, 3, signalLbl(lBos),  text_color=signalCol(lBos),                      text_size=_txtSize, bgcolor=rowBg(ltfBosBar, mostRecentBar))

    // Row 4 — Overall bias
    bool   aligned   = hBias == lBias and hBias != 0
    int    biasFinal = aligned ? hBias : 0
    color  biasCol   = biasFinal == 1 ? color.new(T_UP_RAW, 0) : biasFinal == -1 ? color.new(T_DN_RAW, 0) : FF_DIM
    color  biasBg    = aligned ? color.new(biasFinal == 1 ? T_UP_RAW : T_DN_RAW, 75) : color.new(color.rgb(20,22,30), 0)
    string biasStr   = biasFinal == 1 ? "Bullish ▲" : biasFinal == -1 ? "Bearish ▼" : "Mixed"
    table.cell(t, 0, 4, "Bias",  text_color=color.white, text_size=_txtSize, bgcolor=biasBg, text_halign=text.align_left)
    table.cell(t, 1, 4, biasStr, text_color=biasCol,     text_size=_txtSize, bgcolor=biasBg)

// ── Alerts ────────────────────────────────────────────────────────
alertcondition(newLtfChochBull and barstate.isconfirmed, "Bullish CHoCH", "Bullish CHoCH, bias flipped long")
alertcondition(newLtfChochBear and barstate.isconfirmed, "Bearish CHoCH", "Bearish CHoCH, bias flipped short")
alertcondition(newLtfBosBull   and barstate.isconfirmed, "Bullish BOS",   "Bullish BOS, uptrend continuing")
alertcondition(newLtfBosBear   and barstate.isconfirmed, "Bearish BOS",   "Bearish BOS, downtrend continuing")
alertcondition(hBias == lBias and newLtfBosBull   and barstate.isconfirmed, "Aligned BOS Bull", "Aligned BOS, bullish continuation")
alertcondition(hBias == lBias and newLtfBosBear   and barstate.isconfirmed, "Aligned BOS Bear", "Aligned BOS, bearish continuation")
alertcondition(hBias == lBias and (newLtfChochBull or newLtfChochBear) and barstate.isconfirmed, "Aligned CHoCH", "Aligned CHoCH, high confluence")
````
