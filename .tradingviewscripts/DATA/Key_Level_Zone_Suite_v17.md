<!-- tradingview-pine-id: PUB;53509f8640714fc9a88c6484c500c45e -->
<!-- tradingviewscripts-format: 1 -->
# Key Level Zone Suite v1.7

Source: https://www.tradingview.com/script/Hxmq6GVn-Key-Levels-Zone-v1-5/

## Description

KEY LEVEL ZONE SUITE v1.5

The Key Level Zone Suite is a multi-timeframe market-structure indicator designed to organize important price levels into customizable zones instead of single horizontal lines.

The indicator combines session levels, daily reference levels, supply and demand, repeated-touch support and resistance, and confirmed swing points in one clean system. Every category can be independently enabled, customized, limited, and managed after price breaks through it.

Its purpose is to help traders identify areas where price may react, reject, consolidate, break, or reverse—while reducing chart clutter on lower timeframes.

FEATURES

SESSION OPEN ZONES

The indicator can display the exact opening prices of:

• Asia
• London
• New York

Each opening price is expanded into an adjustable zone. Opening prices are calculated using internal 1-minute data, helping maintain accurate session opens when the indicator is viewed on higher-timeframe charts.

Each session-open zone includes independent controls for:

• Visibility
• Session time
• Zone thickness in ticks
• Horizontal projection length
• Fill and border colors
• Maximum number of zones
• Text visibility
• Broken-zone behavior

Session-open zones are disabled by default but can be enabled individually.

SESSION HIGH AND LOW ZONES

The indicator can display completed high and low zones from the:

• Asia session
• London session
• New York session

For each session, traders can choose:

• Today
• Yesterday
• Both

Today’s high and low are added only after the selected session finishes. This prevents a developing session range from being mistaken for a finalized level.

Older session ranges are automatically cleared, preventing multiple days of session highs and lows from accumulating across the chart.

DAILY AND WEEKLY KEY LEVELS

The indicator includes:

• Daily Open
• Previous-Day High
• Previous-Day Low
• Previous Monday High
• Previous Monday Low

The Daily Open is calculated from the customizable trading-day session. By default, it uses the futures-style trading day beginning at 6:00 PM New York time.

Only the two newest Daily Open zones are retained, representing the current trading day and the previous trading day.

Previous-Day High and Low zones can be enabled when needed, with an adjustable number of previous-day sets.

The Monday levels represent the completed high and low from the latest Monday. Only the newest Monday pair is retained, so older Monday zones do not fill the chart.

SUPPLY AND DEMAND ZONES

Supply and demand zones are created from confirmed pivot points that produce a required move away from the area.

A supply zone requires:

• A confirmed pivot high
• A bearish move away from the pivot
• A move meeting the selected ATR-strength requirement

A demand zone requires:

• A confirmed pivot low
• A bullish move away from the pivot
• A move meeting the selected ATR-strength requirement

Supply and demand have their own calculation timeframe. This allows a trader to display zones from one selected timeframe while changing the chart timeframe.

For example, supply and demand can remain calculated from the 2-hour chart while the trader moves down to a 5-minute, 2-minute, or 1-minute execution chart.

Adjustable settings include:

• Calculation timeframe
• Pivot strength
• ATR length
• Required ATR move away
• Zone thickness
• Projection length
• Supply and demand colors
• Maximum supply zones
• Maximum demand zones
• Broken-zone behavior
• Text visibility

The default profile displays a maximum of four supply zones and four demand zones.

SUPPORT AND RESISTANCE ZONES

Support and resistance zones are created from repeated confirmed pivots near the same price.

A zone is displayed only after the required number of touches occurs within the selected tick tolerance.

Resistance is formed from matching pivot highs, while support is formed from matching pivot lows.

Adjustable settings include:

• Independent calculation timeframe
• Pivot bars to the left and right
• Minimum number of touches
• Matching tolerance in ticks
• Zone thickness
• Projection length
• Maximum support and resistance zones
• Colors and transparency
• Broken-zone behavior
• Text visibility

Because support and resistance use an independent source timeframe, their zones remain consistent when changing chart timeframes.

SWING-HIGH AND SWING-LOW ZONES

Confirmed swing highs and swing lows can also be displayed as zones.

These levels use adjustable pivot confirmation and an independent calculation timeframe.

Swing zones are disabled by default to keep the starting chart clean. They can be enabled when a trader wants additional market-structure levels.

MULTI-TIMEFRAME ZONES

Supply and demand, support and resistance, and swing zones each have independent calculation timeframes.

The selected source timeframe controls where the zone is created—not the current chart timeframe.

For example:

• Set supply and demand to 120 minutes
• Set support and resistance to 2 minutes
• View the chart on 1, 2, 5, or 15 minutes

The supply and demand zones will continue to represent the 2-hour structure, while support and resistance will continue to represent the 2-minute structure.

For multi-timeframe structural zones, projection length is measured using bars from the selected calculation timeframe.

ZONE-BREAK CONFIRMATION

A zone can be considered broken using either:

• Close
• Wick

Close mode waits for a candle to close beyond the zone and break buffer. This is the more conservative setting and helps prevent a temporary wick from invalidating a zone.

Wick mode considers the zone broken when the candle’s high or low crosses completely through the zone and buffer.

An adjustable break buffer, measured in ticks, can help prevent small overshoots or liquidity sweeps from immediately invalidating a level.

BROKEN-ZONE OPTIONS

Every category includes independent behavior for zones that are broken:

DELETE

The zone is completely removed from the chart.

FREEZE

The zone stops extending at the candle that broke it and remains visible for review.

SHORTEN

The zone stops actively extending and keeps only the selected number of bars after the break.

For example, an active zone projecting 20 bars ahead can be shortened to 10 bars after it breaks.

KEEP

The zone stops actively updating but retains its existing endpoint.

Broken zones can also use a separate fill color so traders can distinguish invalidated levels from active zones.

ZONE RETENTION AND CHART CLEANUP

The indicator contains several controls designed to keep lower-timeframe charts organized:

• Adjustable calendar-day history
• Global maximum number of zones
• Independent limits for each structural category
• Only two Daily Opens retained
• Only the latest Monday High and Low retained
• Today, Yesterday, or Both session-range selection
• Independent text switches
• Automatic removal of older zones

The default history is seven calendar days.

When a structural category exceeds its selected maximum, the indicator removes broken zones first. If no broken zones remain, it removes the oldest active zone.

This helps preserve the newest and most relevant active areas.

ZONE TEXT CONTROLS

Zone labels can be controlled using:

• A master text switch
• Session-open text
• Session high/low text
• Daily and weekly level text
• Supply and demand text
• Support and resistance text
• Swing-zone text

Turning off the text does not remove the zones. It only hides their labels, allowing for a cleaner visual layout.

ALERTS

The indicator can generate an alert whenever an active zone is broken.

To use this feature:

1. Enable “Alert when a zone breaks” in the indicator settings.
2. Open TradingView’s alert window.
3. Select the Key Level Zone Suite.
4. Choose “Any alert() function call.”
5. Select the desired alert frequency and notification method.

HOW TO USE THE INDICATOR

1. SET THE CORRECT TIMEZONE AND SESSIONS

Begin by confirming the session timezone. The default is America/New_York.

The default session times are designed around futures trading:

• Asia: 6:00 PM–3:00 AM
• London: 3:00 AM–9:30 AM
• New York: 9:30 AM–4:59 PM
• Trading day: 6:00 PM–5:00 PM

Session behavior can vary by market, exchange, daylight-saving changes, and personal trading plan. Adjust these values when trading instruments that use different session schedules.

2. CHOOSE THE LEVELS YOU NEED

Avoid enabling every available zone at once.

A clean intraday setup can include:

• Asia High and Low
• London High and Low
• Yesterday’s New York High and Low
• Current and previous Daily Open
• Previous Monday High and Low
• Higher-timeframe supply and demand
• Lower-timeframe support and resistance

Swing zones and session opens can be added when the trading plan specifically uses them.

3. USE HIGHER-TIMEFRAME SUPPLY AND DEMAND FOR CONTEXT

The default supply and demand timeframe is 2 hours.

These zones can be used to identify broader areas where a significant reaction may occur. Traders can then move to a lower timeframe and look for entry confirmation inside or near the higher-timeframe zone.

Supply can act as a potential resistance area. Demand can act as a potential support area.

These areas should not automatically be treated as entry signals.

4. USE SESSION LEVELS FOR INTRADAY LIQUIDITY

Session highs and lows often represent important intraday liquidity areas.

Watch how price behaves when it approaches:

• Asia High or Low
• London High or Low
• Previous New York High or Low
• Daily Open
• Previous Monday High or Low

Price may reject the level, sweep beyond it and return, consolidate inside it, or break through it with momentum.

