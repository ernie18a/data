# Triple Moving Averages (TriMA)

- url: https://www.tradingview.com/script/ZWBn8dHp-Triple-Moving-Averages-TriMA/
- type: indicator
- pine_id: PUB;87e011e7263f4a3e8ed498dcdc239c6a
- version: 1.0

## Description

[b]Triple Moving Averages (TriMA)[/b]

[b]Triple Moving Averages (TriMA)[/b] is a flexible multi-timeframe trend analysis indicator that displays up to three independently configurable moving averages on a single chart. Each moving average can use its own calculation method, price source, length, and timeframe, making it ideal for trend following, market structure analysis, and higher-timeframe context without switching charts.

────────────────────────────────────

[b]Key Features[/b]

[b]Three Independent Moving Averages[/b]
Display up to three moving averages simultaneously. The 2nd and 3rd MAs can be enabled or disabled independently for simplified or advanced analysis.

[b]Multiple Moving Average Types[/b]
Each MA supports:
- Hull Moving Average (HMA)
- Simple Moving Average (SMA)
- Weighted Moving Average (WMA)
- Volume Weighted Moving Average (VWMA)
- Smoothed Moving Average (SWMA)
- Running Moving Average (RMA)

All moving averages operate independently and can be combined freely.

[b]Independent Timeframes[/b]
Each MA can be calculated from a different timeframe while plotted on the current chart.

Example:
- 180 HMA on 1-minute
- 288 SMA on 5-minute
- 720 VWMA on 10-minute

This provides built-in multi-timeframe trend context.

[b]Independent Lengths & Sources[/b]
Each MA has its own:
- Length
- Price source (Close, HLCC4, OHLC4, etc.)
- Calculation type
- Timeframe

────────────────────────────────────

[b]Automatic Time Labels[/b]

Optional labels show:
- MA type
- Effective timeframe duration (real-world time equivalent)

Examples:
- HMA 3 h
- SMA 5 d
- VWMA 2.5 mnth

The indicator converts Length × Timeframe into intuitive time duration, making it easier to understand the real smoothing strength of each MA.

────────────────────────────────────

[b]Smart Label Positioning[/b]

Labels are:
- Plotted directly on each MA
- Offset from the latest price action
- Automatically oriented based on slope (up/down)

This keeps the chart clean while maintaining readability.

────────────────────────────────────

[b]Visual Customization[/b]

You can customize:
- Line colors
- Transparency
- Label text color
- Label size
- Label visibility
- Offset position

Each MA is fully independent in styling.

────────────────────────────────────

[b]Typical Uses[/b]

[b]Trend Identification[/b]
Detect overall market direction using slower MAs.

[b]Multi-Timeframe Analysis[/b]
Combine higher timeframe trend context with lower timeframe execution.

[b]Dynamic Support & Resistance[/b]
Use MAs as dynamic reaction zones in trending markets.

[b]Trend Alignment[/b]
Identify when multiple timeframes align for higher-probability setups.

[b]Market Context[/b]
Avoid trading against higher timeframe direction.

────────────────────────────────────

[b]Default Setup[/b]

- MA1: 180 HMA (1-minute)
- MA2: 288 HMA (5-minute)
- MA3: 720 HMA (10-minute)

This creates a balanced short/medium/long trend structure.

────────────────────────────────────

[b]Highlights[/b]

- Up to 3 independent moving averages
- 6 MA calculation methods
- Full multi-timeframe support
- Independent settings per MA
- Automatic time-based labeling
- Clean visual structure
- Fully customizable appearance

[b]TriMA[/b] is designed for traders who want a clean but powerful multi-timeframe trend system combining multiple moving averages into one structured view.

## Source Code

````pine
//@version=6
//@Author: Bodfinmag
indicator("Triple Moving Averages", shorttitle="TriMA", overlay=true)

// =====================================================
// INPUTS
// =====================================================

enum smSource
    SMA
    WMA
    HMA
    VWMA
    SWMA
    RMA 

// Checkbox's for the other 2 MA's
a = input.bool(true, title="Enable 2nd MA")
b = input.bool(true, title="Enable 3rd MA")

srcEnum1   = input.enum(smSource.HMA, "MA Source", group="MA source")
srcEnum2   = input.enum(smSource.HMA, "MA2 Source", group="MA source")
srcEnum3   = input.enum(smSource.HMA, "MA3 Source", group="MA source")

