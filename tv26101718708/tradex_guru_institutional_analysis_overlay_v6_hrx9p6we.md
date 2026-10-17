# TradeX Guru - Institutional Analysis Overlay v6

- url: https://www.tradingview.com/script/Hrx9P6wE-TradeX-Guru-Institutional-Analysis-Overlay-v6/
- type: indicator
- pine_id: PUB;df71943098c54120bdcea13822d77b1a
- version: 1.0

## Description

📝 Overview
This open-source institutional analysis tool bridges core corporate fundamentals with short-term tactical price levels directly on the chart interface. It is designed to visualize structural support/resistance zones alongside a visual representation of key balance sheet metrics and order runway progress.

🛠️ Key Technical Features & Calculations
Dynamic Pivot & R:R Boundaries: The script automatically plots reference pivot points, upside projections, and key invalidation zones based on fundamental valuation benchmarks.

Automated Risk-to-Reward Modeling: It calculates precise percentage targets and stop-loss metrics relative to the pivot line dynamically.

Translucent Asset Shading: Generates automated green/red background boundaries (boxes) around calculated target zones to evaluate structural margin safety efficiently.

📊 Integrated Fundamental Dashboards
Metric Status Grid (Top-Right): Displays essential corporate data points such as order backlog parameters, operational EBITDA margins, and balance sheet leverage health.

Order Runway Fill (Bottom-Right): Dynamically builds a string-based visual loading progress bar (███░░░░░░░) comparing annual revenue metrics directly against the total standing backlog to visualize multi-year revenue runway coverage.

⚙️ How To Use & Interactive Customization
All metrics, technical price inputs, colors, and panel positions are fully exposed in the script settings interface. Double-click the overlay lines or the indicator title to adapt the system variables to match updated institutional research notes or custom technical strategies.

## Source Code

````pine
//@version=6
indicator("TradeX Guru - Institutional Analysis Overlay v6", overlay=true)

// ==========================================
// 1. INTERACTIVE INPUTS (v6 Type-Safe)
// ==========================================
gp_tech = "Technical Analysis & R:R Levels"
refInput     = input.float(4440.0, title="📊 Current Reference Price", group=gp_tech)
targetInput  = input.float(5060.0, title="🎯 Upside Target", group=gp_tech)
supportInput = input.float(4230.0, title="🛡️ Key Support / SL", group=gp_tech)
showZones    = input.bool(true, title="Enable Translucent R:R Zones", group=gp_tech)

gp_fund = "Fundamental Dashboard Data"
showTable    = input.bool(true, title="Show Metrics Dashboard", group=gp_fund)
backlogText  = input.string("₹21,500 Cr (3.4x Coverage)", title="Order Backlog", group=gp_fund)
ebitdaText   = input.string("27.1% (vs -3.6% FY22)", title="EBITDA Margin", group=gp_fund)
balanceText  = input.string("100% Debt-Free", title="Balance Sheet", group=gp_fund)

gp_runway = "Order Runway Settings"
showRunway   = input.bool(true, title="Show Visual Runway Progress", group=gp_runway)
revenueVal   = input.float(6210.0, title="FY26 Revenue (₹ Cr)", group=gp_runway)
backlogVal   = input.float(21500.0, title="Total Backlog (₹ Cr)", group=gp_runway)

// ==========================================
// 2. MATHEMATICAL R:R CALCULATIONS
// ==========================================
float rewardPoints = targetInput - refInput
float riskPoints   = refInput - supportInput
float rrRatio      = riskPoints > 0 ? (rewardPoints / riskPoints) : 0.0

float targetPct    = (rewardPoints / refInput) * 100
float supportPct   = (riskPoints / refInput) * 100

// Design Colors
color greenMain   = #00c853
color redMain     = #d50000
color blueMain    = #2979ff
color grayMain    = #78909c
color textBgColor = color.new(color.black, 100)

// ==========================================
// 3. DYNAMIC LINES, LABELS & BOXES
// ==========================================
var line targetLine  = na
var line refLine     = na
var line supportLine = na

var label targetLabel  = na
var label refLabel     = na
var label supportLabel = na

var box rewardBox = na
var box riskBox   = na

