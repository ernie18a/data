# My Chart [Herman]

- url: https://www.tradingview.com/script/I0n5UPRT-My-Chart-Herman/
- type: indicator
- pine_id: PUB;ee3a9c7a423b4d629d5501d48b43986c
- version: 2.0

## Description

---

[b]## TITLE[/b]
My Chart [Herman]

---

## DESCRIPTION

```
[b]OVERVIEW[/b]

My Chart is a chart-identification badge with a hidden note attached to it. On the
chart it shows up to three compact lines - the symbol, the current timeframe, and a
short line of your own text. When you move the mouse pointer over the badge, a
tooltip opens containing a longer block of text you have written yourself, and closes
again when the pointer leaves.

The problem it addresses is a practical one. Traders who work from a written process
- a pre-trade checklist, a set of session rules, a reminder of the bias they decided
on before the open - normally keep that text somewhere off the chart, in a note app
or on a second screen, or they paste it onto the chart as a text drawing. Neither
works well. Text kept elsewhere is out of sight at the exact moment it matters, and
text pasted on the chart clutters the workspace permanently to serve a reading that
is only needed for a few seconds before an entry.

This script's approach is to keep almost nothing on the chart and put the full text
one hover away. The visible badge stays small. The detail lives in the tooltip and
appears on demand.

[b]WHAT MAKES IT DIFFERENT[/b]

A standard watermark prints fixed information in a fixed way and is not interactive.
This script turns the same corner of the chart into a container that holds three
things at once: chart identity, a short label, and an on-demand body of text - with
independent styling for each visible line, nine anchor positions, per-row visibility,
and a text-wrapping routine that stops long notes from stretching the badge across
the chart.
[b]
HOW IT WORKS[/b]

The badge is a single-column table drawn once, on the most recent bar. It performs no
market calculation of any kind. It draws no levels, produces no signals, and reads no
data beyond the symbol name and the chart's timeframe. Everything it displays is
either taken from the chart context or typed in by the user.

Ticker row
By default the script reads the chart's symbol from built-in symbol information.
Switching the ticker source to Custom lets you type your own label instead. This is
useful on continuous futures contracts, where a plain "NQ" reads better than the
exchange's contract string, or on spreads and renamed symbols.

Timeframe row
The chart's timeframe is read from the built-in timeframe variables and normalised
into a short form: ticks as T, seconds as s, minutes as m, whole hours as h, and
D / W / M for daily, weekly and monthly. A 240-minute chart is therefore shown as 4h
rather than 240m, while a value that is not a whole number of hours, such as 45,
stays in minutes.

Custom text row
A free text field, meant to stay short: a header for the checklist behind it, the
name of the session you are trading, or a single rule you want in view.

Each of the three rows can be switched off individually, and the rows are assembled
dynamically - a row that is switched off is removed from the badge rather than left
as an empty gap. A ticker-only badge, a timeframe-only badge, or a note-only badge
are all valid configurations.

Automatic wrapping
Long custom text would stretch the table sideways, so the script includes its own
wrapping routine rather than relying on the user to insert line breaks. It splits the
text into tokens at spaces, assembles lines up to the character limit you choose
(8 to 60), preserves any line breaks you typed manually, and hard-splits a single
token that is longer than the limit - so an unbroken string cannot widen the badge
either. Wrapping can be switched off if you prefer to control every break by hand.

The hover tooltip
The tooltip contains only the text entered in the Additional tooltip text field.
Nothing is copied into it from the rows above, so the visible badge and the hidden
note are written independently. The field accepts line breaks, so the tooltip can
hold a structured list rather than one paragraph. This is where the longer content
belongs: an entry checklist, risk rules, a description of the setup you are waiting
for, or session times.

Styling
Content and appearance are kept separate so the badge can be matched to any theme:

- Nine anchor positions (three columns by three rows of the chart area).
- Background colour and outer frame colour, each with its own transparency value.
- Frame width from 0 to 4; 0 removes the frame for a borderless look.
- Independent text colour for the ticker, the timeframe and the custom text.
- Eight typography presets, combining the two font families Pine supports (system and
  monospace) with bold and italic variants.
- Independent text size for each row.

Switching the badge off clears the table and its background and frame, rather than
leaving an empty box on the chart.

[b]HOW TO USE IT[/b]

1. Add the script and open its settings.
2. Under Content, switch off any row you do not want, and type the short label you
   want permanently visible.
3. Under Hover Tooltip, type the full text you want hidden behind the hover. Use
   blank lines to separate sections so it stays readable.
4. Under Position, move the badge to a corner that does not overlap your other tools.
5. Under Style and Typography, match the colours to your theme. On a dark chart,
   start from a dark background with light text.
6. Hover over the badge to read the note.

If you want two separate notes on one chart, add the script twice and give each copy
a different position.

[b]A NOTE ON THE CODE[/b]

The cell-drawing function contains one branch per typography preset, which looks
repetitive at first reading. This is deliberate: the text_font_family and
text_formatting parameters require constant arguments, so the values cannot be
assembled at runtime from the user's selection and each preset needs its own call
with literal constants.
[b]
LIMITATIONS YOU SHOULD KNOW ABOUT[/b]

- This is a display tool only. It does not analyse price, does not generate signals
  or alerts, and nothing it shows carries any analytical or predictive meaning. It
  cannot tell you what to trade; it can only keep your own written process in view.
- The tooltip needs a mouse pointer. On touch devices and in the mobile app there is
  no hover state, so tooltip content may not be reachable there. It also does not
  appear in chart snapshots or exported images. If you need the text visible in a
  screenshot, put it in the custom text row instead of the tooltip.
- The badge is drawn only on the most recent bar. It is not historical and does not
  change as you scroll back through the chart.
- Wrapping counts characters, not pixel width. With the proportional system font,
  lines of equal character count will not be exactly equal in width. The monospace
  presets give the most even result.
- The badge uses one of the nine standard table anchors. Other indicators placing
  tables in the same corner will stack with it; move one of them if they collide.
- Colours are not theme-aware. Switching between a light and a dark chart requires
  setting the colours again.
- The tooltip text is shared by the whole badge; individual rows do not have separate
  tooltips.
- Very long tooltip text will be cut off by the platform's tooltip display, so keep
  it to a length that can be read at a glance.

The script displays only information you supply and information already present on
the chart. It makes no claim about future price behaviour and is not trading advice.

The source is published under the Mozilla Public License 2.0. If you reuse it, the
House Rules on open-source reuse apply: credit the original author in your
publication's description, make significant improvements to the code base, and
publish your own script open-source.
```

