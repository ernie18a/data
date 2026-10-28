# OI Liquidation Map [Golden_WolfAI]

- url: https://www.tradingview.com/script/EPqIo7gK-oi-liquidation-map-golden-wolfai/
- type: indicator
- pine_id: PUB;0499060ac92d4d2fb7b65235ab28b081
- version: 1.0

## Description

Golden WolfAI — OI Liquidation Map

Golden WolfAI — OI Liquidation Map is an Open Interest–based market structure indicator designed to visualize potential leveraged-position buildup and estimate price areas where liquidation pressure may be concentrated.

The script combines changes in Open Interest, price direction, statistical normalization, estimated leverage levels, and a liquidation-density profile to create a structured view of leveraged market positioning directly on the chart.

Unlike indicators that simply plot raw Open Interest, this tool focuses on identifying unusually large OI expansions and converting those events into estimated liquidation levels for several leverage categories.

The result is a dynamic map of potential long and short liquidation areas, accompanied by a density profile and two information dashboards.

Core Concept

A rise in Open Interest means that additional derivative exposure is entering the market, but Open Interest alone does not identify whether the new positioning is predominantly long or short.

This indicator uses a simple directional heuristic:

Open Interest rising + price rising → Long buildup

Open Interest rising + price falling → Short buildup

Only positive OI expansions are used to create new liquidation zones.

The objective is not to reconstruct individual exchange positions. Instead, the script uses abnormal changes in aggregate Open Interest as a proxy for newly created leveraged exposure and projects theoretical liquidation prices from those events.

Open Interest Data

The indicator automatically constructs an Open Interest symbol for a Binance USDT perpetual contract based on the base currency of the current chart.

Example:

BTC chart → Binance BTCUSDT perpetual Open Interest

ETH chart → Binance ETHUSDT perpetual Open Interest

The Open Interest data is requested on the same timeframe as the active chart.

If a corresponding Binance USDT perpetual Open Interest symbol is unavailable, the indicator may not be able to generate OI-based information for that asset.

OI Impulse Detection

Raw changes in Open Interest can have very different significance depending on the asset, timeframe and current market environment.

For that reason, the indicator does not rely on a fixed numerical OI threshold.

Instead, it calculates:

ΔOI = Current Open Interest − Previous Open Interest

The absolute OI change is then compared with its recent statistical distribution.

The script calculates the mean and standard deviation of historical absolute OI changes and converts the current change into a z-score.

Importantly, the current OI impulse is excluded from its own statistical baseline. This prevents an unusually large current observation from immediately increasing the average and standard deviation used to evaluate itself.

The resulting OI z-score measures how unusual the current Open Interest movement is relative to recent behavior.

OI Impulse Strength

OI expansions are classified into three configurable categories:

SMALL

Default z-score threshold: 1.0

MEDIUM

Default z-score threshold: 2.0

LARGE

Default z-score threshold: 3.0

These thresholds can be modified in the indicator settings.

A higher classification represents a more statistically unusual Open Interest expansion relative to the selected normalization window.

By default, the normalization length is 60 bars.

Signal Confirmation

New liquidation clusters are generated only when:

Open Interest data is available;

ΔOI is positive;

the OI z-score reaches at least the Small Impulse threshold;

price direction identifies either a long or short buildup;

the chart bar is confirmed.

This means historical liquidation clusters are created from confirmed bars rather than from temporary intrabar price movements.

The price used as the estimated entry reference for a new positioning event is the bar's OHLC4 value.

Directional Positioning Heuristic

When a qualifying OI expansion occurs, the script determines its estimated direction using price movement.

Long buildup

If:

OI increases
and
Close > Previous Close

the expansion is classified as a potential long buildup.

The indicator then projects liquidation levels below the estimated entry price.

Short buildup

If:

OI increases
and
Close < Previous Close

the expansion is classified as a potential short buildup.

The indicator then projects liquidation levels above the estimated entry price.

This directional interpretation is intentionally a heuristic.

The script does not have access to individual trader entries, account positions, long/short ownership of each OI contract, wallet balances or exchange liquidation records.

Leverage-Based Liquidation Map

Each qualifying OI event can create multiple estimated liquidation levels.

The leverage spectrum depends on the strength of the OI impulse.

Small OI impulse

Creates estimated liquidation levels for:

25x
50x
100x

Medium OI impulse

Creates estimated liquidation levels for:

10x
25x
50x
100x

Large OI impulse

Creates the widest liquidation cluster:

5x
10x
25x
50x
100x

The idea is that stronger OI expansions contribute information across a wider hypothetical leverage spectrum.

Each leverage group has its own configurable color, making it possible to distinguish different leverage levels visually.

Liquidation Price Model

Liquidation prices are estimated using a simplified isolated-position model.

For an estimated long position:

Liquidation Price = Entry × (1 − 1 / Leverage) / (1 − MMR)

For an estimated short position:

Liquidation Price = Entry × (1 + 1 / Leverage) / (1 + MMR)

Where:

Entry = estimated entry price generated from the OI event

Leverage = 5x, 10x, 25x, 50x or 100x

MMR = configurable Maintenance Margin Rate

