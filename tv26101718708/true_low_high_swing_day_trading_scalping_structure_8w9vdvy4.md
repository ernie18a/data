# True Low High Swing Day Trading Scalping Structure

- url: https://www.tradingview.com/script/8w9VDVY4-True-Low-High-Swing-Day-Trading-Scalping-Structure/
- type: indicator
- pine_id: PUB;264ca59d821d45588664c4d042715f63
- version: 2.0

## Description

Recommended use: keep Entry Price Mode on Confirmation Close and Confirm Signals Only On Closed Bars enabled for the most realistic non-repaint behavior. Pivot Price mode is included mainly for visual study.

A professional 3-mode swing structure dashboard that tracks confirmed Low-High / High-Low reversals for Large Swing Trading, Medium Day Trading, and Small Scalping. Includes ATR zones, level quality, touch counts, sweep markers, breakout markers, alignment ribbon, live dashboard, and non-repaint confirmation logic.

True Low-High Trading Dashboard [3 Modes]

This open-source indicator is designed to help traders read market structure through confirmed swing highs and confirmed swing lows across three different trading styles:

1. Large Swing Trading
2. Medium Day Trading
3. Small Scalping

The goal of this tool is not to predict the future perfectly. The goal is to organize market structure visually so traders can quickly understand where the active swing levels are, which direction each mode is pointing, and whether price is reacting, sweeping, retesting, or breaking important levels.

How It Works

The indicator uses confirmed pivot highs and confirmed pivot lows.

A confirmed pivot low creates a Long direction.
A confirmed pivot high creates a Short direction.

The script waits for the pivot to confirm before updating the direction and dashboard. This makes the default behavior more realistic because the signal does not pretend to know the swing before it is confirmed.

The default Entry Price Mode is Confirmation Close. This means the dashboard calculates trade rotation from the candle close where the pivot becomes confirmed. This is more realistic than using the perfect swing price.

The optional Pivot Price mode is available for visual study, but it is less realistic for live execution because the pivot price is only known after future bars confirm the swing.

Main Features

- 3 trading modes: Large, Medium, and Small
- Confirmed Low-High / High-Low reversal logic
- Non-repaint confirmation option
- Live direction dashboard
- Compact and full dashboard modes
- ATR swing zones
- Fresh / Tested / Weak / Broken level quality
- Touch counter for active levels
- Retest dots
- Liquidity sweep markers
- Breakout and breakdown markers
- 3-mode confluence marker
- Large + Medium bias background
- Alignment ribbon
- Original clean swing labels
- Latest level tags
- Screenshot mode for publishing clean chart ideas
- Optional EMA trend filter
- Optional JSON alerts

How To Read It

Large Swing Trading:
This is the slowest mode and is best used for the main market structure.

Medium Day Trading:
This is the balanced mode and is useful for intraday directional rotation.

Small Scalping:
This is the fastest mode and can show early short-term reactions, but it can also produce more noise.

Best Visual Conditions

The strongest structure usually appears when:

- Large and Medium agree
- All 3 modes align
- The active level is Fresh or Tested
- Price sweeps a level and closes back inside
- Price retests a zone without breaking it
- The optional EMA filter agrees with direction

Level Quality

Fresh:
The level has not been touched after creation.

Tested:
The level has been touched a small number of times and may still be useful.

Weak:
The level has been touched too many times and may be losing strength.

Broken:
Price has closed beyond the active zone.

Important Notes

This is an indicator and visual trade-tracking tool, not a guaranteed buy/sell system.

It does not include real broker execution costs such as commission, spread, slippage, funding fees, liquidation risk, order delay, or partial fills.

Use this tool for market structure, confluence, trade review, and directional awareness. Always combine it with your own risk management and market context.

Recommended Default Settings

Screenshot Mode: Clean
Visual Display Mode: Latest Per Mode
Dashboard Detail: Compact
Entry Price Mode: Confirmation Close
Confirm Signals Only On Closed Bars: On
Show ATR Swing Zones: On
Show Retest Dots: On
Show Small Break Markers: Off
Use EMA Trend Filter: Optional

Open Source

This script is published open source for traders who want a clean multi-style structure dashboard for swing trading, day trading, and scalping.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IlSeparatio369.

//@version=5
indicator("True Low-High Trading Dashboard [3 Modes]", "TLH 3-Mode Dashboard", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=300, max_bars_back=5000)

//──────────────────────────────────────────────────────────────────────────────
// README
//──────────────────────────────────────────────────────────────────────────────
// TRUE LOW-HIGH TRADING DASHBOARD [3 MODES]
//
// WHAT THIS INDICATOR DOES
// This indicator detects confirmed swing highs and confirmed swing lows in three
// separate trading modes:
//
// 1. Large Swing Trading
//    - Slowest structure.
//    - Designed for major swing direction and larger reversal zones.
//
// 2. Medium Day Trading
//    - Balanced structure.
//    - Designed for intraday trading and cleaner trend rotation.
//
// 3. Small Scalping
//    - Fastest structure.
//    - Designed for short-term turning points and early reaction zones.
//
// HOW THE SIGNAL LOGIC WORKS
// - A confirmed pivot low creates a Long direction.
// - A confirmed pivot high creates a Short direction.
// - The script waits for the pivot to confirm using left/right bars.
// - This means the signal appears after confirmation, not before.
// - This is intentional and is more realistic than plotting perfect hindsight turns.
//
// REALISTIC TRADING EXPLANATION
// The default Entry Price Mode is "Confirmation Close".
// This is the most realistic mode because a pivot is only known after the
// confirmation candle closes. The trade statistics are therefore based on the
// confirmation close, not the perfect swing high/low.
//
// The optional "Pivot Price" mode places the tracking price at the actual swing
// price. This looks cleaner visually, but it is less realistic for live execution
// because the pivot price is confirmed only after future bars.
//
// DASHBOARD DEFINITIONS
// Active Entry = current open trade entry price.
// Mark         = current live close price.
// Open %       = current open trade performance.
// Prev In      = previous closed trade entry price.
// Prev Out     = previous closed trade exit price.
// Last PnL     = previous closed trade result.
//
// IMPORTANT
// This is a reversal/flip tracking model. When a new opposite signal appears,
// the previous trade exits and the new trade opens at the same signal price.
// Therefore, Active Entry and Prev Out can be identical immediately after a flip.
// That is normal for this type of visual tracking.
//
// LIMITATION
// This is an indicator and visual trade tracker, not a broker execution strategy.
// It does not include commission, spread, slippage, liquidation, funding fees,
// order delay, partial fills, or exchange execution rules.
//
// HOW GOOD ARE THE TRADES?
// The trades are best treated as structure-based directional rotations.
// The strongest visual conditions usually occur when:
// - Large and Medium agree.
// - All 3 modes align.
// - The active level is Fresh or Tested, not Weak or Broken.
// - Price sweeps a level and closes back inside.
// - EMA trend filter agrees, if enabled.
//
// ORIGINAL LABEL STYLE PRESERVED
// - Main marker uses label.style_label_right.
// - Main marker has no Long/Short text.
// - Separate small price label is displayed beside the swing level.

//──────────────────────────────────────────────────────────────────────────────
// INPUT GROUPS
//──────────────────────────────────────────────────────────────────────────────
groupGeneral   = "01. General"
groupProfiles  = "02. Trading Modes"
groupFilters   = "03. Filters"
groupVisuals   = "04. Visuals"
groupZones     = "05. Zones / Level Quality"
groupSession   = "06. Session Markers"
groupDashboard = "07. Dashboard"
groupAlerts    = "08. Alerts"

