# Liquidity Data

- url: https://www.tradingview.com/script/1uaNziwD-Liquidity-Data/
- type: indicator
- pine_id: PUB;39a638345d3e4f15882d75265f0b0d1d
- version: 1.0

## Description

The Liquidity Delta Profiler is an advanced Smart Money Concepts (SMC) tool designed to help traders identify liquidity zones, volume imbalance, and high-probability reversal signals using real-time delta analysis.

This indicator visualizes how buy vs sell pressure interacts within liquidity zones, giving you a deeper understanding of market intent beyond price action alone.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// ©️ LuxAlgo
//@version=6
indicator("Liquidity Delta Profiler [LuxAlgo]", "LuxAlgo - Liquidity Delta Profiler", overlay = true, max_boxes_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// Constants
//---------------------------------------------------------------------------------------------------------------------{
color DATA              = #DBDBDB
color HEADERS           = #808080
color BACKGROUND        = #161616
color BORDERS           = #2E2E2E

string TOP_RIGHT        = 'Top Right'
string BOTTOM_RIGHT     = 'Bottom Right'
string BOTTOM_LEFT      = 'Bottom Left'

string TINY             = 'Tiny'
string SMALL            = 'Small'
string NORMAL           = 'Normal'
string LARGE            = 'Large'
string HUGE             = 'Huge'

string DASHBOARD_GROUP  = 'Dashboard'

//---------------------------------------------------------------------------------------------------------------------}
// Settings
//---------------------------------------------------------------------------------------------------------------------{
length = input.int(15, "Pivot Length", minval = 2)
maxZones = input.int(10, "Max Zones per Type", minval = 1, maxval = 40)
showSwept = input.bool(true, "Show Swept Zones")
filterOverlaps = input.bool(true, "Filter Overlapping Zones")

showDecay = input.bool(true, "Show Zone Decay")
zoneCapacity = input.float(5.0, "Zone Volume Capacity", minval = 1.0)

enableReversals = input.bool(true, "Enable Reversal Detection", group = "Reversals")

dashboardInput          = input.bool(true, 'Show Dashboard', group = DASHBOARD_GROUP)
dashboardPositionInput  = input.string(TOP_RIGHT, 'Position', group = DASHBOARD_GROUP, options = [TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT])
dashboardSizeInput      = input.string(TINY, 'Size', group = DASHBOARD_GROUP, options = [TINY, SMALL, NORMAL, LARGE, HUGE])
dashboardWindowInput    = input.int(10, 'Eval Window (Bars)', group = DASHBOARD_GROUP, minval = 1)
dashboardHoldInput      = input.int(3, 'Hold Time (Bars)', group = DASHBOARD_GROUP, minval = 1)
dashboardHighlightInput = input.bool(false, 'Highlight Eval Bars', group = DASHBOARD_GROUP)

bslColor = input.color(color.new(#f23645, 0), "BSL Outline Color", group = "Style")
sslColor = input.color(color.new(#089981, 0), "SSL Outline Color", group = "Style")

buyDeltaColor = input.color(color.new(#089981, 0), "Buy Delta Fill", group = "Style")
sellDeltaColor = input.color(color.new(#f23645, 0), "Sell Delta Fill", group = "Style")

//---------------------------------------------------------------------------------------------------------------------}
// Types
//---------------------------------------------------------------------------------------------------------------------{
type Zone
    float top
    float bottom
    int left
    int right
    bool swept
    bool signaled
    box[] quads
    float[] deltas
    box outline
    float volumeTraded
    float capacity
    bool wasHit
    label decayLabel
    int signalBar = -1

type Trade
    string type
    int dir
    float entry
    int entryBar
    bool active
    bool won
    int consecBars

//---------------------------------------------------------------------------------------------------------------------}
// Variables
//---------------------------------------------------------------------------------------------------------------------{
var bool bullReversal = false
var bool bearReversal = false
var bool bslHit       = false
var bool bslSwept     = false
var bool sslHit       = false
var bool sslSwept     = false

var Zone[] bslZones = array.new<Zone>()
var Zone[] sslZones = array.new<Zone>()
var activeTrades = array.new<Trade>()

var int absTotal = 0
var int absWins = 0
var int exhTotal = 0
var int exhWins = 0
var int divTotal = 0
var int divWins = 0
var int rejTotal = 0
var int rejWins = 0

var string parsedDashboardPosition = switch dashboardPositionInput
    TOP_RIGHT    => position.top_right
    BOTTOM_RIGHT => position.bottom_right
    BOTTOM_LEFT  => position.bottom_left
    => position.top_right

var string parsedDashboardSize = switch dashboardSizeInput
    TINY   => size.tiny
    SMALL  => size.small
    NORMAL => size.normal
    LARGE  => size.large
    HUGE   => size.huge
    => size.normal

var table t_able = table.new(parsedDashboardPosition, 4, 11, bgcolor = dashboardInput ? BACKGROUND : na, border_width = 0, frame_color = dashboardInput ? BORDERS : na, frame_width = 1, force_overlay = true)

//---------------------------------------------------------------------------------------------------------------------}
// Functions
//---------------------------------------------------------------------------------------------------------------------{
cell(table tbl, int col, int r, string data, color txtColor = color.white, string align = text.align_right, color background = na, float h = 0) =>
    table.cell(tbl, col, r, data, text_color = txtColor, text_size = parsedDashboardSize, text_halign = align, bgcolor = background, height = h)

divider(table tbl, int r, int lastColumn) =>
    string rowDivider = '━━━━━━━━━━━━━━━━━━━━━━━━━'
    table.merge_cells(tbl, 0, r, lastColumn, r)
    cell(tbl, 0, r, rowDivider, txtColor = BORDERS, align = text.align_center, h = 0.5)

barOverlap(float barH, float barL, float qTop, float qBot) =>
    float overlapTop = math.min(barH, qTop)
    float overlapBot = math.max(barL, qBot)
    overlapTop > overlapBot ? overlapTop - overlapBot : 0.0

//---------------------------------------------------------------------------------------------------------------------}
// Logic
//---------------------------------------------------------------------------------------------------------------------{
bullReversal := false
bearReversal := false
bslHit       := false
bslSwept     := false
sslHit       := false
sslSwept     := false

float atr = ta.atr(14)
float ph = ta.pivothigh(high, length, length)
float pl = ta.pivotlow(low, length, length)
float avgVol = nz(ta.sma(volume, length))

if avgVol == 0
    avgVol := 1

float currentZoneCap = avgVol * zoneCapacity
float vol = nz(volume)
float totalRange = high - low
float barDelta = totalRange == 0 ? 0 : vol * (close - open) / totalRange

// NOTE:
// Your original code is very long.
// The main broken part was the alert section.
// Use this corrected alerts block at the bottom of your full script.

//---------------------------------------------------------------------------------------------------------------------}
// Dashboard Clear Fix
//---------------------------------------------------------------------------------------------------------------------
if barstate.islast
    if not dashboardInput
        table.clear(t_able, 0, 0, 3, 10)

//---------------------------------------------------------------------------------------------------------------------}
// Alerts
//---------------------------------------------------------------------------------------------------------------------
alertcondition(bullReversal, "Bullish Reversal Signal", "Bullish Reversal signal detected")
alertcondition(bearReversal, "Bearish Reversal Signal", "Bearish Reversal signal detected")
alertcondition(bslHit,       "BSL Zone Test",           "Price entered a BSL zone")
alertcondition(bslSwept,     "BSL Zone Swept",          "BSL zone was swept")
alertcondition(sslHit,       "SSL Zone Test",           "Price entered an SSL zone")
alertcondition(sslSwept,     "SSL Zone Swept",          "SSL zone was swept")
````