5. LOOK FOR CONFLUENCE

A zone becomes more meaningful when multiple independent factors appear near the same price.

Examples include:

• London Low overlapping a demand zone
• Asia High overlapping resistance
• Daily Open inside a support zone
• Previous Monday High near supply
• A session liquidity sweep followed by a market-structure shift

Overlapping zones do not guarantee a trade, but they can help identify areas that deserve closer attention.

6. WAIT FOR PRICE CONFIRMATION

The indicator identifies areas of interest; it does not produce automatic buy or sell signals.

Possible confirmation can include:

• Strong rejection candle
• Hammer or shooting-star formation
• Engulfing candle
• Liquidity sweep and close back inside the zone
• Break of structure
• Change of character
• Increase in volume
• Delta shift
• Retest after a confirmed breakout

Entering only because price touches a zone can expose the trader to levels that are being broken rather than respected.

7. PLACE RISK OUTSIDE THE ZONE

When using a zone for an entry, the invalidation point is commonly placed beyond the opposite side of the zone with an additional tick buffer.

The exact stop distance should account for:

• Instrument volatility
• Zone thickness
• Current ATR
• Session conditions
• The trader’s maximum allowed risk

A wider zone requires different risk management than a narrow zone.

8. USE THE NEXT OPPOSING ZONE AS A REFERENCE

Potential targets can be based on the next opposing area.

For a long setup, possible references include:

• Resistance
• Supply
• Session High
• Previous-Day High
• Previous Monday High

For a short setup, possible references include:

• Support
• Demand
• Session Low
• Previous-Day Low
• Previous Monday Low

Always confirm that the available distance supports the minimum risk-to-reward ratio required by the trading plan.

DEFAULT SETUP

The included default profile is designed to provide useful structure without displaying every possible level.

The main defaults include:

• Seven calendar days of history
• Maximum of 50 total zones
• Close-based break confirmation
• One-tick break buffer
• Session opening zones disabled
• Asia High and Low set to Today
• London High and Low set to Today
• New York High and Low set to Yesterday
• Daily Open enabled
• Previous-Day High and Low disabled
• Previous Monday High and Low enabled
• Supply and demand enabled on the 2-hour timeframe
• Maximum of four supply and four demand zones
• Support and resistance enabled on the 2-minute timeframe
• Maximum of two support and two resistance zones
• Swing zones disabled
• Supply, demand, support, resistance, and swing text hidden

IMPORTANT NOTES

Confirmed pivot-based zones require bars to the right of the pivot. This means supply, demand, support, resistance, and swing zones appear only after their pivot conditions have been confirmed.

Session highs and lows appear after their session finishes because the final high and low cannot be known while the session is still active.

The indicator is best used as a mapping and confluence tool alongside price action, market structure, volume, and disciplined risk management.

No zone guarantees a reversal. Strong momentum can break through any level, and a broken zone does not automatically confirm that price will continue in the same direction.

This indicator is intended for educational and analytical purposes only. It does not provide financial advice or guarantee future trading performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator("Key Level Zone Suite v1.7", shorttitle="Key Zone Suite", overlay=true, max_boxes_count=500, max_bars_back=5000)

//=============================================================================
// GENERAL SETTINGS
//=============================================================================
grpGeneral = "01. General"
zoneTz        = input.string("America/New_York", "Session timezone", group=grpGeneral)
showText      = input.bool(true, "Master zone-text switch", group=grpGeneral)
textColor     = input.color(color.white, "Text color", group=grpGeneral)
maxZones      = input.int(50, "Maximum zones on chart", minval=20, maxval=450, group=grpGeneral)
zoneLookbackDays = input.int(7, "Keep zones from last (calendar days)", minval=1, maxval=365, group=grpGeneral)
breakBasis    = input.string("Close", "Break confirmation", options=["Close", "Wick"], group=grpGeneral)
breakBuffer   = input.int(1, "Break buffer (ticks)", minval=0, maxval=10000, group=grpGeneral)
enableAlerts  = input.bool(true, "Alert when a zone breaks", group=grpGeneral)

// A zone's active length continually projects this many bars ahead.
// When broken, Delete removes it, Freeze stops it on the break bar,
// Shorten preserves only the selected number of bars after the break,
// and Keep stops the existing box without changing its current endpoint.

//=============================================================================
// SESSION OPEN ZONES
//=============================================================================
grpOpen = "02. Session Open Zones"
showOpenText   = input.bool(false, "Show session-open text", group=grpOpen)
showAsiaOpen   = input.bool(false, "Asia open", inline="ao", group=grpOpen)
asiaSession    = input.session("1800-0300", "Session", inline="ao", group=grpOpen)
asiaOpenColor  = input.color(color.new(color.aqua, 76), "Color", inline="aoc", group=grpOpen)
asiaOpenBorder = input.color(color.aqua, "Border", inline="aoc", group=grpOpen)

showLondonOpen   = input.bool(false, "London open", inline="lo", group=grpOpen)
londonSession    = input.session("0300-0930", "Session", inline="lo", group=grpOpen)
londonOpenColor  = input.color(color.new(color.aqua, 82), "Color", inline="loc", group=grpOpen)
londonOpenBorder = input.color(color.aqua, "Border", inline="loc", group=grpOpen)

showNyOpen   = input.bool(false, "New York open", inline="no", group=grpOpen)
nySession    = input.session("0930-1659", "Session", inline="no", group=grpOpen)
nyOpenColor  = input.color(color.new(color.aqua, 76), "Color", inline="noc", group=grpOpen)
nyOpenBorder = input.color(color.aqua, "Border", inline="noc", group=grpOpen)

asiaOpenWidth = input.int(1, "Asia thickness", minval=1, inline="aos", group=grpOpen)
asiaOpenBars  = input.int(40, "Length", minval=1, maxval=500, inline="aos", group=grpOpen)
londonOpenWidth = input.int(1, "London thickness", minval=1, inline="los", group=grpOpen)
londonOpenBars  = input.int(40, "Length", minval=1, maxval=500, inline="los", group=grpOpen)
nyOpenWidth = input.int(1, "New York thickness", minval=1, inline="nos", group=grpOpen)
nyOpenBars  = input.int(40, "Length", minval=1, maxval=500, inline="nos", group=grpOpen)
maxAsiaOpens   = input.int(1, "Maximum Asia opens", minval=1, maxval=20, group=grpOpen)
maxLondonOpens = input.int(1, "Maximum London opens", minval=1, maxval=20, group=grpOpen)
maxNyOpens     = input.int(1, "Maximum New York opens", minval=1, maxval=20, group=grpOpen)
openBreakMode  = input.string("Shorten", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpOpen)
openBrokenBars = input.int(10, "Bars shown after break", minval=1, maxval=500, group=grpOpen)
openBrokenCol  = input.color(color.new(color.gray, 100), "Broken fill", group=grpOpen)

//=============================================================================
// SESSION HIGH / LOW ZONES (FROM THE ATTACHED SCRIPT)
//=============================================================================
grpRange = "03. Session High / Low Zones"
showRangeText  = input.bool(true, "Show session H/L text", group=grpRange)
showAsiaRange  = input.bool(true, "Asia H/L", inline="rh", group=grpRange)
showLondonRange = input.bool(true, "London H/L", inline="rh", group=grpRange)
showNyRange     = input.bool(true, "New York H/L", inline="rh", group=grpRange)
asiaRangeDays   = input.string("Today", "Asia days", options=["Today", "Yesterday", "Both"], group=grpRange)
londonRangeDays = input.string("Today", "London days", options=["Today", "Yesterday", "Both"], group=grpRange)
nyRangeDays     = input.string("Yesterday", "New York days", options=["Today", "Yesterday", "Both"], group=grpRange)
rangeWidthTicks = input.int(8, "Zone thickness (ticks)", minval=1, group=grpRange)
rangeLiveBars   = input.int(60, "Active projection (bars)", minval=1, maxval=500, group=grpRange)
rangeBreakMode  = input.string("Shorten", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpRange)
rangeBrokenBars = input.int(10, "Bars shown after break", minval=1, maxval=500, group=grpRange)
rangeBrokenCol  = input.color(color.new(color.gray, 100), "Broken fill", group=grpRange)

