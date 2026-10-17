# TimeStamp

- url: https://www.tradingview.com/script/016cjSe4-TimeStamp/
- type: indicator
- pine_id: PUB;4f935870d57c48faba7f3c5938d38707
- version: 3.0

## Description

TimeStamp marks any candle at a specific time of day directly on your chart, so you never miss a key session moment again.
Whether you're tracking the New York open, the London fix, a custom news release time, or any other repeating intrabar event — just set the hour and minute, pick your timezone, and TimeStamp will highlight it automatically.
Features:

🕐 Custom time — set any hour and minute to mark
🌍 90+ timezones — including Jerusalem, New York, London, Tokyo, Dubai and more
📅 Lookback window — control how many days back to mark, keeping your chart clean
🔺 Triangle or vertical line — choose your preferred mark style
🎨 Full styling control — color, size, line width, line style (solid / dashed / dotted)
🏷️ Time label — optional label showing the marked time next to each candle

How to use:

Add the indicator to your chart
Open Settings and set your target Hour and Minute
Select your Timezone to match your market or location
Choose your Mark Style — Triangle or Vertical Line
Adjust Days Back to control how far the marks appear

Works on any market and any timeframe equal to or smaller than your target interval.

## Source Code

````pine
//@version=6
indicator("TimeStamp", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ════════════════════════════════════════════════════════════════════════════
// ▌ TIME TARGET
// ════════════════════════════════════════════════════════════════════════════
grp_time = "⏰ Target Time"
target_hour   = input.int(16, "Hour (0–23)",   minval = 0, maxval = 23, group = grp_time)
target_minute = input.int(30, "Minute (0–59)", minval = 0, maxval = 59, group = grp_time)

// ════════════════════════════════════════════════════════════════════════════
// ▌ TIMEZONE
// ════════════════════════════════════════════════════════════════════════════
grp_tz = "🌍 Timezone"
tz_choice = input.string("Asia/Jerusalem", "Timezone",
     options = [
         "Exchange",
         // ── UTC ──────────────────────────────
         "UTC",
         // ── Americas ─────────────────────────
         "America/New_York",        // UTC-5/-4  Eastern
         "America/Chicago",         // UTC-6/-5  Central
         "America/Denver",          // UTC-7/-6  Mountain
         "America/Phoenix",         // UTC-7     Arizona (no DST)
         "America/Los_Angeles",     // UTC-8/-7  Pacific
         "America/Anchorage",       // UTC-9/-8  Alaska
         "Pacific/Honolulu",        // UTC-10    Hawaii
         "America/Toronto",         // UTC-5/-4  Toronto
         "America/Vancouver",       // UTC-8/-7  Vancouver
         "America/Mexico_City",     // UTC-6/-5  Mexico City
         "America/Bogota",          // UTC-5     Colombia
         "America/Lima",            // UTC-5     Peru
         "America/Santiago",        // UTC-4/-3  Chile
         "America/Caracas",         // UTC-4     Venezuela
         "America/Buenos_Aires",    // UTC-3     Argentina
         "America/Sao_Paulo",       // UTC-3/-2  Brazil
         // ── Europe ───────────────────────────
         "Europe/London",           // UTC+0/+1  UK
         "Europe/Dublin",           // UTC+0/+1  Ireland
         "Europe/Lisbon",           // UTC+0/+1  Portugal
         "Europe/Madrid",           // UTC+1/+2  Spain
         "Europe/Paris",            // UTC+1/+2  France
         "Europe/Amsterdam",        // UTC+1/+2  Netherlands
         "Europe/Berlin",           // UTC+1/+2  Germany
         "Europe/Brussels",         // UTC+1/+2  Belgium
         "Europe/Zurich",           // UTC+1/+2  Switzerland
         "Europe/Rome",             // UTC+1/+2  Italy
         "Europe/Stockholm",        // UTC+1/+2  Sweden
         "Europe/Oslo",             // UTC+1/+2  Norway
         "Europe/Copenhagen",       // UTC+1/+2  Denmark
         "Europe/Helsinki",         // UTC+2/+3  Finland
         "Europe/Warsaw",           // UTC+1/+2  Poland
         "Europe/Prague",           // UTC+1/+2  Czech Republic
         "Europe/Vienna",           // UTC+1/+2  Austria
         "Europe/Budapest",         // UTC+1/+2  Hungary
         "Europe/Bucharest",        // UTC+2/+3  Romania
         "Europe/Athens",           // UTC+2/+3  Greece
         "Europe/Istanbul",         // UTC+3     Turkey
         "Europe/Moscow",           // UTC+3     Russia/Moscow
         "Europe/Kiev",             // UTC+2/+3  Ukraine
         "Europe/Riga",             // UTC+2/+3  Latvia
         "Europe/Tallinn",          // UTC+2/+3  Estonia
         "Europe/Vilnius",          // UTC+2/+3  Lithuania
         // ── Middle East ──────────────────────
         "Asia/Jerusalem",          // UTC+2/+3  Israel ★
         "Asia/Nicosia",            // UTC+2/+3  Cyprus
         "Asia/Beirut",             // UTC+2/+3  Lebanon
         "Asia/Damascus",           // UTC+2/+3  Syria
         "Asia/Amman",              // UTC+2/+3  Jordan
         "Asia/Riyadh",             // UTC+3     Saudi Arabia
         "Asia/Kuwait",             // UTC+3     Kuwait
         "Asia/Qatar",              // UTC+3     Qatar
         "Asia/Bahrain",            // UTC+3     Bahrain
         "Asia/Baghdad",            // UTC+3     Iraq
         "Asia/Dubai",              // UTC+4     UAE
         "Asia/Muscat",             // UTC+4     Oman
         "Asia/Tehran",             // UTC+3:30  Iran
         // ── Africa ───────────────────────────
         "Africa/Cairo",            // UTC+2     Egypt
         "Africa/Johannesburg",     // UTC+2     South Africa
         "Africa/Nairobi",          // UTC+3     Kenya
         "Africa/Lagos",            // UTC+1     Nigeria
         "Africa/Casablanca",       // UTC+0/+1  Morocco
         "Africa/Accra",            // UTC+0     Ghana
         "Africa/Addis_Ababa",      // UTC+3     Ethiopia
         // ── Asia / Central ───────────────────
         "Asia/Karachi",            // UTC+5     Pakistan
         "Asia/Kolkata",            // UTC+5:30  India
         "Asia/Colombo",            // UTC+5:30  Sri Lanka
         "Asia/Dhaka",              // UTC+6     Bangladesh
         "Asia/Kathmandu",          // UTC+5:45  Nepal
         "Asia/Almaty",             // UTC+6     Kazakhstan
         "Asia/Tashkent",           // UTC+5     Uzbekistan
         "Asia/Tbilisi",            // UTC+4     Georgia
         "Asia/Baku",               // UTC+4/+5  Azerbaijan
         "Asia/Yerevan",            // UTC+4     Armenia
         // ── Asia / East & SE ─────────────────
         "Asia/Rangoon",            // UTC+6:30  Myanmar
         "Asia/Bangkok",            // UTC+7     Thailand
         "Asia/Ho_Chi_Minh",        // UTC+7     Vietnam
         "Asia/Jakarta",            // UTC+7     Indonesia (WIB)
         "Asia/Kuala_Lumpur",       // UTC+8     Malaysia
         "Asia/Singapore",          // UTC+8     Singapore
         "Asia/Manila",             // UTC+8     Philippines
         "Asia/Shanghai",           // UTC+8     China
         "Asia/Hong_Kong",          // UTC+8     Hong Kong
         "Asia/Taipei",             // UTC+8     Taiwan
         "Asia/Seoul",              // UTC+9     South Korea
         "Asia/Tokyo",              // UTC+9     Japan
         // ── Oceania ──────────────────────────
         "Australia/Perth",         // UTC+8     Western Australia
         "Australia/Darwin",        // UTC+9:30  Northern Territory
         "Australia/Adelaide",      // UTC+9:30/+10:30 South Australia
         "Australia/Brisbane",      // UTC+10    Queensland
         "Australia/Sydney",        // UTC+10/+11 New South Wales
         "Australia/Melbourne",     // UTC+10/+11 Victoria
         "Pacific/Auckland",        // UTC+12/+13 New Zealand
         "Pacific/Fiji",            // UTC+12    Fiji
         "Pacific/Guam"             // UTC+10    Guam
         ],
     group = grp_tz)

// ════════════════════════════════════════════════════════════════════════════
// ▌ LOOKBACK
// ════════════════════════════════════════════════════════════════════════════
grp_lb = "📅 Lookback"
days_back = input.int(30, "Mark candles from last N days", minval = 1, maxval = 500, group = grp_lb)

// ════════════════════════════════════════════════════════════════════════════
// ▌ APPEARANCE
// ════════════════════════════════════════════════════════════════════════════
grp_look = "🎨 Appearance"

// ── Vertical Line options ────────────────────────────────────────────────
vline_col   = input.color(color.new(color.yellow, 0), "Line Color",    group = grp_look)
vline_width = input.int(1, "Line Width", minval = 1, maxval = 4,        group = grp_look)
vline_style = input.string("Solid", "Line Style",
                 options = ["Solid", "Dashed", "Dotted"],               group = grp_look)
mark_dir    = input.string("Above Bar", "Mark Direction",
                 options = ["Above Bar", "Below Bar"],                  group = grp_look)

// ── Label ────────────────────────────────────────────────────────────────
show_label  = input.bool(true,  "Show Time Label",                      group = grp_look)
label_bg    = input.color(color.new(color.yellow, 15), "  Label Background", group = grp_look)
label_txt   = input.color(color.black, "  Label Text Color",            group = grp_look)
label_size  = input.string("Small", "  Label Text Size",
                 options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_look)

// ════════════════════════════════════════════════════════════════════════════
// ▌ HELPERS
// ════════════════════════════════════════════════════════════════════════════

// Return hour in the chosen timezone
f_hour(ts, tz) =>
    switch tz
        "UTC"                  => hour(ts, "UTC")
        "America/New_York"     => hour(ts, "America/New_York")
        "America/Chicago"      => hour(ts, "America/Chicago")
        "America/Denver"       => hour(ts, "America/Denver")
        "America/Phoenix"      => hour(ts, "America/Phoenix")
        "America/Los_Angeles"  => hour(ts, "America/Los_Angeles")
        "America/Anchorage"    => hour(ts, "America/Anchorage")
        "Pacific/Honolulu"     => hour(ts, "Pacific/Honolulu")
        "America/Toronto"      => hour(ts, "America/Toronto")
        "America/Vancouver"    => hour(ts, "America/Vancouver")
        "America/Mexico_City"  => hour(ts, "America/Mexico_City")
        "America/Bogota"       => hour(ts, "America/Bogota")
        "America/Lima"         => hour(ts, "America/Lima")
        "America/Santiago"     => hour(ts, "America/Santiago")
        "America/Caracas"      => hour(ts, "America/Caracas")
        "America/Buenos_Aires" => hour(ts, "America/Buenos_Aires")
        "America/Sao_Paulo"    => hour(ts, "America/Sao_Paulo")
        "Europe/London"        => hour(ts, "Europe/London")
        "Europe/Dublin"        => hour(ts, "Europe/Dublin")
        "Europe/Lisbon"        => hour(ts, "Europe/Lisbon")
        "Europe/Madrid"        => hour(ts, "Europe/Madrid")
        "Europe/Paris"         => hour(ts, "Europe/Paris")
        "Europe/Amsterdam"     => hour(ts, "Europe/Amsterdam")
        "Europe/Berlin"        => hour(ts, "Europe/Berlin")
        "Europe/Brussels"      => hour(ts, "Europe/Brussels")
        "Europe/Zurich"        => hour(ts, "Europe/Zurich")
        "Europe/Rome"          => hour(ts, "Europe/Rome")
        "Europe/Stockholm"     => hour(ts, "Europe/Stockholm")
        "Europe/Oslo"          => hour(ts, "Europe/Oslo")
        "Europe/Copenhagen"    => hour(ts, "Europe/Copenhagen")
        "Europe/Helsinki"      => hour(ts, "Europe/Helsinki")
        "Europe/Warsaw"        => hour(ts, "Europe/Warsaw")
        "Europe/Prague"        => hour(ts, "Europe/Prague")
        "Europe/Vienna"        => hour(ts, "Europe/Vienna")
        "Europe/Budapest"      => hour(ts, "Europe/Budapest")
        "Europe/Bucharest"     => hour(ts, "Europe/Bucharest")
        "Europe/Athens"        => hour(ts, "Europe/Athens")
        "Europe/Istanbul"      => hour(ts, "Europe/Istanbul")
        "Europe/Moscow"        => hour(ts, "Europe/Moscow")
        "Europe/Kiev"          => hour(ts, "Europe/Kiev")
        "Europe/Riga"          => hour(ts, "Europe/Riga")
        "Europe/Tallinn"       => hour(ts, "Europe/Tallinn")
        "Europe/Vilnius"       => hour(ts, "Europe/Vilnius")
        "Asia/Jerusalem"       => hour(ts, "Asia/Jerusalem")
        "Asia/Nicosia"         => hour(ts, "Asia/Nicosia")
        "Asia/Beirut"          => hour(ts, "Asia/Beirut")
        "Asia/Damascus"        => hour(ts, "Asia/Damascus")
        "Asia/Amman"           => hour(ts, "Asia/Amman")
        "Asia/Riyadh"          => hour(ts, "Asia/Riyadh")
        "Asia/Kuwait"          => hour(ts, "Asia/Kuwait")
        "Asia/Qatar"           => hour(ts, "Asia/Qatar")
        "Asia/Bahrain"         => hour(ts, "Asia/Bahrain")
        "Asia/Baghdad"         => hour(ts, "Asia/Baghdad")
        "Asia/Dubai"           => hour(ts, "Asia/Dubai")
        "Asia/Muscat"          => hour(ts, "Asia/Muscat")
        "Asia/Tehran"          => hour(ts, "Asia/Tehran")
        "Africa/Cairo"         => hour(ts, "Africa/Cairo")
        "Africa/Johannesburg"  => hour(ts, "Africa/Johannesburg")
        "Africa/Nairobi"       => hour(ts, "Africa/Nairobi")
        "Africa/Lagos"         => hour(ts, "Africa/Lagos")
        "Africa/Casablanca"    => hour(ts, "Africa/Casablanca")
        "Africa/Accra"         => hour(ts, "Africa/Accra")
        "Africa/Addis_Ababa"   => hour(ts, "Africa/Addis_Ababa")
        "Asia/Karachi"         => hour(ts, "Asia/Karachi")
        "Asia/Kolkata"         => hour(ts, "Asia/Kolkata")
        "Asia/Colombo"         => hour(ts, "Asia/Colombo")
        "Asia/Dhaka"           => hour(ts, "Asia/Dhaka")
        "Asia/Kathmandu"       => hour(ts, "Asia/Kathmandu")
        "Asia/Almaty"          => hour(ts, "Asia/Almaty")
        "Asia/Tashkent"        => hour(ts, "Asia/Tashkent")
        "Asia/Tbilisi"         => hour(ts, "Asia/Tbilisi")
        "Asia/Baku"            => hour(ts, "Asia/Baku")
        "Asia/Yerevan"         => hour(ts, "Asia/Yerevan")
        "Asia/Rangoon"         => hour(ts, "Asia/Rangoon")
        "Asia/Bangkok"         => hour(ts, "Asia/Bangkok")
        "Asia/Ho_Chi_Minh"     => hour(ts, "Asia/Ho_Chi_Minh")
        "Asia/Jakarta"         => hour(ts, "Asia/Jakarta")
        "Asia/Kuala_Lumpur"    => hour(ts, "Asia/Kuala_Lumpur")
        "Asia/Singapore"       => hour(ts, "Asia/Singapore")
        "Asia/Manila"          => hour(ts, "Asia/Manila")
        "Asia/Shanghai"        => hour(ts, "Asia/Shanghai")
        "Asia/Hong_Kong"       => hour(ts, "Asia/Hong_Kong")
        "Asia/Taipei"          => hour(ts, "Asia/Taipei")
        "Asia/Seoul"           => hour(ts, "Asia/Seoul")
        "Asia/Tokyo"           => hour(ts, "Asia/Tokyo")
        "Australia/Perth"      => hour(ts, "Australia/Perth")
        "Australia/Darwin"     => hour(ts, "Australia/Darwin")
        "Australia/Adelaide"   => hour(ts, "Australia/Adelaide")
        "Australia/Brisbane"   => hour(ts, "Australia/Brisbane")
        "Australia/Sydney"     => hour(ts, "Australia/Sydney")
        "Australia/Melbourne"  => hour(ts, "Australia/Melbourne")
        "Pacific/Auckland"     => hour(ts, "Pacific/Auckland")
        "Pacific/Fiji"         => hour(ts, "Pacific/Fiji")
        "Pacific/Guam"         => hour(ts, "Pacific/Guam")
        "Exchange"             => hour   // exchange built-in
        =>                        hour   // fallback

// Return minute in the chosen timezone
f_minute(ts, tz) =>
    switch tz
        "UTC"                  => minute(ts, "UTC")
        "America/New_York"     => minute(ts, "America/New_York")
        "America/Chicago"      => minute(ts, "America/Chicago")
        "America/Denver"       => minute(ts, "America/Denver")
        "America/Phoenix"      => minute(ts, "America/Phoenix")
        "America/Los_Angeles"  => minute(ts, "America/Los_Angeles")
        "America/Anchorage"    => minute(ts, "America/Anchorage")
        "Pacific/Honolulu"     => minute(ts, "Pacific/Honolulu")
        "America/Toronto"      => minute(ts, "America/Toronto")
        "America/Vancouver"    => minute(ts, "America/Vancouver")
        "America/Mexico_City"  => minute(ts, "America/Mexico_City")
        "America/Bogota"       => minute(ts, "America/Bogota")
        "America/Lima"         => minute(ts, "America/Lima")
        "America/Santiago"     => minute(ts, "America/Santiago")
        "America/Caracas"      => minute(ts, "America/Caracas")
        "America/Buenos_Aires" => minute(ts, "America/Buenos_Aires")
        "America/Sao_Paulo"    => minute(ts, "America/Sao_Paulo")
        "Europe/London"        => minute(ts, "Europe/London")
        "Europe/Dublin"        => minute(ts, "Europe/Dublin")
        "Europe/Lisbon"        => minute(ts, "Europe/Lisbon")
        "Europe/Madrid"        => minute(ts, "Europe/Madrid")
        "Europe/Paris"         => minute(ts, "Europe/Paris")
        "Europe/Amsterdam"     => minute(ts, "Europe/Amsterdam")
        "Europe/Berlin"        => minute(ts, "Europe/Berlin")
        "Europe/Brussels"      => minute(ts, "Europe/Brussels")
        "Europe/Zurich"        => minute(ts, "Europe/Zurich")
        "Europe/Rome"          => minute(ts, "Europe/Rome")
        "Europe/Stockholm"     => minute(ts, "Europe/Stockholm")
        "Europe/Oslo"          => minute(ts, "Europe/Oslo")
        "Europe/Copenhagen"    => minute(ts, "Europe/Copenhagen")
        "Europe/Helsinki"      => minute(ts, "Europe/Helsinki")
        "Europe/Warsaw"        => minute(ts, "Europe/Warsaw")
        "Europe/Prague"        => minute(ts, "Europe/Prague")
        "Europe/Vienna"        => minute(ts, "Europe/Vienna")
        "Europe/Budapest"      => minute(ts, "Europe/Budapest")
        "Europe/Bucharest"     => minute(ts, "Europe/Bucharest")
        "Europe/Athens"        => minute(ts, "Europe/Athens")
        "Europe/Istanbul"      => minute(ts, "Europe/Istanbul")
        "Europe/Moscow"        => minute(ts, "Europe/Moscow")
        "Europe/Kiev"          => minute(ts, "Europe/Kiev")
        "Europe/Riga"          => minute(ts, "Europe/Riga")
        "Europe/Tallinn"       => minute(ts, "Europe/Tallinn")
        "Europe/Vilnius"       => minute(ts, "Europe/Vilnius")
        "Asia/Jerusalem"       => minute(ts, "Asia/Jerusalem")
        "Asia/Nicosia"         => minute(ts, "Asia/Nicosia")
        "Asia/Beirut"          => minute(ts, "Asia/Beirut")
        "Asia/Damascus"        => minute(ts, "Asia/Damascus")
        "Asia/Amman"           => minute(ts, "Asia/Amman")
        "Asia/Riyadh"          => minute(ts, "Asia/Riyadh")
        "Asia/Kuwait"          => minute(ts, "Asia/Kuwait")
        "Asia/Qatar"           => minute(ts, "Asia/Qatar")
        "Asia/Bahrain"         => minute(ts, "Asia/Bahrain")
        "Asia/Baghdad"         => minute(ts, "Asia/Baghdad")
        "Asia/Dubai"           => minute(ts, "Asia/Dubai")
        "Asia/Muscat"          => minute(ts, "Asia/Muscat")
        "Asia/Tehran"          => minute(ts, "Asia/Tehran")
        "Africa/Cairo"         => minute(ts, "Africa/Cairo")
        "Africa/Johannesburg"  => minute(ts, "Africa/Johannesburg")
        "Africa/Nairobi"       => minute(ts, "Africa/Nairobi")
        "Africa/Lagos"         => minute(ts, "Africa/Lagos")
        "Africa/Casablanca"    => minute(ts, "Africa/Casablanca")
        "Africa/Accra"         => minute(ts, "Africa/Accra")
        "Africa/Addis_Ababa"   => minute(ts, "Africa/Addis_Ababa")
        "Asia/Karachi"         => minute(ts, "Asia/Karachi")
        "Asia/Kolkata"         => minute(ts, "Asia/Kolkata")
        "Asia/Colombo"         => minute(ts, "Asia/Colombo")
        "Asia/Dhaka"           => minute(ts, "Asia/Dhaka")
        "Asia/Kathmandu"       => minute(ts, "Asia/Kathmandu")
        "Asia/Almaty"          => minute(ts, "Asia/Almaty")
        "Asia/Tashkent"        => minute(ts, "Asia/Tashkent")
        "Asia/Tbilisi"         => minute(ts, "Asia/Tbilisi")
        "Asia/Baku"            => minute(ts, "Asia/Baku")
        "Asia/Yerevan"         => minute(ts, "Asia/Yerevan")
        "Asia/Rangoon"         => minute(ts, "Asia/Rangoon")
        "Asia/Bangkok"         => minute(ts, "Asia/Bangkok")
        "Asia/Ho_Chi_Minh"     => minute(ts, "Asia/Ho_Chi_Minh")
        "Asia/Jakarta"         => minute(ts, "Asia/Jakarta")
        "Asia/Kuala_Lumpur"    => minute(ts, "Asia/Kuala_Lumpur")
        "Asia/Singapore"       => minute(ts, "Asia/Singapore")
        "Asia/Manila"          => minute(ts, "Asia/Manila")
        "Asia/Shanghai"        => minute(ts, "Asia/Shanghai")
        "Asia/Hong_Kong"       => minute(ts, "Asia/Hong_Kong")
        "Asia/Taipei"          => minute(ts, "Asia/Taipei")
        "Asia/Seoul"           => minute(ts, "Asia/Seoul")
        "Asia/Tokyo"           => minute(ts, "Asia/Tokyo")
        "Australia/Perth"      => minute(ts, "Australia/Perth")
        "Australia/Darwin"     => minute(ts, "Australia/Darwin")
        "Australia/Adelaide"   => minute(ts, "Australia/Adelaide")
        "Australia/Brisbane"   => minute(ts, "Australia/Brisbane")
        "Australia/Sydney"     => minute(ts, "Australia/Sydney")
        "Australia/Melbourne"  => minute(ts, "Australia/Melbourne")
        "Pacific/Auckland"     => minute(ts, "Pacific/Auckland")
        "Pacific/Fiji"         => minute(ts, "Pacific/Fiji")
        "Pacific/Guam"         => minute(ts, "Pacific/Guam")
        "Exchange"             => minute  // exchange built-in
        =>                        minute  // fallback

// ════════════════════════════════════════════════════════════════════════════
// ▌ LOGIC
// ════════════════════════════════════════════════════════════════════════════

// Cutoff timestamp: midnight N days ago (in ms)
cutoff_ms = timenow - days_back * 86400000
in_window = time >= cutoff_ms

bar_hour   = f_hour(time, tz_choice)
bar_minute = f_minute(time, tz_choice)
is_target  = in_window and (bar_hour == target_hour) and (bar_minute == target_minute)

atr14       = ta.atr(14)
place_below = mark_dir == "Below Bar"

// ── Clearance: extend line past all candles within last 3 bars ────────────
nearby_high = math.max(high, high[1], high[2], high[3])
nearby_low  = math.min(low,  low[1],  low[2],  low[3])

min_line_len     = atr14 * 0.5
line_start_below = math.min(nearby_low,  low)  - min_line_len
line_start_above = math.max(nearby_high, high) + min_line_len
line_len         = atr14 * 1.5

// ─── Vertical Line ───────────────────────────────────────────────────────────
if is_target and vline_style == "Dashed"
    l_top = place_below ? low              : line_start_above + line_len
    l_bot = place_below ? line_start_below : high
    line.new(bar_index, l_top, bar_index, l_bot, color = vline_col, width = vline_width, style = line.style_dashed)
if is_target and vline_style == "Dotted"
    l_top = place_below ? low              : line_start_above + line_len
    l_bot = place_below ? line_start_below : high
    line.new(bar_index, l_top, bar_index, l_bot, color = vline_col, width = vline_width, style = line.style_dotted)
if is_target and vline_style == "Solid"
    l_top = place_below ? low              : line_start_above + line_len
    l_bot = place_below ? line_start_below : high
    line.new(bar_index, l_top, bar_index, l_bot, color = vline_col, width = vline_width, style = line.style_solid)

// ─── Label ───────────────────────────────────────────────────────────────────
if is_target and show_label
    min_str = target_minute < 10 ? "0" + str.tostring(target_minute) : str.tostring(target_minute)
    lbl_y   = place_below ? line_start_below - atr14 * 0.2 : line_start_above + line_len + atr14 * 0.2
    lbl_sty = place_below ? label.style_label_up : label.style_label_down
    lbl_txt = str.format("{0}:{1}", target_hour, min_str)
    if label_size == "Tiny"
        label.new(bar_index, lbl_y, text = lbl_txt, color = label_bg, textcolor = label_txt, style = lbl_sty, size = size.tiny)
    else if label_size == "Normal"
        label.new(bar_index, lbl_y, text = lbl_txt, color = label_bg, textcolor = label_txt, style = lbl_sty, size = size.normal)
    else if label_size == "Large"
        label.new(bar_index, lbl_y, text = lbl_txt, color = label_bg, textcolor = label_txt, style = lbl_sty, size = size.large)
    else if label_size == "Huge"
        label.new(bar_index, lbl_y, text = lbl_txt, color = label_bg, textcolor = label_txt, style = lbl_sty, size = size.huge)
    else
        label.new(bar_index, lbl_y, text = lbl_txt, color = label_bg, textcolor = label_txt, style = lbl_sty, size = size.small)
````
