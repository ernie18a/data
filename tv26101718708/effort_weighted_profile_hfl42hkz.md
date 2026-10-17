# Effort Weighted Profile

- url: https://www.tradingview.com/script/hFl42hkZ-Effort-Weighted-Profile/
- type: indicator
- pine_id: PUB;78f84fc8aa934c80980a3e3e326d6c34
- version: 1.0

## Description

[b]█ Overview[/b]

EWP — Effort-Weighted Profile introduces a new interpretation of the standard volume profile.

It builds independent ASIA, EU and US session distributions from TradingView footprint data and provides an optional weighting model that considers traded volume, candle-body progress, relative delta magnitude and remembered visits to price zones.

Each session develops its own Point of Control and Value Area. Once collection ends, its levels become fixed and can extend forward while the underlying zones continue recording subsequent visits and traded volume.

EWP provides a framework for comparing where activity accumulated, how weighting changes that distribution, and how price interacts with those areas afterward.

[b]█ A New Interpretation of the Volume Profile[/b]

A conventional volume profile answers:

[b]Where did the greatest amount of trading activity occur?[/b]

EWP's weighted interpretation explores a different question:

[b]Where did activity concentrate after accounting for limited candle-body progress, relative delta magnitude and recurring zone visits?[/b]

Each price row starts with its traded volume. The weighting engine then changes its contribution according to those additional measurements.

A row can become more prominent when its volume occurs during a candle with limited body progress, when its relative delta magnitude is greater, or when qualifying return visits have strengthened its decaying memory.

The resulting distribution represents [b]weighted trading activity[/b]. Its dominant row and boundaries can differ from those of the unweighted volume profile.

[b]What distinguishes EWP[/b]

• [b]Effort and progress:[/b] Volume is evaluated alongside candle-body progress relative to the candle's range.
• [b]Directional intensity:[/b] Relative delta magnitude can amplify a row's contribution.
• [b]Zone memory:[/b] Qualifying return visits strengthen remembered zones, while older encounters gradually lose influence.
• [b]Session context:[/b] ASIA, EU and US develop independently.
• [b]Direct comparison:[/b] Unweighted Footprint Volume mode provides a reference for examining the effect of the weighting model.

These components define the interpretation explicitly. They do not establish absorption, institutional participation or a predictive trading advantage.

[b]█ Calculation Modes[/b]

[b]Footprint Volume[/b]

This mode accumulates unweighted footprint volume into a fixed session price grid.

The highest-volume row determines the POC. The Value Area contains the selected percentage of accumulated volume.

Use this mode to inspect the underlying distribution of trading activity.

[b]W-Weighted[/b]

This mode applies EWP's weighting model to each row's volume contribution.

The highest-weight row determines the W-POC. The W-Value Area contains the selected percentage of calculated weight.

Comparing the two modes shows how candle inhibition, delta magnitude and memory influence the same session's distribution.

[b]█ How the Weighting Engine Works[/b]

[b]1. Volume Contribution[/b]

The engine starts with the footprint volume assigned to each price row.

Footprint rows are mapped onto a fixed session grid. Where their boundaries differ, volume and delta are allocated proportionally to the price overlap.

[b]2. Candle Inhibition[/b]

Inhibition measures how small the absolute candle body is relative to the full high-low range.

A smaller body relative to the range produces greater inhibition. A body occupying the entire range produces zero inhibition.

This is a candle-level measurement of limited body progress. It does not prove that absorption occurred within an individual price row.

[b]3. Delta Magnitude[/b]

The engine calculates each row's delta relative to its volume.

Delta Weight controls how strongly the absolute magnitude of this ratio amplifies the contribution. Positive and negative delta magnitudes are treated symmetrically by the weighting formula.

Direction is represented separately through the profile colors.

[b]4. Decaying Zone Memory[/b]

Price zones can accumulate remembered strength through qualifying return visits.

A return requires an intervening data sample without a recorded visit. Revisit Inhibition sets the minimum inhibition required to strengthen memory.

Remembered strength decays with elapsed time, including periods between sessions. Memory Half-Life controls the decay, while Memory Cap limits the strength accumulated by an individual zone.

The core weighting expression is:

[pine]
float w = effort * inhibition * (1.0 + deltaStrength * math.abs(direction)) * (1.0 + memStrength * oldMemory)
[/pine]

Effort is row volume, direction is row delta divided by volume, and oldMemory is the decayed remembered strength of that zone.

Memory Strength set to zero removes memory amplification. Delta Weight set to zero removes delta amplification.

[b]█ Why POC, VAH and VAL Keep Their Names[/b]

POC, VAH and VAL describe the [b]structural roles of levels within a distribution[/b].

EWP preserves those roles while allowing the quantity being distributed to change.

[b]POC — Point of Control[/b]

In Footprint Volume mode, POC identifies the center of the row with the greatest accumulated volume.

In W-Weighted mode, [b]W-POC[/b] identifies the center of the row with the greatest accumulated EWP weight.

Both identify the dominant row of their respective distribution. A W-POC does not necessarily identify the price where the most raw volume traded.

[b]VAH — Value Area High[/b]

VAH marks the upper boundary of the selected coverage area.

Footprint Volume mode measures coverage using volume. In W-Weighted mode, [b]W-VAH[/b] bounds an area measured using calculated weight.

[b]VAL — Value Area Low[/b]

VAL marks the lower boundary of that same coverage area. In W-Weighted mode, it is identified as [b]W-VAL[/b].

The familiar names preserve a recognizable framework: a dominant row and two distribution boundaries. The [b]W- prefix[/b] makes the weighted interpretation explicit.

[b]█ Value Area Calculation[/b]

The Value Area expands outward from the POC, selecting neighboring rows according to their contributions until the requested coverage is reached.

With the default 70% setting:

• Footprint Volume mode covers at least 70% of accumulated volume.
• W-Weighted mode covers at least 70% of accumulated weight.

Complete calculation rows are included, so the resulting coverage can exceed the requested percentage.

Display-row merging affects the histogram's appearance only. POC and Value Area calculations use the underlying calculation grid.

[b]█ Session Structure[/b]

ASIA, EU and US are independently configurable collection windows.

Sessions may overlap. During an overlap, an eligible chart bar contributes once to each participating profile. Each session retains its own distribution and levels.

Time Zone Preset includes regional options alongside Exchange and Custom settings. Regional IANA zones account for daylight-saving changes where applicable.

