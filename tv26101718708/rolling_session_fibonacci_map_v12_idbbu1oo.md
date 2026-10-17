# Rolling Session Fibonacci Map v1.2

- url: https://www.tradingview.com/script/iDBBu1Oo/
- type: indicator
- pine_id: PUB;94d1c8ddb19548dd927f313dd4ebdb4d
- version: 1.0

## Description

Rolling Session Fibonacci Map

Overview

This indicator provides a structured way to analyze price position using Fibonacci retracement levels anchored to a rolling time-based session.

Instead of manually drawing Fibonacci levels, the script automatically defines a session range (Daily, Weekly, Monthly, or Yearly) and continuously updates its high and low values as the session evolves.

The result is a consistent and repeatable reference framework for observing how price behaves within a defined range.

How It Works

A session is defined using a selected time period (Daily, Weekly, Monthly, or Yearly), a custom anchor time (hour and minute), and a chosen timezone.

During the active session, the highest and lowest prices are tracked dynamically.

Fibonacci levels are calculated between these two points and updated in real time as new highs or lows are formed.

The indicator plots standard Fibonacci levels from 0 to 1, optional background zones between these levels, and a diagonal reference line representing the full session range.

A reference panel displays the current Fibonacci zone, the price range of that zone, the nearest lower and upper reference levels, and the relative position of price compared to the diagonal line.

How to Use

This indicator is designed as a reference layer rather than a trading signal generator.

It can be used to identify where price is located within the current session range, observe how price reacts at different Fibonacci zones, and compare price positioning across multiple timeframes.

It is also suitable to be used alongside other tools such as trend or momentum indicators to provide additional context.

Important Notes

This script does not generate buy or sell signals.

Fibonacci levels are derived strictly from the selected session range and should be interpreted as contextual reference zones.

The diagonal line is a visual reference and does not represent a predictive model.

Disclaimer

This indicator is intended for analytical and educational purposes only.

It does not provide financial advice or trading recommendations.

## Source Code

````pine
//@version=5
indicator("Rolling Session Fibonacci Map v1.2", overlay=true, max_lines_count=100, max_labels_count=100)

// =====================
// LANGUAGE
// =====================
language = input.string("English", "Language / Dil", options=["English", "Türkçe"], group="General")

f_txt(_en, _tr) =>
    language == "Türkçe" ? _tr : _en

