# Session Strata Mapper [JOAT]

- url: https://www.tradingview.com/script/BMKydzAM-Session-Strata-Mapper-JOAT/
- type: indicator
- pine_id: PUB;c18432ef485945dc9d169c9ef4c55d49
- version: 1.0

## Description

[b]Session Strata Mapper [JOAT][/b]

[b]Introduction[/b]

Session Strata Mapper is an overlay indicator that tracks three critical intraday price levels in real time: the Premarket session range (04:00-09:30 ET), the Initial Balance range (09:30-10:30 ET), and the Previous Day's high, low, and midpoint. These levels are rendered as dynamic zones that expand as each session progresses and extend as horizontal reference lines throughout the trading day. Extension projections above and below the Initial Balance provide potential target levels based on the established morning range.

Session-based levels represent areas where institutional participation was concentrated during distinct time periods. The premarket range reflects the overnight positioning of market participants before retail hours begin. The Initial Balance captures the price range set by the first hour of regular trading, a period often dominated by institutional order flow. Violations of these levels, especially when accompanied by volume, frequently signal meaningful directional commitment from large participants.

[image]https://www.tradingview.com/x/kaaU90tl/[/image]

[b]Core Concepts[/b]

[b]1. Session Detection and Range Building[/b]

Sessions are detected using TradingView's time() function with a configurable timezone (default: America/New_York). The premarket range builds bar by bar during the 04:00-09:30 window, tracking the running high and low. The Initial Balance does the same during 09:30-10:30. All objects (boxes, lines, labels) update in real time as each session progresses.

[b]2. Initial Balance Extensions[/b]

The IB range can optionally project extension levels above and below at 0.5x IB multiples. Extensions are labeled IB +1x, IB +2x, etc. These project the IB range beyond the session boundaries and serve as potential continuation targets when price breaks from the IB.

[b]3. Previous Day Levels[/b]

The previous trading day's high, low, and midpoint are tracked by detecting session-start bars and storing the completed day's range. These levels extend throughout the current session as dashed reference lines and are updated at the start of each new day.

[b]4. Zone Boxes and Line Rendering[/b]

Each session's range is rendered as a filled zone box that expands during the session and then remains fixed after the session ends. Horizontal lines extend from the session boundaries into the future trading period, providing ongoing reference as price interacts with those levels throughout the day.

[b]Features[/b]

[list]
[*][b]Premarket Range Zone:[/b] Live-building box with high, low, and optional midpoint lines
[*][b]Initial Balance Zone:[/b] Live-building box with high, low, midpoint, and extension projections
[*][b]Previous Day Levels:[/b] Prior session high, low, and midpoint as dashed reference lines
[*][b]Extension Lines:[/b] Up to 4 levels of IB extension projections with optional labels
[*][b]Dashboard:[/b] Real-time level values and whether price is currently above or below each key level
[*][b]Configurable Timezone:[/b] Works for multiple market sessions globally
[*][b]Label Size and Line Width Controls[/b]
[/list]

[b]Input Parameters[/b]

[list]
[*]Timezone: Market-specific timezone for session detection
[*]Show Premarket, IB, Previous Day: Individual toggles
[*]IB Extension Levels: Number of extension multiples to show (0-4)
[*]Color inputs for each session type
[*]Label size and line width settings
[/list]

[b]How to Use This Indicator[/b]

[b]Premarket Range as Reference[/b]
Price trading above the premarket high at the regular session open is constructive. A break below the premarket low often draws bearish attention. The premarket midpoint frequently acts as intraday support or resistance.

[b]Initial Balance Breakouts[/b]
When price breaks above the IB high with momentum, the extension levels provide natural targets. An IB high breakout that reaches IB +1x suggests continuation may carry to IB +2x. Reversals from IB extension levels are also common.

[b]Previous Day Level Confluences[/b]
When the premarket or IB range aligns closely with the previous day's high or low, that confluence represents an area where two independent session-based reference points agree — a stronger potential reaction zone.

