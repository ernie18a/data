# Multi-Oscillator Consensus Engine [AGPro Series]

- url: https://www.tradingview.com/script/sl2Ivsf1-Multi-Oscillator-Consensus-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;8d7794d3c1854cc98519f6303886ccc1
- version: 4.0

## Description

Multi-Oscillator Consensus Engine [AGPro Series]

🔹 Overview

Multi-Oscillator Consensus Engine aggregates ten independent momentum 
oscillators into a single regime classifier with overlay Consensus Zones, 
flip event labels, and agreement persistence tracking. Instead of watching 
ten charts separately, traders see one unified answer: are the oscillators 
in agreement, and what is the consensus saying right now?

The script monitors RSI, Stochastic, CCI, MFI, Williams %R, ROC, Ultimate 
Oscillator, MACD, DMI balance, and Aroon balance. Each oscillator is 
normalized to a 0–100 scale and votes bullish, bearish, or neutral against 
configurable thresholds. The aggregated vote determines the market regime 
and drives everything else on the chart.


🔹 Unique Edge

Most multi-oscillator tools stop at a dashboard or a simple agreement 
percentage. This engine goes further:

- Regime Classification — four distinct states (Consensus Bull, Consensus 
Bear, Divergent, Transition) instead of a binary signal.
- Consensus Zones — a horizontal price zone is born at every regime flip 
and stays alive while the regime holds. When the regime ends, the zone 
becomes historical structure.
- Flip Event Labels — regime transitions are marked directly on price 
with merged flip + extreme agreement tags.
- Persistence Tracking — streak bars, last flip distance, and historical 
extreme rate tell you how trustworthy the current consensus is.
- Label Discipline — cooldown, horizontal stagger, and flip+extreme merge 
logic keep the chart readable even in choppy regimes.


🔹 Methodology

Step 1. Ten oscillators are computed with their classic defaults and 
normalized to a 0–100 range. Indicators with native 0–100 output (RSI, 
Stochastic, MFI, Ultimate) pass through directly. Others (CCI, ROC, MACD 
histogram) are rescaled against their own recent range. Williams %R is 
flipped from its native -100..0 scale.

Step 2. Each normalized oscillator casts a vote. Values above the bullish 
threshold vote +1, values below the bearish threshold vote -1, everything 
else is neutral. Vote counts and agreement percentage are computed bar by bar.

Step 3. Regime is assigned from the vote distribution. Seven or more votes 
in one direction triggers Consensus Bull or Consensus Bear. A tight spread 
(bull-bear difference ≤ 2) triggers Divergent. Everything else is a 
Transition state.

Step 4. On every bull↔bear regime entry, a new Consensus Zone is born at 
the current close ± a configurable ATR multiple. The zone extends forward 
while the regime is active and locks in place when the regime ends. A 
maximum of five active zones keeps the chart clean.

Step 5. Labels are rendered only when cooldown and merge rules allow. 
Extreme agreement events (80%+ by default) are either merged into the flip 
label or drawn separately with larger offset.


🔹 Signals & Alerts

Seven alert conditions ship with the script:

- Consensus Bull Entry — regime has just entered Consensus Bull
- Consensus Bear Entry — regime has just entered Consensus Bear
- Consensus Bull Flip — direct Bear → Bull transition
- Consensus Bear Flip — direct Bull → Bear transition
- Extreme Bullish Agreement — agreement crosses the extreme threshold up
- Extreme Bearish Agreement — same, on the bearish side
- Consensus Streak 20+ — current regime has held for twenty bars


🔹 Key Inputs

- Oscillator Periods — individual length settings for all ten oscillators
- Bullish / Bearish Thresholds — the normalized levels that define a vote
- Consensus Threshold — how many oscillators must agree for a regime (default 7/10)
- Extreme Agreement — agreement percentage for extreme events (default 80%)
- Consensus Zones — show/hide, ATR length and multiplier, max active count, 
closed zone trail
- Label Cooldown — minimum bars between flip labels, prevents clutter
- Merge Flip + Extreme — combine same-bar events into one label
- Panel — six location options, Dark/Light theme, font sizes