//=============================================================================
// CLASSIC KEY LEVELS
//=============================================================================
grpClassic = "04. Daily / Previous Day / Monday"
showClassicText   = input.bool(true, "Show classic-level text", group=grpClassic)
daySession       = input.session("1800-1700", "Trading day session", group=grpClassic)
showDayOpen      = input.bool(true, "Daily open zone", group=grpClassic)
showPrevDay      = input.bool(false, "Previous-day H/L zones", group=grpClassic)
showMonday       = input.bool(true, "Previous Monday H/L zones", group=grpClassic)
prevDaySets      = input.int(1, "Previous-day H/L sets to keep", minval=1, maxval=7, group=grpClassic)
dayOpenColor     = input.color(color.new(color.white, 76), "Daily open fill", inline="cc1", group=grpClassic)
dayOpenBorder    = input.color(color.white, "Border", inline="cc1", group=grpClassic)
prevDayColor     = input.color(color.new(color.rgb(255, 45, 116), 72), "Previous day fill", inline="cc2", group=grpClassic)
prevDayBorder    = input.color(color.rgb(255, 82, 139), "Border", inline="cc2", group=grpClassic)
mondayColor      = input.color(color.new(color.rgb(255, 182, 193), 76), "Monday fill", inline="cc3", group=grpClassic)
mondayBorder     = input.color(color.rgb(255, 182, 193), "Border", inline="cc3", group=grpClassic)
classicWidthTicks = input.int(8, "Zone thickness (ticks)", minval=1, group=grpClassic)
classicLiveBars   = input.int(500, "Active projection (bars)", minval=1, maxval=500, group=grpClassic)
classicBreakMode  = input.string("Keep", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpClassic)
classicBrokenBars = input.int(10, "Bars shown after break", minval=1, maxval=500, group=grpClassic)
classicBrokenCol  = input.color(color.new(color.gray, 100), "Broken fill", group=grpClassic)

//=============================================================================
// SUPPLY AND DEMAND
//=============================================================================
grpSD = "05. Supply / Demand"
showSdText    = input.bool(false, "Show supply/demand text", group=grpSD)
showSupply    = input.bool(true, "Show supply", inline="sdshow", group=grpSD)
showDemand    = input.bool(true, "Show demand", inline="sdshow", group=grpSD)
sdTimeframe   = input.timeframe("120", "Calculation timeframe", group=grpSD)
sdPivotLeft   = input.int(4, "Pivot bars left", minval=1, maxval=500, group=grpSD)
sdPivotRight  = input.int(3, "Pivot bars right", minval=1, maxval=500, group=grpSD)
sdAtrLength   = input.int(14, "ATR length", minval=1, maxval=5000, group=grpSD)
sdImpulseAtr  = input.float(1.0, "Required move away (ATR)", minval=0.1, step=0.1, group=grpSD)
maxSupplyZones = input.int(4, "Maximum supply zones", minval=1, maxval=30, group=grpSD)
maxDemandZones = input.int(4, "Maximum demand zones", minval=1, maxval=30, group=grpSD)
supplyColor   = input.color(color.new(color.orange, 72), "Supply fill", inline="sdc", group=grpSD)
demandColor   = input.color(color.new(color.blue, 72), "Demand fill", inline="sdc", group=grpSD)
supplyBorder  = input.color(color.orange, "Supply border", inline="sdb", group=grpSD)
demandBorder  = input.color(color.aqua, "Demand border", inline="sdb", group=grpSD)
sdWidthTicks  = input.int(40, "Zone thickness (ticks)", minval=1, group=grpSD)
sdLiveBars    = input.int(20, "Active projection (bars)", minval=1, maxval=500, group=grpSD)
sdBreakMode   = input.string("Delete", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpSD)
sdBrokenBars  = input.int(10, "Bars shown after break", minval=1, maxval=500, group=grpSD)
sdBrokenCol   = input.color(color.new(color.gray, 100), "Broken fill", group=grpSD)

//=============================================================================
// SUPPORT AND RESISTANCE (REPEATED CONFIRMED PIVOTS)
//=============================================================================
grpSR = "06. Support / Resistance"
showSrText    = input.bool(false, "Show support/resistance text", group=grpSR)
showResistance = input.bool(true, "Show resistance", inline="srshow", group=grpSR)
showSupport    = input.bool(true, "Show support", inline="srshow", group=grpSR)
srTimeframe    = input.timeframe("2", "Calculation timeframe", group=grpSR)
srPivotLeft    = input.int(5, "Pivot bars left", minval=1, maxval=500, group=grpSR)
srPivotRight   = input.int(5, "Pivot bars right", minval=1, maxval=500, group=grpSR)
srMinTouches   = input.int(2, "Touches required", minval=2, maxval=10, group=grpSR)
srTolerance    = input.int(8, "Matching tolerance (ticks)", minval=1, group=grpSR)
maxResistanceZones = input.int(2, "Maximum resistance zones", minval=1, maxval=30, group=grpSR)
maxSupportZones    = input.int(2, "Maximum support zones", minval=1, maxval=30, group=grpSR)
resColor       = input.color(color.new(color.aqua, 72), "Resistance fill", inline="src", group=grpSR)
supColor       = input.color(color.new(color.rgb(255, 45, 116), 72), "Support fill", inline="src", group=grpSR)
resBorder      = input.color(color.aqua, "Resistance border", inline="srb", group=grpSR)
supBorder      = input.color(color.rgb(255, 130, 156), "Support border", inline="srb", group=grpSR)
srWidthTicks   = input.int(25, "Zone thickness (ticks)", minval=1, group=grpSR)
srLiveBars     = input.int(100, "Active projection (bars)", minval=1, maxval=500, group=grpSR)
srBreakMode    = input.string("Delete", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpSR)
srBrokenBars   = input.int(10, "Bars shown after break", minval=1, maxval=500, group=grpSR)
srBrokenCol    = input.color(color.new(color.gray, 100), "Broken fill", group=grpSR)

//=============================================================================
// SWING POINT ZONES
//=============================================================================
grpSwing = "07. Swing Zones"
showSwingText  = input.bool(false, "Show swing-zone text", group=grpSwing)
showSwingHigh  = input.bool(false, "Swing highs", inline="swshow", group=grpSwing)
showSwingLow   = input.bool(false, "Swing lows", inline="swshow", group=grpSwing)
swingTimeframe = input.timeframe("1", "Calculation timeframe", group=grpSwing)
swingLeft      = input.int(10, "Pivot bars left", minval=1, maxval=500, group=grpSwing)
swingRight     = input.int(5, "Pivot bars right", minval=1, maxval=500, group=grpSwing)
maxSwingHighZones = input.int(4, "Maximum swing-high zones", minval=1, maxval=30, group=grpSwing)
maxSwingLowZones  = input.int(4, "Maximum swing-low zones", minval=1, maxval=30, group=grpSwing)
swingHighColor = input.color(color.new(color.silver, 84), "High fill", inline="swc", group=grpSwing)
swingLowColor  = input.color(color.new(color.silver, 84), "Low fill", inline="swc", group=grpSwing)
swingHighBorder = input.color(color.white, "High border", inline="swb", group=grpSwing)
swingLowBorder  = input.color(color.white, "Low border", inline="swb", group=grpSwing)
swingWidthTicks = input.int(10, "Zone thickness (ticks)", minval=1, group=grpSwing)
swingLiveBars   = input.int(1, "Active projection (bars)", minval=1, maxval=500, group=grpSwing)
swingBreakMode  = input.string("Delete", "When broken", options=["Delete", "Freeze", "Shorten", "Keep"], group=grpSwing)
swingBrokenBars = input.int(1, "Bars shown after break", minval=1, maxval=500, group=grpSwing)
swingBrokenCol  = input.color(color.new(color.gray, 100), "Broken fill", group=grpSwing)

//=============================================================================
// INVISIBLE DAILY POC CONFLUENCE
// The profile itself is never drawn. Lower-timeframe volume is distributed
// across fixed tick-size price rows, and the highest-volume row is the POC.
//=============================================================================
grpPoc = "08. Daily POC Confluence"
enablePocConfluence = input.bool(true, "Brighten zones overlapping a daily POC", group=grpPoc)
pocTimeframe        = input.timeframe("1", "Profile calculation timeframe", group=grpPoc)
pocRowTicks         = input.int(4, "POC row size (ticks)", minval=1, maxval=1000, group=grpPoc)
includeDevelopingPoc = input.bool(true, "Include current developing POC", group=grpPoc)
pocOverlapTicks     = input.int(2, "POC-to-zone overlap buffer (ticks)", minval=0, maxval=1000, group=grpPoc)
pocHighlightOpacity = input.int(100, "Highlighted-zone opacity (%)", minval=0, maxval=100, group=grpPoc, tooltip="100% is fully solid. This changes only zones that overlap a retained daily POC.")
pocBrightenBorder   = input.bool(true, "Brighten matching zone border", group=grpPoc)

// Completed POCs use the same calendar-day retention as the zone engine.
// The current developing POC is stored separately and can change as new
// lower-timeframe volume arrives.
var float[] retainedPocPrices = array.new_float()
var int[] retainedPocTimes = array.new_int()
var float currentDevelopingPoc = na