[b]Limitations[/b]

[list]
[*]Session detection requires intraday data. The indicator is not meaningful on daily or higher timeframes
[*]Some brokers and data providers do not include premarket data. On charts without premarket bars, the premarket range will be empty
[*]Extension levels are mechanical projections of the IB range. They are reference points, not guaranteed targets
[*]The Previous Day tracking resets on each new session. On instruments that trade continuously (such as some crypto markets), the day boundary is user-defined by the timezone setting
[/list]

[b]Originality Statement[/b]

The integration of three distinct session types (premarket, initial balance, and previous day) within a single dynamically updating visualization system provides a consolidated view that would otherwise require multiple separate tools. The live-expanding zone boxes with simultaneous line extension represent a unified approach to session level tracking. The IB extension projection system is built around the specific multiples used by institutional traders who apply IB methodology.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Session levels are historical reference points and do not predict future price reactions. Price can and regularly does pass through any level without reaction. Use in conjunction with other analysis and always apply proper risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Session Strata Mapper [JOAT]", shorttitle="SSM [JOAT]", overlay=true,
         max_lines_count=500, max_boxes_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_cfg  = "Configuration"
i_mode   = input.string("Today", "Display Mode",
           options=["Hidden","Today","Two Days","Week","All"], group=grp_cfg)
i_tz     = input.string("America/New_York", "Timezone", group=grp_cfg,
           options=["America/New_York","America/Chicago","Europe/London","Asia/Tokyo",
                    "Asia/Hong_Kong","Australia/Sydney","UTC"])