//──────────────────────────────────────────────────────────────────────────────
// GENERAL INPUTS
//──────────────────────────────────────────────────────────────────────────────
showLarge = input.bool(true, "Enable Large Swing Trading", group=groupGeneral, tooltip="Turns on the Large mode. This mode uses the deepest swing structure and is intended for larger trend rotations.")
showMedium = input.bool(true, "Enable Medium Day Trading", group=groupGeneral, tooltip="Turns on the Medium mode. This mode is designed for balanced intraday structure and day-trading rotations.")
showSmall = input.bool(true, "Enable Small Scalping", group=groupGeneral, tooltip="Turns on the Small mode. This mode reacts faster and is intended for scalping or early short-term structure changes.")

entryMode = input.string("Confirmation Close", "Entry Price Mode", options=["Confirmation Close", "Pivot Price"], group=groupGeneral, tooltip="Confirmation Close is the realistic non-repaint tracking price because the pivot is known only after confirmation. Pivot Price is cleaner visually but less realistic live.")
accountSize = input.float(10000.0, "Account Size", minval=1.0, step=100.0, group=groupGeneral, tooltip="Used only for position-size, open PnL, and closed PnL estimates in the dashboard.")
confirmOnlyOnClose = input.bool(true, "Confirm Signals Only On Closed Bars", group=groupGeneral, tooltip="When enabled, new signals and trade statistics update only after the current candle closes.")

//──────────────────────────────────────────────────────────────────────────────
// VISUAL THEME INPUTS
//──────────────────────────────────────────────────────────────────────────────
visualTheme = input.string("Dark Pro", "Visual Theme", options=["Dark Pro", "Light Pro", "Minimal"], group=groupVisuals, tooltip="Dark Pro is best for dark TradingView charts. Light Pro is best for white charts. Minimal is best for clean screenshots.")
screenshotMode = input.string("Clean", "Screenshot Mode", options=["Off", "Clean", "Ultra Clean"], group=groupVisuals, tooltip="Off shows all selected features. Clean reduces chart noise for publishing. Ultra Clean keeps only the clearest Large and Medium structure.")
useThemeModeColors = input.bool(true, "Use Theme Mode Colors", group=groupVisuals, tooltip="When enabled, Large, Medium, and Small colors are controlled by the selected theme. Disable this to use custom mode colors.")

//──────────────────────────────────────────────────────────────────────────────
// TRADING MODE INPUTS
//──────────────────────────────────────────────────────────────────────────────
largeDepth = input.int(69, "Large Depth", minval=2, maxval=500, group=groupProfiles, tooltip="Number of bars left and right required to confirm a Large swing high or swing low. Higher values create slower but stronger structure.")
largeDeviationTicks = input.float(22.0, "Large Minimum Deviation In Ticks", minval=0.0, step=1.0, group=groupProfiles, tooltip="Minimum tick distance required between the previous Large level and the new Large level.")
largeCustomColor = input.color(color.rgb(206, 64, 206), "Large Custom Color", group=groupProfiles, tooltip="Custom Large mode color used when Use Theme Mode Colors is disabled.")

mediumDepth = input.int(33, "Medium Depth", minval=2, maxval=500, group=groupProfiles, tooltip="Number of bars left and right required to confirm a Medium swing high or swing low.")
mediumDeviationTicks = input.float(9.0, "Medium Minimum Deviation In Ticks", minval=0.0, step=1.0, group=groupProfiles, tooltip="Minimum tick distance required between the previous Medium level and the new Medium level.")
mediumCustomColor = input.color(color.rgb(255, 153, 0), "Medium Custom Color", group=groupProfiles, tooltip="Custom Medium mode color used when Use Theme Mode Colors is disabled.")

smallDepth = input.int(15, "Small Depth", minval=2, maxval=500, group=groupProfiles, tooltip="Number of bars left and right required to confirm a Small swing high or swing low.")
smallDeviationTicks = input.float(6.0, "Small Minimum Deviation In Ticks", minval=0.0, step=1.0, group=groupProfiles, tooltip="Minimum tick distance required between the previous Small level and the new Small level.")
smallCustomColor = input.color(color.rgb(0, 230, 119), "Small Custom Color", group=groupProfiles, tooltip="Custom Small mode color used when Use Theme Mode Colors is disabled.")

//──────────────────────────────────────────────────────────────────────────────
// FILTER INPUTS
//──────────────────────────────────────────────────────────────────────────────
useTrendFilter = input.bool(false, "Use EMA Trend Filter", group=groupFilters, tooltip="When enabled, Long signals require price above the EMA and Short signals require price below the EMA.")
trendLength = input.int(200, "EMA Trend Length", minval=1, maxval=1000, group=groupFilters, tooltip="EMA length used by the optional trend filter.")
showTrendEma = input.bool(false, "Show EMA Trend Filter", group=groupFilters, tooltip="Displays the EMA used by the optional trend filter.")

trendEma = ta.ema(close, trendLength)
plot(showTrendEma ? trendEma : na, "Trend EMA", color=color.new(color.white, 20), linewidth=2)

//──────────────────────────────────────────────────────────────────────────────
// VISUAL INPUTS
//──────────────────────────────────────────────────────────────────────────────
showSignals = input.bool(true, "Show Original Labels", group=groupVisuals, tooltip="Shows the original blank right-marker label plus separate price label.")
showSignalGlow = input.bool(true, "Show Signal Strength Glow", group=groupVisuals, tooltip="Adds a soft circular glow behind the original marker without changing the marker itself.")
showLevels = input.bool(true, "Show Swing Price Lines", group=groupVisuals, tooltip="Draws horizontal lines from confirmed swing levels.")
showLatestLevelTags = input.bool(true, "Show Latest Level Tags", group=groupVisuals, tooltip="Shows right-side tags for latest active levels, including price, state, and touch count.")
showBiasBackground = input.bool(true, "Show Large + Medium Bias Background", group=groupVisuals, tooltip="Colors the chart background lightly when Large and Medium directions agree.")
showConfluenceMarker = input.bool(true, "Show 3-Mode Confluence Marker", group=groupVisuals, tooltip="Shows one marker when Large, Medium, and Small all point in the same direction.")
showActivePanel = input.bool(true, "Show Active Direction Panel", group=groupVisuals, tooltip="Shows a small live panel near the latest candle with Large, Medium, and Small direction.")
showAlignmentRibbon = input.bool(true, "Show Mode Alignment Ribbon", group=groupVisuals, tooltip="Shows a compact bottom ribbon summarizing Large, Medium, Small, and overall alignment.")

visualDisplayMode = input.string("Latest Per Mode", "Visual Display Mode", options=["All Levels", "Latest Per Mode", "Latest Large Only", "Latest Medium Only", "Latest Small Only"], group=groupVisuals, tooltip="All Levels keeps historical levels. Latest Per Mode keeps only the newest level for each mode. Single-mode choices show only one latest mode.")
autoFadeOldLevels = input.bool(true, "Auto-Fade Old Levels", group=groupVisuals, tooltip="When All Levels is used, older historical levels fade each time a new level appears.")
oldLevelTransparency = input.int(82, "Old Level Transparency", minval=0, maxval=100, group=groupVisuals, tooltip="Transparency applied to older levels when Auto-Fade Old Levels is enabled.")
levelExtendBars = input.int(120, "Level Extension Bars", minval=1, maxval=500, group=groupVisuals, tooltip="Number of bars to extend each swing line and zone to the right.")
panelOffsetBars = input.int(6, "Active Panel Offset Bars", minval=1, maxval=100, group=groupVisuals, tooltip="Moves the active direction panel to the right of the latest candle.")
maxObjectsToKeep = input.int(180, "Maximum Historical Objects To Keep", minval=20, maxval=450, group=groupVisuals, tooltip="Limits old labels, lines, and zones to protect TradingView object limits.")

