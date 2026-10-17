# Initial Balance Breaks [NQ stats x CantoLab]

- url: https://www.tradingview.com/script/mtbb3Y9x-Initial-Balance-Breaks-NQ-stats-x-CantoLab/
- type: indicator
- pine_id: PUB;19fedfee8f0446948b7ba0b704ad9655
- version: 1.0

## Description

An open source indicator built around the Initial Balance break statistics from NQ Stats (nqstats.com). Credit to NQ Stats for the original research — published here with permission.

[b]⚠️ Important
This is a statistical study indicator. It does not guarantee that the IB high or low will be hit. Over a large sample, this is the expected behaviour based on 10 years of NQ data. It is best combined with other confluences to confirm direction — this indicator alone is not a strategy.[/b]

[b]What is the Initial Balance?[/b]
The Initial Balance (IB) is the price range established during the first hour of the New York equity session — 09:30 to 10:30 ET. The high and low set within this window become key levels for the rest of the trading day.

Based on 10 years of NQ data, IB breaks 83% of the time before noon and 96% of the time before 4:00 PM. [b]The stat alone doesn't give you direction[/b] — but combined with where the IB closes relative to its own midpoint, you get a directional edge:

IB closes in the upper half → high breaks 82% of the time
IB closes in the lower half → low breaks 76% of the time

[b]What it does[/b]
Once the IB window closes at 10:30, the indicator plots the IB High, Low and Mid as levels on the chart and automatically determines the directional bias based on where price closed within the IB range.

The expected break side is labelled with its probability and a tracking line extends forward tracking whether that level gets hit. When the level is breached the label updates to show Success or Failed in real time.

IB High — upper boundary of the initial balance range
IB Low — lower boundary of the initial balance range
IB Mid — equilibrium of the range, plotted in orange. 

When price closes above mid, high break is expected. 
When price close below mid, low break is expected.

Probability line — extends from IB close forward on the expected side, updates to Success or Failed when hit

[b]Settings[/b]
[list]
[*]IB Time — configurable session window, default 09:30–10:30 NY time
[*]Label Size — Tiny / Small / Normal / Large / Huge
[*]Per-level line style and width — IB High, Low, Mid and vertical markers
[*]Auto color — IB High and Low auto-adapt to chart theme, or set manually
[/list]

[b]Notes[/b]
[list]
[*]Built for NQ Futures. Behaviour on other instruments is untested
[*]All times are New York time
[*][b]Current version tracks directional bias from IB close relative to midpoint. The 83% before noon and 96% before 4PM time-based breach tracking and IB formation order confluence are not yet implemented[/b]
[*]Probability data derived from 10 years of NQ historical data by NQ Stats.
[*]This indicator does not provide financial advice or a complete strategy. You are responsible for how you build around and execute on this data
[/list]

## Source Code

````pine
//@version=6
indicator("Initial Balance Breaks [NQ stats x CantoLab]", overlay=true, max_lines_count=500, max_labels_count=500)


//#region [UTILS]
noColor = color.new(color.white, 100)

f_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.auto