len1 = input.int(180, minval=1, title="Length", group="Length")
len2 = input.int(288, minval=1, title="Length2", group="Length")
len3 = input.int(720, minval=1, title="Length3", group="Length")

src1 = input(hlcc4, title="Source", group="Source")
src2 = input(hlcc4, title="Source2", group="Source")
src3 = input(hlcc4, title="Source3", group="Source")

timefr1    = input.timeframe(title="Timeframe", defval="1",  confirm=false, group="Timeframe")
timefr2    = input.timeframe(title="Timeframe2", defval="5",  confirm=false, group="Timeframe")
timefr3    = input.timeframe(title="Timeframe3", defval="10",  confirm=false, group="Timeframe")

enablel   = input.bool(true, "Dispay labels", group="Visuals")
c1        = input.color(defval = color.blue, title = "MA color", group="Visuals")
c2        = input.color(defval = color.green, title = "MA2 color", group="Visuals")
c3        = input.color(defval = color.red, title = "MA3 color", group="Visuals")
tc        = input.color(defval = color.white, title = "Label text color", group="Visuals")
lts       = input.string(title="Label text size", defval="small", options=["auto","tiny","small","normal","large","huge"], group="Visuals")
bar       = input.int(15, minval=0, title="Label offset", group="Visuals")
t         = input.int(10,  "Transparency, %", minval = 0, group="Visuals") 

// Table text size
ltextsize = lts == "auto"   ? size.auto  :
           lts == "tiny"   ? size.tiny  :
           lts == "small"  ? size.small :
           lts == "normal" ? size.normal:
           lts == "large"  ? size.large :
           lts == "huge"   ? size.huge  :
                                      na

// =====================================================
// SOURCE
// =====================================================

float masrc1 = switch srcEnum1
    smSource.SMA   => ta.sma(src1, len1)
    smSource.WMA   => ta.wma(src1, len1)
    smSource.HMA   => ta.hma(src1, len1)  
    smSource.VWMA  => ta.vwma(src1, len1)
    smSource.SWMA  => ta.swma(src1)
    smSource.RMA   => ta.rma(src1, len1)
    => close

float masrc2 = switch srcEnum2
    smSource.SMA   => ta.sma(src2, len2)
    smSource.WMA   => ta.wma(src2, len2)
    smSource.HMA   => ta.hma(src2, len2)  
    smSource.VWMA  => ta.vwma(src2, len2)
    smSource.SWMA  => ta.swma(src2)
    smSource.RMA   => ta.rma(src2, len2)
    => close

float masrc3 = switch srcEnum3
    smSource.SMA   => ta.sma(src3, len3)
    smSource.WMA   => ta.wma(src3, len3)
    smSource.HMA   => ta.hma(src3, len3)  
    smSource.VWMA  => ta.vwma(src3, len3)
    smSource.SWMA  => ta.swma(src3)
    smSource.RMA   => ta.rma(src3, len3)
    => close

// Label variable
var label Label1 = na
var label Label2 = na
var label Label3 = na

out1  = request.security(syminfo.tickerid, timefr1, masrc1,  barmerge.gaps_off, barmerge.lookahead_off)
out2 = request.security(syminfo.tickerid, timefr2, masrc2,  barmerge.gaps_off, barmerge.lookahead_off)
out3 = request.security(syminfo.tickerid, timefr3, masrc3,  barmerge.gaps_off, barmerge.lookahead_off)

plot(out1, title="MA", color = color.new(c1, t))
plot(a ? out2 : na, title="MA2", color = color.new(c2, t))
plot(b ? out3 : na, title="MA3", color = color.new(c3, t))

bar1 = bar + 15
bar2 = bar1 + 15

style1 = out1[bar+1] > out1[bar] ? label.style_label_down : label.style_label_up
style2 = out2[bar1+1] > out2[bar1] ? label.style_label_down : label.style_label_up
style3 = out3[bar2+1] > out3[bar2] ? label.style_label_down : label.style_label_up