The selected zone determines how the entered session hours are interpreted. Changing it changes the actual collection windows; it does not simply change displayed dates.

[b]EU Collection Mode[/b]

• Full Sessions collects until the configured EU session end.
• Freeze at 15:30 ends EU collection at 15:30 in the selected time zone.

The freeze is a fixed local cutoff. It does not automatically follow the US exchange opening when regional daylight-saving schedules differ.

Weekdays Only optionally restricts collection to Monday through Friday.

[b]█ Zone Statistics and Hover Tooltips[/b]

Hover a POC, VAH or VAL label to inspect:

• Zone title.
• Touches.
• Unweighted Volume.

A tooltip can display a touch count such as 4 and a compact volume value such as 30k.

[b]How touches are counted[/b]

A touch represents a separate recorded visit to the underlying calculation row.

Consecutive chart bars with recorded activity in that row count as one continuous visit. A later visit following an intervening sample without recorded activity creates another touch. The initial visit counts.

This is a sampled visit count, rather than a tick-by-tick count of every price crossing.

[b]Which row is measured[/b]

• POC uses its containing calculation row.
• VAH uses the uppermost row inside the Value Area.
• VAL uses the lowest row inside the Value Area.

During development, a level's tooltip reflects the history of its current underlying row. If the level moves, its displayed statistics can change accordingly.

After completion, an extended level retains its fixed row and continues accumulating subsequent visits and volume.

Tooltip volume remains unweighted in both calculation modes. It refers to that price zone, rather than the entire session. Volume units follow the selected instrument's data feed.

[b]█ Profile Colors[/b]

EWP uses the following default directional palette:

• [b]Buy:[/b] #03f10d.
• [b]Sell:[/b] #5100de.
• [b]Neutral:[/b] #8b92a4.

Each visible histogram row is colored according to the sign of its aggregated directional contributions. In W-Weighted mode, these contributions use the profile's weighting.

When calculation rows are merged for display, their contributions are aggregated before the visible row is colored.

Value Area Transparency and Outside VA Transparency control visibility independently. Session-level colors are configured separately.

[b]█ Optional Seconds-Based Memory[/b]

Use Seconds for Zone Visits supplements the memory engine with lower-timeframe OHLCV observations.

These observations provide a finer estimate of exits and returns within a chart bar. Their volume is not added to the footprint profile, and no second footprint request is made.

Seconds data updates memory after the current footprint contribution has been calculated. The current chart bar is therefore not retrospectively amplified by its own subsequent memory updates.

This option affects memory observations. The level-tooltip touch counter remains resolved at chart-bar granularity.

Seconds intervals require suitable account access and data availability. OHLCV ranges cannot reveal the exact sequence of every trade or price crossing within an individual seconds candle.

[b]█ Display and Settings[/b]

[b]Profile Engine[/b]

Calculation Mode selects the volume or weighted distribution.

Row Size sets the price width of each calculation row in minimum ticks. Smaller rows provide finer resolution and require more capacity.

Maximum Rows limits the number of calculation rows per session.

Value Area sets the required distribution coverage.

[b]Profile Display[/b]

Show Profile Bars controls the histogram independently of the lines.

Profile Width controls the width of the largest visible row relative to the collected session duration.

Display Rows controls visual detail. Adjacent rows may be merged to respect drawing limits without changing the calculated levels.

Archived Profiles controls the total number of completed sessions retained across ASIA, EU and US. It does not specify a separate number of days for each session.

[b]Levels & Labels[/b]

Show Level Lines is the master line switch.

POC, VAH and VAL each have an individual switch applying to every session and its corresponding labels.

Extend Completed Levels projects fixed session levels to the current chart bar.

Label size, right padding, optional dates and optional prices can be adjusted independently of the histogram.

[b]█ Suggested Workflow[/b]

1. Select a standard time-based intraday candle chart.
2. Configure the time zone and collection windows for the instrument.
3. Begin with Footprint Volume to inspect the underlying session distribution.
4. Compare W-Weighted to examine how EWP changes that distribution.
5. Observe developing POC and Value Area boundaries as the session progresses.
6. After collection ends, study subsequent interactions with the fixed levels.
7. Use the hover statistics to distinguish continuous activity from separate recorded visits.

If a profile exceeds its price-row capacity, increase Maximum Rows or Row Size to accommodate the session's range.

[b]█ Requirements and Calculation Behavior[/b]

This edition requires TradingView footprint access, currently available with Premium or Ultimate, and appropriate volume data for the selected symbol.

TradingView's footprint buy/sell classification uses intrabar price action. EWP does not identify individual traders, institutional participants or resting order-book liquidity.

Calculations update on confirmed chart bars. Developing profiles and levels can move until collection ends.

Completed levels are drawn across their session for reference. Their final values were only available when the session or freeze window ended; they were not known at its beginning.

Chart bars crossing a collection cutoff are excluded because a whole-bar footprint cannot be accurately divided by time. Chart intervals aligned with session boundaries provide more consistent coverage.

Memory is rebuilt from available loaded history and stores a bounded number of price zones. Changing the available history, symbol, timeframe or settings can change the distributions and remembered strength.

Unavailable footprint data, limited seconds history and data-feed revisions can affect calculations. EWP provides a defined alternative interpretation of trading activity whose usefulness should be evaluated for the selected market and timeframe.

## Source Code

````pine
//@version=6
indicator("Effort Weighted Profile", shorttitle = "EWP", overlay = true, max_boxes_count = 450, max_lines_count = 60, max_labels_count = 80, max_bars_back = 2000)


