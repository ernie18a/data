# WiseWealth ; Ichimoku Trend-Scoring

- url: https://www.tradingview.com/script/zo0k3mjs-WiseWealth-Ichimoku-Trend-Scoring/
- type: indicator
- pine_id: PUB;827d1064f44840f9b99941de87107ec1
- version: 1.0

## Description

### **Ichimoku Multi-Pillar Trend Scoring Engine ("Ichi Score")**
#### **1. Introduction**
The **Ichimoku Multi-Pillar Trend Scoring Engine**, colloquially known as **"Ichi Score,"** is an advanced chart overlay indicator developed in Pine Script version 6 for modern technical analysis platforms. The primary objective of this script is to revolutionize the traditional Ichimoku Kinko Hyo framework by converting its complex, multi-lined charting environment into an automated **Trend Scoring Engine**. Traditional Ichimoku charts display multiple overlapping lines that often create visual clutter and confuse traders. The Ichi Score resolves this core challenge by evaluating market conditions across five distinct technical dimensions and consolidating them into a single, quantifiable **Composite Net Score ranging from -5 to +5**. This automated numerical synthesis enables traders to filter out misleading false breakouts during market consolidation (**Chop Zones**) and confidently isolate genuine bullish or bearish trends. Furthermore, an intuitive on-screen **Heads-Up Display (HUD) Dashboard** presents real-time trend analytics, streamlining executive trading decisions directly on the chart.

---
#### **2. Technical Working Mechanism**
The core underlying engine calculates **Donchian Midpoints**—averaging the highest high and lowest low over customized historical lookback windows—to project foundational Ichimoku components, including the Tenkan-sen, Kijun-sen, and Kumo Cloud boundaries. Trade signal detection operates through five quantitative scoring pillars, where each pillar evaluates specific price dynamics and assigns a sub-score of **+1** (Bullish), **-1** (Bearish), or **0** (Neutral):

* **C1: Price vs. Current Kumo**: Evaluates candlestick position relative to current cloud parameters. A candle closing above the cloud ceiling (Kumo Max) receives **+1**, whereas a close below the cloud floor (Kumo Min) receives **-1**.
* **C2: TK Cross / Position**: Measures short- to medium-term momentum alignment. When the conversion line (Tenkan-sen) sits above the base line (Kijun-sen), a **+1** score is awarded; a position below assigns **-1**.
* **C3: Chikou Span**: Compares the current closing price against historical price action displaced backward. Closing above past historical highs awards **+1**, while falling below historical lows assigns **-1**, confirming breakout momentum.
* **C4: Future Kumo Bias**: Detects long-term macro trend direction by assessing displaced future cloud boundaries. Senkou Span A positioned above Senkou Span B (Green Kumo) scores **+1**, while Span A below Span B (Red Kumo) scores **-1**.
* **C5: Kijun Slope**: Analyzes the structural trajectory of the Kijun-sen base line. An upward slope adds **+1**, a downward slope subtracts **-1**, and a flat horizontal trajectory yields **0**.

When aggregated into a total composite score, reaching the **Strong Threshold** (defaulted at **±4**) prompts the script to plot prominent **"Strong Up"** or **"Strong Down"** triangular execution markers on the price candles. Additionally, the system checks for **Sanyaku 3/3 Alignment**—requiring simultaneous confluence of price above cloud, TK crossover, and Chikou span breakout—and displays confirmation labels marking maximum trend strength. Conversely, when the composite score hovers near zero within the Chop Score Band, or when price fluctuates inside the Kumo cloud, the system identifies a **Chop Zone**. In this state, candle colors automatically shift to amber or grey, and trade entry signals are completely suppressed to protect capital. To ensure reliability, signals execute strictly on **Confirmed Bars** (completed closes), eliminating repainting issues. Furthermore, prolonged flat periods on the Kijun-sen or Senkou Span B automatically generate horizontal dashed **Equilibrium Magnets** on the chart, serving as static support and resistance benchmarks.