// Build one invisible profile per trading-day session. Fixed tick rows allow
// the profile to update incrementally without repainting previously allocated
// volume when the day's high or low expands. Volume from each source bar is
// distributed proportionally across the price rows crossed by that bar.
f_daily_poc_engine() =>
    bool insideProfile = not na(time(timeframe.period, daySession, zoneTz))
    bool tradingDayChanged = nz(ta.change(time_tradingday)) != 0
    bool startsProfile = insideProfile and (not insideProfile[1] or tradingDayChanged)
    bool endsProfile = not insideProfile and insideProfile[1]
    float rowSize = math.max(pocRowTicks * syminfo.mintick, syminfo.mintick)

    var int[] rowKeys = array.new_int()
    var float[] rowVolumes = array.new_float()
    var bool profileOpen = false
    var int activeProfileTime = na
    var int pocRowKey = na
    var float pocRowVolume = 0.0
    var float developingPoc = na
    var float completedPoc = na
    var int completedPocTime = na

    // If the market has no bars during its maintenance break, the next session
    // can start without an outside-session bar. Finalize the prior profile here
    // before clearing its rows.
    if startsProfile
        if profileOpen and not na(developingPoc)
            completedPoc := developingPoc
            completedPocTime := activeProfileTime
        array.clear(rowKeys)
        array.clear(rowVolumes)
        profileOpen := true
        activeProfileTime := time
        pocRowKey := na
        pocRowVolume := 0.0
        developingPoc := na

    // This fallback begins a partial profile if the loaded dataset starts in
    // the middle of a session. Extra history requested below normally ensures
    // that every retained profile begins at its actual session open.
    if insideProfile and not profileOpen
        array.clear(rowKeys)
        array.clear(rowVolumes)
        profileOpen := true
        activeProfileTime := time
        pocRowKey := na
        pocRowVolume := 0.0
        developingPoc := na

    if insideProfile and profileOpen and nz(volume) > 0
        int lowRowKey = int(math.floor(low / rowSize))
        int highRowKey = int(math.floor(high / rowSize))
        int crossedRows = highRowKey - lowRowKey + 1
        float candleRange = high - low

        // Normal lower-timeframe candles distribute their volume over every
        // crossed row. The fallback protects the script from an unusually wide
        // bad-data candle creating an excessive loop.
        if candleRange > 0 and crossedRows <= 250
            for rowKey = lowRowKey to highRowKey
                float rowBottom = rowKey * rowSize
                float rowTop = rowBottom + rowSize
                float overlap = math.max(math.min(high, rowTop) - math.max(low, rowBottom), 0.0)
                float addedVolume = volume * overlap / candleRange
                if addedVolume > 0
                    int rowIndex = array.indexof(rowKeys, rowKey)
                    float updatedVolume = addedVolume
                    if rowIndex >= 0
                        updatedVolume := array.get(rowVolumes, rowIndex) + addedVolume
                        array.set(rowVolumes, rowIndex, updatedVolume)
                    if rowIndex < 0
                        array.push(rowKeys, rowKey)
                        array.push(rowVolumes, addedVolume)
                    if updatedVolume > pocRowVolume
                        pocRowVolume := updatedVolume
                        pocRowKey := rowKey
        if candleRange <= 0 or crossedRows > 250
            int fallbackRowKey = int(math.floor(hlc3 / rowSize))
            int fallbackIndex = array.indexof(rowKeys, fallbackRowKey)
            float updatedVolume = volume
            if fallbackIndex >= 0
                updatedVolume := array.get(rowVolumes, fallbackIndex) + volume
                array.set(rowVolumes, fallbackIndex, updatedVolume)
            if fallbackIndex < 0
                array.push(rowKeys, fallbackRowKey)
                array.push(rowVolumes, volume)
            if updatedVolume > pocRowVolume
                pocRowVolume := updatedVolume
                pocRowKey := fallbackRowKey

        if not na(pocRowKey)
            float rawPoc = (pocRowKey + 0.5) * rowSize
            developingPoc := math.round(rawPoc / syminfo.mintick) * syminfo.mintick

    if endsProfile and profileOpen
        if not na(developingPoc)
            completedPoc := developingPoc
            completedPocTime := activeProfileTime
        profileOpen := false
        activeProfileTime := na
        developingPoc := na

    [completedPoc, completedPocTime, insideProfile ? developingPoc : na, activeProfileTime]

//=============================================================================
// ZONE ENGINE
// role: 1 = upper zone broken upward, -1 = lower zone broken downward,
//       0 = neutral open level; it breaks only after price crosses it completely.
//=============================================================================
type Zone
    box bx
    string name
    float top
    float bottom
    int born
    int bornTime
    int role
    int side
    int liveBars
    int brokenBars
    string breakMode
    color liveFill
    color liveBorder
    color brokenFill
    bool showLabel
    bool timeBased
    int unitMs
    bool active

var Zone[] zones = array.new<Zone>()

f_prices(float level, int role, int widthTicks) =>
    float thick = widthTicks * syminfo.mintick
    float zTop = role == 1 ? level : role == -1 ? level + thick : level + thick * 0.5
    float zBottom = role == 1 ? level - thick : role == -1 ? level : level - thick * 0.5
    [zTop, zBottom]

// A POC matches when any part of its volume row overlaps the zone plus the
// selected tick buffer. Any completed POC still inside the global lookback can
// qualify, as can the current developing POC when enabled.
f_zone_overlaps_poc(Zone z) =>
    bool overlaps = false
    float overlapBuffer = pocOverlapTicks * syminfo.mintick
    float halfPocRow = pocRowTicks * syminfo.mintick * 0.5
    if enablePocConfluence and array.size(retainedPocPrices) > 0
        for i = 0 to array.size(retainedPocPrices) - 1
            float pocPrice = array.get(retainedPocPrices, i)
            float pocRowTop = pocPrice + halfPocRow
            float pocRowBottom = pocPrice - halfPocRow
            if not overlaps and pocRowTop >= z.bottom - overlapBuffer and pocRowBottom <= z.top + overlapBuffer
                overlaps := true
    if enablePocConfluence and includeDevelopingPoc and not overlaps and not na(currentDevelopingPoc)
        float developingRowTop = currentDevelopingPoc + halfPocRow
        float developingRowBottom = currentDevelopingPoc - halfPocRow
        overlaps := developingRowTop >= z.bottom - overlapBuffer and developingRowBottom <= z.top + overlapBuffer
    overlaps

f_make_zone(string name, float level, int role, int leftBar, int widthTicks, int liveBars, int brokenBars, string mode, color fillColor, color borderColor, color brokenColor, bool showLabel) =>
    [zTop, zBottom] = f_prices(level, role, widthTicks)
    int safeLeft = math.max(leftBar, bar_index - 9999)
    box b = box.new(left=safeLeft, top=zTop, right=bar_index + liveBars, bottom=zBottom, xloc=xloc.bar_index, bgcolor=fillColor, border_color=borderColor, border_width=1, text=showText and showLabel ? name : "", text_color=textColor, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)
    Zone.new(b, name, zTop, zBottom, bar_index, time, role, 0, liveBars, brokenBars, mode, fillColor, borderColor, brokenColor, showLabel, false, 0, true)

f_make_time_zone(string name, float level, int role, int leftTime, string sourceTf, int widthTicks, int liveBars, int brokenBars, string mode, color fillColor, color borderColor, color brokenColor, bool showLabel) =>
    [zTop, zBottom] = f_prices(level, role, widthTicks)
    int safeLeftTime = na(leftTime) ? time : leftTime
    int unitMs = int(math.max(timeframe.in_seconds(sourceTf), 1.0) * 1000.0)
    int projectedRight = time + liveBars * unitMs
    box b = box.new(left=safeLeftTime, top=zTop, right=projectedRight, bottom=zBottom, xloc=xloc.bar_time, bgcolor=fillColor, border_color=borderColor, border_width=1, text=showText and showLabel ? name : "", text_color=textColor, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)
    Zone.new(b, name, zTop, zBottom, bar_index, safeLeftTime, role, 0, liveBars, brokenBars, mode, fillColor, borderColor, brokenColor, showLabel, true, unitMs, true)

// Convert the visible zone name into a stable category. Category limits are
// independent, so four demand zones do not consume the four supply slots.
f_zone_type(string name) =>
    string typeId = name
    if str.startswith(name, "Asia High")
        typeId := "Asia High"
    else if str.startswith(name, "Asia Low")
        typeId := "Asia Low"
    else if str.startswith(name, "London High")
        typeId := "London High"
    else if str.startswith(name, "London Low")
        typeId := "London Low"
    else if str.startswith(name, "New York High")
        typeId := "New York High"
    else if str.startswith(name, "New York Low")
        typeId := "New York Low"
    else if str.startswith(name, "Daily Open")
        typeId := "Daily Open"
    else if str.startswith(name, "Previous Day High")
        typeId := "Previous Day High"
    else if str.startswith(name, "Previous Day Low")
        typeId := "Previous Day Low"
    else if str.startswith(name, "Monday High")
        typeId := "Monday High"
    else if str.startswith(name, "Monday Low")
        typeId := "Monday Low"
    else if str.startswith(name, "Supply ")
        typeId := "Supply"
    else if str.startswith(name, "Demand ")
        typeId := "Demand"
    else if str.startswith(name, "Resistance ")
        typeId := "Resistance"
    else if str.startswith(name, "Support ")
        typeId := "Support"
    else if str.startswith(name, "Swing High")
        typeId := "Swing High"
    else if str.startswith(name, "Swing Low")
        typeId := "Swing Low"
    typeId

