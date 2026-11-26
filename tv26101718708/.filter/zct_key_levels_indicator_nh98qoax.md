# ZCT Key Levels Indicator

- url: https://www.tradingview.com/script/Nh98QOaX-ZCT-Key-Levels-Indicator/
- type: indicator
- pine_id: PUB;aa2b5fbed12c43dc8810b940d1100ef4
- version: 1.0

## Description

The ZCT Key Levels Indicator allows you to plot key levels on your chart automatically.

This ensures systematic execution of level selection so your S/R levels are constant.

## Source Code

````pine
//@version=6
indicator('ZCT Key Levels', shorttitle='ZCT Key Levels', overlay=true, max_lines_count=100)


displayStyle = input.string(defval='Standard', title='Display Style', options=['Standard', 'Right Anchored'], inline='Display')
mergebool = input.bool(defval=true, title='Merge Levels?', inline='Display')
distanceright = input.int(defval=30, title='Distance', minval=5, maxval=500, inline='Dist')
radistance = input.int(defval=250, title='Anchor Distance', minval=5, maxval=500, inline='Dist')
labelsize = input.string(defval='Medium', title='Text Size', options=['Small', 'Medium', 'Large'])
linesize = input.string(defval='Small', title='Line Width', options=['Small', 'Medium', 'Large'], inline='Line')
linestyle = input.string(defval='Solid', title='Line Style', options=['Solid', 'Dashed', 'Dotted'], inline='Line')


GlobalTextType = input.bool(defval=false, title='Global Text ShortHand', tooltip='Enable for shorthand text on all text')
var globalcoloring = input.bool(defval=false, title='Global Coloring', tooltip='Enable for all color controls via one color', inline='GC')
GlobalColor = input.color(title='', defval=color.white, inline='GC')