🔹 How to Use

Trend traders: wait for a Consensus Bull or Consensus Bear regime to 
establish (streak > 5 bars), then use pullbacks into the active Consensus 
Zone as entries in the regime direction. Exit on opposite regime flip.

Reversion traders: Extreme Agreement events mark moments where all 
oscillators are stretched in the same direction. These are classic mean 
reversion setups. Wait for a regime flip against the extreme, confirmed on 
the next bar.

Regime filter: overlay the panel on any chart and use the Regime and 
Agreement readings as a binary filter for your primary system. Only take 
longs when regime is Bull, only take shorts when regime is Bear.

Works on all timeframes from 1m to 1W. Higher timeframes produce fewer 
but higher-conviction signals.


🔹 Limitations & Transparency

- The oscillator votes use normalized thresholds. On extremely narrow 
ranges, the normalization may produce unstable votes. Raising the 
Bullish/Bearish Thresholds reduces this sensitivity.
- Consensus Zones are drawn from close price at the flip bar. Large wick 
bars may place the zone slightly away from the visual pivot.
- The script is not a standalone trading system. It is a confluence and 
regime tool to combine with your own structure, volume, or price action 
analysis.
- All signals repaint only within the current forming bar. Once a bar 
closes and barstate.isconfirmed is true, flip labels and zones are final.


🔹 Risk Disclosure

This indicator is provided for educational and analytical purposes only. 
It is not financial advice. Trading involves substantial risk. Past 
behavior of regime transitions does not guarantee future performance. 
Always use proper risk management and never risk more than you can afford 
to lose.

## Source Code

````pine
// -------------------------------------------------
// Multi-Oscillator Consensus Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Aggregates 10 independent momentum oscillators into a single consensus
// regime classifier with curated Consensus Footprint Zones, optional agreement
// events, persistence tracking, and early preview behavior. The default view
// keeps four owned footprints and no secondary event badges.
// -------------------------------------------------

//@version=6
indicator("Multi-Oscillator Consensus Engine [AGPro Series]",
     shorttitle = "AG Pro MOCE",
     overlay = true,
     max_labels_count = 300,
     max_lines_count = 300,
     max_boxes_count = 200)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string grpOsc = "Oscillator Periods"
int rsiLen = input.int(14, "RSI Length", minval = 2, group = grpOsc, tooltip = "Length used for the RSI calculation. Classic default is 14.")
int stochLen = input.int(14, "Stochastic %K Length", minval = 2, group = grpOsc, tooltip = "Lookback for the Stochastic %K. 14 is standard.")
int cciLen = input.int(20, "CCI Length", minval = 2, group = grpOsc, tooltip = "Length for the Commodity Channel Index. 20 is a balanced default.")
int mfiLen = input.int(14, "MFI Length", minval = 2, group = grpOsc, tooltip = "Money Flow Index length. Requires volume data.")
int willrLen = input.int(14, "Williams %R Length", minval = 2, group = grpOsc, tooltip = "Lookback for Williams %R overbought/oversold detection.")
int rocLen = input.int(12, "ROC Length", minval = 2, group = grpOsc, tooltip = "Rate of Change length. Measures momentum polarity.")
int uoFast = input.int(7, "Ultimate Osc Fast", minval = 2, group = grpOsc, tooltip = "Fast period for Ultimate Oscillator weighting.")
int uoMid = input.int(14, "Ultimate Osc Mid", minval = 2, group = grpOsc, tooltip = "Middle period for Ultimate Oscillator weighting.")
int uoSlow = input.int(28, "Ultimate Osc Slow", minval = 2, group = grpOsc, tooltip = "Slow period for Ultimate Oscillator weighting.")
int macdFast = input.int(12, "MACD Fast EMA", minval = 2, group = grpOsc, tooltip = "Fast EMA length for MACD histogram.")
int macdSlow = input.int(26, "MACD Slow EMA", minval = 2, group = grpOsc, tooltip = "Slow EMA length for MACD histogram.")
int macdSig = input.int(9, "MACD Signal", minval = 2, group = grpOsc, tooltip = "Signal EMA length for MACD histogram.")
int dmiLen = input.int(14, "DMI Length", minval = 2, group = grpOsc, tooltip = "Lookback for DI+ / DI- directional indicators.")
int aroonLen = input.int(14, "Aroon Length", minval = 2, group = grpOsc, tooltip = "Aroon Up / Aroon Down lookback.")

