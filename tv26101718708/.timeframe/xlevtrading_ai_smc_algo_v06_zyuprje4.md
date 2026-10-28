# xLevTrading AI SMC Algo v.0.6

- url: https://www.tradingview.com/script/zYUPRJe4/
- type: indicator
- pine_id: PUB;ab03767af56b4eaba2d928b6888e3bfb
- version: 1.0

## Description

The [b]xLevTrading AI Smart Money Concept [/b]Indicator is a significantly expanded and independently developed institutional trading framework based on [b]LuxAlgo’s Smart Money Concept [/b] source code. While the script builds upon established Smart Money Concept principles such as market structure, liquidity analysis, order blocks, and fair value gaps, the internal logic, filtering systems, visual prioritization, and execution tools have been heavily redesigned and extended to create a more adaptive and context-aware analytical environment.

The primary objective of this indicator is not to generate excessive signals, but to help traders better understand how price interacts with liquidity, imbalance, and structural shifts in real market conditions. Instead of treating Smart Money Concepts as isolated visual tools, the indicator combines multiple layers of analysis into a unified framework where each component contributes contextual information to the others. This allows traders to evaluate not only where price currently is, but also why certain areas may become important during future market movement.

At the core of the system is the Adaptive Market Structure Engine, which acts as the foundation for all higher-level calculations. This engine continuously evaluates swing highs, swing lows, internal structure transitions, and external break-of-structure events in order to determine directional context across changing market conditions.

Unlike simplified structure indicators that only label highs and lows, the system distinguishes between internal market behavior and broader external trend development. This distinction allows traders to identify whether price action is currently impulsive, corrective, ranging, or transitioning into a potential reversal phase.

The structure engine also serves as a contextual filter for all other modules. Order blocks, fair value gaps, liquidity sweeps, and entry confirmations are evaluated relative to active structural conditions. This prevents isolated signals from appearing without broader market confirmation and helps traders focus on areas where multiple concepts align simultaneously.

One of the major components of the framework is the enhanced Order Block Engine. Traditional Smart Money Concept implementations often display large amounts of order blocks regardless of quality or contextual relevance, which can quickly overcrowd charts and reduce clarity. In this script, the order block system was redesigned to prioritize quality, structural alignment, and reaction probability instead of quantity.

The engine analyzes several contextual variables before validating a zone, including displacement strength, mitigation behavior, structural positioning, surrounding liquidity conditions, and overall market alignment. Zones that do not meet minimum contextual requirements are filtered out in order to reduce noise and improve readability.

This process creates a cleaner chart environment where institutional-style supply and demand zones become easier to interpret. The goal is not simply to identify historical candles, but to highlight areas where market participants may still have unfilled interest or where future reactions could become more likely.

To further improve usability, the indicator introduces Dynamic Fill Technology across both order blocks and fair value gaps. Instead of displaying every zone with equal visual weight, transparency levels dynamically adapt according to the internal scoring and contextual relevance of each area.

This visual hierarchy helps traders quickly distinguish stronger zones from weaker ones without manually analyzing every individual structure. Higher-confidence zones appear more visually dominant, while weaker areas fade into the background. The intention behind this system is to transform complex structural information into an intuitive visual workflow that supports faster decision-making during live market conditions.

Another major feature is the Dual Fair Value Gap Engine. Fair value gaps represent areas where price moved aggressively, creating temporary inefficiencies in the market. These imbalances often become important reaction zones as price later revisits them in an attempt to rebalance liquidity and restore market efficiency.

The Dual FVG system was specifically developed to identify strong imbalances across both lower timeframes (LTF) and higher timeframes (HTF) simultaneously. This allows traders to observe not only short-term inefficiencies, but also broader institutional imbalances that may influence market behavior over extended periods.

One of the key advantages of this approach is the ability to identify overlapping imbalances between different timeframe structures. When lower-timeframe and higher-timeframe fair value gaps align within similar price regions, these areas can represent stronger institutional interest and potentially more precise market impulses.

This multi-timeframe imbalance framework helps traders better understand where price may accelerate, react, or seek liquidity. By combining local execution zones with broader macro inefficiencies, traders gain additional context for identifying higher-probability entries and continuation opportunities.

The Liquidity Engine represents another central pillar of the framework. Liquidity behavior is one of the most important concepts in institutional trading because price often seeks areas where stop-loss orders, breakout traders, and resting liquidity are concentrated.

Instead of relying solely on static support and resistance levels, the liquidity system actively identifies equal highs, equal lows, liquidity pools, sweep conditions, and engineered liquidity grabs in real time. These events are then evaluated relative to structure and directional context.

This allows traders to better understand potential market intent rather than simply reacting to price movement after it has already occurred. For example, a liquidity sweep occurring against higher-timeframe directional bias may indicate temporary stop-hunting behavior rather than genuine reversal strength.

The interaction between liquidity and structure becomes especially important when combined with order blocks and fair value gaps. Areas where liquidity sweeps occur directly into structurally aligned imbalance zones can often provide significantly stronger contextual setups than isolated technical signals.

To further support directional analysis, the indicator also incorporates a Multi-Timeframe Moving Average Module. This feature provides optional trend filtering and directional confirmation by allowing traders to compare lower-timeframe execution against higher-timeframe trend conditions.

The moving average framework is not intended as a standalone signal generator, but rather as an additional contextual layer that helps traders avoid counter-trend positioning during strongly directional environments. This can be particularly useful when combining liquidity sweeps with continuation structures.

One of the newest additions to the framework is the Entry Finder Module, which is currently in Beta development. The purpose of the Entry Finder is not to replace discretionary trading decisions, but to assist traders in locating areas where multiple forms of confirmation align simultaneously.

The Entry Finder analyzes the relationship between structure direction, liquidity interaction, order block positioning, fair value gap alignment, and market momentum in order to identify potential execution zones. The system attempts to detect moments where price may be transitioning from liquidity collection into directional continuation.

For example, during bullish market conditions, the Entry Finder may identify a scenario where downside liquidity is swept below recent lows before price re-enters a bullish order block or bullish fair value gap that aligns with higher-timeframe structure. In bearish environments, the same logic can apply inversely after upside liquidity has been collected.

The purpose of this process is to help traders avoid emotional momentum entries and instead focus on structurally supported retracement opportunities where institutional participation may become more probable.

The Entry Finder can also assist traders by improving timing during volatile conditions. Many traders correctly identify directional bias but struggle with execution precision. By highlighting areas where liquidity, imbalance, and structure align simultaneously, the system attempts to improve entry location and reduce unnecessary chasing behavior.

Because the Entry Finder remains in Beta, its filtering logic and confirmation models are still being refined. Current versions should be viewed as execution assistance tools rather than fully automated signal systems. Traders are encouraged to combine the Entry Finder with their own risk management and market interpretation.

In addition to its analytical capabilities, the overall design philosophy of the indicator focuses heavily on chart readability and workflow efficiency. One of the common challenges with Smart Money Concept tools is visual overload caused by excessive labels, overlapping zones, and unnecessary calculations appearing simultaneously.

This framework was designed to reduce that issue through selective filtering, contextual prioritization, and dynamic visual weighting. Rather than attempting to display every possible technical event, the indicator focuses on highlighting areas where multiple concepts converge.

The result is a cleaner trading environment that allows users to focus more effectively on liquidity behavior, structural shifts, and execution planning without becoming overwhelmed by chart clutter.

The xLevTrading AI Smart Money Concept Indicator should be viewed as a professional-grade analytical framework designed for discretionary traders who want a deeper understanding of institutional price behavior. By combining enhanced Smart Money Concept principles with proprietary filtering systems, dynamic visualization methods, liquidity analysis, and multi-timeframe contextual alignment, the script aims to transform complex market behavior into a more structured and actionable decision-making process.

This indicator does not guarantee profitable trades and should not be interpreted as financial advice. It is intended as a decision-support and market-structure analysis tool that assists traders in interpreting price action, identifying contextual confluence, and improving overall market awareness across different trading environments.

[b]Chart Visualization & Color Structure[/b]

To improve chart readability and help traders quickly distinguish between different market concepts, the indicator uses a structured color hierarchy across all major components. The visual system was intentionally designed to reduce confusion during live analysis and to make the interaction between liquidity, structure, order blocks, and fair value gaps easier to interpret.

Bearish higher-timeframe order blocks are displayed in purple. These zones represent institutional-style supply areas that align with broader bearish market structure and may act as potential reaction or continuation zones during retracements.

Bearish higher-timeframe fair value gaps (HTF FVGs) are displayed in orange. These imbalance zones represent aggressive bearish displacement on higher timeframes and are intended to highlight areas where price inefficiencies may still attract future reactions or rebalancing behavior.

Bearish chart timeframe fair value gaps are displayed in red. These zones reflect local bearish imbalances directly on the active chart timeframe and are primarily used for short-term execution analysis and momentum continuation setups.

Bullish chart timeframe fair value gaps are displayed in green. These indicate local bullish inefficiencies where price moved aggressively to the upside, potentially leaving behind imbalance zones that may later provide support during retracements.

Bullish higher-timeframe fair value gaps are displayed in turquoise. These zones represent larger bullish imbalances from higher timeframe price action and are intended to provide macro directional context and stronger institutional reaction areas.

The interaction between these colors and zones is an important part of the overall framework. Traders can use overlapping higher-timeframe and lower-timeframe imbalances to identify areas where multiple forms of market inefficiency align simultaneously. For example, when a lower-timeframe bullish fair value gap develops inside a higher-timeframe bullish imbalance zone, this may indicate stronger continuation potential and improved structural confluence.

The chart layout shown in the publication intentionally focuses only on the indicator’s own analytical components without unnecessary overlays or unrelated tools. This cleaner presentation is designed to help traders clearly identify how the different modules interact with one another in real market conditions.

Labels such as Break of Structure (BOS), Change of Character (CHoCH), liquidity sweeps, moving averages, order blocks, and fair value gaps are displayed directly within their relevant market context to support visual interpretation and execution planning.

## Source Code

