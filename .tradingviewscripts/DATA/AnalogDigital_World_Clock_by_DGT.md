<!-- tradingview-pine-id: PUB;K3KHtfgrL8E45d8qD4gR70ukcVnDyWUa -->
<!-- tradingviewscripts-format: 1 -->
# Analog/Digital World Clock by DGT

Source: https://www.tradingview.com/script/QH7jc8Tx-Analog-Digital-World-Clock-by-DGT/

## Description

World Clocks - something for fun 

Happy New Year!

ps: in case no update on the charts then the clock will not update too and will lag or stop till a new update is received

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : Analog / Digital World Clock
//# * Author      : © dgtrd
//# *
//# * Revision History
//# *  Release    : Dec 21, 2020
//# *  Update     : Dec 24, 2020 : added forex market sessions
//# *  Update     : Jan 12, 2021 : presented samples of @midtownsk8rguy's approach for the same purpose
//# *  Update     : Dec 20, 2021 : Pine v5 adaptation, replaced labels with a table
//# *  Update     : Mar 29, 2026 : migrated to Pine v6, IANA timezone support, DST handled automatically
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator('Analog/Digital World Clock by DGT', 'CLOCK ☼☾', max_lines_count = 156, max_bars_back = 500)

display = display.all - display.status_line

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Timezone Enum