The default Maintenance Margin setting is 0.40%.

Important Note About Liquidation Prices

The levels displayed by this indicator are estimated liquidation levels, not actual exchange liquidation prices.

Real liquidation prices depend on variables that are not available to the script, including:

exchange maintenance-margin tiers;

actual position size;

position notional;

account margin mode;

wallet balance;

additional collateral;

trading fees;

funding;

exchange-specific liquidation formulas;

account configuration.

For this reason, the plotted prices should be interpreted as a model of potential liquidation structure rather than an exact liquidation feed.

OI Impulse Weighting

Not every qualifying Open Interest expansion contributes equally to the liquidation-density profile.

The indicator compares the absolute OI change with its recent average absolute change.

Larger expansions receive a larger weight.

The weighting factor is constrained to prevent extreme observations from completely dominating the profile.

This allows statistically significant OI events to contribute more strongly to liquidation-density calculations while maintaining a usable visual scale.

Active Liquidation Levels

New liquidation levels remain active until price reaches them.

For an estimated long liquidation level:

the zone is consumed when the market trades down to or below the level.

For an estimated short liquidation level:

the zone is consumed when the market trades up to or above the level.

The script tracks this state internally for every stored liquidation zone.

Consumed Levels

The Keep consumed levels setting controls what happens after price reaches a projected liquidation level.

When enabled, the historical level remains on the chart, but its line stops at the bar where it was reached and its appearance becomes less prominent.

When disabled, the consumed line is removed.

This makes it possible to use the map either as:

a cleaner view of currently active liquidation structure; or

a historical visualization of where projected liquidation levels were previously reached.

Liquidation Density Profile

Individual liquidation lines provide detailed information, but markets can contain many overlapping levels.

The indicator therefore includes a liquidation-density profile.

The local price range is divided into configurable price bins.

Active liquidation zones falling inside this range are assigned to the corresponding bins and weighted according to the strength of the OI event that created them.

The profile aggregates:

estimated long liquidation density;

estimated short liquidation density;

total liquidation density.

The width of each profile row represents its density relative to the strongest row currently visible.

Density Direction

Each profile row also identifies which side contributes more strongly to the local liquidation density.

If long-liquidation density dominates, the row uses the long-side color.

If short-liquidation density dominates, the row uses the short-side color.

If both sides are balanced, the neutral profile color is used.

This provides more information than a simple total-density histogram because the user can see both the concentration and the estimated directional composition of the liquidation structure.

Density Peak

The indicator identifies the price bin containing the highest combined active liquidation density.

This level is displayed in the information dashboard as:

Density peak

It represents the center price of the strongest current liquidation-density bin inside the analyzed local range.

The Density Peak should not be interpreted as a guaranteed price target. It simply identifies the price area where the model currently finds the greatest concentration of weighted active liquidation levels.

Nearest Active Liquidations

The indicator continuously searches the stored active zones for:

Nearest Long Liquidation

The closest active estimated long liquidation below the current market price.

Nearest Short Liquidation

The closest active estimated short liquidation above the current market price.

These nearest levels are visually emphasized on the chart.

The information dashboard also displays their exact prices and percentage distance from the current market price.

Leverage Liquidation Table

A dedicated table in the upper-right corner provides a leverage-by-leverage view of the nearest active liquidation levels.

The table contains:

LEV | LONG LIQ | SHORT LIQ

for:

5x
10x
25x
50x
100x

For each leverage category, the script searches for:

the nearest active estimated long liquidation below current price;

the nearest active estimated short liquidation above current price.

Each value includes both the projected liquidation price and its percentage distance from the current market price.

This makes it possible to quickly compare how close different hypothetical leverage groups are to their nearest active liquidation areas.

The leverage labels use the same colors as their corresponding liquidation lines on the chart.

Main Information Dashboard

The upper-left dashboard provides a summary of the current indicator state.

OI Source

Displays the Open Interest symbol currently being requested.

Δ OI

Shows the percentage change in Open Interest from the previous bar.

OI z-score

Displays the normalized magnitude of the current OI change together with its impulse classification:

NORMAL / SMALL / MEDIUM / LARGE

Flow Heuristic

Shows the current interpretation of Open Interest and price behavior, such as:

Long build

Short build

OI contraction

OI expansion

or

OI unavailable

Active Zones

Displays the total number of active estimated long and short liquidation zones.

Nearest Long Liq

Displays the closest active estimated long liquidation below price together with its percentage distance.

Nearest Short Liq

Displays the closest active estimated short liquidation above price together with its percentage distance.

Density Peak

Displays the price associated with the strongest combined liquidation-density bin.

Liquidation Model

Displays the Maintenance Margin Rate currently used by the simplified liquidation model.

OI Impulse Markers

Optional markers are plotted directly on the chart when confirmed qualifying OI expansions occur.

An upward marker represents a detected long buildup.

A downward marker represents a detected short buildup.

Marker visibility changes according to impulse strength, allowing larger OI events to stand out more clearly.

These markers identify the bars where new modeled liquidation clusters originated.

They are not intended to represent standalone buy or sell signals.

Visual Encoding

