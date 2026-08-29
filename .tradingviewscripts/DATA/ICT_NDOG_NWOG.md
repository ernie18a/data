<!-- tradingview-pine-id: PUB;97e1ed6ea8944ad6b2e4c52978a12bf5 -->
<!-- tradingviewscripts-format: 1 -->
# ICT NDOG & NWOG

Source: https://www.tradingview.com/script/g2cQgffq-ICT-NDOG-NWOG-D4A/

## Description

NDWOG - New Day / Week Opening Gap

This script is based on popular open source script made by [fadi](https://www.tradingview.com/script/XY0niHGg-ICT-NWOG-NDOG-Source-Code-fadi/).

How is this script different from the original:
- has additional option (set as default) to add one day to NDOG and NWOG, so the displayed gap date reflects the day when the gap is first utilized during London and NY sessions, as recommended numerous times by ICT himself (main reason for this fork)
- gap quadrants can be drawn if enabled and ATR based gap size is large enough (user customizable)
- more gap customization options have been added to help distinguish between the current and previous (historical) gaps
- gap date label format can be set according to your preference
- default settings are based on dark Trading View theme
- a few small bugs have been fixed

Overview

The script is designed for ICT traders operating mostly in the CME futures markets (NQ, MNQ, ES, and MES), but NWOG discovery works also in forex markets. The script automatically plots the opening gaps that serve as primary daily and weekly draw-on-liquidity levels.

- NDOG (New Day Opening Gap): Formed daily during the CME's 1-hour session break (5:00 PM to 6:00 PM ET), the NDOG captures the price difference between the 5:00 PM ET closing candle and the 6:00 PM ET opening candle. A new gap is created every weekday evening at 6:00 PM ET.

- NWOG (New Week Opening Gap): Created over the weekend between Friday’s 5:00 PM ET close and Sunday’s 6:00 PM ET market re-open. NWOGs are typically much wider than daily gaps, serving as macro liquidity targets for the entire trading week.

Every identified gap is displayed as a shaded range spanning its high and low extremes, bounded by horizontal levels at the top and bottom. It features middle line, known as C.E. (Consequent Encroachment) marking the 50% midpoint, optional quadrants and gap date label.

Within ICT methodology, opening gaps act as footprint markers for institutional orders. "Smart money" routinely targets these price imbalances; analyzing how price reacts—whether it bounces off the boundary, respects the midpoint, or closes the gap entirely helps traders gauge institutional sentiment.

Weekly & Daily Directional Bias

NWOG (Weekly Framework): Dictates the macro bias. Trading above the NWOG signals a bullish tone, whereas trading below implies a bearish outlook. The C.E. of the NWOG is a critical line as its clean rejection indicates trend continuation, while a strong break through the CE points to a full gap fill and signals potential trend reversal.

NDOG (Intraday Framework): Functions as the daily counterpart. Yesterday's NDOG highlights overnight institutional order flow shifts. Furthermore, multiple unfilled NDOGs from prior sessions act as magnetic liquidity pools during the London and NY Kill Zones.

SETTINGS

- NWOG - New Week Opening Gap - enable the display of NWOGs
- Current NWOG Fill/Border/C.E.  - customize the current (the newest) weekly gap
- Previous NWOG Fill/Border/C.E. - customize all the previous weekly gaps (historical)
- Max NWOGs - select how many previous weekly gaps should be displayed on the chart
- Label - enable and customize gap date label

- NDOG - New Day Opening Gap - enable the display of NDOGs
- Hide Above - hide the daily gaps above specific timeframe
- Current NDOG Fill/Border/C.E.  - customize the current (the newest) daily gap
- Previous NDOG Fill/Border/C.E. - customize all the previous daily gaps (historical)
- Max NDOGs - select how many previous daily gaps should be displayed on the chart
- Label - enable and customize gap date label

- Draw Quadrants (NDOG & NWOG) - draw quadrants in both daily and weekly gaps
- Threshold - the quadrants are drawn if they are bigger than this ATR threshold
- Only if Price Within the Gap - draw quadrants only if the price is currently inside of the gap. This option serves the purpose of minimizing chart clutter
- Add 1 day offset to date label - most similar scripts use by default the date of gap creation, however this script allows to increase the date by 1 day, thus adhering to ICT recommendations, so the displayed gap date is reflecting the first London and NY sessions after the gap has been created
- Date Format - customize the display of date
- Add left padding - it adds padding to the label, moving it more to the right
- Box Right 'Time Extension' - how far right should the NDOG/NWOG box be extended (time-based)
	
Note: 
NDOG and NWOG created on the same weekend will overlap thus creating one box on the chart. You can still spot them by looking at their date labels: weekly gap labels are bigger and daily labels are smaller (based on script default settings).

The script should work on all timeframes, up to 1D.

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('ICT NDOG & NWOG','NDWOGT', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500)

type Helper
	string name

type Settings
	bool show
	color bg_color_new
    color bg_color_prev
    color border_color_new
    color border_color_prev
	color ce_color_new
    color ce_color_prev
    string style_new
    string style_prev
    string ce_style_new
    string ce_style_prev
    int line_width_new
    int line_width_prev
    int ce_line_width_new
    int ce_line_width_prev
	string extend
	int max_count
	bool label_show
    bool day_ext
	string label_size
	color label_color
	color label_bgcolor

type Gap
	string name
    string  date_name
	float open
	float middle
    float q1
    float q2
	float close
	int open_time
	int close_time
	box box
	line CE
    line quadrant1
    line quadrant2
	label lbl_date
	bool is_current = false
    bool is_priceIN = false

type OpenGap
	array<Gap> gaps
	Settings settings

var nwog_gaps = array.new<Gap>()
var OpenGap NWOG = OpenGap.new()
NWOG.gaps := nwog_gaps
NWOG.settings := Settings.new()

var ndog_gaps = array.new<Gap>()
var OpenGap NDOG = OpenGap.new()
NDOG.gaps := ndog_gaps
NDOG.settings := Settings.new()

var Helper helper = Helper.new()

NDWOG_Group = 'New Day/Week Opening Gap (NDWOG)'

NWOG.settings.show := input.bool(true, 'NWOG - New Week Opening Gap ---------------------', group = NDWOG_Group, tooltip = "NWOG - does not work on crypto")
NWOG.settings.bg_color_new := input.color(color.new(#673CB5, 88), 'Current NWOG:  Fill', group = NDWOG_Group, inline = 'nw1')
NWOG.settings.border_color_new := input.color(color.new(#673CB5, 0), 'Border', group = NDWOG_Group, inline = 'nw1')
NWOG.settings.style_new := input.string(defval = line.style_solid, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nw1', group = NDWOG_Group)
NWOG.settings.line_width_new := input.int(2, title = '', inline = 'nw1', group = NDWOG_Group)
NWOG.settings.ce_color_new := input.color(color.new(#673CB5, 0), '   Current C.E.', group = NDWOG_Group, inline = 'nw2')
NWOG.settings.ce_style_new := input.string(defval = line.style_dotted, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nw2', group = NDWOG_Group)
NWOG.settings.ce_line_width_new := input.int(2, title = '', inline = 'nw2', group = NDWOG_Group)

NWOG.settings.bg_color_prev := input.color(color.new(#673CB5, 88), 'Previous NWOG:  Fill', group = NDWOG_Group, inline = 'nw3')
NWOG.settings.border_color_prev := input.color(color.new(#673CB5, 70), 'Border', group = NDWOG_Group, inline = 'nw3')
NWOG.settings.style_prev := input.string(defval = line.style_solid, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nw3', group = NDWOG_Group)
NWOG.settings.line_width_prev := input.int(1, title = '', inline = 'nw3', group = NDWOG_Group)
NWOG.settings.ce_color_prev := input.color(color.new(#673CB5, 10), '   Previous C.E.', group = NDWOG_Group, inline = 'nw4')
NWOG.settings.ce_style_prev := input.string(defval = line.style_dotted, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nw4', group = NDWOG_Group)
NWOG.settings.ce_line_width_prev := input.int(1, title = '', inline = 'nw4', group = NDWOG_Group)

NWOG.settings.max_count := input.int(6, 'Max NWOGs', 3, 20, group = NDWOG_Group, inline = 'nw5')
NWOG.settings.label_show := input.bool(true, 'Label', group = NDWOG_Group, inline = 'nw5')
NWOG.settings.label_color := input.color(color.new(color.silver, 0), '', group = NDWOG_Group, inline = 'nw5')
NWOG.settings.label_bgcolor := input.color(color.new(#673CB5, 75), '', group = NDWOG_Group, inline = 'nw5')
NWOG.settings.label_size := input.string(size.normal, '', [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group = NDWOG_Group, inline = 'nw5')

NDOG.settings.show := input.bool(true, 'NDOG - New Day Opening Gap (Indices)', inline= 'nd0', group = NDWOG_Group, tooltip = "NDOG - does not work on crypto or forex")
hide_above  = input.timeframe("60", "    Hide Above", inline= 'nd0', group = NDWOG_Group)
NDOG.settings.bg_color_new:= input.color(color.new(color.fuchsia, 92), 'Current NDOG:   Fill', group = NDWOG_Group, inline = 'nd1')
NDOG.settings.border_color_new:= input.color(color.new(color.fuchsia, 0), 'Border', group = NDWOG_Group, inline = 'nd1')
NDOG.settings.style_new := input.string(defval = line.style_solid, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nd1', group = NDWOG_Group)
NDOG.settings.line_width_new := input.int(1, title = '', inline = 'nd1', group = NDWOG_Group)
NDOG.settings.ce_color_new := input.color(color.new(color.fuchsia, 20), '   Current C.E.', group = NDWOG_Group, inline = 'nd2')
NDOG.settings.ce_style_new := input.string(defval = line.style_dotted, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nd2', group = NDWOG_Group)
NDOG.settings.ce_line_width_new := input.int(1, title = '', inline = 'nd2', group = NDWOG_Group)

NDOG.settings.bg_color_prev := input.color(color.new(color.fuchsia, 92), 'Previous NDOG:   Fill', group = NDWOG_Group, inline = 'nd3')
NDOG.settings.border_color_prev := input.color(color.new(color.fuchsia, 85), 'Border', group = NDWOG_Group, inline = 'nd3')
NDOG.settings.style_prev := input.string(defval = line.style_solid, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nd3', group = NDWOG_Group)
NDOG.settings.line_width_prev := input.int(1, title = '', inline = 'nd3', group = NDWOG_Group)
NDOG.settings.ce_color_prev := input.color(color.new(color.fuchsia, 40), '   Previous C.E.', group = NDWOG_Group, inline = 'nd4')
NDOG.settings.ce_style_prev := input.string(defval = line.style_dotted, title = '', options = [line.style_dashed, line.style_dotted, line.style_solid], inline = 'nd4', group = NDWOG_Group)
NDOG.settings.ce_line_width_prev := input.int(1, title = '', inline = 'nd4', group = NDWOG_Group)

NDOG.settings.max_count := input.int(7, 'Max NDOGs', 1, 20, group = NDWOG_Group, inline = 'nd5')
NDOG.settings.label_show := input.bool(true, 'Label', group = NDWOG_Group, inline = 'nd5')
NDOG.settings.label_color := input.color(color.new(color.silver, 0), '', group = NDWOG_Group, inline = 'nd5')
NDOG.settings.label_bgcolor := input.color(color.new(color.fuchsia, 85), '', group = NDWOG_Group, inline = 'nd5')
NDOG.settings.label_size := input.string(size.small, '', [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group = NDWOG_Group, inline = 'nd5')

textPrefix = '                          '
draw_quadrants = input.bool(true, 'Draw Quadrants (NDOG & NWOG)', group = NDWOG_Group, tooltip = "Quadrants are drawn if the Gap is larger than ATR Threshold. Decoration settings are the same as those pertaining C.E.")
filterQ_gap = input.float(1.5, '    Threshold', minval = 0, step = .5, inline='quadrants', group = NDWOG_Group)
draw_ifPriceIn = input.bool(true,"Only if Price Within the Gap", inline='quadrants', group = NDWOG_Group, tooltip = "If price is outside of the Gap, the quadrants are hidden when this option is Enabled")
NDOG.settings.day_ext := input.bool(true, 'Add 1 day offset to date label', group = NDWOG_Group)
dateFormat = input.string('d.M', 'Date Format', options = ['M.d', 'd.M', 'MMM d', 'd MMM'], inline = 'nd6', group = NDWOG_Group)
textPadding = input.bool(true, 'Add Left Padding', group = NDWOG_Group, inline = 'nd6')
extn = input.int(4, title = "Box Right 'Time Extension'", minval = 0, group = NDWOG_Group)

tf_msec = timeframe.in_seconds(timeframe.period) * 500
is_sunday = dayofweek == dayofweek.sunday
dailyBarTime = time('1D')
isNewDay = ta.change(dailyBarTime)
oneDay = 86400000 // 1000 * 60 * 60 * 24 -> 1 full day (24h)

atr_gap = nz(ta.atr(200))
filterQ1Q2(a, b) =>
    math.abs(a - b) > atr_gap * filterQ_gap

method RenderBox(Helper helper, box box, line line, line lineQ1, line lineQ2, label lbl, float top, float bottom, int left, int right, Settings settings, bool is_current, bool is_priceIN) =>
    helper.name := 'RenderBox' //Dummy setting
    if not na(box)
        box.set_lefttop(box, left, top)
        box.set_rightbottom(box, right, bottom)
        box.set_bgcolor(box, is_current ? settings.bg_color_new : settings.bg_color_prev)
        box.set_border_color(box, is_current ? settings.border_color_new : settings.border_color_prev)
        box.set_border_style(box,is_current ? settings.style_new : settings.style_prev)
        box.set_border_width(box, is_current ? settings.line_width_new : settings.line_width_prev)

    if not na(line)
        line.set_x2(line, right)
        line.set_color(line, is_current ? settings.ce_color_new : settings.ce_color_prev)
        line.set_style(line, is_current ? settings.ce_style_new : settings.ce_style_prev)
        line.set_width(line, is_current ? settings.ce_line_width_new : settings.ce_line_width_prev)

    show_quadrants = draw_quadrants and (not draw_ifPriceIn or is_priceIN)

    if not na(lineQ1)
        line.set_x2(lineQ1, right)
        line.set_color(lineQ1, show_quadrants ? (is_current ? color.new(settings.ce_color_new,30) : color.new(settings.ce_color_prev,40)) : color(na)) // hide quadrants when draw_ifPriceIn is enabled
        line.set_style(lineQ1, is_current ? settings.ce_style_new : settings.ce_style_prev)
        line.set_width(lineQ1, is_current ? settings.ce_line_width_new : settings.ce_line_width_prev)

    if not na(lineQ2)
        line.set_x2(lineQ2, right)
        line.set_color(lineQ2, show_quadrants ? (is_current ? color.new(settings.ce_color_new,30) : color.new(settings.ce_color_prev,40)) : color(na)) // hide quadrants when draw_ifPriceIn is enabled
        line.set_style(lineQ2, is_current ? settings.ce_style_new : settings.ce_style_prev)

    if not na(lbl) and settings.label_show
        label.set_x(lbl, right)
        label.set_color(lbl, is_current ? color.new(settings.label_bgcolor,65) : settings.label_bgcolor)

method Add(OpenGap GAP, string name, int tt) =>
    gap = Gap.new()
    gap.date_name := GAP.settings.label_show ? str.format_time(tt, dateFormat, syminfo.timezone) : na //gap.date_name := str.format("{0,date,d.M}", tt)
    gap.open := close[1]
    gap.close := open
    gap.middle := (open + close[1]) / 2
    gap.q1 := math.avg(gap.open,gap.middle)
    gap.q2 := math.avg(gap.close,gap.middle)
    gap.open_time := time[1]
    gap.close_time := time + tf_msec * 100
    is_priceIN = close <= gap.open and close >= gap.close
    
    gap.box := box.new(gap.open_time, gap.open, gap.close_time, gap.close, GAP.settings.bg_color_new, 1, line.style_solid, extend.none, xloc.bar_time, GAP.settings.bg_color_new)
    gap.CE := line.new(gap.open_time, gap.middle, gap.close_time, gap.middle, xloc.bar_time, extend.none, GAP.settings.ce_color_new, GAP.settings.ce_style_new, GAP.settings.ce_line_width_new)
    if draw_quadrants and filterQ1Q2(gap.open,gap.close) //and is_priceIN
        gap.quadrant1 := line.new(gap.open_time, gap.q1, gap.close_time, gap.q1, xloc.bar_time, extend.none, GAP.settings.ce_color_new, GAP.settings.ce_style_new, GAP.settings.ce_line_width_new)
        gap.quadrant2 := line.new(gap.open_time, gap.q2, gap.close_time, gap.q2, xloc.bar_time, extend.none, GAP.settings.ce_color_new, GAP.settings.ce_style_new, GAP.settings.ce_line_width_new)

    if GAP.settings.label_show
        gap.lbl_date := label.new(gap.close_time, gap.middle, text = textPadding ? textPrefix + gap.date_name : gap.date_name, style = label.style_label_left, xloc = xloc.bar_time, size = GAP.settings.label_size, color = GAP.settings.label_bgcolor, textcolor = GAP.settings.label_color)

    GAP.gaps.unshift(gap)

    if GAP.gaps.size() > GAP.settings.max_count
        g = GAP.gaps.pop()
        box.delete(g.box)
        line.delete(g.CE)
        line.delete(g.quadrant1)
        line.delete(g.quadrant2)
        label.delete(g.lbl_date)
    GAP

method Redraw(OpenGap GAP) =>
    if GAP.gaps.size() > 0
        for i = 0 to GAP.gaps.size() - 1 by 1
            g = GAP.gaps.get(i)
            g.is_current := i == 0
            e = time + tf_msec * extn
            g.is_priceIN := close <= math.max(g.open, g.close) and close >= math.min(g.open, g.close)
            helper.RenderBox(g.box, g.CE, g.quadrant1, g.quadrant2, g.lbl_date, math.max(g.open, g.close), math.min(g.open, g.close), g.open_time, e, GAP.settings, g.is_current, g.is_priceIN)
    GAP

if barstate.isconfirmed
    if NWOG.settings.show and syminfo.type != 'crypto'
        if not is_sunday[1] and is_sunday //and open != close[1]
            NWOG.Add('NWOG', NDOG.settings.day_ext ? time + oneDay : time)
        NWOG.Redraw()

    if NDOG.settings.show and syminfo.type != 'forex' and syminfo.type != 'crypto' and timeframe.in_seconds('') <= timeframe.in_seconds(hide_above)
        if bool(isNewDay) and open != close[1]
            NDOG.Add('NDOG', NDOG.settings.day_ext ? time + oneDay : time)
        NDOG.Redraw()
````