// INPUTS · Profile Engine
string gC = "Profile Engine"
string weightMode = input.string("W-Weighted", "Calculation Mode", options = ["Footprint Volume", "W-Weighted"], group = gC, tooltip = "CALCULATION MODE\n\nFootprint Volume builds an unweighted profile from TradingView footprint rows.\n\nW-Weighted applies candle inhibition, delta magnitude and decaying zone memory. Its Value Area contains a percentage of W-weight, rather than raw volume.", display = display.none)
bool useW = weightMode == "W-Weighted"
int ticks = input.int(100, "Row Size (ticks)", minval = 1, group = gC, tooltip = "ROW SIZE\n\nPrice width of each calculation row: minimum tick size multiplied by this value.\n\nLower values provide finer price resolution but require more rows. Higher values cover a wider session range with fewer rows. The grid stays fixed throughout the session.", display = display.none)
int maxRows = input.int(120, "Maximum Rows", minval = 20, maxval = 500, group = gC, tooltip = "MAXIMUM ROWS\n\nMaximum number of calculation rows per session. If the session exceeds this capacity, its profile becomes invalid. Increase this limit or Row Size. Display Rows only changes rendering, not this capacity.", display = display.none)
float vaFraction = input.float(70, "Value Area (%)", minval = 1, maxval = 100, group = gC, tooltip = "VALUE AREA\n\nExpands outward from the highest-weight row until the selected fraction is covered.\n\nFootprint Volume uses raw volume; W-Weighted uses W-weight. POC, VAH and VAL use the full calculation grid, even when display rows are merged.", display = display.none) / 100.0
float stepPrice = syminfo.mintick * ticks
footprint fp = request.footprint(ticks)

// INPUTS · Sessions
string gS = "Sessions"
string timezonePreset = input.string("Berlin / Paris", "Time Zone Preset", options = ["Exchange", "UTC", "Berlin / Paris", "London", "New York", "Chicago", "Los Angeles", "Sao Paulo", "Johannesburg", "Dubai", "Mumbai", "Singapore / Hong Kong", "Tokyo", "Sydney", "Auckland", "Custom"], group = gS, tooltip = "TIME ZONE PRESET\n\nUses regional IANA zones, including automatic daylight-saving changes where applicable. Exchange uses the symbol's exchange zone.\n\nAll session windows are interpreted as local clock times in this zone. Changing the preset changes the actual session windows; it does not just change label display. Adjust ASIA, EU and US for your market. The chart display zone is independent.", display = display.none)
string customTimezone = input.string("Europe/Berlin", "Custom Time Zone", group = gS, active = timezonePreset == "Custom", tooltip = "CUSTOM TIME ZONE\n\nEnter an IANA identifier such as Europe/Berlin, America/New_York or Asia/Tokyo. Used only with the Custom preset.", display = display.none)
string tz = switch timezonePreset
    "Exchange" => syminfo.timezone
    "UTC" => "Etc/UTC"
    "Berlin / Paris" => "Europe/Berlin"
    "London" => "Europe/London"
    "New York" => "America/New_York"
    "Chicago" => "America/Chicago"
    "Los Angeles" => "America/Los_Angeles"
    "Sao Paulo" => "America/Sao_Paulo"
    "Johannesburg" => "Africa/Johannesburg"
    "Dubai" => "Asia/Dubai"
    "Mumbai" => "Asia/Kolkata"
    "Singapore / Hong Kong" => "Asia/Singapore"
    "Tokyo" => "Asia/Tokyo"
    "Sydney" => "Australia/Sydney"
    "Auckland" => "Pacific/Auckland"
    => customTimezone
string s1 = input.session("0000-0800", "ASIA", group = gS, tooltip = "SESSION WINDOWS\n\nASIA, EU and US are independent and may overlap. An overlapping chart bar can contribute once to each eligible session. Only bars fully contained in the collection window are included.", display = display.none)
string s2 = input.session("0800-1800", "EU", group = gS, display = display.none)
string s3 = input.session("1530-2200", "US", group = gS, display = display.none)
bool weekdays = input.bool(false, "Weekdays Only", group = gS, tooltip = "WEEKDAYS ONLY\n\nRestricts session windows to Monday through Friday. Leave off for markets that also trade on weekends.")
string sessionMode = input.string("Full Sessions", "EU Collection Mode", options = ["Full Sessions", "Freeze at 15:30"], group = gS, tooltip = "EU COLLECTION MODE\n\nFull Sessions collects until the configured EU end. Freeze at 15:30 stops the EU profile at 15:30 in Time Zone. This is a fixed local time, not an automatic US exchange opening.\n\nA chart bar crossing the cutoff is excluded because its footprint cannot be split accurately by time. Use chart intervals aligned with your session boundaries.", display = display.none)
bool freezeEurope = sessionMode == "Freeze at 15:30"
string days = weekdays ? ":23456" : ":1234567"

// INPUTS · Memory Engine
string gW = "Memory Engine"
float memStrength = input.float(0.25, "Memory Strength", minval = 0, maxval = 2, step = 0.05, group = gW, active = useW, tooltip = "MEMORY STRENGTH\n\nControls how much remembered zone visits amplify W-weight. Zero removes memory amplification.\n\nMemory is rebuilt from loaded chart history and can therefore differ when the available history changes. Only active in W-Weighted mode.", display = display.none)
float halfLife = input.float(120, "Memory Half-Life (minutes)", minval = 1, group = gW, active = useW, tooltip = "MEMORY HALF-LIFE\n\nElapsed time needed for remembered strength to halve. Lower values forget old encounters faster; higher values retain them longer. Decay uses elapsed clock time, including gaps.", display = display.none)
float memCap = input.float(4, "Memory Cap", minval = 1, maxval = 20, group = gW, active = useW, tooltip = "MEMORY CAP\n\nMaximum remembered strength for a price row. Limits repeated amplification. The storage buffer holds at most 5,000 zones and removes the oldest inserted zone when full.", display = display.none)
float deltaStrength = input.float(0.5, "Delta Weight", minval = 0, maxval = 2, step = 0.1, group = gW, active = useW, tooltip = "DELTA WEIGHT\n\nAmplifies rows with a larger absolute footprint delta relative to their volume. Buy and sell pressure increase the weight symmetrically. Zero removes this amplification. Direction controls profile colors separately.", display = display.none)
float confirmThreshold = input.float(0.65, "Revisit Inhibition", minval = 0, maxval = 1, step = 0.05, group = gW, active = useW, tooltip = "REVISIT INHIBITION\n\nMinimum inhibition required to strengthen memory on a return visit. Inhibition is 1 minus candle body divided by range. It measures limited body progress, not proven absorption.\n\nA return requires at least one intervening data sample without a recorded visit to the zone. With Intrabar Timing enabled, the samples are seconds candles.", display = display.none)