````pine
//@version=6
// 2026-05-12 _ 13:49
indicator("xLevTrading AI SMC Algo v.0.6", shorttitle="xLevTR - AI SMC v.0.6", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//---------------------------------------------------------------------------------------------------------------------}
//CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
BULLISH_LEG  = 1
BEARISH_LEG  = 0

BULLISH      = +1
BEARISH      = -1

OB_FRESH     = 0
OB_TESTED    = 1
OB_MITIGATED = 2
OB_INVALID   = 3

GREEN        = #089981
RED          = #F23645
BLUE         = #2157f3
GRAY         = #878b94
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b

HISTORICAL   = "Historical"
PRESENT      = "Present"

COLORED      = "Colored"
MONOCHROME   = "Monochrome"

ALL          = "All"
BOS          = "BOS"
CHOCH        = "CHoCH"
STRUCTURE_ALL      = "All"
STRUCTURE_INTERNAL = "Internal"
STRUCTURE_SWING    = "Swing"

TINY         = size.tiny
SMALL        = size.small
NORMAL       = size.normal

CLOSE        = "Close"
HIGHLOW      = "High/Low"

SOLID        = "⎯⎯⎯"
DASHED       = "----"
DOTTED       = "····"

VOL_OFF    = "Off"
VOL_LOW    = "Low"
VOL_NORMAL = "Normal"
VOL_HIGH   = "High"

MAX_HISTORY_CORE = 3000
MAX_HISTORY_OB   = 3000
MAX_HISTORY_LVL  = 3000

//GROUPS
grp_general = "General"
grp_ma1     = "Moving Averages 1 - 3"
grp_ma2     = "Moving Averages 4 - 6"

STRUCTURE_GROUP    = "Market Structure"
INTERNAL_GROUP     = "Real Time Internal Structure"
SWING_GROUP        = "Real Time Swing Structure"
LEVELS_GROUP       = "Price Zones"
BLOCKS_GROUP       = "Order Blocks"
EQUAL_GROUP        = "EQH/EQL"
GAPS_Global        = "Fair Value Gaps Engine"
GAPS_GROUP         = "Fair Value Gaps #1"
GAPS2_GROUP        = "Fair Value Gaps #2"
LIQUIDITY_GROUP    = "Liquidity Engine"
DISPLACEMENT_GROUP = "Displacement Engine"
AI_ENTRY_GROUP     = "AI Entry Filter"

OB_ANY           = "Any"
OB_INTERNAL_ONLY = "Only Internal OB"
OB_SWING_ONLY    = "Only Swing OB"

FVG_MODE_TIME         = "Time"
FVG_MODE_PRICE_ACTION = "Price Action"

//=============================================================================
// FIXED SESSION WINDOWS IN AMERICA/NEW_YORK BASE TIME
//=============================================================================
const string BASE_TZ = "America/New_York"
const string ASIA_SESSION_FULL   = "1900-0400"
const string LONDON_SESSION_FULL = "0300-1200"
const string NY_SESSION_FULL     = "0930-1600"

// Tooltips
modeTooltip                     = "Allows to display historical Structure or only the recent ones"
styleTooltip                    = "Indicator color theme"
showTrendTooltip                = "Display additional candles with a color reflecting the current trend detected by structure"
showInternalsTooltip            = "Display internal market structure"
internalFilterConfluenceTooltip = "Filter non significant internal structure breakouts"
showStructureTooltip            = "Display swing market Structure"
showSwingsTooltip               = "Display swing point as labels on the chart"
showHighLowSwingsTooltip        = "Highlight most recent strong and weak high/low points on the chart"
orderBlockMitigationTooltip     = "Select what values to use for order block mitigation"
showEqualHighsLowsTooltip       = "Display equal highs and equal lows on the chart"
equalHighsLowsLengthTooltip     = "Number of bars used to confirm equal highs and equal lows"
equalHighsLowsThresholdTooltip  = "Sensitivity threshold in a range (0, 1) used for the detection of equal highs & lows\n\nLower values will return fewer but more pertinent results"
showFairValueGapsTooltip        = "Display fair values gaps on the chart"
fairValueGapsThresholdTooltip   = "Filter out non significant fair value gaps"
fairValueGapsTimeframeTooltip   = "Fair value gaps timeframe"
fairValueGapsExtendTooltip      = "Determine how many bars to extend the Fair Value Gap boxes on chart"

//━━━━━━━━━━━━━━━━━━
// General
//━━━━━━━━━━━━━━━━━━
src_global = input.source(close, "Source", group=grp_general)
tf_calc_1  = input.timeframe("", "Timeframe", group=grp_general, tooltip="Timeframe for smart money concept incl. MA 1-3. Excl. FVG #2")
tf_use_1   = (tf_calc_1 == "" ? timeframe.period : tf_calc_1)
modeInput  = input.string(PRESENT, "Mode", group=grp_general, tooltip=modeTooltip, options=[HISTORICAL, PRESENT])
styleInput = input.string(COLORED, "Style", group=grp_general, tooltip=styleTooltip, options=[COLORED, MONOCHROME])
showTrendInput = input(false, "Color Candles", group=grp_general, tooltip=showTrendTooltip)
tableTextSizeInput          = input.string("Tiny", "Table Text Size", options=["Tiny", "Small", "Normal"], group=grp_general)

// MASTER ENGINE
Master_Engine = "Engine Master"
showStructureEngineInput    = input.bool(true, "Market Structure", inline = "L1", group=Master_Engine)
showEntryTableInput         = input.bool(true, "AI Trade", inline = "L1", group=Master_Engine, tooltip="BETA VERSION: Indicator for possible Pullback or Continuation Trade Entrys")
show_ma_group1              = input.bool(true, "MA #1 Engine   ", inline = "L2", group=Master_Engine)
show_ma_group2              = input.bool(true, "MA #2 Engine", inline = "L2", group=Master_Engine)
showOrderBlocksInput        = input.bool(true, "Order Blocks Engine", inline = "L3", group=Master_Engine, tooltip="Displays Order Blocks on the chart.")
showFairValueGapsInput      = input.bool(true, "FVG #1 Engine   ", inline = "L4", group=Master_Engine, tooltip=showFairValueGapsTooltip)
showFairValueGapsInput2     = input.bool(true, "FVG #2 Engine   ", inline = "L4", group=Master_Engine, tooltip=showFairValueGapsTooltip)
showLiquidityZonesInput     = input.bool(true, "Liquidity Engine", inline = "L3", group=Master_Engine)

showEmaTableInput           = input.bool(true, "EMA Line Up", inline="L4", group=Master_Engine)

//━━━━━━━━━━━━━━━━━━
// Moving Averages
//━━━━━━━━━━━━━━━━━━
ma(source, length, MAtype) =>
    switch MAtype
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        => na

ma_request(_show, _tf, _src, _len, _type, _gaps) =>
    _show ? request.security(
        syminfo.tickerid,
        _tf,
        ma(_src, _len, _type),
        gaps=_gaps,
        lookahead=barmerge.lookahead_off
    ) : na

f_ma_auto_color(_enabled, _show, _tf, _len, _type) =>
    (_enabled and _show) ? request.security(
        syminfo.tickerid,
        _tf,
        ma(src_global, _len, _type) > ma(src_global, _len, _type)[1] ? color.lime : color.red,
        gaps=barmerge.gaps_off,
        lookahead=barmerge.lookahead_off
    ) : na



auto_color_g1  = input.bool(true, "Trend Structure Auto-Color", group=grp_ma1, tooltip="If activated moving averages will change colors automatically when value above or below the MA")

show_ma1   = input(true,  "#1", inline="MA #1", group=grp_ma1, display=display.none)
ma1_type   = input.string("EMA", "", inline="MA #1", active=show_ma1, options=["SMA","EMA"], group=grp_ma1)
ma1_length = input.int(9, "", inline="MA #1", active=show_ma1, minval=1, group=grp_ma1)

show_ma2   = input(true,  "#2", inline="MA #2", group=grp_ma1, display=display.none)
ma2_type   = input.string("EMA", "", inline="MA #2", active=show_ma2, options=["SMA","EMA"], group=grp_ma1)
ma2_length = input.int(20, "", inline="MA #2", active=show_ma2, minval=1, group=grp_ma1)

show_ma3   = input(true,  "#3", inline="MA #3", group=grp_ma1, display=display.none)
ma3_type   = input.string("EMA", "", inline="MA #3", active=show_ma3, options=["SMA","EMA"], group=grp_ma1)
ma3_length = input.int(200, "", inline="MA #3", active=show_ma3, minval=1, group=grp_ma1)

tooltip_ma2 = "Additional moving averages for a multi-timeframe analysis to detect various averages with possible resistance or support."
tf_calc_2      = input.timeframe("D", "Timeframe", group=grp_ma2, tooltip=tooltip_ma2)
tf_use_2       = (tf_calc_2 == "" ? timeframe.period : tf_calc_2)
auto_color_g2  = input.bool(false, "Trend Structure Auto-Color", group=grp_ma2, tooltip="If activated moving averages will change colors automatically when value above or below the MA")

show_ma4   = input(false, "#4", inline="MA #4", group=grp_ma2, display=display.none)
ma4_type   = input.string("SMA", "", inline="MA #4", active=show_ma4, options=["SMA","EMA"], group=grp_ma2)
ma4_length = input.int(20, "", inline="MA #4", active=show_ma4, minval=1, group=grp_ma2)

show_ma5   = input(false, "#5", inline="MA #5", group=grp_ma2, display=display.none)
ma5_type   = input.string("SMA", "", inline="MA #5", active=show_ma5, options=["SMA","EMA"], group=grp_ma2)
ma5_length = input.int(50, "", inline="MA #5", active=show_ma5, minval=1, group=grp_ma2)

show_ma6   = input(false, "#6", inline="MA #6", group=grp_ma2, display=display.none)
ma6_type   = input.string("SMA", "", inline="MA #6", active=show_ma6, options=["SMA","EMA"], group=grp_ma2)
ma6_length = input.int(200, "", inline="MA #6", active=show_ma6, minval=1, group=grp_ma2)

show_ma1_active = show_ma_group1 and show_ma1
show_ma2_active = show_ma_group1 and show_ma2
show_ma3_active = show_ma_group1 and show_ma3

show_ma4_active = show_ma_group2 and show_ma4
show_ma5_active = show_ma_group2 and show_ma5
show_ma6_active = show_ma_group2 and show_ma6

//━━━━━━━━━━━━━━━━━━
// Requests nur wenn aktiv
//━━━━━━━━━━━━━━━━━━
ma1_raw = ma_request(show_ma1_active, tf_use_1, src_global, ma1_length, ma1_type, barmerge.gaps_on)
ma2_raw = ma_request(show_ma2_active, tf_use_1, src_global, ma2_length, ma2_type, barmerge.gaps_on)
ma3_raw = ma_request(show_ma3_active, tf_use_1, src_global, ma3_length, ma3_type, barmerge.gaps_on)

ma4_raw = ma_request(show_ma4_active, tf_use_2, src_global, ma4_length, ma4_type, barmerge.gaps_on)
ma5_raw = ma_request(show_ma5_active, tf_use_2, src_global, ma5_length, ma5_type, barmerge.gaps_on)
ma6_raw = ma_request(show_ma6_active, tf_use_2, src_global, ma6_length, ma6_type, barmerge.gaps_on)

ma1_lbl_raw = ma_request(show_ma1_active, tf_use_1, src_global, ma1_length, ma1_type, barmerge.gaps_off)
ma2_lbl_raw = ma_request(show_ma2_active, tf_use_1, src_global, ma2_length, ma2_type, barmerge.gaps_off)
ma3_lbl_raw = ma_request(show_ma3_active, tf_use_1, src_global, ma3_length, ma3_type, barmerge.gaps_off)

ma4_lbl_raw = ma_request(show_ma4_active, tf_use_2, src_global, ma4_length, ma4_type, barmerge.gaps_off)
ma5_lbl_raw = ma_request(show_ma5_active, tf_use_2, src_global, ma5_length, ma5_type, barmerge.gaps_off)
ma6_lbl_raw = ma_request(show_ma6_active, tf_use_2, src_global, ma6_length, ma6_type, barmerge.gaps_off)

ma1 = ma1_raw
ma2 = ma2_raw
ma3 = ma3_raw
ma4 = ma4_raw
ma5 = ma5_raw
ma6 = ma6_raw

//━━━━━━━━━━━━━━━━━━
// Auto Color MA Engine #1 #2
//━━━━━━━━━━━━━━━━━━
c1_auto = f_ma_auto_color(auto_color_g1 and show_ma_group1, show_ma1_active, tf_use_1, ma1_length, ma1_type)
c2_auto = f_ma_auto_color(auto_color_g1 and show_ma_group1, show_ma2_active, tf_use_1, ma2_length, ma2_type)
c3_auto = f_ma_auto_color(auto_color_g1 and show_ma_group1, show_ma3_active, tf_use_1, ma3_length, ma3_type)

c4_auto = f_ma_auto_color(auto_color_g2 and show_ma_group2, show_ma4_active, tf_use_2, ma4_length, ma4_type)
c5_auto = f_ma_auto_color(auto_color_g2 and show_ma_group2, show_ma5_active, tf_use_2, ma5_length, ma5_type)
c6_auto = f_ma_auto_color(auto_color_g2 and show_ma_group2, show_ma6_active, tf_use_2, ma6_length, ma6_type)

// Manual Color
c1_manual = input.color(color.orange, "", inline="MA #1", group=grp_ma1)
c2_manual = input.color(color.green,  "", inline="MA #2", group=grp_ma1)
c3_manual = input.color(#00CED1,      "", inline="MA #3", group=grp_ma1)

c4_manual = input.color(#FFFACD,      "", inline="MA #4", group=grp_ma2)
c5_manual = input.color(#8B0000,      "", inline="MA #5", group=grp_ma2)
c6_manual = input.color(color.blue,   "", inline="MA #6", group=grp_ma2)

// Color Selection
c1 = auto_color_g1 and show_ma1_active ? c1_auto : c1_manual
c2 = auto_color_g1 and show_ma2_active ? c2_auto : c2_manual
c3 = auto_color_g1 and show_ma3_active ? c3_auto : c3_manual

c4 = auto_color_g2 and show_ma4_active ? c4_auto : c4_manual
c5 = auto_color_g2 and show_ma5_active ? c5_auto : c5_manual
c6 = auto_color_g2 and show_ma6_active ? c6_auto : c6_manual

plot(show_ma1_active ? ma1 : na, color=c1, editable=false, title="MA #1")
plot(show_ma2_active ? ma2 : na, color=c2, editable=false, title="MA #2")
plot(show_ma3_active ? ma3 : na, color=c3, editable=false, title="MA #3")
plot(show_ma4_active ? ma4 : na, color=c4, editable=false, title="MA #4")
plot(show_ma5_active ? ma5 : na, color=c5, editable=false, title="MA #5")
plot(show_ma6_active ? ma6 : na, color=c6, editable=false, title="MA #6")

//━━━━━━━━━━━━━━━━━━
// Labels am Ende jeder MA-Linie
//━━━━━━━━━━━━━━━━━━
f_tfShort(_tf) =>
    string s = str.upper(_tf)

    if s == "1D"
        s := "D"
    if s == "1W"
        s := "W"
    if s == "1M"
        s := "M"

    float tfNum = str.tonumber(s)

    if not na(tfNum)
        if tfNum < 60
            str.tostring(int(tfNum)) + "m"
        else if tfNum < 1440
            tfNum == 60 ? "h" : str.tostring(int(tfNum / 60)) + "h"
        else if tfNum < 10080
            tfNum == 1440 ? "D" : str.tostring(int(tfNum / 1440)) + "D"
        else if tfNum < 43200
            tfNum == 10080 ? "W" : str.tostring(int(tfNum / 10080)) + "W"
        else
            tfNum == 43200 ? "M" : str.tostring(int(tfNum / 43200)) + "M"
    else
        s

f_maLabelText(_len, _tf, _type, _isChartTF) =>
    _isChartTF ? str.tostring(_len) + " " + _type : str.tostring(_len) + " / " + f_tfShort(_tf) + " " + _type

f_updateLabel(label _lbl, bool _show, float _val, string _txt, color _col) =>
    label _out = _lbl

    if barstate.islast
        if _show and not na(_val)
            if na(_out)
                _out := label.new(
                    x         = bar_index + 1,
                    y         = _val,
                    text      = _txt,
                    xloc      = xloc.bar_index,
                    yloc      = yloc.price,
                    style     = label.style_label_left,
                    size      = size.small,
                    color     = color.new(_col, 100),
                    textcolor = _col
                )
            else
                label.set_x(_out, bar_index + 1)
                label.set_y(_out, _val)
                label.set_text(_out, _txt)
                label.set_color(_out, color.new(_col, 100))
                label.set_textcolor(_out, _col)
        else
            if not na(_out)
                label.delete(_out)
                _out := na

    _out

var label lbl_ma1 = na
var label lbl_ma2 = na
var label lbl_ma3 = na
var label lbl_ma4 = na
var label lbl_ma5 = na
var label lbl_ma6 = na

lbl_ma1 := f_updateLabel(lbl_ma1, show_ma1_active, ma1_lbl_raw, f_maLabelText(ma1_length, tf_use_1, ma1_type, tf_calc_1 == ""), c1)
lbl_ma2 := f_updateLabel(lbl_ma2, show_ma2_active, ma2_lbl_raw, f_maLabelText(ma2_length, tf_use_1, ma2_type, tf_calc_1 == ""), c2)
lbl_ma3 := f_updateLabel(lbl_ma3, show_ma3_active, ma3_lbl_raw, f_maLabelText(ma3_length, tf_use_1, ma3_type, tf_calc_1 == ""), c3)

lbl_ma4 := f_updateLabel(lbl_ma4, show_ma4_active, ma4_lbl_raw, f_maLabelText(ma4_length, tf_use_2, ma4_type, tf_calc_2 == ""), c4)
lbl_ma5 := f_updateLabel(lbl_ma5, show_ma5_active, ma5_lbl_raw, f_maLabelText(ma5_length, tf_use_2, ma5_type, tf_calc_2 == ""), c5)
lbl_ma6 := f_updateLabel(lbl_ma6, show_ma6_active, ma6_lbl_raw, f_maLabelText(ma6_length, tf_use_2, ma6_type, tf_calc_2 == ""), c6)

//━━━━━━━━━━━━━━━━━━
// TABLE: EMA Lineup (MA1-3) + MTF EMA200 bullish/bearish
//━━━━━━━━━━━━━━━━━━
showEmaTableActive = showEmaTableInput

grp_tbl = "Multi-Timeframe Trend Table"

string mtf_tf1 = "5"
string mtf_tf2 = "15"
string mtf_tf3 = "60"
string mtf_tf4 = "240"

string mtf_lbl1 = "5min"
string mtf_lbl2 = "15min"
string mtf_lbl3 = "1h"
string mtf_lbl4 = "4h"

ma1_here = ma(src_global, ma1_length, ma1_type)
ma2_here = ma(src_global, ma2_length, ma2_type)
ma3_here = ma(src_global, ma3_length, ma3_type)

lineupBull = ma1_here > ma2_here and ma2_here > ma3_here
lineupBear = ma1_here < ma2_here and ma2_here < ma3_here

lineupText = lineupBull ? "ALIGNED" : lineupBear ? "ALIGNED" : "NOT ALIGNED"
lineupBg   = lineupBull ? color.new(color.green, 25) : lineupBear ? color.new(color.red, 25) : color.new(color.gray, 65)

f_tableTextSize(string _size) =>
    _size == "Tiny" ? size.tiny : _size == "Normal" ? size.normal : size.small

f_ema200_state(_tf) =>
    float delta = request.security(
        syminfo.tickerid,
        _tf,
        ta.ema(src_global, 200) - ta.ema(src_global, 200)[1],
        gaps = barmerge.gaps_off,
        lookahead = barmerge.lookahead_off
    )
    delta > 0 ? 1 : delta < 0 ? -1 : 0

f_state_text(_s) =>
    _s == 1 ? "BULLISH" : _s == -1 ? "BEARISH" : "FLAT"

f_state_bg(_s) =>
    _s == 1 ? color.new(color.green, 25) : _s == -1 ? color.new(color.red, 25) : color.new(color.gray, 65)

s1 = showEmaTableActive ? f_ema200_state(mtf_tf1) : na
s2 = showEmaTableActive ? f_ema200_state(mtf_tf2) : na
s3 = showEmaTableActive ? f_ema200_state(mtf_tf3) : na
s4 = showEmaTableActive ? f_ema200_state(mtf_tf4) : na

tblSize = f_tableTextSize(tableTextSizeInput)
var table t = table.new(position.top_right, 2, 6, frame_color=color.new(color.white, 80), frame_width=1)

text_color_ema = color.rgb(240, 225, 225)
bg_color_ema   = color.rgb(10,22,48, 10)

if barstate.islast
    if showEmaTableActive
        table.cell(t, 0, 0, "xLevTrading", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 0, "",            text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(t, 0, 1, "EMA Line Up", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 1, lineupText,    text_color=text_color_ema, bgcolor=lineupBg, text_size=tblSize)

        table.cell(t, 0, 2, mtf_lbl1, text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 2, f_state_text(s1), text_color=text_color_ema, bgcolor=f_state_bg(s1), text_size=tblSize)

        table.cell(t, 0, 3, mtf_lbl2, text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 3, f_state_text(s2), text_color=text_color_ema, bgcolor=f_state_bg(s2), text_size=tblSize)

        table.cell(t, 0, 4, mtf_lbl3, text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 4, f_state_text(s3), text_color=text_color_ema, bgcolor=f_state_bg(s3), text_size=tblSize)

        table.cell(t, 0, 5, mtf_lbl4, text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(t, 1, 5, f_state_text(s4), text_color=text_color_ema, bgcolor=f_state_bg(s4), text_size=tblSize)
    else
        table.clear(t, 0, 0, 1, 5)

//━━━━━━━━━━━━━━━━━━
// TABLE: xLevTr Entry Finder
//━━━━━━━━━━━━━━━━━━
var table smcEntryTable = table.new(position.bottom_right, 2, 7, frame_color=color.new(color.white, 80), frame_width=1)

//━━━━━━━━━━━━━━━━━━
// Smart Money Concept
//━━━━━━━━━━━━━━━━━━

// AI Entry Filter
showAITradeEngineActive = showEntryTableInput
useAIHTFBiasTimeframeInput = input.bool(false, "Bias HTF Timeframe", inline = "ai.bias", group=AI_ENTRY_GROUP, tooltip="Only affects the AI Trade. Chart market structure remains unchanged.")
aiHTFBiasTimeframeInput    = input.timeframe("15", "", inline = "ai.bias", group=AI_ENTRY_GROUP, tooltip="Set prefered timeframe for HTF Bias in AI Trade.")
useDisplacementConfirmationInput = input.bool(false, "Trade Entry Filters", group=AI_ENTRY_GROUP, tooltip="Uses displacement-style confirmation for AI Trade filtering.")
aiEntryRejectSpikeInput          = input.bool(true, "Wick Protection", inline = "AIQuality", group=AI_ENTRY_GROUP)
aiEntryRejectSmallRangeInput     = input.bool(true, "Range Protection", inline = "AIQuality", group=AI_ENTRY_GROUP)
aiEntryRequireFollowThroughInput = input.bool(true, "Follow-Through For Weak CHoCH", group=AI_ENTRY_GROUP)
aiEntryFollowThroughBarsInput    = input.int(3, "Follow-Through Bars", group=AI_ENTRY_GROUP, minval=1, maxval=5)
aiSignalSessionModeInput         = input.string("Day", "Signal Session Mode", options=["Day", "London Session", "New York Session", "Full Session"], group=AI_ENTRY_GROUP, tooltip="Day = 24h\nLondon Session = 03:00-12:00 New York base time\nNew York Session = 09:30-16:00 New York base time\nFull Session = London + New York")
aiEntryTinyRangeAtrMultInput     = input.float(0.12, "Tiny Range ATR", group=AI_ENTRY_GROUP, minval=0.01, step=0.01)
aiEntrySpikeWickRatioInput       = input.float(0.82, "Wick Ratio", inline= "AISpike", group=AI_ENTRY_GROUP, minval=0.50, maxval=0.95, step=0.01)
aiEntrySpikeBodyRatioInput       = input.float(0.06, "Body Ratio", inline = "AISpike", group=AI_ENTRY_GROUP, minval=0.01, maxval=0.30, step=0.01)

// Structure Master
structureDisplayModeInput       = input.string(STRUCTURE_ALL, "Structure", inline = "S1", group=STRUCTURE_GROUP, options=[STRUCTURE_ALL, STRUCTURE_INTERNAL, STRUCTURE_SWING], tooltip="All = shows Internal and Swing Structure\nInternal = shows only Internal Structure\nSwing = shows only Swing Structure")

// Internal Structure
showInternalBullInput           = input.string(ALL, "Bullish Structure", group=INTERNAL_GROUP, inline="ibull", options=[ALL, BOS, CHOCH])
internalBullColorInput          = input(GREEN, "", group=INTERNAL_GROUP, inline="ibull")
showInternalBearInput           = input.string(ALL, "Bearish Structure", group=INTERNAL_GROUP, inline="ibear", options=[ALL, BOS, CHOCH])
internalBearColorInput          = input(RED, "", group=INTERNAL_GROUP, inline="ibear")
internalFilterConfluenceInput   = input(false, "Confluence Filter", group=INTERNAL_GROUP, tooltip=internalFilterConfluenceTooltip)
internalStructureSize           = input.string(TINY, "Internal Label Size", group=INTERNAL_GROUP, options=[TINY, SMALL, NORMAL])
entryStructureLengthInput       = input.int(5, "Entry Structure Length", group=INTERNAL_GROUP, minval=2, tooltip="Sensitivity for Entry/Internal structure detection.")

// Swing Structure
showSwingBullInput              = input.string(ALL, "Bullish Structure", group=SWING_GROUP, inline="bull", options=[ALL, BOS, CHOCH])
swingBullColorInput             = input(GREEN, "", group=SWING_GROUP, inline="bull")
showSwingBearInput              = input.string(ALL, "Bearish Structure", group=SWING_GROUP, inline="bear", options=[ALL, BOS, CHOCH])
swingBearColorInput             = input(RED, "", group=SWING_GROUP, inline="bear")
swingStructureSize              = input.string(SMALL, "Swing Label Size", group=SWING_GROUP, options=[TINY, SMALL, NORMAL])
showSwingsInput                 = input(false, "Show Swings Points", group=SWING_GROUP, tooltip=showSwingsTooltip, inline="swings")
swingsLengthInput               = input.int(50, "", group=SWING_GROUP, minval=10, inline="swings")
showHighLowSwingsInput          = input(true, "Show Strong/Weak High/Low", inline = "S2", group=STRUCTURE_GROUP, tooltip=showHighLowSwingsTooltip)

// Equal High / Low
showEqualHighsLowsInput         = input(true, "Equal High/Low", group=STRUCTURE_GROUP, inline = "S2", tooltip=showEqualHighsLowsTooltip)
equalHighsLowsLengthInput       = input.int(3, "Bars Confirmation", group=EQUAL_GROUP, tooltip=equalHighsLowsLengthTooltip, minval=1)
equalHighsLowsThresholdInput    = input.float(0.1, "Threshold", group=EQUAL_GROUP, tooltip=equalHighsLowsThresholdTooltip, minval=0, maxval=0.5, step=0.1)
equalHighsLowsSizeInput         = input.string(TINY, "Label Size", group=EQUAL_GROUP, options=[TINY, SMALL, NORMAL])

// Price Zones
showDailyLevelsInput            = input(true, 'Daily', group = LEVELS_GROUP, inline = 'daily')
dailyLevelsStyleInput           = input.string(DASHED, '', group = LEVELS_GROUP, inline = 'daily', options = [SOLID,DASHED,DOTTED])
dailyLevelsColorInput           = input(BLUE, '', group = LEVELS_GROUP, inline = 'daily')
showPremiumDiscountZonesInput   = input(true, "Equilibrium", inline = "EQ1", group=LEVELS_GROUP, tooltip="Display equilibrium zone on chart")
equilibriumZoneColorInput       = input.color(GRAY, "", inline = "EQ1", group=LEVELS_GROUP)

// Derived active flags
showInternalsActive       = showStructureEngineInput and (structureDisplayModeInput == STRUCTURE_ALL or structureDisplayModeInput == STRUCTURE_INTERNAL)
showSwingActive           = showStructureEngineInput and (structureDisplayModeInput == STRUCTURE_ALL or structureDisplayModeInput == STRUCTURE_SWING)
showHighLowSwingsActive   = showSwingActive and showHighLowSwingsInput
showEqualHighsLowsActive  = showStructureEngineInput and showEqualHighsLowsInput
showDailyLevelsActive     = showStructureEngineInput and showDailyLevelsInput
showEquilibriumZonesActive = showStructureEngineInput and showPremiumDiscountZonesInput

// Order Blocks 
showOrderBlocksActive = showOrderBlocksInput
orderBlockTypeInput    = input.string(OB_ANY, "Order Block Type", group=BLOCKS_GROUP, options=[OB_ANY, OB_INTERNAL_ONLY, OB_SWING_ONLY], tooltip="Any = shows Swing and Internal Order Blocks.\nOnly Internal OB = shows only Internal Order Blocks.\nOnly Swing OB = shows only Swing Order Blocks.")
orderBlockMitigationInput = input.string(HIGHLOW, "Order Block Mitigation", group=BLOCKS_GROUP, tooltip=orderBlockMitigationTooltip, options=[CLOSE, HIGHLOW])
orderBlocksNumberInput = input.int(6, "Number of Order Blocks", group=BLOCKS_GROUP, minval=1, maxval=24, tooltip="Defines how many Order Blocks of each type are displayed.")
obVolumeFilterInput   = input.string(VOL_NORMAL, "Order Block Volume Filter", group=BLOCKS_GROUP, options=[VOL_OFF, VOL_LOW, VOL_NORMAL, VOL_HIGH], tooltip="Off = disables the volume filter.\nLow / Normal / High = selects the strongest Order Blocks using volume, quality and freshness.")
obVolumeMALengthInput = input.int(20, "Order Block Volume Length", group=BLOCKS_GROUP, minval=1, tooltip="Baseline length used for the Order Block volume filter.")
obUseDynamicFillInput = input.bool(true, "Dynamic OB Fill", inline = "OB1", group=BLOCKS_GROUP, tooltip="Adjusts Order Block transparency based on volume quality.")
obDynamicRangeInput   = input.int(3, " // Set Range", inline = "OB1", group=BLOCKS_GROUP, minval=1, maxval=5, tooltip="Controls the dynamic transparency range for Order Blocks.\n1 = very soft\n3 = standard\n5 = strongest range")
bullishOrderBlockColorInput = input.color(color.new(#1848cc, 80), "Bullish OB", inline = "OB3", group=BLOCKS_GROUP)
bearishOrderBlockColorInput = input.color(color.new(color.purple, 80), "Bearish OB", inline = "OB3", group=BLOCKS_GROUP)
obExpandAfterHitInput = input.bool(false, "Expand Mitigated OB",inline = "OB2", group=BLOCKS_GROUP, tooltip="Keeps mitigated / invalidated Order Blocks visible for a number of bars before deleting them.")
obExpandBarsInput     = input.int(10, "// Bars", inline = "OB2", group=BLOCKS_GROUP, minval=1, tooltip="How many bars a mitigated / invalidated Order Block remains visible before deletion.")

useInternalOrderBlocks = showOrderBlocksActive and (orderBlockTypeInput == OB_ANY or orderBlockTypeInput == OB_INTERNAL_ONLY)
useSwingOrderBlocks    = showOrderBlocksActive and (orderBlockTypeInput == OB_ANY or orderBlockTypeInput == OB_SWING_ONLY)

// FVG Engine Global
fairValueGapsThresholdInput = input(true, "Auto Threshold", inline="fvg_global", group=GAPS_Global, tooltip=fairValueGapsThresholdTooltip)
dynamicFVGFillInput         = input.bool(true, "Dynamic FVG Fill", inline="fvg_global", group=GAPS_Global)
useDisplacementFVGOnlyInput = input.bool(false, "Displacement FVG Only", group=GAPS_Global, tooltip="Only creates FVGs when the source candle also qualifies as a displacement candle.")
fvgMaxCountInput            = input.int(6, "Number Of Fair Value Gaps", group=GAPS_Global, minval = 1, maxval = 48, tooltip="Defines how many Fair Value Gaps per Engine are displayed. Max = 48 for performance safety.")
fvgStoreLimit               = math.min(math.max(fvgMaxCountInput * 3, 20), 144)
fvgDisplayModeInput         = input.string(FVG_MODE_PRICE_ACTION, "Max FVG Mode", group=GAPS_Global, options=[FVG_MODE_TIME, FVG_MODE_PRICE_ACTION], tooltip="Time = shows the latest Fair Value Gaps.\nPrice Action = shows the closest Fair Value Gaps around the current price, balanced above and below when possible.")
// FVG Engine #1
fairValueGapsTimeframeInput = tf_calc_1
fairValueGapsBullColorInput = input.color(color.new(#00ff68, 70), "Bullish FVG", inline = "FVG1", group=GAPS_GROUP)
fairValueGapsBearColorInput = input.color(color.new(#ff0008, 70), "Bearish FVG", inline = "FVG1", group=GAPS_GROUP)
fairValueGapsExtendInput    = input.int(240, "Extend FVG", group=GAPS_GROUP, tooltip=fairValueGapsExtendTooltip, minval=0)
fvg1DynamicRangeInput       = input.int(3, "Dynamic FVG Range", group=GAPS_GROUP, minval=1, maxval=5, tooltip="Controls the dynamic transparency range for FVG #1.\n1 = softer\n3 = standard\n5 = strongest range")
fvg1ExpandAfterFillInput    = input.bool(false, "Expand Filled FVG   ", inline = "FVG2", group=GAPS_GROUP, tooltip="Keeps filled FVG #1 visible for a number of bars before deleting it.")
fvg1ExpandBarsInput         = input.int(8, "// Bars", inline = "FVG2", group=GAPS_GROUP, minval=1, tooltip="How many bars a filled FVG #1 remains visible before deletion.")

// FVG Engine #2
fairValueGapsTimeframeInput2 = input.timeframe("15", "Timeframe", group=GAPS2_GROUP, tooltip=fairValueGapsTimeframeTooltip)
fairValueGapsBullColorInput2 = input.color(color.new(#00c3ff, 70), "Bullish FVG", inline = "FVG3", group=GAPS2_GROUP)
fairValueGapsBearColorInput2 = input.color(color.new(#ff9900, 70), "Bearish FVG", inline = "FVG3", group=GAPS2_GROUP)
fairValueGapsExtendInput2    = input.int(240, "Extend FVG", group=GAPS2_GROUP, tooltip=fairValueGapsExtendTooltip, minval=0)
fvg2DynamicRangeInput       = input.int(3, "Dynamic FVG Range", group=GAPS2_GROUP, minval=1, maxval=5)
fvg2ExpandAfterFillInput    = input.bool(false, "Expand Filled FVG", inline = "FVG4", group=GAPS2_GROUP)
fvg2ExpandBarsInput         = input.int(8, "// Bars", inline = "FVG4", group=GAPS2_GROUP, minval=1)

showFairValueGaps1Active    = showFairValueGapsInput
showFairValueGaps2Active    = showFairValueGapsInput2

// Liquidity Engine
showSwingLiquidityInput        = input.bool(true, "Swing High/Low Liquidity Zone", group=LIQUIDITY_GROUP)
showEqualLiquidityInput        = input.bool(true, "EQH/EQL Liquidity Zone", group=LIQUIDITY_GROUP)
liquidityMaxZonesInput         = input.int(6, "Max Active Zones", group=LIQUIDITY_GROUP, minval=1, maxval=30)
liquidityDisplayMaxModeInput   = input.string(FVG_MODE_PRICE_ACTION, "Liquidity Max Mode", group=LIQUIDITY_GROUP, options=[FVG_MODE_TIME, FVG_MODE_PRICE_ACTION], tooltip="Time = shows the latest active liquidity zones.\nPrice Action = shows the closest active liquidity zones around the current price.")
liquidityZonePadATRInput       = input.float(0.05, "Zone Thickness (ATR)", group=LIQUIDITY_GROUP, minval=0.01, step=0.01)
liquidityApproachATRInput      = input.float(0.20, "Approach Distance (ATR)", group=LIQUIDITY_GROUP, minval=0.05, step=0.05)
liquidityExtendBarsInput       = input.int(30, "Extend Zones", group=LIQUIDITY_GROUP, minval=1)
liquidityBuysideColorInput     = input.color(color.new(color.green, 82), "Buyside Liquidity", inline="LQ1", group=LIQUIDITY_GROUP)
liquiditySellsideColorInput    = input.color(color.new(color.red, 82),   "Sellside Liquidity", inline="LQ1", group=LIQUIDITY_GROUP)
liquidityTextColorInput        = input.color(color.white, "Liquidity Text", group=LIQUIDITY_GROUP)
liqExpandAfterHitInput         = input.bool(false, "Expand Swept Liquidity", group=LIQUIDITY_GROUP, tooltip="Keeps swept liquidity zones visible for a number of bars before deleting them.")
liqExpandBarsInput             = input.int(6, "Liquidity Expand Bars", group=LIQUIDITY_GROUP, minval=1, tooltip="How many bars a swept liquidity zone remains visible before deletion.")
liqDeleteSweptZones            = true

showLiquidityZonesActive       = showLiquidityZonesInput
showSwingLiquidityActive       = showLiquidityZonesActive and showSwingLiquidityInput
showEqualLiquidityActive       = showLiquidityZonesActive and showEqualLiquidityInput

// Displacement Engine
displacementATRLengthInput    = input.int(14, "ATR Length", group=DISPLACEMENT_GROUP, minval=1)
displacementATRMultInput      = input.float(1.2, "Range vs ATR", group=DISPLACEMENT_GROUP, minval=0.1, step=0.1, tooltip="Minimum candle range relative to ATR.")
displacementBodyRatioInput    = input.float(0.60, "Min Body Ratio", group=DISPLACEMENT_GROUP, minval=0.1, maxval=1.0, step=0.05, tooltip="Body size divided by full candle range.")
displacementCloseExtremeInput = input.float(0.20, "Close To Extreme", group=DISPLACEMENT_GROUP, minval=0.01, maxval=0.50, step=0.01, tooltip="How close the candle must close to its high/low.")

//---------------------------------------------------------------------------------------------------------------------}
//DATA STRUCTURES & VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
type alerts
    bool internalBullishBOS         = false
    bool internalBearishBOS         = false
    bool internalBullishCHoCH       = false
    bool internalBearishCHoCH       = false
    bool swingBullishBOS            = false
    bool swingBearishBOS            = false
    bool swingBullishCHoCH          = false
    bool swingBearishCHoCH          = false
    bool internalBullishOrderBlock  = false
    bool internalBearishOrderBlock  = false
    bool swingBullishOrderBlock     = false
    bool swingBearishOrderBlock     = false
    bool equalHighs                 = false
    bool equalLows                  = false
    bool bullishFairValueGap        = false
    bool bearishFairValueGap        = false

type trailingExtremes
    float top
    float bottom
    int barTime
    int barIndex
    int lastTopTime
    int lastBottomTime

type fairValueGap
    float top
    float bottom
    int bias
    float strengthRatio
    int deleteAfterBarIndex
    box topBox
    box bottomBox

type trend
    int bias

type equalDisplay
    line l_ine   = na
    label l_abel = na

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime  = time
    int barIndex = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime
    int bias
    float originVolume
    float volumeRatio
    int state
    int touches
    int createdBarIndex
    int deleteAfterBarIndex

type structureEvent
    string eventType = ""
    int bias = 0
    float level = na
    int barTime = na
    int barIndex = na
    float candleOpen = na
    float candleHigh = na
    float candleLow = na
    float candleClose = na

LIQ_BUYSIDE     = 1
LIQ_SELLSIDE    = -1

LIQ_ACTIVE      = 0
LIQ_APPROACHING = 1
LIQ_SWEPT       = 2

LIQ_SRC_SWING_HIGH = 1
LIQ_SRC_SWING_LOW  = 2
LIQ_SRC_EQH        = 3
LIQ_SRC_EQL        = 4

type liquidityZone
    float top
    float bottom
    int bias
    string kind
    int status
    int leftTime
    int createdBarIndex
    int sourceType
    float sourceWeight
    int deleteAfterBarIndex
    box zoneBox

var array<liquidityZone> liquidityZones = array.new<liquidityZone>()

var array<label> longSignalLabels  = array.new<label>()
var array<label> shortSignalLabels = array.new<label>()

var pivot swingHigh    = pivot.new(na, na, false)
var pivot swingLow     = pivot.new(na, na, false)
var pivot internalHigh = pivot.new(na, na, false)
var pivot internalLow  = pivot.new(na, na, false)
var pivot equalHigh    = pivot.new(na, na, false)
var pivot equalLow     = pivot.new(na, na, false)

var trend swingTrend    = trend.new(0)
var trend internalTrend = trend.new(0)

var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay  = equalDisplay.new()

var array<fairValueGap> fairValueGaps  = array.new<fairValueGap>()
var array<fairValueGap> fairValueGaps2 = array.new<fairValueGap>()

var array<float> parsedHighs      = array.new<float>()
var array<float> parsedLows       = array.new<float>()
var array<float> highs            = array.new<float>()
var array<float> lows             = array.new<float>()
var array<int>   times            = array.new<int>()
var array<float> volumes          = array.new<float>()
var array<float> volumeBaselines  = array.new<float>()

var trailingExtremes trailing = trailingExtremes.new()

var array<orderBlock> swingOrderBlocks    = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes      = array.new<box>()
var array<box> internalOrderBlocksBoxes   = array.new<box>()

var structureEvent lastIntradayStructureEvent = structureEvent.new()
var structureEvent lastEntryStructureEvent    = structureEvent.new()
var structureEvent lastChochEvent             = structureEvent.new()
var structureEvent lastAIEntryChochEvent      = structureEvent.new()
var structureEvent pendingAIChochEvent        = structureEvent.new()
var structureEvent lastFvgEvent               = structureEvent.new()

var string intradayStructureState = "NEUTRAL"
var string entryStructureState    = "NEUTRAL"
var string intradaySwingSequence  = ""
var string entrySwingSequence     = ""

var swingBullishColor        = styleInput == MONOCHROME ? MONO_BULLISH : swingBullColorInput
var swingBearishColor        = styleInput == MONOCHROME ? MONO_BEARISH : swingBearColorInput
var fairValueGapBullishColor = styleInput == MONOCHROME ? color.new(MONO_BULLISH, 70) : fairValueGapsBullColorInput
var fairValueGapBearishColor = styleInput == MONOCHROME ? color.new(MONO_BEARISH, 70) : fairValueGapsBearColorInput

var fairValueGapBullishColor2 = styleInput == MONOCHROME ? color.new(MONO_BULLISH, 70) : fairValueGapsBullColorInput2
var fairValueGapBearishColor2 = styleInput == MONOCHROME ? color.new(MONO_BEARISH, 70) : fairValueGapsBearColorInput2

alerts currentAlerts = alerts.new()
var initialTime      = time

var bool bullishTradeRelevantSweep = false
var bool bearishTradeRelevantSweep = false

varip int currentBarIndex = bar_index
varip int lastBarIndex    = bar_index

if barstate.isfirst
    for index = 1 to orderBlocksNumberInput
        swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))
        internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))

bearishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : low
atrMeasure                        = ta.atr(200)
aiEntryAtr                        = ta.atr(displacementATRLengthInput)
volatilityMeasure                 = atrMeasure
highVolatilityBar                 = (high - low) >= (2 * volatilityMeasure)
parsedHigh                        = highVolatilityBar ? low : high
parsedLow                         = highVolatilityBar ? high : low

//---------------------------------------------------------------------------------------------------------------------}
//USER-DEFINED FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
leg(int size) =>
    var int _leg = 0
    newLegHigh = high[size] > ta.highest(size)
    newLegLow  = low[size]  < ta.lowest(size)

    if newLegHigh
        _leg := BEARISH_LEG
    else if newLegLow
        _leg := BULLISH_LEG
    _leg

startOfNewLeg(int _leg)      => ta.change(_leg) != 0
startOfBearishLeg(int _leg)  => ta.change(_leg) == -1
startOfBullishLeg(int _leg)  => ta.change(_leg) == +1

f_pushFloat(array<float> _arr, float _value, int _maxSize) =>
    array.push(_arr, _value)
    if array.size(_arr) > _maxSize
        array.shift(_arr)

f_pushInt(array<int> _arr, int _value, int _maxSize) =>
    array.push(_arr, _value)
    if array.size(_arr) > _maxSize
        array.shift(_arr)

f_pushFloat(parsedHighs, parsedHigh, MAX_HISTORY_CORE)
f_pushFloat(parsedLows, parsedLow, MAX_HISTORY_CORE)
f_pushFloat(highs, high, MAX_HISTORY_LVL)
f_pushFloat(lows, low, MAX_HISTORY_LVL)
f_pushInt(times, time, MAX_HISTORY_LVL)

volumeBaseline = ta.sma(volume, obVolumeMALengthInput)
f_pushFloat(volumes, volume, MAX_HISTORY_OB)
f_pushFloat(volumeBaselines, volumeBaseline, MAX_HISTORY_OB)

f_structureBiasToText(int _bias) =>
    _bias == BULLISH ? "BULLISH" : _bias == BEARISH ? "BEARISH" : "NEUTRAL"

f_storeStructureEvent(bool _internal, string _eventType, int _bias, float _level, int _barTime, int _barIndex) =>
    if _internal
        lastEntryStructureEvent.eventType := _eventType
        lastEntryStructureEvent.bias      := _bias
        lastEntryStructureEvent.level     := _level
        lastEntryStructureEvent.barTime   := _barTime
        lastEntryStructureEvent.barIndex  := _barIndex
    else
        lastIntradayStructureEvent.eventType := _eventType
        lastIntradayStructureEvent.bias      := _bias
        lastIntradayStructureEvent.level     := _level
        lastIntradayStructureEvent.barTime   := _barTime
        lastIntradayStructureEvent.barIndex  := _barIndex

f_storeLastChoch(int _bias, float _level, int _barTime, int _barIndex, float _open, float _high, float _low, float _close) =>
    lastChochEvent.eventType   := CHOCH
    lastChochEvent.bias        := _bias
    lastChochEvent.level       := _level
    lastChochEvent.barTime     := _barTime
    lastChochEvent.barIndex    := _barIndex
    lastChochEvent.candleOpen  := _open
    lastChochEvent.candleHigh  := _high
    lastChochEvent.candleLow   := _low
    lastChochEvent.candleClose := _close

f_storeAIEntryChoch(int _bias, float _level, int _barTime, int _barIndex, float _open, float _high, float _low, float _close) =>
    lastAIEntryChochEvent.eventType   := CHOCH
    lastAIEntryChochEvent.bias        := _bias
    lastAIEntryChochEvent.level       := _level
    lastAIEntryChochEvent.barTime     := _barTime
    lastAIEntryChochEvent.barIndex    := _barIndex
    lastAIEntryChochEvent.candleOpen  := _open
    lastAIEntryChochEvent.candleHigh  := _high
    lastAIEntryChochEvent.candleLow   := _low
    lastAIEntryChochEvent.candleClose := _close

f_storePendingAIChoch(int _bias, float _level, int _barTime, int _barIndex, float _open, float _high, float _low, float _close) =>
    pendingAIChochEvent.eventType   := CHOCH
    pendingAIChochEvent.bias        := _bias
    pendingAIChochEvent.level       := _level
    pendingAIChochEvent.barTime     := _barTime
    pendingAIChochEvent.barIndex    := _barIndex
    pendingAIChochEvent.candleOpen  := _open
    pendingAIChochEvent.candleHigh  := _high
    pendingAIChochEvent.candleLow   := _low
    pendingAIChochEvent.candleClose := _close

f_storeLastFvg(int _bias, int _barTime, int _barIndex) =>
    lastFvgEvent.eventType := "FVG"
    lastFvgEvent.bias      := _bias
    lastFvgEvent.level     := na
    lastFvgEvent.barTime   := _barTime
    lastFvgEvent.barIndex  := _barIndex

f_isRecent(int _eventBarIndex, int _maxBars) =>
    not na(_eventBarIndex) and (bar_index - _eventBarIndex) >= 0 and (bar_index - _eventBarIndex) <= _maxBars

f_biasText(int _bias) =>
    _bias == BULLISH ? "Bullish" : _bias == BEARISH ? "Bearish" : "Neutral"

f_biasColor(int _bias) =>
    _bias == BULLISH ? color.lime : _bias == BEARISH ? color.red : text_color_ema

f_structureText(bool _fresh) =>
    _fresh ? "CHoCH" : ""

f_structureColor(int _bias, bool _fresh) =>
    _fresh ? (_bias == BULLISH ? color.lime : color.red) : text_color_ema

f_fvgValidWithChoch(int _fvgBias, int _chochBias, int _fvgBarIndex, int _chochBarIndex) =>
    not na(_fvgBarIndex) and not na(_chochBarIndex) and _fvgBias == _chochBias and ((_chochBarIndex >= _fvgBarIndex and (_chochBarIndex - _fvgBarIndex) <= 10) or (_fvgBarIndex > _chochBarIndex and (_fvgBarIndex - _chochBarIndex) <= 5))

f_fvgText(bool _valid) =>
    _valid ? "FVG" : ""

f_fvgColorTable(bool _valid, int _fvgBias) =>
    _valid ? (_fvgBias == BULLISH ? color.lime : color.red) : text_color_ema

f_tradeText(int _htfBias, int _ltfBias) =>
    _htfBias == _ltfBias ? (_htfBias == BULLISH ? "Short PB" : _htfBias == BEARISH ? "Long PB" : "") : (_htfBias == BULLISH ? "Long CON" : _htfBias == BEARISH ? "Short CON" : "")

f_tradeColor(int _htfBias, int _ltfBias) =>
    _htfBias == _ltfBias ? (_htfBias == BULLISH ? color.red : _htfBias == BEARISH ? color.lime : text_color_ema) : (_htfBias == BULLISH ? color.lime : _htfBias == BEARISH ? color.red : text_color_ema)

f_entryText(bool _structureFresh) =>
    _structureFresh ? "✔" : ""

f_entryColor(bool _structureFresh, int _structureBias) =>
    _structureFresh ? (_structureBias == BULLISH ? color.lime : color.red) : text_color_ema

f_findStartIdxByTime(array<int> _times, int _startTime) =>
    int idx = array.binary_search_leftmost(_times, _startTime)
    idx < 0 ? 0 : idx

f_clampIndex(int _idx, int _min, int _max) =>
    math.max(_min, math.min(_max, _idx))

f_findRightIdxByTime(array<int> _times, int _targetTime) =>
    int idx = array.binary_search_rightmost(_times, _targetTime)
    idx < 0 ? 0 : idx

f_getStructureStates() =>
    [f_structureBiasToText(swingTrend.bias), f_structureBiasToText(internalTrend.bias)]

f_calcAIHTFSwingBias(int _len) =>
    var float _lastHigh = na
    var float _lastLow  = na
    var int _bias = 0

    float _pivotHigh = ta.pivothigh(high, _len, _len)
    float _pivotLow  = ta.pivotlow(low, _len, _len)

    if not na(_pivotHigh)
        _lastHigh := _pivotHigh

    if not na(_pivotLow)
        _lastLow := _pivotLow

    bool _bullBreak = not na(_lastHigh) and close > _lastHigh
    bool _bearBreak = not na(_lastLow) and close < _lastLow

    if _bullBreak
        _bias := BULLISH
    else if _bearBreak
        _bias := BEARISH

    _bias
//━━━━━━━━━━━━━━━━━━
// AI Entry Helper
//━━━━━━━━━━━━━━━━━━
f_isSignalSession() =>
    bool londonOk  = not na(time(timeframe.period, LONDON_SESSION_FULL, BASE_TZ))
    bool newYorkOk = not na(time(timeframe.period, NY_SESSION_FULL, BASE_TZ))

    switch aiSignalSessionModeInput
        "London Session"   => londonOk
        "New York Session" => newYorkOk
        "Full Session"     => londonOk or newYorkOk
        "Day"              => true
        => true

f_isBullishDisplacementConfirm(float _open, float _high, float _low, float _close, float _atr) =>
    float _range = _high - _low
    float _body  = _close > _open ? _close - _open : 0.0
    float _bodyRatio = _range > 0 ? _body / _range : 0.0
    bool _rangeOk = _range >= _atr * displacementATRMultInput
    bool _bodyOk  = _bodyRatio >= displacementBodyRatioInput
    bool _closeOk = _range > 0 ? (_high - _close) <= _range * displacementCloseExtremeInput : false
    _close > _open and _rangeOk and _bodyOk and _closeOk

f_isBearishDisplacementConfirm(float _open, float _high, float _low, float _close, float _atr) =>
    float _range = _high - _low
    float _body  = _close < _open ? _open - _close : 0.0
    float _bodyRatio = _range > 0 ? _body / _range : 0.0
    bool _rangeOk = _range >= _atr * displacementATRMultInput
    bool _bodyOk  = _bodyRatio >= displacementBodyRatioInput
    bool _closeOk = _range > 0 ? (_close - _low) <= _range * displacementCloseExtremeInput : false
    _close < _open and _rangeOk and _bodyOk and _closeOk

f_isExtremeSpike(structureEvent _e) =>
    float r = _e.candleHigh - _e.candleLow
    float b = math.abs(_e.candleClose - _e.candleOpen)
    float domWick = _e.bias == BULLISH ? (_e.candleHigh - math.max(_e.candleOpen, _e.candleClose)) : (math.min(_e.candleOpen, _e.candleClose) - _e.candleLow)
    bool wickTooLarge = r > 0 ? (domWick / r) > aiEntrySpikeWickRatioInput : false
    bool tinyBody     = r > 0 ? (b / r) < aiEntrySpikeBodyRatioInput : true
    aiEntryRejectSpikeInput and wickTooLarge and tinyBody

f_isTinyRangeChoch(structureEvent _e) =>
    float r = _e.candleHigh - _e.candleLow
    aiEntryRejectSmallRangeInput and r < aiEntryAtr * aiEntryTinyRangeAtrMultInput

f_followThroughOk(structureEvent _e) =>
    float buffer = aiEntryAtr * 0.002
    _e.bias == BULLISH
         ? (close > (_e.level + buffer) and close >= _e.candleClose)
         : (close < (_e.level - buffer) and close <= _e.candleClose)

f_isImmediateAIValid(structureEvent _e) =>
    bool sessionOk = f_isSignalSession()
    bool notSpike  = not f_isExtremeSpike(_e)
    bool notTiny   = not f_isTinyRangeChoch(_e)

    bool optionalDisplacement =
         not useDisplacementConfirmationInput or
         (_e.bias == BULLISH
            ? f_isBullishDisplacementConfirm(_e.candleOpen, _e.candleHigh, _e.candleLow, _e.candleClose, aiEntryAtr)
            : f_isBearishDisplacementConfirm(_e.candleOpen, _e.candleHigh, _e.candleLow, _e.candleClose, aiEntryAtr))

    sessionOk and notSpike and notTiny and optionalDisplacement

f_isConfirmedAIValid(structureEvent _e) =>
    bool sessionOk = f_isSignalSession()
    bool confirmOk = f_followThroughOk(_e)

    bool optionalDisplacement =
         not useDisplacementConfirmationInput or
         (_e.bias == BULLISH
            ? f_isBullishDisplacementConfirm(open, high, low, close, aiEntryAtr)
            : f_isBearishDisplacementConfirm(open, high, low, close, aiEntryAtr))

    sessionOk and confirmOk and optionalDisplacement
    
f_trimSignalLabels(array<label> _arr, int _maxCount) =>
    while array.size(_arr) > _maxCount
        label _old = array.shift(_arr)
        if not na(_old)
            label.delete(_old)

drawLabel(int labelTime, float labelPrice, string tag, color labelColor, string labelStyle) =>
    var label l_abel = na

    if modeInput == PRESENT
        l_abel.delete()

    l_abel := label.new(chart.point.new(labelTime, na, labelPrice), tag, xloc.bar_time, color=color(na), textcolor=labelColor, style=labelStyle, size=size.small)

drawEqualHighLow(pivot p_ivot, float level, int size, bool isEqualHigh) =>
    equalDisplay e_qualDisplay = isEqualHigh ? equalHighDisplay : equalLowDisplay

    string tag = "EQL"
    color equalColor = swingBullishColor
    string labelStyle = label.style_label_up

    if isEqualHigh
        tag := "EQH"
        equalColor := swingBearishColor
        labelStyle := label.style_label_down

    if modeInput == PRESENT
        line.delete(e_qualDisplay.l_ine)
        label.delete(e_qualDisplay.l_abel)

    e_qualDisplay.l_ine := line.new(
        chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel),
        chart.point.new(time[size], na, level),
        xloc=xloc.bar_time,
        color=equalColor,
        style=line.style_dotted
    )

    labelPosition = math.round(0.5 * (p_ivot.barIndex + bar_index - size))
    e_qualDisplay.l_abel := label.new(
        chart.point.new(na, labelPosition, level),
        tag,
        xloc.bar_index,
        color=color(na),
        textcolor=equalColor,
        style=labelStyle,
        size=equalHighsLowsSizeInput
    )

f_getLiquiditySourceWeight(int _sourceType) =>
    switch _sourceType
        LIQ_SRC_SWING_HIGH => 1.0
        LIQ_SRC_SWING_LOW  => 1.0
        LIQ_SRC_EQH        => 1.2
        LIQ_SRC_EQL        => 1.2
        => 1.0

f_liqStatusColor(int _bias, int _status) =>
    _bias == LIQ_BUYSIDE ? liquidityBuysideColorInput : liquiditySellsideColorInput

f_liqIsSweepStatus(int _status) =>
    _status == LIQ_SWEPT

f_liqZoneExists(float _top, float _bottom, int _bias, int _sourceType) =>
    bool exists = false
    float tolerance = atrMeasure * liquidityZonePadATRInput * 0.5

    int zoneCount = array.size(liquidityZones)
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            liquidityZone z = array.get(liquidityZones, i)

            bool sameBias = z.bias == _bias
            bool sameSource = z.sourceType == _sourceType

            bool topClose = math.abs(z.top - _top) <= tolerance
            bool bottomClose = math.abs(z.bottom - _bottom) <= tolerance

            if sameBias and sameSource and topClose and bottomClose
                exists := true
                break

    exists

f_addLiquidityZone(float _top, float _bottom, int _bias, string _kind, int _leftTime, int _sourceType) =>
    if showLiquidityZonesActive and _top > _bottom
        bool alreadyExists = f_liqZoneExists(_top, _bottom, _bias, _sourceType)

        if not alreadyExists
            color zoneColor = f_liqStatusColor(_bias, LIQ_ACTIVE)

            box zoneBox = box.new(
                chart.point.new(_leftTime, na, _top),
                chart.point.new(last_bar_time + liquidityExtendBarsInput * (time - time[1]), na, _bottom),
                xloc = xloc.bar_time,
                border_color = zoneColor,
                bgcolor = zoneColor,
                text = "",
                text_color = liquidityTextColorInput,
                text_halign = text.align_right,
                text_valign = text.align_bottom,
                text_size = size.tiny
            )

            liquidityZone newZone = liquidityZone.new(
                _top,
                _bottom,
                _bias,
                _kind,
                LIQ_ACTIVE,
                _leftTime,
                bar_index,
                _sourceType,
                f_getLiquiditySourceWeight(_sourceType),
                na,
                zoneBox
            )

            array.unshift(liquidityZones, newZone)

            if array.size(liquidityZones) > liquidityMaxZonesInput
                liquidityZone oldZone = array.pop(liquidityZones)
                oldZone.zoneBox.delete()

f_buildSwingLiquidityZone(float _level, int _bias, string _kind, int _leftTime, int _sourceType) =>
    float pad = atrMeasure * liquidityZonePadATRInput
    f_addLiquidityZone(_level + pad, _level - pad, _bias, _kind, _leftTime, _sourceType)

f_buildEqualLiquidityZone(float _levelA, float _levelB, int _bias, string _kind, int _leftTime, int _sourceType) =>
    float pad = atrMeasure * liquidityZonePadATRInput * 0.5
    float hi = math.max(_levelA, _levelB) + pad
    float lo = math.min(_levelA, _levelB) - pad
    f_addLiquidityZone(hi, lo, _bias, _kind, _leftTime, _sourceType)

f_liqTextForZone(liquidityZone _z) =>
    _z.kind

f_liqColorForZone(liquidityZone _z) =>
    f_liqStatusColor(_z.bias, _z.status)

f_liqShouldShowZone(liquidityZone _z) =>
    bool expanding = not na(_z.deleteAfterBarIndex) and bar_index < _z.deleteAfterBarIndex
    _z.status == LIQ_ACTIVE or _z.status == LIQ_APPROACHING or expanding

f_liqDistanceToPrice(liquidityZone _z, float _price) =>
    _price > _z.top ? _price - _z.top : _price < _z.bottom ? _z.bottom - _price : 0.0

f_liqContainsPrice(liquidityZone _z, float _price) =>
    _price <= _z.top and _price >= _z.bottom

f_liqIsAbovePrice(liquidityZone _z, float _price) =>
    _z.bottom > _price

f_liqIsBelowPrice(liquidityZone _z, float _price) =>
    _z.top < _price

f_liqInsertSorted(array<int> _idxs, array<float> _dists, int _idx, float _dist) =>
    int pos = array.size(_idxs)

    if pos == 0
        array.push(_idxs, _idx)
        array.push(_dists, _dist)
    else
        bool inserted = false
        for j = 0 to array.size(_idxs) - 1
            if _dist < array.get(_dists, j)
                array.insert(_idxs, j, _idx)
                array.insert(_dists, j, _dist)
                inserted := true
                break

        if not inserted
            array.push(_idxs, _idx)
            array.push(_dists, _dist)

f_liqPushUnique(array<int> _selected, int _idx) =>
    bool exists = false
    if array.size(_selected) > 0
        for i = 0 to array.size(_selected) - 1
            if array.get(_selected, i) == _idx
                exists := true
                break
    if not exists
        array.push(_selected, _idx)

f_liqApplyVisibility(liquidityZone _z, bool _visible) =>
    color visibleColor = f_liqColorForZone(_z)
    color hiddenColor  = color.new(color.black, 100)
    string txt         = _visible ? f_liqTextForZone(_z) : ""

    box.set_bgcolor(_z.zoneBox, _visible ? visibleColor : hiddenColor)
    box.set_border_color(_z.zoneBox, _visible ? visibleColor : hiddenColor)
    box.set_text(_z.zoneBox, txt)
    box.set_text_color(_z.zoneBox, liquidityTextColorInput)
    box.set_text_halign(_z.zoneBox, text.align_right)
    box.set_text_valign(_z.zoneBox, text.align_bottom)
    box.set_text_size(_z.zoneBox, size.tiny)

f_drawSelectedLiquidityZones() =>
    int total = array.size(liquidityZones)
    array<int> selected = array.new<int>()

    if total > 0
        int maxCount = math.min(liquidityMaxZonesInput, total)

        if liquidityDisplayMaxModeInput == FVG_MODE_TIME
            int picked = 0
            for i = 0 to total - 1
                liquidityZone z = array.get(liquidityZones, i)
                if f_liqShouldShowZone(z)
                    array.push(selected, i)
                    picked += 1
                    if picked >= maxCount
                        break
        else
            array<int> insideIdx = array.new<int>()
            array<float> insideDist = array.new<float>()

            array<int> aboveIdx = array.new<int>()
            array<float> aboveDist = array.new<float>()

            array<int> belowIdx = array.new<int>()
            array<float> belowDist = array.new<float>()

            for i = 0 to total - 1
                liquidityZone z = array.get(liquidityZones, i)

                if f_liqShouldShowZone(z)
                    float dist = f_liqDistanceToPrice(z, close)

                    if f_liqContainsPrice(z, close)
                        f_liqInsertSorted(insideIdx, insideDist, i, dist)
                    else if f_liqIsAbovePrice(z, close)
                        f_liqInsertSorted(aboveIdx, aboveDist, i, dist)
                    else if f_liqIsBelowPrice(z, close)
                        f_liqInsertSorted(belowIdx, belowDist, i, dist)

            int insideCount = array.size(insideIdx)
            if insideCount > 0 and maxCount > 0
                int insideTake = math.min(maxCount, insideCount)
                for i = 0 to insideTake - 1
                    f_liqPushUnique(selected, array.get(insideIdx, i))

            int remaining = maxCount - array.size(selected)

            if remaining > 0
                int aboveCount = array.size(aboveIdx)
                int belowCount = array.size(belowIdx)

                int targetAbove = int(math.floor(remaining * 0.5))
                int targetBelow = remaining - targetAbove

                if aboveCount > 0 and belowCount > 0
                    targetAbove := math.max(1, targetAbove)
                    targetBelow := math.max(1, targetBelow)

                    if targetAbove + targetBelow > remaining
                        targetAbove := 1
                        targetBelow := remaining - 1

                int takeAbove = math.min(targetAbove, aboveCount)
                int takeBelow = math.min(targetBelow, belowCount)

                if takeAbove > 0
                    for i = 0 to takeAbove - 1
                        f_liqPushUnique(selected, array.get(aboveIdx, i))

                if takeBelow > 0
                    for i = 0 to takeBelow - 1
                        f_liqPushUnique(selected, array.get(belowIdx, i))

                int nextAbove = takeAbove
                int nextBelow = takeBelow

                while array.size(selected) < maxCount and (nextAbove < aboveCount or nextBelow < belowCount)
                    bool canUseAbove = nextAbove < aboveCount
                    bool canUseBelow = nextBelow < belowCount

                    if canUseAbove and canUseBelow
                        float distAbove = array.get(aboveDist, nextAbove)
                        float distBelow = array.get(belowDist, nextBelow)

                        if distAbove <= distBelow
                            f_liqPushUnique(selected, array.get(aboveIdx, nextAbove))
                            nextAbove += 1
                        else
                            f_liqPushUnique(selected, array.get(belowIdx, nextBelow))
                            nextBelow += 1
                    else if canUseAbove
                        f_liqPushUnique(selected, array.get(aboveIdx, nextAbove))
                        nextAbove += 1
                    else if canUseBelow
                        f_liqPushUnique(selected, array.get(belowIdx, nextBelow))
                        nextBelow += 1

        int selectedCount = array.size(selected)

        for i = 0 to total - 1
            bool visible = false

            if selectedCount > 0
                for j = 0 to selectedCount - 1
                    if array.get(selected, j) == i
                        visible := true
                        break

            liquidityZone z = array.get(liquidityZones, i)
            f_liqApplyVisibility(z, visible)

f_updateLiquidityZones() =>
    bool bullValidated = false
    bool bearValidated = false

    float approachDist = atrMeasure * liquidityApproachATRInput
    int rightTime      = last_bar_time + liquidityExtendBarsInput * (time - time[1])

    int i = array.size(liquidityZones) - 1
    while i >= 0
        liquidityZone z = array.get(liquidityZones, i)

        bool isBuyside = z.bias == LIQ_BUYSIDE

        bool sweptNow =
             isBuyside
             ? high > z.top
             : low < z.bottom

        bool approachingNow =
             isBuyside
             ? close < z.bottom and (z.bottom - close) <= approachDist
             : close > z.top and (close - z.top) <= approachDist

        int newStatus = z.status

        if sweptNow
            newStatus := LIQ_SWEPT
        else if approachingNow
            newStatus := LIQ_APPROACHING
        else
            newStatus := LIQ_ACTIVE

        z.status := newStatus

        bool deleteNow = false

        if liqDeleteSweptZones and f_liqIsSweepStatus(newStatus)
            if liqExpandAfterHitInput
                if na(z.deleteAfterBarIndex)
                    z.deleteAfterBarIndex := bar_index + liqExpandBarsInput
            else
                deleteNow := true

        if not na(z.deleteAfterBarIndex) and bar_index >= z.deleteAfterBarIndex
            deleteNow := true

        if deleteNow
            z.zoneBox.delete()
            array.remove(liquidityZones, i)
        else
            box.set_top_left_point(z.zoneBox, chart.point.new(z.leftTime, na, z.top))
            box.set_bottom_right_point(z.zoneBox, chart.point.new(rightTime, na, z.bottom))

            color c = f_liqColorForZone(z)
            box.set_bgcolor(z.zoneBox, c)
            box.set_border_color(z.zoneBox, c)
            box.set_text_color(z.zoneBox, liquidityTextColorInput)
            box.set_text_halign(z.zoneBox, text.align_right)
            box.set_text_valign(z.zoneBox, text.align_bottom)
            box.set_text_size(z.zoneBox, size.tiny)

            array.set(liquidityZones, i, z)

        i -= 1

    [bullValidated, bearValidated]

f_runLiquidityEngine() =>
    if showLiquidityZonesActive
        [bullValidated, bearValidated] = f_updateLiquidityZones()
        [bullValidated, bearValidated]
    else
        [false, false]

getCurrentStructure(int size, bool internal = false) =>
    string sequenceOut = ""

    currentLeg = leg(size)
    newPivot   = startOfNewLeg(currentLeg)
    pivotLow   = startOfBullishLeg(currentLeg)
    pivotHigh  = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            pivot p_ivot = internal ? internalLow : swingLow

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := low[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]

            if not internal
                trailing.bottom         := p_ivot.currentLevel
                trailing.barTime        := p_ivot.barTime
                trailing.barIndex       := p_ivot.barIndex
                trailing.lastBottomTime := p_ivot.barTime

                if showSwingLiquidityActive
                    f_buildSwingLiquidityZone(low[size], LIQ_SELLSIDE, "SWING LOW", time[size], LIQ_SRC_SWING_LOW)

            sequenceOut := na(p_ivot.lastLevel) ? "" : p_ivot.currentLevel < p_ivot.lastLevel ? "LL" : "HL"

            if showSwingsInput and not internal
                drawLabel(time[size], p_ivot.currentLevel, p_ivot.currentLevel < p_ivot.lastLevel ? "LL" : "HL", swingBullishColor, label.style_label_up)
        else
            pivot p_ivot = internal ? internalHigh : swingHigh

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]

            if not internal
                trailing.top         := p_ivot.currentLevel
                trailing.barTime     := p_ivot.barTime
                trailing.barIndex    := p_ivot.barIndex
                trailing.lastTopTime := p_ivot.barTime

                if showSwingLiquidityActive
                    f_buildSwingLiquidityZone(high[size], LIQ_BUYSIDE, "SWING HIGH", time[size], LIQ_SRC_SWING_HIGH)

            sequenceOut := na(p_ivot.lastLevel) ? "" : p_ivot.currentLevel > p_ivot.lastLevel ? "HH" : "LH"

            if showSwingsInput and not internal
                drawLabel(time[size], p_ivot.currentLevel, p_ivot.currentLevel > p_ivot.lastLevel ? "HH" : "LH", swingBearishColor, label.style_label_down)

    sequenceOut

f_runEqualHighLowEngine(int size) =>
    int currentLeg = leg(size)
    bool newPivot  = startOfNewLeg(currentLeg)
    bool pivotLow  = startOfBullishLeg(currentLeg)
    bool pivotHigh = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            bool hasReference = not na(equalLow.currentLevel)
            bool isEqualLow   = hasReference and math.abs(equalLow.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure

            if isEqualLow
                currentAlerts.equalLows := true

                if showEqualHighsLowsActive
                    drawEqualHighLow(equalLow, low[size], size, false)

                if showStructureEngineInput and showEqualLiquidityActive
                    f_buildEqualLiquidityZone(equalLow.currentLevel, low[size], LIQ_SELLSIDE, "EQL", time[size], LIQ_SRC_EQL)

            equalLow.lastLevel    := equalLow.currentLevel
            equalLow.currentLevel := low[size]
            equalLow.crossed      := false
            equalLow.barTime      := time[size]
            equalLow.barIndex     := bar_index[size]

        else if pivotHigh
            bool hasReference = not na(equalHigh.currentLevel)
            bool isEqualHigh  = hasReference and math.abs(equalHigh.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure

            if isEqualHigh
                currentAlerts.equalHighs := true

                if showEqualHighsLowsActive
                    drawEqualHighLow(equalHigh, high[size], size, true)

                if showStructureEngineInput and showEqualLiquidityActive
                    f_buildEqualLiquidityZone(equalHigh.currentLevel, high[size], LIQ_BUYSIDE, "EQH", time[size], LIQ_SRC_EQH)

            equalHigh.lastLevel    := equalHigh.currentLevel
            equalHigh.currentLevel := high[size]
            equalHigh.crossed      := false
            equalHigh.barTime      := time[size]
            equalHigh.barIndex     := bar_index[size]

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>
    var line l_ine = line.new(na, na, na, na, xloc=xloc.bar_time)
    var label l_abel = label.new(na, na)

    if modeInput == PRESENT
        l_ine.delete()
        l_abel.delete()

    l_ine := line.new(chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel), chart.point.new(time, na, p_ivot.currentLevel), xloc.bar_time, color=structureColor, style=lineStyle)
    l_abel := label.new(chart.point.new(na, math.round(0.5 * (p_ivot.barIndex + bar_index)), p_ivot.currentLevel), tag, xloc.bar_index, color=color(na), textcolor=structureColor, style=labelStyle, size=labelSize)

getStyle(string style) =>
    switch style
        SOLID  => line.style_solid
        DASHED => line.style_dashed
        DOTTED => line.style_dotted

drawLevels(string timeframe, bool sameTimeframe, string style, color levelColor) =>
    [topLevel, bottomLevel, leftTime, rightTime] = request.security(syminfo.tickerid, timeframe, [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)

    float parsedTop      = sameTimeframe ? high : topLevel
    float parsedBottom   = sameTimeframe ? low : bottomLevel
    int parsedLeftTime   = sameTimeframe ? time : leftTime
    int parsedRightTime  = sameTimeframe ? time : rightTime
    int parsedTopTime    = time
    int parsedBottomTime = time

    if not sameTimeframe
        int maxIdx = math.max(array.size(times) - 1, 0)

        int leftIndexRaw  = f_findRightIdxByTime(times, parsedLeftTime)
        int rightIndexRaw = f_findRightIdxByTime(times, parsedRightTime)

        int leftIndex  = f_clampIndex(leftIndexRaw, 0, maxIdx)
        int rightIndex = f_clampIndex(rightIndexRaw, 0, maxIdx)

        if rightIndex <= leftIndex
            rightIndex := math.min(leftIndex + 1, array.size(times))

        array<int>   timeArray   = times.slice(leftIndex, rightIndex)
        array<float> topArray    = highs.slice(leftIndex, rightIndex)
        array<float> bottomArray = lows.slice(leftIndex, rightIndex)

        if array.size(timeArray) > 0 and array.size(topArray) > 0 and array.size(bottomArray) > 0
            parsedTopTime    := timeArray.get(topArray.indexof(topArray.max()))
            parsedBottomTime := timeArray.get(bottomArray.indexof(bottomArray.min()))
        else
            parsedTopTime    := initialTime
            parsedBottomTime := initialTime

    var line topLine      = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var line bottomLine   = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var label topLabel    = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}H', timeframe), color=color(na), textcolor = levelColor, size = size.small, style = label.style_label_left)
    var label bottomLabel = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}L', timeframe), color=color(na), textcolor = levelColor, size = size.small, style = label.style_label_left)

    topLine.set_first_point(chart.point.new(parsedTopTime,na,parsedTop))
    topLine.set_second_point(chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedTop))
    topLabel.set_point(chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedTop))

    bottomLine.set_first_point(chart.point.new(parsedBottomTime,na,parsedBottom))
    bottomLine.set_second_point(chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedBottom))
    bottomLabel.set_point(chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedBottom))

higherTimeframe(string tf) => timeframe.in_seconds() > timeframe.in_seconds(tf)

f_obMinVolumeRatio() =>
    switch obVolumeFilterInput
        VOL_OFF    => 0.0
        VOL_LOW    => 0.80
        VOL_NORMAL => 1.00
        VOL_HIGH   => 1.25
        => 0.0

f_obQualityScore(int _state) =>
    switch _state
        OB_FRESH     => 1.00
        OB_TESTED    => 0.75
        OB_MITIGATED => 0.45
        OB_INVALID   => 0.00
        => 0.00

f_obFreshnessScore(int _createdBarIndex) =>
    float age = bar_index - _createdBarIndex
    float maxAge = 150.0
    float score = 1.0 - math.min(age, maxAge) / maxAge
    math.max(0.0, score)

f_obVolumeScore(float _volumeRatio) =>
    float minRatio = 0.70
    float maxRatio = 1.80
    float clamped = math.max(minRatio, math.min(maxRatio, _volumeRatio))
    (clamped - minRatio) / (maxRatio - minRatio)

f_obStrengthScore(orderBlock _ob) =>
    float volScore   = f_obVolumeScore(_ob.volumeRatio)
    float qualScore  = f_obQualityScore(_ob.state)
    float freshScore = f_obFreshnessScore(_ob.createdBarIndex)
    0.70 * volScore + 0.20 * qualScore + 0.10 * freshScore

f_obPassDisplayFilter(orderBlock _ob) =>
    obVolumeFilterInput == VOL_OFF ? true : _ob.volumeRatio >= f_obMinVolumeRatio()

f_obWeakTransparency() =>
    switch obDynamicRangeInput
        1 => 99
        2 => 97
        3 => 94
        4 => 88
        5 => 80
        => 97

f_obStrongTransparency() =>
    switch obDynamicRangeInput
        1 => 84
        2 => 74
        3 => 64
        4 => 54
        5 => 44
        => 72

f_obTransparency(float _volumeRatio) =>
    float minRatio = 0.80
    float maxRatio = 1.50

    float clampedRatio = math.max(minRatio, math.min(maxRatio, _volumeRatio))
    float norm = (clampedRatio - minRatio) / (maxRatio - minRatio)

    int weakTransp = f_obWeakTransparency()
    int strongTransp = f_obStrongTransparency()

    int(math.round(weakTransp - norm * (weakTransp - strongTransp)))

f_obStatePenalty(int _state) =>
    switch _state
        OB_FRESH     => 0
        OB_TESTED    => 8
        OB_MITIGATED => 18
        OB_INVALID   => 30
        => 0

f_obMid(float _high, float _low) =>
    math.avg(_high, _low)

f_bullishOBTouched(orderBlock _ob) =>
    low <= _ob.barHigh and high >= _ob.barLow

f_bearishOBTouched(orderBlock _ob) =>
    high >= _ob.barLow and low <= _ob.barHigh

f_bullishOBMitigated(orderBlock _ob) =>
    low <= f_obMid(_ob.barHigh, _ob.barLow)

f_bearishOBMitigated(orderBlock _ob) =>
    high >= f_obMid(_ob.barHigh, _ob.barLow)

f_obVolumeRatio(int _idx) =>
    float originVol  = volumes.get(_idx)
    float originBase = volumeBaselines.get(_idx)
    na(originBase) or originBase <= 0 ? 1.0 : originVol / originBase

f_obRangesOverlap(float _highA, float _lowA, float _highB, float _lowB) =>
    math.min(_highA, _highB) > math.max(_lowA, _lowB)

f_internalOBOverlapsVisibleSwing(orderBlock _internalOb, array<orderBlock> _swingBlocks, int _maxCount) =>
    bool _overlap = false

    int _limit = math.min(_maxCount, array.size(_swingBlocks))
    if _limit > 0
        for j = 0 to _limit - 1
            orderBlock _swingOb = array.get(_swingBlocks, j)
            if f_obRangesOverlap(_internalOb.barHigh, _internalOb.barLow, _swingOb.barHigh, _swingOb.barLow)
                _overlap := true
                break

    _overlap

storeOrdeBlock(pivot p_ivot, bool internal = false, int bias) =>
    if (not internal and useSwingOrderBlocks) or (internal and useInternalOrderBlocks)
        int startIdx = f_findStartIdxByTime(times, p_ivot.barTime)
        int endIdx   = array.size(times)

        if startIdx >= 0 and startIdx < endIdx
            array<float> a_rray = na
            int parsedIndex = na

            if bias == BEARISH
                a_rray := parsedHighs.slice(startIdx, endIdx)
                if array.size(a_rray) > 0
                    parsedIndex := startIdx + a_rray.indexof(a_rray.max())
            else
                a_rray := parsedLows.slice(startIdx, endIdx)
                if array.size(a_rray) > 0
                    parsedIndex := startIdx + a_rray.indexof(a_rray.min())

            if not na(parsedIndex) and parsedIndex >= 0 and parsedIndex < array.size(times)
                float obVol      = volumes.get(parsedIndex)
                float obVolRatio = f_obVolumeRatio(parsedIndex)

                orderBlock o_rderBlock = orderBlock.new(
                    parsedHighs.get(parsedIndex),
                    parsedLows.get(parsedIndex),
                    times.get(parsedIndex),
                    bias,
                    obVol,
                    obVolRatio,
                    OB_FRESH,
                    0,
                    bar_index,
                    na
                )

                array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

                if orderBlocks.size() >= 100
                    orderBlocks.pop()

                orderBlocks.unshift(o_rderBlock)

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    int i = array.size(orderBlocks) - 1
    while i >= 0
        orderBlock ob = array.get(orderBlocks, i)

        bool isBullish = ob.bias == BULLISH

        bool touched = isBullish ? f_bullishOBTouched(ob) : f_bearishOBTouched(ob)
        bool mitigated = isBullish ? f_bullishOBMitigated(ob) : f_bearishOBMitigated(ob)
        bool invalid = isBullish ? bullishOrderBlockMitigationSource < ob.barLow : bearishOrderBlockMitigationSource > ob.barHigh

        bool deleteNow = false

        if invalid
            ob.state := OB_INVALID

            if isBullish
                if internal
                    currentAlerts.internalBullishOrderBlock := true
                else
                    currentAlerts.swingBullishOrderBlock := true
            else
                if internal
                    currentAlerts.internalBearishOrderBlock := true
                else
                    currentAlerts.swingBearishOrderBlock := true
        else if mitigated
            ob.state := OB_MITIGATED
        else if touched
            ob.state := OB_TESTED
        else
            ob.state := OB_FRESH

        if touched
            ob.touches := ob.touches + 1

        if mitigated or invalid
            if obExpandAfterHitInput
                if na(ob.deleteAfterBarIndex)
                    ob.deleteAfterBarIndex := bar_index + obExpandBarsInput
            else
                deleteNow := true

        if not na(ob.deleteAfterBarIndex) and bar_index >= ob.deleteAfterBarIndex
            deleteNow := true

        if deleteNow
            array.remove(orderBlocks, i)
        else
            array.set(orderBlocks, i, ob)

        i -= 1

drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    array<box> b_oxes = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
    int orderBlocksSize = array.size(orderBlocks)

    int drawCount = 0
    int maxOrderBlocks = orderBlocksNumberInput
    int boxesSize = array.size(b_oxes)

    string obLabel = internal ? "Internal OB" : "Swing OB"
    bool blockInternalOverlap = internal and orderBlockTypeInput == OB_ANY
    bool monoMode = styleInput == MONOCHROME

    if orderBlocksSize > 0
        if obVolumeFilterInput == VOL_OFF
            int loopLimit = math.min(maxOrderBlocks, orderBlocksSize)

            for index = 0 to loopLimit - 1
                orderBlock eachOrderBlock = array.get(orderBlocks, index)

                bool shouldDraw = true

                if blockInternalOverlap
                    shouldDraw := not f_internalOBOverlapsVisibleSwing(eachOrderBlock, swingOrderBlocks, maxOrderBlocks)

                if shouldDraw and drawCount < boxesSize
                    color rawBaseColor = monoMode ? (eachOrderBlock.bias == BEARISH ? MONO_BEARISH : MONO_BULLISH) : (eachOrderBlock.bias == BEARISH ? bearishOrderBlockColorInput : bullishOrderBlockColorInput)

                    int staticTransp  = int(math.round(color.t(rawBaseColor)))
                    int dynamicTransp = f_obTransparency(eachOrderBlock.volumeRatio)
                    int baseTransp    = obUseDynamicFillInput ? dynamicTransp : staticTransp
                    int statePenalty  = f_obStatePenalty(eachOrderBlock.state)
                    int finalTransp   = math.min(100, baseTransp + statePenalty)

                    color orderBlockColor = color.new(color.rgb(color.r(rawBaseColor), color.g(rawBaseColor), color.b(rawBaseColor)), finalTransp)

                    box b_ox = array.get(b_oxes, drawCount)
                    b_ox.set_top_left_point(chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh))
                    b_ox.set_bottom_right_point(chart.point.new(last_bar_time, na, eachOrderBlock.barLow))
                    b_ox.set_border_color(orderBlockColor)
                    b_ox.set_bgcolor(orderBlockColor)
                    b_ox.set_text(obLabel)
                    b_ox.set_text_color(color.white)
                    b_ox.set_text_halign(text.align_right)
                    b_ox.set_text_valign(text.align_bottom)
                    b_ox.set_text_size(size.tiny)

                    drawCount += 1
        else
            int candidatePool = math.min(orderBlocksSize, math.max(maxOrderBlocks * 4, maxOrderBlocks))
            array<int> selectedIdx = array.new<int>()

            for pick = 0 to maxOrderBlocks - 1
                int bestIdx = na
                float bestScore = -1.0

                for i = 0 to candidatePool - 1
                    orderBlock candidate = array.get(orderBlocks, i)

                    bool alreadySelected = false
                    if array.size(selectedIdx) > 0
                        for s = 0 to array.size(selectedIdx) - 1
                            if array.get(selectedIdx, s) == i
                                alreadySelected := true
                                break

                    bool passFilter = f_obPassDisplayFilter(candidate)
                    bool overlapBlocked = false

                    if blockInternalOverlap
                        overlapBlocked := f_internalOBOverlapsVisibleSwing(candidate, swingOrderBlocks, maxOrderBlocks)

                    if not alreadySelected and passFilter and not overlapBlocked
                        float score = f_obStrengthScore(candidate)
                        if na(bestIdx) or score > bestScore
                            bestIdx := i
                            bestScore := score

                if not na(bestIdx)
                    array.push(selectedIdx, bestIdx)

            if array.size(selectedIdx) > 0
                for n = 0 to array.size(selectedIdx) - 1
                    int idx = array.get(selectedIdx, n)
                    orderBlock eachOrderBlock = array.get(orderBlocks, idx)

                    color rawBaseColor = monoMode ? (eachOrderBlock.bias == BEARISH ? MONO_BEARISH : MONO_BULLISH) : (eachOrderBlock.bias == BEARISH ? bearishOrderBlockColorInput : bullishOrderBlockColorInput)

                    int staticTransp  = int(math.round(color.t(rawBaseColor)))
                    int dynamicTransp = f_obTransparency(eachOrderBlock.volumeRatio)
                    int baseTransp    = obUseDynamicFillInput ? dynamicTransp : staticTransp
                    int statePenalty  = f_obStatePenalty(eachOrderBlock.state)
                    int finalTransp   = math.min(100, baseTransp + statePenalty)

                    color orderBlockColor = color.new(color.rgb(color.r(rawBaseColor), color.g(rawBaseColor), color.b(rawBaseColor)), finalTransp)

                    box b_ox = array.get(b_oxes, drawCount)
                    b_ox.set_top_left_point(chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh))
                    b_ox.set_bottom_right_point(chart.point.new(last_bar_time, na, eachOrderBlock.barLow))
                    b_ox.set_border_color(orderBlockColor)
                    b_ox.set_bgcolor(orderBlockColor)
                    b_ox.set_text(obLabel)
                    b_ox.set_text_color(color.white)
                    b_ox.set_text_halign(text.align_right)
                    b_ox.set_text_valign(text.align_bottom)
                    b_ox.set_text_size(size.tiny)

                    drawCount += 1

    if boxesSize > drawCount
        for clearIdx = drawCount to boxesSize - 1
            box emptyBox = array.get(b_oxes, clearIdx)
            emptyBox.set_top_left_point(chart.point.new(time, na, close))
            emptyBox.set_bottom_right_point(chart.point.new(time, na, close))
            emptyBox.set_border_color(color.new(color.black, 100))
            emptyBox.set_bgcolor(color.new(color.black, 100))
            emptyBox.set_text("")

displayStructure(bool internal = false) =>
    var bool bullishBar = true
    var bool bearishBar = true

    if internalFilterConfluenceInput
        bullishBar := high - math.max(close, open) > math.min(close, open - low)
        bearishBar := high - math.max(close, open) < math.min(close, open - low)

    pivot p_ivot = internal ? internalHigh : swingHigh
    trend t_rend = internal ? internalTrend : swingTrend

    lineStyle = internal ? line.style_dashed : line.style_solid
    labelSize = internal ? internalStructureSize : swingStructureSize

    extraCondition = internal ? internalHigh.currentLevel != swingHigh.currentLevel and bullishBar : true
    color bullishColor = styleInput == MONOCHROME ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput

    if ta.crossover(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BEARISH ? CHOCH : BOS

        if internal
            currentAlerts.internalBullishCHoCH := tag == CHOCH
            currentAlerts.internalBullishBOS   := tag == BOS
        else
            currentAlerts.swingBullishCHoCH := tag == CHOCH
            currentAlerts.swingBullishBOS   := tag == BOS

        p_ivot.crossed := true
        t_rend.bias    := BULLISH

        f_storeStructureEvent(internal, tag, BULLISH, p_ivot.currentLevel, time, bar_index)

        if tag == CHOCH
            f_storeLastChoch(BULLISH, p_ivot.currentLevel, time, bar_index, open, high, low, close)
            f_storePendingAIChoch(BULLISH, p_ivot.currentLevel, time, bar_index, open, high, low, close)

        displayCondition = internal ? showInternalsActive and (showInternalBullInput == ALL or (showInternalBullInput == BOS and tag != CHOCH) or (showInternalBullInput == CHOCH and tag == CHOCH)) : showSwingActive and (showSwingBullInput == ALL or (showSwingBullInput == BOS and tag != CHOCH) or (showSwingBullInput == CHOCH and tag == CHOCH))

        if displayCondition
            drawStructure(p_ivot, tag, bullishColor, lineStyle, label.style_label_down, labelSize)

        if (internal and useInternalOrderBlocks) or (not internal and useSwingOrderBlocks)
            storeOrdeBlock(p_ivot, internal, BULLISH)

    p_ivot         := internal ? internalLow : swingLow
    extraCondition := internal ? internalLow.currentLevel != swingLow.currentLevel and bearishBar : true
    color bearishColor = styleInput == MONOCHROME ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput

    if ta.crossunder(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BULLISH ? CHOCH : BOS

        if internal
            currentAlerts.internalBearishCHoCH := tag == CHOCH
            currentAlerts.internalBearishBOS   := tag == BOS
        else
            currentAlerts.swingBearishCHoCH := tag == CHOCH
            currentAlerts.swingBearishBOS   := tag == BOS

        p_ivot.crossed := true
        t_rend.bias    := BEARISH

        f_storeStructureEvent(internal, tag, BEARISH, p_ivot.currentLevel, time, bar_index)

        if tag == CHOCH
            f_storeLastChoch(BEARISH, p_ivot.currentLevel, time, bar_index, open, high, low, close)
            f_storePendingAIChoch(BEARISH, p_ivot.currentLevel, time, bar_index, open, high, low, close)

        displayCondition = internal ? showInternalsActive and (showInternalBearInput == ALL or (showInternalBearInput == BOS and tag != CHOCH) or (showInternalBearInput == CHOCH and tag == CHOCH)) : showSwingActive and (showSwingBearInput == ALL or (showSwingBearInput == BOS and tag != CHOCH) or (showSwingBearInput == CHOCH and tag == CHOCH))

        if displayCondition
            drawStructure(p_ivot, tag, bearishColor, lineStyle, label.style_label_up, labelSize)

        if (internal and useInternalOrderBlocks) or (not internal and useSwingOrderBlocks)
            storeOrdeBlock(p_ivot, internal, BEARISH)

f_fvgWeakTransparency(int _rangeInput) =>
    switch _rangeInput
        1 => 99
        2 => 95
        3 => 87
        4 => 79
        5 => 70
        => 90

f_fvgStrongTransparency(int _rangeInput) =>
    switch _rangeInput
        1 => 84
        2 => 74
        3 => 62
        4 => 50
        5 => 40
        => 58

f_fvgTransparencyFromStrength(float _strengthRatio, int _rangeInput) =>
    float minStrength = 1.0
    float maxStrength = 3.0

    float clampedStrength = math.max(minStrength, math.min(maxStrength, _strengthRatio))
    float norm = (clampedStrength - minStrength) / (maxStrength - minStrength)

    int weakTransp   = f_fvgWeakTransparency(_rangeInput)
    int strongTransp = f_fvgStrongTransparency(_rangeInput)

    int(math.round(weakTransp - norm * (weakTransp - strongTransp)))

f_fvgColor(color _baseColor, float _strengthRatio, int _rangeInput) =>
    int staticTransp  = int(math.round(color.t(_baseColor)))
    int dynamicTransp = f_fvgTransparencyFromStrength(_strengthRatio, _rangeInput)
    int finalTransp   = dynamicFVGFillInput ? dynamicTransp : staticTransp

    color.new(color.rgb(color.r(_baseColor), color.g(_baseColor), color.b(_baseColor)), finalTransp)

f_fvgBullDispContext(float _open, float _high, float _low, float _close, float _atr) =>
    float _range = _high - _low
    float _body  = _close > _open ? _close - _open : 0.0
    float _bodyRatio = _range > 0 ? _body / _range : 0.0
    bool _rangeOk = _range >= _atr * displacementATRMultInput
    bool _bodyOk  = _bodyRatio >= displacementBodyRatioInput
    bool _closeOk = _range > 0 ? (_high - _close) <= _range * displacementCloseExtremeInput : false
    _rangeOk and _bodyOk and _closeOk

f_fvgBearDispContext(float _open, float _high, float _low, float _close, float _atr) =>
    float _range = _high - _low
    float _body  = _close < _open ? _open - _close : 0.0
    float _bodyRatio = _range > 0 ? _body / _range : 0.0
    bool _rangeOk = _range >= _atr * displacementATRMultInput
    bool _bodyOk  = _bodyRatio >= displacementBodyRatioInput
    bool _closeOk = _range > 0 ? (_close - _low) <= _range * displacementCloseExtremeInput : false
    _rangeOk and _bodyOk and _closeOk

fairValueGapBox(leftTime, rightTime, topPrice, bottomPrice, boxColor) =>
    box.new(
        chart.point.new(leftTime, na, topPrice),
        chart.point.new(rightTime + fairValueGapsExtendInput * (time - time[1]), na, bottomPrice),
        xloc = xloc.bar_time,
        border_color = boxColor,
        bgcolor = boxColor
    )

deleteFairValueGaps() =>
    int i = array.size(fairValueGaps) - 1
    while i >= 0
        fairValueGap eachFairValueGap = array.get(fairValueGaps, i)

        bool isBullish = eachFairValueGap.bias == BULLISH
        bool filledNow = isBullish ? low < eachFairValueGap.bottom : high > eachFairValueGap.top

        bool deleteNow = false

        if filledNow
            if fvg1ExpandAfterFillInput
                if na(eachFairValueGap.deleteAfterBarIndex)
                    eachFairValueGap.deleteAfterBarIndex := bar_index + fvg1ExpandBarsInput
                    array.set(fairValueGaps, i, eachFairValueGap)
            else
                deleteNow := true

        if not na(eachFairValueGap.deleteAfterBarIndex) and bar_index >= eachFairValueGap.deleteAfterBarIndex
            deleteNow := true

        if deleteNow
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            array.remove(fairValueGaps, i)

        i -= 1

f_fvgDistanceToPrice(fairValueGap _fvg, float _price) =>
    _price > _fvg.top ? _price - _fvg.top : _price < _fvg.bottom ? _fvg.bottom - _price : 0.0

f_fvgContainsPrice(fairValueGap _fvg, float _price) =>
    _price <= _fvg.top and _price >= _fvg.bottom

f_fvgIsAbovePrice(fairValueGap _fvg, float _price) =>
    _fvg.bottom > _price

f_fvgIsBelowPrice(fairValueGap _fvg, float _price) =>
    _fvg.top < _price

f_fvgInsertSorted(array<int> _idxs, array<float> _dists, int _idx, float _dist) =>
    int pos = array.size(_idxs)

    if pos == 0
        array.push(_idxs, _idx)
        array.push(_dists, _dist)
    else
        bool inserted = false
        for j = 0 to array.size(_idxs) - 1
            if _dist < array.get(_dists, j)
                array.insert(_idxs, j, _idx)
                array.insert(_dists, j, _dist)
                inserted := true
                break

        if not inserted
            array.push(_idxs, _idx)
            array.push(_dists, _dist)

f_fvgPushUnique(array<int> _selected, int _idx) =>
    bool exists = false
    if array.size(_selected) > 0
        for i = 0 to array.size(_selected) - 1
            if array.get(_selected, i) == _idx
                exists := true
                break
    if not exists
        array.push(_selected, _idx)

f_fvgApplyVisibility(fairValueGap _fvg, bool _visible) =>
    color baseColor = _fvg.bias == BULLISH ? f_fvgColor(fairValueGapBullishColor, _fvg.strengthRatio, fvg1DynamicRangeInput) : f_fvgColor(fairValueGapBearishColor, _fvg.strengthRatio, fvg1DynamicRangeInput)

    color visibleColor = baseColor
    color hiddenColor  = color.new(color.black, 100)

    box.set_bgcolor(_fvg.topBox, _visible ? visibleColor : hiddenColor)
    box.set_border_color(_fvg.topBox, _visible ? visibleColor : hiddenColor)
    box.set_bgcolor(_fvg.bottomBox, _visible ? visibleColor : hiddenColor)
    box.set_border_color(_fvg.bottomBox, _visible ? visibleColor : hiddenColor)

drawSelectedFairValueGaps() =>
    int total = array.size(fairValueGaps)
    array<int> selected = array.new<int>()

    if total > 0
        int maxCount = math.min(fvgMaxCountInput, total)

        if fvgDisplayModeInput == FVG_MODE_TIME
            if maxCount > 0
                for i = 0 to maxCount - 1
                    array.push(selected, i)
        else
            array<int> insideIdx = array.new<int>()
            array<float> insideDist = array.new<float>()
            array<int> aboveIdx = array.new<int>()
            array<float> aboveDist = array.new<float>()
            array<int> belowIdx = array.new<int>()
            array<float> belowDist = array.new<float>()

            for i = 0 to total - 1
                fairValueGap fvg = array.get(fairValueGaps, i)
                float dist = f_fvgDistanceToPrice(fvg, close)

                if f_fvgContainsPrice(fvg, close)
                    f_fvgInsertSorted(insideIdx, insideDist, i, dist)
                else if f_fvgIsAbovePrice(fvg, close)
                    f_fvgInsertSorted(aboveIdx, aboveDist, i, dist)
                else if f_fvgIsBelowPrice(fvg, close)
                    f_fvgInsertSorted(belowIdx, belowDist, i, dist)

            int insideCount = array.size(insideIdx)
            if insideCount > 0 and maxCount > 0
                int insideTake = math.min(maxCount, insideCount)
                for i = 0 to insideTake - 1
                    f_fvgPushUnique(selected, array.get(insideIdx, i))

            int remaining = maxCount - array.size(selected)

            if remaining > 0
                int aboveCount = array.size(aboveIdx)
                int belowCount = array.size(belowIdx)

                int targetAbove = int(math.floor(remaining * 0.5))
                int targetBelow = remaining - targetAbove

                if aboveCount > 0 and belowCount > 0
                    targetAbove := math.max(1, targetAbove)
                    targetBelow := math.max(1, targetBelow)

                    if targetAbove + targetBelow > remaining
                        targetAbove := 1
                        targetBelow := remaining - 1

                int takeAbove = math.min(targetAbove, aboveCount)
                int takeBelow = math.min(targetBelow, belowCount)

                if takeAbove > 0
                    for i = 0 to takeAbove - 1
                        f_fvgPushUnique(selected, array.get(aboveIdx, i))

                if takeBelow > 0
                    for i = 0 to takeBelow - 1
                        f_fvgPushUnique(selected, array.get(belowIdx, i))

                int nextAbove = takeAbove
                int nextBelow = takeBelow

                while array.size(selected) < maxCount and (nextAbove < aboveCount or nextBelow < belowCount)
                    bool canUseAbove = nextAbove < aboveCount
                    bool canUseBelow = nextBelow < belowCount

                    if canUseAbove and canUseBelow
                        float distAbove = array.get(aboveDist, nextAbove)
                        float distBelow = array.get(belowDist, nextBelow)

                        if distAbove <= distBelow
                            f_fvgPushUnique(selected, array.get(aboveIdx, nextAbove))
                            nextAbove += 1
                        else
                            f_fvgPushUnique(selected, array.get(belowIdx, nextBelow))
                            nextBelow += 1
                    else if canUseAbove
                        f_fvgPushUnique(selected, array.get(aboveIdx, nextAbove))
                        nextAbove += 1
                    else if canUseBelow
                        f_fvgPushUnique(selected, array.get(belowIdx, nextBelow))
                        nextBelow += 1

        int selectedCount = array.size(selected)

        for i = 0 to total - 1
            bool visible = false

            if selectedCount > 0
                for j = 0 to selectedCount - 1
                    if array.get(selected, j) == i
                        visible := true
                        break

            fairValueGap fvg = array.get(fairValueGaps, i)
            f_fvgApplyVisibility(fvg, visible)

f_fvgExists(float _top, float _bottom, int _bias) =>
    bool exists = false
    float tolerance = atrMeasure * 0.10

    int total = array.size(fairValueGaps)
    if total > 0
        for i = 0 to total - 1
            fairValueGap fvg = array.get(fairValueGaps, i)

            bool sameBias = fvg.bias == _bias
            bool topClose = math.abs(fvg.top - _top) <= tolerance
            bool bottomClose = math.abs(fvg.bottom - _bottom) <= tolerance

            if sameBias and topClose and bottomClose
                exists := true
                break

    exists

drawFairValueGaps() =>
    if showFairValueGaps1Active
        [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(
            syminfo.tickerid,
            fairValueGapsTimeframeInput,
            [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],
            lookahead = barmerge.lookahead_on
        )

        barDeltaPercent = (lastClose - lastOpen) / (lastOpen * 100)
        newTimeframe    = timeframe.change(fairValueGapsTimeframeInput)
        threshold       = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / bar_index * 2 : 0

        bullDispOk = not useDisplacementFVGOnlyInput or f_fvgBullDispContext(lastOpen, high[1], low[1], lastClose, atrMeasure)
        bearDispOk = not useDisplacementFVGOnlyInput or f_fvgBearDispContext(lastOpen, high[1], low[1], lastClose, atrMeasure)

        bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe and bullDispOk
        bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe and bearDispOk

        bullStrengthRatio = threshold > 0 ? math.abs(barDeltaPercent) / threshold : 1.0
        bearStrengthRatio = threshold > 0 ? math.abs(barDeltaPercent) / threshold : 1.0

        if bullishFairValueGap
            if not f_fvgExists(currentLow, last2High, BULLISH)
                currentAlerts.bullishFairValueGap := true
                f_storeLastFvg(BULLISH, currentTime, bar_index)

                bullColor = f_fvgColor(fairValueGapBullishColor, bullStrengthRatio, fvg1DynamicRangeInput)

                topB = fairValueGapBox(lastTime, currentTime, currentLow, math.avg(currentLow, last2High), bullColor)
                botB = fairValueGapBox(lastTime, currentTime, math.avg(currentLow, last2High), last2High, bullColor)

                fairValueGaps.unshift(fairValueGap.new(currentLow, last2High, BULLISH, bullStrengthRatio, na, topB, botB))

        if array.size(fairValueGaps) > fvgStoreLimit
            oldest = array.pop(fairValueGaps)
            oldest.topBox.delete()
            oldest.bottomBox.delete()

        if bearishFairValueGap
            if not f_fvgExists(currentHigh, last2Low, BEARISH)
                currentAlerts.bearishFairValueGap := true
                f_storeLastFvg(BEARISH, currentTime, bar_index)

                bearColor = f_fvgColor(fairValueGapBearishColor, bearStrengthRatio, fvg1DynamicRangeInput)

                topB = fairValueGapBox(lastTime, currentTime, currentHigh, math.avg(currentHigh, last2Low), bearColor)
                botB = fairValueGapBox(lastTime, currentTime, math.avg(currentHigh, last2Low), last2Low, bearColor)

                fairValueGaps.unshift(fairValueGap.new(currentHigh, last2Low, BEARISH, bearStrengthRatio, na, topB, botB))

// FVG#2
fairValueGapBox2(leftTime, rightTime, topPrice, bottomPrice, boxColor) =>
    box.new(
        chart.point.new(leftTime, na, topPrice),
        chart.point.new(rightTime + fairValueGapsExtendInput2 * (time - time[1]), na, bottomPrice),
        xloc = xloc.bar_time,
        border_color = boxColor,
        bgcolor = boxColor
    )

deleteFairValueGaps2() =>
    int i = array.size(fairValueGaps2) - 1
    while i >= 0
        fairValueGap eachFairValueGap = array.get(fairValueGaps2, i)

        bool isBullish = eachFairValueGap.bias == BULLISH
        bool filledNow = isBullish ? low < eachFairValueGap.bottom : high > eachFairValueGap.top

        bool deleteNow = false

        if filledNow
            if fvg2ExpandAfterFillInput
                if na(eachFairValueGap.deleteAfterBarIndex)
                    eachFairValueGap.deleteAfterBarIndex := bar_index + fvg2ExpandBarsInput
                    array.set(fairValueGaps2, i, eachFairValueGap)
            else
                deleteNow := true

        if not na(eachFairValueGap.deleteAfterBarIndex) and bar_index >= eachFairValueGap.deleteAfterBarIndex
            deleteNow := true

        if deleteNow
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            array.remove(fairValueGaps2, i)

        i -= 1

f_fvgApplyVisibility2(fairValueGap _fvg, bool _visible) =>
    color baseColor = _fvg.bias == BULLISH ? f_fvgColor(fairValueGapBullishColor2, _fvg.strengthRatio, fvg2DynamicRangeInput) : f_fvgColor(fairValueGapBearishColor2, _fvg.strengthRatio, fvg2DynamicRangeInput)

    color visibleColor = baseColor
    color hiddenColor  = color.new(color.black, 100)

    box.set_bgcolor(_fvg.topBox, _visible ? visibleColor : hiddenColor)
    box.set_border_color(_fvg.topBox, _visible ? visibleColor : hiddenColor)
    box.set_bgcolor(_fvg.bottomBox, _visible ? visibleColor : hiddenColor)
    box.set_border_color(_fvg.bottomBox, _visible ? visibleColor : hiddenColor)

drawSelectedFairValueGaps2() =>
    int total = array.size(fairValueGaps2)
    array<int> selected = array.new<int>()

    if total > 0
        int maxCount = math.min(fvgMaxCountInput, total)

        if fvgDisplayModeInput == FVG_MODE_TIME
            if maxCount > 0
                for i = 0 to maxCount - 1
                    array.push(selected, i)
        else
            array<int> insideIdx = array.new<int>()
            array<float> insideDist = array.new<float>()
            array<int> aboveIdx = array.new<int>()
            array<float> aboveDist = array.new<float>()
            array<int> belowIdx = array.new<int>()
            array<float> belowDist = array.new<float>()

            for i = 0 to total - 1
                fairValueGap fvg = array.get(fairValueGaps2, i)
                float dist = f_fvgDistanceToPrice(fvg, close)

                if f_fvgContainsPrice(fvg, close)
                    f_fvgInsertSorted(insideIdx, insideDist, i, dist)
                else if f_fvgIsAbovePrice(fvg, close)
                    f_fvgInsertSorted(aboveIdx, aboveDist, i, dist)
                else if f_fvgIsBelowPrice(fvg, close)
                    f_fvgInsertSorted(belowIdx, belowDist, i, dist)

            int insideCount = array.size(insideIdx)
            if insideCount > 0 and maxCount > 0
                int insideTake = math.min(maxCount, insideCount)
                for i = 0 to insideTake - 1
                    f_fvgPushUnique(selected, array.get(insideIdx, i))

            int remaining = maxCount - array.size(selected)

            if remaining > 0
                int aboveCount = array.size(aboveIdx)
                int belowCount = array.size(belowIdx)

                int targetAbove = int(math.floor(remaining * 0.5))
                int targetBelow = remaining - targetAbove

                if aboveCount > 0 and belowCount > 0
                    targetAbove := math.max(1, targetAbove)
                    targetBelow := math.max(1, targetBelow)

                    if targetAbove + targetBelow > remaining
                        targetAbove := 1
                        targetBelow := remaining - 1

                int takeAbove = math.min(targetAbove, aboveCount)
                int takeBelow = math.min(targetBelow, belowCount)

                if takeAbove > 0
                    for i = 0 to takeAbove - 1
                        f_fvgPushUnique(selected, array.get(aboveIdx, i))

                if takeBelow > 0
                    for i = 0 to takeBelow - 1
                        f_fvgPushUnique(selected, array.get(belowIdx, i))

                int nextAbove = takeAbove
                int nextBelow = takeBelow

                while array.size(selected) < maxCount and (nextAbove < aboveCount or nextBelow < belowCount)
                    bool canUseAbove = nextAbove < aboveCount
                    bool canUseBelow = nextBelow < belowCount

                    if canUseAbove and canUseBelow
                        float distAbove = array.get(aboveDist, nextAbove)
                        float distBelow = array.get(belowDist, nextBelow)

                        if distAbove <= distBelow
                            f_fvgPushUnique(selected, array.get(aboveIdx, nextAbove))
                            nextAbove += 1
                        else
                            f_fvgPushUnique(selected, array.get(belowIdx, nextBelow))
                            nextBelow += 1
                    else if canUseAbove
                        f_fvgPushUnique(selected, array.get(aboveIdx, nextAbove))
                        nextAbove += 1
                    else if canUseBelow
                        f_fvgPushUnique(selected, array.get(belowIdx, nextBelow))
                        nextBelow += 1

        int selectedCount = array.size(selected)

        for i = 0 to total - 1
            bool visible = false

            if selectedCount > 0
                for j = 0 to selectedCount - 1
                    if array.get(selected, j) == i
                        visible := true
                        break

            fairValueGap fvg = array.get(fairValueGaps2, i)
            f_fvgApplyVisibility2(fvg, visible)

f_fvgExists2(float _top, float _bottom, int _bias) =>
    bool exists = false
    float tolerance = atrMeasure * 0.10

    int total = array.size(fairValueGaps2)
    if total > 0
        for i = 0 to total - 1
            fairValueGap fvg = array.get(fairValueGaps2, i)

            bool sameBias = fvg.bias == _bias
            bool topClose = math.abs(fvg.top - _top) <= tolerance
            bool bottomClose = math.abs(fvg.bottom - _bottom) <= tolerance

            if sameBias and topClose and bottomClose
                exists := true
                break

    exists
drawFairValueGaps2() =>
    if showFairValueGaps2Active
        [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(
            syminfo.tickerid,
            fairValueGapsTimeframeInput2,
            [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],
            lookahead = barmerge.lookahead_on
        )

        barDeltaPercent = (lastClose - lastOpen) / (lastOpen * 100)
        newTimeframe    = timeframe.change(fairValueGapsTimeframeInput2)
        threshold       = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / bar_index * 2 : 0

        bullDispOk = not useDisplacementFVGOnlyInput or f_fvgBullDispContext(lastOpen, high[1], low[1], lastClose, atrMeasure)
        bearDispOk = not useDisplacementFVGOnlyInput or f_fvgBearDispContext(lastOpen, high[1], low[1], lastClose, atrMeasure)

        bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe and bullDispOk
        bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe and bearDispOk

        bullStrengthRatio = threshold > 0 ? math.abs(barDeltaPercent) / threshold : 1.0
        bearStrengthRatio = threshold > 0 ? math.abs(barDeltaPercent) / threshold : 1.0

        if bullishFairValueGap
            if not f_fvgExists2(currentLow, last2High, BULLISH)
                currentAlerts.bullishFairValueGap := true
                f_storeLastFvg(BULLISH, currentTime, bar_index)

                bullColor = f_fvgColor(fairValueGapBullishColor2, bullStrengthRatio, fvg2DynamicRangeInput)

                topB = fairValueGapBox2(lastTime, currentTime, currentLow, math.avg(currentLow, last2High), bullColor)
                botB = fairValueGapBox2(lastTime, currentTime, math.avg(currentLow, last2High), last2High, bullColor)

                fairValueGaps2.unshift(fairValueGap.new(currentLow, last2High, BULLISH, bullStrengthRatio, na, topB, botB))

        if array.size(fairValueGaps2) > fvgStoreLimit
            oldest = array.pop(fairValueGaps2)
            oldest.topBox.delete()
            oldest.bottomBox.delete()

        if bearishFairValueGap
            if not f_fvgExists2(currentHigh, last2Low, BEARISH)
                currentAlerts.bearishFairValueGap := true
                f_storeLastFvg(BEARISH, currentTime, bar_index)

                bearColor = f_fvgColor(fairValueGapBearishColor2, bearStrengthRatio, fvg2DynamicRangeInput)

                topB = fairValueGapBox2(lastTime, currentTime, currentHigh, math.avg(currentHigh, last2Low), bearColor)
                botB = fairValueGapBox2(lastTime, currentTime, math.avg(currentHigh, last2Low), last2Low, bearColor)

                fairValueGaps2.unshift(fairValueGap.new(currentHigh, last2Low, BEARISH, bearStrengthRatio, na, topB, botB))


updateTrailingExtremes() =>
    trailing.top            := math.max(high, trailing.top)
    trailing.lastTopTime    := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom         := math.min(low, trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

drawHighLowSwings() =>
    var line topLine = line.new(na, na, na, na, color=swingBearishColor, xloc=xloc.bar_time)
    var line bottomLine = line.new(na, na, na, na, color=swingBullishColor, xloc=xloc.bar_time)
    var label topLabel = label.new(na, na, color=color(na), textcolor=swingBearishColor, xloc=xloc.bar_time, style=label.style_label_down, size=size.tiny)
    var label bottomLabel = label.new(na, na, color=color(na), textcolor=swingBullishColor, xloc=xloc.bar_time, style=label.style_label_up, size=size.tiny)

    int rightTimeBar = last_bar_time + 20 * (time - time[1])

    bool bearishTrend = swingTrend.bias == BEARISH
    bool bullishTrend = swingTrend.bias == BULLISH

    string topText = bearishTrend ? "Strong High" : "Weak High"
    string bottomText = bullishTrend ? "Strong Low" : "Weak Low"

    line.set_first_point(topLine, chart.point.new(trailing.lastTopTime, na, trailing.top))
    line.set_second_point(topLine, chart.point.new(rightTimeBar, na, trailing.top))
    label.set_point(topLabel, chart.point.new(rightTimeBar, na, trailing.top))
    label.set_text(topLabel, topText)

    line.set_first_point(bottomLine, chart.point.new(trailing.lastBottomTime, na, trailing.bottom))
    line.set_second_point(bottomLine, chart.point.new(rightTimeBar, na, trailing.bottom))
    label.set_point(bottomLabel, chart.point.new(rightTimeBar, na, trailing.bottom))
    label.set_text(bottomLabel, bottomText)

drawZone(float labelLevel, int labelIndex, float top, float bottom, string tag, color zoneColor, string style) =>
    var label l_abel = label.new(na, na, text=tag, color=color(na), textcolor=zoneColor, style=style, size=size.small)
    var box b_ox = box.new(na, na, na, na, bgcolor=color.new(zoneColor, 80), border_color=color(na), xloc=xloc.bar_time)

    b_ox.set_top_left_point(chart.point.new(trailing.barTime, na, top))
    b_ox.set_bottom_right_point(chart.point.new(last_bar_time, na, bottom))

    l_abel.set_point(chart.point.new(na, labelIndex, labelLevel))

drawPremiumDiscountZones() =>
    equilibriumLevel = math.avg(trailing.top, trailing.bottom)
    drawZone(equilibriumLevel, last_bar_index, 0.525 * trailing.top + 0.475 * trailing.bottom, 0.525 * trailing.bottom + 0.475 * trailing.top, "Equilibrium", equilibriumZoneColorInput, label.style_label_left)

//---------------------------------------------------------------------------------------------------------------------}
//MUTABLE VARIABLES & EXECUTION
//---------------------------------------------------------------------------------------------------------------------{
parsedOpen  = showTrendInput ? open : na
candleColor = internalTrend.bias == BULLISH ? swingBullishColor : swingBearishColor
plotcandle(parsedOpen, high, low, close, color=candleColor, wickcolor=candleColor, bordercolor=candleColor)

if showHighLowSwingsActive or showEquilibriumZonesActive
    updateTrailingExtremes()

    if showHighLowSwingsActive
        drawHighLowSwings()

    if showEquilibriumZonesActive
        drawPremiumDiscountZones()

if showFairValueGaps1Active
    deleteFairValueGaps()

if showFairValueGaps2Active
    deleteFairValueGaps2()

string intradaySeq = getCurrentStructure(swingsLengthInput, false)
if intradaySeq != ""
    intradaySwingSequence := intradaySeq

string entrySeq = getCurrentStructure(entryStructureLengthInput, true)
if entrySeq != ""
    entrySwingSequence := entrySeq

bool runEqualEngine = showEqualHighsLowsActive or (showStructureEngineInput and showLiquidityZonesInput and showEqualLiquidityInput)
if runEqualEngine
    f_runEqualHighLowEngine(equalHighsLowsLengthInput)

if showInternalsActive or useInternalOrderBlocks or showTrendInput
    displayStructure(true)

if showSwingActive or useSwingOrderBlocks or showHighLowSwingsActive
    displayStructure(false)

if showLiquidityZonesActive
    [_bullValidatedSweep, _bearValidatedSweep] = f_runLiquidityEngine()
    bullishTradeRelevantSweep := _bullValidatedSweep
    bearishTradeRelevantSweep := _bearValidatedSweep
    f_drawSelectedLiquidityZones()
else
    bullishTradeRelevantSweep := false
    bearishTradeRelevantSweep := false

[_intradayState, _entryState] = f_getStructureStates()
intradayStructureState := _intradayState
entryStructureState    := _entryState

int aiHTFBias = useAIHTFBiasTimeframeInput
     ? request.security(
         syminfo.tickerid,
         aiHTFBiasTimeframeInput,
         f_calcAIHTFSwingBias(swingsLengthInput),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
       )
     : swingTrend.bias

// AI Entry Resolver
int biasHTF = aiHTFBias
int biasLTF = internalTrend.bias

bool chochFresh = false
bool fvgValid   = false

if showAITradeEngineActive
    bool pendingFresh = pendingAIChochEvent.eventType == CHOCH and f_isRecent(pendingAIChochEvent.barIndex, aiEntryFollowThroughBarsInput)

    if pendingFresh
        bool immediatePass = pendingAIChochEvent.barIndex == bar_index and f_isImmediateAIValid(pendingAIChochEvent)
        bool confirmPass   = pendingAIChochEvent.barIndex < bar_index and aiEntryRequireFollowThroughInput and f_isConfirmedAIValid(pendingAIChochEvent)

        if immediatePass or confirmPass
            f_storeAIEntryChoch(pendingAIChochEvent.bias, pendingAIChochEvent.level, time, bar_index, open, high, low, close)
            pendingAIChochEvent.eventType := ""
            pendingAIChochEvent.barIndex  := na

    if pendingAIChochEvent.eventType == CHOCH and not f_isRecent(pendingAIChochEvent.barIndex, aiEntryFollowThroughBarsInput)
        pendingAIChochEvent.eventType := ""
        pendingAIChochEvent.barIndex  := na

    chochFresh := f_isRecent(lastAIEntryChochEvent.barIndex, 5)
    fvgValid   := chochFresh and f_fvgValidWithChoch(lastFvgEvent.bias, lastAIEntryChochEvent.bias, lastFvgEvent.barIndex, lastAIEntryChochEvent.barIndex)
else
    pendingAIChochEvent.eventType := ""
    pendingAIChochEvent.barIndex  := na

string rowBiasHTFText = f_biasText(biasHTF)
color  rowBiasHTFCol  = f_biasColor(biasHTF)

string rowBiasLTFText = f_biasText(biasLTF)
color  rowBiasLTFCol  = f_biasColor(biasLTF)

string rowStructureText = f_structureText(chochFresh)
color  rowStructureCol  = f_structureColor(lastAIEntryChochEvent.bias, chochFresh)

string rowFvgText = f_fvgText(fvgValid)
color  rowFvgCol  = f_fvgColorTable(fvgValid, lastFvgEvent.bias)

string rowEntryText = f_entryText(chochFresh)
color  rowEntryCol  = f_entryColor(chochFresh, lastAIEntryChochEvent.bias)

string rowTradeText = rowEntryText == "" ? f_tradeText(biasHTF, biasLTF) : ""
color  rowTradeCol  = rowEntryText == "" ? f_tradeColor(biasHTF, biasLTF) : text_color_ema

bool longSignalNow  = showAITradeEngineActive and chochFresh and lastAIEntryChochEvent.bias == BULLISH and lastAIEntryChochEvent.barIndex == bar_index
bool shortSignalNow = showAITradeEngineActive and chochFresh and lastAIEntryChochEvent.bias == BEARISH and lastAIEntryChochEvent.barIndex == bar_index

if barstate.islast
    if showAITradeEngineActive
        table.cell(smcEntryTable, 0, 0, "xLevTrading", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 0, "   AI Trade   ", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 1, "Bias HTF", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 1, rowBiasHTFText, text_color=rowBiasHTFCol, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 2, "Bias LTF", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 2, rowBiasLTFText, text_color=rowBiasLTFCol, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 3, "Structure", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 3, rowStructureText, text_color=rowStructureCol, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 4, "FVG", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 4, rowFvgText, text_color=rowFvgCol, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 5, "Next Trade", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 5, rowTradeText, text_color=rowTradeCol, bgcolor=bg_color_ema, text_size=tblSize)

        table.cell(smcEntryTable, 0, 6, "Trade Entry", text_color=text_color_ema, bgcolor=bg_color_ema, text_size=tblSize)
        table.cell(smcEntryTable, 1, 6, rowEntryText, text_color=rowEntryCol, bgcolor=bg_color_ema, text_size=tblSize)
    else
        table.clear(smcEntryTable, 0, 0, 1, 6)

if showAITradeEngineActive and longSignalNow
    label _longLbl = label.new(
         x = bar_index,
         y = low,
         text = "▲",
         xloc = xloc.bar_index,
         yloc = yloc.belowbar,
         style = label.style_none,
         textcolor = color.lime,
         size = size.small
     )
    array.push(longSignalLabels, _longLbl)

    if modeInput == PRESENT
        f_trimSignalLabels(longSignalLabels, 4)

if showAITradeEngineActive and shortSignalNow
    label _shortLbl = label.new(
         x = bar_index,
         y = high,
         text = "▼",
         xloc = xloc.bar_index,
         yloc = yloc.abovebar,
         style = label.style_none,
         textcolor = color.red,
         size = size.small
     )
    array.push(shortSignalLabels, _shortLbl)

    if modeInput == PRESENT
        f_trimSignalLabels(shortSignalLabels, 4)

if useInternalOrderBlocks
    deleteOrderBlocks(true)

if useSwingOrderBlocks
    deleteOrderBlocks()

if barstate.islastconfirmedhistory or barstate.islast
    if useSwingOrderBlocks
        drawOrderBlocks(false)
    if useInternalOrderBlocks
        drawOrderBlocks(true)

if showFairValueGaps1Active
    drawFairValueGaps()
    drawSelectedFairValueGaps()

if showFairValueGaps2Active
    drawFairValueGaps2()
    drawSelectedFairValueGaps2()

lastBarIndex    := currentBarIndex
currentBarIndex := bar_index
newBar          = currentBarIndex != lastBarIndex

if barstate.islastconfirmedhistory or (barstate.isrealtime and newBar)
    if showDailyLevelsActive and not higherTimeframe('D')
        drawLevels('D', timeframe.isdaily, dailyLevelsStyleInput, dailyLevelsColorInput)

//---------------------------------------------------------------------------------------------------------------------}
//ALERTS
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(currentAlerts.internalBullishBOS,        "Internal Bullish BOS",         "Internal Bullish BOS formed")
alertcondition(currentAlerts.internalBullishCHoCH,      "Internal Bullish CHoCH",       "Internal Bullish CHoCH formed")
alertcondition(currentAlerts.internalBearishBOS,        "Internal Bearish BOS",         "Internal Bearish BOS formed")
alertcondition(currentAlerts.internalBearishCHoCH,      "Internal Bearish CHoCH",       "Internal Bearish CHoCH formed")

alertcondition(currentAlerts.swingBullishBOS,           "Bullish BOS",                  "Internal Bullish BOS formed")
alertcondition(currentAlerts.swingBullishCHoCH,         "Bullish CHoCH",                "Internal Bullish CHoCH formed")
alertcondition(currentAlerts.swingBearishBOS,           "Bearish BOS",                  "Bearish BOS formed")
alertcondition(currentAlerts.swingBearishCHoCH,         "Bearish CHoCH",                "Bearish CHoCH formed")

alertcondition(currentAlerts.internalBullishOrderBlock, "Bullish Internal OB Breakout", "Price broke bullish internal OB")
alertcondition(currentAlerts.internalBearishOrderBlock, "Bearish Internal OB Breakout", "Price broke bearish internal OB")
alertcondition(currentAlerts.swingBullishOrderBlock,    "Bullish Swing OB Breakout",    "Price broke bullish swing OB")
alertcondition(currentAlerts.swingBearishOrderBlock,    "Bearish Swing OB Breakout",    "Price broke bearish swing OB")

alertcondition(currentAlerts.equalHighs,                "Equal Highs",                  "Equal highs detected")
alertcondition(currentAlerts.equalLows,                 "Equal Lows",                   "Equal lows detected")

alertcondition(currentAlerts.bullishFairValueGap,       "Bullish FVG",                  "Bullish FVG formed")
alertcondition(currentAlerts.bearishFairValueGap,       "Bearish FVG",                  "Bearish FVG formed")

alertcondition(bullishTradeRelevantSweep,               "Bullish Trade-Relevant Sweep", "Bullish trade-relevant liquidity sweep detected")
alertcondition(bearishTradeRelevantSweep,               "Bearish Trade-Relevant Sweep", "Bearish trade-relevant liquidity sweep detected")
````
