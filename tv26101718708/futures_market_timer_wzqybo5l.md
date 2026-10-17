# Futures Market Timer

- url: https://www.tradingview.com/script/WzqYbO5l-Futures-Market-Timer/
- type: indicator
- pine_id: PUB;07486f7af3a84087b3802b66923c7d32
- version: 5.0

## Description

Futures Market Timer displays estimated futures market open, close, and reopen countdowns using a simplified CME-style trading schedule. Includes weekend countdowns and alert conditions for upcoming closes and reopens.

For educational, informational, creative, and entertainment purposes only. Trading schedules vary by exchange, product, broker, holidays, and market conditions. No guarantee of accuracy is expressed or implied. [b]Users must independently verify all market hours and trading information before making any decisions.[/b]

## Source Code

````pine
//====================================================
// Futures Market Timer — v3.2 (Unified CT Market Logic)
//
// CME Globex holidays calculated algorithmically for
// ANY year. No manual updates ever needed.
//
// FULL CLOSE  : New Year's Day, Good Friday,
//               Thanksgiving, Christmas Day
// EARLY CLOSE : MLK Jr. Day, Presidents' Day,
//               Memorial Day, Juneteenth,
//               Independence Day, Labor Day,
//               Black Friday, Christmas Eve (weekdays)
//
// DISCLAIMER: CME finalises exact times ~2 weeks before
// each holiday. Verify at cmegroup.com/trading-hours
// Not financial advice.
//====================================================

//@version=6
indicator("Futures Timer", overlay=true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
timeZoneChoice = input.string("Central Time - Chicago", "Time Zone",
     options=["Eastern Time - New York", "Central Time - Chicago",
              "Mountain Time - Denver",  "Arizona Time - Phoenix",
              "Pacific Time - Los Angeles", "Alaska Time - Anchorage",
              "Hawaii Time - Honolulu"])

tz = timeZoneChoice == "Eastern Time - New York"    ? "America/New_York"    :
     timeZoneChoice == "Central Time - Chicago"     ? "America/Chicago"     :
     timeZoneChoice == "Mountain Time - Denver"     ? "America/Denver"      :
     timeZoneChoice == "Arizona Time - Phoenix"     ? "America/Phoenix"     :
     timeZoneChoice == "Pacific Time - Los Angeles" ? "America/Los_Angeles" :
     timeZoneChoice == "Alaska Time - Anchorage"    ? "America/Anchorage"   :
     "Pacific/Honolulu"

closeHour    = input.int(16, "Daily Close Hour (CT)",    minval=0, maxval=23, tooltip="CME close time in Central Time. Default: 16 = 4:00 PM CT.")
closeMinute  = input.int(0,  "Daily Close Minute (CT)",  minval=0, maxval=59)
reopenHour   = input.int(17, "Daily Reopen Hour (CT)",   minval=0, maxval=23, tooltip="CME reopen time in Central Time. Default: 17 = 5:00 PM CT.")
reopenMinute = input.int(0,  "Daily Reopen Minute (CT)", minval=0, maxval=59)
alertMinutes = input.int(15, "Alert Minutes Before Close", minval=1, maxval=240)

showTable       = input.bool(true, "Show Timer Table")
showWeekend     = input.bool(true, "Show Weekend Countdown")
showBgWhenClose = input.bool(true, "Shade Background When Closed (red)")
showHolidayBg   = input.bool(true, "Shade Background on Holidays (orange)")

// ─────────────────────────────────────────────
// TIME SETUP
//
// KEY DESIGN PRINCIPLE:
//   All market open/close TIMESTAMPS must be built
//   in CT ("America/Chicago") because CME times are
//   defined in CT. timenow is UTC-based so comparing
//   nowTime against a CT timestamp works correctly
//   regardless of the user's selected display timezone.
//
//   Y/M/D/DOW for holiday detection and market logic
//   are also derived from CT so the calendar date is
//   always correct (e.g. a Hawaii user past 6 PM CT
//   is still on the same CT calendar day).
//
//   Y_disp/M_disp/D_disp use the user's local tz
//   only for display purposes (not used in any
//   timestamp() or market-state calculations).
// ─────────────────────────────────────────────
MS_MIN  = 60 * 1000
MS_HR   = 60 * MS_MIN
MS_DAY  = 24 * MS_HR

CT = "America/Chicago"   // all market timestamps built in CT

nowTime = timenow

// CT calendar — used for ALL market logic and holiday detection
Y   = year(nowTime, CT)
M   = month(nowTime, CT)
D   = dayofmonth(nowTime, CT)
DOW = dayofweek(nowTime, CT)

isSun     = DOW == dayofweek.sunday
isMon     = DOW == dayofweek.monday
isTue     = DOW == dayofweek.tuesday
isWed     = DOW == dayofweek.wednesday
isThu     = DOW == dayofweek.thursday
isFri     = DOW == dayofweek.friday
isSat     = DOW == dayofweek.saturday
isWeekday = isMon or isTue or isWed or isThu

// All timestamps stamped in CT — CME close is 4 PM CT, reopen 5 PM CT
// closeHour/reopenHour inputs are CT hours (defaults 16 / 17)
todayClose  = timestamp(CT, Y, M, D, closeHour, closeMinute)
todayReopen = timestamp(CT, Y, M, D, reopenHour, reopenMinute)
earlyCloseT = timestamp(CT, Y, M, D, 12, 0)

// ─────────────────────────────────────────────
// HELPER: Zeller's Congruence
// Returns 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
// ─────────────────────────────────────────────
f_zeller(y, m, d) =>
    zm = m < 3 ? m + 12 : m
    zy = m < 3 ? y - 1  : y
    zk = zy % 100
    zj = math.floor(zy / 100)
    zh = (d + math.floor(13 * (zm + 1) / 5) + zk + math.floor(zk / 4) + math.floor(zj / 4) - 2 * zj) % 7
    (zh + 6) % 7

// ─────────────────────────────────────────────
// HELPER: Nth weekday of a month (n=-1 = last)
// ─────────────────────────────────────────────
f_nthWD(y, m, wd, n) =>
    result = 0
    if n > 0
        d1   = f_zeller(y, m, 1)
        diff = (wd - d1 + 7) % 7
        result := 1 + diff + (n - 1) * 7
    else
        isLeap  = y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)
        febDays = isLeap ? 29 : 28
        lastDay = m == 2 ? febDays : (m == 4 or m == 6 or m == 9 or m == 11) ? 30 : 31
        dLast   = f_zeller(y, m, lastDay)
        diff    = (dLast - wd + 7) % 7
        result  := lastDay - diff
    result