// INPUTS · Intrabar Timing
string gT = "Intrabar Timing"
bool secondsMemory = input.bool(false, "Use Seconds for Zone Visits", group = gT, active = useW, tooltip = "SECONDS ZONE VISITS\n\nUses seconds OHLCV to estimate exits and revisits inside a chart bar. Only the visit sequence updates memory; footprint volume and delta remain the profile data source.\n\nSeconds ranges do not reveal the exact tick path. Missing seconds history is not silently replaced by chart-bar visits. Requires supported seconds data and a lower interval than the chart.")
string secondsTf = input.timeframe("10S", "Seconds Interval", options = ["1S", "5S", "10S", "15S", "30S", "45S"], group = gT, active = useW and secondsMemory, tooltip = "SECONDS INTERVAL\n\nSmaller intervals refine the estimated visit sequence but consume more intrabar history and processing time. Ten seconds is the initial setting. This does not request a second footprint.", display = display.none)
bool useSeconds = secondsMemory and useW

// INPUTS · Profile Display
string gD = "Profile Display"
bool showProfiles = input.bool(true, "Show Profile Bars", group = gD, tooltip = "PROFILE BARS\n\nShows or hides the horizontal volume histogram only. Level lines and labels have independent controls in Levels & Labels. Calculations continue while the bars are hidden.")
float profileShare = input.float(30, "Profile Width (%)", minval = 5, maxval = 100, group = gD, active = showProfiles, tooltip = "PROFILE WIDTH\n\nWidth of the largest visible row as a percentage of the collected session duration. All other rows are scaled relative to it. Purely visual.", display = display.none) / 100.0
int displayRows = input.int(40, "Display Rows", minval = 10, maxval = 150, group = gD, active = showProfiles, tooltip = "DISPLAY ROWS\n\nMaximum visible rows per profile. Adjacent calculation rows are merged when needed. The drawing budget may reduce visible detail further when more profiles are retained. POC and Value Area calculations remain unchanged.", display = display.none)
int keepProfiles = input.int(3, "Archived Profiles", minval = 1, maxval = 6, group = gD, tooltip = "ARCHIVED PROFILES\n\nTotal number of completed session profiles retained across all sessions. Three means the latest three completed sessions, not three days per session.", display = display.none)
int vaTransparency = input.int(15, "Value Area Transparency", minval = 0, maxval = 100, group = gD, active = showProfiles, tooltip = "PROFILE TRANSPARENCY\n\nZero is opaque; 100 is invisible. Value Area rows use the first setting, other rows use the second. Lower values make the brand colors more visible.", display = display.none)
int outerTransparency = input.int(35, "Outside VA Transparency", minval = 0, maxval = 100, group = gD, active = showProfiles, display = display.none)

// INPUTS · Levels & Labels
string gL = "Levels & Labels"
bool showLevels = input.bool(true, "Show Level Lines", group = gL, tooltip = "LEVEL LINES\n\nMaster switch for POC, VAH and VAL lines and their labels. Independent of Show Profile Bars.")
bool showPOC = input.bool(true, "POC", inline = "visibleLevels", group = gL, active = showLevels)
bool showVAH = input.bool(true, "VAH", inline = "visibleLevels", group = gL, active = showLevels)
bool showVAL = input.bool(true, "VAL", inline = "visibleLevels", group = gL, active = showLevels, tooltip = "VISIBLE LEVELS\n\nEach switch applies to every session, including archived profiles. Disabling a level hides both its line and its label. POC, VAH and VAL are still calculated internally.")
bool anyLevel = showLevels and (showPOC or showVAH or showVAL)
bool extendFinal = input.bool(true, "Extend Completed Levels", group = gL, active = anyLevel, tooltip = "EXTEND COMPLETED LEVELS\n\nExtends completed POC, VAH and VAL to the current chart-bar close. Labels follow the right endpoint. Completed level prices remain fixed.")
bool showLabels = input.bool(true, "Show Labels", group = gL, active = anyLevel, tooltip = "LEVEL TOOLTIPS\n\nHover a level label for the zone title, Touches and unweighted Volume. A touch is a separate recorded visit to the underlying price row; consecutive data samples count as one visit. The initial visit counts.\n\nPOC uses its containing row. VAH uses the uppermost row inside the Value Area; VAL uses the lowest. Developing levels display the history of their current row. Extended completed levels include subsequent retests. Counts are resolved at chart-bar granularity in the footprint edition and analysis-candle granularity in the LTF edition.")
string labelSize = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = gL, active = anyLevel and showLabels, display = display.none)
int labelOffset = input.int(0, "Right Padding (bars)", minval = 0, maxval = 25, group = gL, active = anyLevel and showLabels, tooltip = "LABEL POSITION\n\nText is placed to the right of the line endpoint and vertically centered at the exact level price. Zero attaches the transparent label anchor to the endpoint. Higher values add spacing measured in chart-bar durations.", display = display.none)
bool labelPrices = input.bool(false, "Show Price", inline = "labelDetails", group = gL, active = anyLevel and showLabels)
bool labelDates = input.bool(false, "Show Date", inline = "labelDetails", group = gL, active = anyLevel and showLabels, tooltip = "LABEL DETAILS\n\nOptionally append the level price and session start date. Session identifiers always use ASIA, EU and US.")
string textSize = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small