---

[b]## WHAT CHANGED IN THE CODE[/b]

1. Standard licence header plus the `© helmans13` attribution line, and a header
   block stating the reuse terms.
2. Title and shorttitle are now `My Chart [Herman]`, so the tag is permanently
   visible in every user's chart legend.
3. New per-row visibility toggles: **Show ticker** and **Show timeframe**, alongside
   the existing **Show custom text**.
4. Rows are now assembled dynamically with a running row counter. This replaces the
   old placeholder cell (`text_size = 1`) used when the custom text row was hidden,
   which left a thin sliver in the badge.
5. `table.clear` now runs before every redraw, so hidden rows leave no residue.
6. The badge auto-hides when every row is switched off, instead of drawing an empty
   framed box.
7. Explanatory comment above `f_drawCell` so reviewers understand why the branches
   are repetitive.
8. Removed the check-mark characters from the default tooltip text in favour of plain
   hyphens, keeping the source fully 7-bit ASCII.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © helmans13

// ============================================================================
//  MY CHART [Herman]  -  v1.2
//
//  A chart identification badge with an interactive hover note.
//  The badge can show the symbol, timeframe, chart date, day of the week and
//  a short custom line. The full note - a checklist, a rule set, a session plan
//  - is held in the hover tooltip and appears only when the pointer is over it.
//
//  Reuse is permitted under the Mozilla Public License 2.0 and TradingView's
//  House Rules on open-source reuse: credit the original author in your
//  publication's description, make significant improvements to the code base,
//  and publish your script open-source.
// ============================================================================

//@version=6
indicator(
     "My Chart [Herman]",
     shorttitle = "My Chart [Herman]",
     overlay = true,
     behind_chart = false
)