The indicator uses several visual dimensions to make the map easier to interpret.

Leverage color

Each leverage category has its own configurable color:

5x

10x

25x

50x

100x

Line style

OI impulse strength affects the style of the liquidation line.

Larger impulses receive stronger visual emphasis.

Active vs consumed

Active liquidation levels are displayed more prominently.

Consumed levels are faded when historical levels are retained.

Nearest levels

The nearest active long and short liquidation levels receive additional visual emphasis.

Local Range Filtering

A large number of historical liquidation levels can make a chart difficult to read.

The Only show levels near local price range option can hide lines that are outside the currently calculated local range.

The underlying liquidation-zone data remains stored, while the visual presentation focuses on levels that are more relevant to the current price environment.

Density Profile Settings

The density visualization can be customized through several parameters.

Local Range Lookback

Defines how many bars are used to determine the recent high/low range.

Default: 240 bars

Profile Rows

Controls the number of price bins used by the density profile.

Default: 64 rows

More rows provide greater price resolution, while fewer rows produce broader density zones.

Range Padding

Adds additional space above and below the calculated local price range.

Default: 12%

Profile Offset

Controls how far to the right of the latest candle the density profile is drawn.

Maximum Profile Width

Controls the maximum horizontal width of the strongest density row.

Signal Engine Settings

OI Normalization Length

Historical period used to calculate the average and standard deviation of absolute OI changes.

Default: 60

Small OI Impulse

Minimum z-score required for a Small event.

Default: 1.0

Medium OI Impulse

Minimum z-score required for a Medium event.

Default: 2.0

Large OI Impulse

Minimum z-score required for a Large event.

Default: 3.0

These parameters allow the indicator to be adapted to different assets, timeframes and desired sensitivity levels.

Performance Settings

Maximum Stored Zones

Controls the maximum number of liquidation-zone objects retained by the indicator.

Older zones are removed when this limit is exceeded.

The default value is 360 zones.

This setting provides a balance between maintaining historical liquidation structure and controlling Pine Script resource usage.

Visual Settings

The following components can be enabled or disabled independently:

liquidation level lines;

local-range filtering;

historical consumed levels;

OI impulse markers;

information dashboard;

leverage liquidation table;

liquidation density profile.

Colors for long buildup, short buildup, neutral density and individual leverage categories can also be customized.

Suggested Interpretation

The indicator is designed to provide context about leveraged market structure rather than predict price direction by itself.

Potential applications include:

identifying where estimated leveraged positions may become vulnerable;

observing clusters of liquidation levels above and below current price;

comparing long-side and short-side liquidation density;

locating the nearest modeled liquidation areas;

monitoring unusually large expansions in Open Interest;

observing how liquidation structure develops after major positioning events;

comparing liquidation proximity across several leverage assumptions.

A dense group of levels represents an area where multiple model-generated liquidation estimates overlap or accumulate.

It does not mean that the market must trade to that area.

What the Indicator Does Not Show

This indicator does not claim to provide:

actual individual trader positions;

exact exchange liquidation orders;

actual entry prices of market participants;

exact leverage used by individual traders;

exchange account balances;

guaranteed support or resistance;

guaranteed liquidation events;

guaranteed future price targets.

The liquidation map is a statistical and model-based reconstruction derived from publicly available chart data and Open Interest behavior.

Practical Limitation of the Direction Model

An increase in price combined with an increase in Open Interest does not prove that all new positions are long.

Likewise, falling price with rising Open Interest does not prove that all new positions are short.

Every derivatives trade contains both sides of a transaction.

The directional logic used here should therefore be understood as an analytical heuristic for estimating dominant positioning behavior, not as direct order-level information from the exchange.

Data Availability

The script relies on Binance USDT perpetual Open Interest data.

If the corresponding Open Interest series does not exist for the current base asset, the indicator may show OI as unavailable and will not be able to create new OI-based liquidation clusters.

Historical results also depend on the amount of Open Interest history made available to Pine Script for the selected symbol and timeframe.

Open-Source Purpose

The script is published with visible source code so its calculations and assumptions can be inspected directly.

The key parts of the methodology — OI normalization, directional heuristic, liquidation formulas, leverage mapping, zone lifecycle and density calculation — are intentionally transparent so users can understand what the visualization represents and what its limitations are.

The indicator is intended as a market-analysis and educational tool for studying Open Interest behavior, leverage structure and estimated liquidation concentration.

Golden WolfAI — OI Liquidation Map

## Source Code

````pine
//@version=6

// This Pine Script® code is proprietary and confidential.

// Unauthorized copying, modification, redistribution, publication, or commercial use is prohibited.

//

// © 2026 Golden_WolfAI. All rights reserved.



indicator(

     "Golden WolfAI — OI Liquidation Map",

     overlay = true,

     max_lines_count = 500,

     max_boxes_count = 120

)





// ============================================================================

// INPUTS

// ============================================================================



// Signal engine

int zLookback = input.int(

     60,

     "OI normalization length",

     minval = 10,

     group = "Signal engine"

)



float zSmall = input.float(

     1.0,

     "Small OI impulse",

     minval = 0.1,

     step = 0.1,

     group = "Signal engine"

)