enum utcOffsets
    EXCHANGE             = 'Exchange'
    // Major Global Trading Centers
    UTCm5_New_York       = 'America/New_York'
    UTC0_London          = 'Europe/London'
    UTCp9_Tokyo          = 'Asia/Tokyo'
    UTCp10_Sydney        = 'Australia/Sydney'
    UTCp4_Dubai          = 'Asia/Dubai'
    UTCp1_Berlin         = 'Europe/Berlin'
    UTCp1_Paris          = 'Europe/Paris'
    UTCp3_Istanbul       = 'Europe/Istanbul'
    UTCm6_Chicago        = 'America/Chicago'
    UTCm8_Los_Angeles    = 'America/Los_Angeles'
    UTCp8_Singapore      = 'Asia/Singapore'
    UTCp8_Shanghai       = 'Asia/Shanghai'
    UTCp9_Seoul          = 'Asia/Seoul'
    // Americas
    UTCm5_Toronto        = 'America/Toronto'
    UTCm8_Vancouver      = 'America/Vancouver'
    UTCm8_Tijuana        = 'America/Tijuana'
    UTCm7_Denver         = 'America/Denver'
    UTCm7_Edmonton       = 'America/Edmonton'
    UTCm6_Mexico_City    = 'America/Mexico_City'
    UTCm6_Winnipeg       = 'America/Winnipeg'
    UTCm5_Lima           = 'America/Lima'
    UTCm5_Bogota         = 'America/Bogota'
    UTCm5_Jamaica        = 'America/Jamaica'
    UTCm4_Santiago       = 'America/Santiago'
    UTCm4_Manaus         = 'America/Manaus'
    UTCm4_La_Paz         = 'America/La_Paz'
    UTCm4_Santo_Domingo  = 'America/Santo_Domingo'
    UTCm3p30_St_Johns    = 'America/St_Johns'
    UTCm3_Sao_Paulo      = 'America/Sao_Paulo'
    UTCm3_Buenos_Aires   = 'America/Argentina/Buenos_Aires'
    UTCm3_Montevideo     = 'America/Montevideo'
    UTCm9_Anchorage      = 'America/Anchorage'
    UTCm10_Honolulu      = 'Pacific/Honolulu'
    // Europe
    UTC0_Lisbon          = 'Europe/Lisbon'
    UTCp1_Madrid         = 'Europe/Madrid'
    UTCp1_Warsaw         = 'Europe/Warsaw'
    UTCp2_Kyiv           = 'Europe/Kyiv'
    UTCp2_Athens         = 'Europe/Athens'
    UTCp3_Moscow         = 'Europe/Moscow'
    UTCp4_Samara         = 'Europe/Samara'
    // Middle East
    UTCp3_Riyadh         = 'Asia/Riyadh'
    UTCp3_Baghdad        = 'Asia/Baghdad'
    UTCp3p30_Tehran      = 'Asia/Tehran'
    UTCp4_Baku           = 'Asia/Baku'
    UTCp4_Yerevan        = 'Asia/Yerevan'
    UTCp4p30_Kabul       = 'Asia/Kabul'
    UTCp2_Jerusalem      = 'Asia/Jerusalem'
    // Asia
    UTCp5_Karachi        = 'Asia/Karachi'
    UTCp5_Tashkent       = 'Asia/Tashkent'
    UTCp5p30_Mumbai      = 'Asia/Kolkata'
    UTCp5p30_Colombo     = 'Asia/Colombo'
    UTCp5p45_Kathmandu   = 'Asia/Kathmandu'
    UTCp6_Dhaka          = 'Asia/Dhaka'
    UTCp6_Almaty         = 'Asia/Almaty'
    UTCp6p30_Yangon      = 'Asia/Yangon'
    UTCp7_Jakarta        = 'Asia/Jakarta'
    UTCp7_Bangkok        = 'Asia/Bangkok'
    UTCp7_Krasnoyarsk    = 'Asia/Krasnoyarsk'
    UTCp8_Taipei         = 'Asia/Taipei'
    UTCp8_Kuala_Lumpur   = 'Asia/Kuala_Lumpur'
    UTCp8_Manila         = 'Asia/Manila'
    UTCp8_Perth          = 'Australia/Perth'
    UTCp9_Pyongyang      = 'Asia/Pyongyang'
    UTCp10_Vladivostok   = 'Asia/Vladivostok'
    UTCp11_Magadan       = 'Asia/Magadan'
    UTCp12_Kamchatka     = 'Asia/Kamchatka'
    // Oceania
    UTCp9p30_Adelaide    = 'Australia/Adelaide'
    UTCp10_Port_Moresby  = 'Pacific/Port_Moresby'
    UTCp11_Noumea        = 'Pacific/Noumea'
    UTCp12_Auckland      = 'Pacific/Auckland'
    UTCp12_Fiji          = 'Pacific/Fiji'
    UTCp14_Kiritimati    = 'Pacific/Kiritimati'
    // Africa
    UTC0_Accra           = 'Africa/Accra'
    UTC0_Casablanca      = 'Africa/Casablanca'
    UTCp1_Lagos          = 'Africa/Lagos'
    UTCp1_Algiers        = 'Africa/Algiers'
    UTCp2_Cairo          = 'Africa/Cairo'
    UTCp2_Johannesburg   = 'Africa/Johannesburg'
    UTCp3_Addis_Ababa    = 'Africa/Addis_Ababa'

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Inputs

i_tz = input.enum(utcOffsets.UTCp3_Istanbul, 'City / Timezone', group = 'Time Settings', display = display)

i_forex = input.bool(false, 'Forex Sessions', group = 'Forex Sessions',
     tooltip = 'Displays major forex market sessions with real-time open/close status.\n\n' +
         'Includes Sydney, Tokyo, London, and New York.')

i_mono = input.bool(true, 'Monochrome', group = 'Appearance')
i_animate = input.bool(false, 'Animated Clock Ring', group = 'Appearance')
i_textSize = input.string('Small', 'Text Size', options = ['Tiny', 'Small', 'Normal'], group = 'Appearance', inline = 'AHA', display = display)


// ── Ring color pairs ───────────────────────────────────────────────────────────────────────────── //

textSize = i_textSize == 'Small' ? size.small : i_textSize == 'Normal' ? size.normal : size.tiny