//=============================================================================
// GROUPS
//=============================================================================

const string GROUP_CONTENT  = "1. Content"
const string GROUP_TOOLTIP  = "2. Hover Tooltip"
const string GROUP_POSITION = "3. Position"
const string GROUP_STYLE    = "4. Style"
const string GROUP_TEXT     = "5. Typography"

//=============================================================================
// CONTENT
//=============================================================================

bool showBadge = input.bool(
     true,
     "Show badge",
     group = GROUP_CONTENT
)

bool showTicker = input.bool(
     true,
     "Show ticker",
     tooltip = "Hides the first row. Rows that are switched off are removed, not left blank.",
     group = GROUP_CONTENT
)

string tickerSource = input.string(
     "Automatic",
     "Ticker source",
     options = ["Automatic", "Custom"],
     group = GROUP_CONTENT
)

string customTicker = input.string(
     "NQ1!",
     "Custom ticker",
     group = GROUP_CONTENT
)

bool showTimeframe = input.bool(
     true,
     "Show timeframe",
     group = GROUP_CONTENT
)

bool showDate = input.bool(
     true,
     "Show date",
     tooltip = "Displays the current calendar date in the symbol's exchange time zone.",
     group = GROUP_CONTENT
)

string dateFormatInput = input.string(
     "DD/MM/YYYY",
     "Date format",
     options = [
          "DD/MM/YYYY",
          "MM/DD/YYYY",
          "YYYY-MM-DD",
          "DD-MM-YYYY",
          "DD.MM.YYYY",
          "DD MMM YYYY",
          "MMM DD, YYYY"
     ],
     group = GROUP_CONTENT
)

bool showDayOfWeek = input.bool(
     true,
     "Show day of the week",
     tooltip = "Displays the current weekday in the symbol's exchange time zone.",
     group = GROUP_CONTENT
)

bool showCustomText = input.bool(
     true,
     "Show custom text",
     group = GROUP_CONTENT
)

string customText = input.text_area(
     "My A+ Checklist",
     "Custom text",
     tooltip = "Enter your own text. You can create manual line breaks, or use automatic wrapping below.",
     group = GROUP_CONTENT
)

bool automaticWrapping = input.bool(
     true,
     "Automatic text wrapping",
     tooltip = "Prevents long custom text from stretching the badge across the chart.",
     group = GROUP_CONTENT
)

int wrapLength = input.int(
     22,
     "Characters per line",
     minval = 8,
     maxval = 60,
     tooltip = "Lower values create a narrower badge with more lines.",
     group = GROUP_CONTENT
)

//=============================================================================
// TOOLTIP
//=============================================================================

bool showTooltip = input.bool(
     true,
     "Show tooltip on hover",
     tooltip = "When enabled, the tooltip displays only the Additional tooltip text entered below.",
     group = GROUP_TOOLTIP
)

string additionalTooltipText = input.text_area(
     "MY A+ TRADE CHECKLIST\n\n- Direction confirmed\n- Liquidity swept\n- Entry model present\n- Risk defined\n- Target mapped\n\nNo setup. No trade.",
     "Additional tooltip text",
     tooltip = "This is the only content displayed inside the hover tooltip.",
     group = GROUP_TOOLTIP
)

//=============================================================================
// POSITION
//=============================================================================

string positionInput = input.string(
     "Bottom Right",
     "Badge position",
     options = [
          "Top Left",
          "Top Center",
          "Top Right",
          "Middle Left",
          "Middle Center",
          "Middle Right",
          "Bottom Left",
          "Bottom Center",
          "Bottom Right"
     ],
     group = GROUP_POSITION
)

//=============================================================================
// STYLE
//=============================================================================

bool transparentBackground = input.bool(
     false,
     "Transparency",
     tooltip = "When ON, the table background is removed. Only the text and outer frame remain visible.",
     group = GROUP_STYLE
)

color backgroundColor = input.color(
     color.rgb(238, 240, 244),
     "Background",
     group = GROUP_STYLE
)

int backgroundTransparency = input.int(
     5,
     "Background transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_STYLE
)