f_type_limit(string typeId) =>
    int categoryLimit = maxZones
    if typeId == "Asia Open"
        categoryLimit := maxAsiaOpens
    else if typeId == "London Open"
        categoryLimit := maxLondonOpens
    else if typeId == "New York Open"
        categoryLimit := maxNyOpens
    else if typeId == "Asia High" or typeId == "Asia Low"
        categoryLimit := asiaRangeDays == "Both" ? 2 : 1
    else if typeId == "London High" or typeId == "London Low"
        categoryLimit := londonRangeDays == "Both" ? 2 : 1
    else if typeId == "New York High" or typeId == "New York Low"
        categoryLimit := nyRangeDays == "Both" ? 2 : 1
    else if typeId == "Daily Open"
        categoryLimit := 2
    else if typeId == "Previous Day High" or typeId == "Previous Day Low"
        categoryLimit := prevDaySets
    else if typeId == "Monday High" or typeId == "Monday Low"
        categoryLimit := 1
    else if typeId == "Supply"
        categoryLimit := maxSupplyZones
    else if typeId == "Demand"
        categoryLimit := maxDemandZones
    else if typeId == "Resistance"
        categoryLimit := maxResistanceZones
    else if typeId == "Support"
        categoryLimit := maxSupportZones
    else if typeId == "Swing High"
        categoryLimit := maxSwingHighZones
    else if typeId == "Swing Low"
        categoryLimit := maxSwingLowZones
    categoryLimit

// Structural categories remove their oldest broken zone first. Calendar-based
// levels always remove the oldest chronological level so Daily Open remains
// exactly today plus the prior trading day.
f_enforce_type_limit(string typeId, int categoryLimit) =>
    int matches = 0
    bool preferActive = typeId == "Supply" or typeId == "Demand" or typeId == "Resistance" or typeId == "Support" or typeId == "Swing High" or typeId == "Swing Low"
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone candidate = array.get(zones, i)
            if f_zone_type(candidate.name) == typeId
                matches += 1
    while matches > categoryLimit
        int removeIndex = -1
        if preferActive and array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                Zone candidate = array.get(zones, i)
                if removeIndex == -1 and f_zone_type(candidate.name) == typeId and not candidate.active
                    removeIndex := i
        if removeIndex == -1 and array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                Zone candidate = array.get(zones, i)
                if removeIndex == -1 and f_zone_type(candidate.name) == typeId
                    removeIndex := i
        if removeIndex >= 0
            Zone oldCategoryZone = array.get(zones, removeIndex)
            box.delete(oldCategoryZone.bx)
            Zone removedCategoryZone = array.remove(zones, removeIndex)
            matches -= 1
        else
            matches := 0
    true

f_add_zone(Zone z) =>
    array.push(zones, z)
    string typeId = f_zone_type(z.name)
    bool categoryTrimmed = f_enforce_type_limit(typeId, f_type_limit(typeId))
    while array.size(zones) > maxZones
        Zone old = array.shift(zones)
        box.delete(old.bx)
    true

f_clear_session_range(string sessionName) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            Zone z = array.get(zones, i)
            bool sessionRange = z.name == sessionName + " High â€¢ Today" or z.name == sessionName + " Low â€¢ Today" or z.name == sessionName + " High â€¢ Yesterday" or z.name == sessionName + " Low â€¢ Yesterday"
            if sessionRange
                box.delete(z.bx)
                Zone removed = array.remove(zones, i)
    true

f_break_value_high() =>
    breakBasis == "Close" ? close : high

f_break_value_low() =>
    breakBasis == "Close" ? close : low