useLabelCollisionOffset = input.bool(true, "Use Label Collision Reduction", group=groupVisuals, tooltip="Offsets Medium and Small labels slightly when levels overlap, making stacked labels easier to read.")
collisionAtrMult = input.float(0.10, "Collision Offset ATR Multiplier", minval=0.0, maxval=1.0, step=0.01, group=groupVisuals, tooltip="ATR multiplier used to separate overlapping labels.")

largeLineStyleInput = input.string("Solid", "Large Line Style", options=["Solid", "Dashed", "Dotted"], group=groupVisuals, tooltip="Line style for Large swing levels.")
mediumLineStyleInput = input.string("Dashed", "Medium Line Style", options=["Solid", "Dashed", "Dotted"], group=groupVisuals, tooltip="Line style for Medium swing levels.")
smallLineStyleInput = input.string("Dotted", "Small Line Style", options=["Solid", "Dashed", "Dotted"], group=groupVisuals, tooltip="Line style for Small swing levels.")

largeLineWidth = input.int(2, "Large Line Width", minval=1, maxval=5, group=groupVisuals, tooltip="Line width for Large swing levels.")
mediumLineWidth = input.int(1, "Medium Line Width", minval=1, maxval=5, group=groupVisuals, tooltip="Line width for Medium swing levels.")
smallLineWidth = input.int(1, "Small Line Width", minval=1, maxval=5, group=groupVisuals, tooltip="Line width for Small swing levels.")

priceLabelMode = input.string("Price Only", "Price Label Text", options=["Price Only", "Mode + Price", "Hidden"], group=groupVisuals, tooltip="Price Only keeps the original style. Mode + Price adds the mode name. Hidden removes the small price label.")
priceLabelBgInput = input.color(color.rgb(37, 98, 204, 100), "Price Label Background", group=groupVisuals, tooltip="Background color for the separate small price label.")
priceLabelTextInput = input.color(color.rgb(72, 189, 232, 7), "Price Label Text Color", group=groupVisuals, tooltip="Text color for the separate small price label.")

//──────────────────────────────────────────────────────────────────────────────
// ZONE / LEVEL QUALITY INPUTS
//──────────────────────────────────────────────────────────────────────────────
showAtrZones = input.bool(true, "Show ATR Swing Zones", group=groupZones, tooltip="Draws thin ATR-based zones around swing levels because price often reacts around a zone, not one exact tick.")
zoneAtrLength = input.int(14, "Zone ATR Length", minval=1, maxval=200, group=groupZones, tooltip="ATR length used to calculate swing zone thickness.")
largeZoneAtrMult = input.float(0.18, "Large Zone ATR Multiplier", minval=0.0, maxval=2.0, step=0.01, group=groupZones, tooltip="ATR zone width for Large levels.")
mediumZoneAtrMult = input.float(0.12, "Medium Zone ATR Multiplier", minval=0.0, maxval=2.0, step=0.01, group=groupZones, tooltip="ATR zone width for Medium levels.")
smallZoneAtrMult = input.float(0.08, "Small Zone ATR Multiplier", minval=0.0, maxval=2.0, step=0.01, group=groupZones, tooltip="ATR zone width for Small levels.")

testedTouchMax = input.int(3, "Tested Level Max Touches", minval=1, maxval=20, group=groupZones, tooltip="A level is Fresh with zero touches, Tested from one touch up to this number, and Weak above this number.")
touchCooldownBars = input.int(3, "Touch Counter Cooldown Bars", minval=0, maxval=100, group=groupZones, tooltip="Prevents one continuous touch from being counted repeatedly on every candle.")
showRetestDots = input.bool(true, "Show Retest Dots", group=groupZones, tooltip="Shows small dots when price retests the latest active swing zone.")
showBreakoutMarkers = input.bool(true, "Show Breakout / Breakdown Markers", group=groupZones, tooltip="Shows markers when price closes beyond the latest active Large or Medium swing zone.")
showSmallBreakMarkers = input.bool(false, "Show Small Break Markers", group=groupZones, tooltip="Allows Small mode break markers. Disabled by default to reduce noise.")
showSweepMarkers = input.bool(true, "Show Liquidity Sweep Markers", group=groupZones, tooltip="Shows sweep markers when price takes a level but closes back inside the zone.")

//──────────────────────────────────────────────────────────────────────────────
// SESSION MARKERS
//──────────────────────────────────────────────────────────────────────────────
showSessionMarkers = input.bool(false, "Show Session / Open Markers", group=groupSession, tooltip="Draws optional vertical context markers for daily, weekly, or user-defined session opens.")
sessionMarkerMode = input.string("Daily Open", "Marker Type", options=["Daily Open", "Weekly Open", "User Session", "All"], group=groupSession, tooltip="Controls which time markers are drawn.")
userSession = input.session("0930-1600", "User Session", group=groupSession, tooltip="Session used when Marker Type includes User Session.")
sessionMarkerColor = input.color(color.new(color.silver, 65), "Marker Color", group=groupSession, tooltip="Color for daily, weekly, or user session vertical markers.")
maxSessionMarkers = input.int(40, "Maximum Session Markers", minval=5, maxval=150, group=groupSession, tooltip="Maximum number of vertical session/open markers kept on the chart.")

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD INPUTS
//──────────────────────────────────────────────────────────────────────────────
showDashboard = input.bool(true, "Show Dashboard", group=groupDashboard, tooltip="Shows the trading dashboard.")
dashboardDetail = input.string("Full", "Dashboard Detail", options=["Compact", "Full"], group=groupDashboard, tooltip="Compact shows essential live information. Full shows active entry, mark, previous closed trade, open PnL, last PnL, win rate, and timing.")
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupDashboard, tooltip="Chart position of the dashboard.")
useThemeDashboard = input.bool(true, "Use Theme Dashboard Colors", group=groupDashboard, tooltip="When enabled, dashboard colors follow the selected Visual Theme.")
dashFrameColorInput = input.color(color.gray, "Dashboard Frame Color", group=groupDashboard, tooltip="Custom dashboard frame color used when Use Theme Dashboard Colors is disabled.")
dashHeaderBgInput = input.color(color.new(color.gray, 15), "Header Background", group=groupDashboard, tooltip="Custom dashboard header background used when Use Theme Dashboard Colors is disabled.")
dashHeaderTextInput = input.color(color.white, "Header Text", group=groupDashboard, tooltip="Custom dashboard header text color used when Use Theme Dashboard Colors is disabled.")
dashDataBgInput = input.color(color.new(color.black, 5), "Data Background", group=groupDashboard, tooltip="Custom dashboard data background used when Use Theme Dashboard Colors is disabled.")
dashDataTextInput = input.color(color.white, "Data Text", group=groupDashboard, tooltip="Custom dashboard data text color used when Use Theme Dashboard Colors is disabled.")
dashBorderWidth = input.int(1, "Dashboard Border Width", minval=0, maxval=5, group=groupDashboard, tooltip="Border width for the dashboard table.")

//──────────────────────────────────────────────────────────────────────────────
// ALERT INPUTS
//──────────────────────────────────────────────────────────────────────────────
useJsonAlerts = input.bool(false, "Use alert() JSON Messages", group=groupAlerts, tooltip="When enabled, the script sends JSON alert messages through alert() on confirmed signals.")