// INPUTS · Colors
string gCP = "Colors · Profile"
color upColor = input.color(#03f10d, "Buy", inline = "brand", group = gCP)
color downColor = input.color(#5100de, "Sell", inline = "brand", group = gCP, tooltip = "PROFILE COLORS\n\nBrand defaults: Buy #03f10d and Sell #5100de. Each visible row uses the dominant sign of its aggregated footprint delta. Full base colors replace the previous weak gray gradient. A balanced row uses Neutral. These colors describe pressure, not entry signals.")
color neutralColor = input.color(#8b92a4, "Neutral", group = gCP)
string gCS = "Colors · Session Levels"
color c1 = input.color(color.aqua, "ASIA", inline = "sessionColors", group = gCS)
color c2 = input.color(color.orange, "EU", inline = "sessionColors", group = gCS)
color c3 = input.color(color.fuchsia, "US", inline = "sessionColors", group = gCS, tooltip = "SESSION LEVEL COLORS\n\nColors for each session's POC, VAH, VAL and text labels. Kept separate from Buy/Sell profile colors so session identity and pressure remain distinguishable.")

if barstate.isfirst
    if not timeframe.isintraday or not chart.is_standard
        runtime.error("Use a standard time-based intraday candle chart.")
    if useSeconds and timeframe.in_seconds(secondsTf) >= timeframe.in_seconds()
        runtime.error("The seconds interval must be lower than the chart interval.")
    if freezeEurope
        int startMin = int(str.tonumber(str.substring(s2, 0, 2))) * 60 + int(str.tonumber(str.substring(s2, 2, 4)))
        int endMin = int(str.tonumber(str.substring(s2, 5, 7))) * 60 + int(str.tonumber(str.substring(s2, 7, 9)))
        int duration = (endMin - startMin + 1440) % 1440
        duration := duration == 0 ? 1440 : duration
        int offset = (15 * 60 + 30 - startMin + 1440) % 1440
        if offset == 0 or offset > duration
            runtime.error("EU freeze at 15:30 must fall after the session start and within the EU window.")

f_sessionKey(string session, int t) =>
    int hh = int(str.tonumber(str.substring(session, 0, 2)))
    int mm = int(str.tonumber(str.substring(session, 2, 4)))
    int offset = hour(t, tz) * 60 + minute(t, tz) < hh * 60 + mm ? -1 : 0
    timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz) + offset, hh, mm)

f_sessionEnd(string session, int key) =>
    int sh = int(str.tonumber(str.substring(session, 0, 2)))
    int sm = int(str.tonumber(str.substring(session, 2, 4)))
    int eh = int(str.tonumber(str.substring(session, 5, 7)))
    int em = int(str.tonumber(str.substring(session, 7, 9)))
    int offset = eh * 60 + em <= sh * 60 + sm ? 1 : 0
    timestamp(tz, year(key, tz), month(key, tz), dayofmonth(key, tz) + offset, eh, em)

f_freezeTime(int key) =>
    int offset = hour(key, tz) * 60 + minute(key, tz) > 15 * 60 + 30 ? 1 : 0
    timestamp(tz, year(key, tz), month(key, tz), dayofmonth(key, tz) + offset, 15, 30)

f_collectionEnd(string session, int key, int sess) =>
    int ending = f_sessionEnd(session, key)
    sess == 1 and freezeEurope ? math.min(ending, f_freezeTime(key)) : ending

f_levelText(string name, string levelName, float price, int key) =>
    string prefix = useW ? "W-" : ""
    name + (labelDates ? " " + str.format_time(key, "dd.MM", tz) : "") + " " + prefix + levelName + (labelPrices ? " " + str.tostring(price, format.mintick) : "")

f_textLabel(int x, float price, string caption, color tone, string details) =>
    label.new(x, price, caption, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = tone, textalign = text.align_left, size = textSize, tooltip = details)

f_compactVolume(float zoneVolume) =>
    float amount = math.abs(zoneVolume)
    amount >= 1e9 ? str.tostring(zoneVolume / 1e9, "#.##") + "b" : amount >= 1e6 ? str.tostring(zoneVolume / 1e6, "#.##") + "m" : amount >= 1e3 ? str.tostring(zoneVolume / 1e3, "#.##") + "k" : str.tostring(zoneVolume, "#.##")

f_zoneDetails(string title, int touches, float zoneVolume) =>
    title + "\nTouches: " + str.tostring(touches) + "\nVolume: " + f_compactVolume(zoneVolume)

type Drawing
    array<box> boxes
    array<line> lines
    array<label> labels
    array<int> labelLevels
    array<int> zoneKeys
    array<int> zoneTouches
    array<float> zoneVolumes
    array<int> zoneLastSeen
    array<string> zoneTitles
    bool followCurrent = false
    bool trackRetests = false

f_newDrawing() =>
    Drawing.new(array.new<box>(), array.new<line>(), array.new<label>(), array.new<int>(), array.new<int>(3, na), array.new<int>(3, 0), array.new<float>(3, 0.0), array.new<int>(3, na), array.new<string>(3, ""))

method erase(Drawing d) =>
    while d.boxes.size() > 0
        box.delete(d.boxes.pop())
    while d.lines.size() > 0
        line.delete(d.lines.pop())
    while d.labels.size() > 0
        label.delete(d.labels.pop())
    d.labelLevels.clear()
    true

// One visit can span several consecutive samples. Volume remains raw.
method addZoneTrade(Drawing d, int level, float zoneVolume, int sequence) =>
    if d.trackRetests and zoneVolume > 0
        int seen = d.zoneLastSeen.get(level)
        if na(seen) or sequence > seen + 1
            d.zoneTouches.set(level, d.zoneTouches.get(level) + 1)
        d.zoneLastSeen.set(level, sequence)
        d.zoneVolumes.set(level, d.zoneVolumes.get(level) + zoneVolume)
    true

method refreshTooltips(Drawing d) =>
    if d.labels.size() > 0
        for j = 0 to d.labels.size() - 1
            int level = d.labelLevels.get(j)
            label.set_tooltip(d.labels.get(j), f_zoneDetails(d.zoneTitles.get(level), d.zoneTouches.get(level), d.zoneVolumes.get(level)))
    true

method toCurrentBar(Drawing d) =>
    if d.followCurrent
        for levelLine in d.lines
            line.set_x2(levelLine, time_close)
        int labelTime = time_close + int(timeframe.in_seconds() * 1000) * labelOffset
        for textLabel in d.labels
            label.set_x(textLabel, labelTime)
    true

type Profile
    array<float> weights
    array<float> directions
    array<float> rowVolumes
    array<int> rowTouches
    array<int> rowLastSeen
    Drawing drawing
    int sessionKey = na
    int endTime = na
    int cutoff = na
    int baseKey = na
    bool finished = false
    bool frozen = false
    bool invalid = false
    bool partial = false
    int samples = 0
    int secondsGaps = 0
    int secondsSamples = 0
    int missingBars = 0
    int boundarySkips = 0
    float rawVolume = 0.0
    float total = 0.0
    float poc = na
    float vah = na
    float val = na

f_newProfile() =>
    Profile.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<int>(), array.new<int>(), f_newDrawing())

method reset(Profile p, int key, int cutoff, int firstDataTime) =>
    p.drawing := f_newDrawing()
    p.weights.clear()
    p.directions.clear()
    p.rowVolumes.clear()
    p.rowTouches.clear()
    p.rowLastSeen.clear()
    p.sessionKey := key
    p.endTime := na
    p.cutoff := cutoff
    p.baseKey := na
    p.finished := false
    p.frozen := false
    p.invalid := false
    p.partial := firstDataTime > key
    p.samples := 0
    p.secondsGaps := 0
    p.secondsSamples := 0
    p.missingBars := 0
    p.boundarySkips := 0
    p.rawVolume := 0.0
    p.total := 0.0
    p.poc := na
    p.vah := na
    p.val := na
    true