color frameColor = input.color(
     color.rgb(164, 169, 180),
     "Outer frame",
     group = GROUP_STYLE
)

int frameTransparency = input.int(
     20,
     "Frame transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_STYLE
)

int frameWidth = input.int(
     1,
     "Frame width",
     minval = 0,
     maxval = 4,
     group = GROUP_STYLE
)

color tickerColor = input.color(
     color.rgb(28, 31, 36),
     "Ticker colour",
     group = GROUP_STYLE
)

color timeframeColor = input.color(
     color.rgb(77, 82, 92),
     "Timeframe colour",
     group = GROUP_STYLE
)

color customTextColor = input.color(
     color.rgb(104, 109, 119),
     "Custom text colour",
     group = GROUP_STYLE
)

//=============================================================================
// TYPOGRAPHY
//=============================================================================

string fontPreset = input.string(
     "System",
     "Font preset",
     options = [
          "System",
          "System Bold",
          "System Italic",
          "System Bold Italic",
          "Monospace",
          "Monospace Bold",
          "Monospace Italic",
          "Monospace Bold Italic"
     ],
     tooltip = "Pine supports System and Monospace font families. Bold and Italic provide additional visual presets.",
     group = GROUP_TEXT
)

string tickerSizeInput = input.string(
     "Small",
     "Ticker size",
     options = ["Tiny", "Small", "Medium", "Large"],
     group = GROUP_TEXT
)

string timeframeSizeInput = input.string(
     "Small",
     "Timeframe size",
     options = ["Tiny", "Small", "Medium", "Large"],
     group = GROUP_TEXT
)

string customTextSizeInput = input.string(
     "Small",
     "Custom text size",
     options = ["Tiny", "Small", "Medium", "Large"],
     group = GROUP_TEXT
)

//=============================================================================
// FUNCTIONS
//=============================================================================

f_sizeInPoints(string selectedSize) =>
    int result = 10

    if selectedSize == "Tiny"
        result := 8
    else if selectedSize == "Small"
        result := 10
    else if selectedSize == "Medium"
        result := 13
    else if selectedSize == "Large"
        result := 17

    result


f_tablePosition(string selectedPosition) =>
    string result = position.bottom_left

    if selectedPosition == "Top Left"
        result := position.top_left
    else if selectedPosition == "Top Center"
        result := position.top_center
    else if selectedPosition == "Top Right"
        result := position.top_right
    else if selectedPosition == "Middle Left"
        result := position.middle_left
    else if selectedPosition == "Middle Center"
        result := position.middle_center
    else if selectedPosition == "Middle Right"
        result := position.middle_right
    else if selectedPosition == "Bottom Left"
        result := position.bottom_left
    else if selectedPosition == "Bottom Center"
        result := position.bottom_center
    else if selectedPosition == "Bottom Right"
        result := position.bottom_right

    result


f_timeframeText() =>
    string result = timeframe.period
    int multiplier = timeframe.multiplier

    if timeframe.isticks
        result := str.tostring(multiplier) + "T"
    else if timeframe.isseconds
        result := str.tostring(multiplier) + "s"
    else if timeframe.isminutes
        if multiplier < 60
            result := str.tostring(multiplier) + "m"
        else if multiplier % 60 == 0
            result := str.tostring(int(multiplier / 60)) + "h"
        else
            result := str.tostring(multiplier) + "m"
    else if timeframe.isdaily
        result := str.tostring(multiplier) + "D"
    else if timeframe.isweekly
        result := str.tostring(multiplier) + "W"
    else if timeframe.ismonthly
        result := str.tostring(multiplier) + "M"

    result


f_datePattern(string selectedFormat) =>
    string result = "dd/MM/yyyy"

    if selectedFormat == "MM/DD/YYYY"
        result := "MM/dd/yyyy"
    else if selectedFormat == "YYYY-MM-DD"
        result := "yyyy-MM-dd"
    else if selectedFormat == "DD-MM-YYYY"
        result := "dd-MM-yyyy"
    else if selectedFormat == "DD.MM.YYYY"
        result := "dd.MM.yyyy"
    else if selectedFormat == "DD MMM YYYY"
        result := "dd MMM yyyy"
    else if selectedFormat == "MMM DD, YYYY"
        result := "MMM dd, yyyy"

    result