float zMedium = input.float(

     2.0,

     "Medium OI impulse",

     minval = 0.1,

     step = 0.1,

     group = "Signal engine"

)



float zLarge = input.float(

     3.0,

     "Large OI impulse",

     minval = 0.1,

     step = 0.1,

     group = "Signal engine"

)





// Liquidation model

float mmrPercent = input.float(

     0.40,

     "Maintenance margin, %",

     minval = 0.0,

     maxval = 10.0,

     step = 0.05,

     tooltip = "Approximation only. Real liquidation price depends on exchange tier, position size, fees and account configuration.",

     group = "Liquidation model"

)



float mmr = mmrPercent / 100.0





// Storage

int maxStoredZones = input.int(

     360,

     "Maximum stored zones",

     minval = 50,

     maxval = 475,

     group = "Performance"

)





// Profile

bool showProfile = input.bool(

     true,

     "Show liquidation density",

     group = "Density profile"

)



int profileLookback = input.int(

     240,

     "Local range lookback",

     minval = 20,

     maxval = 3000,

     group = "Density profile"

)



int profileBins = input.int(

     64,

     "Profile rows",

     minval = 10,

     maxval = 100,

     group = "Density profile"

)



float profilePadding = input.float(

     12.0,

     "Range padding, %",

     minval = 0.0,

     maxval = 100.0,

     step = 1.0,

     group = "Density profile"

)



int profileOffset = input.int(

     5,

     "Profile offset",

     minval = 1,

     maxval = 50,

     group = "Density profile"

)



int profileMaxWidth = input.int(

     24,

     "Maximum profile width",

     minval = 2,

     maxval = 60,

     group = "Density profile"

)





// Visuals

bool showLines = input.bool(

     true,

     "Show liquidation levels",

     group = "Visuals"

)



bool showLocalOnly = input.bool(

     true,

     "Only show levels near local price range",

     group = "Visuals"

)



bool keepConsumed = input.bool(

     true,

     "Keep consumed levels",

     group = "Visuals"

)



bool showSignalMarkers = input.bool(

     true,

     "Show OI impulse markers",

     group = "Visuals"

)



bool showDashboard = input.bool(

     true,

     "Show information table",

     group = "Visuals"

)


bool showLeverageTable = input.bool(

     true,

     "Show leverage liquidation table",

     group = "Visuals"

)





// Direction colors

color longAccent = input.color(

     color.rgb(38, 166, 154),

     "Long buildup",

     group = "Colors"

)



color shortAccent = input.color(

     color.rgb(239, 83, 80),

     "Short buildup",

     group = "Colors"

)



color profileNeutral = input.color(

     color.rgb(120, 128, 145),

     "Neutral density",

     group = "Colors"

)





// Leverage colors

color color5x = input.color(

     color.rgb(156, 105, 255),

     "5x",

     group = "Leverage colors"

)



color color10x = input.color(

     color.rgb(41, 121, 255),

     "10x",

     group = "Leverage colors"

)



color color25x = input.color(

     color.rgb(0, 188, 155),

     "25x",

     group = "Leverage colors"

)



color color50x = input.color(

     color.rgb(255, 167, 38),

     "50x",

     group = "Leverage colors"

)



color color100x = input.color(

     color.rgb(244, 67, 105),

     "100x",

     group = "Leverage colors"

)





// ============================================================================

// OPEN INTEREST

// ============================================================================



string oiSymbol =

     "BINANCE:" +

     string(syminfo.basecurrency) +

     "USDT.P_OI"



float oi = request.security(

     oiSymbol,

     timeframe.period,

     close,

     ignore_invalid_symbol = true

)



float oiDelta = oi - oi[1]

float absOiDelta = math.abs(oiDelta)



// Current impulse is deliberately excluded from its own baseline.

float oiMean = ta.sma(absOiDelta, zLookback)[1]

float oiStd = ta.stdev(absOiDelta, zLookback)[1]



float oiZ =

     not na(oiStd) and oiStd > 0

     ? (absOiDelta - oiMean) / oiStd

     : na



float oiDeltaPct =

     not na(oi[1]) and oi[1] != 0

     ? oiDelta / oi[1] * 100.0

     : na





// ============================================================================

// LOCAL PRICE RANGE

// ============================================================================



float localHigh = ta.highest(high, profileLookback)

float localLow = ta.lowest(low, profileLookback)



float rawRange = localHigh - localLow



float safeRange =

     rawRange > syminfo.mintick

     ? rawRange

     : syminfo.mintick * profileBins



float rangePadding = safeRange * profilePadding / 100.0



float rangeLow = localLow - rangePadding

float rangeHigh = localHigh + rangePadding



float rangeHeight = rangeHigh - rangeLow

float binHeight = rangeHeight / profileBins





// ============================================================================

// DATA MODEL

// ============================================================================



type LiquidationZone

    float price

    bool longSide

    int leverage

    int strength

    float weight

    int createdBar

    bool active

    int hitBar

    line visual





var array<LiquidationZone> zones = array.new<LiquidationZone>()





// ============================================================================

// HELPERS

// ============================================================================



