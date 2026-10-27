# Pivot Rays [BMT]

- url: https://www.tradingview.com/script/BHmAchC4-Pivot-Rays-BMT/
- type: indicator
- pine_id: PUB;08d55f9cee0e49d19355abce709698e0
- version: 2.0

## Description

Pivot Rays [BMT]

Horizontal rays from every pivot high and low that price has not yet taken out, on the chart timeframe and up to three higher ones, tagged by timeframe, plus the all-time high. Only the levels inside the price range on screen are drawn, so the rays never stretch the chart's auto-scale, and a level disappears the moment price trades through it.

[b]What it draws[/b]

A pivot high is a bar whose high is not exceeded by any of the N bars to its left or right (N is the Bars left / right input, 5 by default); a pivot low is the mirror. Each confirmed pivot becomes a horizontal ray from the bar that made it to the right edge of the chart.

The rays are rebuilt on every tick of the last bar from a stored list of pivots, so what you see is always the current set: rays appear as price approaches a level or as you scroll it into view, and leave when the level is broken or scrolls out.

[b]Timeframes[/b]

Four rows: the chart timeframe and three higher ones, preset to 4H, D and W. Each row has its own on/off switch, timeframe, tag and line width. A row whose timeframe is not above the chart's is ignored; a row equal to the chart's lends its tag to the chart pivots instead, so a daily chart still prints D on its own pivots. Chart-timeframe pivots carry no tag by default; give the row a tag if you want one.

Pivots at the same price on several timeframes are one level, not three: they merge into a single ray whose tag lists every timeframe it belongs to, for example "D 4H". The merged ray starts at the bar of the lowest timeframe in the group, because that is the exact bar: a daily pivot is only known to the resolution of the daily bar, and on a 5-minute chart that is the day's open, hours before the candle that actually made the high. A merge tolerance in ticks (0 by default) widens what counts as the same price.

[b]Which pivots are drawn[/b]

Three modes.

[list] 
[*][b]Visible price range[/b] (default): only levels between the lowest low and highest high of the bars currently on screen. The range is measured from the bars alone, never from the drawings, so nothing is ever drawn outside the candles' own span and Reset chart view fits the candles rather than a distant level. The set follows every scroll and zoom. 
[*][b]Within N ATR[/b]: levels within N chart-timeframe ATRs of the current close (ATR(14) x 5 by default), whether on screen or not. Higher-timeframe pivots are measured against the same chart ATR. 
[*][b]Both[/b]: on screen and near price.
[/list]

A cap on the number of rays keeps the nearest to price when more than that pass the filter.

[b]Broken pivots[/b]

A pivot is broken when price trades through it: a wick beyond the level by default, or a close beyond it by input (the close test runs on bar close only, so a live bar does not flicker). A broken pivot is removed. Because every break removes a level, the stored set holds only the pivots price has never taken out, the staircase of highs above and lows below, and stays small however long the chart is.

The most recent break stays on as a dashed, fainter ray so the level just lost or reclaimed is still in view, and is dropped at the close of the period it happened in, daily by default: a level taken out during Tuesday's session shows dashed through Tuesday and is gone at the daily close. On a chart at or above that timeframe it lasts for the break bar only. The count is of break events, not pivots, so every pivot broken by the same bar stays or goes together. Both the expiry timeframe and how many recent breaks to keep are inputs; the dashed ray can be turned off.

[b]All-time high[/b]

Its own dotted, heavier ray tagged ATH. The value comes from the symbol's monthly series, which TradingView serves back to the first bar it has for the symbol whatever the chart timeframe, combined with the loaded bars for the open month, so it is the real all-time high on a 5-minute chart, not the high of the bars loaded. On a continuous futures symbol it is the high of that continuous series, adjusted or not as the chart is set. Loaded bars is available as an alternative source. The ATH obeys the same filter as the pivots by default, so it shows when you scroll or zoom out far enough to include it; an input draws it always. A pivot high at the ATH price is left to the ATH ray rather than drawn twice.

[b]Labels[/b]

A tag at the pivot bar by default, above a high or below a low (the empty side, by definition of a pivot), so it lands in the same place at any zoom. Right edge hangs the tag from an anchor a settable number of bars past the last bar; that number has to match the chart's right margin, which is a pixel width and so a different number of bars at every zoom. Text size, and whether the price is appended, are inputs. Each tag's tooltip gives the timeframes and the pivot's date.

[b]Theme[/b]

Auto reads the chart background and picks the muted text gray of the light or dark theme for the rays, at a default 30% transparency so they sit behind the candles, with the theme's primary text color for the tags. The dashed broken ray is fainter by a settable amount. Custom exposes the ray, ATH and label colors.

[b]Notes[/b]

Higher-timeframe pivots are one request.security call per row, asking for the previous higher-timeframe bar's pivot with lookahead on. That is the standard non-repainting form: a pivot is stored once the higher-timeframe bar that confirms it has closed, and never changes afterwards. Chart-timeframe pivots confirm N bars after the pivot bar, as pivots do. The ATH is one more request on the monthly series.

Because the chart timeframe's pivots are stored from the bars loaded on the chart, a higher-timeframe pivot older than the chart's first bar is drawn from the left edge, with its true date in the tooltip.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © matt_spinola

// version v0.7.2, 2026-09-28
// Pivot rays: every confirmed pivot high and low on the chart timeframe and on up to three
// higher timeframes (4H / D / W by default), each drawn as a horizontal ray from the pivot
// bar to the right edge, and shown only while the level sits inside the price range of the
// bars on screen (or within N ATRs of the close, by input), so the rays never stretch the
// auto-scale. A pivot is dropped once price closes (or trades, by input) through it; the most
// recent break stays on as a dashed, fainter ray so the level just lost or reclaimed is
// still in view. The set is rebuilt on every tick of the last bar, so rays appear and
// disappear as price moves. Pivots at the same price on several timeframes merge into one ray carrying
// every timeframe's tag (a daily pivot is nearly always a 4H and a chart pivot too). The
// all-time high is its own dotted, heavier ray tagged ATH, taken from the symbol's full
// monthly history rather than only the bars loaded on the chart.
//
// Previous-period highs and lows (PDH/PDL, PWH/PWL, PMH/PML by default) are levels of their
// own: the high and low of the last completed day, week and month, replaced when the next
// period starts. They share the pivots' filter, merge, break and label rules, so a PDH that
// is also a daily pivot is one ray tagged "PDH D". When a bar sweeps one (trades beyond it)
// and a bar then closes back inside, the script marks the bar and fires an alert: a
// swept-and-reclaimed level, once per level per period.
//
// Session highs and lows (Asia, London, New York by default, times in an explicit time zone)
// are the same kind of level on intraday charts: the high and low of the last completed
// session, replaced when that session next completes, with the same break and reclaim rules.
// The midpoints of the previous day, week and month are drawn too; a midpoint is crossed all
// the time, so it never breaks and simply lasts until the next period replaces it.
//
// Higher-timeframe pivots come through request.security on the previous HTF bar with
// lookahead on, the standard non-repainting form: a pivot is stored once the HTF bar that
// confirms it has closed, and the ray starts at that HTF bar's open time.