f_appendLine(string existingText, string newLine) =>
    string result = existingText

    if str.length(newLine) > 0
        if str.length(result) > 0
            result += "\n"

        result += newLine

    result


// Wraps normal sentences at spaces and also divides long strings without spaces.
f_wrapText(string sourceText, int maximumLength) =>
    string marker = "<LINE_BREAK>"
    string preparedText = str.replace_all(sourceText, "\n", " " + marker + " ")
    array<string> tokens = str.split(preparedText, " ")

    string finishedText = ""
    string currentLine = ""
    int tokenCount = array.size(tokens)

    if tokenCount > 0
        for tokenIndex = 0 to tokenCount - 1
            string token = array.get(tokens, tokenIndex)

            if token == marker
                if str.length(currentLine) > 0
                    finishedText := f_appendLine(finishedText, currentLine)
                    currentLine := ""
                else if str.length(finishedText) > 0
                    finishedText += "\n"

            else if str.length(token) > 0
                int tokenLength = str.length(token)

                if tokenLength > maximumLength
                    if str.length(currentLine) > 0
                        finishedText := f_appendLine(finishedText, currentLine)
                        currentLine := ""

                    int startIndex = 0

                    while startIndex < tokenLength
                        int endIndex = startIndex + maximumLength

                        if endIndex > tokenLength
                            endIndex := tokenLength

                        string tokenPart = str.substring(
                             token,
                             startIndex,
                             endIndex
                        )

                        if endIndex < tokenLength
                            finishedText := f_appendLine(
                                 finishedText,
                                 tokenPart
                            )
                        else
                            currentLine := tokenPart

                        startIndex := endIndex

                else
                    int proposedLength = tokenLength

                    if str.length(currentLine) > 0
                        proposedLength += str.length(currentLine) + 1

                    if proposedLength <= maximumLength
                        if str.length(currentLine) == 0
                            currentLine := token
                        else
                            currentLine += " " + token
                    else
                        finishedText := f_appendLine(
                             finishedText,
                             currentLine
                        )

                        currentLine := token

    if str.length(currentLine) > 0
        finishedText := f_appendLine(
             finishedText,
             currentLine
        )

    finishedText


// Draws one centred table cell using the selected font preset.
//
// The branches below look repetitive on purpose. In Pine, the text_font_family
// and text_formatting parameters of table.cell require constant arguments, so
// the values cannot be assembled at runtime from the user's preset selection.
// Each preset therefore needs its own call with literal constants.
f_drawCell(
     table tableId,
     int rowNumber,
     string displayedText,
     color displayedColour,
     int displayedSize,
     color displayedBackground,
     string displayedTooltip,
     string selectedFontPreset
 ) =>

    if selectedFontPreset == "System Bold"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_default,
             text_formatting = text.format_bold,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "System Italic"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_default,
             text_formatting = text.format_italic,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "System Bold Italic"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_default,
             text_formatting = text.format_bold + text.format_italic,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "Monospace"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_monospace,
             text_formatting = text.format_none,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "Monospace Bold"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_monospace,
             text_formatting = text.format_bold,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "Monospace Italic"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_monospace,
             text_formatting = text.format_italic,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else if selectedFontPreset == "Monospace Bold Italic"
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_monospace,
             text_formatting = text.format_bold + text.format_italic,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

    else
        table.cell(
             tableId,
             0,
             rowNumber,
             displayedText,
             text_color = displayedColour,
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_size = displayedSize,
             text_font_family = font.family_default,
             text_formatting = text.format_none,
             bgcolor = displayedBackground,
             tooltip = displayedTooltip
        )

//=============================================================================
// DISPLAY VALUES
//=============================================================================

string displayedTicker = syminfo.ticker

if tickerSource == "Custom"
    displayedTicker := customTicker

string displayedTimeframe = f_timeframeText()

// Current calendar date and weekday.
// timenow is used instead of the latest bar's timestamp, so weekends and
// non-trading days display the actual current day when the script recalculates.
string displayedDate = str.format_time(
     timenow,
     f_datePattern(dateFormatInput),
     syminfo.timezone
)