f_strength(float z) =>

    int result = 0



    if not na(z)

        if z >= zLarge

            result := 3

        else if z >= zMedium

            result := 2

        else if z >= zSmall

            result := 1



    result





f_strengthText(int strength) =>

    strength == 3 ? "LARGE" :

     strength == 2 ? "MEDIUM" :

     strength == 1 ? "SMALL" :

     "NORMAL"





f_leverageColor(int leverage) =>

    leverage == 5 ? color5x :

     leverage == 10 ? color10x :

     leverage == 25 ? color25x :

     leverage == 50 ? color50x :

     color100x





f_lineStyle(int strength) =>

    strength == 3 ? line.style_solid :

     strength == 2 ? line.style_dashed :

     line.style_dotted





f_lineWidth(int strength) =>

    strength == 3 ? 2 : 1





f_activeTransparency(int strength) =>

    strength == 3 ? 5 :

     strength == 2 ? 25 :

     48





f_zoneColor(

     int leverage,

     int strength,

     bool active,

     bool visible

 ) =>

    color base = f_leverageColor(leverage)



    int alpha =

         not visible ? 100 :

         active ? f_activeTransparency(strength) :

         82



    color.new(base, alpha)





// Simplified isolated-position liquidation model.

//

// LONG:

// Initial margin + PnL = maintenance margin

// E/L + (P-E) = P*MMR

//

// P = E*(1-1/L)/(1-MMR)

//

// SHORT:

// E/L + (E-P) = P*MMR

//

// P = E*(1+1/L)/(1+MMR)

//

// It remains an estimate because exchange tiers, fees, position notional,

// wallet balance and other parameters are not available here.

f_liquidationPrice(

     float entry,

     int leverage,

     bool longSide

 ) =>

    float lev = float(leverage)



    float result =

         longSide

         ? entry * (1.0 - 1.0 / lev) / math.max(0.000001, 1.0 - mmr)

         : entry * (1.0 + 1.0 / lev) / (1.0 + mmr)



    result





f_addZone(

     array<LiquidationZone> store,

     float entry,

     int leverage,

     bool longSide,

     int strength,

     float weight

 ) =>

    float levelPrice =

         f_liquidationPrice(

             entry,

             leverage,

             longSide

         )



    line visual = na



    if showLines

        visual := line.new(

             x1 = bar_index,

             y1 = levelPrice,

             x2 = bar_index + 1,

             y2 = levelPrice,

             xloc = xloc.bar_index,

             extend = extend.right,

             color = f_zoneColor(

                 leverage,

                 strength,

                 true,

                 true

             ),

             style = f_lineStyle(strength),

             width = f_lineWidth(strength)

         )



    LiquidationZone zone = LiquidationZone.new(

         levelPrice,

         longSide,

         leverage,

         strength,

         weight,

         bar_index,

         true,

         na,

         visual

     )



    array.push(store, zone)





f_createCluster(

     array<LiquidationZone> store,

     float entry,

     bool longSide,

     int strength,

     float weight

 ) =>

    // Largest OI expansion gets the widest leverage spectrum.

    if strength == 3

        f_addZone(store, entry, 5, longSide, strength, weight)



    if strength >= 2

        f_addZone(store, entry, 10, longSide, strength, weight)



    if strength >= 1

        f_addZone(store, entry, 25, longSide, strength, weight)

        f_addZone(store, entry, 50, longSide, strength, weight)

        f_addZone(store, entry, 100, longSide, strength, weight)





f_trimZones(

     array<LiquidationZone> store,

     int limit

 ) =>

    while array.size(store) > limit

        LiquidationZone oldest = array.shift(store)



        if not na(oldest.visual)

            line.delete(oldest.visual)





f_priceText(float value) =>

    na(value)

     ? "—"

     : str.tostring(value, format.mintick)





f_signedPercent(float value) =>

    na(value)

     ? "—"

     : (value > 0 ? "+" : "") +

       str.tostring(value, "#.##") +

       "%"





f_priceDistance(float level) =>

    string result = "—"



    if not na(level)

        float distance =

             (level - close) /

             close *

             100.0



        result :=

             str.tostring(level, format.mintick) +

             " (" +

             (distance > 0 ? "+" : "") +

             str.tostring(distance, "#.##") +

             "%)"



    result





// ============================================================================

// SIGNAL ENGINE

// ============================================================================



int impulseStrength = f_strength(oiZ)



bool validExpansion =

     not na(oiDelta) and

     oiDelta > 0 and

     impulseStrength > 0



// Direction heuristic:

//

// OI rising + price rising  -> new long exposure dominates.

// OI rising + price falling -> new short exposure dominates.

//

// This avoids creating symmetrical long/short liquidation zones

// from every OI increase.

bool longExpansion =

     barstate.isconfirmed and

     validExpansion and

     close > close[1]



bool shortExpansion =

     barstate.isconfirmed and

     validExpansion and

     close < close[1]





float impulseWeight =

     not na(oiMean) and oiMean > 0

     ? math.max(

         1.0,

         math.min(

             8.0,

             absOiDelta / oiMean

         )

       )

     : 1.0