if barstate.islast
    // Clear previous loop calculations to prevent ghosting
    line.delete(targetLine)
    line.delete(refLine)
    line.delete(supportLine)
    label.delete(targetLabel)
    label.delete(refLabel)
    label.delete(supportLabel)
    box.delete(rewardBox)
    box.delete(riskBox)

    int extendBars = 18
    int startBar   = bar_index - 60
    int endBar     = bar_index + extendBars

    // Plot Risk/Reward Target Shading Boxes
    // Change lines 72 and 73 to this:
    if showZones
        rewardBox := box.new(left=startBar, top=targetInput, right=endBar, bottom=refInput, bgcolor=color.new(greenMain, 92), border_color=na)
        riskBox   := box.new(left=startBar, top=refInput, right=endBar, bottom=supportInput, bgcolor=color.new(redMain, 93), border_color=na)

    // Render Structural Dynamic Lines
    targetLine  := line.new(startBar, targetInput, endBar, targetInput, color=greenMain, width=2, style=line.style_dashed)
    refLine     := line.new(startBar, refInput, endBar, refInput, color=grayMain, width=1, style=line.style_dotted)
    supportLine := line.new(startBar, supportInput, endBar, supportInput, color=redMain, width=2, style=line.style_solid)

    // Render Information Labels with Live Math Metrics
    targetLabel  := label.new(endBar, targetInput, "🎯 Target: ₹" + str.tostring(targetInput, "#.##") + " (+" + str.tostring(targetPct, "#.#") + "%)", color=textBgColor, textcolor=greenMain, style=label.style_label_left)
    refLabel     := label.new(endBar, refInput, "📊 Pivot Base: ₹" + str.tostring(refInput, "#.##") + " [R:R = 1:" + str.tostring(rrRatio, "#.##") + "]", color=textBgColor, textcolor=color.white, style=label.style_label_left)
    supportLabel := label.new(endBar, supportInput, "🛡️ Support: ₹" + str.tostring(supportInput, "#.##") + " (-" + str.tostring(supportPct, "#.#") + "%)", color=textBgColor, textcolor=redMain, style=label.style_label_left)

// ==========================================
// 4. METRIC DASHBOARD & PROGRESS RUNWAY
// ==========================================
var table statsTable = table.new(position.top_right, 2, 4, bgcolor=color.new(#1e222d, 10), border_color=#363c4e, border_width=1)
if barstate.islast and showTable
    table.cell(statsTable, 0, 0, "Key Metric", text_color=color.white, bgcolor=#2a2e39, text_size=size.large)
    table.cell(statsTable, 1, 0, "Value / Structure", text_color=color.white, bgcolor=#2a2e39, text_size=size.large)
    table.cell(statsTable, 0, 1, "Order Backlog", text_color=color.gray, text_size=size.large)
    table.cell(statsTable, 1, 1, backlogText, text_color=blueMain, text_size=size.large)
    table.cell(statsTable, 0, 2, "EBITDA Margin", text_color=color.gray, text_size=size.large)
    table.cell(statsTable, 1, 2, ebitdaText, text_color=greenMain, text_size=size.large)
    table.cell(statsTable, 0, 3, "Balance Sheet", text_color=color.gray, text_size=size.large)
    table.cell(statsTable, 1, 3, balanceText, text_color=greenMain, text_size=size.large)

// Building the String Progress Bar for the Order Runway
if barstate.islast and showRunway
    float fillPercent = (revenueVal / backlogVal) * 100
    int totalSegments = 10
    int filledSegments = math.round((fillPercent / 100) * totalSegments)
    
    string progressBar = ""
    if totalSegments > 0
        for i = 1 to totalSegments
            progressBar := progressBar + (i <= filledSegments ? "█" : "░")

    var table runwayTable = table.new(position.bottom_right, 2, 3, bgcolor=color.new(#1e222d, 10), border_color=#363c4e, border_width=1)
    table.cell(runwayTable, 0, 0, "⚡ Institutional Order Runway Runway", text_color=color.white, bgcolor=#2a2e39, text_size=size.large)
    table.merge_cells(runwayTable, 0, 0, 1, 0)
    table.cell(runwayTable, 0, 1, "Runway Fill:", text_color=color.gray, text_size=size.large)
    table.cell(runwayTable, 1, 1, progressBar + " (" + str.tostring(fillPercent, "#.#") + "%)", text_color=blueMain, text_size=size.large)
    table.cell(runwayTable, 0, 2, "Revenue Impact:", text_color=color.gray, text_size=size.large)
    table.cell(runwayTable, 1, 2, "₹" + str.tostring(backlogVal, "#") + " Cr Backlog provides ~3.4x Coverage", text_color=greenMain, text_size=size.large)
````