---
#### **3. Practical Application & Preset Configurations**
To maximize operational efficiency across diverse financial instruments, traders can select specialized preset profiles tailored to specific market dynamics:

* **Classic (9/26/52/26)**: Employs traditional Ichimoku period settings, optimized for standard capital asset classes and higher timeframe swing trading.
* **5-Day Week (7/22/44/22)**: Specifically adjusted for institutional 5-day trading calendars, making it ideal for Stock markets, ETFs, Indices, and Forex on daily chart timeframes.
* **Crypto (20/60/120/30)**: Features extended lookback parameters specifically structured for 24/7 cryptocurrency trading, effectively smoothing high volatility and removing market noise.
* **Custom**: Allows quantitative traders and short-term scalpers to freely customize individual period lengths and scoring thresholds.

In live execution, traders should consult the on-screen **HUD Dashboard** prior to entering any trade. If the status reads **"CHOP ZONE"** alongside amber or grey candles, a **No-Action** stance is required to conserve equity. Position entries should only be triggered when the HUD transitions to **"STRONG UP"** or **"STRONG DOWN"** accompanied by green or dark red candles, triangle entry markers, or **3/3 Alignment** badges. Once a trade is active, the auto-generated cyan Kijun and purple Span B **Equilibrium Magnets** act as statistically backed references for placing **Take Profit** targets and **Stop Loss** levels. Finally, the indicator integrates real-time alerts to notify traders immediately upon major trend reversals.

## Source Code

````pine
//@version=6
indicator("WiseWealth ; Ichimoku Trend-Scoring", overlay=true, max_labels_count=500, max_lines_count=500)

// =============================================================================
// 1. INPUTS & CONFIGURATION
// =============================================================================

// Preset selection & Custom Parameters
GRP_PRESET = "⚙️ Ichimoku Presets & Periods"
preset     = input.string("Classic", "Parameter Preset", options=["Classic", "5-Day Week", "Crypto", "Custom"], group=GRP_PRESET,
              tooltip="Selects predefined Ichimoku periods: Classic (9/26/52/26), 5-Day Week (7/22/44/22), Crypto (20/60/120/30), or Custom to set your own lengths below.")

customTenkan = input.int(9,  "Custom Tenkan-sen",     minval=1, group=GRP_PRESET,
                tooltip="Conversion Line lookback period used when preset is set to Custom. Measures short-term equilibrium over the highest high and lowest low.")
customKijun  = input.int(26, "Custom Kijun-sen",      minval=1, group=GRP_PRESET,
                tooltip="Base Line lookback period used when preset is set to Custom. Acts as key baseline trend filter and equilibrium level.")
customSpanB  = input.int(52, "Custom Senkou Span B",  minval=1, group=GRP_PRESET,
                tooltip="Leading Span B lookback period used when preset is set to Custom. Defines the slower, stronger boundary of the Kumo cloud.")
customDisp   = input.int(26, "Custom Displacement",   minval=1, group=GRP_PRESET,
                tooltip="Displacement period used when preset is set to Custom. Controls cloud forward projection and Chikou Span backward shift.")

// Resolve parameter lengths strictly as simple integers for Pine Script compilation safety
int tenkanLen = switch preset
    "Classic"    => 9
    "5-Day Week" => 7
    "Crypto"     => 20
    => customTenkan

int kijunLen = switch preset
    "Classic"    => 26
    "5-Day Week" => 22
    "Crypto"     => 60
    => customKijun

int spanBLen = switch preset
    "Classic"    => 52
    "5-Day Week" => 44
    "Crypto"     => 120
    => customSpanB

int dispLen = switch preset
    "Classic"    => 26
    "5-Day Week" => 22
    "Crypto"     => 30
    => customDisp

// Offsets for projection and historical lookback
int dispOffset = dispLen - 1

// Thresholds & Lookbacks
GRP_SCORE       = "🎯 Scoring & Thresholds"
strongThreshold = input.int(4, "Strong Score Threshold (±)", minval=1, maxval=5, group=GRP_SCORE,
                   tooltip="Minimum composite score required to trigger Strong Up (+Threshold) or Strong Down (-Threshold) breakout entry signals on confirmed bars.")