// ─────────────────────────────────────────────
// HELPER: Easter Sunday (Anonymous Gregorian)
// ─────────────────────────────────────────────
f_easter(y) =>
    ea = y % 19
    eb = math.floor(y / 100)
    ec = y % 100
    ed = math.floor(eb / 4)
    ee = eb % 4
    ef = math.floor((eb + 8) / 25)
    eg = math.floor((eb - ef + 1) / 3)
    eh = (19 * ea + eb - ed - eg + 15) % 30
    ei = math.floor(ec / 4)
    ek = ec % 4
    el = (32 + 2 * ee + 2 * ei - eh - ek) % 7
    em = math.floor((ea + 11 * eh + 22 * el) / 451)
    eMo = math.floor((eh + el - 7 * em + 114) / 31)
    eDa = (eh + el - 7 * em + 114) % 31 + 1
    [eMo, eDa]

// ─────────────────────────────────────────────
// HELPER: Format milliseconds as countdown string
// ─────────────────────────────────────────────
f_timeLeft(ms) =>
    s  = math.max(ms, 0)
    td = math.floor(s / MS_DAY)
    r1 = s - td * MS_DAY
    th = math.floor(r1 / MS_HR)
    r2 = r1 - th * MS_HR
    tm = math.floor(r2 / MS_MIN)
    td > 0 ? str.tostring(td) + "d " + str.tostring(th) + "h " + str.tostring(tm) + "m" : str.tostring(th) + "h " + str.tostring(tm) + "m"

// ─────────────────────────────────────────────
// HOLIDAY DATE CALCULATIONS
// ─────────────────────────────────────────────
WD_MON = 1
WD_THU = 4

ny_wd    = f_zeller(Y, 1, 1)
ny_day   = ny_wd == 0 ? 2 : 1
isNewYear = M == 1 and D == ny_day and not (ny_wd == 6)