method ensureRange(Profile p, int loKey, int hiKey) =>
    int oldSize = p.weights.size()
    int newBase = oldSize == 0 ? loKey : math.min(p.baseKey, loKey)
    int newTop = oldSize == 0 ? hiKey : math.max(p.baseKey + oldSize - 1, hiKey)
    if newTop - newBase + 1 > maxRows
        p.invalid := true
        p.poc := na
        p.vah := na
        p.val := na
    else if not p.invalid
        if oldSize == 0
            p.baseKey := newBase
        else if newBase < p.baseKey
            int prepend = p.baseKey - newBase
            for j = 1 to prepend
                p.weights.unshift(0.0)
                p.directions.unshift(0.0)
                p.rowVolumes.unshift(0.0)
                p.rowTouches.unshift(0)
                p.rowLastSeen.unshift(na)
            p.baseKey := newBase
        int append = newTop - p.baseKey + 1 - p.weights.size()
        if append > 0
            for j = 1 to append
                p.weights.push(0.0)
                p.directions.push(0.0)
                p.rowVolumes.push(0.0)
                p.rowTouches.push(0)
                p.rowLastSeen.push(na)
    true

method addWeight(Profile p, int key, float w, float direction, float zoneVolume, int sequence) =>
    if not p.invalid
        int idx = key - p.baseKey
        p.weights.set(idx, p.weights.get(idx) + w)
        p.directions.set(idx, p.directions.get(idx) + w * direction)
        if zoneVolume > 0
            int seen = p.rowLastSeen.get(idx)
            if na(seen) or sequence > seen + 1
                p.rowTouches.set(idx, p.rowTouches.get(idx) + 1)
            p.rowLastSeen.set(idx, sequence)
            p.rowVolumes.set(idx, p.rowVolumes.get(idx) + zoneVolume)
    true

method calculate(Profile p) =>
    if not p.invalid and p.weights.size() > 0
        p.total := p.weights.sum()
        float peak = p.weights.max()
        if p.total > 0 and peak > 0
            int center = p.weights.indexof(peak)
            int left = center
            int right = center
            float covered = peak
            float target = p.total * vaFraction
            int lastIdx = p.weights.size() - 1
            while covered < target and (left > 0 or right < lastIdx)
                float below = left > 0 ? p.weights.get(left - 1) : -1.0
                float above = right < lastIdx ? p.weights.get(right + 1) : -1.0
                if above > below
                    right += 1
                    covered += above
                else if below > above
                    left -= 1
                    covered += below
                else
                    if left > 0
                        left -= 1
                        covered += below
                    if right < lastIdx
                        right += 1
                        covered += above
            p.poc := (p.baseKey + center + 0.5) * stepPrice
            p.val := (p.baseKey + left) * stepPrice
            p.vah := (p.baseKey + right + 1) * stepPrice
    true

var array<Drawing> archive = array.new<Drawing>()

method render(Profile p, string name, color sessionColor) =>
    p.drawing.erase()
    p.drawing.followCurrent := p.finished and extendFinal and anyLevel
    p.drawing.trackRetests := p.finished and extendFinal
    if (showProfiles or anyLevel) and not na(p.sessionKey) and not na(p.endTime) and not p.invalid and not na(p.poc)
        int x0 = p.sessionKey
        int xEnd = p.endTime
        int duration = math.max(1, xEnd - x0)
        int widthTime = math.max(1, int(duration * profileShare))
        int lineEnd = p.finished and extendFinal ? time_close : xEnd
        // VA boundary levels describe the adjacent row inside the Value Area.
        array<int> keys = array.from(int(math.floor(p.poc / stepPrice + 1e-7)), int(math.ceil(p.vah / stepPrice - 1e-7)) - 1, int(math.floor(p.val / stepPrice + 1e-7)))
        array<string> levelNames = array.from("POC", "VAH", "VAL")
        array<float> levelPrices = array.from(p.poc, p.vah, p.val)
        for level = 0 to 2
            int key = keys.get(level)
            int idx = key - p.baseKey
            p.drawing.zoneKeys.set(level, key)
            p.drawing.zoneTouches.set(level, p.rowTouches.get(idx))
            p.drawing.zoneVolumes.set(level, p.rowVolumes.get(idx))
            p.drawing.zoneLastSeen.set(level, p.rowLastSeen.get(idx))
            p.drawing.zoneTitles.set(level, f_levelText(name, levelNames.get(level), levelPrices.get(level), p.sessionKey))
        if showProfiles
            int n = p.weights.size()
            // Budget for three active profiles plus the archive; rendering only.
            int rowLimit = math.min(displayRows, int(math.floor(450.0 / (keepProfiles + 3))))
            int stride = math.max(1, int(math.ceil(float(n) / rowLimit)))
            float peak = 0.0
            for first = 0 to n - 1 by stride
                float groupWeight = 0.0
                int last = math.min(n - 1, first + stride - 1)
                for j = first to last
                    groupWeight += p.weights.get(j)
                peak := math.max(peak, groupWeight)
            if peak > 0
                for first = 0 to n - 1 by stride
                    int last = math.min(n - 1, first + stride - 1)
                    float w = 0.0
                    float dw = 0.0
                    for j = first to last
                        w += p.weights.get(j)
                        dw += p.directions.get(j)
                    if w > 0
                        float bottom = (p.baseKey + first) * stepPrice
                        float top = (p.baseKey + last + 1) * stepPrice
                        float direction = math.max(-1.0, math.min(1.0, dw / w))
                        color tone = direction > 1e-6 ? upColor : direction < -1e-6 ? downColor : neutralColor
                        bool insideVA = top > p.val and bottom < p.vah
                        int x1 = math.min(xEnd, x0 + math.max(1, int(widthTime * w / peak)))
                        p.drawing.boxes.push(box.new(left = x0, top = top, right = x1, bottom = bottom, xloc = xloc.bar_time, border_color = color.new(tone, math.min(100, (insideVA ? vaTransparency : outerTransparency) + 15)), bgcolor = color.new(tone, insideVA ? vaTransparency : outerTransparency)))
        if anyLevel
            if showPOC
                p.drawing.lines.push(line.new(x0, p.poc, lineEnd, p.poc, xloc = xloc.bar_time, color = sessionColor, width = 2))
            if showVAH
                p.drawing.lines.push(line.new(x0, p.vah, lineEnd, p.vah, xloc = xloc.bar_time, color = sessionColor, style = line.style_dashed))
            if showVAL
                p.drawing.lines.push(line.new(x0, p.val, lineEnd, p.val, xloc = xloc.bar_time, color = sessionColor, style = line.style_dashed))
            if showLabels
                int textX = lineEnd + int(timeframe.in_seconds() * 1000) * labelOffset
                if showPOC
                    p.drawing.labels.push(f_textLabel(textX, p.poc, f_levelText(name, "POC", p.poc, p.sessionKey), sessionColor, f_zoneDetails(p.drawing.zoneTitles.get(0), p.drawing.zoneTouches.get(0), p.drawing.zoneVolumes.get(0))))
                    p.drawing.labelLevels.push(0)
                if showVAH
                    p.drawing.labels.push(f_textLabel(textX, p.vah, f_levelText(name, "VAH", p.vah, p.sessionKey), sessionColor, f_zoneDetails(p.drawing.zoneTitles.get(1), p.drawing.zoneTouches.get(1), p.drawing.zoneVolumes.get(1))))
                    p.drawing.labelLevels.push(1)
                if showVAL
                    p.drawing.labels.push(f_textLabel(textX, p.val, f_levelText(name, "VAL", p.val, p.sessionKey), sessionColor, f_zoneDetails(p.drawing.zoneTitles.get(2), p.drawing.zoneTouches.get(2), p.drawing.zoneVolumes.get(2))))
                    p.drawing.labelLevels.push(2)
    true

