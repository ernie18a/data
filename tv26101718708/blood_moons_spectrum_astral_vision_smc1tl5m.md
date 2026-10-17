# Blood Moons Spectrum | Astral Vision 

- url: https://www.tradingview.com/script/sMc1tl5m/
- type: indicator
- pine_id: PUB;da2a9366c8354d49994d4a738237eaa8
- version: 1.0

## Description

[b]🌑 Blood Moons ❤️‍🔥 | Astral Vision 🌠💠[/b]

A Blood Moon occurs during a total lunar eclipse, when Earth's shadow fully covers the Moon and the only light reaching it is refracted through Earth's atmosphere, filtering out shorter wavelengths and casting the Moon in deep red. 
These events follow predictable astronomical cycles and have historically captured significant cultural and psychological attention across civilizations.

This indicator maps every Blood Moon and total lunar eclipse event from 2015 through 2029 onto the Bitcoin price chart, marking each event with a vertical line, a background highlight window, and a labeled annotation. 
The dataset includes named events (the 2015 Tetrad completion, the 2018 Super Blue Blood Moon, the 2018 record-length eclipse of the 21st century) alongside all standard Blood Moons, with duration and date displayed directly on the chart. 
Future events through 2029 are projected forward, making the indicator active across the current and next cycle.

[b]Calculation ⚙️[/b]

All event timestamps are hardcoded to their precise astronomical dates. The background highlight activates within a ±10-day window around each event, capturing the price behavior in the days immediately surrounding each eclipse. The label and line are rendered at the exact event date. No mathematical transformation is applied — the indicator is a temporal annotation layer mapped to astronomical data.