chopScoreBand   = input.int(1, "Chop Score Band (±)",        minval=0, maxval=4, group=GRP_SCORE,
                   tooltip="Chop threshold band (±). If absolute score falls within this range or price is inside the cloud, the market is flagged as Chop Zone.")
slopeLen        = input.int(5, "Kijun Slope Lookback",       minval=1, group=GRP_SCORE,
                   tooltip="Bars lookback to determine Kijun-sen slope (C5 component). Positive slope scores +1, negative scores -1, and flat scores 0.")

// Equilibrium Magnets
GRP_MAG = "🧲 Equilibrium Magnets"
showMagnets       = input.bool(true,  "Detect Equilibrium Magnets", group=GRP_MAG,
                     tooltip="Enables detection of horizontal equilibrium magnet levels when Kijun or Span B remains flat for multiple consecutive bars.")
magnetFlatLen     = input.int(8,      "Magnet Flat Length (Bars)",  minval=2, group=GRP_MAG,
                     tooltip="Consecutive bars required for Kijun or Span B to remain flat before drawing an equilibrium magnet support/resistance line.")
magnetExtBars     = input.int(10,     "Forward Extension (Bars)",   minval=0, maxval=50, group=GRP_MAG,
                     tooltip="Number of bars to project equilibrium magnet lines forward into the future for visual reference.")
