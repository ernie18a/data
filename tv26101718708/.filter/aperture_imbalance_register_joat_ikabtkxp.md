# Aperture Imbalance Register [JOAT]

- url: https://www.tradingview.com/script/iKabTkxp-Aperture-Imbalance-Register-JOAT/
- type: indicator
- pine_id: PUB;d327865f4c494d6582612d95238387a3
- version: 1.0

## Description

[b]Aperture Imbalance Register [JOAT][/b]

[b]Introduction[/b]

Aperture Imbalance Register is an open-source Pine Script v6 indicator built to detect, rank, and manage directional imbalance zones in a more structured way than a basic fair value gap overlay. Instead of marking every raw three-candle gap and leaving the trader to judge which ones matter, the script builds a register of active bullish and bearish imbalance zones, measures their internal lower-timeframe participation, assigns a quality score, tracks mitigation progress, and keeps the resulting stack visible with a compact institutional-style dashboard.

The problem this indicator solves is selectivity. Many imbalance tools show too many zones, retire them too slowly, or provide no context for which inefficiencies are likely to matter. Aperture Imbalance Register focuses on the active imbalance stack and grades each register by combining gap displacement with lower-timeframe volume participation. That lets the trader see not only where imbalance exists, but how concentrated the internal participation was when the zone formed.

The script is designed for traders who use imbalance as part of a broader market-structure process. It is not trying to predict every reversal. It is designed to answer practical chart questions: where are the open directional inefficiencies, how strong are they, how much of each zone has been mitigated, and whether the current stack favors bullish or bearish continuation pressure.

Because the script uses Pine Script v6 lower-timeframe arrays, the register is not just a visual box painter. It uses lower-timeframe intrabar data to build participation histograms inside each zone, identify the local point of control of the imbalance, and display whether a register still has open space or has already been substantially repaired by later price action.

[image]https://www.tradingview.com/x/tE8qGD5W/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Bullish and Bearish Gap Detection[/b]

The script detects a bullish register when the current low is above the high from two bars ago and the middle bar confirms continuation. It detects a bearish register with the inverse condition. A sigma-style filter based on the statistical size of the gap helps reject weaker dislocations:

[pine]
bool confirmedBullGap = enoughGapHistory and barstate.isconfirmed and low > high[2] and high[1] > high[2] and bullGapSigma > gapSigma
bool confirmedBearGap = enoughGapHistory and barstate.isconfirmed and high < low[2] and low[1] < low[2] and bearGapSigma > gapSigma
[/pine]

This means the indicator is not plotting every minor price skip. It requires both structural displacement and a size filter before a new register is added to the active stack.

[b]2. Lower-Timeframe Participation Ranking[/b]

Once a gap is confirmed, the script requests lower-timeframe `close` and `volume` data using `request.security_lower_tf()` and maps intrabar participation into configurable bins across the zone. That participation profile is then used to score the register.

This matters because not all imbalances are equal. Some form with broad participation spread across the full zone. Others form with concentrated acceptance in one portion of the gap. The participation histogram helps identify where the market transacted most heavily inside the register and where the imbalance may be most meaningful on a retest.

[b]3. Quality Scoring and Register Prioritization[/b]

Each register receives a quality score derived from the concentration of lower-timeframe participation plus the size of the gap sigma event. Higher-quality zones get more visual emphasis, stronger edges, and greater dashboard influence.

In practice, this creates a hierarchy. The trader does not need to treat every imbalance equally. The register list naturally emphasizes the zones with stronger displacement and denser participation.

[b]4. Mitigation Tracking and Lifecycle Management[/b]

Open imbalance is not enough. What matters is whether the zone remains unfilled. The script measures mitigation depth as price trades back into the register and updates the display from open to partial mitigation to fully filled. When the `Retire Fully Mitigated Zones` option is enabled, fully repaired or invalidated zones are removed from the active stack.

This keeps the chart cleaner and prevents stale boxes from dominating the view after the market has already rebalanced the inefficiency.