string t1 = switch
    math.round((len1 * str.tonumber(timefr1))/60/24/24,1) >= 1 => str.tostring(srcEnum2) + " " + str.tostring((len1 * str.tonumber(timefr1)/60/24/24), "#.#") + " y"
    math.round((len1 * str.tonumber(timefr1))/60/24/12,1) >= 1 => str.tostring(srcEnum2) + " " + str.tostring((len1 * str.tonumber(timefr1)/60/24/12), "#.#") + " mnth"
    math.round((len1 * str.tonumber(timefr1))/60/24,1) >= 1    => str.tostring(srcEnum2) + " " + str.tostring((len1 * str.tonumber(timefr1)/60/24),    "#.#") + " d"
    math.round((len1 * str.tonumber(timefr1))/60,1) >= 1       => str.tostring(srcEnum2) + " " + str.tostring((len1 * str.tonumber(timefr1)/60),       "#.#") + " h"
    math.round((len1 * str.tonumber(timefr1))/60,1) < 1       => str.tostring(srcEnum2) + " " + str.tostring(len1 * str.tonumber(timefr1),           "#.#") + " m"
    => na

string t2 = switch
    math.round((len2 * str.tonumber(timefr2))/60/24/24,1) >= 1 => str.tostring(srcEnum2) + " " + str.tostring((len2 * str.tonumber(timefr2)/60/24/24), "#.#") + " y"
    math.round((len2 * str.tonumber(timefr2))/60/24/12,1) >= 1 => str.tostring(srcEnum2) + " " + str.tostring((len2 * str.tonumber(timefr2)/60/24/12), "#.#") + " mnth"
    math.round((len2 * str.tonumber(timefr2))/60/24,1) >= 1    => str.tostring(srcEnum2) + " " + str.tostring((len2 * str.tonumber(timefr2)/60/24),    "#.#") + " d"
    math.round((len2 * str.tonumber(timefr2))/60,1) >= 1       => str.tostring(srcEnum2) + " " + str.tostring((len2 * str.tonumber(timefr2)/60),       "#.#") + " h"
    math.round((len2 * str.tonumber(timefr2))/60,1) < 1      => str.tostring(srcEnum2) + " " + str.tostring(len2 * str.tonumber(timefr2),           "#.#") + " m"
    => na

string t3 = switch
    math.round((len3 * str.tonumber(timefr3))/60/24/24,1) >= 1 => str.tostring(srcEnum3) + " " + str.tostring((len3 * str.tonumber(timefr3)/60/24/24), "#.#") + " y"
    math.round((len3 * str.tonumber(timefr3))/60/24/12,1) >= 1 => str.tostring(srcEnum3) + " " + str.tostring((len3 * str.tonumber(timefr3)/60/24/12), "#.#") + " mnth"
    math.round((len3 * str.tonumber(timefr3))/60/24,1) >= 1    => str.tostring(srcEnum3) + " " + str.tostring((len3 * str.tonumber(timefr3)/60/24),    "#.#") + " d"
    math.round((len3 * str.tonumber(timefr3))/60,1) >= 1       => str.tostring(srcEnum3) + " " + str.tostring((len3 * str.tonumber(timefr3)/60),       "#.#") + " h"
    math.round((len3 * str.tonumber(timefr3))/60,1) < 1      => str.tostring(srcEnum3) + " " + str.tostring(len3 * str.tonumber(timefr3),           "#.#") + " m"
    => na

// Show label on the th bar from the right
if barstate.islast and bar_index >= bar

    // Delete old label
    if not na(Label1)
        label.delete(Label1)
    if not na(Label2)
        label.delete(Label2)
    if not na(Label3)
        label.delete(Label3)

    if enablel
        // Create label n bars back
        Label1 := label.new(
            bar_index - bar,                         // bar from latest
            out1[bar],                            
            text = t1,
            style = style1,
            color = color.new(c1, t),
            textcolor = color.new(tc, t),
            size = ltextsize
        )

    if a and enablel
        // Create label n bars back
        Label2 := label.new(
            bar_index - bar1,                         
            out2[bar1],                            
            text = t2,
            style = style2,
            color = color.new(c2, t),
            textcolor = color.new(tc, t),
            size = ltextsize
        )

    if b and enablel
        Label3 := label.new(
            bar_index - bar2,                         
            out3[bar2],                            
            text = t3,
            style = style3,
            color = color.new(c3, t),
            textcolor = color.new(tc, t),
            size = ltextsize
        )
````
