# volume profil multitimeframe

- url: https://www.tradingview.com/script/pTF1Asiv-volume-profil-multitimeframe/
- type: indicator
- pine_id: PUB;f151d5b16e6c44c692e3cf8652bce89e
- version: 1.0

## Description

**Volume Profile D/W/M — Auction Map**

Volume Profile D/W/M is a visual auction-analysis indicator designed to display confirmed Daily, Weekly, or Monthly volume profiles on the chart. It focuses on value areas, volume concentration, auction structure, and important reaction zones. The script is intended for discretionary market analysis and does not generate automatic buy or sell signals.

---

## Overview

This indicator builds a volume profile from a selected confirmed period:

* Daily
* Weekly
* Monthly

Only one mode is active at a time. The goal is to keep the chart readable while still showing the most important auction levels.

The profile highlights where volume was concentrated during the selected period and displays key levels such as POC, VAH, VAL, HVN, LVN, VWAP, Initial Balance, naked POC levels, imbalance zones, confluence zones, and auction-state information.

---

## Main Features

### Confirmed Volume Profile

The script draws confirmed profiles from closed periods. This makes historical profiles stable and prevents them from constantly changing after the period has closed.

Available profile modes:

* Daily profile
* Weekly profile
* Monthly profile

The current developing profile can also be displayed with the dedicated option, but it should be understood as a live preview and not as a confirmed profile.

---

### POC, VAH and VAL

The script displays the main volume profile levels:

* POC: the price row with the highest volume
* VAH: upper boundary of the value area
* VAL: lower boundary of the value area

These levels are used to read market acceptance, rejection, rotation, and possible return-to-value behavior.

---

### HVN and LVN

The script can highlight:

* HVN: high-volume nodes, where the market accepted price
* LVN: low-volume nodes, where price often moved quickly or found less acceptance

HVN levels may act as areas of balance or reaction. LVN levels may act as rejection zones or acceleration zones depending on context.

---

### Bull / Bear Split and Delta Imbalance Rows

Each profile row can be split into bullish and bearish volume estimates. This helps visualize whether a price area was dominated by bullish or bearish pressure.

The indicator also includes imbalance rows, which highlight areas where one side strongly dominated the row volume.

To avoid label clutter, imbalance labels can be displayed as:

* a single multiplier label
* one label per row
* no label

The multiplier mode is recommended for normal use.

---

### Confluence Zones

The confluence module looks for clusters where several important levels are close to each other.

Examples of levels used in confluence:

* POC
* VAH / VAL
* HVN / LVN
* Period open / close
* Naked POC
* Profile high / low
* Poor high / poor low
* Composite levels

A confluence zone does not predict direction by itself. It simply marks an area where several auction references are grouped together.

---

### Naked POC Tracking

The script can track previous POC levels that have not yet been revisited. These levels are often watched as potential return-to-value or magnet zones.

Naked POC levels include status logic such as:

* Fresh
* Tested
* Respected
* Broken
* Dead

The extension distance can be adjusted so naked POC levels do not appear too far away from the rest of the profile.

---

### VWAP and Initial Balance

The indicator includes optional period VWAP and VWAP bands.

It can also display Initial Balance levels:

* IB High
* IB Low
* IB Mid
* 1x / 2x IB extensions

These tools are useful for reading whether price is rotating inside value, expanding away from balance, or failing an attempted breakout.

---

### Auction Dashboard

The dashboard summarizes useful auction information such as:

* selected mode
* current price location
* auction state
* value relation
* POC migration
* profile shape
* nearest target
* risk zone
* dominant session
* confluence score
* POC, VAH, VAL, VWAP and IB information

The dashboard is only a reading aid. It should not be used as a standalone trading system.

---

## Beginner Tutorial

### Step 1 — Choose the Profile Mode

Start with Daily mode.

Daily mode is usually the easiest to understand because each profile represents one completed trading day.

Once you are comfortable, you can test Weekly and Monthly modes to read the larger market structure.

---

### Step 2 — Read the Main Levels

Start with three levels:

* POC
* VAH
* VAL

A simple way to read them:

* Price above VAH: market is trading above accepted value
* Price below VAL: market is trading below accepted value
* Price around POC: market is rotating near the main accepted price
* Price between VAH and VAL: market is inside value

---

### Step 3 — Look for Reaction Areas

After the basic value area is understood, check:

* HVN zones
* LVN zones
* naked POC levels
* confluence zones
* VWAP
* Initial Balance

Do not use every line as a trade signal. The goal is to identify areas where price may react, pause, reject, or accelerate.

---

### Step 4 — Use the Dashboard

The dashboard helps summarize the profile state.

For example:

* If price is above VAH and POC migration is rising, the market may be accepting higher prices.
* If price rejects above VAH and returns inside value, it may indicate a failed auction.
* If price is near a confluence zone, the area may deserve more attention.

---

## Example Use Cases

### Example 1 — Return to Value

Price trades above VAH, fails to hold, and returns inside the value area.
A trader may watch for a rotation back toward POC.

This is not a direct entry signal. Confirmation should come from price action, market structure, or another method.

---

### Example 2 — POC Magnet

Price moves away from the previous POC but later returns toward it.
A naked POC or composite POC may act as a reference level where traders expect a reaction or pause.

---

### Example 3 — LVN Acceleration

Price approaches an LVN zone.
Because LVN zones represent low acceptance, price may either reject quickly or move through the area with speed.

The direction depends on context, not on the LVN alone.

---

### Example 4 — Weekly Context, Daily Execution

A trader can use Weekly mode to identify larger auction levels, then switch back to a lower chart timeframe to observe how price reacts near those levels.

This helps separate macro context from execution timing.

---

## Recommended Timeframes

The script is not designed for very low timeframes with heavy settings.

Recommended chart timeframes:

* 5 minutes and above for Daily mode
* 15 minutes and above for Weekly mode
* 15 minutes, 30 minutes, or 1 hour for Monthly mode

Using the script on a 1-minute chart is not recommended, especially with Weekly or Monthly mode, developing profile enabled, high profile rows, many historical profiles, or multiple visual modules active.

Very low timeframes may require too many historical bars or too many drawing objects, which can cause TradingView limits to be reached.

---

## Performance Recommendations

For stable use, start with these settings:

* Profiles History: 3
* Profile Rows: 48
* Current Developing Profile: Off
* Imbalance Labels: Multiplier
* Composite Display: Near Profile
* Naked POC extension: short distance

If the chart becomes heavy, reduce:

* profile rows
* history count
* developing profile
* imbalance zones
* VWAP bands
* Initial Balance extensions
* confluence labels

---

## Important Notes

This indicator is an analytical tool, not a trading system.

It does not predict the market and does not provide guaranteed results. All levels should be interpreted with market context, price action, risk management, and the trader’s own strategy.

Volume profile analysis is most useful when combined with structure, trend, volatility, session behavior, and confirmation from price action.