float estimatedEntry = ohlc4





if longExpansion

    f_createCluster(

         zones,

         estimatedEntry,

         true,

         impulseStrength,

         impulseWeight

     )



if shortExpansion

    f_createCluster(

         zones,

         estimatedEntry,

         false,

         impulseStrength,

         impulseWeight

     )



if longExpansion or shortExpansion

    f_trimZones(

         zones,

         maxStoredZones

     )





// ============================================================================

// CONSUMED LEVEL DETECTION

// ============================================================================



int storedCount = array.size(zones)



if storedCount > 0

    for i = 0 to storedCount - 1



        LiquidationZone zone =

             array.get(zones, i)



        if zone.active and

           bar_index > zone.createdBar



            bool consumed =

                 zone.longSide

                 ? low <= zone.price

                 : high >= zone.price



            if consumed

                zone.active := false

                zone.hitBar := bar_index



                if not na(zone.visual)

                    if keepConsumed

                        line.set_extend(

                             zone.visual,

                             extend.none

                         )



                        line.set_x2(

                             zone.visual,

                             bar_index

                         )



                        line.set_color(

                             zone.visual,

                             f_zoneColor(

                                 zone.leverage,

                                 zone.strength,

                                 false,

                                 true

                             )

                         )



                        line.set_width(

                             zone.visual,

                             1

                         )



                    else

                        line.delete(

                             zone.visual

                         )



                        zone.visual := na



                array.set(

                     zones,

                     i,

                     zone

                 )





// ============================================================================

// SIGNAL MARKERS

// ============================================================================



plotshape(

     showSignalMarkers and longExpansion,

     title = "Long OI buildup",

     style = shape.triangleup,

     location = location.belowbar,

     color = color.new(

         longAccent,

         impulseStrength == 3 ? 0 :

         impulseStrength == 2 ? 20 :

         45

     ),

     size = size.tiny

)



plotshape(

     showSignalMarkers and shortExpansion,

     title = "Short OI buildup",

     style = shape.triangledown,

     location = location.abovebar,

     color = color.new(

         shortAccent,

         impulseStrength == 3 ? 0 :

         impulseStrength == 2 ? 20 :

         45

     ),

     size = size.tiny

)





// ============================================================================

// PROFILE DRAWINGS

// ============================================================================



var array<box> profileBoxes =

     array.new<box>()



if barstate.islast and showProfile



    if array.size(profileBoxes) != profileBins



        while array.size(profileBoxes) > 0

            box oldBox =

                 array.pop(profileBoxes)



            box.delete(oldBox)



        for i = 0 to profileBins - 1

            box newBox =

                 box.new(

                     na,

                     na,

                     na,

                     na

                 )



            array.push(

                 profileBoxes,

                 newBox

             )





// ============================================================================

// DASHBOARD

// ============================================================================



var table dashboard =

     table.new(

         position.top_left,

         2,

         10,

         frame_color = color.new(

             color.white,

             82

         ),

         frame_width = 1,

         border_color = color.new(

             color.white,

             92

         ),

         border_width = 1

     )


var table leverageDashboard =

     table.new(

         position.top_right,

         3,

         6,

         frame_color = color.new(

             color.white,

             78

         ),

         frame_width = 2,

         border_color = color.new(

             color.white,

             90

         ),

         border_width = 1

     )





// ============================================================================

// LAST-BAR ANALYSIS + PROFILE

// ============================================================================