f_st(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        =>          line.style_dashed

f_lbl(int t, float y, string txt, color c, string sz) =>
    label.new(t, y, txt, xloc.bar_time, style=label.style_label_left, color=noColor, textcolor=c, size=f_sz(sz), text_font_family=font.family_monospace)
//#endregion


//#region [TYPES]
type IBLevel
    line  ln
    label lbl

type IBSweep
    line  hi
    line  lo
    float hi_price
    float lo_price
    bool  hi_hit
    bool  lo_hit
    bool  bias_hi
    label hi_lbl
    label lo_lbl

type IBSetup
    IBLevel hi
    IBLevel mid
    IBLevel lo
    line    v_start
    line    v_end
    label   bias_hi
    label   bias_lo
    int     t_end
    IBSweep swp
    bool    last_bias_hi

method setXY(IBLevel self, int t1, float y, int t2) =>
    line.set_xy1(self.ln,  t1, y)
    line.set_xy2(self.ln,  t2, y)
    label.set_xy(self.lbl, t2, y)

method init(IBLevel self, int t1, float y, int t2, color c, string st, int w, string sz) =>
    self.ln  := line.new(t1, y, t2, y, xloc.bar_time, color=c, style=f_st(st), width=w)
    self.lbl := f_lbl(t2, y, "", c, sz)
//#endregion


//#region [INPUTS]
G_GEN = "General Settings"
G_STY = "Line Customization"

lblSize      = input.string("Small",     "Labels Size", options=["Tiny","Small","Normal","Large","Huge"], group=G_GEN)
sessionInput = input.session("0930-1030","IB Time (NY)",                                                 group=G_GEN)

s_ver  = input.string("Dotted", "Vertical Lines", options=["Solid","Dotted","Dashed"], group=G_STY, inline="ver"), w_ver = input.int(1, "", minval=1, group=G_STY, inline="ver"), auto_ver = input.bool(true, "Auto", tooltip="Turn off Auto Color to edit color", group=G_STY, inline="ver"), c_ver = input.color(color.new(#808080, 50), "", group=G_STY, inline="ver", active=not auto_ver)
s_h    = input.string("Dotted", "IB High",        options=["Solid","Dotted","Dashed"], group=G_STY, inline="h"),   w_h   = input.int(1, "", minval=1, group=G_STY, inline="h"),   auto_h   = input.bool(true, "Auto", tooltip="Turn off Auto Color to edit color", group=G_STY, inline="h"),   c_h   = input.color(#808080, "", group=G_STY, inline="h",   active=not auto_h)
s_m    = input.string("Dotted", "IB Mid",         options=["Solid","Dotted","Dashed"], group=G_STY, inline="m"),   w_m   = input.int(1, "", minval=1, group=G_STY, inline="m"),   c_m   = input.color(#ff9800, "", group=G_STY, inline="m")
s_l    = input.string("Dotted", "IB Low",         options=["Solid","Dotted","Dashed"], group=G_STY, inline="l"),   w_l   = input.int(1, "", minval=1, group=G_STY, inline="l"),   auto_l   = input.bool(true, "Auto", tooltip="Turn off Auto Color to edit color", group=G_STY, inline="l"),   c_l   = input.color(#808080, "", group=G_STY, inline="l",   active=not auto_l)

eff_c_h   = auto_h   ? chart.fg_color : c_h
eff_c_l   = auto_l   ? chart.fg_color : c_l
eff_c_ver = auto_ver ? chart.fg_color : c_ver

C_EXPECTED = color.new(#4caf50, 0)
C_INVALID  = color.new(#ff5252, 0)
//#endregion


//#region [LOGIC]
TZ = "America/New_York"

var float   ib_h = na
var float   ib_l = na
var int  t_start = na
var IBSetup ib   = IBSetup.new(IBLevel.new(na, na), IBLevel.new(na, na), IBLevel.new(na, na), na, na, na, na, na, IBSweep.new(na, na, na, na, false, false, false, na, na), false)

inSess     = not na(time(timeframe.period, sessionInput, TZ))
sessOpen   = inSess and not inSess[1]
sessClose  = not inSess and inSess[1]

if inSess
    if sessOpen
        ib_h     := high
        ib_l     := low
        t_start  := time
        ib.t_end := time_close

        ib.hi.init (t_start, ib_h,                 time_close, eff_c_h, s_h, w_h, lblSize)
        ib.lo.init (t_start, ib_l,                 time_close, eff_c_l, s_l, w_l, lblSize)
        ib.mid.init(t_start, math.avg(ib_h, ib_l), time_close, c_m,     s_m, w_m, lblSize)

        ib.v_start := line.new(t_start,    ib_l, t_start,    ib_h, xloc.bar_time, color=eff_c_ver, style=f_st(s_ver), width=w_ver)
        ib.v_end   := line.new(time_close, ib_l, time_close, ib_h, xloc.bar_time, color=eff_c_ver, style=f_st(s_ver), width=w_ver)

    else
        ib_h     := math.max(high, ib_h)
        ib_l     := math.min(low,  ib_l)
        ib.t_end := time_close
        mid       = math.avg(ib_h, ib_l)

        ib.hi.setXY(t_start, ib_h, time_close)
        ib.lo.setXY(t_start, ib_l, time_close)
        ib.mid.setXY(t_start, mid, time_close)

        line.set_xy1(ib.v_start, t_start,    ib_l), line.set_xy2(ib.v_start, t_start,    ib_h)
        line.set_xy1(ib.v_end,   time_close, ib_l), line.set_xy2(ib.v_end,   time_close, ib_h)

if sessClose
    mid      = math.avg(ib_h, ib_l)
    t_mid    = t_start + math.round((ib.t_end - t_start) / 2)
    biasHi   = close[1] > mid

    ib.last_bias_hi := biasHi

    ib.bias_hi := label.new(t_mid, ib_h, biasHi ? "IB High Break Expected" : "", xloc.bar_time, style=label.style_label_down, color=noColor, textcolor=eff_c_h, size=f_sz(lblSize), text_font_family=font.family_monospace)
    ib.bias_lo := label.new(t_mid, ib_l, biasHi ? "" : "IB Low Break Expected",  xloc.bar_time, style=label.style_label_up,   color=noColor, textcolor=eff_c_l, size=f_sz(lblSize), text_font_family=font.family_monospace)

    swp          = ib.swp
    swp.hi_price := ib_h
    swp.lo_price := ib_l
    swp.hi_hit   := false
    swp.lo_hit   := false
    swp.bias_hi  := biasHi
    swp.hi       := line.new(bar_index, ib_h, bar_index, ib_h, xloc=xloc.bar_index, color=biasHi ? eff_c_h : noColor,  style=f_st(s_h), width=w_h)
    swp.lo       := line.new(bar_index, ib_l, bar_index, ib_l, xloc=xloc.bar_index, color=biasHi ? noColor  : eff_c_l, style=f_st(s_l), width=w_l)
    swp.hi_lbl   := label.new(bar_index, ib_h, biasHi ? "82% prob." : "",  xloc=xloc.bar_index, style=label.style_label_left, color=noColor, textcolor=eff_c_h, size=f_sz(lblSize), text_font_family=font.family_monospace)
    swp.lo_lbl   := label.new(bar_index, ib_l, biasHi ? "" : "76% prob.",  xloc=xloc.bar_index, style=label.style_label_left, color=noColor, textcolor=eff_c_l, size=f_sz(lblSize), text_font_family=font.family_monospace)

swp_target_hi  = false
swp_target_lo  = false
swp_invalid_hi = false
swp_invalid_lo = false

if not inSess and not sessClose and not na(ib.swp.hi)
    swp = ib.swp
    if not swp.hi_hit and not swp.lo_hit
        swp.hi.set_x2(bar_index)
        swp.lo.set_x2(bar_index)
        label.set_x(swp.hi_lbl, bar_index)
        label.set_x(swp.lo_lbl, bar_index)

        hiHit = high >= swp.hi_price
        loHit = low  <= swp.lo_price

        if hiHit or loHit
            targetLbl  = swp.bias_hi ? swp.hi_lbl : swp.lo_lbl
            prob       = swp.bias_hi ? "82%" : "76%"
            isSuccess  = (hiHit and swp.bias_hi) or (loHit and not swp.bias_hi)

            if hiHit
                swp.hi_hit := true
                swp.hi.set_color(swp.bias_hi ? C_EXPECTED : C_INVALID)
                swp_target_hi  := isSuccess
                swp_invalid_hi := not isSuccess
            else
                swp.lo_hit := true
                swp.lo.set_color(swp.bias_hi ? C_INVALID : C_EXPECTED)
                swp_target_lo  := isSuccess
                swp_invalid_lo := not isSuccess

            label.set_text(targetLbl,      prob + " prob. [" + (isSuccess ? "Success]" : "Failed]"))
            label.set_textcolor(targetLbl, isSuccess ? C_EXPECTED : C_INVALID)
//#endregion


//#region [SWEEP MARK]
plotshape(swp_target_hi,  title="Target Hit High",       style=shape.circle, location=location.abovebar, color=C_EXPECTED, size=size.tiny)
plotshape(swp_target_lo,  title="Target Hit Low",        style=shape.circle, location=location.belowbar, color=C_EXPECTED, size=size.tiny)
plotshape(swp_invalid_hi, title="Invalidation Hit High", style=shape.xcross, location=location.abovebar, color=C_INVALID,  size=size.tiny)
plotshape(swp_invalid_lo, title="Invalidation Hit Low",  style=shape.xcross, location=location.belowbar, color=C_INVALID,  size=size.tiny)
//#endregion
````