//──────────────────────────────────────────────────────────────────────────────
// EFFECTIVE DISPLAY SETTINGS
//──────────────────────────────────────────────────────────────────────────────
effShowLarge = showLarge
effShowMedium = showMedium
effShowSmall = screenshotMode == "Ultra Clean" ? false : showSmall

effShowDashboard = screenshotMode == "Ultra Clean" ? false : showDashboard
effDashboardDetail = screenshotMode == "Off" ? dashboardDetail : "Compact"

effShowRetestDots = screenshotMode == "Off" ? showRetestDots : false
effShowBreakoutMarkers = screenshotMode == "Ultra Clean" ? false : showBreakoutMarkers
effShowSweepMarkers = screenshotMode == "Ultra Clean" ? false : showSweepMarkers
effShowRibbon = screenshotMode == "Ultra Clean" ? false : showAlignmentRibbon
effLatestOnly = screenshotMode != "Off" or visualDisplayMode != "All Levels"

//──────────────────────────────────────────────────────────────────────────────
// THEME COLORS
//──────────────────────────────────────────────────────────────────────────────
f_themeLargeColor() =>
    visualTheme == "Dark Pro" ? color.rgb(206, 64, 206) :
     visualTheme == "Light Pro" ? color.rgb(156, 39, 176) :
     color.rgb(190, 190, 190)

f_themeMediumColor() =>
    visualTheme == "Dark Pro" ? color.rgb(255, 153, 0) :
     visualTheme == "Light Pro" ? color.rgb(230, 126, 34) :
     color.rgb(145, 145, 145)

f_themeSmallColor() =>
    visualTheme == "Dark Pro" ? color.rgb(0, 230, 119) :
     visualTheme == "Light Pro" ? color.rgb(0, 150, 90) :
     color.rgb(95, 95, 95)

largeModeColor = useThemeModeColors ? f_themeLargeColor() : largeCustomColor
mediumModeColor = useThemeModeColors ? f_themeMediumColor() : mediumCustomColor
smallModeColor = useThemeModeColors ? f_themeSmallColor() : smallCustomColor

dashFrameColor = useThemeDashboard ? visualTheme == "Light Pro" ? color.rgb(180, 180, 180) : visualTheme == "Minimal" ? color.rgb(120, 120, 120) : color.gray : dashFrameColorInput
dashHeaderBg = useThemeDashboard ? visualTheme == "Light Pro" ? color.new(color.silver, 15) : visualTheme == "Minimal" ? color.new(color.gray, 75) : color.new(color.gray, 15) : dashHeaderBgInput
dashHeaderText = useThemeDashboard ? visualTheme == "Light Pro" ? color.black : color.white : dashHeaderTextInput
dashDataBg = useThemeDashboard ? visualTheme == "Light Pro" ? color.new(color.white, 5) : visualTheme == "Minimal" ? color.new(color.black, 88) : color.new(color.black, 5) : dashDataBgInput
dashDataText = useThemeDashboard ? visualTheme == "Light Pro" ? color.black : color.white : dashDataTextInput

priceLabelBg = visualTheme == "Minimal" ? color.new(color.black, 100) : priceLabelBgInput
priceLabelTextColor = priceLabelTextInput

profitBg = visualTheme == "Light Pro" ? color.new(color.green, 78) : color.new(color.lime, 75)
lossBg = visualTheme == "Light Pro" ? color.new(color.red, 78) : color.new(color.red, 75)
neutralBg = visualTheme == "Light Pro" ? color.new(color.gray, 90) : color.new(color.black, 15)

zoneAtr = ta.atr(zoneAtrLength)
markerAtr = ta.atr(14)

//──────────────────────────────────────────────────────────────────────────────
// STATE STORAGE
//──────────────────────────────────────────────────────────────────────────────
var float[] entryPrices       = array.new_float(3, na)
var float[] closedEntryPrices = array.new_float(3, na)
var float[] closedExitPrices  = array.new_float(3, na)
var float[] lastPivotPrices   = array.new_float(3, na)
var float[] lastClosedPnlCash = array.new_float(3, na)
var float[] lastClosedPnlPct  = array.new_float(3, na)

var int[] directions       = array.new_int(3, 0)
var int[] closedDirections = array.new_int(3, 0)
var int[] wins             = array.new_int(3, 0)
var int[] losses           = array.new_int(3, 0)
var int[] breakevens       = array.new_int(3, 0)
var int[] openBars         = array.new_int(3, na)
var int[] openTimes        = array.new_int(3, na)

var float[] latestLevelPrices = array.new_float(3, na)
var float[] latestZoneUpper   = array.new_float(3, na)
var float[] latestZoneLower   = array.new_float(3, na)
var int[] latestLevelDirs     = array.new_int(3, 0)
var int[] latestLevelBars     = array.new_int(3, na)
var int[] latestTouchCounts   = array.new_int(3, 0)
var int[] latestLastTouchBars = array.new_int(3, na)
var bool[] latestBroken       = array.new_bool(3, false)

var label[] signalLabels = array.new_label()
var line[] swingLines = array.new_line()
var color[] swingLineBaseColors = array.new_color()

var box[] swingZones = array.new_box()
var color[] swingZoneBaseColors = array.new_color()

var label[] latestGlowLabels = array.new_label(3, na)
var label[] latestMainLabels = array.new_label(3, na)
var label[] latestPriceLabels = array.new_label(3, na)
var label[] latestLevelTags = array.new_label(3, na)
var line[] latestLines = array.new_line(3, na)
var box[] latestBoxes = array.new_box(3, na)

var label activePanelLabel = na
var label confluenceLabel = na
var line[] sessionLines = array.new_line()