// =====================
// GENERAL SETTINGS
// =====================
tz = input.string("Etc/UTC", "Time Zone / Zaman Dilimi", options=["Etc/UTC", "Europe/Istanbul", "America/New_York", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Dubai"], group="General")

periodType = input.string("Daily", "Anchor Period / Çapa Periyodu", options=["Daily", "Weekly", "Monthly", "Yearly"], group="General")

backPeriod = input.int(0, "Lookback Period / Geri Dönem", minval=0, maxval=500, group="General")

startHour = input.int(0, "Anchor Hour / Başlangıç Saati", minval=0, maxval=23, group="General")

startMinute = input.int(0, "Anchor Minute / Başlangıç Dakikası", minval=0, maxval=59, group="General")

// =====================
// VISUAL SETTINGS
// =====================
showLabels = input.bool(true, "Show Labels / Etiketleri Göster", group="Visuals")

showDiagonal = input.bool(true, "Show Diagonal / Diyagonal Çizgiyi Göster", group="Visuals")

showZones = input.bool(true, "Show Background Zones / Arka Plan Bölgelerini Göster", group="Visuals")

zoneTransparency = input.int(85, "Zone Transparency / Bölge Şeffaflığı", minval=0, maxval=100, group="Visuals")

lineWidthMain = input.int(2, "Main Level Width / Ana Seviye Kalınlığı", minval=1, maxval=5, group="Visuals")

lineWidthMid = input.int(1, "Middle Level Width / Ara Seviye Kalınlığı", minval=1, maxval=5, group="Visuals")

// =====================
// REFERENCE PANEL SETTINGS
// =====================
showInfoPanel = input.bool(true, "Show Reference Panel / Referans Panelini Göster", group="Reference Panel")

panelPosition = input.string("Top Right", "Panel Position / Panel Konumu", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Reference Panel")

// =====================
// COLORS
// =====================
col0   = color.rgb(242, 54, 69)
col236 = color.rgb(255, 152, 0)
col382 = color.rgb(76, 175, 80)
col50  = color.rgb(120, 123, 134)
col618 = color.rgb(0, 150, 136)
col786 = color.rgb(33, 150, 243)
col1   = color.rgb(230, 230, 230)

zone0_236   = color.new(col0, zoneTransparency)
zone236_382 = color.new(col236, zoneTransparency)
zone382_50  = color.new(col382, zoneTransparency)
zone50_618  = color.new(col382, zoneTransparency)
zone618_786 = color.new(col618, zoneTransparency)
zone786_1   = color.new(col786, zoneTransparency)

zoneHidden = color.new(color.white, 100)

// =====================
// TIME CONSTANTS
// =====================
dayMs  = 24 * 60 * 60 * 1000
weekMs = 7 * dayMs

nowTime = timenow

curYear  = year(nowTime, tz)
curMonth = month(nowTime, tz)
curDay   = dayofmonth(nowTime, tz)
curDow   = dayofweek(nowTime, tz)

// =====================
// DAILY START / END
// =====================
todayStart = timestamp(tz, curYear, curMonth, curDay, startHour, startMinute)
activeDailyStart = nowTime >= todayStart ? todayStart : todayStart - dayMs

dailyStart = activeDailyStart - backPeriod * dayMs
dailyEnd   = dailyStart + dayMs

// =====================
// WEEKLY START / END
// =====================
daysFromMonday = curDow == dayofweek.monday ? 0 :
     curDow == dayofweek.tuesday ? 1 :
     curDow == dayofweek.wednesday ? 2 :
     curDow == dayofweek.thursday ? 3 :
     curDow == dayofweek.friday ? 4 :
     curDow == dayofweek.saturday ? 5 : 6

mondayDateTime = timestamp(tz, curYear, curMonth, curDay, startHour, startMinute) - daysFromMonday * dayMs
activeWeeklyStart = nowTime >= mondayDateTime ? mondayDateTime : mondayDateTime - weekMs

weeklyStart = activeWeeklyStart - backPeriod * weekMs
weeklyEnd   = weeklyStart + weekMs

// =====================
// MONTHLY START / END
// =====================
currentMonthStart = timestamp(tz, curYear, curMonth, 1, startHour, startMinute)

activeMonthIndex = curYear * 12 + curMonth - 1
activeMonthIndex := nowTime >= currentMonthStart ? activeMonthIndex : activeMonthIndex - 1

selectedMonthIndex = activeMonthIndex - backPeriod

selectedMonthYear = int(math.floor(selectedMonthIndex / 12))
selectedMonth     = selectedMonthIndex % 12 + 1

nextMonthIndex = selectedMonthIndex + 1
nextMonthYear  = int(math.floor(nextMonthIndex / 12))
nextMonth      = nextMonthIndex % 12 + 1

monthlyStart = timestamp(tz, selectedMonthYear, selectedMonth, 1, startHour, startMinute)
monthlyEnd   = timestamp(tz, nextMonthYear, nextMonth, 1, startHour, startMinute)

// =====================
// YEARLY START / END
// =====================
currentYearStart = timestamp(tz, curYear, 1, 1, startHour, startMinute)

activeYear = nowTime >= currentYearStart ? curYear : curYear - 1
selectedYear = activeYear - backPeriod

yearlyStart = timestamp(tz, selectedYear, 1, 1, startHour, startMinute)
yearlyEnd   = timestamp(tz, selectedYear + 1, 1, 1, startHour, startMinute)

// =====================
// SELECTED SESSION
// =====================
sessionStart =
     periodType == "Daily"   ? dailyStart :
     periodType == "Weekly"  ? weeklyStart :
     periodType == "Monthly" ? monthlyStart :
     yearlyStart

sessionEnd =
     periodType == "Daily"   ? dailyEnd :
     periodType == "Weekly"  ? weeklyEnd :
     periodType == "Monthly" ? monthlyEnd :
     yearlyEnd

inSession = time >= sessionStart and time < sessionEnd
newSession = inSession and not inSession[1]

// =====================
// DYNAMIC HIGH / LOW
// =====================
var float sessionLow  = na
var float sessionHigh = na

if newSession
    sessionLow  := low
    sessionHigh := high

if inSession
    sessionLow  := math.min(nz(sessionLow, low), low)
    sessionHigh := math.max(nz(sessionHigh, high), high)

// =====================
// FIBONACCI LEVELS
// =====================
fib0   = sessionLow
fib236 = sessionLow + (sessionHigh - sessionLow) * 0.236
fib382 = sessionLow + (sessionHigh - sessionLow) * 0.382
fib50  = sessionLow + (sessionHigh - sessionLow) * 0.5
fib618 = sessionLow + (sessionHigh - sessionLow) * 0.618
fib786 = sessionLow + (sessionHigh - sessionLow) * 0.786
fib1   = sessionHigh

// =====================
// PANEL HELPERS
// =====================
f_price(_v) =>
    na(_v) ? "-" : str.tostring(_v, format.mintick)

f_periodTxt() =>
    periodType == "Daily" ? f_txt("Daily", "Günlük") :
     periodType == "Weekly" ? f_txt("Weekly", "Haftalık") :
     periodType == "Monthly" ? f_txt("Monthly", "Aylık") :
     f_txt("Yearly", "Yıllık")

f_panelPos() =>
    panelPosition == "Top Right" ? position.top_right :
     panelPosition == "Top Left" ? position.top_left :
     panelPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

// =====================
// CURRENT ZONE / REFERENCES
// =====================
float lowerRef = na
float upperRef = na
string zoneText = ""

if not na(sessionLow) and not na(sessionHigh)
    if close < fib0
        lowerRef := na
        upperRef := fib0
        zoneText := f_txt("Below 0", "0 Altı")
    else if close >= fib0 and close < fib236
        lowerRef := fib0
        upperRef := fib236
        zoneText := "0 - 0.236"
    else if close >= fib236 and close < fib382
        lowerRef := fib236
        upperRef := fib382
        zoneText := "0.236 - 0.382"
    else if close >= fib382 and close < fib50
        lowerRef := fib382
        upperRef := fib50
        zoneText := "0.382 - 0.5"
    else if close >= fib50 and close < fib618
        lowerRef := fib50
        upperRef := fib618
        zoneText := "0.5 - 0.618"
    else if close >= fib618 and close < fib786
        lowerRef := fib618
        upperRef := fib786
        zoneText := "0.618 - 0.786"
    else if close >= fib786 and close <= fib1
        lowerRef := fib786
        upperRef := fib1
        zoneText := "0.786 - 1"
    else
        lowerRef := fib1
        upperRef := na
        zoneText := f_txt("Above 1", "1 Üstü")

zoneRangeText = f_price(lowerRef) + " - " + f_price(upperRef)

// =====================
// DIAGONAL BIAS
// =====================
sessionDuration = sessionEnd - sessionStart
progressRaw = sessionDuration > 0 ? (time - sessionStart) / sessionDuration : na
progress = math.max(0.0, math.min(1.0, progressRaw))
diagPrice = fib1 + (fib0 - fib1) * progress

diagBias =
     not showDiagonal or na(diagPrice) ? f_txt("Off", "Kapalı") :
     close > diagPrice ? f_txt("Above / Strong", "Üstünde / Güçlü") :
     close < diagPrice ? f_txt("Below / Weak", "Altında / Zayıf") :
     f_txt("On Diagonal", "Diyagonal Üzerinde")

// =====================
// OBJECTS
// =====================
var line l0   = na
var line l236 = na
var line l382 = na
var line l50  = na
var line l618 = na
var line l786 = na
var line l1   = na
var line diag = na

var linefill fill0_236   = na
var linefill fill236_382 = na
var linefill fill382_50  = na
var linefill fill50_618  = na
var linefill fill618_786 = na
var linefill fill786_1   = na

var label lab0   = na
var label lab236 = na
var label lab382 = na
var label lab50  = na
var label lab618 = na
var label lab786 = na
var label lab1   = na

var table infoPanel = table.new(f_panelPos(), 2, 6, border_width=1)

// =====================
// FUNCTIONS
// =====================
f_setLine(_line, _y, _col, _width) =>
    if na(_line)
        line.new(sessionStart, _y, sessionEnd, _y, xloc=xloc.bar_time, color=_col, width=_width)
    else
        line.set_xy1(_line, sessionStart, _y)
        line.set_xy2(_line, sessionEnd, _y)
        line.set_color(_line, _col)
        line.set_width(_line, _width)
        _line

f_setLabel(_label, _txt, _y, _col) =>
    if showLabels
        if na(_label)
            label.new(sessionEnd, _y, _txt, xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=_col)
        else
            label.set_x(_label, sessionEnd)
            label.set_y(_label, _y)
            label.set_text(_label, _txt)
            label.set_color(_label, _col)
            _label
    else
        if not na(_label)
            label.delete(_label)
        na

f_setFill(_fill, _line1, _line2, _col) =>
    activeColor = showZones ? _col : zoneHidden
    if na(_fill)
        linefill.new(_line1, _line2, activeColor)
    else
        linefill.set_color(_fill, activeColor)
        _fill

f_panelRow(_row, _left, _right) =>
    table.cell(infoPanel, 0, _row, _left, text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(infoPanel, 1, _row, _right, text_color=color.white, bgcolor=color.new(color.black, 15))

// =====================
// DRAWING
// =====================
if inSession and not na(sessionLow) and not na(sessionHigh)
    l0   := f_setLine(l0, fib0, col0, lineWidthMain)
    l236 := f_setLine(l236, fib236, col236, lineWidthMid)
    l382 := f_setLine(l382, fib382, col382, lineWidthMid)
    l50  := f_setLine(l50, fib50, col50, lineWidthMid)
    l618 := f_setLine(l618, fib618, col618, lineWidthMid)
    l786 := f_setLine(l786, fib786, col786, lineWidthMid)
    l1   := f_setLine(l1, fib1, col1, lineWidthMain)

    fill0_236   := f_setFill(fill0_236, l0, l236, zone0_236)
    fill236_382 := f_setFill(fill236_382, l236, l382, zone236_382)
    fill382_50  := f_setFill(fill382_50, l382, l50, zone382_50)
    fill50_618  := f_setFill(fill50_618, l50, l618, zone50_618)
    fill618_786 := f_setFill(fill618_786, l618, l786, zone618_786)
    fill786_1   := f_setFill(fill786_1, l786, l1, zone786_1)

    if showDiagonal
        if na(diag)
            diag := line.new(sessionStart, fib1, sessionEnd, fib0, xloc=xloc.bar_time, color=color.gray, style=line.style_dashed)
        else
            line.set_xy1(diag, sessionStart, fib1)
            line.set_xy2(diag, sessionEnd, fib0)
            line.set_color(diag, color.gray)
            line.set_style(diag, line.style_dashed)
    else
        if not na(diag)
            line.delete(diag)
            diag := na

    lab0   := f_setLabel(lab0, "0", fib0, col0)
    lab236 := f_setLabel(lab236, "0.236", fib236, col236)
    lab382 := f_setLabel(lab382, "0.382", fib382, col382)
    lab50  := f_setLabel(lab50, "0.5", fib50, col50)
    lab618 := f_setLabel(lab618, "0.618", fib618, col618)
    lab786 := f_setLabel(lab786, "0.786", fib786, col786)
    lab1   := f_setLabel(lab1, "1", fib1, col1)

// =====================
// REFERENCE PANEL
// =====================
if barstate.islast
    if showInfoPanel
        table.clear(infoPanel, 0, 0, 1, 5)
        f_panelRow(0, f_txt("Period", "Periyot"), f_periodTxt())
        f_panelRow(1, f_txt("Current Zone", "Mevcut Bölge"), zoneText)
        f_panelRow(2, f_txt("Zone Range", "Bölge Aralığı"), zoneRangeText)
        f_panelRow(3, f_txt("Lower Reference", "Alt Referans"), f_price(lowerRef))
        f_panelRow(4, f_txt("Upper Reference", "Üst Referans"), f_price(upperRef))
        f_panelRow(5, f_txt("Diagonal Bias", "Diyagonal Eğilim"), diagBias)
    else
        table.clear(infoPanel, 0, 0, 1, 5)
````