mlk_day = f_nthWD(Y, 1, WD_MON, 3)
isMLK   = M == 1 and D == mlk_day

pres_day      = f_nthWD(Y, 2, WD_MON, 3)
isPresidents  = M == 2 and D == pres_day

[eMo, eDa]   = f_easter(Y)
gf_day        = eDa - 2
gf_mon        = eMo
gf_day_safe   = gf_day < 1 ? 31 + gf_day : gf_day
gf_mon_safe   = gf_day < 1 ? eMo - 1 : eMo
isGoodFriday  = M == gf_mon_safe and D == gf_day_safe

mem_day    = f_nthWD(Y, 5, WD_MON, -1)
isMemorial = M == 5 and D == mem_day

jun_wd       = f_zeller(Y, 6, 19)
jun_day      = jun_wd == 0 ? 20 : jun_wd == 6 ? 18 : 19
isJuneteenth = M == 6 and D == jun_day

jul_wd  = f_zeller(Y, 7, 4)
jul_day = jul_wd == 0 ? 5 : jul_wd == 6 ? 3 : 4
isJuly4 = M == 7 and D == jul_day

lab_day = f_nthWD(Y, 9, WD_MON, 1)
isLabor = M == 9 and D == lab_day

tg_day         = f_nthWD(Y, 11, WD_THU, 4)
isThanksgiving = M == 11 and D == tg_day

isBlackFriday = M == 11 and D == tg_day + 1

xe_wd          = f_zeller(Y, 12, 24)
isChristmasEve = M == 12 and D == 24 and xe_wd >= 1 and xe_wd <= 5

xm_wd      = f_zeller(Y, 12, 25)
xm_day     = xm_wd == 0 ? 26 : xm_wd == 6 ? 24 : 25
isChristmas = M == 12 and D == xm_day

// ─────────────────────────────────────────────
// AGGREGATE FLAGS
// ─────────────────────────────────────────────
isFullClose  = isNewYear or isGoodFriday or isThanksgiving or isChristmas
isEarlyClose = isMLK or isPresidents or isMemorial or isJuneteenth or isJuly4 or isLabor or isBlackFriday or (isChristmasEve and not isChristmas)
isHoliday    = isFullClose or isEarlyClose

holidayName = isNewYear ? "New Year's Day" : isMLK ? "MLK Jr. Day" : isPresidents ? "Presidents' Day" : isGoodFriday ? "Good Friday" : isMemorial ? "Memorial Day" : isJuneteenth ? "Juneteenth" : isJuly4 ? "Independence Day" : isLabor ? "Labor Day" : isThanksgiving ? "Thanksgiving" : isBlackFriday ? "Black Friday" : isChristmasEve ? "Christmas Eve" : isChristmas ? "Christmas Day" : ""
holidayType = isFullClose ? "Full Close" : isEarlyClose ? "Early Close 12 PM CT" : ""

holidayOnFri = isHoliday and isFri
holidayOnSat = isHoliday and isSat

daysToSun = isFri ? 2 : isSat ? 1 : 0
sundayReopen = timestamp(CT, Y, M, D + daysToSun, reopenHour, reopenMinute)

// ─────────────────────────────────────────────
// MARKET OPEN LOGIC
// ─────────────────────────────────────────────
marketOpen = isFullClose ? false : isEarlyClose and holidayOnFri ? nowTime < earlyCloseT : isEarlyClose ? (nowTime < earlyCloseT or nowTime >= todayReopen) : isSun ? nowTime >= todayReopen : isWeekday ? not (nowTime >= todayClose and nowTime < todayReopen) : isFri ? nowTime < todayClose : false

// ─────────────────────────────────────────────
// NEXT CLOSE / REOPEN TIMESTAMPS
// ─────────────────────────────────────────────
nextClose = marketOpen and isEarlyClose ? earlyCloseT : marketOpen and isSun ? timestamp(CT, Y, M, D+1, closeHour, closeMinute) : marketOpen and isWeekday and nowTime < todayClose ? todayClose : marketOpen and isWeekday and nowTime >= todayReopen ? timestamp(CT, Y, M, D+1, closeHour, closeMinute) : marketOpen and isFri ? todayClose : na