string grpThr = "Thresholds"
int obLevel = input.int(70, "Bullish Threshold (normalized)", minval = 55, maxval = 90, group = grpThr, tooltip = "Oscillators above this normalized level count as a bullish vote. Default 70 aligns with classic oscillator strength.")
int osLevel = input.int(30, "Bearish Threshold (normalized)", minval = 10, maxval = 45, group = grpThr, tooltip = "Oscillators below this normalized level count as a bearish vote. Default 30 aligns with classic oversold weakness.")
int consensusN = input.int(7, "Consensus Threshold (/10)", minval = 5, maxval = 10, group = grpThr, tooltip = "Minimum number of oscillators that must agree in the same direction to classify a Consensus Bull or Consensus Bear regime.")
int extremeLvl = input.int(80, "Extreme Agreement (%)", minval = 70, maxval = 100, group = grpThr, tooltip = "Agreement percentage required to flag an Extreme Agreement event.")

string grpConfirm = "Signal Confirmation"
string confirmationMode = input.string("Bar Close Confirmed", "Confirmation Mode", options = ["Bar Close Confirmed", "Early Preview"], group = grpConfirm, tooltip = "Bar Close Confirmed keeps zones, labels, and alerts final after candle close. Early Preview allows current-bar monitoring that may change before the bar closes.")
bool showPreviewTag = input.bool(true, "Show Preview Mode In Panel", group = grpConfirm, tooltip = "Displays whether the script is running in confirmed or early-preview mode inside the panel.")

string grpZone = "Consensus Zones"
bool showZones = input.bool(true, "Show Consensus Zones", group = grpZone, tooltip = "Draw horizontal zones at each consensus entry. Zones extend while the regime is active and remain as historical structure once closed.")
bool showZoneBadges = input.bool(true, "Show Zone Identity Badges", group = grpZone, tooltip = "Centers one filled identity badge inside every visible consensus zone. The badge preserves zone ownership on dark and light charts.")
int zoneAtrLen = input.int(14, "Zone ATR Length", minval = 2, group = grpZone, tooltip = "ATR length used to size the consensus zone height.")
float zoneAtrMult = input.float(0.40, "Zone Height (ATR)", minval = 0.05, step = 0.05, group = grpZone, tooltip = "Consensus zone half-height as a multiple of ATR. The 0.40 default gives the footprint and its centered badge clearer visual ownership.")
int maxActive = input.int(5, "Max Active Zones", minval = 1, maxval = 10, group = grpZone, tooltip = "Maximum number of live consensus zones kept on chart. Older active zones are auto-closed.")
int maxVisibleZones = input.int(4, "Max Visible Footprint Zones", minval = 2, maxval = 8, group = grpZone, tooltip = "Keeps only the most recent footprint zones and their centered identity badges. The 4-zone default preserves useful context without filling the chart.")
int closedTrail = input.int(200, "Closed Zone Trail (bars)", minval = 20, group = grpZone, tooltip = "How many bars a closed zone remains visible as historical structure before being removed.")
color bullZoneCol = input.color(color.new(color.rgb(34, 197, 166), 80), "Bull Zone Fill", group = grpZone)
color bearZoneCol = input.color(color.new(color.rgb(244, 114, 182), 80), "Bear Zone Fill", group = grpZone)