[b]5. Participation Histogram and Local POC[/b]

Each register can display a small internal histogram showing participation intensity by price segment. The maximum participation bin defines the register’s local point of control, and that level is drawn as a line through the zone.

This gives the register more structure than a plain box. Instead of just seeing the outer bounds, the trader can see where activity concentrated inside the imbalance.

[image]https://www.tradingview.com/x/bhGIm6O9/[/image]

[b]Features[/b]

[list]
[*][b]Bullish and bearish imbalance registers:[/b] Detects confirmed gap-style inefficiencies in both directions using confirmed-bar logic
[*][b]Lower-timeframe participation model:[/b] Uses lower-timeframe arrays to rank each register by internal participation rather than gap presence alone
[*][b]Quality scoring:[/b] Combines participation concentration and sigma displacement into a single register score
[*][b]Mitigation tracking:[/b] Continuously estimates how much of each register has been repaired by later price action
[*][b]Automatic lifecycle retirement:[/b] Fully mitigated or invalidated zones can be retired automatically to reduce clutter
[*][b]Internal histogram bars:[/b] Optional profile bars show where lower-timeframe participation concentrated inside the zone
[*][b]Point-of-control line:[/b] Each register maintains a local participation midpoint for tactical reference
[*][b]Midline support:[/b] Optional dotted midpoint line helps visualize the fair center of the register
[*][b]Dashboard summary:[/b] Displays bull count, bear count, mitigated count, average quality, best quality, stack count, and bias
[*][b]Data-window exports:[/b] Publishes stack bias, quality sum, and active register count for downstream reading
[/list]

[b]Visual Elements[/b]

[list]
[*][b]Register boxes:[/b] The outer body of each imbalance zone shows whether price is dealing with bullish or bearish open inefficiency
[*][b]Participation bars:[/b] Optional internal profile bars highlight where lower-timeframe participation concentrated inside the register
[*][b]Midline and POC references:[/b] The centerline and participation high point help identify the most important sub-levels inside the zone
[*][b]Adaptive edge intensity:[/b] Stronger registers receive more visual emphasis than weaker ones
[*][b]Mitigation labels:[/b] Each register updates from open to mitigation to filled so the chart communicates lifecycle state directly
[/list]

[b]Best Practices[/b]

[list]
[*]Use the register stack as context, then let your own execution model decide entries
[*]Favor high-quality registers that align with broader structure instead of reacting to every new zone
[*]Treat partial mitigation as a sign that some imbalance has already been repaired, not as automatic invalidation
[*]Be especially careful on symbols with poor lower-timeframe data because internal participation quality can degrade
[*]If the active stack flips from one side to the other quickly, read that as changing imbalance context rather than a guaranteed reversal signal
[/list]

[b]Input Parameters[/b]

[b]Intrabar Data:[/b]
[list]
[*]Auto Lower Timeframe: Automatically derives a lower timeframe for participation analysis
[*]Custom Lower Timeframe: Allows manual lower-timeframe selection when auto mode is disabled
[*]Calculation Depth: Controls how much lower-timeframe history is requested
[/list]

[b]Imbalance Detection:[/b]
[list]
[*]Gap Sigma Filter: Sets the minimum displacement strength required for a new register
[*]Participation Bins: Controls how many internal profile slices are built inside each zone
[*]Max Active Registers: Limits how many open registers remain on the chart at once
[*]Retire Fully Mitigated Zones: Removes zones once they are effectively repaired or invalidated
[/list]

[b]Lifecycle And Display:[/b]
[list]
[*]Extend Active Zones: Extends open registers to the right for forward reference
[*]Show Participation Histogram: Displays the internal lower-timeframe bar profile
[*]Show Midline: Draws a dotted centerline through each register
[*]Show Dashboard: Enables the top-right summary panel
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Stack Bias[/b]
Start with the dashboard. Compare the bullish and bearish active register counts and note the stack bias value. A positive bias means bullish imbalance is dominating the active structure. A negative bias means bearish imbalance is dominating.