nextReopen = not marketOpen and (isFullClose or isEarlyClose) and holidayOnFri ? sundayReopen : not marketOpen and (isFullClose or isEarlyClose) ? todayReopen : not marketOpen and isSun ? todayReopen : not marketOpen and isWeekday and nowTime >= todayClose and nowTime < todayReopen ? todayReopen : not marketOpen and isFri ? timestamp(CT, Y, M, D+2, reopenHour, reopenMinute) : not marketOpen and isSat ? timestamp(CT, Y, M, D+1, reopenHour, reopenMinute) : na

// ─────────────────────────────────────────────
// TIMEZONE-AWARE TIME LABEL HELPERS
//
// CME canonical times are in CT. We convert to the
// selected display timezone using a fixed hour offset.
//
// Standard offsets from CT (ignoring DST edge cases
// since CME times are always quoted in CT and users
// should verify at cmegroup.com for DST transitions):
//   ET  = CT + 1
//   MT  = CT - 1
//   AZT = CT - 1  (no DST observed)
//   PT  = CT - 2
//   AKT = CT - 3
//   HT  = CT - 5
//
// NOTE: During DST transitions (spring-forward /
// fall-back) the offset between time zones can shift
// by ±1 hour for a brief window. Always verify exact
// times at cmegroup.com/trading-hours during those weeks.
// ─────────────────────────────────────────────
tzOffset =
     timeZoneChoice == "Eastern Time - New York"    ?  1 :
     timeZoneChoice == "Central Time - Chicago"     ?  0 :
     timeZoneChoice == "Mountain Time - Denver"     ? -1 :
     timeZoneChoice == "Arizona Time - Phoenix"     ? -1 :
     timeZoneChoice == "Pacific Time - Los Angeles" ? -2 :
     timeZoneChoice == "Alaska Time - Anchorage"    ? -3 : -5   // Hawaii

// Abbreviation for the selected timezone
tzAbbr =
     timeZoneChoice == "Eastern Time - New York"    ? "ET"  :
     timeZoneChoice == "Central Time - Chicago"     ? "CT"  :
     timeZoneChoice == "Mountain Time - Denver"     ? "MT"  :
     timeZoneChoice == "Arizona Time - Phoenix"     ? "AZT" :
     timeZoneChoice == "Pacific Time - Los Angeles" ? "PT"  :
     timeZoneChoice == "Alaska Time - Anchorage"    ? "AKT" : "HT"

// Convert a CT hour (24h) to a display string like "4 PM ET"
// Wraps correctly across midnight boundaries
f_tzLabel(ctHour) =>
    raw  = ctHour + tzOffset
    h24  = raw < 0 ? raw + 24 : raw > 23 ? raw - 24 : raw
    ampm = h24 >= 12 ? "PM" : "AM"
    h12  = h24 == 0 ? 12 : h24 > 12 ? h24 - 12 : h24
    str.tostring(h12) + " " + ampm + " " + tzAbbr

// CME canonical hours in CT
CT_CLOSE      = 16   // 4:00 PM CT
CT_REOPEN     = 17   // 5:00 PM CT
CT_EARLY      = 12   // 12:00 PM CT (early close)

closeLabel      = f_tzLabel(CT_CLOSE)    // e.g. "4 PM ET", "2 PM PT"
reopenLabel_tz  = f_tzLabel(CT_REOPEN)  // e.g. "5 PM ET", "3 PM PT"
earlyCloseLabel = f_tzLabel(CT_EARLY)   // e.g. "1 PM ET", "10 AM PT"

// ─────────────────────────────────────────────
// DISPLAY STRINGS — all times now use local TZ labels
// ─────────────────────────────────────────────
timeToClose = not na(nextClose)  ? nextClose  - nowTime : na
timeToOpen  = not na(nextReopen) ? nextReopen - nowTime : na

statusText = isFullClose ? "CLOSED — " + holidayName : isEarlyClose and not marketOpen ? "CLOSED — " + holidayName : marketOpen ? "FUTURES OPEN" : "FUTURES CLOSED"

// Reopen label adapts to both TZ and Friday holiday routing
reopenLabel     = holidayOnFri ? "Reopens Sunday " + reopenLabel_tz : "Reopens today at " + reopenLabel_tz
scheduleReopens = holidayOnFri ? "reopens Sunday " + reopenLabel_tz : "reopens today " + reopenLabel_tz