string grpVis = "Visuals"
bool showFlipLbl = input.bool(false, "Show Flip Event Badges", group = grpVis, tooltip = "Adds a separate event badge at each consensus entry. Disabled by default because the centered zone identity already owns the same transition.")
bool showExtLbl = input.bool(false, "Show Extreme Agreement Event Badges", group = grpVis, tooltip = "Adds separate badges when agreement first enters the extreme threshold. Disabled by default because the panel and footprint badges already communicate agreement without duplicate chart text.")
int labelCooldown = input.int(12, "Flip Badge Cooldown (bars)", minval = 0, maxval = 100, group = grpVis, tooltip = "Minimum bars between separate flip-event badges. Zone identity badges remain visible regardless of this filter.")
bool mergeLabels = input.bool(true, "Merge Flip + Extreme on same bar", group = grpVis, tooltip = "When a flip and an extreme agreement event occur on the same bar, render a single merged label instead of stacking two.")
int maxEventBadges = input.int(4, "Max Visible Event Badges", minval = 2, maxval = 12, group = grpVis, tooltip = "Caps optional event badges and their owned connector lines as one atomic history. The default visual profile keeps event badges disabled.")
string labelSize = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVis, tooltip = "Global label size. Normal is recommended for balanced chart readability.")

string grpPnl = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = grpPnl)
string panelLoc = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPnl)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPnl, tooltip = "Dark uses AGPro slate palette. Light improves readability on bright-chart setups.")
string panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPnl)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = panelTheme == "Dark" ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)
color panelBorder = panelTheme == "Dark" ? color.rgb(51, 65, 85) : color.rgb(203, 213, 225)
color panelLabelCol = panelTheme == "Dark" ? color.rgb(148, 163, 184) : color.rgb(71, 85, 105)
color panelValueCol = panelTheme == "Dark" ? color.rgb(226, 232, 240) : color.rgb(15, 23, 42)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_toSize(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_toPos(string s) =>
    switch s
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

// Luminance-aware contrast text (AGPro standard: luminance 145)
f_lum(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_collision_bars(string s) =>
    switch s
        "Tiny" => 7
        "Small" => 9
        "Large" => 15
        => 12

f_norm(float src, int len) =>
    float hh = ta.highest(src, len)
    float ll = ta.lowest(src, len)
    float rng = hh - ll
    rng > 0 ? (src - ll) / rng * 100.0 : 50.0

f_vote(float n) =>
    n >= obLevel ? 1 : n <= osLevel ? -1 : 0

f_safe_div(float num, float den, float fallback) =>
    den != 0.0 ? num / den : fallback

// Emit one filled event badge in a font-aware three-lane layout. Its connector
// and badge share one FIFO lifecycle so no orphaned ownership guides remain.
f_emit_label(array<label> badges, array<line> guides, int x, float anchorY, float baseOff, string txt, color bg, bool up, float gap, string szName, color lineCol, int maxVisible) =>
    int collisionBars = f_collision_bars(szName)
    int nearby = 0
    if array.size(badges) > 0
        for i = 0 to array.size(badges) - 1
            label ex = array.get(badges, i)
            if math.abs(label.get_x(ex) - x) <= collisionBars
                nearby += 1
    int lane = nearby % 3
    float laneOff = baseOff + gap * lane
    float adjY = up ? anchorY - laneOff : anchorY + laneOff
    int guard = 0
    bool moved = true
    while moved and guard < 16
        moved := false
        if array.size(badges) > 0
            for i = 0 to array.size(badges) - 1
                label ex = array.get(badges, i)
                if math.abs(label.get_x(ex) - x) <= collisionBars and math.abs(label.get_y(ex) - adjY) < gap
                    adjY := up ? adjY - gap : adjY + gap
                    moved := true
                    break
        guard += 1
    label lb = label.new(x, adjY, txt, xloc = xloc.bar_index, yloc = yloc.price, style = up ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = bg, size = f_toSize(szName))
    line guide = line.new(x, anchorY, x, adjY, xloc = xloc.bar_index, color = lineCol, width = 1)
    array.push(badges, lb)
    array.push(guides, guide)
    while array.size(badges) > maxVisible
        label.delete(array.shift(badges))
        line.delete(array.shift(guides))

// -------------------------------------------------
// Oscillator Calculations
// -------------------------------------------------
float rsiVal = ta.rsi(close, rsiLen)
float stochVal = ta.stoch(close, high, low, stochLen)
float cciRaw = ta.cci(close, cciLen)
float cciVal = f_norm(cciRaw, cciLen * 2)
float mfiVal = ta.mfi(hlc3, mfiLen)
float willrRaw = ta.wpr(willrLen)
float willrVal = willrRaw + 100.0
float rocRaw = ta.roc(close, rocLen)
float rocVal = f_norm(rocRaw, rocLen * 2)

float bpUo = close - math.min(low, close[1])
float trUo = math.max(high, close[1]) - math.min(low, close[1])
f_uo_avg(int len) =>
    f_safe_div(math.sum(bpUo, len), math.sum(trUo, len), 0.0)
float uoVal = 100.0 * (4.0 * f_uo_avg(uoFast) + 2.0 * f_uo_avg(uoMid) + f_uo_avg(uoSlow)) / 7.0

[macdLine, sigLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
float macdVal = f_norm(histLine, macdSlow * 2)

[diPlus, diMinus, adxValue] = ta.dmi(dmiLen, dmiLen)
float diSum = diPlus + diMinus
float dmiVal = diSum > 0 ? diPlus / diSum * 100.0 : 50.0

float aroonUp = 100.0 * (aroonLen - ta.highestbars(high, aroonLen + 1)) / aroonLen
float aroonDown = 100.0 * (aroonLen - ta.lowestbars(low, aroonLen + 1)) / aroonLen
float aroonVal = (aroonUp - aroonDown + 100.0) / 2.0

// -------------------------------------------------
// Consensus Engine
// -------------------------------------------------
int v1 = f_vote(rsiVal)
int v2 = f_vote(stochVal)
int v3 = f_vote(cciVal)
int v4 = f_vote(mfiVal)
int v5 = f_vote(willrVal)
int v6 = f_vote(rocVal)
int v7 = f_vote(uoVal)
int v8 = f_vote(macdVal)
int v9 = f_vote(dmiVal)
int v10 = f_vote(aroonVal)

int bullCount = (v1 == 1 ? 1 : 0) + (v2 == 1 ? 1 : 0) + (v3 == 1 ? 1 : 0) + (v4 == 1 ? 1 : 0) + (v5 == 1 ? 1 : 0) + (v6 == 1 ? 1 : 0) + (v7 == 1 ? 1 : 0) + (v8 == 1 ? 1 : 0) + (v9 == 1 ? 1 : 0) + (v10 == 1 ? 1 : 0)
int bearCount = (v1 == -1 ? 1 : 0) + (v2 == -1 ? 1 : 0) + (v3 == -1 ? 1 : 0) + (v4 == -1 ? 1 : 0) + (v5 == -1 ? 1 : 0) + (v6 == -1 ? 1 : 0) + (v7 == -1 ? 1 : 0) + (v8 == -1 ? 1 : 0) + (v9 == -1 ? 1 : 0) + (v10 == -1 ? 1 : 0)
int neutralCount = 10 - bullCount - bearCount
float agreementPct = math.max(bullCount, bearCount) * 10.0

var int regime = 0
var int prevRegime = 0
prevRegime := regime
regime := bullCount >= consensusN ? 1 : bearCount >= consensusN ? -1 : math.abs(bullCount - bearCount) <= 2 ? 0 : 2

var int streakBars = 0
streakBars := regime == prevRegime ? streakBars + 1 : 1

bool eventAllowed = confirmationMode == "Early Preview" or barstate.isconfirmed
bool isPreviewMode = confirmationMode == "Early Preview"
bool isPreviewOpenBar = isPreviewMode and not barstate.isconfirmed

bool bullFlip = regime == 1 and prevRegime == -1
bool bearFlip = regime == -1 and prevRegime == 1
bool bullEnter = regime == 1 and prevRegime != 1
bool bearEnter = regime == -1 and prevRegime != -1
bool bullEnterSignal = bullEnter and eventAllowed
bool bearEnterSignal = bearEnter and eventAllowed
bool bullFlipSignal = bullFlip and eventAllowed
bool bearFlipSignal = bearFlip and eventAllowed

var int lastFlipBar = na
if bullEnterSignal or bearEnterSignal
    lastFlipBar := bar_index
int barsSinceFlip = na(lastFlipBar) ? na : bar_index - lastFlipBar

bool extremeNow = agreementPct >= extremeLvl
var int extremeHits = 0
var int totalBars = 0
totalBars := totalBars + 1
if extremeNow and barstate.isconfirmed
    extremeHits := extremeHits + 1
float extremeRate = totalBars > 0 ? extremeHits / totalBars * 100.0 : 0.0
bool extremeEnter = extremeNow and not extremeNow[1]
bool extremeBullSignal = extremeEnter and bullCount >= bearCount and eventAllowed
bool extremeBearSignal = extremeEnter and bearCount > bullCount and eventAllowed

// -------------------------------------------------
// Consensus Zones
// -------------------------------------------------
float atrZone = ta.atr(zoneAtrLen)
float atrZoneSafe = math.max(nz(atrZone, ta.tr(true)), syminfo.mintick)

var array<box> zBoxes = array.new<box>()
var array<label> zBadges = array.new<label>()
var array<int> zBornBars = array.new<int>()
var array<int> zRegimes = array.new<int>()
var array<bool> zActive = array.new<bool>()
var array<int> zCloseBars = array.new<int>()

f_place_zone_badge(int idx, int rightBar) =>
    label badge = array.get(zBadges, idx)
    if not na(badge)
        box zone = array.get(zBoxes, idx)
        int bornBar = array.get(zBornBars, idx)
        int centerBar = int(math.round((bornBar + rightBar) * 0.5))
        float centerPrice = (box.get_top(zone) + box.get_bottom(zone)) * 0.5
        label.set_xy(badge, centerBar, centerPrice)

if array.size(zBoxes) > 0
    for i = 0 to array.size(zBoxes) - 1
        if array.get(zActive, i)
            int zReg = array.get(zRegimes, i)
            bool stillLive = regime == zReg
            if not stillLive
                array.set(zActive, i, false)
                array.set(zCloseBars, i, bar_index)
                box b = array.get(zBoxes, i)
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(zReg == 1 ? bullColor : bearColor, 92))
                box.set_border_color(b, color.new(zReg == 1 ? bullColor : bearColor, 70))
                f_place_zone_badge(i, bar_index)

if array.size(zBoxes) > 0
    for i = 0 to array.size(zBoxes) - 1
        if array.get(zActive, i)
            box.set_right(array.get(zBoxes, i), bar_index)
            f_place_zone_badge(i, bar_index)

if showZones and (bullEnterSignal or bearEnterSignal)
    int zReg = bullEnterSignal ? 1 : -1
    color zCol = bullEnterSignal ? bullZoneCol : bearZoneCol
    color zBord = bullEnterSignal ? bullColor : bearColor
    float halfH = atrZoneSafe * zoneAtrMult
    float top = close + halfH
    float bot = close - halfH
    box newBox = box.new(bar_index, top, bar_index, bot, bgcolor = zCol, border_color = color.new(zBord, isPreviewOpenBar ? 35 : 60), border_width = isPreviewOpenBar ? 2 : 1)
    string zoneTxt = (zReg == 1 ? "BULL" : "BEAR") + " ZONE | " + str.tostring(math.round(agreementPct)) + "%" + (isPreviewOpenBar ? " PREVIEW" : "")
    label newBadge = showZoneBadges ? label.new(bar_index, close, zoneTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(zBord), color = zBord, size = f_toSize(labelSize)) : na
    array.push(zBoxes, newBox)
    array.push(zBadges, newBadge)
    array.push(zBornBars, bar_index)
    array.push(zRegimes, zReg)
    array.push(zActive, true)
    array.push(zCloseBars, 0)

    while array.size(zBoxes) > maxVisibleZones
        box.delete(array.shift(zBoxes))
        label oldestBadge = array.shift(zBadges)
        if not na(oldestBadge)
            label.delete(oldestBadge)
        array.shift(zBornBars)
        array.shift(zRegimes)
        array.shift(zActive)
        array.shift(zCloseBars)

    int activeCount = 0
    if array.size(zActive) > 0
        for i = 0 to array.size(zActive) - 1
            if array.get(zActive, i)
                activeCount += 1
    if activeCount > maxActive
        int oldestIdx = -1
        int oldestBar = bar_index + 1
        if array.size(zActive) > 0
            for i = 0 to array.size(zActive) - 1
                if array.get(zActive, i) and array.get(zBornBars, i) < oldestBar
                    oldestBar := array.get(zBornBars, i)
                    oldestIdx := i
        if oldestIdx >= 0
            array.set(zActive, oldestIdx, false)
            array.set(zCloseBars, oldestIdx, bar_index)
            box ob = array.get(zBoxes, oldestIdx)
            int oReg = array.get(zRegimes, oldestIdx)
            box.set_right(ob, bar_index)
            box.set_bgcolor(ob, color.new(oReg == 1 ? bullColor : bearColor, 92))
            box.set_border_color(ob, color.new(oReg == 1 ? bullColor : bearColor, 70))
            f_place_zone_badge(oldestIdx, bar_index)

if array.size(zBoxes) > 0
    int i = array.size(zBoxes) - 1
    while i >= 0
        if not array.get(zActive, i) and array.get(zCloseBars, i) > 0 and (bar_index - array.get(zCloseBars, i)) > closedTrail
            box.delete(array.get(zBoxes, i))
            label oldBadge = array.get(zBadges, i)
            if not na(oldBadge)
                label.delete(oldBadge)
            array.remove(zBoxes, i)
            array.remove(zBadges, i)
            array.remove(zBornBars, i)
            array.remove(zRegimes, i)
            array.remove(zActive, i)
            array.remove(zCloseBars, i)
        i -= 1

// -------------------------------------------------
// Owned Event Badges
// -------------------------------------------------
float atrLbl = ta.atr(14)
float atrLblSafe = math.max(nz(atrLbl, ta.tr(true)), syminfo.mintick)
var array<label> consensusLabels = array.new<label>()
var array<line> consensusGuides = array.new<line>()

var int lastFlipLblBar = na
bool canFlipLbl = na(lastFlipLblBar) or (bar_index - lastFlipLblBar) >= labelCooldown

bool renderBullFlip = showFlipLbl and bullEnterSignal and canFlipLbl
bool renderBearFlip = showFlipLbl and bearEnterSignal and canFlipLbl
bool renderBullExt = showExtLbl and extremeBullSignal
bool renderBearExt = showExtLbl and extremeBearSignal
bool bullMerged = mergeLabels and renderBullFlip and renderBullExt
bool bearMerged = mergeLabels and renderBearFlip and renderBearExt
string previewSuffix = isPreviewOpenBar ? " PREVIEW" : ""
float collisionGap = atrLblSafe * (labelSize == "Large" ? 1.05 : labelSize == "Normal" ? 0.90 : 0.75)

if bullMerged
    f_emit_label(consensusLabels, consensusGuides, bar_index, low, atrLblSafe * 1.8, "BULL CONSENSUS | " + str.tostring(math.round(agreementPct)) + "% EXTREME" + previewSuffix, bullColor, true, collisionGap, labelSize, color.new(bullColor, 45), maxEventBadges)
    lastFlipLblBar := bar_index
else
    if renderBullFlip
        f_emit_label(consensusLabels, consensusGuides, bar_index, low, atrLblSafe * 1.7, "BULL FLIP | " + str.tostring(math.round(agreementPct)) + "%" + previewSuffix, bullColor, true, collisionGap, labelSize, color.new(bullColor, 45), maxEventBadges)
        lastFlipLblBar := bar_index
    if renderBullExt and not renderBullFlip
        f_emit_label(consensusLabels, consensusGuides, bar_index, low, atrLblSafe * 2.0, "BULL EXTREME | " + str.tostring(math.round(agreementPct)) + "%" + previewSuffix, color.new(bullColor, 10), true, collisionGap, labelSize, color.new(bullColor, 50), maxEventBadges)

if bearMerged
    f_emit_label(consensusLabels, consensusGuides, bar_index, high, atrLblSafe * 1.8, "BEAR CONSENSUS | " + str.tostring(math.round(agreementPct)) + "% EXTREME" + previewSuffix, bearColor, false, collisionGap, labelSize, color.new(bearColor, 45), maxEventBadges)
    lastFlipLblBar := bar_index
else
    if renderBearFlip
        f_emit_label(consensusLabels, consensusGuides, bar_index, high, atrLblSafe * 1.7, "BEAR FLIP | " + str.tostring(math.round(agreementPct)) + "%" + previewSuffix, bearColor, false, collisionGap, labelSize, color.new(bearColor, 45), maxEventBadges)
        lastFlipLblBar := bar_index
    if renderBearExt and not renderBearFlip
        f_emit_label(consensusLabels, consensusGuides, bar_index, high, atrLblSafe * 2.0, "BEAR EXTREME | " + str.tostring(math.round(agreementPct)) + "%" + previewSuffix, color.new(bearColor, 10), false, collisionGap, labelSize, color.new(bearColor, 50), maxEventBadges)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_toPos(panelLoc), 2, 9, border_width = 1, border_color = panelBorder, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 8)
    if showPanel
        pFont = f_toSize(panelFont)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Multi-Osc Consensus", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = pFont, text_halign = text.align_center)

        string regimeTxt = regime == 1 ? "CONSENSUS BULL" : regime == -1 ? "CONSENSUS BEAR" : regime == 0 ? "DIVERGENT" : "TRANSITION"
        color regimeCol = regime == 1 ? bullColor : regime == -1 ? bearColor : regime == 0 ? neutralColor : accentColor
        string flash = extremeNow ? " *" : ""

        table.cell(panel, 0, 1, "Regime", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 1, regimeTxt + flash, text_color = regimeCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 2, showPreviewTag ? "Signal Mode" : "Mode", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 2, showPreviewTag ? (confirmationMode == "Early Preview" ? "EARLY PREVIEW" : "BAR CLOSE") : "-", text_color = confirmationMode == "Early Preview" ? neutralColor : panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 3, "Agreement", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 3, str.tostring(math.round(agreementPct)) + "%", text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 4, "Bull / Bear", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 4, str.tostring(bullCount) + " / " + str.tostring(bearCount), text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 5, "Neutral", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 5, str.tostring(neutralCount), text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 6, "Streak (bars)", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 6, str.tostring(streakBars), text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        string barsAgoTxt = na(barsSinceFlip) ? "-" : str.tostring(barsSinceFlip)
        table.cell(panel, 0, 7, "Last Flip (bars)", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 7, barsAgoTxt, text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

        table.cell(panel, 0, 8, "Extreme Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_left)
        table.cell(panel, 1, 8, str.tostring(math.round(extremeRate, 1)) + "%", text_color = panelValueCol, bgcolor = panelBg, text_size = pFont, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(bullEnterSignal, title = "Consensus Bull Entry", message = "Multi-Osc Consensus: bullish regime event on {{ticker}} {{interval}}.")
alertcondition(bearEnterSignal, title = "Consensus Bear Entry", message = "Multi-Osc Consensus: bearish regime event on {{ticker}} {{interval}}.")
alertcondition(bullFlipSignal, title = "Consensus Bull Flip", message = "Multi-Osc Consensus: flip from Bear to Bull on {{ticker}} {{interval}}.")
alertcondition(bearFlipSignal, title = "Consensus Bear Flip", message = "Multi-Osc Consensus: flip from Bull to Bear on {{ticker}} {{interval}}.")
alertcondition(extremeBullSignal, title = "Extreme Bullish Agreement", message = "Multi-Osc Consensus: extreme bullish agreement event on {{ticker}} {{interval}}.")
alertcondition(extremeBearSignal, title = "Extreme Bearish Agreement", message = "Multi-Osc Consensus: extreme bearish agreement event on {{ticker}} {{interval}}.")
alertcondition(eventAllowed and streakBars == 20 and (regime == 1 or regime == -1), title = "Consensus Streak 20+", message = "Multi-Osc Consensus: regime has held for 20 bars on {{ticker}} {{interval}}.")
````