colKijunMagnet    = input.color(color.new(#2962ff, 20), "Kijun Magnet Color", group=GRP_MAG,
                     tooltip="Color for horizontal equilibrium magnet lines spawned by a flat Kijun-sen baseline.")
colSsbMagnet      = input.color(color.new(#ab47bc, 20), "Span B Magnet Color", group=GRP_MAG,
                     tooltip="Color for horizontal equilibrium magnet lines spawned by a flat Senkou Span B cloud line.")

// Visuals & Display
GRP_VIS = "🎨 Visuals & Plots"
showTenkan      = input.bool(true,  "Show Tenkan-sen",             group=GRP_VIS,
                   tooltip="Toggles visibility of the short-term Tenkan-sen (Conversion Line) on the chart.")
showChikou      = input.bool(false, "Show Chikou Span (Lagging)",  group=GRP_VIS,
                   tooltip="Toggles visibility of the lagging Chikou Span line, plotted backward by displacement bars.")
showKumo        = input.bool(true,  "Show Projected Kumo Cloud",   group=GRP_VIS,
                   tooltip="Toggles visibility of the projected future Kumo cloud and its dynamic color fill.")
showSignals     = input.bool(true,  "Show Signal Triangles",       group=GRP_VIS,
                   tooltip="Displays green Up triangles on Strong Up signals and red Down triangles on Strong Down signals.")
showSanyakuLbl  = input.bool(true,  "Show Sanyaku (3/3) Labels",   group=GRP_VIS,
                   tooltip="Displays compact 3/3 UP and 3/3 DN labels on bars where all three classic Ichimoku conditions newly align.")
paintCandles    = input.bool(true,  "Paint Trend / Chop Candles",  group=GRP_VIS,
                   tooltip="Colors price candles dynamically: Green when trending up, Red when trending down, and Amber when inside Chop Zone.")
showDashboard   = input.bool(true,  "Show HUD Score Dashboard",    group=GRP_VIS,
                   tooltip="Displays an on-screen HUD table summarizing total score, component breakdown (C1-C5), market regime, and Sanyaku status.")
dashPosition    = input.string("Top Right", "Dashboard Position",  options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GRP_VIS,
                   tooltip="Selects the chart corner where the HUD Score Dashboard table is anchored.")

// Color Scheme
GRP_COL = "🎨 Colors & Aesthetics"
colBull     = input.color(#089981, "Bullish / Strong Up Color", inline="bull", group=GRP_COL,
               tooltip="Color used for bullish trends, Strong Up signals, positive Kijun gradient, and Span A cloud fills.")
colBear     = input.color(#f23645, "Bearish / Strong Down Color", inline="bear", group=GRP_COL,
               tooltip="Color used for bearish trends, Strong Down signals, negative Kijun gradient, and Span B cloud fills.")
colChop     = input.color(#ffb300, "Chop Zone Color (Amber)", inline="chop", group=GRP_COL,
               tooltip="Color used for candle bars and dashboard badges when price or score is inside the Chop Zone.")
colNeutral  = input.color(#787b86, "Neutral Gray Color", inline="neu", group=GRP_COL,
               tooltip="Neutral gray color used for Kijun-sen and candles when in Chop Zone or balanced state.")


// =============================================================================
// 2. CORE ICHIMOKU CALCULATIONS
// =============================================================================

// Donchian midpoint formula: (Highest High + Lowest Low) / 2
donchianMid(int len) =>
    math.avg(ta.highest(high, len), ta.lowest(low, len))

// Standard lines
float tenkan  = donchianMid(tenkanLen)
float kijun   = donchianMid(kijunLen)
float ssa_raw = math.avg(tenkan, kijun)
float ssb_raw = donchianMid(spanBLen)

// Current Kumo on the current candle (calculated dispOffset bars ago)
float kumoA   = ssa_raw[dispOffset]
float kumoB   = ssb_raw[dispOffset]
float kumoMax = math.max(kumoA, kumoB)
float kumoMin = math.min(kumoA, kumoB)


// =============================================================================
// 3. ITTO SCORE LOGIC (-5 TO +5)
// =============================================================================

// C1: Price vs Current Kumo
int c1 = na(kumoMax) or na(kumoMin) ? 0 :
         close > kumoMax ?  1 :
         close < kumoMin ? -1 : 0

// C2: TK Cross / Position
int c2 = na(tenkan) or na(kijun) ? 0 :
         tenkan > kijun ?  1 :
         tenkan < kijun ? -1 : 0

// C3: Chikou Span relative to historical price bar
float refHigh = high[dispOffset]
float refLow  = low[dispOffset]
int c3 = na(refHigh) or na(refLow) ? 0 :
         close > refHigh ?  1 :
         close < refLow  ? -1 : 0

// C4: Future Kumo Bias
int c4 = na(ssa_raw) or na(ssb_raw) ? 0 :
         ssa_raw > ssb_raw ?  1 :
         ssa_raw < ssb_raw ? -1 : 0

// C5: Kijun Slope
float kijunLag = kijun[slopeLen]
int c5 = na(kijunLag) ? 0 :
         kijun > kijunLag ?  1 :
         kijun < kijunLag ? -1 : 0

// Composite Itto Trend Score
int totalScore = c1 + c2 + c3 + c4 + c5


// =============================================================================
// 4. SANYAKU ALIGNMENT & CHOP FILTER
// =============================================================================

// Sanyaku 3/3 Alignment (Price vs Kumo, TK Cross, and Chikou Span)
bool alignedUp   = (c1 == 1)  and (c2 == 1)  and (c3 == 1)
bool alignedDown = (c1 == -1) and (c2 == -1) and (c3 == -1)

// Chop Zone condition: inside Kumo OR score within chop band
bool insideKumo     = not na(kumoMin) and not na(kumoMax) and close >= kumoMin and close <= kumoMax
bool insideChopBand = math.abs(totalScore) <= chopScoreBand
bool inChopZone     = insideKumo or insideChopBand

// Non-repainting execution flag
bool isConfirmed = barstate.isconfirmed


// =============================================================================
// 5. SIGNALS & TRANSITIONS
// =============================================================================

// Strong Up & Down signals
bool rawStrongUp   = not inChopZone and (totalScore >= strongThreshold) and (totalScore[1] < strongThreshold)
bool rawStrongDown = not inChopZone and (totalScore <= -strongThreshold) and (totalScore[1] > -strongThreshold)

bool strongUp   = isConfirmed and rawStrongUp
bool strongDown = isConfirmed and rawStrongDown

// Sanyaku new occurrences
bool newAlignedUp   = isConfirmed and alignedUp and not alignedUp[1]
bool newAlignedDown = isConfirmed and alignedDown and not alignedDown[1]

// Chop zone transitions
bool enterChop = isConfirmed and inChopZone and not inChopZone[1]
bool exitChop  = isConfirmed and not inChopZone and inChopZone[1]


// =============================================================================
// 6. VISUAL PLOTS
// =============================================================================

// Kijun-sen baseline dynamic coloring (-5 red to +5 green, gray in Chop Zone)
color kijunColor = if inChopZone
    colNeutral
else
    color.from_gradient(float(totalScore), -5.0, 5.0, colBear, colBull)

plot(kijun, "Kijun-sen (Baseline)", color=kijunColor, linewidth=3)

// Optional Tenkan-sen
plot(showTenkan ? tenkan : na, "Tenkan-sen", color=color.new(#00bcd4, 20), linewidth=1)

// Optional Chikou Span (plotted backwards)
plot(showChikou ? close : na, "Chikou Span", offset=-dispOffset, color=color.new(#7e57c2, 30), linewidth=1)

// Projected Future Kumo Cloud
p_ssa = plot(showKumo ? ssa_raw : na, "Senkou Span A", offset=dispOffset, color=color.new(colBull, 60), linewidth=1)
p_ssb = plot(showKumo ? ssb_raw : na, "Senkou Span B", offset=dispOffset, color=color.new(colBear, 60), linewidth=1)

color kumoFillColor = ssa_raw >= ssb_raw ? color.new(colBull, 82) : color.new(colBear, 82)
fill(p_ssa, p_ssb, color=showKumo ? kumoFillColor : na, title="Projected Kumo Cloud Fill")

// Signal Triangles
plotshape(
    showSignals and strongUp,
    title     = "Strong Up Signal Triangle",
    style     = shape.triangleup,
    location  = location.belowbar,
    color     = colBull,
    size      = size.small
)

plotshape(
    showSignals and strongDown,
    title     = "Strong Down Signal Triangle",
    style     = shape.triangledown,
    location  = location.abovebar,
    color     = colBear,
    size      = size.small
)

// Sanyaku Alignment Labels (New Occurrences)
if showSanyakuLbl and newAlignedUp
    label.new(
        x         = bar_index,
        y         = low,
        text      = "3/3 UP",
        style     = label.style_label_up,
        color     = color.new(colBull, 10),
        textcolor = color.white,
        size      = size.tiny
    )

if showSanyakuLbl and newAlignedDown
    label.new(
        x         = bar_index,
        y         = high,
        text      = "3/3 DN",
        style     = label.style_label_down,
        color     = color.new(colBear, 10),
        textcolor = color.white,
        size      = size.tiny
    )

// Candle Bar Coloring
color barCol = if inChopZone
    colChop
else if totalScore > 0
    colBull
else if totalScore < 0
    colBear
else
    colNeutral

barcolor(paintCandles ? barCol : na, title="Score / Chop Candle Paint")


// =============================================================================
// 7. EQUILIBRIUM MAGNETS (MAX 6 LINES IN MEMORY)
// =============================================================================

var line[] magnetLines     = array.new_line()
var line   activeKijunLine = na
var line   activeSsbLine   = na
var int    kijunFlatCount  = 0
var int    ssbFlatCount    = 0

if showMagnets and isConfirmed
    // ----------------- Kijun-sen Flat Tracking -----------------
    if not na(kijun) and not na(kijun[1]) and kijun == kijun[1]
        kijunFlatCount += 1
    else
        kijunFlatCount  := 0
        activeKijunLine := na

    if kijunFlatCount == magnetFlatLen
        line newKijunMag = line.new(
            x1    = bar_index - magnetFlatLen + 1,
            y1    = kijun,
            x2    = bar_index + magnetExtBars,
            y2    = kijun,
            xloc  = xloc.bar_index,
            color = colKijunMagnet,
            style = line.style_dashed,
            width = 1
        )
        activeKijunLine := newKijunMag
        array.push(magnetLines, newKijunMag)
        if array.size(magnetLines) > 6
            line.delete(array.shift(magnetLines))
    else if kijunFlatCount > magnetFlatLen and not na(activeKijunLine)
        line.set_x2(activeKijunLine, bar_index + magnetExtBars)

    // ----------------- Senkou Span B Flat Tracking -----------------
    if not na(ssb_raw) and not na(ssb_raw[1]) and ssb_raw == ssb_raw[1]
        ssbFlatCount += 1
    else
        ssbFlatCount  := 0
        activeSsbLine := na

    if ssbFlatCount == magnetFlatLen
        line newSsbMag = line.new(
            x1    = bar_index - magnetFlatLen + 1,
            y1    = ssb_raw,
            x2    = bar_index + magnetExtBars,
            y2    = ssb_raw,
            xloc  = xloc.bar_index,
            color = colSsbMagnet,
            style = line.style_dashed,
            width = 1
        )
        activeSsbLine := newSsbMag
        array.push(magnetLines, newSsbMag)
        if array.size(magnetLines) > 6
            line.delete(array.shift(magnetLines))
    else if ssbFlatCount > magnetFlatLen and not na(activeSsbLine)
        line.set_x2(activeSsbLine, bar_index + magnetExtBars)


// =============================================================================
// 8. HUD SCORE DASHBOARD TABLE
// =============================================================================

string tblPos = switch dashPosition
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table hud = table.new(tblPos, 3, 8, bgcolor=color.new(#131722, 10), border_color=color.new(#334155, 0), border_width=1)

if showDashboard and barstate.islast
    // Header
    table.cell(hud, 0, 0, "ITTO ICHIMOKU",   bgcolor=color.new(#1e293b, 0), text_color=#f8fafc, text_size=size.small)
    table.cell(hud, 1, 0, "STATUS",          bgcolor=color.new(#1e293b, 0), text_color=#f8fafc, text_size=size.small)
    table.cell(hud, 2, 0, "PTS",             bgcolor=color.new(#1e293b, 0), text_color=#f8fafc, text_size=size.small)

    // Total Score
    string scoreText = (totalScore > 0 ? "+" : "") + str.tostring(totalScore) + " / 5"
    color  scoreBg   = inChopZone ? color.new(colChop, 20) : totalScore > 0 ? color.new(colBull, 20) : totalScore < 0 ? color.new(colBear, 20) : color.new(colNeutral, 30)
    color  scoreTxt  = inChopZone ? colChop : totalScore > 0 ? colBull : totalScore < 0 ? colBear : #cbd5e1

    table.cell(hud, 0, 1, "Total Score",     bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 1, inChopZone ? "CHOP ZONE" : totalScore >= strongThreshold ? "STRONG UP" : totalScore <= -strongThreshold ? "STRONG DOWN" : "TRENDING", bgcolor=scoreBg, text_color=scoreTxt, text_size=size.small)
    table.cell(hud, 2, 1, scoreText,         bgcolor=scoreBg, text_color=scoreTxt, text_size=size.small)

    // C1: Price vs Kumo
    string t1   = c1 == 1 ? "BULL" : c1 == -1 ? "BEAR" : "NEUT"
    color  col1 = c1 == 1 ? colBull : c1 == -1 ? colBear : colNeutral
    table.cell(hud, 0, 2, "C1: Price vs Kumo", bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 2, t1,                  bgcolor=color.new(col1, 75),    text_color=col1,   text_size=size.small)
    table.cell(hud, 2, 2, (c1 > 0 ? "+" : "") + str.tostring(c1), bgcolor=color.new(col1, 75), text_color=col1, text_size=size.small)

    // C2: TK Cross
    string t2   = c2 == 1 ? "BULL" : c2 == -1 ? "BEAR" : "NEUT"
    color  col2 = c2 == 1 ? colBull : c2 == -1 ? colBear : colNeutral
    table.cell(hud, 0, 3, "C2: TK Cross",      bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 3, t2,                  bgcolor=color.new(col2, 75),    text_color=col2,   text_size=size.small)
    table.cell(hud, 2, 3, (c2 > 0 ? "+" : "") + str.tostring(c2), bgcolor=color.new(col2, 75), text_color=col2, text_size=size.small)

    // C3: Chikou Span
    string t3   = c3 == 1 ? "BULL" : c3 == -1 ? "BEAR" : "NEUT"
    color  col3 = c3 == 1 ? colBull : c3 == -1 ? colBear : colNeutral
    table.cell(hud, 0, 4, "C3: Chikou Span",   bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 4, t3,                  bgcolor=color.new(col3, 75),    text_color=col3,   text_size=size.small)
    table.cell(hud, 2, 4, (c3 > 0 ? "+" : "") + str.tostring(c3), bgcolor=color.new(col3, 75), text_color=col3, text_size=size.small)

    // C4: Future Cloud
    string t4   = c4 == 1 ? "BULL" : c4 == -1 ? "BEAR" : "NEUT"
    color  col4 = c4 == 1 ? colBull : c4 == -1 ? colBear : colNeutral
    table.cell(hud, 0, 5, "C4: Future Cloud",  bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 5, t4,                  bgcolor=color.new(col4, 75),    text_color=col4,   text_size=size.small)
    table.cell(hud, 2, 5, (c4 > 0 ? "+" : "") + str.tostring(c4), bgcolor=color.new(col4, 75), text_color=col4, text_size=size.small)

    // C5: Kijun Slope
    string t5   = c5 == 1 ? "BULL" : c5 == -1 ? "BEAR" : "NEUT"
    color  col5 = c5 == 1 ? colBull : c5 == -1 ? colBear : colNeutral
    table.cell(hud, 0, 6, "C5: Kijun Slope",   bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 6, t5,                  bgcolor=color.new(col5, 75),    text_color=col5,   text_size=size.small)
    table.cell(hud, 2, 6, (c5 > 0 ? "+" : "") + str.tostring(c5), bgcolor=color.new(col5, 75), text_color=col5, text_size=size.small)

    // Sanyaku Status
    string sanyakuText = alignedUp ? "3/3 ALIGNED UP" : alignedDown ? "3/3 ALIGNED DOWN" : "PARTIAL / MIXED"
    color  sanyakuCol  = alignedUp ? colBull : alignedDown ? colBear : colNeutral

    table.cell(hud, 0, 7, "Sanyaku State",     bgcolor=color.new(#1e293b, 40), text_color=#94a3b8, text_size=size.small)
    table.cell(hud, 1, 7, sanyakuText,         bgcolor=color.new(sanyakuCol, 75), text_color=sanyakuCol, text_size=size.small)
    table.cell(hud, 2, 7, alignedUp or alignedDown ? "3/3" : "Mixed", bgcolor=color.new(sanyakuCol, 75), text_color=sanyakuCol, text_size=size.small)


// =============================================================================
// 9. ALERTS
// =============================================================================

alertcondition(strongUp,       title="Strong Up Entry",    message="[Ichimoku Score] Strong Up Entry Signal: Score crossed above threshold into strong bullish territory.")
alertcondition(strongDown,     title="Strong Down Entry",  message="[Ichimoku Score] Strong Down Entry Signal: Score crossed below threshold into strong bearish territory.")
alertcondition(newAlignedUp,   title="Sanyaku Aligned Up", message="[Ichimoku Score] Sanyaku Koten: 3/3 Bullish Alignment Achieved (Price > Kumo, Tenkan > Kijun, Chikou > Price).")
alertcondition(newAlignedDown, title="Sanyaku Aligned Down", message="[Ichimoku Score] Sanyaku Gyakuten: 3/3 Bearish Alignment Achieved (Price < Kumo, Tenkan < Kijun, Chikou < Price).")
alertcondition(enterChop,      title="Enter Chop Zone",    message="[Ichimoku Score] Market entered Chop Zone / Equilibrium (No-Action Zone).")
alertcondition(exitChop,       title="Exit Chop Zone",     message="[Ichimoku Score] Market exited Chop Zone / Trending Resumed.")
````
