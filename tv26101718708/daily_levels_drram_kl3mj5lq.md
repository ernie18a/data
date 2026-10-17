# Daily Levels [Dr-Ram]

- url: https://www.tradingview.com/script/kl3Mj5lq-Daily-Levels-Dr-Ram/
- type: indicator
- pine_id: PUB;11b3afdcde6b4061a23f84ba0f5515cd
- version: 1.0

## Description

English:

This indicator plots the previous trading day's highest and lowest wick prices as horizontal reference lines, helping traders spot key support/resistance levels carried over from the prior session.

- On **Tuesday–Friday**, it draws the **High** and **Low** of the immediately preceding trading day (e.g., on Wednesday it shows Tuesday's High/Low).
- On **Monday**, since the market was closed over the weekend, it draws two separate reference pairs instead: **Friday's High/Low** (last full trading day) and **Sunday's High/Low** (the initial weekend/open session), each in its own color so they can be told apart at a glance.
- Each line begins at the start of its target day and extends only through that day — it does not carry over into the next day.
- Colors, line width, and line style (solid/dashed/dotted) are fully customizable in the settings.

فارسی:

این اندیکاتور بالاترین و پایین‌ترین قیمت (سایه کندل، نه بدنه) روز معاملاتی قبل را به‌صورت خطوط افقی مرجع روی چارت رسم می‌کند تا سطوح حمایت/مقاومت مهمی که از روز قبل باقی مانده مشخص شوند.

- در روزهای **سه‌شنبه تا جمعه**، بالاترین و پایین‌ترین نقطه‌ی **روز معاملاتی قبل** رسم می‌شود (مثلاً چهارشنبه، سقف/کف روز سه‌شنبه نشان داده می‌شود).
- در **دوشنبه**، چون بازار در تعطیلات آخر هفته بسته بوده، به‌جای یک جفت خط، دو جفت جداگانه رسم می‌شود: **سقف/کف جمعه** (آخرین روز کامل معاملاتی) و **سقف/کف یکشنبه** (اولین بخش بازگشایی هفته)، هرکدام با رنگ متفاوت تا به‌راحتی از هم تشخیص داده شوند.
- هر خط دقیقاً از ابتدای روز هدف شروع شده و فقط تا پایان همان روز ادامه دارد و به روز بعد کشیده نمی‌شود.
- رنگ‌ها، ضخامت خط و نوع خط (ممتد/خط‌چین/نقطه‌چین) کاملاً از تنظیمات قابل تغییر هستند.

## Source Code

````pine
// Daily Levels [Dr-Ram]
// Draws previous trading day's High/Low as horizontal lines on Tue-Fri,
// and Friday's + Sunday's High/Low on Monday.

//@version=6
indicator("Daily Levels [Dr-Ram]", "Daily Levels (Dr-Ram)", overlay = true, max_lines_count = 500)

//-----------------------------------------------------------------------------}
//Settings
//-----------------------------------------------------------------------------{
show_prevday = input(true, 'Show Previous-Day High/Low (Tue-Fri)', group = 'Daily Levels')
prevday_high_css = input.color(color.lime, 'High Line', inline = 'prevday_css', group = 'Daily Levels')
prevday_low_css = input.color(color.red, 'Low Line', inline = 'prevday_css', group = 'Daily Levels')
prevday_width = input.int(1, 'Line Width', minval = 1, group = 'Daily Levels')
prevday_style = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Daily Levels')

show_monday = input(true, 'Show Monday Levels (Friday & Sunday)', group = 'Monday Levels')
monday_fri_css = input.color(color.orange, 'Friday High/Low', group = 'Monday Levels')
monday_sun_css = input.color(color.aqua, 'Sunday High/Low', group = 'Monday Levels')
monday_width = input.int(1, 'Line Width', minval = 1, group = 'Monday Levels')
monday_style = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Monday Levels')

show_day_div = input(true, 'Show Daily Divider', group = 'Dividers')

//-----------------------------------------------------------------------------}
//Functions
//-----------------------------------------------------------------------------{
n = bar_index

get_line_style(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

//-----------------------------------------------------------------------------}
//Daily High/Low Tracking
//-----------------------------------------------------------------------------{
wd = dayofweek //1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday

//Running accumulator for the day currently in progress
var float d_high = na
var float d_low  = na

//Completed-day storage, updated the moment each calendar day ends
var float mon_high = na
var float mon_low  = na
var float tue_high = na
var float tue_low  = na
var float wed_high = na
var float wed_low  = na
var float thu_high = na
var float thu_low  = na
var float fri_high = na
var float fri_low  = na
var float sun_high = na
var float sun_low  = na

is_new_day = wd != wd[1]

if is_new_day
    if not na(d_high)
        if wd[1] == 2
            mon_high := d_high
            mon_low  := d_low
        else if wd[1] == 3
            tue_high := d_high
            tue_low  := d_low
        else if wd[1] == 4
            wed_high := d_high
            wed_low  := d_low
        else if wd[1] == 5
            thu_high := d_high
            thu_low  := d_low
        else if wd[1] == 6
            fri_high := d_high
            fri_low  := d_low
        else if wd[1] == 1
            sun_high := d_high
            sun_low  := d_low
    d_high := high
    d_low  := low
else
    d_high := math.max(d_high, high)
    d_low  := math.min(d_low, low)

prevday_line_style = get_line_style(prevday_style)
monday_line_style  = get_line_style(monday_style)

//-----------------------------------------------------------------------------}
//Draw Lines
//-----------------------------------------------------------------------------{
//Tuesday : draw Monday's High/Low, only during Tuesday
var line tue_hi_ln = na
var line tue_lo_ln = na
is_tue = wd == 3
if show_prevday and is_tue and not na(mon_high)
    if not is_tue[1]
        tue_hi_ln := line.new(n, mon_high, n, mon_high, color = prevday_high_css, width = prevday_width, style = prevday_line_style)
        tue_lo_ln := line.new(n, mon_low, n, mon_low, color = prevday_low_css, width = prevday_width, style = prevday_line_style)
    else
        line.set_xy2(tue_hi_ln, n, mon_high)
        line.set_xy2(tue_lo_ln, n, mon_low)

//Wednesday : draw Tuesday's High/Low, only during Wednesday
var line wed_hi_ln = na
var line wed_lo_ln = na
is_wed = wd == 4
if show_prevday and is_wed and not na(tue_high)
    if not is_wed[1]
        wed_hi_ln := line.new(n, tue_high, n, tue_high, color = prevday_high_css, width = prevday_width, style = prevday_line_style)
        wed_lo_ln := line.new(n, tue_low, n, tue_low, color = prevday_low_css, width = prevday_width, style = prevday_line_style)
    else
        line.set_xy2(wed_hi_ln, n, tue_high)
        line.set_xy2(wed_lo_ln, n, tue_low)

//Thursday : draw Wednesday's High/Low, only during Thursday
var line thu_hi_ln = na
var line thu_lo_ln = na
is_thu = wd == 5
if show_prevday and is_thu and not na(wed_high)
    if not is_thu[1]
        thu_hi_ln := line.new(n, wed_high, n, wed_high, color = prevday_high_css, width = prevday_width, style = prevday_line_style)
        thu_lo_ln := line.new(n, wed_low, n, wed_low, color = prevday_low_css, width = prevday_width, style = prevday_line_style)
    else
        line.set_xy2(thu_hi_ln, n, wed_high)
        line.set_xy2(thu_lo_ln, n, wed_low)

//Friday : draw Thursday's High/Low, only during Friday
var line fri_hi_ln = na
var line fri_lo_ln = na
is_fri = wd == 6
if show_prevday and is_fri and not na(thu_high)
    if not is_fri[1]
        fri_hi_ln := line.new(n, thu_high, n, thu_high, color = prevday_high_css, width = prevday_width, style = prevday_line_style)
        fri_lo_ln := line.new(n, thu_low, n, thu_low, color = prevday_low_css, width = prevday_width, style = prevday_line_style)
    else
        line.set_xy2(fri_hi_ln, n, thu_high)
        line.set_xy2(fri_lo_ln, n, thu_low)

//Monday : draw Friday's High/Low (one color) and Sunday's High/Low (another color), only during Monday
var line mon_fri_hi_ln = na
var line mon_fri_lo_ln = na
var line mon_sun_hi_ln = na
var line mon_sun_lo_ln = na
is_mon = wd == 2
if show_monday and is_mon
    if not is_mon[1]
        if not na(fri_high)
            mon_fri_hi_ln := line.new(n, fri_high, n, fri_high, color = monday_fri_css, width = monday_width, style = monday_line_style)
            mon_fri_lo_ln := line.new(n, fri_low, n, fri_low, color = monday_fri_css, width = monday_width, style = monday_line_style)
        if not na(sun_high)
            mon_sun_hi_ln := line.new(n, sun_high, n, sun_high, color = monday_sun_css, width = monday_width, style = monday_line_style)
            mon_sun_lo_ln := line.new(n, sun_low, n, sun_low, color = monday_sun_css, width = monday_width, style = monday_line_style)
    else
        if not na(fri_high)
            line.set_xy2(mon_fri_hi_ln, n, fri_high)
            line.set_xy2(mon_fri_lo_ln, n, fri_low)
        if not na(sun_high)
            line.set_xy2(mon_sun_hi_ln, n, sun_high)
            line.set_xy2(mon_sun_lo_ln, n, sun_low)

//-----------------------------------------------------------------------------}
//Daily Divider (vertical line + weekday label)
//-----------------------------------------------------------------------------{
if wd != wd[1] and show_day_div
    line.new(n, close + syminfo.mintick, n, close - syminfo.mintick
      , color  = color.gray
      , extend = extend.both
      , style  = line.style_dashed)

plotshape(wd != wd[1] and wd == 1 and show_day_div, "Sunday"
  , shape.labeldown
  , location.top
  , na
  , text = "Sunday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 2 and show_day_div, "Monday"
  , shape.labeldown
  , location.top
  , na
  , text = "Monday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 3 and show_day_div, "Tuesday"
  , shape.labeldown
  , location.top
  , na
  , text = "Tuesday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 4 and show_day_div, "Wednesday"
  , shape.labeldown
  , location.top
  , na
  , text = "Wednesday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 5 and show_day_div, "Thursday"
  , shape.labeldown
  , location.top
  , na
  , text = "Thursday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 6 and show_day_div, "Friday"
  , shape.labeldown
  , location.top
  , na
  , text = "Friday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

plotshape(wd != wd[1] and wd == 7 and show_day_div, "Saturday"
  , shape.labeldown
  , location.top
  , na
  , text = "Saturday"
  , textcolor = color.gray
  , size = size.tiny
  , display = display.all - display.status_line
  , editable = false)

//-----------------------------------------------------------------------------}
````