[b]Step 2: Focus on Quality, Not Quantity[/b]
Use the average and strongest quality readings to judge whether the active stack is meaningful. A chart with fewer but stronger registers is often more actionable than a chart with many weak inefficiencies.

[b]Step 3: Watch Mitigation Progress[/b]
Each active register updates from open to partial mitigation to filled. Open registers represent unresolved inefficiency. Deeply mitigated registers have already lost part of their tactical edge.

[b]Step 4: Use The Internal Profile[/b]
When the participation histogram is enabled, look for bins that concentrated most of the intrabar volume. The local point of control and denser profile segments often become the most useful retest references inside the wider zone.

[b]Step 5: Apply It As Context, Not A Standalone Trigger[/b]
Aperture Imbalance Register works best as a context layer. It helps frame whether an imbalance stack is supporting continuation or warning of unresolved opposing pressure. Use it with your own structure, execution, and risk model.

[b]Indicator Limitations[/b]

[list]
[*]Because the script uses lower-timeframe data requests, realtime behavior can differ slightly from historical behavior as new intrabars accumulate inside the live bar
[*]Mitigation does not guarantee reversal or continuation. It only shows how much of the zone has been traded back through
[*]A strong register can still fail if broader market structure, liquidity, or volatility conditions change
[*]On very low-history charts or symbols with thin lower-timeframe data, participation quality can be less informative than on liquid instruments
[/list]

[b]Originality Statement[/b]

Aperture Imbalance Register is original in the way it treats imbalances as managed registers rather than passive boxes. The script is published because it contributes more than a generic fair value gap mashup:

[list]
[*]It ranks each imbalance with a lower-timeframe participation model instead of drawing every gap with equal importance
[*]It combines gap displacement, intrabar participation, mitigation tracking, and internal histogram rendering into a single workflow
[*]It maintains a tactical register stack with lifecycle management rather than leaving stale zones permanently on the chart
[*]It exposes stack-level information through a dashboard and data-window fields so the indicator can be read systematically
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Imbalance zones are analytical references based on historical price behavior and lower-timeframe participation, not guarantees of future reaction. Markets can rebalance, ignore, or invalidate any zone without warning. Always use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aperture Imbalance Register [JOAT]", shorttitle = "RIG [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 200, max_bars_back = 5000)

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupData = "Intrabar Data"
bool autoLtf = input.bool(true, "Auto Lower Timeframe", group = groupData, inline = "tf")
string customLtf = input.timeframe("5", "", group = groupData, inline = "tf")
int calcDepth = input.int(2800, "Calculation Depth", minval = 500, maxval = 5000, group = groupData)

string groupDetection = "Imbalance Detection"
float gapSigma = input.float(0.40, "Gap Sigma Filter", minval = 0.05, maxval = 2.00, step = 0.05, group = groupDetection)
int profileBins = input.int(14, "Participation Bins", minval = 6, maxval = 30, group = groupDetection)
int maxZones = input.int(8, "Max Active Registers", minval = 2, maxval = 16, group = groupDetection)
bool hideFilled = input.bool(true, "Retire Fully Mitigated Zones", group = groupDetection)

string groupLifecycle = "Lifecycle"
bool extendZones = input.bool(true, "Extend Active Zones", group = groupLifecycle)
bool showParticipation = input.bool(true, "Show Participation Histogram", group = groupLifecycle)
bool showMidline = input.bool(true, "Show Midline", group = groupLifecycle)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupLifecycle)