i_color1 = i_mono ? color.new(#90A4AE, 20) : #26C6DA
i_color2 = i_mono ? color.new(#607D8B, 20) : #006064

i_color3 = i_mono ? color.new(#CFD8DC, 20) : #FFB300
i_color4 = i_mono ? color.new(#B0BEC5, 20) : #FF6F00

i_handColor = color.new(chart.fg_color, 50)
i_secColor  = #FF1744

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// City Display Name

f_cityName(_tz) =>
    switch _tz
        utcOffsets.EXCHANGE            => syminfo.timezone
        utcOffsets.UTCm5_New_York      => 'NEW YORK'
        utcOffsets.UTC0_London         => 'LONDON'
        utcOffsets.UTCp9_Tokyo         => 'TOKYO'
        utcOffsets.UTCp10_Sydney       => 'SYDNEY'
        utcOffsets.UTCp4_Dubai         => 'DUBAI'
        utcOffsets.UTCp1_Berlin        => 'BERLIN'
        utcOffsets.UTCp1_Paris         => 'PARIS'
        utcOffsets.UTCp3_Istanbul      => 'ISTANBUL'
        utcOffsets.UTCm6_Chicago       => 'CHICAGO'
        utcOffsets.UTCm8_Los_Angeles   => 'LOS ANGELES'
        utcOffsets.UTCp8_Singapore     => 'SINGAPORE'
        utcOffsets.UTCp8_Shanghai      => 'SHANGHAI'
        utcOffsets.UTCp9_Seoul         => 'SEOUL'
        utcOffsets.UTCm5_Toronto       => 'TORONTO'
        utcOffsets.UTCm8_Vancouver     => 'VANCOUVER'
        utcOffsets.UTCm8_Tijuana       => 'TIJUANA'
        utcOffsets.UTCm7_Denver        => 'DENVER'
        utcOffsets.UTCm7_Edmonton      => 'EDMONTON'
        utcOffsets.UTCm6_Mexico_City   => 'MEXICO CITY'
        utcOffsets.UTCm6_Winnipeg      => 'WINNIPEG'
        utcOffsets.UTCm5_Lima          => 'LIMA'
        utcOffsets.UTCm5_Bogota        => 'BOGOTA'
        utcOffsets.UTCm5_Jamaica       => 'KINGSTON'
        utcOffsets.UTCm4_Santiago      => 'SANTIAGO'
        utcOffsets.UTCm4_Manaus        => 'MANAUS'
        utcOffsets.UTCm4_La_Paz        => 'LA PAZ'
        utcOffsets.UTCm4_Santo_Domingo => 'SANTO DOMINGO'
        utcOffsets.UTCm3p30_St_Johns   => 'ST. JOHN\'S'
        utcOffsets.UTCm3_Sao_Paulo     => 'SAO PAULO'
        utcOffsets.UTCm3_Buenos_Aires  => 'BUENOS AIRES'
        utcOffsets.UTCm3_Montevideo    => 'MONTEVIDEO'
        utcOffsets.UTCm9_Anchorage     => 'ANCHORAGE'
        utcOffsets.UTCm10_Honolulu     => 'HONOLULU'
        utcOffsets.UTC0_Lisbon         => 'LISBON'
        utcOffsets.UTCp1_Madrid        => 'MADRID'
        utcOffsets.UTCp1_Warsaw        => 'WARSAW'
        utcOffsets.UTCp2_Kyiv          => 'KYIV'
        utcOffsets.UTCp2_Athens        => 'ATHENS'
        utcOffsets.UTCp3_Moscow        => 'MOSCOW'
        utcOffsets.UTCp4_Samara        => 'SAMARA'
        utcOffsets.UTCp3_Riyadh        => 'RIYADH'
        utcOffsets.UTCp3_Baghdad       => 'BAGHDAD'
        utcOffsets.UTCp3p30_Tehran     => 'TEHRAN'
        utcOffsets.UTCp4_Baku          => 'BAKU'
        utcOffsets.UTCp4_Yerevan       => 'YEREVAN'
        utcOffsets.UTCp4p30_Kabul      => 'KABUL'
        utcOffsets.UTCp2_Jerusalem     => 'JERUSALEM'
        utcOffsets.UTCp5_Karachi       => 'KARACHI'
        utcOffsets.UTCp5_Tashkent      => 'TASHKENT'
        utcOffsets.UTCp5p30_Mumbai     => 'MUMBAI'
        utcOffsets.UTCp5p30_Colombo    => 'COLOMBO'
        utcOffsets.UTCp5p45_Kathmandu  => 'KATHMANDU'
        utcOffsets.UTCp6_Dhaka         => 'DHAKA'
        utcOffsets.UTCp6_Almaty        => 'ALMATY'
        utcOffsets.UTCp6p30_Yangon     => 'YANGON'
        utcOffsets.UTCp7_Jakarta       => 'JAKARTA'
        utcOffsets.UTCp7_Bangkok       => 'BANGKOK'
        utcOffsets.UTCp7_Krasnoyarsk   => 'KRASNOYARSK'
        utcOffsets.UTCp8_Taipei        => 'TAIPEI'
        utcOffsets.UTCp8_Kuala_Lumpur  => 'KUALA LUMPUR'
        utcOffsets.UTCp8_Manila        => 'MANILA'
        utcOffsets.UTCp8_Perth         => 'PERTH'
        utcOffsets.UTCp9_Pyongyang     => 'PYONGYANG'
        utcOffsets.UTCp10_Vladivostok  => 'VLADIVOSTOK'
        utcOffsets.UTCp11_Magadan      => 'MAGADAN'
        utcOffsets.UTCp12_Kamchatka    => 'KAMCHATKA'
        utcOffsets.UTCp9p30_Adelaide   => 'ADELAIDE'
        utcOffsets.UTCp10_Port_Moresby => 'PORT MORESBY'
        utcOffsets.UTCp11_Noumea       => 'NOUMEA'
        utcOffsets.UTCp12_Auckland     => 'AUCKLAND'
        utcOffsets.UTCp12_Fiji         => 'SUVA'
        utcOffsets.UTCp14_Kiritimati   => 'KIRITIMATI'
        utcOffsets.UTC0_Accra          => 'ACCRA'
        utcOffsets.UTC0_Casablanca     => 'CASABLANCA'
        utcOffsets.UTCp1_Lagos         => 'LAGOS'
        utcOffsets.UTCp1_Algiers       => 'ALGIERS'
        utcOffsets.UTCp2_Cairo         => 'CAIRO'
        utcOffsets.UTCp2_Johannesburg  => 'JOHANNESBURG'
        utcOffsets.UTCp3_Addis_Ababa   => 'ADDIS ABABA'
        => str.tostring(_tz)

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Forex Session Hours

f_forexHours(_tz) =>
    switch _tz
        utcOffsets.UTCp10_Sydney  => [8,  17]
        utcOffsets.UTCp9_Tokyo    => [9,  18]
        utcOffsets.UTC0_London    => [8,  17]
        utcOffsets.UTCm5_New_York => [8,  17]
        => [int(na), int(na)]

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Time Function — IANA native, DST automatic

f_whatIsTheTime(_tz) =>
    tz = _tz == utcOffsets.EXCHANGE ? syminfo.timezone : str.tostring(_tz)
    [
     hour(timenow, tz),
     minute(timenow, tz),
     second(timenow, tz),
     dayofmonth(timenow, tz),
     month(timenow, tz),
     year(timenow, tz),
     dayofweek(timenow, tz)]

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Digital Display

f_pad(_n) => _n < 10 ? '0' + str.tostring(_n) : str.tostring(_n)

f_digitalDisplay(_tz, _marketDetails) =>
    [h, m, s, D, M, Y, A] = f_whatIsTheTime(_tz)

    dateTime = f_pad(D) + '/' + f_pad(M) + '/' + str.tostring(Y) + '  ' + f_pad(h) + ':' + f_pad(m) + ':' + f_pad(s)

    if _marketDetails
        [fxO, fxC] = f_forexHours(_tz)

        if na(fxO)
            dateTime
        else
            currentSec = h * 3600 + m * 60 + s
            openSec    = fxO * 3600
            closeSec   = fxC * 3600
            isWeekday  = A != 1 and A != 7
        
            isOpen = isWeekday and currentSec >= openSec and currentSec < closeSec
        
            if isOpen
                closeInSec = closeSec - currentSec
                hc = math.floor(closeInSec / 3600)
                mc = math.floor(closeInSec % 3600 / 60)
                sc = closeInSec % 60
                dateTime + '  🟢 Closes in ' + f_pad(hc) + ':' + f_pad(mc) + ':' + f_pad(sc)
            else if not isWeekday
                openInSec = currentSec < openSec ? openSec - currentSec : 86400 - currentSec + openSec
                ho = math.floor(openInSec / 3600)
                mo = math.floor(openInSec % 3600 / 60)
                so = openInSec % 60
                if openInSec > 3600
                    dateTime + '  🟠 Weekend'
                else
                    dateTime + '  🔴 Opens in ' + f_pad(ho) + ':' + f_pad(mo) + ':' + f_pad(so)
            else
                openInSec = currentSec < openSec ? openSec - currentSec : 86400 - currentSec + openSec
                ho = math.floor(openInSec / 3600)
                mo = math.floor(openInSec % 3600 / 60)
                so = openInSec % 60
                if A == 6 and currentSec >= closeSec
                    dateTime + '  🟠 Weekend'
                else
                    dateTime + '  🔴 Opens in ' + f_pad(ho) + ':' + f_pad(mo) + ':' + f_pad(so)
    else
        dateTime

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Digital Clock Label

f_digitalClock(_x, _y, _style, _textcolor, _tz, _marketDetails) =>
    var label digitalClock = label.new(0, _y, text = '', color = #00000000, xloc = xloc.bar_index, style = _style, textcolor = _textcolor, size = textSize, text_font_family = font.family_monospace)
    label.set_text(digitalClock, f_cityName(_tz) + '\n' + f_digitalDisplay(_tz, _marketDetails))
    label.set_xy(digitalClock, bar_index[_x], _y)

f_digitalClock(15, 17, label.style_label_down, chart.fg_color, i_tz, false)

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Forex Table

var table clock = table.new(position.middle_right, 2, 4, border_width = 3)

baseColor = i_mono ? #B0BEC5 : #1AA3B5

bg1 = color.new(baseColor, 85)
bg2 = color.new(baseColor, 80)
bg3 = color.new(baseColor, 75)
bg4 = color.new(baseColor, 70)


if barstate.islast and (i_forex or syminfo.type == 'forex')

    table.cell(clock, 0, 0, f_cityName(utcOffsets.UTCp10_Sydney),
        text_color = chart.fg_color, bgcolor = bg1, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)
    table.cell(clock, 1, 0, f_digitalDisplay(utcOffsets.UTCp10_Sydney, true),
        text_color = chart.fg_color, bgcolor = bg1, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)

    table.cell(clock, 0, 1, f_cityName(utcOffsets.UTCp9_Tokyo),
        text_color = chart.fg_color, bgcolor = bg2, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)
    table.cell(clock, 1, 1, f_digitalDisplay(utcOffsets.UTCp9_Tokyo, true),
        text_color = chart.fg_color, bgcolor = bg2, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)

    table.cell(clock, 0, 2, f_cityName(utcOffsets.UTC0_London),
        text_color = chart.fg_color, bgcolor = bg3, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)
    table.cell(clock, 1, 2, f_digitalDisplay(utcOffsets.UTC0_London, true),
        text_color = chart.fg_color, bgcolor = bg3, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)

    table.cell(clock, 0, 3, f_cityName(utcOffsets.UTCm5_New_York),
        text_color = chart.fg_color, bgcolor = bg4, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)
    table.cell(clock, 1, 3, f_digitalDisplay(utcOffsets.UTCm5_New_York, true),
        text_color = chart.fg_color, bgcolor = bg4, text_halign = text.align_left, text_size = textSize, text_font_family = font.family_monospace)

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Analog Clock Setup

var a_linePointY  = array.new_float()
var a_linePointY2 = array.new_float()
var a_analogClock = array.new_line()

clockDiameter = 15
barTime       = time

if barstate.isfirst
    angle = 6
    for i = 0 to clockDiameter - 1
        a_linePointY2.push(math.tan(i * angle * 2.0 * math.asin(1.0) / 180))
    a_linePointY2.push(13)

    for v in array.from(0.0, 0.1, 0.27, 0.55, 0.85, 1.25, 1.7, 2.3, 3.0, 3.8, 4.8, 6.0, 7.6, 9.6, 13.0, 15.1,
                        0.0, 0.1, 0.27, 0.55, 0.85, 1.25, 1.7, 2.3, 3.0, 3.8, 4.8, 6.0, 7.6, 9.6, 13.0, 15.1)
        a_linePointY.push(v)


[hourHand, minuteHand, secondHand, _, _, _, _] = f_whatIsTheTime(i_tz)

if timeframe.change(timeframe.period) and a_analogClock.size() > 0
    for i = a_analogClock.size() to 1
        line.delete(a_analogClock.shift())

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
// Analog Clock Drawing

if barstate.islast

    // ── Animation state ───────────────────────────────────────────────────────────────────────── //
    varip bool switchColor = true
    switchColor := not switchColor

    color1 = i_animate ? (switchColor ? i_color1 : i_color3) : i_color1
    color2 = i_animate ? (switchColor ? i_color2 : i_color4) : i_color2
    color3 = i_animate ? (switchColor ? i_color3 : i_color1) : i_color3
    color4 = i_animate ? (switchColor ? i_color4 : i_color2) : i_color4

    // ── Clock ring — Pythagorean circle ───────────────────────────────────────────────────────── //

    for i = 0 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[clockDiameter + i], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(i, 2)), barTime[clockDiameter + i + 1], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(i + 1, 2)), xloc.bar_time, extend.both, color1, line.style_dotted, 1))
    for i = 0 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[clockDiameter + i], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(i, 2)), barTime[clockDiameter + i + 1], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(i + 1, 2)), xloc.bar_time, extend.both, color2, line.style_dotted, 1))
    for i = 0 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[clockDiameter + i], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(i, 2)), barTime[clockDiameter + i + 1], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(i + 1, 2)), xloc.bar_time, extend.none, color1, line.style_solid, 1))
    for i = 0 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[clockDiameter + i], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(i, 2)), barTime[clockDiameter + i + 1], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(i + 1, 2)), xloc.bar_time, extend.none, color2, line.style_solid, 1))
    for i = 1 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[i + 1], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i, 2)), barTime[i], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i + 1, 2)), xloc.bar_time, extend.none, color3, line.style_solid, 1))
    for i = 1 to clockDiameter - 1
        a_analogClock.push(line.new(barTime[i + 1], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i, 2)), barTime[i], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i + 1, 2)), xloc.bar_time, extend.none, color4, line.style_solid, 1))

    if not (i_forex or syminfo.type == 'forex')
        for i = 1 to clockDiameter - 1
            a_analogClock.push(line.new(barTime[i + 1], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i, 2)), barTime[i], clockDiameter + math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i + 1, 2)), xloc.bar_time, extend.both, color3, line.style_dotted, 1))
        for i = 1 to clockDiameter - 1
            a_analogClock.push(line.new(barTime[i + 1], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i, 2)), barTime[i], clockDiameter - math.sqrt(math.pow(clockDiameter, 2) - math.pow(clockDiameter - i + 1, 2)), xloc.bar_time, extend.both, color4, line.style_dotted, 1))

    // ── Second Hand ───────────────────────────────────────────────────────────────────────────── //

    int   x2 = na
    float y2 = na

    if secondHand < 15
        x2 := barTime[clockDiameter - secondHand]
        y2 := 2 * clockDiameter - a_linePointY.get(secondHand)
    else if secondHand < 30
        x2 := barTime[(secondHand == 15 ? secondHand + 1 : secondHand) - clockDiameter]
        y2 := a_linePointY.get(2 * clockDiameter - secondHand)
    else if secondHand < 45
        x2 := barTime[secondHand - clockDiameter]
        y2 := a_linePointY.get(secondHand - 2 * clockDiameter)
    else
        x2 := barTime[5 * clockDiameter - (secondHand < 46 ? secondHand + 1 : secondHand)]
        y2 := 2 * clockDiameter - a_linePointY.get(4 * clockDiameter - secondHand)

    a_analogClock.push(line.new(time[clockDiameter], clockDiameter, x2, y2, xloc.bar_time, extend.none, i_secColor, line.style_solid, 1))

    // ── Minute Hand ───────────────────────────────────────────────────────────────────────────── //

    if minuteHand < 16
        a_analogClock.push(line.new(barTime[clockDiameter], clockDiameter, barTime[clockDiameter - minuteHand], 2 * clockDiameter - a_linePointY2.get(minuteHand) - 2, xloc.bar_time, extend.none, i_handColor, line.style_solid, 3))
    else if minuteHand < 31
        a_analogClock.push(line.new(barTime[clockDiameter], clockDiameter, barTime[minuteHand - clockDiameter], a_linePointY2.get(2 * clockDiameter - minuteHand) + 2, xloc.bar_time, extend.none, i_handColor, line.style_solid, 3))
    else if minuteHand < 46
        a_analogClock.push(line.new(barTime[clockDiameter], clockDiameter, barTime[minuteHand - clockDiameter], a_linePointY2.get(minuteHand - 2 * clockDiameter) + 2, xloc.bar_time, extend.none, i_handColor, line.style_solid, 3))
    else
        a_analogClock.push(line.new(barTime[clockDiameter], clockDiameter, barTime[5 * clockDiameter - minuteHand], 2 * clockDiameter - a_linePointY2.get(4 * clockDiameter - minuteHand) - 2, xloc.bar_time, extend.none, i_handColor, line.style_solid, 3))

    // ── Hour Hand ─────────────────────────────────────────────────────────────────────────────── //

    mq  = minuteHand < 16 ? 0 : minuteHand < 31 ? 1 : minuteHand < 46 ? 2 : 3
    h12 = hourHand % 12

    xOff = switch h12
        0  => array.from( 0, -1, -2, -2)
        1  => array.from(-3, -3, -4, -4)
        2  => array.from(-5, -5, -5, -5)
        3  => array.from(-6, -6, -6, -6)
        4  => array.from(-7, -7, -6, -6)
        5  => array.from(-5, -4, -3, -2)
        6  => array.from( 0,  1,  2,  3)
        7  => array.from( 5,  5,  6,  6)
        8  => array.from( 7,  8,  9,  9)
        9  => array.from(10, 10,  9,  9)
        10 => array.from( 8,  7,  6,  5)
        11 => array.from( 4,  3,  2,  1)
        =>   array.from( 0,  0,  0,  0)

    yMult = switch h12
        0  => array.from(1.60, 1.58, 1.56, 1.53)
        1  => array.from(1.50, 1.45, 1.40, 1.35)
        2  => array.from(1.30, 1.25, 1.20, 1.15)
        3  => array.from(1.00, 0.95, 0.90, 0.85)
        4  => array.from(0.80, 0.75, 0.70, 0.65)
        5  => array.from(0.60, 0.50, 0.40, 0.30)
        6  => array.from(0.30, 0.32, 0.34, 0.37)
        7  => array.from(0.40, 0.45, 0.50, 0.60)
        8  => array.from(0.70, 0.75, 0.80, 0.90)
        9  => array.from(1.00, 1.10, 1.20, 1.30)
        10 => array.from(1.35, 1.40, 1.45, 1.50)
        11 => array.from(1.55, 1.60, 1.65, 1.70)
        =>   array.from(1.00, 1.00, 1.00, 1.00)

    a_analogClock.push(line.new(barTime[clockDiameter], clockDiameter, barTime[clockDiameter + xOff.get(mq)], yMult.get(mq) * clockDiameter, xloc.bar_time, extend.none, i_handColor, line.style_solid, 5))

// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    logo.cell(0, 0, '☼☾  ', text_size=size.normal, text_color=color.teal, tooltip = 'SoleMare Analytics')
````