if barstate.islast



    array<float> longBins =

         array.new<float>(

             profileBins,

             0.0

         )



    array<float> shortBins =

         array.new<float>(

             profileBins,

             0.0

         )



    int activeLong = 0

    int activeShort = 0



    float nearestLong = na

    float nearestShort = na

    array<float> nearestLongByLev = array.new<float>(5, na)

    array<float> nearestShortByLev = array.new<float>(5, na)



    line nearestLongLine = na

    line nearestShortLine = na



    int currentStoredCount =

         array.size(zones)



    // One pass through all stored liquidation data.

    if currentStoredCount > 0



        for i = 0 to currentStoredCount - 1



            LiquidationZone zone =

                 array.get(zones, i)



            bool insideLocalRange =

                 zone.price >= rangeLow and

                 zone.price <= rangeHigh



            bool visualVisible =

                 not showLocalOnly or

                 insideLocalRange



            // Update line presentation without using lines

            // as the source of indicator calculations.

            if not na(zone.visual)



                line.set_color(

                     zone.visual,

                     f_zoneColor(

                         zone.leverage,

                         zone.strength,

                         zone.active,

                         visualVisible

                     )

                 )



                line.set_style(

                     zone.visual,

                     f_lineStyle(

                         zone.strength

                     )

                 )



                line.set_width(

                     zone.visual,

                     zone.active

                     ? f_lineWidth(zone.strength)

                     : 1

                 )



            if zone.active

                int levIndex = -1
                if zone.leverage == 5
                    levIndex := 0
                else if zone.leverage == 10
                    levIndex := 1
                else if zone.leverage == 25
                    levIndex := 2
                else if zone.leverage == 50
                    levIndex := 3
                else if zone.leverage == 100
                    levIndex := 4

                if levIndex >= 0
                    if zone.longSide and zone.price < close
                        float currentLongByLev = array.get(nearestLongByLev, levIndex)
                        if na(currentLongByLev) or zone.price > currentLongByLev
                            array.set(nearestLongByLev, levIndex, zone.price)
                    else if not zone.longSide and zone.price > close
                        float currentShortByLev = array.get(nearestShortByLev, levIndex)
                        if na(currentShortByLev) or zone.price < currentShortByLev
                            array.set(nearestShortByLev, levIndex, zone.price)



                if zone.longSide

                    activeLong += 1



                    if zone.price < close and

                       (na(nearestLong) or

                        zone.price > nearestLong)



                        nearestLong := zone.price



                        nearestLongLine :=

                             visualVisible

                             ? zone.visual

                             : na



                else

                    activeShort += 1



                    if zone.price > close and

                       (na(nearestShort) or

                        zone.price < nearestShort)



                        nearestShort := zone.price



                        nearestShortLine :=

                             visualVisible

                             ? zone.visual

                             : na



                // O(1) bin lookup.

                // No nested zone × histogram loop.

                if insideLocalRange and

                   binHeight > 0



                    int binIndex =

                         int(

                             math.floor(

                                 (zone.price - rangeLow) /

                                 binHeight

                             )

                         )



                    binIndex :=

                         math.max(

                             0,

                             math.min(

                                 profileBins - 1,

                                 binIndex

                             )

                         )



                    if zone.longSide



                        float current =

                             array.get(

                                 longBins,

                                 binIndex

                             )



                        array.set(

                             longBins,

                             binIndex,

                             current + zone.weight

                         )



                    else



                        float current =

                             array.get(

                                 shortBins,

                                 binIndex

                             )



                        array.set(

                             shortBins,

                             binIndex,

                             current + zone.weight

                         )





    // Highlight nearest active liquidation on both sides.

    if not na(nearestLongLine)



        line.set_width(

             nearestLongLine,

             3

         )



        line.set_color(

             nearestLongLine,

             color.new(

                 longAccent,

                 0

             )

         )



    if not na(nearestShortLine)



        line.set_width(

             nearestShortLine,

             3

         )



        line.set_color(

             nearestShortLine,

             color.new(

                 shortAccent,

                 0

             )

         )





    // ------------------------------------------------------------------------

    // Find profile maximum

    // ------------------------------------------------------------------------



    float maxDensity = 0.0

    int peakBin = na



    for i = 0 to profileBins - 1



        float totalDensity =

             array.get(longBins, i) +

             array.get(shortBins, i)



        if totalDensity > maxDensity

            maxDensity := totalDensity

            peakBin := i





    float peakPrice =

         not na(peakBin)

         ? rangeLow +

           binHeight *

           (peakBin + 0.5)

         : na





    // ------------------------------------------------------------------------

    // Update existing boxes instead of deleting/recreating them each tick.

    // ------------------------------------------------------------------------



    if showProfile and

       array.size(profileBoxes) == profileBins



        int profileLeft =

             bar_index +

             profileOffset



        for i = 0 to profileBins - 1



            float longDensity =

                 array.get(

                     longBins,

                     i

                 )



            float shortDensity =

                 array.get(

                     shortBins,

                     i

                 )



            float totalDensity =

                 longDensity +

                 shortDensity



            float relativeDensity =

                 maxDensity > 0

                 ? totalDensity / maxDensity

                 : 0.0



            int widthBars =

                 totalDensity > 0

                 ? math.max(

                     1,

                     int(

                         math.round(

                             profileMaxWidth *

                             relativeDensity

                         )

                     )

                   )

                 : 0



            float rowLow =

                 rangeLow +

                 binHeight *

                 i



            float rowHigh =

                 rowLow +

                 binHeight



            color dominantColor =

                 longDensity > shortDensity

                 ? longAccent :

                 shortDensity > longDensity

                 ? shortAccent :

                 profileNeutral



            int transparency =

                 int(

                     math.round(

                         90.0 -

                         62.0 *

                         relativeDensity

                     )

                 )



            transparency :=

                 math.max(

                     20,

                     math.min(

                         100,

                         transparency

                     )

                 )



            box profileBox =

                 array.get(

                     profileBoxes,

                     i

                 )



            box.set_lefttop(

                 profileBox,

                 profileLeft,

                 rowHigh

             )



            box.set_rightbottom(

                 profileBox,

                 profileLeft +

                 widthBars,

                 rowLow

             )



            box.set_bgcolor(

                 profileBox,

                 totalDensity > 0

                 ? color.new(

                     dominantColor,

                     transparency

                   )

                 : color.new(

                     profileNeutral,

                     100

                   )

             )



            box.set_border_color(

                 profileBox,

                 color.new(

                     dominantColor,

                     100

                 )

             )





    // ------------------------------------------------------------------------

    // Dashboard

    // ------------------------------------------------------------------------



    if showDashboard



        color panelBg =

             color.new(

                 color.rgb(16, 20, 29),

                 18

             )



        color labelColor =

             color.rgb(

                 155,

                 163,

                 178

             )



        color valueColor =

             color.rgb(

                 230,

                 233,

                 239

             )



        color headerBg =

             color.new(

                 color.rgb(27, 32, 45),

                 5

             )



        string flowText =

             na(oiDelta)

             ? "OI unavailable" :

             oiDelta < 0

             ? "OI contraction" :

             close > close[1]

             ? "Long build"

             : close < close[1]

             ? "Short build"

             : "OI expansion"



        color flowColor =

             oiDelta > 0 and close > close[1]

             ? longAccent :

             oiDelta > 0 and close < close[1]

             ? shortAccent :

             valueColor



        string zText =

             na(oiZ)

             ? "—"

             : str.tostring(

                   oiZ,

                   "#.00"

               ) +

               "  •  " +

               f_strengthText(

                   impulseStrength

               )



        color zColor =

             impulseStrength == 3

             ? color.rgb(255, 82, 82) :

             impulseStrength == 2

             ? color.rgb(255, 183, 77) :

             impulseStrength == 1

             ? color.rgb(255, 235, 59) :

             valueColor





        table.cell(

             dashboard,

             0,

             0,

             "GOLDEN WOLFAI",

             text_color = color.white,

             bgcolor = headerBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             0,

             "OI LIQ MAP",

             text_color = color.rgb(

                 116,

                 185,

                 255

             ),

             bgcolor = headerBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             1,

             "OI source",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             1,

             oiSymbol,

             text_color = valueColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             2,

             "Δ OI",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             2,

             f_signedPercent(

                 oiDeltaPct

             ),

             text_color =

                 oiDelta > 0

                 ? color.rgb(102, 187, 106)

                 : oiDelta < 0

                 ? color.rgb(239, 83, 80)

                 : valueColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             3,

             "OI z-score",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             3,

             zText,

             text_color = zColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             4,

             "Flow heuristic",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             4,

             flowText,

             text_color = flowColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             5,

             "Active zones",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             5,

             "L " +

             str.tostring(activeLong) +

             "  |  S " +

             str.tostring(activeShort),

             text_color = valueColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             6,

             "Nearest long liq",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             6,

             f_priceDistance(

                 nearestLong

             ),

             text_color = longAccent,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             7,

             "Nearest short liq",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             7,

             f_priceDistance(

                 nearestShort

             ),

             text_color = shortAccent,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             8,

             "Density peak",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             8,

             f_priceText(

                 peakPrice

             ),

             text_color = valueColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )





        table.cell(

             dashboard,

             0,

             9,

             "Liquidation model",

             text_color = labelColor,

             bgcolor = panelBg,

             text_halign = text.align_left,

             text_size = size.normal

         )



        table.cell(

             dashboard,

             1,

             9,

             str.tostring(

                 mmrPercent,

                 "#.##"

             ) +

             "% MMR • estimated",

             text_color = valueColor,

             bgcolor = panelBg,

             text_halign = text.align_right,

             text_size = size.normal

         )



    // ------------------------------------------------------------------------
    // Leverage liquidation table
    // ------------------------------------------------------------------------

    if showLeverageTable

        color levPanelBg = color.new(color.rgb(16, 20, 29), 14)
        color levHeaderBg = color.new(color.rgb(27, 32, 45), 2)
        color levLabelColor = color.rgb(190, 197, 210)

        table.cell(
            leverageDashboard,
            0,
            0,
            "LEV",
            text_color = color.white,
            bgcolor = levHeaderBg,
            text_halign = text.align_center,
            text_size = size.normal
        )

        table.cell(
            leverageDashboard,
            1,
            0,
            "LONG LIQ",
            text_color = longAccent,
            bgcolor = levHeaderBg,
            text_halign = text.align_center,
            text_size = size.normal
        )

        table.cell(
            leverageDashboard,
            2,
            0,
            "SHORT LIQ",
            text_color = shortAccent,
            bgcolor = levHeaderBg,
            text_halign = text.align_center,
            text_size = size.normal
        )

        for row = 0 to 4

            int lev = 100

            if row == 0
                lev := 5
            else if row == 1
                lev := 10
            else if row == 2
                lev := 25
            else if row == 3
                lev := 50

            float longLevel = array.get(nearestLongByLev, row)
            float shortLevel = array.get(nearestShortByLev, row)
            color levColor = f_leverageColor(lev)

            table.cell(
                leverageDashboard,
                0,
                row + 1,
                str.tostring(lev) + "x",
                text_color = levColor,
                bgcolor = levPanelBg,
                text_halign = text.align_center,
                text_size = size.normal
            )

            table.cell(
                leverageDashboard,
                1,
                row + 1,
                f_priceDistance(longLevel),
                text_color = na(longLevel) ? levLabelColor : longAccent,
                bgcolor = levPanelBg,
                text_halign = text.align_right,
                text_size = size.normal
            )

            table.cell(
                leverageDashboard,
                2,
                row + 1,
                f_priceDistance(shortLevel),
                text_color = na(shortLevel) ? levLabelColor : shortAccent,
                bgcolor = levPanelBg,
                text_halign = text.align_right,
                text_size = size.normal
            )
````