grp_pm   = "Premarket Session"
i_pm_on  = input.bool(true, "Show Premarket", group=grp_pm)
i_pm_col = input.color(#7c4dff, "Premarket Color", group=grp_pm)
i_pm_mid = input.bool(true, "Show Midpoint", group=grp_pm)
i_pm_q   = input.bool(false, "Show Quartiles (75/25)", group=grp_pm)
i_pm_op  = input.int(75, "Shade Opacity", minval=40, maxval=95, group=grp_pm)

grp_ib   = "Initial Balance (9:30-10:30)"
i_ib_on  = input.bool(true, "Show Initial Balance", group=grp_ib)
i_ib_col = input.color(#1976d2, "IB Color", group=grp_ib)
i_ib_ext = input.int(2, "Extension Levels", minval=0, maxval=4, group=grp_ib)

grp_pd   = "Previous Day"
i_pd_on  = input.bool(true, "Show Previous Day Levels", group=grp_pd)
i_pd_col = input.color(#ff7043, "Prev Day Color", group=grp_pd)

grp_lbl  = "Labels"
i_lbl    = input.bool(true,   "Show Labels", group=grp_lbl)
i_fs     = input.string("Small", "Label Size", options=["Tiny","Small","Medium"], group=grp_lbl)
i_lw     = input.int(1, "Line Width", minval=1, maxval=3, group=grp_lbl)

// ─────────────────────────────────────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────────────────────────────────────
fs = i_fs == "Tiny" ? size.tiny : i_fs == "Medium" ? size.normal : size.small

// Premarket: 04:00–09:30
pm_sess    = time(timeframe.period, "0400-0930", i_tz)
pm_start() => not na(pm_sess) and na(pm_sess[1])
pm_end()   => na(pm_sess)     and not na(pm_sess[1])
pm_active  = not na(pm_sess)

// Initial Balance: 09:30–10:30
ib_sess    = time(timeframe.period, "0930-1030", i_tz)
ib_start() => not na(ib_sess) and na(ib_sess[1])
ib_active  = not na(ib_sess)

// Extended post-IB session: 10:30–16:00
ex_sess    = time(timeframe.period, "1030-1600", i_tz)
ex_active  = not na(ex_sess)

// Daily session (for previous day)
day_sess   = time(timeframe.period, "0000-2359", i_tz)
day_start() => not na(day_sess) and na(day_sess[1])

// ─────────────────────────────────────────────────────────────────────────────
// PREMARKET STATE
// ─────────────────────────────────────────────────────────────────────────────
var float pm_h = na
var float pm_l = na
var int   pm_bar_start = na
var box   pm_box  = na
var line  pm_hl   = na
var line  pm_ll   = na
var line  pm_mid_l = na
var line  pm_q75_l = na
var line  pm_q25_l = na
var box   pm_hl_lbl = na
var box   pm_ll_lbl = na
var box   pm_mid_lbl = na
var array<box> pm_boxes_hist = array.new<box>()

if i_pm_on and pm_start()
    pm_h          := high
    pm_l          := low
    pm_bar_start  := bar_index
    pm_box        := box.new(bar_index, high, bar_index, low,
                             bgcolor=color.new(i_pm_col, i_pm_op), border_color=na)
    pm_hl         := line.new(bar_index, high, bar_index, high,
                              color=i_pm_col, width=i_lw, style=line.style_dashed)
    pm_ll         := line.new(bar_index, low,  bar_index, low,
                              color=i_pm_col, width=i_lw, style=line.style_dashed)
    if i_pm_mid
        pm_mid_l  := line.new(bar_index, (high+low)/2, bar_index, (high+low)/2,
                              color=color.new(i_pm_col, 40), width=1, style=line.style_dotted)
    if i_lbl
        pm_hl_lbl := box.new(bar_index, high, bar_index, high, text="PM High",
                             text_size=fs, text_color=i_pm_col, text_halign=text.align_right,
                             text_valign=text.align_bottom, bgcolor=color.new(color.black,100),
                             border_color=color.new(color.black,100))
        pm_ll_lbl := box.new(bar_index, low, bar_index, low, text="PM Low",
                             text_size=fs, text_color=i_pm_col, text_halign=text.align_right,
                             text_valign=text.align_top, bgcolor=color.new(color.black,100),
                             border_color=color.new(color.black,100))

if i_pm_on and pm_active
    if high > pm_h
        pm_h := high
    if low  < pm_l
        pm_l := low
    pm_box.set_top(pm_h)
    pm_box.set_right(bar_index)
    pm_box.set_bottom(pm_l)
    pm_hl.set_x2(bar_index)
    pm_hl.set_y1(pm_h)
    pm_hl.set_y2(pm_h)
    pm_ll.set_x2(bar_index)
    pm_ll.set_y1(pm_l)
    pm_ll.set_y2(pm_l)
    if i_pm_mid and not na(pm_mid_l)
        mid_val = (pm_h + pm_l) / 2
        pm_mid_l.set_x2(bar_index)
        pm_mid_l.set_y1(mid_val)
        pm_mid_l.set_y2(mid_val)
    if i_lbl
        if not na(pm_hl_lbl)
            pm_hl_lbl.set_right(bar_index)
            pm_hl_lbl.set_top(pm_h)
            pm_hl_lbl.set_bottom(pm_h)
        if not na(pm_ll_lbl)
            pm_ll_lbl.set_right(bar_index)
            pm_ll_lbl.set_top(pm_l)
            pm_ll_lbl.set_bottom(pm_l)

if i_pm_on and not pm_active
    if not na(pm_hl)
        pm_hl.set_x2(bar_index)
    if not na(pm_ll)
        pm_ll.set_x2(bar_index)
    if not na(pm_mid_l)
        pm_mid_l.set_x2(bar_index)
    if i_lbl
        if not na(pm_hl_lbl)
            pm_hl_lbl.set_right(bar_index)
        if not na(pm_ll_lbl)
            pm_ll_lbl.set_right(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// INITIAL BALANCE STATE
// ─────────────────────────────────────────────────────────────────────────────
var float ib_h = na
var float ib_l = na
var int   ib_bar_start = na
var box   ib_box = na
var line  ib_hl  = na
var line  ib_ll  = na
var line  ib_mid = na
var box   ib_hl_lbl = na
var box   ib_ll_lbl = na
var box   ib_mid_lbl = na
var array<line> ib_ext_lines = array.new<line>()
var array<box>  ib_ext_lbls  = array.new<box>()

if i_ib_on and ib_start()
    // Clear previous extensions
    for l in ib_ext_lines
        l.delete()
    for b in ib_ext_lbls
        b.delete()
    ib_ext_lines.clear()
    ib_ext_lbls.clear()

    ib_h          := high
    ib_l          := low
    ib_bar_start  := bar_index
    ib_box        := box.new(bar_index, high, bar_index, low,
                             bgcolor=color.new(i_ib_col, 78), border_color=na)
    ib_hl         := line.new(bar_index, high, bar_index, high,
                              color=i_ib_col, width=i_lw, style=line.style_solid)
    ib_ll         := line.new(bar_index, low,  bar_index, low,
                              color=i_ib_col, width=i_lw, style=line.style_solid)
    ib_mid        := line.new(bar_index, (high+low)/2, bar_index, (high+low)/2,
                              color=color.new(i_ib_col, 40), width=1, style=line.style_dashed)
    if i_lbl
        ib_hl_lbl  := box.new(bar_index, high, bar_index, high, text="IB High",
                              text_size=fs, text_color=i_ib_col, text_halign=text.align_right,
                              text_valign=text.align_bottom, bgcolor=color.new(color.black,100),
                              border_color=color.new(color.black,100))
        ib_ll_lbl  := box.new(bar_index, low, bar_index, low, text="IB Low",
                              text_size=fs, text_color=i_ib_col, text_halign=text.align_right,
                              text_valign=text.align_top, bgcolor=color.new(color.black,100),
                              border_color=color.new(color.black,100))
        ib_mid_lbl := box.new(bar_index, (high+low)/2, bar_index, (high+low)/2, text="IB 50%",
                              text_size=fs, text_color=color.new(i_ib_col,40),
                              text_halign=text.align_right, text_valign=text.align_bottom,
                              bgcolor=color.new(color.black,100), border_color=color.new(color.black,100))

if i_ib_on and ib_active
    if high > ib_h
        ib_h := high
    if low < ib_l
        ib_l := low
    ib_range = ib_h - ib_l
    ib_box.set_top(ib_h)
    ib_box.set_right(bar_index)
    ib_box.set_bottom(ib_l)
    ib_hl.set_x2(bar_index)
    ib_hl.set_y1(ib_h)
    ib_hl.set_y2(ib_h)
    ib_ll.set_x2(bar_index)
    ib_ll.set_y1(ib_l)
    ib_ll.set_y2(ib_l)
    ib_mid.set_x2(bar_index)
    ib_mid.set_y1((ib_h + ib_l) / 2)
    ib_mid.set_y2((ib_h + ib_l) / 2)
    // Rebuild extensions when range changes
    if i_ib_ext > 0
        for l in ib_ext_lines
            l.delete()
        for b in ib_ext_lbls
            b.delete()
        ib_ext_lines.clear()
        ib_ext_lbls.clear()
        for i = 1 to i_ib_ext
            ext_price_up = ib_h + ib_range * 0.5 * i
            ext_price_dn = ib_l - ib_range * 0.5 * i
            lu = line.new(ib_bar_start, ext_price_up, bar_index, ext_price_up,
                         color=color.new(i_ib_col, 55), width=1, style=line.style_dotted)
            ld = line.new(ib_bar_start, ext_price_dn, bar_index, ext_price_dn,
                         color=color.new(i_ib_col, 55), width=1, style=line.style_dotted)
            ib_ext_lines.push(lu)
            ib_ext_lines.push(ld)
            if i_lbl
                bu = box.new(ib_bar_start, ext_price_up, bar_index, ext_price_up,
                             text="IB +" + str.tostring(i) + "x",
                             text_size=fs, text_color=color.new(i_ib_col,55),
                             text_halign=text.align_right, text_valign=text.align_bottom,
                             bgcolor=color.new(color.black,100), border_color=color.new(color.black,100))
                bd = box.new(ib_bar_start, ext_price_dn, bar_index, ext_price_dn,
                             text="IB -" + str.tostring(i) + "x",
                             text_size=fs, text_color=color.new(i_ib_col,55),
                             text_halign=text.align_right, text_valign=text.align_top,
                             bgcolor=color.new(color.black,100), border_color=color.new(color.black,100))
                ib_ext_lbls.push(bu)
                ib_ext_lbls.push(bd)
    if i_lbl
        if not na(ib_hl_lbl)
            ib_hl_lbl.set_right(bar_index)
            ib_hl_lbl.set_top(ib_h)
            ib_hl_lbl.set_bottom(ib_h)
        if not na(ib_ll_lbl)
            ib_ll_lbl.set_right(bar_index)
            ib_ll_lbl.set_top(ib_l)
            ib_ll_lbl.set_bottom(ib_l)
        if not na(ib_mid_lbl)
            ib_mid_lbl.set_right(bar_index)
            ib_mid_lbl.set_top((ib_h+ib_l)/2)
            ib_mid_lbl.set_bottom((ib_h+ib_l)/2)

if i_ib_on and ex_active and not ib_active
    if not na(ib_hl)
        ib_hl.set_x2(bar_index)
    if not na(ib_ll)
        ib_ll.set_x2(bar_index)
    if not na(ib_mid)
        ib_mid.set_x2(bar_index)
    for l in ib_ext_lines
        l.set_x2(bar_index)
    if i_lbl
        if not na(ib_hl_lbl)
            ib_hl_lbl.set_right(bar_index)
        if not na(ib_ll_lbl)
            ib_ll_lbl.set_right(bar_index)
        if not na(ib_mid_lbl)
            ib_mid_lbl.set_right(bar_index)
        for b in ib_ext_lbls
            b.set_right(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS DAY LEVELS
// ─────────────────────────────────────────────────────────────────────────────
var float pd_h    = na
var float pd_l    = na
var float pd_close= na
var float pd_mid  = na
var float session_h = na
var float session_l = na
var line  pd_hl   = na
var line  pd_ll   = na
var line  pd_ml   = na
var box   pd_hl_lbl = na
var box   pd_ll_lbl = na

if day_start()
    if not na(session_h) and not na(session_l)
        pd_h     := session_h
        pd_l     := session_l
        pd_mid   := (session_h + session_l) / 2
        pd_close := close[1]

        if i_pd_on
            line.delete(pd_hl)
            line.delete(pd_ll)
            line.delete(pd_ml)
            box.delete(pd_hl_lbl)
            box.delete(pd_ll_lbl)
            pd_hl := line.new(bar_index, pd_h, bar_index, pd_h,
                              color=i_pd_col, width=i_lw, style=line.style_dashed)
            pd_ll := line.new(bar_index, pd_l, bar_index, pd_l,
                              color=i_pd_col, width=i_lw, style=line.style_dashed)
            pd_ml := line.new(bar_index, pd_mid, bar_index, pd_mid,
                              color=color.new(i_pd_col, 50), width=1, style=line.style_dotted)
            if i_lbl
                pd_hl_lbl := box.new(bar_index, pd_h, bar_index, pd_h,
                                     text="Prev High", text_size=fs, text_color=i_pd_col,
                                     text_halign=text.align_right, text_valign=text.align_bottom,
                                     bgcolor=color.new(color.black,100), border_color=color.new(color.black,100))
                pd_ll_lbl := box.new(bar_index, pd_l, bar_index, pd_l,
                                     text="Prev Low", text_size=fs, text_color=i_pd_col,
                                     text_halign=text.align_right, text_valign=text.align_top,
                                     bgcolor=color.new(color.black,100), border_color=color.new(color.black,100))
    session_h := high
    session_l := low
else
    if not na(session_h)
        session_h := math.max(session_h, high)
    if not na(session_l)
        session_l := math.min(session_l, low)

if i_pd_on and not na(pd_hl)
    pd_hl.set_x2(bar_index)
    pd_ll.set_x2(bar_index)
    pd_ml.set_x2(bar_index)
    if i_lbl
        if not na(pd_hl_lbl)
            pd_hl_lbl.set_right(bar_index)
        if not na(pd_ll_lbl)
            pd_ll_lbl.set_right(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table _t = na
if barstate.islast
    if na(_t)
        _t := table.new(position.bottom_right, 3, 8,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0 = color.new(#0a1628, 0)
    C1 = color.new(#0f2341, 0)
    C2 = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "SESSION STRATA MAPPER", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    table.cell(_t, 0, 1, "PM High", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 1, not na(pm_h) ? str.tostring(pm_h, format.mintick) : "—",
               bgcolor=C1, text_color=i_pm_col, text_size=size.small)
    table.cell(_t, 2, 1, not na(pm_h) ? (close > pm_h ? "Above" : "Below") : "—",
               bgcolor=C1, text_color=not na(pm_h) and close > pm_h ? #00bfa5 : #ef5350,
               text_size=size.small)

    table.cell(_t, 0, 2, "PM Low", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, not na(pm_l) ? str.tostring(pm_l, format.mintick) : "—",
               bgcolor=C2, text_color=i_pm_col, text_size=size.small)
    table.merge_cells(_t, 1, 2, 2, 2)

    table.cell(_t, 0, 3, "IB High", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, not na(ib_h) ? str.tostring(ib_h, format.mintick) : "—",
               bgcolor=C1, text_color=i_ib_col, text_size=size.small)
    table.cell(_t, 2, 3, not na(ib_h) ? (close > ib_h ? "Above" : "Below") : "—",
               bgcolor=C1, text_color=not na(ib_h) and close > ib_h ? #00bfa5 : #ef5350,
               text_size=size.small)

    table.cell(_t, 0, 4, "IB Low", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 4, not na(ib_l) ? str.tostring(ib_l, format.mintick) : "—",
               bgcolor=C2, text_color=i_ib_col, text_size=size.small)
    table.merge_cells(_t, 1, 4, 2, 4)

    table.cell(_t, 0, 5, "Prev High", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 5, not na(pd_h) ? str.tostring(pd_h, format.mintick) : "—",
               bgcolor=C1, text_color=i_pd_col, text_size=size.small)
    table.cell(_t, 2, 5, not na(pd_h) ? (close > pd_h ? "Above" : "Below") : "—",
               bgcolor=C1, text_color=not na(pd_h) and close > pd_h ? #00bfa5 : #ef5350,
               text_size=size.small)

    table.cell(_t, 0, 6, "Prev Low", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 6, not na(pd_l) ? str.tostring(pd_l, format.mintick) : "—",
               bgcolor=C2, text_color=i_pd_col, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    table.cell(_t, 0, 7, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 7, 2, 7)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(not na(pm_h) and close > pm_h and close[1] <= pm_h,
               "SSM — Price Above PM High", "Price broke above Premarket High — {{ticker}}")
alertcondition(not na(pm_l) and close < pm_l and close[1] >= pm_l,
               "SSM — Price Below PM Low",  "Price broke below Premarket Low — {{ticker}}")
alertcondition(not na(ib_h) and close > ib_h and close[1] <= ib_h,
               "SSM — IB Breakout Up",   "Price broke above Initial Balance High — {{ticker}}")
alertcondition(not na(ib_l) and close < ib_l and close[1] >= ib_l,
               "SSM — IB Breakout Down", "Price broke below Initial Balance Low — {{ticker}}")
alertcondition(not na(pd_h) and close > pd_h and close[1] <= pd_h,
               "SSM — Above Prev Day High", "Price broke above Previous Day High — {{ticker}}")
alertcondition(not na(pd_l) and close < pd_l and close[1] >= pd_l,
               "SSM — Below Prev Day Low",  "Price broke below Previous Day Low — {{ticker}}")
````