// Data requests
[daily_time, daily_open] = request.security(syminfo.tickerid, 'D', [time, open], lookahead=barmerge.lookahead_on)
[dailyh_time, dailyh_open] = request.security(syminfo.tickerid, 'D', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[dailyl_time, dailyl_open] = request.security(syminfo.tickerid, 'D', [time[1], low[1]], lookahead=barmerge.lookahead_on)


[weekly_time, weekly_open] = request.security(syminfo.tickerid, 'W', [time, open], lookahead=barmerge.lookahead_on)
[weeklyh_time, weeklyh_open] = request.security(syminfo.tickerid, 'W', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[weeklyl_time, weeklyl_open] = request.security(syminfo.tickerid, 'W', [time[1], low[1]], lookahead=barmerge.lookahead_on)


[monthly_time, monthly_open] = request.security(syminfo.tickerid, 'M', [time, open], lookahead=barmerge.lookahead_on)
[monthlyh_time, monthlyh_open] = request.security(syminfo.tickerid, 'M', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[monthlyl_time, monthlyl_open] = request.security(syminfo.tickerid, 'M', [time[1], low[1]], lookahead=barmerge.lookahead_on)


[intra_time, intra_open] = request.security(syminfo.tickerid, '240', [time, open], lookahead=barmerge.lookahead_on)
[intrah_time, intrah_open] = request.security(syminfo.tickerid, '240', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[intral_time, intral_open] = request.security(syminfo.tickerid, '240', [time[1], low[1]], lookahead=barmerge.lookahead_on)


[hour1_time, hour1_open] = request.security(syminfo.tickerid, '60', [time, open], lookahead=barmerge.lookahead_on)
[hour1h_time, hour1h_open] = request.security(syminfo.tickerid, '60', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[hour1l_time, hour1l_open] = request.security(syminfo.tickerid, '60', [time[1], low[1]], lookahead=barmerge.lookahead_on)


[min15_time, min15_open] = request.security(syminfo.tickerid, '15', [time, open], lookahead=barmerge.lookahead_on)
[min15h_time, min15h_open] = request.security(syminfo.tickerid, '15', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[min15l_time, min15l_open] = request.security(syminfo.tickerid, '15', [time[1], low[1]], lookahead=barmerge.lookahead_on)


//------------------------------ INPUTS - ONLY H/L ENABLED BY DEFAULT -------------------------------


// 15min - ENABLED
var is_min15range_enabled = input.bool(defval=true, title='Prev H/L', group='15min', inline='15min')


// 1hr - ENABLED  
var is_hour1range_enabled = input.bool(defval=true, title='Prev H/L', group='1H', inline='1H')


// 4hr - ENABLED
var is_intrarange_enabled = input.bool(defval=true, title='Prev H/L', group='4H', inline='4H')


// Daily - ENABLED
var is_dailyrange_enabled = input.bool(defval=true, title='Prev H/L', group='Daily', inline='Daily')


// Weekly - ENABLED
var is_weeklyrange_enabled = input.bool(defval=true, title='Prev H/L', group='Weekly', inline='Weekly')


// Monthly - ENABLED
var is_monthlyrange_enabled = input.bool(defval=true, title='Prev H/L', group='Monthly', inline='Monthly')


// Colors
Min15Color = input.color(title='', defval=color.purple, group='15min', inline='15min')
Hour1Color = input.color(title='', defval=color.blue, group='1H', inline='1H')
IntraColor = input.color(title='', defval=color.orange, group='4H', inline='4H')
DailyColor = input.color(title='', defval=#08bcd4, group='Daily', inline='Daily')
WeeklyColor = input.color(title='', defval=#fffcbc, group='Weekly', inline='Weekly')
MonthlyColor = input.color(title='', defval=#08d48c, group='Monthly', inline='Monthly')


// Text labels
var p15htext = 'P15H'
var p15ltext = 'P15L'
var p1htext = 'P1H'
var p1ltext = 'P1L'
var pihtext = 'P4H'
var piltext = 'P4L'
var pdhtext = 'PDH'
var pdltext = 'PDL'
var pwhtext = 'PWH'
var pwltext = 'PWL'
var pmhtext = 'PMH'
var pmltext = 'PML'


if globalcoloring == true
    Min15Color := GlobalColor
    Hour1Color := GlobalColor
    IntraColor := GlobalColor
    DailyColor := GlobalColor
    WeeklyColor := GlobalColor
    MonthlyColor := GlobalColor


linewidthint = linesize == 'Small' ? 1 : linesize == 'Medium' ? 2 : 3
var DEFAULT_LINE_WIDTH = linewidthint


fontsize = labelsize == 'Small' ? size.small : labelsize == 'Medium' ? size.normal : size.large
var DEFAULT_LABEL_SIZE = fontsize
var DEFAULT_LABEL_STYLE = label.style_none
var DEFAULT_EXTEND_RIGHT = distanceright


linestyles = linestyle == 'Dashed' ? line.style_dashed : linestyle == 'Dotted' ? line.style_dotted : line.style_solid


//------------------------------ Plotting ------------------------------
var pricearray = array.new_float(0)
var labelarray = array.new_label(0)


f_LevelMerge(pricearray, labelarray, currentprice, currentlabel, currentcolor) =>
    if array.includes(pricearray, currentprice)
        whichindex = array.indexof(pricearray, currentprice)
        labelhold = array.get(labelarray, whichindex)
        whichtext = label.get_text(labelhold)
        label.set_text(labelhold, label.get_text(currentlabel) + ' / ' + whichtext)
        label.set_text(currentlabel, '')
        label.set_textcolor(labelhold, currentcolor)
    else
        array.push(pricearray, currentprice)
        array.push(labelarray, currentlabel)


get_limit_right(bars) =>
    timenow + (time - time[1]) * bars


if barstate.islast
    pricearray := array.new_float(0)
    labelarray := array.new_label(0)


    // 15min High/Low
    if is_min15range_enabled
        min15h_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        min15l_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            min15h_time := get_limit_right(radistance)
            min15l_time := get_limit_right(radistance)


        var min15h_line = line.new(x1=min15h_time, x2=min15h_limit_right, y1=min15h_open, y2=min15h_open, color=Min15Color, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var min15h_label = label.new(x=min15h_limit_right, y=min15h_open, text=p15htext, style=DEFAULT_LABEL_STYLE, textcolor=Min15Color, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var min15l_line = line.new(x1=min15l_time, x2=min15l_limit_right, y1=min15l_open, y2=min15l_open, color=Min15Color, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var min15l_label = label.new(x=min15l_limit_right, y=min15l_open, text=p15ltext, style=DEFAULT_LABEL_STYLE, textcolor=Min15Color, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(min15h_line, min15h_time)
        line.set_x2(min15h_line, min15h_limit_right)
        line.set_y1(min15h_line, min15h_open)
        line.set_y2(min15h_line, min15h_open)
       
        line.set_x1(min15l_line, min15l_time)
        line.set_x2(min15l_line, min15l_limit_right)
        line.set_y1(min15l_line, min15l_open)
        line.set_y2(min15l_line, min15l_open)
       
        label.set_x(min15h_label, min15h_limit_right)
        label.set_y(min15h_label, min15h_open)
        label.set_text(min15h_label, p15htext)
       
        label.set_x(min15l_label, min15l_limit_right)
        label.set_y(min15l_label, min15l_open)
        label.set_text(min15l_label, p15ltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, min15h_open, min15h_label, Min15Color)
            f_LevelMerge(pricearray, labelarray, min15l_open, min15l_label, Min15Color)


    // 1hr High/Low
    if is_hour1range_enabled
        hour1h_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        hour1l_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            hour1h_time := get_limit_right(radistance)
            hour1l_time := get_limit_right(radistance)


        var hour1h_line = line.new(x1=hour1h_time, x2=hour1h_limit_right, y1=hour1h_open, y2=hour1h_open, color=Hour1Color, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var hour1h_label = label.new(x=hour1h_limit_right, y=hour1h_open, text=p1htext, style=DEFAULT_LABEL_STYLE, textcolor=Hour1Color, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var hour1l_line = line.new(x1=hour1l_time, x2=hour1l_limit_right, y1=hour1l_open, y2=hour1l_open, color=Hour1Color, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var hour1l_label = label.new(x=hour1l_limit_right, y=hour1l_open, text=p1ltext, style=DEFAULT_LABEL_STYLE, textcolor=Hour1Color, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(hour1h_line, hour1h_time)
        line.set_x2(hour1h_line, hour1h_limit_right)
        line.set_y1(hour1h_line, hour1h_open)
        line.set_y2(hour1h_line, hour1h_open)
       
        line.set_x1(hour1l_line, hour1l_time)
        line.set_x2(hour1l_line, hour1l_limit_right)
        line.set_y1(hour1l_line, hour1l_open)
        line.set_y2(hour1l_line, hour1l_open)
       
        label.set_x(hour1h_label, hour1h_limit_right)
        label.set_y(hour1h_label, hour1h_open)
        label.set_text(hour1h_label, p1htext)
       
        label.set_x(hour1l_label, hour1l_limit_right)
        label.set_y(hour1l_label, hour1l_open)
        label.set_text(hour1l_label, p1ltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, hour1h_open, hour1h_label, Hour1Color)
            f_LevelMerge(pricearray, labelarray, hour1l_open, hour1l_label, Hour1Color)


    // 4hr High/Low
    if is_intrarange_enabled
        intrah_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        intral_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            intrah_time := get_limit_right(radistance)
            intral_time := get_limit_right(radistance)


        var intrah_line = line.new(x1=intrah_time, x2=intrah_limit_right, y1=intrah_open, y2=intrah_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intrah_label = label.new(x=intrah_limit_right, y=intrah_open, text=pihtext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var intral_line = line.new(x1=intral_time, x2=intral_limit_right, y1=intral_open, y2=intral_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intral_label = label.new(x=intral_limit_right, y=intral_open, text=piltext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(intrah_line, intrah_time)
        line.set_x2(intrah_line, intrah_limit_right)
        line.set_y1(intrah_line, intrah_open)
        line.set_y2(intrah_line, intrah_open)
       
        line.set_x1(intral_line, intral_time)
        line.set_x2(intral_line, intral_limit_right)
        line.set_y1(intral_line, intral_open)
        line.set_y2(intral_line, intral_open)
       
        label.set_x(intrah_label, intrah_limit_right)
        label.set_y(intrah_label, intrah_open)
        label.set_text(intrah_label, pihtext)
       
        label.set_x(intral_label, intral_limit_right)
        label.set_y(intral_label, intral_open)
        label.set_text(intral_label, piltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, intrah_open, intrah_label, IntraColor)
            f_LevelMerge(pricearray, labelarray, intral_open, intral_label, IntraColor)


    // Daily High/Low
    if is_dailyrange_enabled
        dailyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        dailyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            dailyh_time := get_limit_right(radistance)
            dailyl_time := get_limit_right(radistance)


        var dailyh_line = line.new(x1=dailyh_time, x2=dailyh_limit_right, y1=dailyh_open, y2=dailyh_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var dailyh_label = label.new(x=dailyh_limit_right, y=dailyh_open, text=pdhtext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var dailyl_line = line.new(x1=dailyl_time, x2=dailyl_limit_right, y1=dailyl_open, y2=dailyl_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var dailyl_label = label.new(x=dailyl_limit_right, y=dailyl_open, text=pdltext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(dailyh_line, dailyh_time)
        line.set_x2(dailyh_line, dailyh_limit_right)
        line.set_y1(dailyh_line, dailyh_open)
        line.set_y2(dailyh_line, dailyh_open)
       
        line.set_x1(dailyl_line, dailyl_time)
        line.set_x2(dailyl_line, dailyl_limit_right)
        line.set_y1(dailyl_line, dailyl_open)
        line.set_y2(dailyl_line, dailyl_open)
       
        label.set_x(dailyh_label, dailyh_limit_right)
        label.set_y(dailyh_label, dailyh_open)
        label.set_text(dailyh_label, pdhtext)
       
        label.set_x(dailyl_label, dailyl_limit_right)
        label.set_y(dailyl_label, dailyl_open)
        label.set_text(dailyl_label, pdltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, dailyh_open, dailyh_label, DailyColor)
            f_LevelMerge(pricearray, labelarray, dailyl_open, dailyl_label, DailyColor)


    // Weekly High/Low
    if is_weeklyrange_enabled
        weeklyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        weeklyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            weeklyh_time := get_limit_right(radistance)
            weeklyl_time := get_limit_right(radistance)


        var weeklyh_line = line.new(x1=weeklyh_time, x2=weeklyh_limit_right, y1=weeklyh_open, y2=weeklyh_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weeklyh_label = label.new(x=weeklyh_limit_right, y=weeklyh_open, text=pwhtext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var weeklyl_line = line.new(x1=weeklyl_time, x2=weeklyl_limit_right, y1=weeklyl_open, y2=weeklyl_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weeklyl_label = label.new(x=weeklyl_limit_right, y=weeklyl_open, text=pwltext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(weeklyh_line, weeklyh_time)
        line.set_x2(weeklyh_line, weeklyh_limit_right)
        line.set_y1(weeklyh_line, weeklyh_open)
        line.set_y2(weeklyh_line, weeklyh_open)
       
        line.set_x1(weeklyl_line, weeklyl_time)
        line.set_x2(weeklyl_line, weeklyl_limit_right)
        line.set_y1(weeklyl_line, weeklyl_open)
        line.set_y2(weeklyl_line, weeklyl_open)
       
        label.set_x(weeklyh_label, weeklyh_limit_right)
        label.set_y(weeklyh_label, weeklyh_open)
        label.set_text(weeklyh_label, pwhtext)
       
        label.set_x(weeklyl_label, weeklyl_limit_right)
        label.set_y(weeklyl_label, weeklyl_open)
        label.set_text(weeklyl_label, pwltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, weeklyh_open, weeklyh_label, WeeklyColor)
            f_LevelMerge(pricearray, labelarray, weeklyl_open, weeklyl_label, WeeklyColor)


    // Monthly High/Low
    if is_monthlyrange_enabled
        monthlyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        monthlyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
       
        if displayStyle == 'Right Anchored'
            monthlyh_time := get_limit_right(radistance)
            monthlyl_time := get_limit_right(radistance)


        var monthlyh_line = line.new(x1=monthlyh_time, x2=monthlyh_limit_right, y1=monthlyh_open, y2=monthlyh_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlyh_label = label.new(x=monthlyh_limit_right, y=monthlyh_open, text=pmhtext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
       
        var monthlyl_line = line.new(x1=monthlyl_time, x2=monthlyl_limit_right, y1=monthlyl_open, y2=monthlyl_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlyl_label = label.new(x=monthlyl_limit_right, y=monthlyl_open, text=pmltext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)


        line.set_x1(monthlyh_line, monthlyh_time)
        line.set_x2(monthlyh_line, monthlyh_limit_right)
        line.set_y1(monthlyh_line, monthlyh_open)
        line.set_y2(monthlyh_line, monthlyh_open)
       
        line.set_x1(monthlyl_line, monthlyl_time)
        line.set_x2(monthlyl_line, monthlyl_limit_right)
        line.set_y1(monthlyl_line, monthlyl_open)
        line.set_y2(monthlyl_line, monthlyl_open)
       
        label.set_x(monthlyh_label, monthlyh_limit_right)
        label.set_y(monthlyh_label, monthlyh_open)
        label.set_text(monthlyh_label, pmhtext)
       
        label.set_x(monthlyl_label, monthlyl_limit_right)
        label.set_y(monthlyl_label, monthlyl_open)
        label.set_text(monthlyl_label, pmltext)
       
        if mergebool
            f_LevelMerge(pricearray, labelarray, monthlyh_open, monthlyh_label, MonthlyColor)
            f_LevelMerge(pricearray, labelarray, monthlyl_open, monthlyl_label, MonthlyColor)


// Required plot (invisible)
plot(na, title="Key Levels")
````
