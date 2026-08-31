<!-- tradingview-pine-id: PUB;489b7f9fa7ed4185886359bf3613e6f7 -->
<!-- tradingviewscripts-format: 1 -->
# The Mayan Calendar

Source: https://www.tradingview.com/script/8moPa8K8-The-Mayan-Calendar/

## Description

This indicator displays the current date in the Mayan Calendar, based on real-time UTC time. It calculates and presents:

[*]🌀 Long Count (Baktun.Katun.Tun.Uinal.Kin) – A linear count of days since the Mayan epoch (August 11, 3114 BCE).
[*]🔮 Tzolk'in Date – A 260-day sacred cycle combining a number (1–13) and one of 20 day names (e.g., 4 Ajaw).
[*]🌾 Haab' Date – A 365-day civil cycle divided into 18 months of 20 days + 5 "nameless" days (Wayeb').

The calculations follow Smithsonian standards and align with the Maya Calendar Converter from the National Museum of the American Indian:
👉 https://maya.nmai.si.edu/calendar/maya-calendar-converter

The results are shown in a table overlay on your chart's top-right corner. This indicator is great for symbolic traders, astro enthusiasts, or anyone interested in ancient timekeeping systems woven into financial timeframes. Enjoy, time travelers! ⌛

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BarefootJoey

// See the Smithsonian calculator at https://maya.nmai.si.edu/calendar/maya-calendar-converter

//@version=5
indicator("The Mayan Calendar", overlay=true)

// Constants for Mayan calendar calculations
var DAYS_PER_BAKTUN = 144000
var DAYS_PER_KATUN = 7200
var DAYS_PER_TUN = 360
var DAYS_PER_UINAL = 20
var DAYS_PER_KIN = 1

// Reference date (August 11, 3114 BCE in Julian calendar)
var DAYS_TO_UNIX_EPOCH = 2440588  // Days from Julian Day 0 to Unix Epoch (January 1, 1970)
var MAYAN_EPOCH_JULIAN_DAY = 584283  // Julian Day number for August 11, 3114 BCE

// Function to calculate Julian Day Number from Unix timestamp
getJulianDayNumber(unixTime) =>
    int((unixTime / (1000 * 60 * 60 * 24)) + DAYS_TO_UNIX_EPOCH)

// Function to calculate days since Mayan epoch
getDaysSinceReference() =>
    julianDay = getJulianDayNumber(timenow)
    julianDay - MAYAN_EPOCH_JULIAN_DAY

// Calculate Long Count components
calculateLongCount() =>
    totalDays = getDaysSinceReference()
    
    baktun = int(totalDays / DAYS_PER_BAKTUN)
    remaining = totalDays % DAYS_PER_BAKTUN
    
    katun = int(remaining / DAYS_PER_KATUN)
    remaining := remaining % DAYS_PER_KATUN
    
    tun = int(remaining / DAYS_PER_TUN)
    remaining := remaining % DAYS_PER_TUN
    
    uinal = int(remaining / DAYS_PER_UINAL)
    kin = remaining % DAYS_PER_UINAL
    
    [baktun, katun, tun, uinal, kin]

// Calculate Tzolkin components 
calculateTzolkin() =>
    totalDays = getDaysSinceReference()
    // The Tzolkin number cycle starts at 4 Ahau
    number = ((totalDays + 3) % 13) + 1  
    // The day name cycle starts with Ahau 
    name = (totalDays + 159) % 20  
    [number, name]

// Calculate Haab components
calculateHaab() =>
    totalDays = getDaysSinceReference()
    yearDay = (totalDays + 348) % 365
    month = int(yearDay / 20)
    day = yearDay % 20
    [day, month]

// Get Tzolkin day name
getTzolkinDayName(dayNumber) =>
    dayNames = array.from("Imix", "Ik'", "Ak'b'al", "K'an", "Chikchan",
                         "Kimi", "Manik'", "Lamat", "Muluk", "Ok",
                         "Chuwen", "Eb'", "B'en", "Ix", "Men",
                         "Kib'", "Kab'an", "Etz'nab'", "Kawak", "Ajaw")
    array.get(dayNames, dayNumber)

// Get Haab month name
getHaabMonthName(monthNumber) =>
    monthNames = array.from("Pop", "Wo'", "Sip", "Sotz'", "Sek",
                           "Xul", "Yaxk'in", "Mol", "Ch'en", "Yax",
                           "Sak'", "Keh", "Mak", "K'ank'in", "Muwan",
                           "Pax", "K'ayab", "Kumk'u", "Wayeb'")
    array.get(monthNames, monthNumber)

// Calculate all calendar components
[baktun, katun, tun, uinal, kin] = calculateLongCount()
[tzolkinNumber, tzolkinDayNumber] = calculateTzolkin()
[haabDay, haabMonth] = calculateHaab()

tzolkinDayName = getTzolkinDayName(tzolkinDayNumber)
haabMonthName = getHaabMonthName(haabMonth)

// Create table for display
var table mayan_table = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 70), border_width = 1)

// Update table content
if barstate.islast
    table.cell(mayan_table, 0, 0, "Mayan Calendar", bgcolor = color.new(color.blue, 70), text_color = color.white)
    table.cell(mayan_table, 0, 1, "Long Count:", text_color = color.white)
    table.cell(mayan_table, 1, 1, str.format("{0}.{1}.{2}.{3}.{4}", baktun, katun, tun, uinal, kin), text_color = color.yellow)
    table.cell(mayan_table, 0, 2, "Tzolkin:", text_color = color.white)
    table.cell(mayan_table, 1, 2, str.format("{0} {1}", tzolkinNumber, tzolkinDayName), text_color = color.yellow)
    table.cell(mayan_table, 0, 3, "Haab:", text_color = color.white)
    table.cell(mayan_table, 1, 3, str.format("{0} {1}", haabDay, haabMonthName), text_color = color.yellow)

// Made with ❤ by @BarefootJoey ✌💗📈
````