//@version=6
indicator("Pivot Rays [BMT]", "Pivot Rays [BMT]", overlay=true, max_lines_count=500, max_labels_count=500)

// --------------------- Theme { ----------------------------- \\
// The chart's own background picks the ray color: the same relative-luminance test the
// other [BMT] scripts use. Both canvases get TradingView's muted text gray for their theme,
// plus a default transparency, so a ray sits behind the candles rather than over them.
color noColor = color.new(color.black, 100)

var g_theme = "Theme"
themeInput = input.string("Auto (chart)", group=g_theme, title="Theme", options=["Auto (chart)", "Dark", "Light", "Custom"],
     tooltip="Auto reads the chart background and picks a light gray on dark canvases, a dark gray on light ones. Custom uses the two colors below.")
customRayInput = input.color(#787B86, group=g_theme, title="Custom ray color", active=themeInput == "Custom")
customAthInput = input.color(#787B86, group=g_theme, title="Custom ATH color", active=themeInput == "Custom")
customLabelInput = input.color(#B2B5BE, group=g_theme, title="Custom label color", active=themeInput == "Custom")
transpInput    = input.int(30, group=g_theme, title="Ray transparency", minval=0, maxval=90, inline="tr")
brokenDimInput = input.int(25, group=g_theme, title="extra for broken", minval=0, maxval=60, inline="tr",
     tooltip="Transparency of live rays, and how much more transparent the dashed broken ray is.")

chartLuma = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
bool isCustom = themeInput == "Custom"
bool isDark   = themeInput == "Dark" or (themeInput == "Auto (chart)" and chartLuma <= 128)

color darkRayColor    = #787B86   // TradingView dark theme muted text
color lightRayColor   = #9598A1   // TradingView light theme muted text
color darkLabelColor  = #D1D4DC   // dark theme primary text: the tag has to read, the ray only has to be there
color lightLabelColor = #131722   // light theme primary text

color rayColor    = color.new(isCustom ? customRayInput : isDark ? darkRayColor : lightRayColor, transpInput)
color brokenColor = color.new(isCustom ? customRayInput : isDark ? darkRayColor : lightRayColor, math.min(95, transpInput + brokenDimInput))
color athColor    = color.new(isCustom ? customAthInput : isDark ? darkRayColor : lightRayColor, transpInput)
color labelColor       = isCustom ? customLabelInput : isDark ? darkLabelColor : lightLabelColor
color brokenLabelColor = color.new(labelColor, brokenDimInput)

colorByRowInput = input.bool(false, group=g_theme, title="Color rays by row",
     tooltip="Off: every ray takes the theme color above. On: each timeframe and previous-period row uses the swatch on its own row, rays at the transparency above and tags opaque. A merged ray takes the color of its highest row (PMH over PDH over W over D and so on).")
//}

// --------------------- Inputs { ----------------------------- \\
var g_filter = "Which pivots to draw"
filterModeInput = input.string("Visible price range", group=g_filter, title="Show pivots", options=["Visible price range", "Within N ATR", "Both"],
     tooltip="Visible price range: only levels between the lowest low and highest high of the bars on screen, so the rays never push the auto-scale out; the set follows every scroll and zoom. Within N ATR: levels near the current close, whether on screen or not. Both: inside the visible range AND near price.")
atrLenInput  = input.int(14, group=g_filter, title="ATR length", minval=1, inline="atr", active=filterModeInput != "Visible price range")
atrMultInput = input.float(5.0, group=g_filter, title="x ATR", minval=0.1, step=0.5, inline="atr", active=filterModeInput != "Visible price range",
     tooltip="Within this many chart-timeframe ATRs of the current close. Higher-timeframe pivots are measured against the same chart ATR.")
maxRaysInput = input.int(60, group=g_filter, title="Max rays drawn", minval=1, maxval=400,
     tooltip="When more pivots than this pass the filter, the nearest to price are kept.")

var g_pivot = "Pivots"
leftInput  = input.int(5, group=g_pivot, title="Bars left", minval=1, maxval=50, inline="lr")
rightInput = input.int(5, group=g_pivot, title="right", minval=1, maxval=50, inline="lr",
     tooltip="Pivot strength on every timeframe: a high is a pivot when no bar this many to the left or right exceeds it. Same rule for lows.")
showHighsInput = input.bool(true, group=g_pivot, title="Pivot highs", inline="hl")
showLowsInput  = input.bool(true, group=g_pivot, title="Pivot lows", inline="hl")
keepInput      = input.int(500, group=g_pivot, title="Pivots kept per timeframe", minval=50, maxval=2000,
     tooltip="Oldest pivots are dropped past this count. Only the ones that pass the filter are ever drawn.")
mergeTicksInput = input.int(0, group=g_pivot, title="Merge pivots within (ticks)", minval=0, maxval=100,
     tooltip="Pivots from different timeframes at the same price (within this many ticks) become one ray carrying every timeframe's tag.")

var g_break = "Broken pivots"
breakOnInput    = input.string("Wick", group=g_break, title="A pivot is broken on", options=["Close", "Wick"], inline="br",
     tooltip="Close: a bar closes beyond the pivot (checked on bar close only, so a live bar does not flicker). Wick: any trade beyond it, including on the live bar. Broken pivots are removed.")
brokenKeepInput = input.int(1, group=g_break, title="keep the last", minval=0, maxval=10, inline="br")
brokenOnInput   = input.bool(true, group=g_break, title="Most recent break stays on as a dashed ray", inline="br2",
     tooltip="The number to the right counts break events, not pivots: every pivot broken on the same bar stays together. 0 keeps none. This toggle is the same as setting it to 0.")
brokenExpireInput   = input.bool(true, group=g_break, title="and is dropped at the close of", inline="br3")
brokenExpireTfInput = input.timeframe("D", group=g_break, title="", inline="br3",
     tooltip="The dashed ray lives only for the rest of the period in which the break happened: broken during Tuesday's session, gone at Tuesday's daily close. On a chart at or above this timeframe it lasts for the break bar only. Off keeps it until a newer break pushes it out.")

var g_tf = "Timeframes"
chartOnInput    = input.bool(true, group=g_tf, title="Chart timeframe", inline="tf0")
chartTagInput   = input.string("", group=g_tf, title="tag", inline="tf0",
     tooltip="Label text shown at the right edge for chart-timeframe pivots. Blank means no label. When the chart timeframe equals one of the rows below, that row's tag is used.")
chartWidthInput = input.int(1, group=g_tf, title="width", minval=1, maxval=5, inline="tf0")
chartColorInput = input.color(#787B86, group=g_tf, title="", inline="tf0", active=colorByRowInput)

htf1OnInput    = input.bool(true, group=g_tf, title="", inline="tf1")
htf1TfInput    = input.timeframe("240", group=g_tf, title="", inline="tf1")
htf1TagInput   = input.string("4H", group=g_tf, title="tag", inline="tf1")
htf1ColorInput = input.color(#42A5F5, group=g_tf, title="", inline="tf1", active=colorByRowInput)
htf1WidthInput = input.int(1, group=g_tf, title="width", minval=1, maxval=5, inline="tf1")

htf2OnInput    = input.bool(true, group=g_tf, title="", inline="tf2")
htf2TfInput    = input.timeframe("D", group=g_tf, title="", inline="tf2")
htf2TagInput   = input.string("D", group=g_tf, title="tag", inline="tf2")
htf2ColorInput = input.color(#FFA726, group=g_tf, title="", inline="tf2", active=colorByRowInput)
htf2WidthInput = input.int(1, group=g_tf, title="width", minval=1, maxval=5, inline="tf2")

htf3OnInput    = input.bool(true, group=g_tf, title="", inline="tf3")
htf3TfInput    = input.timeframe("W", group=g_tf, title="", inline="tf3")
htf3TagInput   = input.string("W", group=g_tf, title="tag", inline="tf3")
htf3ColorInput = input.color(#AB47BC, group=g_tf, title="", inline="tf3", active=colorByRowInput)
htf3WidthInput = input.int(1, group=g_tf, title="width", minval=1, maxval=5, inline="tf3",
     tooltip="Each row is a higher timeframe, its right-edge tag, and its ray width. A row is ignored when its timeframe is not above the chart's.")

var g_prev = "Previous-period highs and lows"
pdOnInput    = input.bool(false, group=g_prev, title="", inline="pd")
pdTfInput    = input.timeframe("D", group=g_prev, title="", inline="pd")
pdHTagInput  = input.string("PDH", group=g_prev, title="tags", inline="pd")
pdLTagInput  = input.string("PDL", group=g_prev, title="", inline="pd")
pdColorInput = input.color(#26A69A, group=g_prev, title="", inline="pd", active=colorByRowInput)
pdWidthInput = input.int(1, group=g_prev, title="width", minval=1, maxval=5, inline="pd")

pwOnInput    = input.bool(false, group=g_prev, title="", inline="pw")
pwTfInput    = input.timeframe("W", group=g_prev, title="", inline="pw")
pwHTagInput  = input.string("PWH", group=g_prev, title="tags", inline="pw")
pwLTagInput  = input.string("PWL", group=g_prev, title="", inline="pw")
pwColorInput = input.color(#EC407A, group=g_prev, title="", inline="pw", active=colorByRowInput)
pwWidthInput = input.int(1, group=g_prev, title="width", minval=1, maxval=5, inline="pw")

pmOnInput    = input.bool(false, group=g_prev, title="", inline="pm")
pmTfInput    = input.timeframe("M", group=g_prev, title="", inline="pm")
pmHTagInput  = input.string("PMH", group=g_prev, title="tags", inline="pm")
pmLTagInput  = input.string("PML", group=g_prev, title="", inline="pm")
pmColorInput = input.color(#D4E157, group=g_prev, title="", inline="pm", active=colorByRowInput)
pmWidthInput = input.int(1, group=g_prev, title="width", minval=1, maxval=5, inline="pm",
     tooltip="Off by default. The high and low of the last completed period on each row's timeframe, replaced when the next period opens. A row is ignored when its timeframe is below the chart's; on a chart of the same timeframe it is the previous bar's high and low. The ray starts at the chart bar that made the extreme, or at the period's open when that bar is not loaded. These levels break, dash and expire exactly like pivots.")

midOnInput    = input.bool(false, group=g_prev, title="Midpoints, tagged", inline="mid")
pdMidTagInput = input.string("PD50", group=g_prev, title="", inline="mid")
pwMidTagInput = input.string("PW50", group=g_prev, title="", inline="mid")
pmMidTagInput = input.string("PM50", group=g_prev, title="", inline="mid",
     tooltip="Off by default. The 50% level of each previous period's range, in that row's color and width, shown while its row is on. Midpoints never break (price crosses them all the time) and are replaced with the period.")

var g_sess = "Session highs and lows"
sessTzInput    = input.string("America/New_York", group=g_sess, title="Time zone",
     tooltip="The session times below are read in this time zone, whatever the chart's own time zone is set to. Any IANA name (America/New_York, Europe/London, Asia/Tokyo) or UTC offset (GMT+2).")
sessBelowInput = input.timeframe("240", group=g_sess, title="Shown on charts below",
     tooltip="Sessions are intraday levels: they are drawn only when the chart timeframe is below this one.")

asOnInput    = input.bool(false, group=g_sess, title="", inline="as")
asSessInput  = input.session("1800-0300", group=g_sess, title="", inline="as")
asHTagInput  = input.string("AsiaH", group=g_sess, title="tags", inline="as")
asLTagInput  = input.string("AsiaL", group=g_sess, title="", inline="as")
asColorInput = input.color(#66BB6A, group=g_sess, title="", inline="as", active=colorByRowInput)
asWidthInput = input.int(1, group=g_sess, title="width", minval=1, maxval=5, inline="as")

loOnInput    = input.bool(false, group=g_sess, title="", inline="lo")
loSessInput  = input.session("0300-0800", group=g_sess, title="", inline="lo")
loHTagInput  = input.string("LonH", group=g_sess, title="tags", inline="lo")
loLTagInput  = input.string("LonL", group=g_sess, title="", inline="lo")
loColorInput = input.color(#5C6BC0, group=g_sess, title="", inline="lo", active=colorByRowInput)
loWidthInput = input.int(1, group=g_sess, title="width", minval=1, maxval=5, inline="lo")

nyOnInput    = input.bool(false, group=g_sess, title="", inline="ny")
nySessInput  = input.session("0830-1700", group=g_sess, title="", inline="ny")
nyHTagInput  = input.string("NYH", group=g_sess, title="tags", inline="ny")
nyLTagInput  = input.string("NYL", group=g_sess, title="", inline="ny")
nyColorInput = input.color(#FF7043, group=g_sess, title="", inline="ny", active=colorByRowInput)
nyWidthInput = input.int(1, group=g_sess, title="width", minval=1, maxval=5, inline="ny",
     tooltip="Off by default. Each row is a session window, its high and low tags, color and width. A session's high and low become levels once it has ended and are replaced when the same session next ends; the ray starts at the bar that made the extreme. They break, dash, expire and fire the swept-and-reclaimed alert exactly like the previous-period levels.")

var g_sweep = "Swept and reclaimed"
markInput      = input.bool(true, group=g_sweep, title="Mark the reclaim bar", inline="mk")
markHighInput  = input.color(#F23645, group=g_sweep, title="high", inline="mk")
markLowInput   = input.color(#089981, group=g_sweep, title="low", inline="mk",
     tooltip="Applies to the previous-period and session highs and lows. A previous-period high is swept when any bar in the current period trades above it, and reclaimed when a bar then CLOSES back below it (the sweep bar itself counts, as in a candle-range sweep). The mirror for lows. Each level fires once per period, checked on bar close only, on the chart timeframe: on a 5-minute chart the first 5-minute close back inside counts. Alerts: the two alert conditions below, or 'Any alert() function call' for a message that names the level and its price.")
sameTfInput    = input.bool(false, group=g_sweep, title="Include rows at the chart timeframe",
     tooltip="Off: only rows above the chart timeframe mark and alert, so a daily chart fires on the previous week and month but not on PDH/PDL, which there are just the previous bar's high and low and would fire on most bars (every bar that pokes past yesterday's extreme and closes back inside). The rays are drawn either way. On: those rows fire too, a candle-range sweep on every such bar.")

var g_ath = "All-time high"
athOnInput     = input.bool(true, group=g_ath, title="Show ATH ray", inline="ath")
athAlwaysInput = input.bool(false, group=g_ath, title="ignore the filter", inline="ath",
     tooltip="Drawn dotted and heavier. A pivot high at the ATH price is left to this ray rather than drawn twice.")
athSourceInput = input.string("Full history", group=g_ath, title="Source", options=["Full history", "Loaded bars"],
     tooltip="Full history reads the symbol's monthly series, which TradingView serves back to the first bar it has for the symbol whatever the chart timeframe, so the ATH is the real one even on a 5-minute chart. Loaded bars uses only what the chart has loaded. Either way the current bar's high is included.")
athTagInput    = input.string("ATH", group=g_ath, title="tag", inline="ath2")
athWidthInput  = input.int(3, group=g_ath, title="width", minval=1, maxval=6, inline="ath2")

var g_label = "Labels"
labelPosInput    = input.string("Pivot", group=g_label, title="Position", options=["Pivot", "Right edge"],
     tooltip="Pivot: the tag sits at the bar that made the pivot, above a high or below a low, so it lands in the same place at any zoom. Right edge: the tag hangs left from the anchor below.")
labelOffsetInput = input.int(60, group=g_label, title="Right edge (bars past the last bar)", minval=1, maxval=500, active=labelPosInput == "Right edge",
     tooltip="Pine cannot see the chart's right margin, which is a pixel width and so a different number of bars at every zoom: set this to match. Too small and the tags float short of the edge; too large and they are clipped.")
labelSizeInput   = input.string("small", group=g_label, title="Size", options=["tiny", "small", "normal", "large", "huge"])
showPriceInput   = input.bool(false, group=g_label, title="Append the price to the tag")
//}

// --------------------- Types and storage { ----------------------------- \\
type Pivot
    float price
    int   t        // open time of the bar that made the pivot
    bool  isHigh
    int   level    // 0 chart, 1..3 HTF rows, 4..9 PDH PDL PWH PWL PMH PML, 10..15 session H/L, 16..18 midpoints
    int   brokenT  // open time of the bar that broke it, na while live
    int   brokenP  // open time of the expiry period (daily by default) that bar sits in

var array<Pivot> piv0 = array.new<Pivot>()
var array<Pivot> piv1 = array.new<Pivot>()
var array<Pivot> piv2 = array.new<Pivot>()
var array<Pivot> piv3 = array.new<Pivot>()
var array<Pivot> prevD = array.new<Pivot>()    // the live previous-period high and low, at most two each
var array<Pivot> prevW = array.new<Pivot>()
var array<Pivot> prevM = array.new<Pivot>()
var array<Pivot> sessA = array.new<Pivot>()    // the last completed session's high and low
var array<Pivot> sessL = array.new<Pivot>()
var array<Pivot> sessN = array.new<Pivot>()
var array<Pivot> broken = array.new<Pivot>()   // the last N break events, oldest first

var array<line>  rays = array.new<line>()
var array<label> tags = array.new<label>()

var int firstBarTime = time
//}

// --------------------- Timeframe resolution { ----------------------------- \\
// A row only counts as "higher" when it is strictly above the chart. A row equal to the
// chart timeframe lends its tag and width to the chart-timeframe pivots instead, so a
// daily chart still prints D on its own pivots.
int chartSec = timeframe.in_seconds()
int htf1Sec  = timeframe.in_seconds(htf1TfInput)
int htf2Sec  = timeframe.in_seconds(htf2TfInput)
int htf3Sec  = timeframe.in_seconds(htf3TfInput)

bool htf1Active = htf1OnInput and htf1Sec > chartSec
bool htf2Active = htf2OnInput and htf2Sec > chartSec
bool htf3Active = htf3OnInput and htf3Sec > chartSec

string chartTag   = htf3OnInput and htf3Sec == chartSec ? htf3TagInput   : htf2OnInput and htf2Sec == chartSec ? htf2TagInput   : htf1OnInput and htf1Sec == chartSec ? htf1TagInput   : chartTagInput
int    chartWidth = htf3OnInput and htf3Sec == chartSec ? htf3WidthInput : htf2OnInput and htf2Sec == chartSec ? htf2WidthInput : htf1OnInput and htf1Sec == chartSec ? htf1WidthInput : chartWidthInput

color chartColor = htf3OnInput and htf3Sec == chartSec ? htf3ColorInput : htf2OnInput and htf2Sec == chartSec ? htf2ColorInput : htf1OnInput and htf1Sec == chartSec ? htf1ColorInput : chartColorInput

// Previous-period rows count from the chart timeframe up (a PDH on a daily chart is simply
// the previous bar's high, the level a daily candle-range sweep takes out).
bool pdActive = pdOnInput and timeframe.in_seconds(pdTfInput) >= chartSec
bool pwActive = pwOnInput and timeframe.in_seconds(pwTfInput) >= chartSec
bool pmActive = pmOnInput and timeframe.in_seconds(pmTfInput) >= chartSec

bool sessShown = chartSec < timeframe.in_seconds(sessBelowInput)
bool asActive  = asOnInput and sessShown
bool loActive  = loOnInput and sessShown
bool nyActive  = nyOnInput and sessShown

// Indexed by Pivot.level. Bit i of a merged ray's mask is level i, so the tag reads from the
// top down: previous-period levels first, then W D 4H.
var array<string> levelTags   = array.from(chartTag, htf1TagInput, htf2TagInput, htf3TagInput, pdHTagInput, pdLTagInput, pwHTagInput, pwLTagInput, pmHTagInput, pmLTagInput,
     asHTagInput, asLTagInput, loHTagInput, loLTagInput, nyHTagInput, nyLTagInput, pdMidTagInput, pwMidTagInput, pmMidTagInput)
var array<int>    levelWidths = array.from(chartWidth, htf1WidthInput, htf2WidthInput, htf3WidthInput, pdWidthInput, pdWidthInput, pwWidthInput, pwWidthInput, pmWidthInput, pmWidthInput,
     asWidthInput, asWidthInput, loWidthInput, loWidthInput, nyWidthInput, nyWidthInput, pdWidthInput, pwWidthInput, pmWidthInput)
var array<color>  levelColors = array.from(chartColor, htf1ColorInput, htf2ColorInput, htf3ColorInput, pdColorInput, pdColorInput, pwColorInput, pwColorInput, pmColorInput, pmColorInput,
     asColorInput, asColorInput, loColorInput, loColorInput, nyColorInput, nyColorInput, pdColorInput, pwColorInput, pmColorInput)
int FIRST_PREV_LEVEL = 4    // from here up a ray is a level rather than a pivot
int FIRST_MID_LEVEL  = 16   // midpoints, which never break
int TOP_LEVEL        = 18
//}

// --------------------- Detection { ----------------------------- \\
float atrValue = ta.atr(atrLenInput)
float band     = atrMultInput * atrValue

// The price range of the bars on screen. The chart.*_visible_bar_time values change with
// every scroll and zoom and the script recalculates from the first bar when they do, so
// these two running values are always the current view's. They come from the bars alone,
// never from the drawings, so there is no feedback between what is drawn and the range.
var float visHigh = na
var float visLow  = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visHigh := math.max(nz(visHigh, high), high)
    visLow  := math.min(nz(visLow, low), low)

f_inRange(float price) =>
    bool inAtr = math.abs(price - close) <= band
    bool inVis = na(visHigh) or (price >= visLow and price <= visHigh)
    filterModeInput == "Visible price range" ? inVis : filterModeInput == "Within N ATR" ? inAtr : inVis and inAtr

// Chart timeframe: the pivot is at bar [right] once confirmed on this bar.
float chartPh = ta.pivothigh(leftInput, rightInput)
float chartPl = ta.pivotlow(leftInput, rightInput)
int   chartPt = time[rightInput]

// Higher timeframes: the previous HTF bar's confirmed pivot, fetched with lookahead on, so
// the value is fixed from the moment the confirming HTF bar closes and never repaints.
f_htfPivots(simple string tf) =>
    request.security(syminfo.tickerid, tf, [ta.pivothigh(leftInput, rightInput)[1], ta.pivotlow(leftInput, rightInput)[1], time[rightInput + 1]], lookahead=barmerge.lookahead_on)

[htf1Ph, htf1Pl, htf1Pt] = f_htfPivots(htf1TfInput)
[htf2Ph, htf2Pl, htf2Pt] = f_htfPivots(htf2TfInput)
[htf3Ph, htf3Pl, htf3Pt] = f_htfPivots(htf3TfInput)

// One call site per timeframe, so the var dedupe state is per timeframe. The HTF values
// repeat on every chart bar inside the next HTF bar; the stored time catches the repeats.
f_collect(array<Pivot> arr, int level, float ph, float pl, int t, bool enabled) =>
    var int lastHighT = -1
    var int lastLowT  = -1
    if enabled
        if not na(ph) and t != lastHighT
            array.push(arr, Pivot.new(price=ph, t=t, isHigh=true, level=level))
            lastHighT := t
        if not na(pl) and t != lastLowT
            array.push(arr, Pivot.new(price=pl, t=t, isHigh=false, level=level))
            lastLowT := t
        while array.size(arr) > keepInput
            array.shift(arr)

f_collect(piv0, 0, chartPh, chartPl, chartPt, chartOnInput)
f_collect(piv1, 1, htf1Ph, htf1Pl, htf1Pt, htf1Active)
f_collect(piv2, 2, htf2Ph, htf2Pl, htf2Pt, htf2Active)
f_collect(piv3, 3, htf3Ph, htf3Pl, htf3Pt, htf3Active)

// Previous-period highs and lows. The price comes from the period's own series (the last
// completed bar, lookahead on, so it is fixed the moment the period opens and never
// repaints) because the chart may not have loaded the whole previous period, a month on a
// 5-minute chart for one. The chart's own running extremes supply the exact bar that made
// the high or low whenever that bar is loaded; otherwise the ray starts at the period's open.
f_prevPeriod(simple string tf) =>
    [pH, pL, pT] = request.security(syminfo.tickerid, tf, [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)
    var float curH  = na
    var int   curHT = na
    var float curL  = na
    var int   curLT = na
    var float lastH  = na
    var int   lastHT = na
    var float lastL  = na
    var int   lastLT = na
    if timeframe.change(tf) and not na(curH)
        lastH  := curH
        lastHT := curHT
        lastL  := curL
        lastLT := curLT
        curH  := high
        curHT := time
        curL  := low
        curLT := time
    else
        if na(curH) or high > curH
            curH  := high
            curHT := time
        if na(curL) or low < curL
            curL  := low
            curLT := time
    float half = syminfo.mintick / 2
    int hT = not na(lastH) and math.abs(lastH - pH) < half and lastHT >= pT ? lastHT : pT
    int lT = not na(lastL) and math.abs(lastL - pL) < half and lastLT >= pT ? lastLT : pT
    [pH, hT, pL, lT, pT]

[pdH, pdHT, pdL, pdLT, pdKey] = f_prevPeriod(pdTfInput)
[pwH, pwHT, pwL, pwLT, pwKey] = f_prevPeriod(pwTfInput)
[pmH, pmHT, pmL, pmLT, pmKey] = f_prevPeriod(pmTfInput)

// The key is the previous period's open time: it changes exactly when a new period starts,
// and that is when the old pair (live or not) is replaced by the new one.
// The midpoint starts at the period's open and lives in the same array as the pair.
f_setPrev(array<Pivot> arr, int levelH, int levelMid, float ph, int pht, float pl, int plt, int key, bool enabled) =>
    var int lastKey = na
    if enabled and not na(key) and (na(lastKey) or key != lastKey)
        array.clear(arr)
        if not na(ph)
            array.push(arr, Pivot.new(price=ph, t=pht, isHigh=true, level=levelH))
        if not na(pl)
            array.push(arr, Pivot.new(price=pl, t=plt, isHigh=false, level=levelH + 1))
        if midOnInput and not na(ph) and not na(pl)
            array.push(arr, Pivot.new(price=(ph + pl) / 2, t=key, isHigh=true, level=levelMid))
        lastKey := key
    // A separate if, not an else branch: this is the function's last statement, and an
    // if/else whose branches return an int and void does not compile (CE10235).
    if not enabled
        array.clear(arr)

f_setPrev(prevD, 4, 16, pdH, pdHT, pdL, pdLT, pdKey, pdActive)
f_setPrev(prevW, 6, 17, pwH, pwHT, pwL, pwLT, pwKey, pwActive)
f_setPrev(prevM, 8, 18, pmH, pmHT, pmL, pmLT, pmKey, pmActive)

// Sessions. A bar is in the session when its open falls inside the window, read in the
// session time zone. The running high and low (and the bars that made them) are kept while
// the session is open; on the first bar after it, the pair replaces the last session's. The
// key is that bar's time, so the reclaim tracking resets once per completed session.
f_session(array<Pivot> arr, int levelH, simple string sess, bool enabled) =>
    var float curH    = na
    var int   curHT   = na
    var float curL    = na
    var int   curLT   = na
    var float lastH   = na
    var float lastL   = na
    var int   lastKey = na
    var bool  prevIn  = false
    bool inS = enabled and not na(time(timeframe.period, sess, sessTzInput))
    if inS and not prevIn
        curH  := high
        curHT := time
        curL  := low
        curLT := time
    else if inS
        if high > curH
            curH  := high
            curHT := time
        if low < curL
            curL  := low
            curLT := time
    if not inS and prevIn and not na(curH)
        array.clear(arr)
        array.push(arr, Pivot.new(price=curH, t=curHT, isHigh=true, level=levelH))
        array.push(arr, Pivot.new(price=curL, t=curLT, isHigh=false, level=levelH + 1))
        lastH   := curH
        lastL   := curL
        lastKey := time
    if not enabled
        array.clear(arr)
    prevIn := inS
    [lastH, lastL, lastKey]

[asH, asL, asKey] = f_session(sessA, 10, asSessInput, asActive)
[loH, loL, loKey] = f_session(sessL, 12, loSessInput, loActive)
[nyH, nyL, nyKey] = f_session(sessN, 14, nySessInput, nyActive)

// Swept and reclaimed. Tracked on the period's levels themselves, not on the drawn rays, so
// it holds whatever the break rule has done to the ray: under wick breaks the sweep bar has
// already turned the ray dashed, and the reclaim is the close that comes back inside.
f_reclaim(float lvlH, float lvlL, int key, bool enabled) =>
    var int  curKey = na
    var bool sweptH = false
    var bool sweptL = false
    var bool doneH  = false
    var bool doneL  = false
    if na(curKey) or key != curKey
        curKey := key
        sweptH := false
        sweptL := false
        doneH  := false
        doneL  := false
    bool rH = false
    bool rL = false
    if enabled
        if not na(lvlH) and high > lvlH
            sweptH := true
        if not na(lvlL) and low < lvlL
            sweptL := true
        if barstate.isconfirmed and sweptH and not doneH and close < lvlH
            rH    := true
            doneH := true
        if barstate.isconfirmed and sweptL and not doneL and close > lvlL
            rL    := true
            doneL := true
    [rH, rL]

// A row at the chart timeframe is the previous bar, and a reclaim of it fires on most bars,
// so by default only rows strictly above the chart timeframe mark and alert.
[pdRH, pdRL] = f_reclaim(pdH, pdL, pdKey, pdActive and (sameTfInput or timeframe.in_seconds(pdTfInput) > chartSec))
[pwRH, pwRL] = f_reclaim(pwH, pwL, pwKey, pwActive and (sameTfInput or timeframe.in_seconds(pwTfInput) > chartSec))
[pmRH, pmRL] = f_reclaim(pmH, pmL, pmKey, pmActive and (sameTfInput or timeframe.in_seconds(pmTfInput) > chartSec))
[asRH, asRL] = f_reclaim(asH, asL, asKey, asActive)
[loRH, loRL] = f_reclaim(loH, loL, loKey, loActive)
[nyRH, nyRL] = f_reclaim(nyH, nyL, nyKey, nyActive)

bool reclaimHigh = pdRH or pwRH or pmRH or asRH or loRH or nyRH
bool reclaimLow  = pdRL or pwRL or pmRL or asRL or loRL or nyRL

f_add(string txt, bool hit, string tag, float price) =>
    hit ? (txt == "" ? "" : txt + ", ") + tag + " " + str.tostring(price, format.mintick) : txt

if reclaimHigh
    string lv = f_add(f_add(f_add(f_add(f_add(f_add("", pmRH, pmHTagInput, pmH), pwRH, pwHTagInput, pwH), pdRH, pdHTagInput, pdH), nyRH, nyHTagInput, nyH), loRH, loHTagInput, loH), asRH, asHTagInput, asH)
    alert(syminfo.ticker + " " + timeframe.period + ": swept and reclaimed " + lv + ", closed back below at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if reclaimLow
    string lv = f_add(f_add(f_add(f_add(f_add(f_add("", pmRL, pmLTagInput, pmL), pwRL, pwLTagInput, pwL), pdRL, pdLTagInput, pdL), nyRL, nyLTagInput, nyL), loRL, loLTagInput, loL), asRL, asLTagInput, asL)
    alert(syminfo.ticker + " " + timeframe.period + ": swept and reclaimed " + lv + ", closed back above at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

alertcondition(reclaimHigh, "Swept and reclaimed a high", "{{ticker}} {{interval}}: swept a previous-period or session high and closed back below it at {{close}}")
alertcondition(reclaimLow,  "Swept and reclaimed a low",  "{{ticker}} {{interval}}: swept a previous-period or session low and closed back above it at {{close}}")

plotshape(markInput and reclaimHigh, "Reclaimed high", shape.triangledown, location.abovebar, markHighInput, size=size.tiny, display=display.pane)
plotshape(markInput and reclaimLow,  "Reclaimed low",  shape.triangleup,   location.belowbar, markLowInput,  size=size.tiny, display=display.pane)

// Breaks. A live pivot leaves its timeframe's array the bar price goes through it and
// joins the broken list stamped with that bar. Because every break removes a pivot, the
// live arrays hold only the levels price has never taken out: the staircase of highs
// above and lows below, which stays small however long the chart is.
bool  breakOnClose = breakOnInput == "Close"
float upProbe      = breakOnClose ? close : high
float downProbe    = breakOnClose ? close : low
bool  checkBreaks  = not breakOnClose or barstate.isconfirmed

// The expiry period the current bar belongs to. A period at or below the chart timeframe
// means every bar is its own period, so a dashed ray lasts for the break bar only.
int expireSec = timeframe.in_seconds(brokenExpireTfInput)
int expireT   = time(brokenExpireTfInput)
int periodT   = expireSec <= chartSec or na(expireT) ? time : expireT

f_checkBreaks(array<Pivot> arr) =>
    int n = array.size(arr)
    if checkBreaks and n > 0
        for i = n - 1 to 0
            Pivot p = array.get(arr, i)
            bool hit = p.level < FIRST_MID_LEVEL and (p.isHigh ? upProbe > p.price : downProbe < p.price)
            if hit
                p.brokenT := time
                p.brokenP := periodT
                array.push(broken, p)
                array.remove(arr, i)

f_checkBreaks(piv0)
f_checkBreaks(piv1)
f_checkBreaks(piv2)
f_checkBreaks(piv3)
f_checkBreaks(prevD)
f_checkBreaks(prevW)
f_checkBreaks(prevM)
f_checkBreaks(sessA)
f_checkBreaks(sessL)
f_checkBreaks(sessN)

// Expire: breaks from an earlier period leave at that period's close. Pushes arrive in
// time order, so anything stale is at the front.
if brokenExpireInput
    while array.size(broken) > 0 and array.get(broken, 0).brokenP != periodT
        array.shift(broken)

// Keep the last N break EVENTS: pivots broken on the same bar share a stamp and stay or go
// together. Pushes arrive in time order, so the oldest stamp is always at the front.
int keepEvents = brokenOnInput ? brokenKeepInput : 0
if array.size(broken) > 0
    int events = 1
    for i = 1 to math.max(1, array.size(broken) - 1)
        if i < array.size(broken) and array.get(broken, i).brokenT != array.get(broken, i - 1).brokenT
            events += 1
    while events > keepEvents and array.size(broken) > 0
        int oldest = array.get(broken, 0).brokenT
        while array.size(broken) > 0 and array.get(broken, 0).brokenT == oldest
            array.shift(broken)
        events -= 1

// All-time high. The chart's own running max (first occurrence; Pine rolls var state back
// on each realtime tick, so a developing high never sticks early) covers the loaded bars
// and the open month. The monthly request covers everything before the chart's first bar:
// TradingView computes the monthly series over the symbol's whole history and hands back
// the running max as of the last closed month. The higher of the two is the ATH, and the
// chart's finer bar time is used whenever the chart has the record bar itself.
var float loadedAth  = na
var int   loadedAthT = na
if na(loadedAth) or high > loadedAth
    loadedAth  := high
    loadedAthT := time

[monthlyAth, monthlyAthT] = request.security(syminfo.tickerid, "M", [ta.max(high), ta.valuewhen(high == ta.max(high), time, 0)])

bool  useHistory = athSourceInput == "Full history" and not na(monthlyAth)
float ath  = useHistory ? math.max(monthlyAth, loadedAth) : loadedAth
int   athT = useHistory and monthlyAth > loadedAth ? monthlyAthT : loadedAthT
//}

// --------------------- Drawing { ----------------------------- \\
f_hasLevel(int mask, int level) =>
    int(math.floor(mask / math.pow(2, level))) % 2 == 1

f_labelSize() =>
    labelSizeInput == "tiny" ? size.tiny : labelSizeInput == "small" ? size.small : labelSizeInput == "large" ? size.large : labelSizeInput == "huge" ? size.huge : size.normal

// Tag text runs from the highest level down, e.g. "PDH W D 4H".
f_tagText(int mask) =>
    string txt = ""
    for lv = TOP_LEVEL to 0
        if f_hasLevel(mask, lv)
            string tag = array.get(levelTags, lv)
            if tag != ""
                txt := txt == "" ? tag : txt + " " + tag
    txt

f_gather(array<Pivot> src, array<float> cPrice, array<int> cT, array<int> cLevel, array<bool> cHigh) =>
    for p in src
        bool sideOn  = p.level >= FIRST_PREV_LEVEL or (p.isHigh ? showHighsInput : showLowsInput)
        bool isAth   = athOnInput and p.isHigh and p.price == ath
        if sideOn and not isAth and f_inRange(p.price)
            array.push(cPrice, p.price)
            array.push(cT, p.t)
            array.push(cLevel, p.level)
            array.push(cHigh, p.isHigh)

// Merge by price: walk the candidates in price order and fold same-price neighbors into
// one ray. The ray takes its start bar, width and side from the LOWEST timeframe in the
// group (chart first), because a higher-timeframe pivot is only known to the resolution
// of its bar: a daily pivot on a 5-minute chart is stamped with the day's open, hours
// before the candle that actually made the high. The tag still lists every timeframe.
// Two pivots of the same timeframe at one price (a double top) start at the earlier one.
f_merge(array<float> cPrice, array<int> cT, array<int> cLevel, array<bool> cHigh) =>
    array<float> mPrice = array.new<float>()
    array<int>   mT     = array.new<int>()
    array<int>   mMask  = array.new<int>()
    array<int>   mLevel = array.new<int>()
    array<bool>  mHigh  = array.new<bool>()
    if array.size(cPrice) > 0
        float tol = (mergeTicksInput + 0.5) * syminfo.mintick
        array<int> order = array.sort_indices(cPrice)
        for idx in order
            float pr = array.get(cPrice, idx)
            int   tt = array.get(cT, idx)
            int   lv = array.get(cLevel, idx)
            bool  hi = array.get(cHigh, idx)
            int   n  = array.size(mPrice)
            if n > 0 and math.abs(pr - array.get(mPrice, n - 1)) <= tol
                if not f_hasLevel(array.get(mMask, n - 1), lv)
                    array.set(mMask, n - 1, array.get(mMask, n - 1) + int(math.pow(2, lv)))
                int curLevel = array.get(mLevel, n - 1)
                if lv < curLevel
                    array.set(mLevel, n - 1, lv)
                    array.set(mT, n - 1, tt)
                    array.set(mPrice, n - 1, pr)
                    array.set(mHigh, n - 1, hi)
                else if lv == curLevel
                    array.set(mT, n - 1, math.min(array.get(mT, n - 1), tt))
            else
                array.push(mPrice, pr)
                array.push(mT, tt)
                array.push(mMask, int(math.pow(2, lv)))
                array.push(mLevel, lv)
                array.push(mHigh, hi)
    [mPrice, mT, mMask, mLevel, mHigh]

// At the pivot, the tag sits on the empty side of the level (above a high, below a low)
// at the bar that made it. At the right edge it hangs left from the anchor bar.
// A merged ray's color is its highest level's, so a PDH that is also a chart pivot reads as
// the PDH; the start bar and width still come from the lowest level, as above.
f_rowColor(int mask) =>
    color c = na
    for lv = TOP_LEVEL to 0
        if na(c) and f_hasLevel(mask, lv)
            c := array.get(levelColors, lv)
    c

f_kind(int mask) =>
    mask >= int(math.pow(2, FIRST_PREV_LEVEL)) ? "level" : "pivot"

f_draw(int t0, float price, bool isHigh, color col, color txtCol, int width, string lineStyle, string txt, string tip) =>
    int x1 = math.max(t0, firstBarTime)
    line ln = line.new(x1=x1, y1=price, x2=time + 1, y2=price, xloc=xloc.bar_time, extend=extend.right, color=col, width=width, style=lineStyle)
    array.push(rays, ln)
    if txt != ""
        string full = showPriceInput ? txt + " " + str.tostring(price, format.mintick) : txt
        if labelPosInput == "Pivot"
            array.push(tags, label.new(x1, price, full, xloc=xloc.bar_time, yloc=yloc.price, color=noColor, style=isHigh ? label.style_label_down : label.style_label_up, textcolor=txtCol, size=f_labelSize(), tooltip=tip))
        else
            array.push(tags, label.new(bar_index + labelOffsetInput, price, full, xloc=xloc.bar_index, yloc=yloc.price, color=noColor, style=label.style_label_right, textcolor=txtCol, size=f_labelSize(), tooltip=tip))

if barstate.islast
    for ln in rays
        line.delete(ln)
    array.clear(rays)
    for lb in tags
        label.delete(lb)
    array.clear(tags)

    string dateFmt = chartSec >= 86400 ? "yyyy-MM-dd" : "yyyy-MM-dd HH:mm"

    // Live candidates inside the filter, from every timeframe.
    array<float> cPrice = array.new<float>()
    array<int>   cT     = array.new<int>()
    array<int>   cLevel = array.new<int>()
    array<bool>  cHigh  = array.new<bool>()
    f_gather(piv0, cPrice, cT, cLevel, cHigh)
    f_gather(piv1, cPrice, cT, cLevel, cHigh)
    f_gather(piv2, cPrice, cT, cLevel, cHigh)
    f_gather(piv3, cPrice, cT, cLevel, cHigh)
    f_gather(prevD, cPrice, cT, cLevel, cHigh)
    f_gather(prevW, cPrice, cT, cLevel, cHigh)
    f_gather(prevM, cPrice, cT, cLevel, cHigh)
    f_gather(sessA, cPrice, cT, cLevel, cHigh)
    f_gather(sessL, cPrice, cT, cLevel, cHigh)
    f_gather(sessN, cPrice, cT, cLevel, cHigh)
    [mPrice, mT, mMask, mLevel, mHigh] = f_merge(cPrice, cT, cLevel, cHigh)

    // Nearest first when the filter passes more than the cap, with any ray that carries a
    // previous-period level ahead of every pivot-only ray.
    array<int> drawOrder = array.new<int>()
    if array.size(mPrice) > maxRaysInput
        array<float> dist = array.new<float>()
        for [i, pr] in mPrice
            array.push(dist, f_kind(array.get(mMask, i)) == "level" ? -1.0 : math.abs(pr - close))
        array<int> nearest = array.sort_indices(dist)
        for i = 0 to maxRaysInput - 1
            array.push(drawOrder, array.get(nearest, i))
    else
        for [i, pr] in mPrice
            array.push(drawOrder, i)

    for i in drawOrder
        float pr   = array.get(mPrice, i)
        int   t0   = array.get(mT, i)
        int   lv   = array.get(mLevel, i)
        int   mask = array.get(mMask, i)
        string txt = f_tagText(mask)
        string tip = (txt == "" ? "" : txt + " ") + f_kind(mask) + "  " + str.format_time(t0, dateFmt, syminfo.timezone)
        color rowC = f_rowColor(mask)
        color col  = colorByRowInput ? color.new(rowC, transpInput) : rayColor
        color tcol = colorByRowInput ? rowC : labelColor
        f_draw(t0, pr, array.get(mHigh, i), col, tcol, array.get(levelWidths, lv), line.style_solid, txt, tip)

    // The last break events, dashed and fainter, merged the same way.
    array<float> bPrice = array.new<float>()
    array<int>   bT     = array.new<int>()
    array<int>   bLevel = array.new<int>()
    array<bool>  bHigh  = array.new<bool>()
    f_gather(broken, bPrice, bT, bLevel, bHigh)
    [xPrice, xT, xMask, xLevel, xHigh] = f_merge(bPrice, bT, bLevel, bHigh)
    for [i, pr] in xPrice
        int   t0   = array.get(xT, i)
        int   lv   = array.get(xLevel, i)
        int   mask = array.get(xMask, i)
        string txt = f_tagText(mask)
        string tip = "broken " + (txt == "" ? "" : txt + " ") + f_kind(mask) + "  " + str.format_time(t0, dateFmt, syminfo.timezone)
        color rowC = f_rowColor(mask)
        color col  = colorByRowInput ? color.new(rowC, math.min(95, transpInput + brokenDimInput)) : brokenColor
        color tcol = colorByRowInput ? color.new(rowC, brokenDimInput) : brokenLabelColor
        f_draw(t0, pr, array.get(xHigh, i), col, tcol, array.get(levelWidths, lv), line.style_dashed, txt, tip)

    if athOnInput and not na(ath) and (athAlwaysInput or f_inRange(ath))
        f_draw(athT, ath, true, athColor, labelColor, athWidthInput, line.style_dotted, athTagInput, (useHistory ? "all-time high  " : "all-time high of the loaded bars  ") + str.format_time(athT, dateFmt, syminfo.timezone))
//}
````