Use the script to build a map of important auction areas, not as a standalone reason to enter or exit a trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("volume profil mtf", "vpm", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

gEngine = "engine"
vpMode           = input.string("Daily", "VP Mode", options = ["Daily", "Weekly", "Monthly"], group = gEngine, tooltip = "Selects the confirmed profile period used for the volume profile.")
string vpTf      = vpMode == "Daily" ? "D" : vpMode == "Weekly" ? "W" : "M"
string vpTag     = vpMode == "Daily" ? "1D" : vpMode == "Weekly" ? "1W" : "1M"
int chartTfSec = timeframe.in_seconds(timeframe.period)
int vpTfSec = timeframe.in_seconds(vpTf)
bool validChartTf = chartTfSec <= vpTfSec
profilesHistory  = input.int(3, "Confirmed Profiles History", minval = 1, maxval = 8, group = gEngine, tooltip = "Sets how many closed profiles remain visible on the chart.")
showDeveloping   = input.bool(true, "Show Current Developing Profile", group = gEngine, tooltip = "Shows a preview of the current unfinished profile on the last bar.")
maxProfileBars   = input.int(3000, "Max Bars Per Profile", minval = 20, maxval = 4500, group = gEngine, tooltip = "Limits the number of chart bars used to build one profile.")
profilePlacement = input.string("Right", "Profile Placement", options = ["Right", "Left"], group = gEngine, tooltip = "Chooses whether the profile is drawn on the left or right side of its period.")
profileWidthPct  = input.float(35.0, "Profile Width %", minval = 5, maxval = 100, step = 1, group = gEngine, tooltip = "Sets the maximum horizontal width of the profile rows.")
minWidthBars     = input.int(12, "Minimum Profile Width Bars", minval = 3, maxval = 200, group = gEngine, tooltip = "Sets the minimum profile width in chart bars.")
levelExtendMode  = input.string("Fixed Bars", "Level Extension Mode", options = ["Fixed Bars", "Extend Right"], group = gEngine, tooltip = "Fixed Bars uses the per-level extension values below. Extend Right makes horizontal levels continue to the right.")
showDebug         = input.bool(true, "Dashboard", group = gEngine, tooltip = "Shows or hides the auction dashboard.")

gExt = "extensions"
pocExtendBars        = input.int(0, "POC Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for POC lines and labels.")
vaExtendBars         = input.int(0, "VAH / VAL Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for VAH and VAL lines and labels.")
hvnExtendBars        = input.int(0, "HVN Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for HVN lines and labels.")
lvnExtendBars        = input.int(0, "LVN Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for LVN lines and labels.")
openCloseExtendBars  = input.int(0, "Open / Close Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for period open and close lines and labels.")
rangeEqExtendBars    = input.int(0, "Profile H/L + EQ Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for profile high, low, and equilibrium lines and labels.")
voidExtendBars       = input.int(0, "VOID / LVG Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for volume void boxes and labels.")
poorExtendBars       = input.int(0, "Poor H/L Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for Poor High and Poor Low lines and labels.")
imbalanceExtendBars  = input.int(0, "Imbalance Row Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for bull/bear imbalance zones and labels.")
deltaPocExtendBars   = input.int(0, "Delta POC Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for Delta POC lines and labels.")
vwapExtendBars       = input.int(0, "VWAP Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for VWAP and VWAP band lines and labels.")
ibExtendBars         = input.int(0, "Initial Balance Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for IB lines and labels.")
confluenceExtendBars = input.int(0, "Confluence Extend Bars", minval = 0, maxval = 499, group = gExt, tooltip = "Controls the fixed right extension for confluence lines and labels.")

gRes = "resolution"
nRows    = input.int(48, "Profile Rows", minval = 12, maxval = 120, group = gRes, tooltip = "Sets the number of price rows used to build each profile.")
valuePct = input.float(70.0, "Value Area %", minval = 50, maxval = 90, step = 1, group = gRes, tooltip = "Sets the percentage of volume used to calculate the value area.")
rowGapY  = input.float(0.10, "Row Gap Y", minval = 0.0, maxval = 0.45, step = 0.01, group = gRes, tooltip = "Adds vertical spacing between profile rows.")

gDelta = "delta"
showSplit = input.bool(true, "Show Bull/Bear Split", group = gDelta, tooltip = "Splits each row into bullish and bearish volume sections.")
deltaMode = input.string("Bar Direction", "Delta Calculation", options = ["Bar Direction", "Range Position"], group = gDelta, tooltip = "Chooses how bullish and bearish volume are estimated.")

gLevels = "poc and value area"
showPoc    = input.bool(true, "Show POC", group = gLevels, tooltip = "Shows or hides the point of control line.")
showVa     = input.bool(true, "Show Value Area", group = gLevels, tooltip = "Shows or hides VAH and VAL levels.")
showVaFill = input.bool(true, "Value Area Fill", group = gLevels, tooltip = "Fills the area between VAH and VAL.")
pocStyle   = input.string("Solid", "POC Line Style", options = ["Solid", "Dashed", "Dotted"], group = gLevels, tooltip = "Sets the visual style of the POC line.")
pocWidth   = input.int(2, "POC Line Width", minval = 1, maxval = 5, group = gLevels, tooltip = "Sets the thickness of the POC line.")
showRangeBg = input.bool(true, "Profile Range Background", group = gLevels, tooltip = "Shows the full high-to-low range background for each profile.")

gZones = "levels"
showPeriodOpen   = input.bool(true, "Show Period Open", group = gZones, tooltip = "Shows the open price of the selected profile period.")
showPeriodClose  = input.bool(true, "Show Period Close", group = gZones, tooltip = "Shows the close price of the selected profile period.")
showProfileHL    = input.bool(true, "Show Profile High / Low", group = gZones, tooltip = "Shows the high and low of the selected profile period.")
showProfileEQ    = input.bool(true, "Show Profile EQ / Mid", group = gZones, tooltip = "Shows the midpoint of the selected profile range.")
openLineColor    = input.color(color.new(#90A4AE, 0), "Open Line Color", group = gZones, tooltip = "Controls the setting setting.")
closeLineColor   = input.color(color.new(#FFFFFF, 0), "Close Line Color", group = gZones, tooltip = "Controls the setting setting.")
rangeLineColor   = input.color(color.new(#B0BEC5, 35), "High / Low Color", group = gZones, tooltip = "Controls the setting setting.")
eqLineColor      = input.color(color.new(#78909C, 25), "EQ Color", group = gZones, tooltip = "Controls the setting setting.")
openCloseWidth   = input.int(1, "Open / Close Width", minval = 1, maxval = 4, group = gZones, tooltip = "Sets the thickness of the open and close lines.")
rangeLineWidth   = input.int(1, "Range / EQ Width", minval = 1, maxval = 4, group = gZones, tooltip = "Sets the thickness of range and midpoint lines.")

gVoids = "voids"
showVolumeVoids  = input.bool(true, "Show Volume Voids / LVG", group = gVoids, tooltip = "Highlights low-volume gaps inside the profile.")
voidThresholdPct = input.float(12.0, "Void Threshold % of POC Volume", minval = 1.0, maxval = 40.0, step = 1.0, group = gVoids, tooltip = "Defines how low a row volume must be to qualify as a void.")
minVoidRows      = input.int(3, "Minimum Consecutive Void Rows", minval = 2, maxval = 12, group = gVoids, tooltip = "Sets how many adjacent low-volume rows are required for a void zone.")
maxVoidZones     = input.int(4, "Max Void Zones Per Profile", minval = 1, maxval = 10, group = gVoids, tooltip = "Limits the number of void zones drawn per profile.")
voidZoneColor    = input.color(color.new(#7B2CBF, 86), "Void Zone Color", group = gVoids, tooltip = "Controls the setting setting.")
showPoorHL       = input.bool(true, "Show Poor High / Poor Low", group = gVoids, tooltip = "Marks unfinished highs or lows with notable edge volume.")
poorEdgeRows     = input.int(3, "Poor Edge Rows", minval = 1, maxval = 8, group = gVoids, tooltip = "Sets how many edge rows are checked for poor highs and lows.")
poorEdgeRatioPct = input.float(36.0, "Poor Edge Threshold %", minval = 10.0, maxval = 90.0, step = 1.0, group = gVoids, tooltip = "Sets the edge-volume threshold used to detect poor highs and lows.")
poorLineColor    = input.color(color.new(#FF6F00, 0), "Poor High / Low Color", group = gVoids, tooltip = "Controls the setting setting.")

gComp = "composite"
showPocMigration = input.bool(true, "Show Confirmed POC Migration", group = gComp, tooltip = "Shows how the confirmed POC moves from one profile to the next.")
showComposite    = input.bool(true, "Show Composite POC / VAH / VAL", group = gComp, tooltip = "Shows composite profile levels based on recent confirmed profiles.")
compositeDisplay = input.string("Near Profile", "Composite Display", options = ["Near Profile", "Off"], group = gComp, tooltip = "Chooses whether composite levels are drawn near the last confirmed profile or hidden.")
compositePeriods = input.int(5, "Composite Periods", minval = 2, maxval = 20, group = gComp, tooltip = "Sets how many confirmed profiles are used in the composite calculation.")
compositeNearBars = input.int(35, "Composite Near Profile Bars", minval = 5, maxval = 150, group = gComp, tooltip = "Sets the length of composite levels when displayed near the profile.")
showCompositeLabels = input.bool(true, "Show Composite Labels", group = gComp, tooltip = "Shows labels for composite POC, VAH and VAL.")
compositeLineAlpha = input.int(55, "Composite Line Transparency", minval = 0, maxval = 95, group = gComp, tooltip = "Sets the transparency of composite lines.")
compositeColor   = input.color(color.new(#00E5FF, 0), "Composite POC Color", group = gComp, tooltip = "Controls the setting setting.")
compositeVaColor = input.color(color.new(#80DEEA, 25), "Composite VAH / VAL Color", group = gComp, tooltip = "Controls the setting setting.")

gConf = "confluence"
showConfluence      = input.bool(true, "Show Confluence Zones", group = gConf, tooltip = "Shows zones where multiple auction levels cluster together.")
confluenceMinScore  = input.int(55, "Minimum Score", minval = 10, maxval = 100, group = gConf, tooltip = "Sets the minimum score required to display a confluence label.")
confluenceMinLevels = input.int(2, "Minimum Levels In Cluster", minval = 2, maxval = 8, group = gConf, tooltip = "Sets the minimum number of levels required inside one cluster.")
confluenceMaxZones  = input.int(3, "Max Confluence Labels", minval = 1, maxval = 6, group = gConf, tooltip = "Limits the number of confluence labels drawn.")
confluenceAtrLen    = input.int(14, "ATR Length", minval = 1, maxval = 200, group = gConf, tooltip = "Sets the ATR length used for confluence distance.")
confluenceAtrMult   = input.float(0.18, "Cluster Distance × ATR", minval = 0.01, maxval = 2.0, step = 0.01, group = gConf, tooltip = "Sets the maximum distance between levels in a confluence cluster.")
confluenceColor     = input.color(color.new(#FFD54F, 0), "Confluence Color", group = gConf, tooltip = "Controls the setting setting.")

float atrConfluence = ta.atr(confluenceAtrLen)

gDash = "dashboard"
showAuctionDashboard = input.bool(true, "Show Auction State Dashboard", group = gDash, tooltip = "Shows the dashboard with auction state and level information.")

gNakedAdv = "naked poc"
showNakedAdvanced   = input.bool(true, "Show Advanced Naked POCs", group = gNakedAdv, tooltip = "Tracks POCs from closed profiles that have not been revisited.")
maxNakedAdvanced    = input.int(8, "Max Naked POCs", minval = 1, maxval = 60, group = gNakedAdv, tooltip = "Limits the number of naked POCs kept in memory.")
nakedExtendBars     = input.int(8, "Naked POC Extra Bars", minval = 0, maxval = 499, group = gNakedAdv, tooltip = "Sets how many bars naked POC lines extend beyond the current bar. Default keeps nPOCs only slightly past the other levels.")
nakedDeleteMode     = input.string("On Cross", "Delete Naked POC", options = ["None", "On Touch", "On Cross"], group = gNakedAdv, tooltip = "Chooses when a naked POC is removed from tracking.")
hideBrokenNaked     = input.bool(true, "Hide Broken Naked POCs", group = gNakedAdv, tooltip = "Hides naked POCs after they are broken.")
hideDeadNaked       = input.bool(true, "Hide Dead Naked POCs", group = gNakedAdv, tooltip = "Hides naked POCs after they become too old.")
nakedDeadAgeBars    = input.int(600, "Dead Status After Bars", minval = 50, maxval = 5000, group = gNakedAdv, tooltip = "Sets the age after which a naked POC is marked as dead.")
nakedColorFresh     = input.color(color.new(#FFFFFF, 0), "Fresh Color", group = gNakedAdv, tooltip = "Controls the setting setting.")
nakedColorTested    = input.color(color.new(#FFD54F, 0), "Tested Color", group = gNakedAdv, tooltip = "Controls the setting setting.")
nakedColorBroken    = input.color(color.new(#78909C, 0), "Broken / Dead Color", group = gNakedAdv, tooltip = "Controls the setting setting.")

gImb = "delta imbalance"
showDeltaImbalance = input.bool(true, "Show Bull/Bear Imbalance Rows", group = gImb, tooltip = "Highlights rows dominated by bullish or bearish volume.")
deltaImbalancePct  = input.float(75.0, "Imbalance Threshold %", minval = 55.0, maxval = 95.0, step = 1.0, group = gImb, tooltip = "Sets the dominance percentage required for a row imbalance.")
maxImbalanceRows   = input.int(8, "Max Imbalance Rows Per Profile", minval = 1, maxval = 30, group = gImb, tooltip = "Limits how many imbalance rows are drawn per profile.")
imbalanceLabelMode = input.string("Multiplier", "Imbalance Labels", options = ["Multiplier", "Each Row", "Off"], group = gImb, tooltip = "Multiplier = one compact label with counts, Each Row = one label per imbalance row, Off = zones only.")
showDeltaPoc       = input.bool(true, "Show Delta POC", group = gImb, tooltip = "Shows the row with the strongest bullish or bearish delta.")
bullImbColor       = input.color(color.new(#00E676, 84), "Bull Imbalance Zone", group = gImb, tooltip = "Controls the setting setting.")
bearImbColor       = input.color(color.new(#FF1744, 84), "Bear Imbalance Zone", group = gImb, tooltip = "Controls the setting setting.")
deltaPocColor      = input.color(color.new(#FFFFFF, 0), "Delta POC Color", group = gImb, tooltip = "Controls the setting setting.")

gVwap = "vwap"
showPeriodVwap = input.bool(true, "Show Period VWAP", group = gVwap, tooltip = "Shows the VWAP calculated inside the selected profile period.")
showVwapBands  = input.bool(true, "Show VWAP Bands", group = gVwap, tooltip = "Shows standard deviation bands around period VWAP.")
vwapBandMult1  = input.float(1.0, "Band 1 Mult", minval = 0.1, maxval = 5.0, step = 0.1, group = gVwap, tooltip = "Sets the first VWAP band multiplier.")
vwapBandMult2  = input.float(2.0, "Band 2 Mult", minval = 0.1, maxval = 5.0, step = 0.1, group = gVwap, tooltip = "Sets the second VWAP band multiplier.")
vwapColor      = input.color(color.new(#26C6DA, 0), "VWAP Color", group = gVwap, tooltip = "Controls the setting setting.")
vwapBandColor  = input.color(color.new(#90A4AE, 35), "Band Color", group = gVwap, tooltip = "Controls the setting setting.")

gIB = "initial balance"
showInitialBalance = input.bool(true, "Show Initial Balance", group = gIB, tooltip = "Shows the initial balance range for the selected period.")
ibDailyMinutes     = input.int(60, "Daily IB Minutes", minval = 5, maxval = 480, group = gIB, tooltip = "Sets the number of minutes used for the daily initial balance.")
ibWeeklyDays       = input.int(1, "Weekly IB Days", minval = 1, maxval = 3, group = gIB, tooltip = "Sets the number of days used for the weekly initial balance.")
ibMonthlyDays      = input.int(5, "Monthly IB Days", minval = 1, maxval = 10, group = gIB, tooltip = "Sets the number of days used for the monthly initial balance.")
showIbExtensions   = input.bool(true, "Show IB 1x / 2x Extensions", group = gIB, tooltip = "Shows one-times and two-times initial balance extensions.")
ibColor            = input.color(color.new(#AB47BC, 0), "IB Color", group = gIB, tooltip = "Controls the setting setting.")

gSess = "sessions"
showSessionContribution = input.bool(true, "Track Session Contribution", group = gSess, tooltip = "Tracks which session contributed the most volume.")
sessionTzAdv            = input.string("America/New_York", "Session Timezone", group = gSess, tooltip = "Sets the timezone used for session calculations.")
asiaSessionAdv          = input.session("1800-0300", "Asia Session", group = gSess, tooltip = "Defines the Asia session time window.")
londonSessionAdv        = input.session("0300-0800", "London Session", group = gSess, tooltip = "Defines the London session time window.")
nySessionAdv            = input.session("0800-1700", "New York Session", group = gSess, tooltip = "Defines the New York session time window.")
int asiaTimeAdv = time(timeframe.period, asiaSessionAdv, sessionTzAdv)
int londonTimeAdv = time(timeframe.period, londonSessionAdv, sessionTzAdv)
int nyTimeAdv = time(timeframe.period, nySessionAdv, sessionTzAdv)

gShape = "profile shape"
showProfileShape = input.bool(true, "Classify Profile Shape", group = gShape, tooltip = "Classifies the profile shape as D, P, b, B or thin trend.")
showShapeLabel   = input.bool(true, "Show Shape Label", group = gShape, tooltip = "Shows the profile shape label on the chart.")

gAlerts = "alerts"
enableVpAlerts  = input.bool(true, "Enable alertcondition() Events", group = gAlerts, tooltip = "Enables TradingView alert conditions from this script.")
signalAcceptBars = input.int(2, "Acceptance Confirmation Bars", minval = 1, maxval = 10, group = gAlerts, tooltip = "Sets how many bars are required to confirm acceptance above VAH or below VAL.")

gNodes = "hvn and lvn"
showHvn   = input.bool(true, "Show HVN", group = gNodes, tooltip = "Shows high-volume nodes inside each profile.")
showLvn   = input.bool(true, "Show LVN", group = gNodes, tooltip = "Shows low-volume nodes inside each profile.")
hvnThresh = input.float(75, "HVN Threshold %", minval = 50, maxval = 95, step = 1, group = gNodes, tooltip = "Sets the volume threshold for high-volume nodes.")
lvnThresh = input.float(20, "LVN Threshold %", minval = 5, maxval = 45, step = 1, group = gNodes, tooltip = "Sets the volume threshold for low-volume nodes.")
maxNodes  = input.int(8, "Max HVN/LVN Lines Per Profile", minval = 1, maxval = 20, group = gNodes, tooltip = "Limits how many HVN and LVN lines are drawn per profile.")

gStyle = "style"
heatStyle   = input.string("Thermal", "VP Color Theme", options = ["Thermal", "Plasma", "Ice Fire", "Mono Cyan", "Mono Gold"], group = gStyle, tooltip = "Selects the color theme used for profile rows and levels.")
bgIntensity = input.float(1.0, "Profile Opacity", minval = 0.3, maxval = 1.5, step = 0.1, group = gStyle, tooltip = "Controls the opacity of profile rows.")
glowEffect  = input.bool(true, "POC/VA Glow", group = gStyle, tooltip = "Adds a soft glow effect to POC and value area lines.")
showStats   = input.bool(true, "Stats Labels", group = gStyle, tooltip = "Shows labels for profile levels and statistics.")
darkBg      = input.bool(false, "Force Dark Background", group = gStyle, tooltip = "Adds a dark chart background behind the indicator.")

useCustomColors = input.bool(false, "Use Custom Level Colors", group = gStyle, tooltip = "Allows custom colors to override the selected theme.")
customPocColor  = input.color(#FFEB3B, "Custom POC", group = gStyle, tooltip = "Sets the custom color for POC lines.")
customVaColor   = input.color(#29B6F6, "Custom VAH/VAL", group = gStyle, tooltip = "Sets the custom color for VAH and VAL lines.")
customHvnColor  = input.color(#FFA726, "Custom HVN", group = gStyle, tooltip = "Sets the custom color for HVN lines.")
customLvnColor  = input.color(#546E7A, "Custom LVN", group = gStyle, tooltip = "Sets the custom color for LVN lines.")
customTextColor = input.color(#ECEFF1, "Custom Text", group = gStyle, tooltip = "Sets the custom text color for labels.")
rangeBgColor    = input.color(color.new(#2962FF, 95), "Range Background", group = gStyle, tooltip = "Controls the setting setting.")

bgcolor(darkBg ? color.new(#000000, 0) : na)

f_palBull(int stop) =>
    color c = #00E676
    if heatStyle == "Thermal"
        c := stop == 0 ? #00E676 : stop == 1 ? #66BB6A : stop == 2 ? #FFEB3B : stop == 3 ? #FFA726 : #FF6F00
    else if heatStyle == "Plasma"
        c := stop == 0 ? #00BCD4 : stop == 1 ? #26C6DA : stop == 2 ? #E0AAFF : stop == 3 ? #FF6EC7 : #FF006E
    else if heatStyle == "Ice Fire"
        c := stop == 0 ? #4FC3F7 : stop == 1 ? #29B6F6 : stop == 2 ? #FFE66D : stop == 3 ? #FFA500 : #FF4500
    else if heatStyle == "Mono Cyan"
        c := stop == 0 ? #006978 : stop == 1 ? #00838F : stop == 2 ? #0097A7 : stop == 3 ? #00ACC1 : #00BCD4
    else
        c := stop == 0 ? #5D4037 : stop == 1 ? #795548 : stop == 2 ? #A1887F : stop == 3 ? #D7B48E : #FFD54F
    c

f_palBear(int stop) =>
    color c = #FF1744
    if heatStyle == "Thermal"
        c := stop == 0 ? #B71C1C : stop == 1 ? #D32F2F : stop == 2 ? #F44336 : stop == 3 ? #E91E63 : #FF1744
    else if heatStyle == "Plasma"
        c := stop == 0 ? #4A148C : stop == 1 ? #6A1B9A : stop == 2 ? #8E24AA : stop == 3 ? #C2185B : #E91E63
    else if heatStyle == "Ice Fire"
        c := stop == 0 ? #01579B : stop == 1 ? #0277BD : stop == 2 ? #B71C1C : stop == 3 ? #C62828 : #D32F2F
    else if heatStyle == "Mono Cyan"
        c := stop == 0 ? #263238 : stop == 1 ? #37474F : stop == 2 ? #455A64 : stop == 3 ? #546E7A : #607D8B
    else
        c := stop == 0 ? #3E2723 : stop == 1 ? #4E342E : stop == 2 ? #5D4037 : stop == 3 ? #6D4C41 : #795548
    c

f_colPoc() =>
    useCustomColors ? customPocColor : heatStyle == "Mono Gold" ? #FFD700 : heatStyle == "Mono Cyan" ? #00E5FF : heatStyle == "Plasma" ? #FF6EC7 : heatStyle == "Ice Fire" ? #FFFFFF : #FFEB3B

f_colVaEdge() =>
    useCustomColors ? customVaColor : heatStyle == "Mono Gold" ? #B8860B : heatStyle == "Mono Cyan" ? #00ACC1 : heatStyle == "Plasma" ? #9C27B0 : #29B6F6

f_colHvn() =>
    useCustomColors ? customHvnColor : heatStyle == "Plasma" ? #FF6EC7 : #FFA726

f_colLvn() =>
    useCustomColors ? customLvnColor : heatStyle == "Plasma" ? #7B2CBF : #546E7A

f_colText() =>
    useCustomColors ? customTextColor : #ECEFF1

f_lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_levelExtend() =>
    levelExtendMode == "Extend Right" ? extend.right : extend.none

f_clamp_int(int v, int lo, int hi) =>
    math.max(lo, math.min(hi, v))

f_safe_profile_len(int lenRaw, int offset) =>
    int hardCap = 4500
    int available = math.max(0, bar_index - offset)
    int userCap = math.min(maxProfileBars, hardCap)
    int out = math.min(lenRaw, userCap)
    out := math.min(out, available)
    out

f_safe_draw_left(int leftBar) =>
    leftBar >= bar_index - 9500

f_x_right(int baseBar, int extraBars) =>
    math.min(baseBar + extraBars, bar_index + 499)

f_x_label(int rightBar) =>
    math.min(rightBar + 1, bar_index + 500)

f_x_label_extra(int rightBar, int extraBars) =>
    math.min(rightBar + extraBars, bar_index + 500)

f_safeVolume(float v) =>
    float out = nz(v, 1.0)
    out <= 0 ? 1.0 : out

f_add_level(array<float> prices, array<string> names, array<float> weights, float p, string name, float w) =>
    if not na(p)
        array.push(prices, p)
        array.push(names, name)
        array.push(weights, w)

f_profile_shape_from_bins(array<float> binsVol, int pocIdx, float maxVol) =>
    int bins = array.size(binsVol)
    float topVol = 0.0
    float midVol = 0.0
    float botVol = 0.0
    float thinVol = 0.0
    float total = 0.0
    int peaks = 0
    if bins > 2 and maxVol > 0
        int third = int(math.floor(bins / 3.0))
        for i = 0 to bins - 1
            float vv = array.get(binsVol, i)
            total += vv
            if i < third
                botVol += vv
            else if i > bins - third - 1
                topVol += vv
            else
                midVol += vv
            float norm = vv / maxVol
            if norm < 0.16
                thinVol += vv
            if i > 0 and i < bins - 1
                float l = array.get(binsVol, i - 1)
                float r = array.get(binsVol, i + 1)
                if vv > l and vv > r and norm >= 0.45
                    peaks += 1
    float topRatio = total > 0 ? topVol / total : 0.0
    float botRatio = total > 0 ? botVol / total : 0.0
    float midRatio = total > 0 ? midVol / total : 0.0
    float thinRatio = total > 0 ? thinVol / total : 0.0
    float pocPos = bins > 1 ? float(pocIdx) / float(bins - 1) : 0.5
    string shape = "D-Shape"
    if thinRatio > 0.55
        shape := "Thin Trend"
    else if peaks >= 2 and midRatio < 0.44
        shape := "B-Shape"
    else if topRatio > 0.42 and pocPos > 0.58
        shape := "P-Shape"
    else if botRatio > 0.42 and pocPos < 0.42
        shape := "b-Shape"
    else
        shape := "D-Shape"
    shape

f_value_relation_dash(float curVah, float curVal, float prevVah, float prevVal) =>
    string rel = "NA"
    if not na(curVah) and not na(curVal) and not na(prevVah) and not na(prevVal)
        bool higher = curVal > prevVal and curVah > prevVah
        bool lower = curVal < prevVal and curVah < prevVah
        bool inside = curVah <= prevVah and curVal >= prevVal
        bool outside = curVah >= prevVah and curVal <= prevVal
        bool overlap = math.max(curVal, prevVal) <= math.min(curVah, prevVah)
        rel := higher ? "Higher Value" : lower ? "Lower Value" : inside ? "Inside Value" : outside ? "Outside Value" : overlap ? "Overlapping Value" : "Unchanged Value"
    rel

f_status_naked(int touches, int ageBars, bool broken) =>
    broken ? "Broken" : ageBars > nakedDeadAgeBars ? "Dead" : touches == 0 ? "Fresh" : touches == 1 ? "Tested" : "Respected"

f_color_naked(string status) =>
    status == "Fresh" ? nakedColorFresh : status == "Tested" or status == "Respected" ? nakedColorTested : nakedColorBroken

var array<box> histBoxes = array.new_box()
var array<line> histLines = array.new_line()
var array<label> histLabels = array.new_label()
var array<linefill> histFills = array.new_linefill()

var array<int> histBoxCounts = array.new_int()
var array<int> histLineCounts = array.new_int()
var array<int> histLabelCounts = array.new_int()
var array<int> histFillCounts = array.new_int()

var array<box> liveBoxes = array.new_box()
var array<line> liveLines = array.new_line()
var array<label> liveLabels = array.new_label()
var array<linefill> liveFills = array.new_linefill()

var array<float> sumPocs = array.new_float()
var array<float> sumVahs = array.new_float()
var array<float> sumVals = array.new_float()
var array<float> sumVols = array.new_float()
var array<int> sumRights = array.new_int()

var array<line> compLines = array.new_line()
var array<label> compLabels = array.new_label()

var array<line> advLines = array.new_line()
var array<box> advBoxes = array.new_box()

var array<float> nakedPricesAdv = array.new_float()
var array<int> nakedStartsAdv = array.new_int()
var array<int> nakedTouchesAdv = array.new_int()
var array<int> nakedLastTouchAdv = array.new_int()
var array<bool> nakedBrokenAdv = array.new_bool()
var array<line> nakedLinesAdv = array.new_line()
var array<label> nakedLabelsAdv = array.new_label()

var float apLastPoc = na
var float apLastVah = na
var float apLastVal = na
var float apLastHigh = na
var float apLastLow = na
var float apLastOpen = na
var float apLastClose = na
var float apPrevPocDash = na
var float apPrevVahDash = na
var float apPrevValDash = na
var string apLastPocMigration = "NA"
var string apLastValueRelation = "NA"
var string apLastShape = "NA"
var float apLastDeltaPoc = na
var float apLastVoidTop = na
var float apLastVoidBot = na
var bool apLastPoorHigh = false
var bool apLastPoorLow = false
var float apLastVwap = na
var float apLastIbHigh = na
var float apLastIbLow = na
var string apLastDominantSession = "NA"
var float apLastDominantShare = na
var int apLastConfluenceScore = na
var string apLastConfluenceText = "NA"
var float apLastConfluencePrice = na

var bool evPocTouch = false
var bool evAcceptedAboveVah = false
var bool evAcceptedBelowVal = false
var bool evRejectedVah = false
var bool evRejectedVal = false
var bool evFailedAuction = false
var bool evPocReclaim = false
var bool evPocLost = false
var bool evValDefense = false
var bool evLvgFill = false
var bool evPoorHighRepaired = false
var bool evPoorLowRepaired = false
var bool evNakedTouch = false
var bool evPocMigrationChange = false
var bool evConfluenceTouch = false

f_should_show_naked(string status) =>
    not ((hideBrokenNaked and status == "Broken") or (hideDeadNaked and status == "Dead"))

f_nearest_naked(float price) =>
    float nearest = na
    float best = 1e20
    if array.size(nakedPricesAdv) > 0 and not na(price)
        for i = 0 to array.size(nakedPricesAdv) - 1
            float p = array.get(nakedPricesAdv, i)
            int ns = array.get(nakedStartsAdv, i)
            int touches = array.get(nakedTouchesAdv, i)
            bool broken = array.get(nakedBrokenAdv, i)
            int age = bar_index - ns
            string st = f_status_naked(touches, age, broken)
            if f_should_show_naked(st)
                float d = math.abs(price - p)
                if d < best
                    best := d
                    nearest := p
    nearest

f_composite_calc() =>
    float cPoc = na
    float cVah = na
    float cVal = na
    if array.size(sumPocs) >= 2
        int n = math.min(compositePeriods, array.size(sumPocs))
        float wSum = 0.0
        float pocSum = 0.0
        float vahSum = 0.0
        float valSum = 0.0
        for i = 0 to n - 1
            int idx = array.size(sumPocs) - 1 - i
            float w = nz(array.get(sumVols, idx), 1.0)
            w := w <= 0 ? 1.0 : w
            pocSum += array.get(sumPocs, idx) * w
            vahSum += array.get(sumVahs, idx) * w
            valSum += array.get(sumVals, idx) * w
            wSum += w
        if wSum > 0
            cPoc := pocSum / wSum
            cVah := vahSum / wSum
            cVal := valSum / wSum
    [cPoc, cVah, cVal]

f_clear_boxes(array<box> arr) =>
    while array.size(arr) > 0
        box bx = array.shift(arr)
        if not na(bx)
            box.delete(bx)

f_clear_lines(array<line> arr) =>
    while array.size(arr) > 0
        line ln = array.shift(arr)
        if not na(ln)
            line.delete(ln)

f_clear_labels(array<label> arr) =>
    while array.size(arr) > 0
        label lb = array.shift(arr)
        if not na(lb)
            label.delete(lb)

f_clear_fills(array<linefill> arr) =>
    while array.size(arr) > 0
        linefill lf = array.shift(arr)
        if not na(lf)
            linefill.delete(lf)

f_delete_oldest_boxes(array<box> arr, int qty) =>
    int q = qty
    while q > 0 and array.size(arr) > 0
        box bx = array.shift(arr)
        if not na(bx)
            box.delete(bx)
        q -= 1

f_delete_oldest_lines(array<line> arr, int qty) =>
    int q = qty
    while q > 0 and array.size(arr) > 0
        line ln = array.shift(arr)
        if not na(ln)
            line.delete(ln)
        q -= 1

f_delete_oldest_labels(array<label> arr, int qty) =>
    int q = qty
    while q > 0 and array.size(arr) > 0
        label lb = array.shift(arr)
        if not na(lb)
            label.delete(lb)
        q -= 1

f_delete_oldest_fills(array<linefill> arr, int qty) =>
    int q = qty
    while q > 0 and array.size(arr) > 0
        linefill lf = array.shift(arr)
        if not na(lf)
            linefill.delete(lf)
        q -= 1

f_trim_history() =>
    while array.size(histBoxCounts) > profilesHistory
        int bc = array.shift(histBoxCounts)
        int lc = array.shift(histLineCounts)
        int tc = array.shift(histLabelCounts)
        int fc = array.shift(histFillCounts)
        f_delete_oldest_fills(histFills, fc)
        f_delete_oldest_boxes(histBoxes, bc)
        f_delete_oldest_lines(histLines, lc)
        f_delete_oldest_labels(histLabels, tc)

f_drawProfile(int periodLeftBar, int periodRightBar, int lenRaw, int offset, string tag, array<box> boxArr, array<line> lineArr, array<label> labelArr, array<linefill> fillArr) =>
    int beforeB = array.size(boxArr)
    int beforeL = array.size(lineArr)
    int beforeT = array.size(labelArr)
    int beforeF = array.size(fillArr)

    int len = f_safe_profile_len(lenRaw, offset)

    if len <= 1
        [0, 0, 0, 0, na, na, na, na, na, na, na, na]
    else
        float hi = high[offset]
        float lo = low[offset]

        for i = 0 to len - 1
            int idx = offset + i
            hi := math.max(hi, high[idx])
            lo := math.min(lo, low[idx])

        float periodOpen = open[offset + len - 1]
        float periodClose = close[offset]

        float range_ = math.max(hi - lo, syminfo.mintick * nRows)
        float step = range_ / nRows

        array<float> rowsTotal = array.new_float(nRows, 0.0)
        array<float> rowsBull = array.new_float(nRows, 0.0)
        array<float> rowsBear = array.new_float(nRows, 0.0)
        array<float> hvnPrices = array.new_float()
        array<float> lvnPrices = array.new_float()

        float bullTot = 0.0
        float bearTot = 0.0

        for i = 0 to len - 1
            int idx = offset + i
            float barHi = high[idx]
            float barLo = low[idx]
            float barRange = math.max(barHi - barLo, syminfo.mintick)
            float v = f_safeVolume(volume[idx])

            float bullShare = 0.5
            float bearShare = 0.5
            if deltaMode == "Bar Direction"
                bullShare := close[idx] > open[idx] ? 1.0 : close[idx] < open[idx] ? 0.0 : 0.5
                bearShare := 1.0 - bullShare
            else
                bullShare := (close[idx] - barLo) / barRange
                bullShare := math.max(math.min(bullShare, 1.0), 0.0)
                bearShare := 1.0 - bullShare

            float vBull = v * bullShare
            float vBear = v * bearShare
            bullTot += vBull
            bearTot += vBear

            int rowLoIdx = int(math.floor((barLo - lo) / step))
            int rowHiIdx = int(math.floor((barHi - lo) / step))
            rowLoIdx := f_clamp_int(rowLoIdx, 0, nRows - 1)
            rowHiIdx := f_clamp_int(rowHiIdx, 0, nRows - 1)

            int spannedRows = math.max(rowHiIdx - rowLoIdx + 1, 1)
            float vPerRowBull = vBull / spannedRows
            float vPerRowBear = vBear / spannedRows

            for k = rowLoIdx to rowHiIdx
                array.set(rowsBull, k, array.get(rowsBull, k) + vPerRowBull)
                array.set(rowsBear, k, array.get(rowsBear, k) + vPerRowBear)
                array.set(rowsTotal, k, array.get(rowsTotal, k) + vPerRowBull + vPerRowBear)

        int pocIdx = 0
        float pocVol = array.get(rowsTotal, 0)
        float totalVol = 0.0
        for k = 0 to nRows - 1
            float vv = array.get(rowsTotal, k)
            totalVol += vv
            if vv > pocVol
                pocVol := vv
                pocIdx := k

        if pocVol <= 0 or totalVol <= 0
            [0, 0, 0, 0, na, na, na, na, na, na, na, na]
        else
            float pocPrice = lo + (pocIdx + 0.5) * step

            float vaTargetVol = totalVol * valuePct / 100.0
            float accVol = pocVol
            int vaHi = pocIdx
            int vaLo = pocIdx

            while accVol < vaTargetVol and (vaHi < nRows - 1 or vaLo > 0)
                float volUp = vaHi < nRows - 1 ? array.get(rowsTotal, vaHi + 1) : -1.0
                float volDn = vaLo > 0 ? array.get(rowsTotal, vaLo - 1) : -1.0
                if volUp >= volDn and volUp >= 0
                    vaHi += 1
                    accVol += volUp
                else if volDn >= 0
                    vaLo -= 1
                    accVol += volDn
                else
                    break

            float vahPrice = lo + (vaHi + 1) * step
            float valPrice = lo + vaLo * step

            float thrHvn = pocVol * hvnThresh / 100.0
            float thrLvn = pocVol * lvnThresh / 100.0

            if nRows >= 5
                for k = 2 to nRows - 3
                    float vv = array.get(rowsTotal, k)
                    float vm2 = array.get(rowsTotal, k - 2)
                    float vm1 = array.get(rowsTotal, k - 1)
                    float vp1 = array.get(rowsTotal, k + 1)
                    float vp2 = array.get(rowsTotal, k + 2)
                    if vv >= thrHvn and vv > vm1 and vv > vp1 and vv >= vm2 and vv >= vp2 and k != pocIdx and array.size(hvnPrices) < maxNodes
                        array.push(hvnPrices, lo + (k + 0.5) * step)
                    if vv <= thrLvn and vv < vm1 and vv < vp1 and vv <= vm2 and vv <= vp2 and array.size(lvnPrices) < maxNodes
                        array.push(lvnPrices, lo + (k + 0.5) * step)

            int calcPeriodLeft = periodRightBar - len + 1
            int periodLeft = math.max(periodLeftBar, calcPeriodLeft)
            int periodRight = periodRightBar
            int profileBarsWide = int(math.max(len * profileWidthPct / 100.0, minWidthBars))
            profileBarsWide := math.max(profileBarsWide, 2)

            int bandLeft = profilePlacement == "Right" ? periodRight - profileBarsWide : periodLeft
            int bandRight = profilePlacement == "Right" ? periodRight : periodLeft + profileBarsWide
            int midBar = int(math.round((bandLeft + bandRight) / 2.0))
            int pocRight = f_x_right(periodRight, pocExtendBars)
            int vaRight = f_x_right(periodRight, vaExtendBars)
            int hvnRight = f_x_right(periodRight, hvnExtendBars)
            int lvnRight = f_x_right(periodRight, lvnExtendBars)
            int openCloseRight = f_x_right(periodRight, openCloseExtendBars)
            int rangeEqRight = f_x_right(periodRight, rangeEqExtendBars)
            int voidRight = f_x_right(periodRight, voidExtendBars)
            int poorRight = f_x_right(periodRight, poorExtendBars)

            if showRangeBg
                box bg = box.new(periodLeft, hi, periodRight, lo, xloc = xloc.bar_index, border_color = color.new(rangeBgColor, 10), border_width = 1, border_style = line.style_dotted, bgcolor = rangeBgColor)
                array.push(boxArr, bg)

            for k = 0 to nRows - 1
                float rowLo = lo + (k + rowGapY) * step
                float rowHi = lo + (k + 1.0 - rowGapY) * step
                float vBull = array.get(rowsBull, k)
                float vBear = array.get(rowsBear, k)
                float vTot = vBull + vBear

                if vTot > 0
                    float intensity = vTot / pocVol
                    int stop = intensity > 0.85 ? 4 : intensity > 0.65 ? 3 : intensity > 0.40 ? 2 : intensity > 0.20 ? 1 : 0
                    int transp = int(math.max(85 - intensity * 60 * bgIntensity, 25))

                    if showSplit
                        int bullW = int(math.round((vBull / pocVol) * (profileBarsWide / 2.0)))
                        int bearW = int(math.round((vBear / pocVol) * (profileBarsWide / 2.0)))

                        if bullW > 0
                            box bbull = box.new(midBar, rowHi, midBar + bullW, rowLo, xloc = xloc.bar_index, border_color = color.new(f_palBull(stop), math.max(transp - 10, 15)), border_width = 1, bgcolor = color.new(f_palBull(stop), transp))
                            array.push(boxArr, bbull)
                        if bearW > 0
                            box bbear = box.new(midBar - bearW, rowHi, midBar, rowLo, xloc = xloc.bar_index, border_color = color.new(f_palBear(stop), math.max(transp - 10, 15)), border_width = 1, bgcolor = color.new(f_palBear(stop), transp))
                            array.push(boxArr, bbear)
                    else
                        bool bullDom = vBull >= vBear
                        color c = bullDom ? f_palBull(stop) : f_palBear(stop)
                        int halfW = int(math.round((vTot / pocVol) * (profileBarsWide / 2.0)))
                        if halfW > 0
                            box buni = box.new(midBar - halfW, rowHi, midBar + halfW, rowLo, xloc = xloc.bar_index, border_color = color.new(c, math.max(transp - 10, 15)), border_width = 1, bgcolor = color.new(c, transp))
                            array.push(boxArr, buni)

            color colPoc = f_colPoc()
            color colVa = f_colVaEdge()
            color colTxt = f_colText()
            levelExt = f_levelExtend()

            if showVolumeVoids and nRows >= minVoidRows
                int voidCount = 0
                int seqStart = na
                int seqLen = 0
                for k = 0 to nRows - 1
                    float normVol = array.get(rowsTotal, k) / pocVol
                    bool isVoidRow = normVol <= voidThresholdPct / 100.0
                    if isVoidRow
                        if na(seqStart)
                            seqStart := k
                        seqLen += 1
                    bool closeSeq = (not isVoidRow or k == nRows - 1)
                    if closeSeq
                        int seqEnd = isVoidRow and k == nRows - 1 ? k : k - 1
                        if seqLen >= minVoidRows and voidCount < maxVoidZones and not na(seqStart)
                            float zBot = lo + seqStart * step
                            float zTop = lo + (seqEnd + 1) * step
                            box voidBx = box.new(periodLeft, zTop, voidRight, zBot, xloc = xloc.bar_index, border_color = color.new(voidZoneColor, 20), border_width = 1, border_style = line.style_dotted, bgcolor = voidZoneColor)
                            array.push(boxArr, voidBx)
                            if showStats
                                label voidLb = label.new(f_x_label(voidRight), math.avg(zTop, zBot), tag + " VOID", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(voidZoneColor, 55), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                                array.push(labelArr, voidLb)
                            voidCount += 1
                        seqStart := na
                        seqLen := 0

            if showProfileHL
                line ph = line.new(periodLeft, hi, rangeEqRight, hi, xloc = xloc.bar_index, extend = levelExt, color = rangeLineColor, width = rangeLineWidth, style = line.style_solid)
                line pl = line.new(periodLeft, lo, rangeEqRight, lo, xloc = xloc.bar_index, extend = levelExt, color = rangeLineColor, width = rangeLineWidth, style = line.style_solid)
                array.push(lineArr, ph)
                array.push(lineArr, pl)
                if showStats
                    label phLb = label.new(f_x_label(rangeEqRight), hi, tag + " PH", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(rangeLineColor, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    label plLb = label.new(f_x_label(rangeEqRight), lo, tag + " PL", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(rangeLineColor, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, phLb)
                    array.push(labelArr, plLb)

            if showProfileEQ
                float eqPrice = math.avg(hi, lo)
                line eq = line.new(periodLeft, eqPrice, rangeEqRight, eqPrice, xloc = xloc.bar_index, extend = levelExt, color = eqLineColor, width = rangeLineWidth, style = line.style_dotted)
                array.push(lineArr, eq)
                if showStats
                    label eqLb = label.new(f_x_label(rangeEqRight), eqPrice, tag + " EQ", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(eqLineColor, 75), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, eqLb)

            if showPeriodOpen
                line opL = line.new(periodLeft, periodOpen, openCloseRight, periodOpen, xloc = xloc.bar_index, extend = levelExt, color = openLineColor, width = openCloseWidth, style = line.style_dotted)
                array.push(lineArr, opL)
                if showStats
                    label opLb = label.new(f_x_label(openCloseRight), periodOpen, tag + " OPEN", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(openLineColor, 75), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, opLb)

            if showPeriodClose
                line clL = line.new(periodLeft, periodClose, openCloseRight, periodClose, xloc = xloc.bar_index, extend = levelExt, color = closeLineColor, width = openCloseWidth, style = line.style_solid)
                array.push(lineArr, clL)
                if showStats
                    label clLb = label.new(f_x_label(openCloseRight), periodClose, tag + " CLOSE", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(closeLineColor, 75), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, clLb)

            if showPoorHL
                int edgeRows = math.min(poorEdgeRows, nRows)
                float topVol = 0.0
                float botVol = 0.0
                for e = 0 to edgeRows - 1
                    topVol += array.get(rowsTotal, nRows - 1 - e)
                    botVol += array.get(rowsTotal, e)
                float edgeBase = pocVol * edgeRows
                bool poorHigh = edgeBase > 0 and topVol / edgeBase >= poorEdgeRatioPct / 100.0
                bool poorLow = edgeBase > 0 and botVol / edgeBase >= poorEdgeRatioPct / 100.0
                if poorHigh
                    line poorH = line.new(periodLeft, hi, poorRight, hi, xloc = xloc.bar_index, extend = levelExt, color = poorLineColor, width = 2, style = line.style_dashed)
                    array.push(lineArr, poorH)
                    if showStats
                        label poorHLb = label.new(f_x_label(poorRight), hi, tag + " POOR H", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(poorLineColor, 30), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                        array.push(labelArr, poorHLb)
                if poorLow
                    line poorL = line.new(periodLeft, lo, poorRight, lo, xloc = xloc.bar_index, extend = levelExt, color = poorLineColor, width = 2, style = line.style_dashed)
                    array.push(lineArr, poorL)
                    if showStats
                        label poorLLb = label.new(f_x_label(poorRight), lo, tag + " POOR L", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(poorLineColor, 30), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                        array.push(labelArr, poorLLb)

            if showVa and showVaFill
                line vahFillL = line.new(periodLeft, vahPrice, vaRight, vahPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(colVa, 90), width = 1)
                line valFillL = line.new(periodLeft, valPrice, vaRight, valPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(colVa, 90), width = 1)
                linefill vf = linefill.new(vahFillL, valFillL, color.new(colVa, 92))
                array.push(lineArr, vahFillL)
                array.push(lineArr, valFillL)
                array.push(fillArr, vf)

            if showVa
                line vahMain = line.new(periodLeft, vahPrice, vaRight, vahPrice, xloc = xloc.bar_index, extend = levelExt, color = colVa, width = 1, style = line.style_dashed)
                line valMain = line.new(periodLeft, valPrice, vaRight, valPrice, xloc = xloc.bar_index, extend = levelExt, color = colVa, width = 1, style = line.style_dashed)
                array.push(lineArr, vahMain)
                array.push(lineArr, valMain)
                if glowEffect
                    line vahGlow = line.new(periodLeft, vahPrice, vaRight, vahPrice, xloc = xloc.bar_index, extend = levelExt, color = color.new(colVa, 80), width = 3, style = line.style_dashed)
                    line valGlow = line.new(periodLeft, valPrice, vaRight, valPrice, xloc = xloc.bar_index, extend = levelExt, color = color.new(colVa, 80), width = 3, style = line.style_dashed)
                    array.push(lineArr, vahGlow)
                    array.push(lineArr, valGlow)

                if showStats
                    label vahLb = label.new(f_x_label(vaRight), vahPrice, tag + " VAH " + str.tostring(vahPrice, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colVa, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    label valLb = label.new(f_x_label(vaRight), valPrice, tag + " VAL " + str.tostring(valPrice, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colVa, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, vahLb)
                    array.push(labelArr, valLb)

            if showPoc
                if glowEffect
                    line pocGlow1 = line.new(periodLeft, pocPrice, pocRight, pocPrice, xloc = xloc.bar_index, extend = levelExt, color = color.new(colPoc, 80), width = pocWidth + 3, style = f_lineStyle(pocStyle))
                    line pocGlow2 = line.new(periodLeft, pocPrice, pocRight, pocPrice, xloc = xloc.bar_index, extend = levelExt, color = color.new(colPoc, 60), width = pocWidth + 1, style = f_lineStyle(pocStyle))
                    array.push(lineArr, pocGlow1)
                    array.push(lineArr, pocGlow2)
                line pocMain = line.new(periodLeft, pocPrice, pocRight, pocPrice, xloc = xloc.bar_index, extend = levelExt, color = colPoc, width = pocWidth, style = f_lineStyle(pocStyle))
                array.push(lineArr, pocMain)

                if showStats
                    label pocLb = label.new(f_x_label(pocRight), pocPrice, tag + " POC " + str.tostring(pocPrice, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(colPoc, 30), textcolor = color.black, size = size.tiny, style = label.style_label_left)
                    array.push(labelArr, pocLb)

            if showHvn and array.size(hvnPrices) > 0
                for i = 0 to array.size(hvnPrices) - 1
                    float p = array.get(hvnPrices, i)
                    line l = line.new(periodLeft, p, hvnRight, p, xloc = xloc.bar_index, extend = levelExt, color = color.new(f_colHvn(), 50), width = 1, style = line.style_dotted)
                    array.push(lineArr, l)
                    if showStats
                        label lb = label.new(f_x_label(hvnRight), p, tag + " HVN", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(f_colHvn(), 75), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                        array.push(labelArr, lb)

            if showLvn and array.size(lvnPrices) > 0
                for i = 0 to array.size(lvnPrices) - 1
                    float p = array.get(lvnPrices, i)
                    line l = line.new(periodLeft, p, lvnRight, p, xloc = xloc.bar_index, extend = levelExt, color = color.new(f_colLvn(), 65), width = 1, style = line.style_dotted)
                    array.push(lineArr, l)
                    if showStats
                        label lb = label.new(f_x_label(lvnRight), p, tag + " LVN", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(f_colLvn(), 78), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                        array.push(labelArr, lb)

            if showStats
                float delta = bullTot - bearTot
                float deltaPct = totalVol > 0 ? (delta / totalVol) * 100.0 : 0.0
                string sign = deltaPct >= 0 ? "+" : ""
                color deltaCol = deltaPct >= 0 ? f_palBull(3) : f_palBear(3)
                label deltaLb = label.new(midBar, lo - step, tag + " Δ " + sign + str.tostring(deltaPct, "#.0") + "%", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(deltaCol, 30), textcolor = colTxt, size = size.tiny, style = label.style_label_up)
                array.push(labelArr, deltaLb)

            int afterB = array.size(boxArr)
            int afterL = array.size(lineArr)
            int afterT = array.size(labelArr)
            int afterF = array.size(fillArr)
            [afterB - beforeB, afterL - beforeL, afterT - beforeT, afterF - beforeF, pocPrice, vahPrice, valPrice, totalVol, hi, lo, periodOpen, periodClose]

f_drawAdvanced(int periodLeft, int periodRight, int lenRaw, int offset, string tag, array<box> boxArr, array<line> lineArr, array<label> labelArr, array<linefill> fillArr, float pocPrice, float vahPrice, float valPrice, float profHi, float profLo, float periodOpen, float periodClose) =>
    int beforeB = array.size(boxArr)
    int beforeL = array.size(lineArr)
    int beforeT = array.size(labelArr)
    int beforeF = array.size(fillArr)

    int len = f_safe_profile_len(lenRaw, offset)

    bool validAdv = len > 1 and not na(pocPrice) and not na(vahPrice) and not na(valPrice) and not na(profHi) and not na(profLo)
    int outB = 0
    int outL = 0
    int outT = 0
    int outF = 0
    string outShape = "NA"
    float outDeltaPoc = na
    float outVoidTop = na
    float outVoidBot = na
    int outPoorH = 0
    int outPoorL = 0
    float outVwap = na
    float outIbHigh = na
    float outIbLow = na
    string outDomSession = "NA"
    float outDomShare = na
    int outConfScore = na
    string outConfText = "NA"
    float outConfPrice = na

    if validAdv
        float range_ = math.max(profHi - profLo, syminfo.mintick * nRows)
        float step = range_ / nRows
        int drawLeft = math.max(periodLeft, periodRight - len + 1)
        int imbRight = f_x_right(periodRight, imbalanceExtendBars)
        int deltaPocRight = f_x_right(periodRight, deltaPocExtendBars)
        int vwapRight = f_x_right(periodRight, vwapExtendBars)
        int ibRight = f_x_right(periodRight, ibExtendBars)
        int confluenceRight = f_x_right(periodRight, confluenceExtendBars)
        levelExt = f_levelExtend()
        color colTxt = f_colText()

        array<float> rowsTotal = array.new_float(nRows, 0.0)
        array<float> rowsBull = array.new_float(nRows, 0.0)
        array<float> rowsBear = array.new_float(nRows, 0.0)
        array<float> hvnPrices = array.new_float()
        array<float> lvnPrices = array.new_float()

        float bullTot = 0.0
        float bearTot = 0.0
        float vwapPV = 0.0
        float vwapVol = 0.0
        float totalVol = 0.0

        float ibHigh = na
        float ibLow = na
        int startT = time[offset + len - 1]
        int ibSpanMs = vpMode == "Daily" ? ibDailyMinutes * 60 * 1000 : vpMode == "Weekly" ? ibWeeklyDays * 24 * 60 * 60 * 1000 : ibMonthlyDays * 24 * 60 * 60 * 1000
        int ibCutoff = startT + ibSpanMs

        float asiaVol = 0.0
        float londonVol = 0.0
        float nyVol = 0.0
        float otherVol = 0.0

        for i = 0 to len - 1
            int idx = offset + i
            float barHi = high[idx]
            float barLo = low[idx]
            float barRange = math.max(barHi - barLo, syminfo.mintick)
            float v = f_safeVolume(volume[idx])
            float barPrice = hlc3[idx]
            totalVol += v
            vwapPV += barPrice * v
            vwapVol += v

            if showInitialBalance and time[idx] <= ibCutoff
                ibHigh := na(ibHigh) ? barHi : math.max(ibHigh, barHi)
                ibLow := na(ibLow) ? barLo : math.min(ibLow, barLo)

            if showSessionContribution
                bool inAsia = not na(asiaTimeAdv[idx])
                bool inLondon = not na(londonTimeAdv[idx])
                bool inNy = not na(nyTimeAdv[idx])
                if inAsia
                    asiaVol += v
                else if inLondon
                    londonVol += v
                else if inNy
                    nyVol += v
                else
                    otherVol += v

            float bullShare = 0.5
            float bearShare = 0.5
            if deltaMode == "Bar Direction"
                bullShare := close[idx] > open[idx] ? 1.0 : close[idx] < open[idx] ? 0.0 : 0.5
                bearShare := 1.0 - bullShare
            else
                bullShare := (close[idx] - barLo) / barRange
                bullShare := math.max(math.min(bullShare, 1.0), 0.0)
                bearShare := 1.0 - bullShare

            float vBull = v * bullShare
            float vBear = v * bearShare
            bullTot += vBull
            bearTot += vBear

            int rowLoIdx = int(math.floor((barLo - profLo) / step))
            int rowHiIdx = int(math.floor((barHi - profLo) / step))
            rowLoIdx := f_clamp_int(rowLoIdx, 0, nRows - 1)
            rowHiIdx := f_clamp_int(rowHiIdx, 0, nRows - 1)
            int spannedRows = math.max(rowHiIdx - rowLoIdx + 1, 1)
            float vPerRowBull = vBull / spannedRows
            float vPerRowBear = vBear / spannedRows
            for k = rowLoIdx to rowHiIdx
                array.set(rowsBull, k, array.get(rowsBull, k) + vPerRowBull)
                array.set(rowsBear, k, array.get(rowsBear, k) + vPerRowBear)
                array.set(rowsTotal, k, array.get(rowsTotal, k) + vPerRowBull + vPerRowBear)

        int pocIdx = 0
        float pocVol = array.get(rowsTotal, 0)
        for k = 1 to nRows - 1
            float vv = array.get(rowsTotal, k)
            if vv > pocVol
                pocVol := vv
                pocIdx := k

        float vwap = vwapVol > 0 ? vwapPV / vwapVol : na
        float variance = 0.0
        if showPeriodVwap and showVwapBands and not na(vwap) and vwapVol > 0
            for i = 0 to len - 1
                int idx = offset + i
                float v = f_safeVolume(volume[idx])
                float d = hlc3[idx] - vwap
                variance += d * d * v
        float vwapDev = vwapVol > 0 ? math.sqrt(variance / vwapVol) : na

        float thrHvn = pocVol * hvnThresh / 100.0
        float thrLvn = pocVol * lvnThresh / 100.0
        float nearestHvn = na
        float nearestLvn = na
        float nearestHvnDist = 1e20
        float nearestLvnDist = 1e20

        if nRows >= 5 and pocVol > 0
            for k = 2 to nRows - 3
                float vv = array.get(rowsTotal, k)
                float vm2 = array.get(rowsTotal, k - 2)
                float vm1 = array.get(rowsTotal, k - 1)
                float vp1 = array.get(rowsTotal, k + 1)
                float vp2 = array.get(rowsTotal, k + 2)
                float p = profLo + (k + 0.5) * step
                if vv >= thrHvn and vv > vm1 and vv > vp1 and vv >= vm2 and vv >= vp2 and k != pocIdx
                    array.push(hvnPrices, p)
                    float d = math.abs(p - close)
                    if d < nearestHvnDist
                        nearestHvnDist := d
                        nearestHvn := p
                if vv <= thrLvn and vv < vm1 and vv < vp1 and vv <= vm2 and vv <= vp2
                    array.push(lvnPrices, p)
                    float d = math.abs(p - close)
                    if d < nearestLvnDist
                        nearestLvnDist := d
                        nearestLvn := p

        string shape = showProfileShape ? f_profile_shape_from_bins(rowsTotal, pocIdx, pocVol) : "NA"
        if showProfileShape and showShapeLabel
            label shapeLb = label.new(periodRight + 1, profHi + step, tag + " " + shape, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(f_colPoc(), 72), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
            array.push(labelArr, shapeLb)

        float deltaPoc = na
        float maxAbsDelta = 0.0
        int imbCount = 0
        int bullImbCount = 0
        int bearImbCount = 0
        float bullImbBestPct = 0.0
        float bearImbBestPct = 0.0
        float bullImbBestPrice = na
        float bearImbBestPrice = na
        float bullImbSumPrice = 0.0
        float bearImbSumPrice = 0.0
        if pocVol > 0
            for k = 0 to nRows - 1
                float b = array.get(rowsBull, k)
                float r = array.get(rowsBear, k)
                float t = b + r
                float d = b - r
                if math.abs(d) > maxAbsDelta
                    maxAbsDelta := math.abs(d)
                    deltaPoc := profLo + (k + 0.5) * step
                if showDeltaImbalance and t > 0 and imbCount < maxImbalanceRows
                    float bullPct = b / t * 100.0
                    float bearPct = r / t * 100.0
                    bool bullImb = bullPct >= deltaImbalancePct
                    bool bearImb = bearPct >= deltaImbalancePct
                    if bullImb or bearImb
                        float zBot = profLo + k * step
                        float zTop = profLo + (k + 1) * step
                        float zMid = math.avg(zTop, zBot)
                        color zCol = bullImb ? bullImbColor : bearImbColor
                        box imbBx = box.new(drawLeft, zTop, imbRight, zBot, xloc = xloc.bar_index, border_color = color.new(zCol, 25), border_width = 1, border_style = line.style_dotted, bgcolor = zCol)
                        array.push(boxArr, imbBx)
                        if bullImb
                            bullImbCount += 1
                            bullImbSumPrice += zMid
                            if bullPct > bullImbBestPct
                                bullImbBestPct := bullPct
                                bullImbBestPrice := zMid
                        if bearImb
                            bearImbCount += 1
                            bearImbSumPrice += zMid
                            if bearPct > bearImbBestPct
                                bearImbBestPct := bearPct
                                bearImbBestPrice := zMid
                        if imbalanceLabelMode == "Each Row"
                            label imbLb = label.new(f_x_label(imbRight), zMid, bullImb ? "Bull Imb" : "Bear Imb", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(zCol, 45), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
                            array.push(labelArr, imbLb)
                        imbCount += 1

        if showDeltaImbalance and imbalanceLabelMode == "Multiplier" and (bullImbCount > 0 or bearImbCount > 0)
            string imbTxt = ""
            if bullImbCount > 0
                imbTxt := imbTxt + "Bull Imb ×" + str.tostring(bullImbCount)
            if bearImbCount > 0
                imbTxt := imbTxt + (imbTxt == "" ? "" : "\n") + "Bear Imb ×" + str.tostring(bearImbCount)
            float imbLabelPrice = na
            if bullImbCount >= bearImbCount and bullImbCount > 0
                imbLabelPrice := not na(bullImbBestPrice) ? bullImbBestPrice : bullImbSumPrice / bullImbCount
            else if bearImbCount > 0
                imbLabelPrice := not na(bearImbBestPrice) ? bearImbBestPrice : bearImbSumPrice / bearImbCount
            color imbLabelColor = bullImbCount >= bearImbCount ? bullImbColor : bearImbColor
            label imbSummaryLb = label.new(f_x_label(imbRight), imbLabelPrice, imbTxt, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(imbLabelColor, 35), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
            array.push(labelArr, imbSummaryLb)

        if showDeltaPoc and not na(deltaPoc)
            line dpl = line.new(drawLeft, deltaPoc, deltaPocRight, deltaPoc, xloc = xloc.bar_index, extend = levelExt, color = deltaPocColor, width = 1, style = line.style_dotted)
            array.push(lineArr, dpl)
            label dplb = label.new(f_x_label(deltaPocRight), deltaPoc, tag + " ΔPOC", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(deltaPocColor, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
            array.push(labelArr, dplb)

        if showPeriodVwap and not na(vwap)
            line vw = line.new(drawLeft, vwap, vwapRight, vwap, xloc = xloc.bar_index, extend = levelExt, color = vwapColor, width = 2, style = line.style_solid)
            array.push(lineArr, vw)
            label vwLb = label.new(f_x_label(vwapRight), vwap, tag + " VWAP", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(vwapColor, 65), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
            array.push(labelArr, vwLb)
            if showVwapBands and not na(vwapDev) and vwapDev > 0
                float b1u = vwap + vwapDev * vwapBandMult1
                float b1d = vwap - vwapDev * vwapBandMult1
                float b2u = vwap + vwapDev * vwapBandMult2
                float b2d = vwap - vwapDev * vwapBandMult2
                line l1u = line.new(drawLeft, b1u, vwapRight, b1u, xloc = xloc.bar_index, extend = levelExt, color = vwapBandColor, width = 1, style = line.style_dashed)
                line l1d = line.new(drawLeft, b1d, vwapRight, b1d, xloc = xloc.bar_index, extend = levelExt, color = vwapBandColor, width = 1, style = line.style_dashed)
                line l2u = line.new(drawLeft, b2u, vwapRight, b2u, xloc = xloc.bar_index, extend = levelExt, color = color.new(vwapBandColor, 25), width = 1, style = line.style_dotted)
                line l2d = line.new(drawLeft, b2d, vwapRight, b2d, xloc = xloc.bar_index, extend = levelExt, color = color.new(vwapBandColor, 25), width = 1, style = line.style_dotted)
                array.push(lineArr, l1u)
                array.push(lineArr, l1d)
                array.push(lineArr, l2u)
                array.push(lineArr, l2d)

        if showInitialBalance and not na(ibHigh) and not na(ibLow) and ibHigh > ibLow
            float ibMid = math.avg(ibHigh, ibLow)
            float ibRange = ibHigh - ibLow
            line ih = line.new(drawLeft, ibHigh, ibRight, ibHigh, xloc = xloc.bar_index, extend = levelExt, color = ibColor, width = 1, style = line.style_solid)
            line il = line.new(drawLeft, ibLow, ibRight, ibLow, xloc = xloc.bar_index, extend = levelExt, color = ibColor, width = 1, style = line.style_solid)
            line im = line.new(drawLeft, ibMid, ibRight, ibMid, xloc = xloc.bar_index, extend = levelExt, color = color.new(ibColor, 35), width = 1, style = line.style_dotted)
            array.push(lineArr, ih)
            array.push(lineArr, il)
            array.push(lineArr, im)
            label ibLb = label.new(f_x_label(ibRight), ibHigh, tag + " IBH", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(ibColor, 70), textcolor = colTxt, size = size.tiny, style = label.style_label_left)
            array.push(labelArr, ibLb)
            if showIbExtensions
                line i1u = line.new(drawLeft, ibHigh + ibRange, ibRight, ibHigh + ibRange, xloc = xloc.bar_index, extend = levelExt, color = color.new(ibColor, 45), width = 1, style = line.style_dashed)
                line i1d = line.new(drawLeft, ibLow - ibRange, ibRight, ibLow - ibRange, xloc = xloc.bar_index, extend = levelExt, color = color.new(ibColor, 45), width = 1, style = line.style_dashed)
                line i2u = line.new(drawLeft, ibHigh + ibRange * 2.0, ibRight, ibHigh + ibRange * 2.0, xloc = xloc.bar_index, extend = levelExt, color = color.new(ibColor, 65), width = 1, style = line.style_dotted)
                line i2d = line.new(drawLeft, ibLow - ibRange * 2.0, ibRight, ibLow - ibRange * 2.0, xloc = xloc.bar_index, extend = levelExt, color = color.new(ibColor, 65), width = 1, style = line.style_dotted)
                array.push(lineArr, i1u)
                array.push(lineArr, i1d)
                array.push(lineArr, i2u)
                array.push(lineArr, i2d)

        float firstVoidTop = na
        float firstVoidBot = na
        int seqStart = na
        int seqLen = 0
        if nRows >= minVoidRows and pocVol > 0
            for k = 0 to nRows - 1
                bool isVoidRow = array.get(rowsTotal, k) / pocVol <= voidThresholdPct / 100.0
                if isVoidRow
                    if na(seqStart)
                        seqStart := k
                    seqLen += 1
                bool closeSeq = (not isVoidRow or k == nRows - 1)
                if closeSeq
                    int seqEnd = isVoidRow and k == nRows - 1 ? k : k - 1
                    if seqLen >= minVoidRows and na(firstVoidTop) and not na(seqStart)
                        firstVoidBot := profLo + seqStart * step
                        firstVoidTop := profLo + (seqEnd + 1) * step
                    seqStart := na
                    seqLen := 0

        int edgeRows = math.min(poorEdgeRows, nRows)
        float topVol = 0.0
        float botVol = 0.0
        for e = 0 to edgeRows - 1
            topVol += array.get(rowsTotal, nRows - 1 - e)
            botVol += array.get(rowsTotal, e)
        float edgeBase = pocVol * edgeRows
        bool poorHigh = edgeBase > 0 and topVol / edgeBase >= poorEdgeRatioPct / 100.0
        bool poorLow = edgeBase > 0 and botVol / edgeBase >= poorEdgeRatioPct / 100.0

        string domSession = "NA"
        float domShare = na
        if showSessionContribution
            float sessTotal = asiaVol + londonVol + nyVol + otherVol
            float domVol = asiaVol
            domSession := "Asia"
            if londonVol > domVol
                domVol := londonVol
                domSession := "London"
            if nyVol > domVol
                domVol := nyVol
                domSession := "New York"
            if otherVol > domVol
                domVol := otherVol
                domSession := "Other"
            domShare := sessTotal > 0 ? domVol / sessTotal * 100.0 : na

        int bestScoreOut = na
        string bestTextOut = "NA"
        float bestPriceOut = na
        if showConfluence
            array<float> cPrices = array.new_float()
            array<string> cNames = array.new_string()
            array<float> cWeights = array.new_float()
            f_add_level(cPrices, cNames, cWeights, pocPrice, "POC", 2.0)
            f_add_level(cPrices, cNames, cWeights, vahPrice, "VAH", 1.4)
            f_add_level(cPrices, cNames, cWeights, valPrice, "VAL", 1.4)
            f_add_level(cPrices, cNames, cWeights, nearestHvn, "HVN", 1.5)
            f_add_level(cPrices, cNames, cWeights, nearestLvn, "LVN", 1.3)
            f_add_level(cPrices, cNames, cWeights, periodOpen, "Open", 1.0)
            f_add_level(cPrices, cNames, cWeights, periodClose, "Close", 1.2)
            f_add_level(cPrices, cNames, cWeights, poorHigh ? profHi : na, "Poor H", 1.3)
            f_add_level(cPrices, cNames, cWeights, poorLow ? profLo : na, "Poor L", 1.3)
            f_add_level(cPrices, cNames, cWeights, profHi, "PH", 0.8)
            f_add_level(cPrices, cNames, cWeights, profLo, "PL", 0.8)
            f_add_level(cPrices, cNames, cWeights, f_nearest_naked(pocPrice), "Naked POC", 1.8)
            [cPocNow, cVahNow, cValNow] = f_composite_calc()
            f_add_level(cPrices, cNames, cWeights, cPocNow, "cPOC", 1.8)
            f_add_level(cPrices, cNames, cWeights, cVahNow, "cVAH", 1.2)
            f_add_level(cPrices, cNames, cWeights, cValNow, "cVAL", 1.2)

            float tol = math.max(nz(atrConfluence, syminfo.mintick * 50.0) * confluenceAtrMult, syminfo.mintick * 5.0)
            array<int> usedIdx = array.new_int()
            for z = 0 to confluenceMaxZones - 1
                float bestScore = 0.0
                int bestIdx = na
                string bestText = ""
                int bestCount = 0
                if array.size(cPrices) > 0
                    for i = 0 to array.size(cPrices) - 1
                        bool skip = false
                        if array.size(usedIdx) > 0
                            for u = 0 to array.size(usedIdx) - 1
                                if math.abs(array.get(cPrices, i) - array.get(cPrices, array.get(usedIdx, u))) <= tol
                                    skip := true
                        if not skip
                            float sumW = 0.0
                            int cnt = 0
                            string txt = ""
                            for j = 0 to array.size(cPrices) - 1
                                if math.abs(array.get(cPrices, j) - array.get(cPrices, i)) <= tol
                                    sumW += array.get(cWeights, j)
                                    cnt += 1
                                    txt += (txt == "" ? "" : " + ") + array.get(cNames, j)
                            float score = math.min(100.0, sumW * 13.0)
                            if cnt >= confluenceMinLevels and score > bestScore
                                bestScore := score
                                bestIdx := i
                                bestText := txt
                                bestCount := cnt
                if not na(bestIdx) and bestScore >= confluenceMinScore
                    float bp = array.get(cPrices, bestIdx)
                    int sc = int(math.round(bestScore))
                    line cl = line.new(drawLeft, bp, confluenceRight, bp, xloc = xloc.bar_index, extend = levelExt, color = confluenceColor, width = 2, style = line.style_solid)
                    array.push(lineArr, cl)
                    label cb = label.new(f_x_label_extra(confluenceRight, 2), bp, "CONFLUENCE " + str.tostring(sc) + "%\n" + bestText, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(confluenceColor, 15), textcolor = color.black, size = size.small, style = label.style_label_left)
                    array.push(labelArr, cb)
                    array.push(usedIdx, bestIdx)
                    if na(bestScoreOut) or sc > bestScoreOut
                        bestScoreOut := sc
                        bestTextOut := bestText
                        bestPriceOut := bp

        int afterB = array.size(boxArr)
        int afterL = array.size(lineArr)
        int afterT = array.size(labelArr)
        int afterF = array.size(fillArr)
        outB := afterB - beforeB
        outL := afterL - beforeL
        outT := afterT - beforeT
        outF := afterF - beforeF
        outShape := shape
        outDeltaPoc := deltaPoc
        outVoidTop := firstVoidTop
        outVoidBot := firstVoidBot
        outPoorH := poorHigh ? 1 : 0
        outPoorL := poorLow ? 1 : 0
        outVwap := vwap
        outIbHigh := ibHigh
        outIbLow := ibLow
        outDomSession := domSession
        outDomShare := domShare
        outConfScore := bestScoreOut
        outConfText := bestTextOut
        outConfPrice := bestPriceOut

    [outB, outL, outT, outF, outShape, outDeltaPoc, outVoidTop, outVoidBot, outPoorH, outPoorL, outVwap, outIbHigh, outIbLow, outDomSession, outDomShare, outConfScore, outConfText, outConfPrice]

var int periodStartBar = na
var int confirmedCount = 0
var int lastDrawnBoxes = 0
var int lastDrawnLines = 0
var int lastDrawnLabels = 0
var int lastDrawnFills = 0
var float prevConfirmedPoc = na
var int prevConfirmedRight = na

if na(periodStartBar)
    periodStartBar := bar_index

bool newVpPeriod = validChartTf and timeframe.change(vpTf)

if newVpPeriod and barstate.isconfirmed and not na(periodStartBar) and bar_index > periodStartBar
    int rawLen = bar_index - periodStartBar
    int len = f_safe_profile_len(rawLen, 1)
    int rightBar = bar_index - 1
    int leftBar = math.max(periodStartBar, rightBar - len + 1)
    bool drawWindowOk = f_safe_draw_left(leftBar)
    if drawWindowOk
        [bc, lc, tc, fc, profPoc, profVah, profVal, profVol, profHi, profLo, profOpen, profClose] = f_drawProfile(leftBar, rightBar, len, 1, vpTag, histBoxes, histLines, histLabels, histFills)
        if bc + lc + tc + fc > 0
            [abc, alc, atc, afc, advShape, advDeltaPoc, advVoidTop, advVoidBot, advPoorH, advPoorL, advVwap, advIbHigh, advIbLow, advDomSession, advDomShare, advConfScore, advConfText, advConfPrice] = f_drawAdvanced(leftBar, rightBar, len, 1, vpTag, histBoxes, histLines, histLabels, histFills, profPoc, profVah, profVal, profHi, profLo, profOpen, profClose)
            bc += abc
            lc += alc
            tc += atc
            fc += afc
    
            string newMigration = not na(prevConfirmedPoc) and not na(profPoc) ? profPoc > prevConfirmedPoc ? "Rising" : profPoc < prevConfirmedPoc ? "Falling" : "Flat" : "NA"
            evPocMigrationChange := apLastPocMigration != "NA" and newMigration != "NA" and newMigration != apLastPocMigration
            apLastPocMigration := newMigration
            apLastValueRelation := f_value_relation_dash(profVah, profVal, apLastVah, apLastVal)
            apPrevPocDash := apLastPoc
            apPrevVahDash := apLastVah
            apPrevValDash := apLastVal
            apLastPoc := profPoc
            apLastVah := profVah
            apLastVal := profVal
            apLastHigh := profHi
            apLastLow := profLo
            apLastOpen := profOpen
            apLastClose := profClose
            apLastShape := advShape
            apLastDeltaPoc := advDeltaPoc
            apLastVoidTop := advVoidTop
            apLastVoidBot := advVoidBot
            apLastPoorHigh := advPoorH == 1
            apLastPoorLow := advPoorL == 1
            apLastVwap := advVwap
            apLastIbHigh := advIbHigh
            apLastIbLow := advIbLow
            apLastDominantSession := advDomSession
            apLastDominantShare := advDomShare
            apLastConfluenceScore := advConfScore
            apLastConfluenceText := advConfText
            apLastConfluencePrice := advConfPrice
    
            if showNakedAdvanced and not na(profPoc)
                bool existsNaked = false
                if array.size(nakedPricesAdv) > 0
                    for nk = 0 to array.size(nakedPricesAdv) - 1
                        if math.abs(array.get(nakedPricesAdv, nk) - profPoc) <= syminfo.mintick * 5
                            existsNaked := true
                if not existsNaked
                    array.unshift(nakedPricesAdv, profPoc)
                    array.unshift(nakedStartsAdv, rightBar)
                    array.unshift(nakedTouchesAdv, 0)
                    array.unshift(nakedLastTouchAdv, na)
                    array.unshift(nakedBrokenAdv, false)
                    while array.size(nakedPricesAdv) > maxNakedAdvanced
                        array.pop(nakedPricesAdv)
                        array.pop(nakedStartsAdv)
                        array.pop(nakedTouchesAdv)
                        array.pop(nakedLastTouchAdv)
                        array.pop(nakedBrokenAdv)
    
            if showPocMigration and not na(prevConfirmedPoc) and not na(profPoc) and not na(prevConfirmedRight)
                line mig = line.new(prevConfirmedRight, prevConfirmedPoc, rightBar, profPoc, xloc = xloc.bar_index, extend = extend.none, color = color.new(f_colPoc(), 25), width = 2, style = line.style_solid)
                array.push(histLines, mig)
                lc += 1
                if showStats
                    label migLb = label.new(rightBar, profPoc, vpTag + " POC MIG", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(f_colPoc(), 70), textcolor = f_colText(), size = size.tiny, style = label.style_label_left)
                    array.push(histLabels, migLb)
                    tc += 1
            prevConfirmedPoc := profPoc
            prevConfirmedRight := rightBar
    
            array.push(sumPocs, profPoc)
            array.push(sumVahs, profVah)
            array.push(sumVals, profVal)
            array.push(sumVols, profVol)
            array.push(sumRights, rightBar)
            while array.size(sumPocs) > 100
                array.shift(sumPocs)
                array.shift(sumVahs)
                array.shift(sumVals)
                array.shift(sumVols)
                array.shift(sumRights)
    
            array.push(histBoxCounts, bc)
            array.push(histLineCounts, lc)
            array.push(histLabelCounts, tc)
            array.push(histFillCounts, fc)
            confirmedCount += 1
            lastDrawnBoxes := bc
            lastDrawnLines := lc
            lastDrawnLabels := tc
            lastDrawnFills := fc
            f_trim_history()
    periodStartBar := bar_index

if barstate.islast
    f_clear_fills(liveFills)
    f_clear_boxes(liveBoxes)
    f_clear_lines(liveLines)
    f_clear_labels(liveLabels)

    if showDeveloping and validChartTf and not na(periodStartBar) and bar_index >= periodStartBar
        int rawLiveLen = bar_index - periodStartBar + 1
        int liveLen = f_safe_profile_len(rawLiveLen, 0)
        int liveRight = bar_index
        int liveLeft = math.max(periodStartBar, liveRight - liveLen + 1)
        if f_safe_draw_left(liveLeft)
            [lbc, llc, ltc, lfc, lpoc, lvah, lval, lvol, lhi, llo, lopen, lclose] = f_drawProfile(liveLeft, liveRight, liveLen, 0, vpTag + " LIVE", liveBoxes, liveLines, liveLabels, liveFills)

evNakedTouch := false
if showNakedAdvanced and array.size(nakedPricesAdv) > 0
    int nki = array.size(nakedPricesAdv) - 1
    while nki >= 0
        float np = array.get(nakedPricesAdv, nki)
        int ns = array.get(nakedStartsAdv, nki)
        bool touched = bar_index > ns and high >= np and low <= np
        bool crossed = bar_index > ns and ((close[1] < np and close > np) or (close[1] > np and close < np))
        if touched
            evNakedTouch := true
            if array.get(nakedLastTouchAdv, nki) != bar_index
                array.set(nakedTouchesAdv, nki, array.get(nakedTouchesAdv, nki) + 1)
                array.set(nakedLastTouchAdv, nki, bar_index)
        if crossed
            array.set(nakedBrokenAdv, nki, true)
        bool del = nakedDeleteMode == "On Touch" and touched or nakedDeleteMode == "On Cross" and crossed
        if del
            array.remove(nakedPricesAdv, nki)
            array.remove(nakedStartsAdv, nki)
            array.remove(nakedTouchesAdv, nki)
            array.remove(nakedLastTouchAdv, nki)
            array.remove(nakedBrokenAdv, nki)
        nki -= 1

if barstate.islast
    f_clear_lines(nakedLinesAdv)
    f_clear_labels(nakedLabelsAdv)
    if showNakedAdvanced and array.size(nakedPricesAdv) > 0
        for i = 0 to array.size(nakedPricesAdv) - 1
            float np = array.get(nakedPricesAdv, i)
            int ns = array.get(nakedStartsAdv, i)
            int touches = array.get(nakedTouchesAdv, i)
            bool broken = array.get(nakedBrokenAdv, i)
            int age = bar_index - ns
            string st = f_status_naked(touches, age, broken)
            if f_should_show_naked(st) and f_safe_draw_left(ns)
                color nc = f_color_naked(st)
                int alpha = st == "Fresh" ? 20 : st == "Tested" ? 35 : st == "Respected" ? 45 : 88
                int width = st == "Fresh" ? 2 : st == "Respected" ? 2 : 1
                int nakedRight = f_x_right(bar_index, nakedExtendBars)
                line nl = line.new(ns, np, nakedRight, np, xloc = xloc.bar_index, extend = extend.none, color = color.new(nc, alpha), width = width, style = line.style_dashed)
                array.push(nakedLinesAdv, nl)
                label nlb = label.new(nakedRight, np, "nPOC " + st + "\nT" + str.tostring(touches) + " A" + str.tostring(age), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(nc, 78), textcolor = f_colText(), size = size.tiny, style = label.style_label_left)
                array.push(nakedLabelsAdv, nlb)

evPocTouch := not na(apLastPoc) and high >= apLastPoc and low <= apLastPoc and not (high[1] >= apLastPoc and low[1] <= apLastPoc)
evAcceptedAboveVah := not na(apLastVah) and ta.lowest(close, signalAcceptBars) > apLastVah and close[signalAcceptBars] <= apLastVah
evAcceptedBelowVal := not na(apLastVal) and ta.highest(close, signalAcceptBars) < apLastVal and close[signalAcceptBars] >= apLastVal
evRejectedVah := not na(apLastVah) and high > apLastVah and close < apLastVah and close[1] <= apLastVah
evRejectedVal := not na(apLastVal) and low < apLastVal and close > apLastVal and close[1] >= apLastVal
evFailedAuction := (not na(apLastVah) and high > apLastVah and close < apLastVal) or (not na(apLastVal) and low < apLastVal and close > apLastVah)
evPocReclaim := not na(apLastPoc) and close > apLastPoc and close[1] <= apLastPoc
evPocLost := not na(apLastPoc) and close < apLastPoc and close[1] >= apLastPoc
evValDefense := not na(apLastVal) and low <= apLastVal and close > apLastVal
evLvgFill := not na(apLastVoidTop) and not na(apLastVoidBot) and high >= apLastVoidBot and low <= apLastVoidTop and not (high[1] >= apLastVoidBot and low[1] <= apLastVoidTop)
evPoorHighRepaired := apLastPoorHigh and not na(apLastHigh) and high >= apLastHigh
evPoorLowRepaired := apLastPoorLow and not na(apLastLow) and low <= apLastLow
evConfluenceTouch := not na(apLastConfluencePrice) and high >= apLastConfluencePrice and low <= apLastConfluencePrice and not (high[1] >= apLastConfluencePrice and low[1] <= apLastConfluencePrice)

f_drawCompositeLevels() =>
    f_clear_lines(compLines)
    f_clear_labels(compLabels)
    if showComposite and compositeDisplay != "Off" and array.size(sumPocs) >= 2
        [cPoc, cVah, cVal] = f_composite_calc()
        if not na(cPoc) and not na(cVah) and not na(cVal)
            int lastRight = array.size(sumRights) > 0 ? array.get(sumRights, array.size(sumRights) - 1) : bar_index
            int x1 = lastRight
            int x2 = lastRight + compositeNearBars
            bool compDrawOk = f_safe_draw_left(x1)
            if compDrawOk
                int labelX = x2 + 1
                color cPocCol = color.new(compositeColor, compositeLineAlpha)
                color cVaCol = color.new(compositeVaColor, math.min(compositeLineAlpha + 10, 95))
                line cp = line.new(x1, cPoc, x2, cPoc, xloc = xloc.bar_index, extend = extend.none, color = cPocCol, width = 1, style = line.style_dotted)
                line ch = line.new(x1, cVah, x2, cVah, xloc = xloc.bar_index, extend = extend.none, color = cVaCol, width = 1, style = line.style_dashed)
                line cv = line.new(x1, cVal, x2, cVal, xloc = xloc.bar_index, extend = extend.none, color = cVaCol, width = 1, style = line.style_dashed)
                array.push(compLines, cp)
                array.push(compLines, ch)
                array.push(compLines, cv)
                if showStats and showCompositeLabels
                    label cpl = label.new(labelX, cPoc, "cPOC", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(compositeColor, 72), textcolor = f_colText(), size = size.tiny, style = label.style_label_left, tooltip = "Composite POC: " + str.tostring(cPoc, format.mintick))
                    label chl = label.new(labelX, cVah, "cVAH", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(compositeVaColor, 82), textcolor = f_colText(), size = size.tiny, style = label.style_label_left, tooltip = "Composite VAH: " + str.tostring(cVah, format.mintick))
                    label cvl = label.new(labelX, cVal, "cVAL", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(compositeVaColor, 82), textcolor = f_colText(), size = size.tiny, style = label.style_label_left, tooltip = "Composite VAL: " + str.tostring(cVal, format.mintick))
                    array.push(compLabels, cpl)
                    array.push(compLabels, chl)
                    array.push(compLabels, cvl)

if barstate.islast
    f_drawCompositeLevels()

if showAuctionDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 15, border_width = 1, border_color = color.new(#263238, 60), frame_width = 1, frame_color = color.new(#263238, 30))
    string tfWarn = not validChartTf ? "CHART>VP" : "OK"

    string priceState = na(apLastPoc) or na(apLastVah) or na(apLastVal) ? "NA" : close > apLastVah ? "Above VAH" : close < apLastVal ? "Below VAL" : close > apLastPoc ? "Inside VA / Above POC" : close < apLastPoc ? "Inside VA / Below POC" : "At POC"
    string auctionState = "NA"
    if not na(apLastPoc) and not na(apLastVah) and not na(apLastVal)
        auctionState := close > apLastVah ? "Bullish acceptance" : close < apLastVal ? "Bearish acceptance" : evRejectedVah ? "VAH rejection" : evRejectedVal ? "VAL defense" : "Balanced / Rotation"
    float nearestNaked = f_nearest_naked(close)
    string targetText = not na(nearestNaked) ? "nPOC " + str.tostring(nearestNaked, format.mintick) : not na(apLastPoc) ? "POC " + str.tostring(apLastPoc, format.mintick) : "NA"
    string riskZone = "NA"
    if not na(apLastVoidTop) and not na(apLastVoidBot)
        riskZone := close < apLastVoidBot ? "LVG above" : close > apLastVoidTop ? "LVG below" : "Inside LVG"
    else if apLastPoorHigh and close < apLastHigh
        riskZone := "Poor High above"
    else if apLastPoorLow and close > apLastLow
        riskZone := "Poor Low below"
    string pocText = not na(apLastPoc) ? str.tostring(apLastPoc, format.mintick) : "NA"
    string vaText = not na(apLastVah) and not na(apLastVal) ? "H " + str.tostring(apLastVah, format.mintick) + " / L " + str.tostring(apLastVal, format.mintick) : "NA"
    string vwapText = not na(apLastVwap) ? str.tostring(apLastVwap, format.mintick) : "NA"
    string ibText = not na(apLastIbHigh) and not na(apLastIbLow) ? "H " + str.tostring(apLastIbHigh, format.mintick) + " / L " + str.tostring(apLastIbLow, format.mintick) : "NA"

    color bgHdr = color.new(#0D1B2A, 0)
    color bgVal = color.new(#0D1B2A, 30)
    color txtHdr = #607D8B
    color txtVal = f_colText()

    table.cell(dash, 0, 0, "📊 volume profile", bgcolor = color.new(f_colPoc(), 30), text_color = color.black, text_size = size.tiny)
    table.cell(dash, 1, 0, "D/W/M", bgcolor = color.new(f_colPoc(), 30), text_color = color.black, text_size = size.tiny)
    table.cell(dash, 0, 1, "🕒 MODE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 1, vpTag + " / " + tfWarn, bgcolor = bgVal, text_color = tfWarn == "OK" ? txtVal : color.orange, text_size = size.tiny)
    table.cell(dash, 0, 2, "💰 PRICE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 2, priceState, bgcolor = bgVal, text_color = priceState == "Above VAH" ? f_palBull(3) : priceState == "Below VAL" ? f_palBear(3) : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 3, "⚖️ AUCTION", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 3, auctionState, bgcolor = bgVal, text_color = str.contains(auctionState, "Bullish") ? f_palBull(3) : str.contains(auctionState, "Bearish") ? f_palBear(3) : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 4, "📦 VALUE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 4, apLastValueRelation, bgcolor = bgVal, text_color = txtVal, text_size = size.tiny)
    table.cell(dash, 0, 5, "🧲 POC", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 5, pocText, bgcolor = bgVal, text_color = not na(apLastPoc) ? f_colPoc() : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 6, "📐 VAH / VAL", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 6, vaText, bgcolor = bgVal, text_color = txtVal, text_size = size.tiny)
    table.cell(dash, 0, 7, "🧭 POC MIG", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 7, apLastPocMigration, bgcolor = bgVal, text_color = apLastPocMigration == "Rising" ? f_palBull(3) : apLastPocMigration == "Falling" ? f_palBear(3) : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 8, "🧬 SHAPE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 8, apLastShape, bgcolor = bgVal, text_color = txtVal, text_size = size.tiny)
    table.cell(dash, 0, 9, "🎯 TARGET", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 9, targetText, bgcolor = bgVal, text_color = txtVal, text_size = size.tiny)
    table.cell(dash, 0, 10, "⚠️ RISK", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 10, riskZone, bgcolor = bgVal, text_color = riskZone == "NA" ? txtVal : color.orange, text_size = size.tiny)
    table.cell(dash, 0, 11, "🌍 SESSION", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 11, apLastDominantSession + (not na(apLastDominantShare) ? " " + str.tostring(apLastDominantShare, "#.0") + "%" : ""), bgcolor = bgVal, text_color = txtVal, text_size = size.tiny)
    table.cell(dash, 0, 12, "🔥 CONFLUENCE", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 12, not na(apLastConfluenceScore) ? str.tostring(apLastConfluenceScore) + "% " + apLastConfluenceText : "NA", bgcolor = bgVal, text_color = not na(apLastConfluenceScore) and apLastConfluenceScore >= confluenceMinScore ? confluenceColor : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 13, "〽️ VWAP", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 13, vwapText, bgcolor = bgVal, text_color = not na(apLastVwap) ? vwapColor : txtVal, text_size = size.tiny)
    table.cell(dash, 0, 14, "📏 IB", bgcolor = bgHdr, text_color = txtHdr, text_size = size.tiny)
    table.cell(dash, 1, 14, ibText, bgcolor = bgVal, text_color = not na(apLastIbHigh) and not na(apLastIbLow) ? ibColor : txtVal, text_size = size.tiny)

alertcondition(enableVpAlerts and evPocTouch, "volume profil mtf: POC touch", "Price touched the last confirmed POC.")
alertcondition(enableVpAlerts and evAcceptedAboveVah, "volume profil mtf: Accepted above VAH", "Price accepted above the last confirmed VAH.")
alertcondition(enableVpAlerts and evAcceptedBelowVal, "volume profil mtf: Accepted below VAL", "Price accepted below the last confirmed VAL.")
alertcondition(enableVpAlerts and evRejectedVah, "volume profil mtf: Rejected VAH", "Price rejected the last confirmed VAH.")
alertcondition(enableVpAlerts and evRejectedVal, "volume profil mtf: VAL defense", "Price defended the last confirmed VAL.")
alertcondition(enableVpAlerts and evFailedAuction, "volume profil mtf: Failed auction", "Price created a failed auction around the last confirmed value area.")
alertcondition(enableVpAlerts and evPocReclaim, "volume profil mtf: POC reclaim", "Price reclaimed the last confirmed POC.")
alertcondition(enableVpAlerts and evPocLost, "volume profil mtf: POC lost", "Price lost the last confirmed POC.")
alertcondition(enableVpAlerts and evNakedTouch, "volume profil mtf: Naked POC touch", "Price touched an active naked POC.")
alertcondition(enableVpAlerts and evLvgFill, "volume profil mtf: LVG fill", "Price filled/touched the last detected low-volume gap.")
alertcondition(enableVpAlerts and (evPoorHighRepaired or evPoorLowRepaired), "volume profil mtf: Poor high/low repaired", "Price repaired a poor high or poor low.")
alertcondition(enableVpAlerts and evPocMigrationChange, "volume profil mtf: POC migration changed", "Confirmed POC migration changed direction.")
alertcondition(enableVpAlerts and evConfluenceTouch, "volume profil mtf: Confluence zone touch", "Price touched the strongest confluence zone.")
````