timerText = isFullClose and holidayOnFri ? reopenLabel + " (" + f_timeLeft(timeToOpen) + ")" : isFullClose ? reopenLabel : isEarlyClose and marketOpen and nowTime < earlyCloseT ? "⚠ Early close in: " + f_timeLeft(timeToClose) : isEarlyClose and not marketOpen and holidayOnFri ? "Sunday open in: " + f_timeLeft(timeToOpen) : isEarlyClose and not marketOpen ? "Reopens in: " + f_timeLeft(timeToOpen) : marketOpen ? "Closes in: " + f_timeLeft(timeToClose) : showWeekend and (isFri or isSat) ? "Sunday open in: " + f_timeLeft(timeToOpen) : "Reopens in: " + f_timeLeft(timeToOpen)

// Schedule row: uses local TZ labels throughout
scheduleText = isHoliday ? holidayType + " — " + scheduleReopens : marketOpen ? "Next close: " + closeLabel : showWeekend and (isFri or isSat) ? "Next open: Sunday " + reopenLabel_tz : "Next open: " + reopenLabel_tz

// Footer: CME Globex times shown in selected timezone
footerText = isHoliday ? "⚠ Verify at cmegroup.com/trading-hours" : "CME Globex: " + closeLabel + " close / " + reopenLabel_tz + " reopen"

holidayRow = isHoliday ? holidayName + " — " + holidayType : " "

// ─────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────
statusBg   = isFullClose ? color.new(color.orange, 10) : isEarlyClose and not marketOpen ? color.new(color.orange, 30) : marketOpen ? color.new(color.green, 20) : color.new(color.red, 20)
timerColor = isEarlyClose and marketOpen ? color.orange : color.white

var table t = table.new(position.top_right, 1, 5, border_width=1)

if showTable and barstate.islast
    table.cell(t, 0, 0, statusText,   text_color=color.white,                                      bgcolor=statusBg)
    table.cell(t, 0, 1, timerText,    text_color=timerColor,                                       bgcolor=color.new(color.black, 20))
    table.cell(t, 0, 2, scheduleText, text_color=color.white,                                      bgcolor=color.new(color.gray, 55))
    table.cell(t, 0, 3, holidayRow,   text_color=isHoliday ? color.orange : color.gray,            bgcolor=color.new(color.black, 40))
    table.cell(t, 0, 4, footerText,   text_color=isHoliday ? color.orange : color.white,           bgcolor=color.new(color.gray, 70))

// ─────────────────────────────────────────────
// BACKGROUND SHADING
// ─────────────────────────────────────────────
bgcolor(showHolidayBg  and isFullClose                       ? color.new(color.orange, 85) : na)
bgcolor(showHolidayBg  and isEarlyClose and not marketOpen   ? color.new(color.orange, 92) : na)
bgcolor(showBgWhenClose and not marketOpen and not isHoliday ? color.new(color.red,    90) : na)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
closingSoon    = marketOpen and not na(timeToClose) and timeToClose <= alertMinutes * MS_MIN and timeToClose > 0
earlyCloseSoon = isEarlyClose and closingSoon
justClosed     = not marketOpen and marketOpen[1]
justOpened     = marketOpen and not marketOpen[1]
holidayAlert   = isHoliday and not isHoliday[1]

alertcondition(closingSoon,    "Futures Closing Soon",     "Futures market is closing soon.")
alertcondition(earlyCloseSoon, "Holiday Early Close Soon", "Holiday early close approaching.")
alertcondition(justClosed,     "Futures Closed",           "Futures market is now closed.")
alertcondition(justOpened,     "Futures Reopened",         "Futures market has reopened.")
alertcondition(holidayAlert,   "CME Holiday Today",        "CME holiday — check timer for details.")

if closingSoon and not earlyCloseSoon
    alert("Futures closes in " + str.tostring(alertMinutes) + " min", alert.freq_once_per_bar)
if earlyCloseSoon
    alert("⚠ " + holidayName + " early close in " + str.tostring(alertMinutes) + " min", alert.freq_once_per_bar)
if justClosed
    alert("Futures market is now closed", alert.freq_once_per_bar)
if justOpened
    alert("Futures market has reopened", alert.freq_once_per_bar)
if holidayAlert
    alert("⚠ CME Holiday: " + holidayName + " — " + holidayType, alert.freq_once_per_bar)
````