method finishAndArchive(Profile p, string name, color tone, bool frozen) =>
    if not p.finished
        p.finished := true
        p.frozen := frozen
        p.calculate()
        p.render(name, tone)
        archive.push(p.drawing)
        while archive.size() > keepProfiles
            Drawing oldest = archive.shift()
            oldest.erase()
    true

var Profile p1 = f_newProfile()
var Profile p2 = f_newProfile()
var Profile p3 = f_newProfile()
var array<Profile> profiles = array.from(p1, p2, p3)
var array<string> sessions = array.from(s1, s2, s3)
var array<string> names = array.from("ASIA", "EU", "US")
var array<color> colors = array.from(c1, c2, c3)

// Cross-session memory. Chart and seconds modes use separate visit counters.
// FIFO capacity: 5,000 zones; state is rebuilt from loaded history.
var map<int, float> memories = map.new<int, float>()
var map<int, int> lastSeenBar = map.new<int, int>()
var map<int, int> lastSeenSecond = map.new<int, int>()
var map<int, int> lastSeenTime = map.new<int, int>()
var array<int> insertionOrder = array.new<int>()
var int sampleNumber = 0
var int evictions = 0

f_updateMemory(int k, int t, int sequence, float inhibition, bool secondsMode) =>
    bool known = memories.contains(k)
    float elapsed = known ? math.max(0.0, (t - lastSeenTime.get(k)) / 60000.0) : 0.0
    float oldMemory = known ? memories.get(k) * math.pow(0.5, elapsed / halfLife) : 0.0
    bool seenInMode = secondsMode ? lastSeenSecond.contains(k) : lastSeenBar.contains(k)
    int previous = seenInMode ? (secondsMode ? lastSeenSecond.get(k) : lastSeenBar.get(k)) : sequence
    bool returnVisit = seenInMode and sequence - previous > 1
    float nextMemory = math.min(memCap, oldMemory + (returnVisit and inhibition >= confirmThreshold ? 1.0 : 0.0))
    int removed = 0
    if not known
        if insertionOrder.size() >= 5000
            int oldest = insertionOrder.shift()
            memories.remove(oldest)
            lastSeenBar.remove(oldest)
            lastSeenSecond.remove(oldest)
            lastSeenTime.remove(oldest)
            removed := 1
        insertionOrder.push(k)
    memories.put(k, nextMemory)
    lastSeenTime.put(k, t)
    if secondsMode
        lastSeenSecond.put(k, sequence)
    else
        lastSeenBar.put(k, sequence)
    removed

bool a1 = not na(time(timeframe.period, s1 + days, tz))
bool a2 = not na(time(timeframe.period, s2 + days, tz))
bool a3 = not na(time(timeframe.period, s3 + days, tz))
array<bool> membership = array.from(a1, a2, a3)
array<bool> collect = array.new<bool>(3, false)

// Seconds OHLCV supplies only the visit sequence, never additional
// profile volume or delta. It does not reconstruct a tick or bid/ask path.
array<int> secT = array.new<int>()
array<int> secEnd = array.new<int>()
array<float> secO = array.new<float>()
array<float> secH = array.new<float>()
array<float> secL = array.new<float>()
array<float> secC = array.new<float>()
array<float> secV = array.new<float>()
array<bool> secA = array.new<bool>()
array<bool> secE = array.new<bool>()
array<bool> secU = array.new<bool>()
if useSeconds
    [st, se, so, sh, sl, sc, sv, sa, sb, su] = request.security_lower_tf(syminfo.tickerid, secondsTf, [time, time_close, open, high, low, close, volume, not na(time(timeframe.period, s1 + days, tz)), not na(time(timeframe.period, s2 + days, tz)), not na(time(timeframe.period, s3 + days, tz))])
    secT := st
    secEnd := se
    secO := so
    secH := sh
    secL := sl
    secC := sc
    secV := sv
    secA := sa
    secE := sb
    secU := su