[b]Plots 📊[/b]
[list]
[*]Vertical line at each Blood Moon date, extended across the full chart (toggleable)
[*]Background highlight on the price chart for a 10-day window around each event (toggleable)
[*]Label at each event bar displaying the event name, date, and eclipse duration (toggleable)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Show Background` toggles the ±10-day highlight window around each event
[*]`Plot Labels` toggles the annotation labels at each event date
[*]`Plot Lines` toggles the full-height vertical lines at each event date
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Inferno. Positive color applies to vertical lines and background highlights; negative color applies to label backgrounds.

[b]Purpose 🎯[/b]

Bitcoin price history contains a disproportionate number of notable moves, both tops and bottoms,in proximity to Blood Moon events, a pattern that has attracted consistent attention from on-chain analysts and cycle researchers. Whether the correlation reflects genuine market psychology, confirmation bias, or coincidence, the events are astronomically fixed and objectively dateable, making them worth tracking as potential behavioral anchors.

This indicator provides the complete historical and forward-looking Blood Moon calendar overlaid directly on the price chart, eliminating the need to cross-reference external astronomical sources. The 10-day background window contextualizes price behavior in the event's immediate vicinity, and the duration annotation distinguishes short penumbral grazes from the long total eclipses that have historically drawn the most attention. Future events through 2029 allow the current cycle to be tracked against the same framework in real time.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 

//@version=6
indicator("🌑 Blood Moons ❤️‍🔥 | Astral Vision 🌠💠", overlay = true, max_labels_count = 500)

theme        = input.string("Inferno", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"])
usecustom    = input.bool(false, "Custom Colors")
custom_pos   = input.color(color.rgb(255,0,0), "Custom +", inline="cc")
custom_neg   = input.color(color.rgb(120,0,0), "Custom −", inline="cc")
bool showBg  = input.bool(true,  "Show Background", group="Visualizzazione")
bool showLabel = input.bool(true, "Plot Labels",    group="Visualizzazione")
bool showLines = input.bool(true, "Plot Lines",     group="Visualizzazione")

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255, 0,   0)   :
     theme == "Paradiso" ? color.rgb(0,   210, 255)  :
     theme == "Futura"   ? color.rgb(0,   255, 180)  :
     theme == "Infinito" ? color.rgb(180, 120, 255)  :
                           color.rgb(255, 160, 0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120, 0,   0)   :
     theme == "Paradiso" ? color.rgb(0,   80,  160)  :
     theme == "Futura"   ? color.rgb(180, 0,   255)  :
     theme == "Infinito" ? color.rgb(255, 220, 80)   :
                           color.rgb(0,   180, 120)

color C_TEXT = color.rgb(255, 235, 210)

var array<int>    bmTime = array.new<int>()
var array<string> bmName = array.new<string>()
var array<string> bmDur  = array.new<string>()

if barstate.isfirst
    array.push(bmTime, timestamp(2015,04,04,0,0))
    array.push(bmName, "Tetrade III")
    array.push(bmDur,  "4m 43s")

    array.push(bmTime, timestamp(2015,09,28,0,0))
    array.push(bmName, "Superluna")
    array.push(bmDur,  "1h 12m")

    array.push(bmTime, timestamp(2018,01,31,0,0))
    array.push(bmName, "Super Blue Blood Moon")
    array.push(bmDur,  "1h 16m")

    array.push(bmTime, timestamp(2018,07,27,0,0))
    array.push(bmName, "Record XXI sec.")
    array.push(bmDur,  "1h 43m")

    array.push(bmTime, timestamp(2019,01,21,0,0))
    array.push(bmName, "Superluna")
    array.push(bmDur,  "1h 02m")

    array.push(bmTime, timestamp(2021,05,26,0,0))
    array.push(bmName, "Superluna")
    array.push(bmDur,  "14m 30s")

    array.push(bmTime, timestamp(2022,05,16,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "1h 24m")

    array.push(bmTime, timestamp(2022,11,08,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "1h 25m")

    array.push(bmTime, timestamp(2025,03,13,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "1h 05m")

    array.push(bmTime, timestamp(2025,09,07,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "1h 22m")

    array.push(bmTime, timestamp(2026,03,03,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "58m")

    array.push(bmTime, timestamp(2028,12,31,0,0))
    array.push(bmName, "New Year Blood Moon")
    array.push(bmDur,  "~1h")

    array.push(bmTime, timestamp(2029,06,26,0,0))
    array.push(bmName, "Blood Moon")
    array.push(bmDur,  "~1h")

if barstate.isfirst and showLines
    int m = array.size(bmTime)
    for i = 0 to m - 1
        int t = array.get(bmTime, i)
        line.new(
             x1     = t,
             y1     = low,
             x2     = t,
             y2     = high,
             xloc   = xloc.bar_time,
             extend = extend.both,
             color  = color.new(pos_col, 20),
             width  = 5)

int    MS_DAY      = 86400000
int    WINDOW_MS   = 10 * MS_DAY
bool   isBmBg      = false
bool   isBmExact   = false
string bmLabelText = ""
string bmTooltip   = ""

int n = array.size(bmTime)
for i = 0 to n - 1
    int    t   = array.get(bmTime, i)
    string nm  = array.get(bmName, i)
    string dur = array.get(bmDur,  i)
    int    dist = math.abs(time - t)

    if dist <= WINDOW_MS
        isBmBg := true

    if time >= t and time < t + MS_DAY
        isBmExact := true
        string dateStr  = str.format_time(t, "dd MMM yyyy")
        string titleStr = nm == "Blood Moon" ? "🌕 Blood Moon" : "🌕 Blood Moon\n" + nm
        bmLabelText := titleStr + "\n" + dateStr + "\nDuration': " + dur
        bmTooltip   := bmLabelText

bgcolor(showBg and isBmBg ? color.new(pos_col, 50) : na, title="Blood Moon bg")

if showLabel and isBmExact
    float labelY = high * (1.0 + 70 / 100.0)
    label.new(
         x         = time,
         y         = labelY,
         text      = bmLabelText,
         xloc      = xloc.bar_time,
         yloc      = yloc.price,
         color     = neg_col,
         style     = label.style_label_down,
         textcolor = C_TEXT,
         size      = size.normal,
         textalign = text.align_center,
         tooltip   = bmTooltip)
````