f_manage_zones() =>
    float buffer = breakBuffer * syminfo.mintick
    int maxAgeMs = zoneLookbackDays * 86400000
    // Indicators recalculate on every realtime price update. Requiring a
    // confirmed bar here prevents the Close option from invalidating a zone
    // intrabar when price briefly moves outside and then closes back inside.
    bool breakReady = breakBasis == "Wick" or barstate.isconfirmed
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            Zone z = array.get(zones, i)
            bool expired = time >= z.bornTime and time - z.bornTime >= maxAgeMs
            if expired
                box.delete(z.bx)
                Zone removedExpiredZone = array.remove(zones, i)
            if not expired and z.active
                int activeRight = z.timeBased ? time + z.liveBars * z.unitMs : bar_index + z.liveBars
                box.set_right(z.bx, activeRight)

                // The profile remains invisible. Only the active zone's
                // appearance changes when a retained POC overlaps it.
                bool pocConfluence = f_zone_overlaps_poc(z)
                int highlightedTransparency = 100 - pocHighlightOpacity
                color activeFill = pocConfluence ? color.new(z.liveFill, highlightedTransparency) : z.liveFill
                color activeBorder = pocConfluence and pocBrightenBorder ? color.new(z.liveBorder, highlightedTransparency) : z.liveBorder
                box.set_bgcolor(z.bx, activeFill)
                box.set_border_color(z.bx, activeBorder)

                // Neutral opening levels first establish which side price chose.
                if z.role == 0 and bar_index > z.born and breakReady
                    if z.side == 0
                        if breakBasis == "Close"
                            if close > z.top
                                z.side := 1
                            else if close < z.bottom
                                z.side := -1
                        else
                            if low > z.top
                                z.side := 1
                            else if high < z.bottom
                                z.side := -1

                bool brokeUpper = z.role == 1 and f_break_value_high() > z.top + buffer
                bool brokeLower = z.role == -1 and f_break_value_low() < z.bottom - buffer
                bool crossedNeutralDown = z.role == 0 and z.side == 1 and f_break_value_low() < z.bottom - buffer
                bool crossedNeutralUp = z.role == 0 and z.side == -1 and f_break_value_high() > z.top + buffer
                bool isBroken = breakReady and bar_index > z.born and (brokeUpper or brokeLower or crossedNeutralDown or crossedNeutralUp)

                if isBroken
                    if enableAlerts
                        // Close-mode calls occur only on a confirmed bar. Wick-mode
                        // calls can occur intrabar, so once_per_bar supports both.
                        alert(z.name + " zone broken at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
                    // Keep Delete and retained-zone handling in separate `if`
                    // statements. `array.remove()` returns a Zone, while
                    // `array.set()` returns void; placing them in opposite
                    // branches of one `if/else` causes Pine error CE 10235.
                    bool deleteZone = z.breakMode == "Delete"
                    if deleteZone
                        box.delete(z.bx)
                        Zone removed = array.remove(zones, i)
                    if not deleteZone
                        if z.breakMode == "Freeze"
                            box.set_right(z.bx, z.timeBased ? time_close : bar_index)
                        else if z.breakMode == "Shorten"
                            int shortenedRight = z.timeBased ? time + z.brokenBars * z.unitMs : bar_index + z.brokenBars
                            box.set_right(z.bx, shortenedRight)
                        // Keep leaves the currently projected right edge in place.
                        box.set_bgcolor(z.bx, z.brokenFill)
                        box.set_border_color(z.bx, color.new(z.liveBorder, 35))
                        if showText and z.showLabel
                            box.set_text(z.bx, z.name + " â€¢ broken")
                        z.active := false
                        array.set(zones, i, z)
                else
                    array.set(zones, i, z)
    true

//=============================================================================
// SESSION HELPERS
//=============================================================================
f_session_state(string sessionSpec) =>
    bool inside = not na(time(timeframe.period, sessionSpec, zoneTz))
    bool starts = inside and not inside[1]
    bool ends = not inside and inside[1]
    [inside, starts, ends]

f_session_range(string sessionSpec) =>
    [inside, starts, ends] = f_session_state(sessionSpec)
    var float sessionHigh = na
    var float sessionLow = na
    var int highBar = na
    var int lowBar = na
    if starts
        sessionHigh := high
        sessionLow := low
        highBar := bar_index
        lowBar := bar_index
    else if inside
        if na(sessionHigh) or high > sessionHigh
            sessionHigh := high
            highBar := bar_index
        if na(sessionLow) or low < sessionLow
            sessionLow := low
            lowBar := bar_index
    [inside, starts, ends, sessionHigh, sessionLow, highBar, lowBar]

// Session starts can fall inside a higher-timeframe chart bar (for example,
// the 09:30 New York open inside a 09:00 hourly futures candle). Calculate the
// opening prices in one 1-minute request so their prices stay exact on the
// user's higher-timeframe charts as well. The Daily Open also checks its exact
// configured start clock because futures charts often have no bars during the
// maintenance break. In that case, `inside and not inside[1]` alone never fires.
f_precise_session_opens() =>
    bool asiaInsideLtf = not na(time(timeframe.period, asiaSession, zoneTz))
    bool londonInsideLtf = not na(time(timeframe.period, londonSession, zoneTz))
    bool nyInsideLtf = not na(time(timeframe.period, nySession, zoneTz))
    bool dayInsideLtf = not na(time(timeframe.period, daySession, zoneTz))
    bool asiaStartsLtf = asiaInsideLtf and not asiaInsideLtf[1]
    bool londonStartsLtf = londonInsideLtf and not londonInsideLtf[1]
    bool nyStartsLtf = nyInsideLtf and not nyInsideLtf[1]
    int dayStartHour = int(str.tonumber(str.substring(daySession, 0, 2)))
    int dayStartMinute = int(str.tonumber(str.substring(daySession, 2, 4)))
    bool exactDayClock = hour(time, zoneTz) == dayStartHour and minute(time, zoneTz) == dayStartMinute
    bool exchangeTradingDayChanged = nz(ta.change(time_tradingday)) != 0
    bool dayStartsLtf = dayInsideLtf and (exactDayClock or not dayInsideLtf[1] or exchangeTradingDayChanged)
    var float exactAsiaOpen = na
    var float exactLondonOpen = na
    var float exactNyOpen = na
    var float exactDayOpen = na
    var int asiaOpenStamp = na
    var int londonOpenStamp = na
    var int nyOpenStamp = na
    var int dayOpenStamp = na
    if asiaStartsLtf
        exactAsiaOpen := open
        asiaOpenStamp := time
    if londonStartsLtf
        exactLondonOpen := open
        londonOpenStamp := time
    if nyStartsLtf
        exactNyOpen := open
        nyOpenStamp := time
    if dayStartsLtf
        exactDayOpen := open
        dayOpenStamp := time
    [exactAsiaOpen, asiaOpenStamp, exactLondonOpen, londonOpenStamp, exactNyOpen, nyOpenStamp, exactDayOpen, dayOpenStamp]

//=============================================================================
// SESSION OPEN AND RANGE CREATION
//=============================================================================
[asiaIn, asiaStart, asiaEnd, asiaHigh, asiaLow, asiaHighBar, asiaLowBar] = f_session_range(asiaSession)
[londonIn, londonStart, londonEnd, londonHigh, londonLow, londonHighBar, londonLowBar] = f_session_range(londonSession)
[nyIn, nyStart, nyEnd, nyHigh, nyLow, nyHighBar, nyLowBar] = f_session_range(nySession)

[exactAsiaOpen, asiaOpenStamp, exactLondonOpen, londonOpenStamp, exactNyOpen, nyOpenStamp, exactDayOpen, dayOpenStamp] = request.security(syminfo.tickerid, "1", f_precise_session_opens(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=100000)
bool exactAsiaStart = not na(asiaOpenStamp) and (na(asiaOpenStamp[1]) or asiaOpenStamp != asiaOpenStamp[1])
bool exactLondonStart = not na(londonOpenStamp) and (na(londonOpenStamp[1]) or londonOpenStamp != londonOpenStamp[1])
bool exactNyStart = not na(nyOpenStamp) and (na(nyOpenStamp[1]) or nyOpenStamp != nyOpenStamp[1])
bool exactDayStart = not na(dayOpenStamp) and (na(dayOpenStamp[1]) or dayOpenStamp != dayOpenStamp[1])
bool createAsiaOpen = exactAsiaStart or (na(asiaOpenStamp) and asiaStart)
bool createLondonOpen = exactLondonStart or (na(londonOpenStamp) and londonStart)
bool createNyOpen = exactNyStart or (na(nyOpenStamp) and nyStart)
float asiaOpenLevel = exactAsiaStart ? exactAsiaOpen : open
float londonOpenLevel = exactLondonStart ? exactLondonOpen : open
float nyOpenLevel = exactNyStart ? exactNyOpen : open

if showAsiaOpen and createAsiaOpen
    f_add_zone(f_make_zone("Asia Open", asiaOpenLevel, 0, bar_index, asiaOpenWidth, asiaOpenBars, openBrokenBars, openBreakMode, asiaOpenColor, asiaOpenBorder, openBrokenCol, showOpenText))
if showLondonOpen and createLondonOpen
    f_add_zone(f_make_zone("London Open", londonOpenLevel, 0, bar_index, londonOpenWidth, londonOpenBars, openBrokenBars, openBreakMode, londonOpenColor, londonOpenBorder, openBrokenCol, showOpenText))
if showNyOpen and createNyOpen
    f_add_zone(f_make_zone("New York Open", nyOpenLevel, 0, bar_index, nyOpenWidth, nyOpenBars, openBrokenBars, openBreakMode, nyOpenColor, nyOpenBorder, openBrokenCol, showOpenText))

// Keep only the selected current/previous completed session range. At a new
// session, the last completed range becomes "Yesterday". The current day's
// range is added after that session finishes, so developing highs/lows do not
// repaint finalized zones.
var float lastAsiaHigh = na
var float lastAsiaLow = na
var int lastAsiaHighBar = na
var int lastAsiaLowBar = na
var float lastLondonHigh = na
var float lastLondonLow = na
var int lastLondonHighBar = na
var int lastLondonLowBar = na
var float lastNyHigh = na
var float lastNyLow = na
var int lastNyHighBar = na
var int lastNyLowBar = na

if asiaStart
    f_clear_session_range("Asia")
    if showAsiaRange and (asiaRangeDays == "Yesterday" or asiaRangeDays == "Both") and not na(lastAsiaHigh)
        f_add_zone(f_make_zone("Asia High â€¢ Yesterday", lastAsiaHigh, 1, lastAsiaHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, asiaOpenColor, asiaOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("Asia Low â€¢ Yesterday", lastAsiaLow, -1, lastAsiaLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, asiaOpenColor, asiaOpenBorder, rangeBrokenCol, showRangeText))
if asiaEnd and not na(asiaHigh)
    if showAsiaRange and (asiaRangeDays == "Today" or asiaRangeDays == "Both")
        f_add_zone(f_make_zone("Asia High â€¢ Today", asiaHigh, 1, asiaHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, asiaOpenColor, asiaOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("Asia Low â€¢ Today", asiaLow, -1, asiaLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, asiaOpenColor, asiaOpenBorder, rangeBrokenCol, showRangeText))
    lastAsiaHigh := asiaHigh
    lastAsiaLow := asiaLow
    lastAsiaHighBar := asiaHighBar
    lastAsiaLowBar := asiaLowBar

if londonStart
    f_clear_session_range("London")
    if showLondonRange and (londonRangeDays == "Yesterday" or londonRangeDays == "Both") and not na(lastLondonHigh)
        f_add_zone(f_make_zone("London High â€¢ Yesterday", lastLondonHigh, 1, lastLondonHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, londonOpenColor, londonOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("London Low â€¢ Yesterday", lastLondonLow, -1, lastLondonLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, londonOpenColor, londonOpenBorder, rangeBrokenCol, showRangeText))
if londonEnd and not na(londonHigh)
    if showLondonRange and (londonRangeDays == "Today" or londonRangeDays == "Both")
        f_add_zone(f_make_zone("London High â€¢ Today", londonHigh, 1, londonHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, londonOpenColor, londonOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("London Low â€¢ Today", londonLow, -1, londonLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, londonOpenColor, londonOpenBorder, rangeBrokenCol, showRangeText))
    lastLondonHigh := londonHigh
    lastLondonLow := londonLow
    lastLondonHighBar := londonHighBar
    lastLondonLowBar := londonLowBar

if nyStart
    f_clear_session_range("New York")
    if showNyRange and (nyRangeDays == "Yesterday" or nyRangeDays == "Both") and not na(lastNyHigh)
        f_add_zone(f_make_zone("New York High â€¢ Yesterday", lastNyHigh, 1, lastNyHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, nyOpenColor, nyOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("New York Low â€¢ Yesterday", lastNyLow, -1, lastNyLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, nyOpenColor, nyOpenBorder, rangeBrokenCol, showRangeText))
if nyEnd and not na(nyHigh)
    if showNyRange and (nyRangeDays == "Today" or nyRangeDays == "Both")
        f_add_zone(f_make_zone("New York High â€¢ Today", nyHigh, 1, nyHighBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, nyOpenColor, nyOpenBorder, rangeBrokenCol, showRangeText))
        f_add_zone(f_make_zone("New York Low â€¢ Today", nyLow, -1, nyLowBar, rangeWidthTicks, rangeLiveBars, rangeBrokenBars, rangeBreakMode, nyOpenColor, nyOpenBorder, rangeBrokenCol, showRangeText))
    lastNyHigh := nyHigh
    lastNyLow := nyLow
    lastNyHighBar := nyHighBar
    lastNyLowBar := nyLowBar

//=============================================================================
// DAILY OPEN + PREVIOUS-DAY HIGH/LOW
//=============================================================================
[dayIn, daySessionStart, dayEnd] = f_session_state(daySession)
bool exchangeDayStart = dayIn and nz(ta.change(time_tradingday)) != 0
bool dayStart = exactDayStart or daySessionStart or exchangeDayStart
var float runningDayHigh = na
var float runningDayLow = na
var int runningDayHighBar = na
var int runningDayLowBar = na

if dayStart
    if showPrevDay and not na(runningDayHigh)
        f_add_zone(f_make_zone("Previous Day High", runningDayHigh, 1, runningDayHighBar, classicWidthTicks, classicLiveBars, classicBrokenBars, classicBreakMode, prevDayColor, prevDayBorder, classicBrokenCol, showClassicText))
        f_add_zone(f_make_zone("Previous Day Low", runningDayLow, -1, runningDayLowBar, classicWidthTicks, classicLiveBars, classicBrokenBars, classicBreakMode, prevDayColor, prevDayBorder, classicBrokenCol, showClassicText))
    runningDayHigh := high
    runningDayLow := low
    runningDayHighBar := bar_index
    runningDayLowBar := bar_index
    if showDayOpen
        float dailyOpenLevel = exactDayStart and not na(exactDayOpen) ? exactDayOpen : open
        f_add_zone(f_make_zone("Daily Open", dailyOpenLevel, 0, bar_index, classicWidthTicks, classicLiveBars, classicBrokenBars, classicBreakMode, dayOpenColor, dayOpenBorder, classicBrokenCol, showClassicText))
else if dayIn
    if na(runningDayHigh) or high > runningDayHigh
        runningDayHigh := high
        runningDayHighBar := bar_index
    if na(runningDayLow) or low < runningDayLow
        runningDayLow := low
        runningDayLowBar := bar_index

//=============================================================================
// PREVIOUS MONDAY HIGH/LOW
//=============================================================================
int dow = dayofweek(time, zoneTz)
int priorDow = dayofweek(time[1], zoneTz)
bool firstMondayBar = dow == dayofweek.monday and priorDow != dayofweek.monday
bool firstPostMondayBar = dow != dayofweek.monday and priorDow == dayofweek.monday
var float mondayHigh = na
var float mondayLow = na
var int mondayHighBar = na
var int mondayLowBar = na

if firstMondayBar
    mondayHigh := high
    mondayLow := low
    mondayHighBar := bar_index
    mondayLowBar := bar_index
else if dow == dayofweek.monday
    if na(mondayHigh) or high > mondayHigh
        mondayHigh := high
        mondayHighBar := bar_index
    if na(mondayLow) or low < mondayLow
        mondayLow := low
        mondayLowBar := bar_index

if showMonday and firstPostMondayBar and not na(mondayHigh)
    f_add_zone(f_make_zone("Monday High", mondayHigh, 1, mondayHighBar, classicWidthTicks, classicLiveBars, classicBrokenBars, classicBreakMode, mondayColor, mondayBorder, classicBrokenCol, showClassicText))
    f_add_zone(f_make_zone("Monday Low", mondayLow, -1, mondayLowBar, classicWidthTicks, classicLiveBars, classicBrokenBars, classicBreakMode, mondayColor, mondayBorder, classicBrokenCol, showClassicText))

//=============================================================================
// SUPPLY / DEMAND: CONFIRMED PIVOT PLUS REQUIRED ATR MOVE AWAY
//=============================================================================
f_sd_events() =>
    float localAtr = ta.atr(sdAtrLength)
    float localPh = ta.pivothigh(high, sdPivotLeft, sdPivotRight)
    float localPl = ta.pivotlow(low, sdPivotLeft, sdPivotRight)
    bool localSupply = not na(localPh) and localPh - ta.lowest(low, sdPivotRight + 1) >= localAtr[sdPivotRight] * sdImpulseAtr
    bool localDemand = not na(localPl) and ta.highest(high, sdPivotRight + 1) - localPl >= localAtr[sdPivotRight] * sdImpulseAtr
    [localSupply ? localPh : na, localSupply ? time[sdPivotRight] : na, localDemand ? localPl : na, localDemand ? time[sdPivotRight] : na]

var int lastSupplyStamp = na
var int lastDemandStamp = na
bool sdIsLowerTf = timeframe.in_seconds(sdTimeframe) < timeframe.in_seconds(timeframe.period)

if not sdIsLowerTf
    [mtfSupplyPrice, mtfSupplyStamp, mtfDemandPrice, mtfDemandStamp] = request.security(syminfo.tickerid, sdTimeframe, f_sd_events(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    bool newSupply = not na(mtfSupplyStamp) and (na(lastSupplyStamp) or mtfSupplyStamp > lastSupplyStamp)
    bool newDemand = not na(mtfDemandStamp) and (na(lastDemandStamp) or mtfDemandStamp > lastDemandStamp)
    if newSupply
        if showSupply
            f_add_zone(f_make_time_zone("Supply " + sdTimeframe, mtfSupplyPrice, 1, mtfSupplyStamp, sdTimeframe, sdWidthTicks, sdLiveBars, sdBrokenBars, sdBreakMode, supplyColor, supplyBorder, sdBrokenCol, showSdText))
        lastSupplyStamp := mtfSupplyStamp
    if newDemand
        if showDemand
            f_add_zone(f_make_time_zone("Demand " + sdTimeframe, mtfDemandPrice, -1, mtfDemandStamp, sdTimeframe, sdWidthTicks, sdLiveBars, sdBrokenBars, sdBreakMode, demandColor, demandBorder, sdBrokenCol, showSdText))
        lastDemandStamp := mtfDemandStamp
    bool sdBranchDone = true
else
    [supplyPrices, supplyStamps, demandPrices, demandStamps] = request.security_lower_tf(syminfo.tickerid, sdTimeframe, f_sd_events())
    if array.size(supplyStamps) > 0
        for j = 0 to array.size(supplyStamps) - 1
            int supplyStamp = array.get(supplyStamps, j)
            int demandStamp = array.get(demandStamps, j)
            if not na(supplyStamp) and (na(lastSupplyStamp) or supplyStamp > lastSupplyStamp)
                if showSupply
                    f_add_zone(f_make_time_zone("Supply " + sdTimeframe, array.get(supplyPrices, j), 1, supplyStamp, sdTimeframe, sdWidthTicks, sdLiveBars, sdBrokenBars, sdBreakMode, supplyColor, supplyBorder, sdBrokenCol, showSdText))
                lastSupplyStamp := supplyStamp
            if not na(demandStamp) and (na(lastDemandStamp) or demandStamp > lastDemandStamp)
                if showDemand
                    f_add_zone(f_make_time_zone("Demand " + sdTimeframe, array.get(demandPrices, j), -1, demandStamp, sdTimeframe, sdWidthTicks, sdLiveBars, sdBrokenBars, sdBreakMode, demandColor, demandBorder, sdBrokenCol, showSdText))
                lastDemandStamp := demandStamp
    bool sdBranchDone = true

//=============================================================================
// SUPPORT / RESISTANCE CANDIDATE ENGINE
//=============================================================================
var float[] srPrices = array.new_float()
var int[] srCounts = array.new_int()
var int[] srRoles = array.new_int()
var bool[] srPrinted = array.new_bool()

f_register_sr(float price, int role) =>
    bool emit = false
    float emitPrice = na
    int match = -1
    float tolerance = srTolerance * syminfo.mintick
    int count = array.size(srPrices)
    if count > 0
        for i = 0 to count - 1
            if match == -1 and array.get(srRoles, i) == role and math.abs(array.get(srPrices, i) - price) <= tolerance
                match := i
    if match == -1
        array.push(srPrices, price)
        array.push(srCounts, 1)
        array.push(srRoles, role)
        array.push(srPrinted, false)
    else
        int oldCount = array.get(srCounts, match)
        int newCount = oldCount + 1
        float averagePrice = (array.get(srPrices, match) * oldCount + price) / newCount
        array.set(srPrices, match, averagePrice)
        array.set(srCounts, match, newCount)
        if newCount >= srMinTouches and not array.get(srPrinted, match)
            emit := true
            emitPrice := averagePrice
            array.set(srPrinted, match, true)
    while array.size(srPrices) > 120
        array.shift(srPrices)
        array.shift(srCounts)
        array.shift(srRoles)
        array.shift(srPrinted)
    [emit, emitPrice]

f_sr_events() =>
    float localPh = ta.pivothigh(high, srPivotLeft, srPivotRight)
    float localPl = ta.pivotlow(low, srPivotLeft, srPivotRight)
    [localPh, not na(localPh) ? time[srPivotRight] : na, localPl, not na(localPl) ? time[srPivotRight] : na]

var int lastResistanceStamp = na
var int lastSupportStamp = na
bool srIsLowerTf = timeframe.in_seconds(srTimeframe) < timeframe.in_seconds(timeframe.period)

if not srIsLowerTf
    [mtfSrPh, mtfSrPhStamp, mtfSrPl, mtfSrPlStamp] = request.security(syminfo.tickerid, srTimeframe, f_sr_events(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    if not na(mtfSrPhStamp) and (na(lastResistanceStamp) or mtfSrPhStamp > lastResistanceStamp)
        [emitResistance, resistancePrice] = f_register_sr(mtfSrPh, 1)
        if showResistance and emitResistance
            f_add_zone(f_make_time_zone("Resistance " + str.tostring(srMinTouches) + "x â€¢ " + srTimeframe, resistancePrice, 1, mtfSrPhStamp, srTimeframe, srWidthTicks, srLiveBars, srBrokenBars, srBreakMode, resColor, resBorder, srBrokenCol, showSrText))
        lastResistanceStamp := mtfSrPhStamp
    if not na(mtfSrPlStamp) and (na(lastSupportStamp) or mtfSrPlStamp > lastSupportStamp)
        [emitSupport, supportPrice] = f_register_sr(mtfSrPl, -1)
        if showSupport and emitSupport
            f_add_zone(f_make_time_zone("Support " + str.tostring(srMinTouches) + "x â€¢ " + srTimeframe, supportPrice, -1, mtfSrPlStamp, srTimeframe, srWidthTicks, srLiveBars, srBrokenBars, srBreakMode, supColor, supBorder, srBrokenCol, showSrText))
        lastSupportStamp := mtfSrPlStamp
    bool srBranchDone = true
else
    [srHighPrices, srHighStamps, srLowPrices, srLowStamps] = request.security_lower_tf(syminfo.tickerid, srTimeframe, f_sr_events())
    if array.size(srHighStamps) > 0
        for j = 0 to array.size(srHighStamps) - 1
            int srHighStamp = array.get(srHighStamps, j)
            int srLowStamp = array.get(srLowStamps, j)
            if not na(srHighStamp) and (na(lastResistanceStamp) or srHighStamp > lastResistanceStamp)
                [emitResistance, resistancePrice] = f_register_sr(array.get(srHighPrices, j), 1)
                if showResistance and emitResistance
                    f_add_zone(f_make_time_zone("Resistance " + str.tostring(srMinTouches) + "x â€¢ " + srTimeframe, resistancePrice, 1, srHighStamp, srTimeframe, srWidthTicks, srLiveBars, srBrokenBars, srBreakMode, resColor, resBorder, srBrokenCol, showSrText))
                lastResistanceStamp := srHighStamp
            if not na(srLowStamp) and (na(lastSupportStamp) or srLowStamp > lastSupportStamp)
                [emitSupport, supportPrice] = f_register_sr(array.get(srLowPrices, j), -1)
                if showSupport and emitSupport
                    f_add_zone(f_make_time_zone("Support " + str.tostring(srMinTouches) + "x â€¢ " + srTimeframe, supportPrice, -1, srLowStamp, srTimeframe, srWidthTicks, srLiveBars, srBrokenBars, srBreakMode, supColor, supBorder, srBrokenCol, showSrText))
                lastSupportStamp := srLowStamp
    bool srBranchDone = true

//=============================================================================
// SWING POINT ZONES
//=============================================================================
f_swing_events() =>
    float localPh = ta.pivothigh(high, swingLeft, swingRight)
    float localPl = ta.pivotlow(low, swingLeft, swingRight)
    [localPh, not na(localPh) ? time[swingRight] : na, localPl, not na(localPl) ? time[swingRight] : na]

var int lastSwingHighStamp = na
var int lastSwingLowStamp = na
bool swingIsLowerTf = timeframe.in_seconds(swingTimeframe) < timeframe.in_seconds(timeframe.period)

if not swingIsLowerTf
    [mtfSwingPh, mtfSwingPhStamp, mtfSwingPl, mtfSwingPlStamp] = request.security(syminfo.tickerid, swingTimeframe, f_swing_events(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    if not na(mtfSwingPhStamp) and (na(lastSwingHighStamp) or mtfSwingPhStamp > lastSwingHighStamp)
        if showSwingHigh
            f_add_zone(f_make_time_zone("Swing High â€¢ " + swingTimeframe, mtfSwingPh, 1, mtfSwingPhStamp, swingTimeframe, swingWidthTicks, swingLiveBars, swingBrokenBars, swingBreakMode, swingHighColor, swingHighBorder, swingBrokenCol, showSwingText))
        lastSwingHighStamp := mtfSwingPhStamp
    if not na(mtfSwingPlStamp) and (na(lastSwingLowStamp) or mtfSwingPlStamp > lastSwingLowStamp)
        if showSwingLow
            f_add_zone(f_make_time_zone("Swing Low â€¢ " + swingTimeframe, mtfSwingPl, -1, mtfSwingPlStamp, swingTimeframe, swingWidthTicks, swingLiveBars, swingBrokenBars, swingBreakMode, swingLowColor, swingLowBorder, swingBrokenCol, showSwingText))
        lastSwingLowStamp := mtfSwingPlStamp
    bool swingBranchDone = true
else
    [swingHighPrices, swingHighStamps, swingLowPrices, swingLowStamps] = request.security_lower_tf(syminfo.tickerid, swingTimeframe, f_swing_events())
    if array.size(swingHighStamps) > 0
        for j = 0 to array.size(swingHighStamps) - 1
            int swingHighStamp = array.get(swingHighStamps, j)
            int swingLowStamp = array.get(swingLowStamps, j)
            if not na(swingHighStamp) and (na(lastSwingHighStamp) or swingHighStamp > lastSwingHighStamp)
                if showSwingHigh
                    f_add_zone(f_make_time_zone("Swing High â€¢ " + swingTimeframe, array.get(swingHighPrices, j), 1, swingHighStamp, swingTimeframe, swingWidthTicks, swingLiveBars, swingBrokenBars, swingBreakMode, swingHighColor, swingHighBorder, swingBrokenCol, showSwingText))
                lastSwingHighStamp := swingHighStamp
            if not na(swingLowStamp) and (na(lastSwingLowStamp) or swingLowStamp > lastSwingLowStamp)
                if showSwingLow
                    f_add_zone(f_make_time_zone("Swing Low â€¢ " + swingTimeframe, array.get(swingLowPrices, j), -1, swingLowStamp, swingTimeframe, swingWidthTicks, swingLiveBars, swingBrokenBars, swingBreakMode, swingLowColor, swingLowBorder, swingBrokenCol, showSwingText))
                lastSwingLowStamp := swingLowStamp
    bool swingBranchDone = true

//=============================================================================
// INVISIBLE DAILY POC STORAGE AND RETENTION
//=============================================================================
[completedPocValue, completedPocStamp, developingPocValue, developingPocStamp] = request.security(syminfo.tickerid, pocTimeframe, f_daily_poc_engine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=20000)

var int lastStoredPocStamp = na
bool newCompletedPoc = enablePocConfluence and not na(completedPocValue) and not na(completedPocStamp) and (na(lastStoredPocStamp) or completedPocStamp != lastStoredPocStamp)

if newCompletedPoc
    array.push(retainedPocPrices, completedPocValue)
    array.push(retainedPocTimes, completedPocStamp)
    lastStoredPocStamp := completedPocStamp

// Remove completed POCs with the exact same calendar-day rule used by zones.
int pocMaxAgeMs = zoneLookbackDays * 86400000
if array.size(retainedPocTimes) > 0
    for i = array.size(retainedPocTimes) - 1 to 0
        int storedPocTime = array.get(retainedPocTimes, i)
        bool pocExpired = time >= storedPocTime and time - storedPocTime >= pocMaxAgeMs
        if pocExpired
            array.remove(retainedPocPrices, i)
            array.remove(retainedPocTimes, i)

// The developing POC is live by design and can migrate as the current
// session accumulates volume. Completed POCs never change after storage.
currentDevelopingPoc := enablePocConfluence and includeDevelopingPoc ? developingPocValue : na

// Manage last so newly-created zones cannot be broken on their creation bar,
// and so today's new POC information can immediately update zone strength.
f_manage_zones()
````