if barstate.isconfirmed
    // The footprint represents the whole chart bar. Bars crossing a cutoff
    // are excluded instead of allocating their volume by an assumed time split.
    // Example: exclude 15:15-15:45 when the EU freeze is at 15:30.
    for sess = 0 to 2
        Profile p = profiles.get(sess)
        string window = sessions.get(sess)
        int key = f_sessionKey(window, time)
        int cutoff = f_collectionEnd(window, key, sess)
        if not na(p.sessionKey) and not p.finished and (time >= p.cutoff or (membership.get(sess) and p.sessionKey != key))
            p.finishAndArchive(names.get(sess), colors.get(sess), sess == 1 and freezeEurope)
        if membership.get(sess) and time < cutoff
            if na(p.sessionKey) or p.sessionKey != key
                p.reset(key, cutoff, time)
            if not p.finished
                if time_close <= cutoff
                    collect.set(sess, true)
                    p.endTime := time_close
                    p.samples += 1
                    if na(fp)
                        p.missingBars += 1
                else
                    p.boundarySkips += 1
                    p.partial := true

    // Retests of completed extended levels, including outside session hours.
    // Raw row volume is allocated once by overlap; W-calculations are unchanged.
    if not na(fp) and archive.size() > 0
        for row in fp.rows()
            float bottom = row.down_price()
            float top = row.up_price()
            float span = top - bottom
            if span > 0
                for drawing in archive
                    if drawing.trackRetests
                        for level = 0 to 2
                            int key = drawing.zoneKeys.get(level)
                            if not na(key)
                                float overlap = math.max(0.0, math.min(top, (key + 1) * stepPrice) - math.max(bottom, key * stepPrice))
                                if overlap > 0
                                    drawing.addZoneTrade(level, row.total_volume() * overlap / span, bar_index)

    bool anyCollect = collect.get(0) or collect.get(1) or collect.get(2)
    if anyCollect and not na(fp)
        array<volume_row> rows = fp.rows()
        if rows.size() > 0
            int loKey = int(math.floor(rows.first().down_price() / stepPrice + 1e-7))
            int hiKey = int(math.ceil(rows.last().up_price() / stepPrice - 1e-7)) - 1
            hiKey := math.max(loKey, hiKey)
            int count = hiKey - loKey + 1
            for sess = 0 to 2
                if collect.get(sess)
                    profiles.get(sess).ensureRange(loKey, hiKey)
            if count <= maxRows
                array<float> rowVolume = array.new<float>(count, 0.0)
                array<float> rowDelta = array.new<float>(count, 0.0)
                // Rebin footprint rows onto the fixed session price grid.
                // If boundaries differ, allocate by price overlap.
                for row in rows
                    float bottom = row.down_price()
                    float top = row.up_price()
                    float span = top - bottom
                    if span > 0
                        int first = math.max(loKey, int(math.floor(bottom / stepPrice + 1e-7)))
                        int last = math.min(hiKey, int(math.ceil(top / stepPrice - 1e-7)) - 1)
                        if last >= first
                            for k = first to last
                                float overlap = math.max(0.0, math.min(top, (k + 1) * stepPrice) - math.max(bottom, k * stepPrice))
                                float fraction = overlap / span
                                int idx = k - loKey
                                rowVolume.set(idx, rowVolume.get(idx) + row.total_volume() * fraction)
                                rowDelta.set(idx, rowDelta.get(idx) + row.delta() * fraction)
                float span = high - low
                float inhibition = span > 0 ? 1.0 - math.min(1.0, math.abs(close - open) / span) : 1.0
                for idx = 0 to count - 1
                    float effort = rowVolume.get(idx)
                    if effort > 0
                        int k = loKey + idx
                        float direction = math.max(-1.0, math.min(1.0, rowDelta.get(idx) / effort))
                        bool known = memories.contains(k)
                        float elapsed = known ? math.max(0.0, (time - lastSeenTime.get(k)) / 60000.0) : 0.0
                        float oldMemory = known ? memories.get(k) * math.pow(0.5, elapsed / halfLife) : 0.0
                        float w = useW ? effort * inhibition * (1.0 + deltaStrength * math.abs(direction)) * (1.0 + memStrength * oldMemory) : effort
                        for sess = 0 to 2
                            if collect.get(sess)
                                Profile p = profiles.get(sess)
                                p.rawVolume += effort
                                p.addWeight(k, w, direction, effort, bar_index)
                        // In seconds mode, memory is updated only from the
                        // seconds visit sequence processed below.
                        if useW and not useSeconds
                            evictions += f_updateMemory(k, time, bar_index, inhibition, false)
        else
            for sess = 0 to 2
                if collect.get(sess)
                    Profile p = profiles.get(sess)
                    p.missingBars += 1

    // Update memory AFTER adding this bar: its own visits must not
    // retroactively amplify its footprint contribution.
    if useSeconds
        int n = secT.size()
        if n > 0
            for sample = 0 to n - 1
                sampleNumber += 1
                int t = secT.get(sample)
                int ending = secEnd.get(sample)
                array<bool> inside = array.from(secA.get(sample), secE.get(sample), secU.get(sample))
                bool eligible = false
                for sess = 0 to 2
                    int key = f_sessionKey(sessions.get(sess), t)
                    int cutoff = f_collectionEnd(sessions.get(sess), key, sess)
                    if inside.get(sess) and ending <= cutoff
                        eligible := true
                        Profile p = profiles.get(sess)
                        if p.sessionKey == key
                            p.secondsSamples += 1
                float v = secV.get(sample)
                float h = secH.get(sample)
                float l = secL.get(sample)
                if eligible and not na(v) and v > 0 and not na(h) and not na(l)
                    int first = int(math.floor(l / stepPrice + 1e-7))
                    int last = h > l ? int(math.ceil(h / stepPrice - 1e-7)) - 1 : first
                    last := math.max(first, last)
                    float span = h - l
                    float inhibition = span > 0 ? 1.0 - math.min(1.0, math.abs(secC.get(sample) - secO.get(sample)) / span) : 1.0
                    if last - first + 1 <= maxRows
                        for k = first to last
                            evictions += f_updateMemory(k, t, sampleNumber, inhibition, true)
        // Missing seconds history is not silently replaced by chart visits.
        // Flag discrepancies between seconds and chart volume for label tooltips.
        float secTotal = n > 0 ? secV.sum() : 0.0
        bool secGap = n == 0 or (not na(volume) and volume > 0 and (na(secTotal) or math.abs(secTotal - volume) > math.max(1e-6, volume * 0.01)))
        if secGap
            for sess = 0 to 2
                if collect.get(sess)
                    Profile p = profiles.get(sess)
                    p.secondsGaps += 1

    for sess = 0 to 2
        Profile p = profiles.get(sess)
        if not na(p.sessionKey) and not p.finished
            p.calculate()
            if time_close >= p.cutoff
                p.finishAndArchive(names.get(sess), colors.get(sess), sess == 1 and freezeEurope)

// Update archived levels and redraw only the active session profiles.
if barstate.islast
    for drawing in archive
        drawing.toCurrentBar()
        drawing.refreshTooltips()
    for sess = 0 to 2
        Profile p = profiles.get(sess)
        if not p.finished and not na(p.sessionKey)
            p.render(names.get(sess), colors.get(sess))
````