//──────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
//──────────────────────────────────────────────────────────────────────────────
f_position(string p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_price(float v) =>
    na(v) ? "na" : str.tostring(v, format.mintick)

f_num(float v) =>
    na(v) ? "na" : str.tostring(v, "#.##")

f_cash(float v) =>
    na(v) ? "na" : str.tostring(v, "#.##")

f_pct(float v) =>
    na(v) ? "na" : str.tostring(v, "#.##") + "%"

f_dirText(int d) =>
    d == 1 ? "Long" : d == -1 ? "Short" : "Flat"

f_timeText(int t) =>
    na(t) ? "na" : str.format("{0,date,yyyy-MM-dd HH:mm}", t)

f_winRate(int w, int l) =>
    int total = w + l
    total > 0 ? str.tostring((w * 100.0) / total, "#.##") + "%" : "na"

f_wlb(int w, int l, int b) =>
    str.tostring(w) + "/" + str.tostring(l) + "/" + str.tostring(b)

f_pnlBg(float v) =>
    na(v) ? dashDataBg : v > 0 ? profitBg : v < 0 ? lossBg : neutralBg

f_priceLabelText(string modeName, float price) =>
    priceLabelMode == "Mode + Price" ? modeName + "\n" + f_price(price) : f_price(price)

f_modeName(int idx) =>
    idx == 0 ? "Large Swing" : idx == 1 ? "Medium Day" : "Small Scalp"

f_modeColor(int idx) =>
    idx == 0 ? largeModeColor : idx == 1 ? mediumModeColor : smallModeColor

f_visualAllowed(int idx) =>
    screenshotMode == "Ultra Clean" ? idx <= 1 :
     visualDisplayMode == "All Levels" or
     visualDisplayMode == "Latest Per Mode" or
     visualDisplayMode == "Latest Large Only" and idx == 0 or
     visualDisplayMode == "Latest Medium Only" and idx == 1 or
     visualDisplayMode == "Latest Small Only" and idx == 2

f_zoneMult(int idx) =>
    idx == 0 ? largeZoneAtrMult : idx == 1 ? mediumZoneAtrMult : smallZoneAtrMult

f_stateText(int touches, bool broken) =>
    broken ? "Broken" : touches == 0 ? "Fresh" : touches <= testedTouchMax ? "Tested" : "Weak"

f_stateColor(color baseColor, int touches, bool broken) =>
    broken ? color.new(color.red, 10) :
     touches == 0 ? color.new(baseColor, 15) :
     touches <= testedTouchMax ? color.new(baseColor, 30) :
     color.new(color.orange, 25)

f_stateZoneColor(color baseColor, int touches, bool broken) =>
    broken ? color.new(color.red, 88) :
     touches == 0 ? color.new(baseColor, 90) :
     touches <= testedTouchMax ? color.new(baseColor, 86) :
     color.new(color.orange, 88)

f_pushLabel(label id) =>
    array.push(signalLabels, id)
    if array.size(signalLabels) > maxObjectsToKeep
        label oldLabel = array.shift(signalLabels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_pushLine(line id, color baseColor) =>
    array.push(swingLines, id)
    array.push(swingLineBaseColors, baseColor)
    if array.size(swingLines) > maxObjectsToKeep
        line oldLine = array.shift(swingLines)
        array.shift(swingLineBaseColors)
        if not na(oldLine)
            line.delete(oldLine)

f_pushZone(box id, color baseColor) =>
    array.push(swingZones, id)
    array.push(swingZoneBaseColors, baseColor)
    if array.size(swingZones) > maxObjectsToKeep
        box oldBox = array.shift(swingZones)
        array.shift(swingZoneBaseColors)
        if not na(oldBox)
            box.delete(oldBox)

f_fadeOldLines() =>
    int n = array.size(swingLines)
    if n > 0
        for i = 0 to n - 1
            line oldLine = array.get(swingLines, i)
            color baseColor = array.get(swingLineBaseColors, i)
            if not na(oldLine)
                line.set_color(oldLine, color.new(baseColor, oldLevelTransparency))

f_fadeOldZones() =>
    int n = array.size(swingZones)
    if n > 0
        for i = 0 to n - 1
            box oldBox = array.get(swingZones, i)
            color baseColor = array.get(swingZoneBaseColors, i)
            if not na(oldBox)
                box.set_bgcolor(oldBox, color.new(baseColor, 96))
                box.set_border_color(oldBox, color.new(baseColor, oldLevelTransparency))

f_clearLatestVisuals(int idx) =>
    label oldGlow = array.get(latestGlowLabels, idx)
    label oldMain = array.get(latestMainLabels, idx)
    label oldPrice = array.get(latestPriceLabels, idx)
    line oldLine = array.get(latestLines, idx)
    box oldBox = array.get(latestBoxes, idx)

    if not na(oldGlow)
        label.delete(oldGlow)
    if not na(oldMain)
        label.delete(oldMain)
    if not na(oldPrice)
        label.delete(oldPrice)
    if not na(oldLine)
        line.delete(oldLine)
    if not na(oldBox)
        box.delete(oldBox)

    array.set(latestGlowLabels, idx, na)
    array.set(latestMainLabels, idx, na)
    array.set(latestPriceLabels, idx, na)
    array.set(latestLines, idx, na)
    array.set(latestBoxes, idx, na)

f_updateLatestTag(int idx, string modeName, int dir, float price, color modeColor) =>
    label oldTag = array.get(latestLevelTags, idx)
    if not na(oldTag)
        label.delete(oldTag)

    int touches = array.get(latestTouchCounts, idx)
    bool broken = array.get(latestBroken, idx)
    string tagSide = dir == 1 ? "Low" : "High"
    string tagText = modeName + " " + tagSide + "\n" + f_price(price) + "\n" + f_stateText(touches, broken) + " | T: " + str.tostring(touches)
    label newTag = label.new(bar_index + levelExtendBars, price, tagText, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(modeColor, 10), textcolor=dashDataText, style=label.style_label_left, size=size.tiny)
    array.set(latestLevelTags, idx, newTag)

f_refreshLatestTag(int idx) =>
    label tag = array.get(latestLevelTags, idx)
    float price = array.get(latestLevelPrices, idx)
    int dir = array.get(latestLevelDirs, idx)
    int touches = array.get(latestTouchCounts, idx)
    bool broken = array.get(latestBroken, idx)

    if not na(tag) and not na(price)
        string modeName = f_modeName(idx)
        string tagSide = dir == 1 ? "Low" : "High"
        string tagText = modeName + " " + tagSide + "\n" + f_price(price) + "\n" + f_stateText(touches, broken) + " | T: " + str.tostring(touches)
        label.set_x(tag, bar_index + levelExtendBars)
        label.set_y(tag, price)
        label.set_text(tag, tagText)
        label.set_color(tag, f_stateColor(f_modeColor(idx), touches, broken))
        label.set_textcolor(tag, dashDataText)

f_json(string mode, int dir, float price) =>
    "{" +
     "\"ticker\":\"" + syminfo.ticker + "\"," +
     "\"timeframe\":\"" + timeframe.period + "\"," +
     "\"mode\":\"" + mode + "\"," +
     "\"direction\":\"" + f_dirText(dir) + "\"," +
     "\"price\":\"" + f_price(price) + "\"," +
     "\"time\":\"" + str.format("{0,date,yyyy-MM-dd HH:mm}", time) + "\"" +
     "}"

//──────────────────────────────────────────────────────────────────────────────
// CORE SWING ENGINE
//──────────────────────────────────────────────────────────────────────────────
f_processProfile(int idx, bool enabled, string modeName, int depth, float deviationTicks, color modeColor, string labelSize, string lineStyleInput, int lineWidth) =>
    float ph = ta.pivothigh(high, depth, depth)
    float pl = ta.pivotlow(low, depth, depth)

    bool hasHigh = not na(ph)
    bool hasLow = not na(pl)

    int candidateDir = 0
    float candidatePivotPrice = na
    int candidatePivotBar = na

    if hasHigh and hasLow
        float prevPivot = array.get(lastPivotPrices, idx)
        bool useHigh = na(prevPivot) ? close < open : math.abs(ph - prevPivot) >= math.abs(pl - prevPivot)
        candidateDir := useHigh ? -1 : 1
        candidatePivotPrice := useHigh ? ph : pl
        candidatePivotBar := bar_index - depth
    else if hasHigh
        candidateDir := -1
        candidatePivotPrice := ph
        candidatePivotBar := bar_index - depth
    else if hasLow
        candidateDir := 1
        candidatePivotPrice := pl
        candidatePivotBar := bar_index - depth

    int oldDir = array.get(directions, idx)
    float prevPivotPrice = array.get(lastPivotPrices, idx)

    bool deviationOk = na(prevPivotPrice) or math.abs(candidatePivotPrice - prevPivotPrice) >= deviationTicks * syminfo.mintick
    bool alternates = candidateDir != 0 and candidateDir != oldDir
    bool trendOk = not useTrendFilter or (candidateDir == 1 and close > trendEma) or (candidateDir == -1 and close < trendEma)
    bool closeOk = confirmOnlyOnClose ? barstate.isconfirmed : true

    bool signal = enabled and candidateDir != 0 and alternates and deviationOk and trendOk and closeOk
    float signalTradePrice = na

    if signal
        signalTradePrice := entryMode == "Confirmation Close" ? close : candidatePivotPrice

        float oldEntry = array.get(entryPrices, idx)
        int previousDirection = array.get(directions, idx)

        if not na(oldEntry) and previousDirection != 0
            float closedExit = signalTradePrice
            float qtyOld = oldEntry != 0.0 ? accountSize / oldEntry : na
            float closedPoints = previousDirection == 1 ? closedExit - oldEntry : oldEntry - closedExit
            float closedCash = na(qtyOld) ? na : closedPoints * qtyOld
            float closedPct = oldEntry != 0.0 ? closedPoints / oldEntry * 100.0 : na

            array.set(closedEntryPrices, idx, oldEntry)
            array.set(closedExitPrices, idx, closedExit)
            array.set(closedDirections, idx, previousDirection)
            array.set(lastClosedPnlCash, idx, closedCash)
            array.set(lastClosedPnlPct, idx, closedPct)

            if closedCash > 0
                array.set(wins, idx, array.get(wins, idx) + 1)
            else if closedCash < 0
                array.set(losses, idx, array.get(losses, idx) + 1)
            else
                array.set(breakevens, idx, array.get(breakevens, idx) + 1)

        float zoneWidth = zoneAtr * f_zoneMult(idx)
        float upper = candidatePivotPrice + zoneWidth
        float lower = candidatePivotPrice - zoneWidth

        array.set(entryPrices, idx, signalTradePrice)
        array.set(directions, idx, candidateDir)
        array.set(openBars, idx, bar_index)
        array.set(openTimes, idx, time)
        array.set(lastPivotPrices, idx, candidatePivotPrice)

        array.set(latestLevelPrices, idx, candidatePivotPrice)
        array.set(latestZoneUpper, idx, upper)
        array.set(latestZoneLower, idx, lower)
        array.set(latestLevelDirs, idx, candidateDir)
        array.set(latestLevelBars, idx, bar_index)
        array.set(latestTouchCounts, idx, 0)
        array.set(latestLastTouchBars, idx, na)
        array.set(latestBroken, idx, false)

        bool allowedVisual = f_visualAllowed(idx)

        if allowedVisual and effLatestOnly
            f_clearLatestVisuals(idx)

        if autoFadeOldLevels and not effLatestOnly
            f_fadeOldLines()
            f_fadeOldZones()

        float collisionOffset = useLabelCollisionOffset ? zoneAtr * collisionAtrMult * idx : 0.0
        float visualY = candidatePivotPrice + (candidateDir == 1 ? -collisionOffset : collisionOffset)

        if showSignals and allowedVisual
            label glowLabel = na
            label pointLabel = na
            label priceLabel = na

            if showSignalGlow
                string glowSize = idx == 0 ? size.huge : idx == 1 ? size.large : size.normal
                glowLabel := label.new(candidatePivotBar, visualY, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(modeColor, idx == 0 ? 82 : idx == 1 ? 87 : 90), textcolor=color.new(modeColor, 100), style=label.style_circle, size=glowSize)

            pointLabel := label.new(candidatePivotBar, visualY, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(modeColor, 0), textcolor=color.white, style=label.style_label_right, size=labelSize)

            if priceLabelMode != "Hidden"
                priceLabel := label.new(bar_index + 1, visualY, f_priceLabelText(modeName, candidatePivotPrice), xloc=xloc.bar_index, yloc=yloc.price, color=priceLabelBg, textcolor=priceLabelTextColor, style=label.style_label_center, size=size.tiny)

            if effLatestOnly
                array.set(latestGlowLabels, idx, glowLabel)
                array.set(latestMainLabels, idx, pointLabel)
                array.set(latestPriceLabels, idx, priceLabel)
            else
                if not na(glowLabel)
                    f_pushLabel(glowLabel)
                if not na(pointLabel)
                    f_pushLabel(pointLabel)
                if not na(priceLabel)
                    f_pushLabel(priceLabel)

        if showAtrZones and allowedVisual
            box newBox = box.new(left=candidatePivotBar, top=upper, right=bar_index + levelExtendBars, bottom=lower, xloc=xloc.bar_index, bgcolor=f_stateZoneColor(modeColor, 0, false), border_color=color.new(modeColor, 60), border_width=1)
            array.set(latestBoxes, idx, newBox)
            if not effLatestOnly
                f_pushZone(newBox, modeColor)

        if showLevels and allowedVisual
            line newLine = line.new(candidatePivotBar, candidatePivotPrice, bar_index + levelExtendBars, candidatePivotPrice, xloc=xloc.bar_index, extend=extend.none, color=f_stateColor(modeColor, 0, false), width=lineWidth, style=f_lineStyle(lineStyleInput))
            array.set(latestLines, idx, newLine)
            if not effLatestOnly
                f_pushLine(newLine, modeColor)

        if showLatestLevelTags and allowedVisual
            f_updateLatestTag(idx, modeName, candidateDir, candidatePivotPrice, modeColor)

    [signal, signal ? candidateDir : 0, signalTradePrice]

//──────────────────────────────────────────────────────────────────────────────
// RUN ENGINES
//──────────────────────────────────────────────────────────────────────────────
[largeSignal, largeSignalDir, largeSignalPrice] = f_processProfile(0, effShowLarge, "Large Swing", largeDepth, largeDeviationTicks, largeModeColor, size.normal, largeLineStyleInput, largeLineWidth)
[mediumSignal, mediumSignalDir, mediumSignalPrice] = f_processProfile(1, effShowMedium, "Medium Day", mediumDepth, mediumDeviationTicks, mediumModeColor, size.small, mediumLineStyleInput, mediumLineWidth)
[smallSignal, smallSignalDir, smallSignalPrice] = f_processProfile(2, effShowSmall, "Small Scalp", smallDepth, smallDeviationTicks, smallModeColor, size.tiny, smallLineStyleInput, smallLineWidth)

//──────────────────────────────────────────────────────────────────────────────
// LEVEL STATE ENGINE
//──────────────────────────────────────────────────────────────────────────────
f_updateLevelState(int idx, bool enabled) =>
    float price = array.get(latestLevelPrices, idx)
    float upper = array.get(latestZoneUpper, idx)
    float lower = array.get(latestZoneLower, idx)
    int dir = array.get(latestLevelDirs, idx)
    int createdBar = array.get(latestLevelBars, idx)
    int lastTouchBar = array.get(latestLastTouchBars, idx)
    int touches = array.get(latestTouchCounts, idx)
    bool broken = array.get(latestBroken, idx)
    color modeColor = f_modeColor(idx)

    bool valid = enabled and not na(price) and not na(upper) and not na(lower) and dir != 0 and not na(createdBar)
    bool pastCreation = valid and bar_index > createdBar

    bool touched = pastCreation and high >= lower and low <= upper
    bool canCountTouch = touched and not broken and (na(lastTouchBar) or bar_index - lastTouchBar > touchCooldownBars)

    bool breakNow = pastCreation and not broken and (dir == 1 ? close < lower : close > upper)
    bool sweepNow = pastCreation and not broken and (dir == 1 ? low < lower and close > price : high > upper and close < price)

    if canCountTouch and not breakNow
        touches += 1
        array.set(latestTouchCounts, idx, touches)
        array.set(latestLastTouchBars, idx, bar_index)

        if effShowRetestDots and f_visualAllowed(idx)
            label retestDot = label.new(bar_index, price, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(modeColor, 0), textcolor=color.new(modeColor, 100), style=label.style_circle, size=size.tiny)
            f_pushLabel(retestDot)

    if sweepNow and effShowSweepMarkers and f_visualAllowed(idx)
        string sweepText = dir == 1 ? "Sweep Low" : "Sweep High"
        float sweepY = dir == 1 ? low : high
        string sweepStyle = dir == 1 ? label.style_label_up : label.style_label_down
        label sweepLabel = label.new(bar_index, sweepY, sweepText, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.yellow, 0), textcolor=color.black, style=sweepStyle, size=size.tiny)
        f_pushLabel(sweepLabel)

    if breakNow
        broken := true
        array.set(latestBroken, idx, true)

        bool allowBreakMarker = idx <= 1 or showSmallBreakMarkers
        if effShowBreakoutMarkers and allowBreakMarker and f_visualAllowed(idx)
            string breakText = dir == 1 ? "Break Down" : "Break Up"
            string breakStyle = dir == 1 ? label.style_label_down : label.style_label_up
            color breakColor = dir == 1 ? color.new(color.red, 0) : color.new(color.green, 0)
            label breakLabel = label.new(bar_index, price, breakText, xloc=xloc.bar_index, yloc=yloc.price, color=breakColor, textcolor=color.white, style=breakStyle, size=size.tiny)
            f_pushLabel(breakLabel)

    line ln = array.get(latestLines, idx)
    box bx = array.get(latestBoxes, idx)

    if valid
        if not na(ln)
            line.set_x2(ln, bar_index + levelExtendBars)
            line.set_color(ln, f_stateColor(modeColor, touches, broken))

        if not na(bx)
            box.set_right(bx, bar_index + levelExtendBars)
            box.set_bgcolor(bx, f_stateZoneColor(modeColor, touches, broken))
            box.set_border_color(bx, f_stateColor(modeColor, touches, broken))

        f_refreshLatestTag(idx)

f_updateLevelState(0, effShowLarge)
f_updateLevelState(1, effShowMedium)
f_updateLevelState(2, effShowSmall)

//──────────────────────────────────────────────────────────────────────────────
// SESSION / OPEN MARKERS
//──────────────────────────────────────────────────────────────────────────────
inUserSession = not na(time(timeframe.period, userSession))
userSessionStart = inUserSession and not inUserSession[1]
dailyOpen = ta.change(time("D")) != 0
weeklyOpen = ta.change(time("W")) != 0

drawDaily = showSessionMarkers and (sessionMarkerMode == "Daily Open" or sessionMarkerMode == "All") and dailyOpen
drawWeekly = showSessionMarkers and (sessionMarkerMode == "Weekly Open" or sessionMarkerMode == "All") and weeklyOpen
drawUserSession = showSessionMarkers and (sessionMarkerMode == "User Session" or sessionMarkerMode == "All") and userSessionStart

if drawDaily or drawWeekly or drawUserSession
    float y1 = low - markerAtr * 5.0
    float y2 = high + markerAtr * 5.0
    line vLine = line.new(bar_index, y1, bar_index, y2, xloc=xloc.bar_index, extend=extend.none, color=sessionMarkerColor, style=drawWeekly ? line.style_solid : line.style_dotted, width=drawWeekly ? 2 : 1)
    array.push(sessionLines, vLine)
    if array.size(sessionLines) > maxSessionMarkers
        line oldSessionLine = array.shift(sessionLines)
        if not na(oldSessionLine)
            line.delete(oldSessionLine)

//──────────────────────────────────────────────────────────────────────────────
// BIAS BACKGROUND
//──────────────────────────────────────────────────────────────────────────────
largeDirNow = array.get(directions, 0)
mediumDirNow = array.get(directions, 1)
smallDirNow = array.get(directions, 2)

biasLong = effShowLarge and effShowMedium and largeDirNow == 1 and mediumDirNow == 1
biasShort = effShowLarge and effShowMedium and largeDirNow == -1 and mediumDirNow == -1

bgcolor(showBiasBackground and biasLong ? color.new(color.green, 93) : showBiasBackground and biasShort ? color.new(color.red, 93) : na)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(largeSignal and largeSignalDir == 1, "Large Long Signal", "Large Swing Long signal confirmed.")
alertcondition(largeSignal and largeSignalDir == -1, "Large Short Signal", "Large Swing Short signal confirmed.")
alertcondition(mediumSignal and mediumSignalDir == 1, "Medium Long Signal", "Medium Day Long signal confirmed.")
alertcondition(mediumSignal and mediumSignalDir == -1, "Medium Short Signal", "Medium Day Short signal confirmed.")
alertcondition(smallSignal and smallSignalDir == 1, "Small Long Signal", "Small Scalping Long signal confirmed.")
alertcondition(smallSignal and smallSignalDir == -1, "Small Short Signal", "Small Scalping Short signal confirmed.")

if useJsonAlerts and largeSignal
    alert(f_json("Large Swing", largeSignalDir, largeSignalPrice), alert.freq_once_per_bar_close)

if useJsonAlerts and mediumSignal
    alert(f_json("Medium Day", mediumSignalDir, mediumSignalPrice), alert.freq_once_per_bar_close)

if useJsonAlerts and smallSignal
    alert(f_json("Small Scalp", smallSignalDir, smallSignalPrice), alert.freq_once_per_bar_close)

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(f_position(dashboardPosition), 12, 4, border_width=dashBorderWidth, frame_color=dashFrameColor)

f_dashboardRow(int row, int idx, string modeName, bool enabled, color modeColor) =>
    int dir = array.get(directions, idx)

    float activeEntry = array.get(entryPrices, idx)
    float prevEntry = array.get(closedEntryPrices, idx)
    float prevExit = array.get(closedExitPrices, idx)

    int openedBar = array.get(openBars, idx)
    int openedTime = array.get(openTimes, idx)

    float qty = not na(activeEntry) and activeEntry != 0.0 ? accountSize / activeEntry : na
    float markPrice = close

    float openPoints = not na(activeEntry) and dir != 0 ? dir == 1 ? markPrice - activeEntry : activeEntry - markPrice : na
    float openCash = not na(openPoints) and not na(qty) ? openPoints * qty : na
    float openPct = not na(openPoints) and activeEntry != 0.0 ? openPoints / activeEntry * 100.0 : na

    float lastCash = array.get(lastClosedPnlCash, idx)
    float lastPct = array.get(lastClosedPnlPct, idx)

    int w = array.get(wins, idx)
    int l = array.get(losses, idx)
    int b = array.get(breakevens, idx)

    string status = enabled ? f_dirText(dir) : "Off"
    string ageText = na(openedBar) ? "na" : str.tostring(bar_index - openedBar) + " bars"
    string lastPnlText = na(lastCash) ? "na" : f_cash(lastCash) + " / " + f_pct(lastPct)

    color rowBg = enabled ? color.new(modeColor, 88) : color.new(color.gray, 88)
    color dirBg = dir == 1 ? color.new(color.lime, 82) : dir == -1 ? color.new(color.red, 82) : rowBg

    if effDashboardDetail == "Compact"
        table.cell(dash, 0, row, modeName, text_color=dashDataText, bgcolor=rowBg)
        table.cell(dash, 1, row, status, text_color=dashDataText, bgcolor=dirBg)
        table.cell(dash, 2, row, f_price(activeEntry), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 3, row, f_price(markPrice), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 4, row, f_pct(openPct), text_color=dashDataText, bgcolor=f_pnlBg(openCash))
        table.cell(dash, 5, row, f_price(prevEntry), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 6, row, f_price(prevExit), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 7, row, lastPnlText, text_color=dashDataText, bgcolor=f_pnlBg(lastCash))
        table.cell(dash, 8, row, f_wlb(w, l, b), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 9, row, f_winRate(w, l), text_color=dashDataText, bgcolor=dashDataBg)
        for c = 10 to 11
            table.cell(dash, c, row, "", bgcolor=color.new(color.black, 100))
    else
        table.cell(dash, 0, row, modeName, text_color=dashDataText, bgcolor=rowBg)
        table.cell(dash, 1, row, status, text_color=dashDataText, bgcolor=dirBg)
        table.cell(dash, 2, row, f_price(activeEntry), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 3, row, f_price(markPrice), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 4, row, f_num(qty), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 5, row, f_cash(openCash), text_color=dashDataText, bgcolor=f_pnlBg(openCash))
        table.cell(dash, 6, row, f_pct(openPct), text_color=dashDataText, bgcolor=f_pnlBg(openCash))
        table.cell(dash, 7, row, f_price(prevEntry), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 8, row, f_price(prevExit), text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 9, row, lastPnlText, text_color=dashDataText, bgcolor=f_pnlBg(lastCash))
        table.cell(dash, 10, row, ageText, text_color=dashDataText, bgcolor=dashDataBg)
        table.cell(dash, 11, row, f_timeText(openedTime), text_color=dashDataText, bgcolor=dashDataBg)

if barstate.islast
    if effShowDashboard
        if effDashboardDetail == "Compact"
            table.cell(dash, 0, 0, "Mode", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 1, 0, "Dir", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 2, 0, "Active Entry", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 3, 0, "Mark", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 4, 0, "Open %", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 5, 0, "Prev In", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 6, 0, "Prev Out", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 7, 0, "Last PnL", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 8, 0, "W/L/BE", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 9, 0, "Win %", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            for c = 10 to 11
                table.cell(dash, c, 0, "", bgcolor=color.new(color.black, 100))
        else
            table.cell(dash, 0, 0, "Mode", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 1, 0, "Direction", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 2, 0, "Active Entry", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 3, 0, "Mark", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 4, 0, "Size", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 5, 0, "Open PnL", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 6, 0, "Open %", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 7, 0, "Prev In", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 8, 0, "Prev Out", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 9, 0, "Last PnL", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 10, 0, "Age", text_color=dashHeaderText, bgcolor=dashHeaderBg)
            table.cell(dash, 11, 0, "Opened", text_color=dashHeaderText, bgcolor=dashHeaderBg)

        f_dashboardRow(1, 0, "Large Swing", effShowLarge, largeModeColor)
        f_dashboardRow(2, 1, "Medium Day", effShowMedium, mediumModeColor)
        f_dashboardRow(3, 2, "Small Scalp", effShowSmall, smallModeColor)
    else
        for r = 0 to 3
            for c = 0 to 11
                table.cell(dash, c, r, "")

//──────────────────────────────────────────────────────────────────────────────
// ALIGNMENT RIBBON
//──────────────────────────────────────────────────────────────────────────────
var table ribbon = table.new(position.bottom_center, 5, 1, border_width=1, frame_color=color.new(color.gray, 65))

if barstate.islast
    int longCount = (largeDirNow == 1 ? 1 : 0) + (mediumDirNow == 1 ? 1 : 0) + (smallDirNow == 1 ? 1 : 0)
    int shortCount = (largeDirNow == -1 ? 1 : 0) + (mediumDirNow == -1 ? 1 : 0) + (smallDirNow == -1 ? 1 : 0)

    color ribbonBg = longCount == 3 ? color.new(color.green, 10) :
         shortCount == 3 ? color.new(color.red, 10) :
         longCount == 2 ? color.new(color.green, 60) :
         shortCount == 2 ? color.new(color.red, 60) :
         color.new(color.gray, 70)

    string alignText = longCount == 3 ? "Strong Long" :
         shortCount == 3 ? "Strong Short" :
         longCount == 2 ? "Long Lean" :
         shortCount == 2 ? "Short Lean" :
         "Mixed"

    if effShowRibbon
        table.cell(ribbon, 0, 0, "Alignment", text_color=color.white, bgcolor=ribbonBg)
        table.cell(ribbon, 1, 0, "Large: " + f_dirText(largeDirNow), text_color=color.white, bgcolor=color.new(largeModeColor, 35))
        table.cell(ribbon, 2, 0, "Medium: " + f_dirText(mediumDirNow), text_color=color.white, bgcolor=color.new(mediumModeColor, 35))
        table.cell(ribbon, 3, 0, "Small: " + f_dirText(smallDirNow), text_color=color.white, bgcolor=color.new(smallModeColor, 35))
        table.cell(ribbon, 4, 0, alignText, text_color=color.white, bgcolor=ribbonBg)
    else
        for c = 0 to 4
            table.cell(ribbon, c, 0, "")

//──────────────────────────────────────────────────────────────────────────────
// ACTIVE DIRECTION PANEL
//──────────────────────────────────────────────────────────────────────────────
if barstate.islast
    string panelText = "Active Direction\n" +
         "Large: " + f_dirText(largeDirNow) + "\n" +
         "Medium: " + f_dirText(mediumDirNow) + "\n" +
         "Small: " + f_dirText(smallDirNow)

    bool allLong = effShowLarge and effShowMedium and effShowSmall and largeDirNow == 1 and mediumDirNow == 1 and smallDirNow == 1
    bool allShort = effShowLarge and effShowMedium and effShowSmall and largeDirNow == -1 and mediumDirNow == -1 and smallDirNow == -1
    color panelBg = allLong ? color.new(color.green, 15) : allShort ? color.new(color.red, 15) : color.new(color.gray, 25)

    if showActivePanel
        if na(activePanelLabel)
            activePanelLabel := label.new(bar_index + panelOffsetBars, close, panelText, xloc=xloc.bar_index, yloc=yloc.price, color=panelBg, textcolor=dashDataText, style=label.style_label_left, size=size.small)
        else
            label.set_x(activePanelLabel, bar_index + panelOffsetBars)
            label.set_y(activePanelLabel, close)
            label.set_text(activePanelLabel, panelText)
            label.set_color(activePanelLabel, panelBg)
            label.set_textcolor(activePanelLabel, dashDataText)
    else
        if not na(activePanelLabel)
            label.delete(activePanelLabel)
            activePanelLabel := na

//──────────────────────────────────────────────────────────────────────────────
// 3-MODE CONFLUENCE MARKER
//──────────────────────────────────────────────────────────────────────────────
if barstate.islast
    bool confluenceLong = effShowLarge and effShowMedium and effShowSmall and largeDirNow == 1 and mediumDirNow == 1 and smallDirNow == 1
    bool confluenceShort = effShowLarge and effShowMedium and effShowSmall and largeDirNow == -1 and mediumDirNow == -1 and smallDirNow == -1
    bool hasConfluence = confluenceLong or confluenceShort

    float confluenceY = confluenceLong ? low - markerAtr : high + markerAtr
    string confluenceText = confluenceLong ? "3x LONG" : confluenceShort ? "3x SHORT" : ""
    color confluenceColor = confluenceLong ? color.new(color.green, 0) : color.new(color.red, 0)
    string confluenceStyle = confluenceLong ? label.style_label_up : label.style_label_down

    if showConfluenceMarker and hasConfluence and screenshotMode != "Ultra Clean"
        if na(confluenceLabel)
            confluenceLabel := label.new(bar_index, confluenceY, confluenceText, xloc=xloc.bar_index, yloc=yloc.price, color=confluenceColor, textcolor=color.white, style=confluenceStyle, size=size.normal)
        else
            label.set_x(confluenceLabel, bar_index)
            label.set_y(confluenceLabel, confluenceY)
            label.set_text(confluenceLabel, confluenceText)
            label.set_color(confluenceLabel, confluenceColor)
            label.set_textcolor(confluenceLabel, color.white)
    else
        if not na(confluenceLabel)
            label.delete(confluenceLabel)
            confluenceLabel := na
````