string displayedDayOfWeek = str.format_time(
     timenow,
     "EEEE",
     syminfo.timezone
)

string displayedCustomText = customText

if automaticWrapping
    displayedCustomText := f_wrapText(
         customText,
         wrapLength
    )

//=============================================================================
// SIZES
//=============================================================================

int tickerSize = f_sizeInPoints(
     tickerSizeInput
)

int timeframeSize = f_sizeInPoints(
     timeframeSizeInput
)

int customTextSize = f_sizeInPoints(
     customTextSizeInput
)

//=============================================================================
// TOOLTIP CONTENT
// Only Additional tooltip text is displayed.
//=============================================================================

string tooltipText = ""

if showTooltip and str.length(additionalTooltipText) > 0
    tooltipText := additionalTooltipText

//=============================================================================
// COLOURS AND POSITION
//=============================================================================

color badgeBackground = color.new(
     backgroundColor,
     backgroundTransparency
)

color badgeFrame = color.new(
     frameColor,
     frameTransparency
)

color fullyTransparent = color.new(
     backgroundColor,
     100
)

color activeCellBackground = badgeBackground

if transparentBackground
    activeCellBackground := fullyTransparent

string badgePosition = f_tablePosition(
     positionInput
)

//=============================================================================
// VISIBILITY
//=============================================================================

bool anyRowVisible = showTicker or showTimeframe or showDate or showDayOfWeek or showCustomText
bool badgeVisible  = showBadge and anyRowVisible

//=============================================================================
// TABLE
//=============================================================================

var table badge = table.new(
     position.bottom_right,
     1,
     5,
     bgcolor = color.new(color.white, 100),
     frame_color = color.new(color.white, 100),
     frame_width = 0,
     border_color = color.new(color.white, 100),
     border_width = 0
)

//=============================================================================
// DRAWING
// Rows are assembled dynamically, so a row that is switched off is removed
// from the badge rather than left as an empty gap.
//=============================================================================

if barstate.islast
    table.set_position(
         badge,
         badgePosition
    )

    table.clear(
         badge,
         0,
         0,
         0,
         4
    )

    if badgeVisible
        table.set_bgcolor(
             badge,
             activeCellBackground
        )

        table.set_frame_color(
             badge,
             badgeFrame
        )

        table.set_frame_width(
             badge,
             frameWidth
        )

        table.set_border_color(
             badge,
             fullyTransparent
        )

        table.set_border_width(
             badge,
             0
        )

        int rowNumber = 0

        // Ticker.
        if showTicker
            f_drawCell(
                 badge,
                 rowNumber,
                 displayedTicker,
                 tickerColor,
                 tickerSize,
                 activeCellBackground,
                 tooltipText,
                 fontPreset
            )

            rowNumber += 1

        // Automatic timeframe.
        if showTimeframe
            f_drawCell(
                 badge,
                 rowNumber,
                 displayedTimeframe,
                 timeframeColor,
                 timeframeSize,
                 activeCellBackground,
                 tooltipText,
                 fontPreset
            )

            rowNumber += 1

        // Current calendar date.
        if showDate
            f_drawCell(
                 badge,
                 rowNumber,
                 displayedDate,
                 timeframeColor,
                 timeframeSize,
                 activeCellBackground,
                 tooltipText,
                 fontPreset
            )

            rowNumber += 1

        // Current day of the week.
        if showDayOfWeek
            f_drawCell(
                 badge,
                 rowNumber,
                 displayedDayOfWeek,
                 timeframeColor,
                 timeframeSize,
                 activeCellBackground,
                 tooltipText,
                 fontPreset
            )

            rowNumber += 1

        // Custom text.
        if showCustomText
            f_drawCell(
                 badge,
                 rowNumber,
                 displayedCustomText,
                 customTextColor,
                 customTextSize,
                 activeCellBackground,
                 tooltipText,
                 fontPreset
            )

    else
        table.set_bgcolor(
             badge,
             fullyTransparent
        )

        table.set_frame_color(
             badge,
             fullyTransparent
        )

        table.set_frame_width(
             badge,
             0
        )
````