string groupStyle = "Visual Language"
color bullCore = input.color(color.rgb(26, 178, 126), "Bull Core", group = groupStyle, inline = "a")
color bearCore = input.color(color.rgb(187, 45, 201), "Bear Core", group = groupStyle, inline = "a")
color bullAccent = input.color(color.rgb(33, 119, 196), "Bull Accent", group = groupStyle, inline = "b")
color bearAccent = input.color(color.rgb(255, 133, 66), "Bear Accent", group = groupStyle, inline = "b")
color panelBg = input.color(color.rgb(14, 20, 30), "Panel Background", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Types
//--------------------------------------------------------------------------------------------------
type Register
    box zone
    array<box> bars
    line poc
    line mid
    label info
    array<float> participation
    bool bull
    float top
    float bottom
    int bornIndex
    float quality

//--------------------------------------------------------------------------------------------------
// Persistent objects
//--------------------------------------------------------------------------------------------------
var array<Register> registers = array.new<Register>()
var table dashboard = table.new(position.top_right, 2, 9, frame_color = color.new(color.white, 85), frame_width = 1)

//--------------------------------------------------------------------------------------------------
// Helper functions
//--------------------------------------------------------------------------------------------------
safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

formatPct(float value) =>
    str.tostring(value, "#.0") + "%"

formatVol(float value) =>
    str.tostring(value, format.volume)

resolveLtf() =>
    float chartSeconds = timeframe.in_seconds()
    string autoTf =
         chartSeconds <= 1 ? "1S" :
         chartSeconds <= 5 ? "1S" :
         chartSeconds <= 10 ? "5S" :
         chartSeconds <= 15 ? "5S" :
         chartSeconds <= 30 ? "15S" :
         chartSeconds <= 45 ? "15S" :
         str.tostring(math.max(1, int(math.floor(chartSeconds / 60.0 / 8.0))))
    autoLtf ? autoTf : customLtf

zoneColor(bool bull, float intensity) =>
    color base = bull ? bullCore : bearCore
    color accent = bull ? bullAccent : bearAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 90), color.new(base, 10))

zoneFill(bool bull, float intensity) =>
    color base = bull ? bullCore : bearCore
    color accent = bull ? bullAccent : bearAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 96), color.new(base, 82))

dashboardCell(int column, int row, string cellText, color bg, color fg) =>
    table.cell(dashboard, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

createBarsArray() =>
    array.new<box>(profileBins, na)

createParticipationArray() =>
    array.new_float(profileBins, 0.0)

deleteRegister(Register reg) =>
    box.delete(reg.zone)
    line.delete(reg.poc)
    line.delete(reg.mid)
    label.delete(reg.info)
    for barBox in reg.bars
        box.delete(barBox)

//--------------------------------------------------------------------------------------------------
// Lower timeframe sources
//--------------------------------------------------------------------------------------------------
string ltf = resolveLtf()
array<float> ltfClose = request.security_lower_tf(syminfo.tickerid, ltf, close, ignore_invalid_symbol = true, ignore_invalid_timeframe = true, calc_bars_count = calcDepth)
array<float> ltfVolume = request.security_lower_tf(syminfo.tickerid, ltf, volume, ignore_invalid_symbol = true, ignore_invalid_timeframe = true, calc_bars_count = calcDepth)

//--------------------------------------------------------------------------------------------------
// Detection metrics
//--------------------------------------------------------------------------------------------------
float bullGapSigma = (low - high[2]) / math.max(ta.stdev(low - high[2], 200), syminfo.mintick)
float bearGapSigma = (low[2] - high) / math.max(ta.stdev(low[2] - high, 200), syminfo.mintick)

bool enoughGapHistory = bar_index >= 2
bool confirmedBullGap = enoughGapHistory and barstate.isconfirmed and low > high[2] and high[1] > high[2] and bullGapSigma > gapSigma
bool confirmedBearGap = enoughGapHistory and barstate.isconfirmed and high < low[2] and low[1] < low[2] and bearGapSigma > gapSigma

//--------------------------------------------------------------------------------------------------
// Participation builder
//--------------------------------------------------------------------------------------------------
buildParticipation(float bottomPrice, float topPrice) =>
    array<float> participation = createParticipationArray()
    float step = (topPrice - bottomPrice) / profileBins
    if step > 0 and ltfClose.size() > 0 and ltfVolume.size() > 0
        for intrabar = 0 to ltfClose.size() - 1
            float value = ltfClose.get(intrabar)
            float vol = ltfVolume.get(intrabar)
            if value >= bottomPrice and value <= topPrice
                int rawIndex = int(math.floor((value - bottomPrice) / step))
                int binIndex = math.max(0, math.min(profileBins - 1, rawIndex))
                participation.set(binIndex, participation.get(binIndex) + vol)
    participation

registerQuality(array<float> participation, float sigmaValue) =>
    float total = participation.sum()
    float maxBin = participation.max()
    float concentration = safeDiv(maxBin, total)
    float quality = concentration * 60.0 + math.min(math.abs(sigmaValue), 4.0) * 10.0
    math.min(100.0, quality)

createRegister(bool bull, float topPrice, float bottomPrice, float sigmaValue) =>
    array<float> participation = buildParticipation(bottomPrice, topPrice)
    array<box> bars = createBarsArray()
    float quality = registerQuality(participation, sigmaValue)
    color edgeColor = zoneColor(bull, quality)
    color fillColor = zoneFill(bull, quality)

    box zone = box.new(bar_index - 1, topPrice, bar_index + 3, bottomPrice, bgcolor = fillColor, border_color = color.new(edgeColor, 0), border_width = 1)
    line poc = line.new(bar_index - 1, math.avg(topPrice, bottomPrice), bar_index + 3, math.avg(topPrice, bottomPrice), color = color.new(edgeColor, 20), width = 1)
    line mid = line.new(bar_index - 1, math.avg(topPrice, bottomPrice), bar_index + 3, math.avg(topPrice, bottomPrice), color = showMidline ? color.new(edgeColor, 55) : color.new(edgeColor, 100), style = line.style_dotted)

    string infoText = (bull ? "Bull Register" : "Bear Register") + "\nQ " + formatPct(quality) + "\n" + str.tostring(math.avg(topPrice, bottomPrice), format.mintick)
    label info = label.new(bar_index + 4, math.avg(topPrice, bottomPrice), infoText, style = label.style_label_left, color = color.new(panelBg, 0), textcolor = edgeColor, size = size.tiny)

    Register.new(zone, bars, poc, mid, info, participation, bull, topPrice, bottomPrice, bar_index, quality)

//--------------------------------------------------------------------------------------------------
// Register creation
//--------------------------------------------------------------------------------------------------
if confirmedBullGap
    Register reg = createRegister(true, low, high[2], bullGapSigma)
    registers.push(reg)

if confirmedBearGap
    Register reg = createRegister(false, low[2], high, bearGapSigma)
    registers.push(reg)

if registers.size() > maxZones
    Register expired = registers.shift()
    deleteRegister(expired)

//--------------------------------------------------------------------------------------------------
// Register maintenance
//--------------------------------------------------------------------------------------------------
int bullActive = 0
int bearActive = 0
float strongestQuality = 0.0
float qualityAccumulator = 0.0
int mitigatedCount = 0
array<int> removeIndexes = array.new_int()

if registers.size() > 0
    for index = 0 to registers.size() - 1
        Register reg = registers.get(index)
        float midPrice = math.avg(reg.top, reg.bottom)
        int rightSide = extendZones ? bar_index + 22 : bar_index + 4
        color edgeColor = zoneColor(reg.bull, reg.quality)
        color fillColor = zoneFill(reg.bull, reg.quality)
        float zoneSize = reg.top - reg.bottom

        reg.zone.set_right(rightSide)
        reg.zone.set_bgcolor(fillColor)
        reg.zone.set_border_color(edgeColor)

        strongestQuality := math.max(strongestQuality, reg.quality)
        qualityAccumulator += reg.quality

        bool mitigated = reg.bull ? low <= reg.top and high >= reg.bottom : high >= reg.bottom and low <= reg.top
        bool invalidated = reg.bull ? low < reg.bottom : high > reg.top

        float mitigationDepth = reg.bull ? safeDiv(reg.top - low, zoneSize) : safeDiv(high - reg.bottom, zoneSize)
        float mitigationPct = math.max(0.0, math.min(100.0, mitigationDepth * 100.0))

        float unfilledPct = 100.0 - mitigationPct
        edgeColor := color.from_gradient(unfilledPct, 0, 100, reg.bull ? color.new(bullAccent, 0) : color.new(bearAccent, 0), reg.bull ? color.new(bullCore, 0) : color.new(bearCore, 0))
        fillColor := color.from_gradient(unfilledPct, 0, 100, reg.bull ? color.new(bullAccent, 96) : color.new(bearAccent, 96), reg.bull ? color.new(bullCore, 82) : color.new(bearCore, 82))

        reg.zone.set_bgcolor(fillColor)
        reg.zone.set_border_color(edgeColor)
        reg.poc.set_x2(rightSide)
        reg.poc.set_color(color.new(edgeColor, 10))
        reg.mid.set_x2(rightSide)
        reg.mid.set_color(showMidline ? color.new(edgeColor, 45) : color.new(edgeColor, 100))
        reg.info.set_x(rightSide + 1)

        string mitigationText =
             mitigationPct <= 0 ? "Open" :
             mitigationPct >= 100 ? "Filled" :
             "Mitigation " + formatPct(mitigationPct)

        reg.info.set_text((reg.bull ? "Bull Register" : "Bear Register") + "\nQ " + formatPct(reg.quality) + "\n" + mitigationText)
        reg.info.set_textcolor(edgeColor)

        if mitigated
            mitigatedCount += 1

        reg.zone.set_text(mitigationText)
        reg.zone.set_text_color(color.white)
        reg.zone.set_text_halign(text.align_right)
        reg.zone.set_text_valign(reg.bull ? text.align_bottom : text.align_top)

        if reg.bull
            bullActive += 1
        else
            bearActive += 1

        if showParticipation and reg.participation.max() > 0
            float step = zoneSize / profileBins
            for binIndex = 0 to profileBins - 1
                float lower = reg.bottom + step * binIndex
                float upper = lower + step
                float value = reg.participation.get(binIndex)
                float ratio = safeDiv(value, reg.participation.max())
                int left = reg.zone.get_left()
                int width = int(math.round(ratio * 18))
                color barColor = color.from_gradient(value, 0, reg.participation.max(), color.new(edgeColor, 95), color.new(edgeColor, 35))

                box profileBar = reg.bars.get(binIndex)
                if na(profileBar)
                    profileBar := box.new(left, upper, left + width, lower, bgcolor = barColor, border_color = color.new(edgeColor, 100))
                    reg.bars.set(binIndex, profileBar)
                else
                    profileBar.set_left(left)
                    profileBar.set_right(left + width)
                    profileBar.set_top(upper)
                    profileBar.set_bottom(lower)
                    profileBar.set_bgcolor(barColor)

                if value == reg.participation.max()
                    float pocPrice = math.avg(lower, upper)
                    reg.poc.set_y1(pocPrice)
                    reg.poc.set_y2(pocPrice)

        bool retired = invalidated or mitigationPct >= 100.0
        if retired and hideFilled
            array.push(removeIndexes, index)

if removeIndexes.size() > 0
    for removal = removeIndexes.size() - 1 to 0
        int removeIndex = removeIndexes.get(removal)
        Register doomed = registers.get(removeIndex)
        deleteRegister(doomed)
        registers.remove(removeIndex)

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
if showDashboard and barstate.islast
    float averageQuality = registers.size() > 0 ? qualityAccumulator / registers.size() : 0.0
    color biasColor = bullActive >= bearActive ? bullCore : bearCore
    color panelTop = color.new(biasColor, 84)
    float stackBias = bullActive - bearActive
    float activeRegisterCount = registers.size()

    dashboardCell(0, 0, "Aperture Register", panelTop, color.white)
    dashboardCell(1, 0, syminfo.ticker, panelTop, color.white)

    dashboardCell(0, 1, "Bull Active", panelBg, color.new(color.white, 10))
    dashboardCell(1, 1, str.tostring(bullActive), panelBg, bullCore)

    dashboardCell(0, 2, "Bear Active", panelBg, color.new(color.white, 10))
    dashboardCell(1, 2, str.tostring(bearActive), panelBg, bearCore)

    dashboardCell(0, 3, "Mitigated", panelBg, color.new(color.white, 10))
    dashboardCell(1, 3, str.tostring(mitigatedCount), panelBg, biasColor)

    dashboardCell(0, 4, "Avg Quality", panelBg, color.new(color.white, 10))
    dashboardCell(1, 4, formatPct(averageQuality), panelBg, color.white)

    dashboardCell(0, 5, "Best Quality", panelBg, color.new(color.white, 10))
    dashboardCell(1, 5, formatPct(strongestQuality), panelBg, biasColor)

    dashboardCell(0, 6, "LTF", panelBg, color.new(color.white, 10))
    dashboardCell(1, 6, ltf, panelBg, color.white)

    dashboardCell(0, 7, "Registers", panelBg, color.new(color.white, 10))
    dashboardCell(1, 7, str.tostring(activeRegisterCount), panelBg, color.white)

    dashboardCell(0, 8, "Stack Bias", panelBg, color.new(color.white, 10))
    dashboardCell(1, 8, str.tostring(stackBias, "#.0"), panelBg, stackBias >= 0 ? bullCore : bearCore)

//--------------------------------------------------------------------------------------------------
// Context coloring
//--------------------------------------------------------------------------------------------------
float activeBias = bullActive - bearActive
float biasAtr = ta.atr(100)
color registerCandle =
     activeBias > 0
     ? color.from_gradient(activeBias, 0, maxZones, color.new(bullCore, 50), color.new(bullCore, 0))
     : activeBias < 0
       ? color.from_gradient(math.abs(activeBias), 0, maxZones, color.new(bearCore, 50), color.new(bearCore, 0))
       : color.new(color.gray, 70)

plot(ta.ema(close, 34), "Imbalance Basis", color = color.new(color.white, 65))
plot(ta.ema(close, 34) + biasAtr * 0.3, "", display = display.none)
plot(ta.ema(close, 34) - biasAtr * 0.3, "", display = display.none)
barcolor(registerCandle)
plotcandle(open, high, low, close, color = registerCandle, wickcolor = registerCandle, bordercolor = registerCandle, force_overlay = true, title = "Register Candles")

//--------------------------------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------------------------------
bool freshBullRegister = confirmedBullGap
bool freshBearRegister = confirmedBearGap
bool stackedBullBias = barstate.isconfirmed and bullActive >= 2 and bullActive > bearActive
bool stackedBearBias = barstate.isconfirmed and bearActive >= 2 and bearActive > bullActive

alertcondition(freshBullRegister, "JOAT Aperture Fresh Bull Register", "A new bullish imbalance register has formed.")
alertcondition(freshBearRegister, "JOAT Aperture Fresh Bear Register", "A new bearish imbalance register has formed.")
alertcondition(stackedBullBias, "JOAT Aperture Bull Bias", "Bullish imbalance registers dominate the active stack.")
alertcondition(stackedBearBias, "JOAT Aperture Bear Bias", "Bearish imbalance registers dominate the active stack.")

plot(activeBias, "Register Bias (Data Window)", color = activeBias >= 0 ? bullCore : bearCore, display = display.data_window)
plot(qualityAccumulator, "Quality Sum (Data Window)", color = color.white, display = display.data_window)
plot(float(registers.size()), "Register Count (Data Window)", color = color.gray, display = display.data_window)
````
