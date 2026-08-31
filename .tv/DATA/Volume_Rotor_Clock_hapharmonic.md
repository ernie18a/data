<!-- tradingview-pine-id: PUB;832cde6d2a0646a5be95057e61d9fd5b -->
<!-- tradingviewscripts-format: 1 -->
# Volume Rotor Clock [hapharmonic]

Source: https://www.tradingview.com/script/8nJGAsbV-Volume-Rotor-Clock-hapharmonic/

## Description

🕰️ Volume Rotor Clock

The Volume Rotor Clock is an indicator that separates buy and sell volume, compiling these volumes over a recent number of bars or a specified past period, as defined by the user. This helps to reveal accumulation (buying) or distribution (selling) behavior, showing which side has superior volume. With its unique and beautiful display, the Volume Rotor Clock is more than just a timepiece; it's a dynamic dashboard that visualizes the buying and selling pressure of your favorite symbols, all wrapped in an elegant and fully customizable interface.

Instead of just tracking price, this indicator focuses on the engine behind the movement: volume. It helps you instantly identify which assets are under accumulation (buying) and which are under distribution (selling).

---

🎨 20 Pre-configured Templates
[image]https://www.tradingview.com/x/la4JmyIb/[/image]
[image]https://www.tradingview.com/x/sBfkz1Z8/[/image]
[image]https://www.tradingview.com/x/lWGs3QIp/[/image]
[image]https://www.tradingview.com/x/gX72984g/[/image]
[image]https://www.tradingview.com/x/oqrfyeKG/[/image]
[image]https://www.tradingview.com/x/cu05MXNP/[/image]
[image]https://www.tradingview.com/x/wLzRBlBX/[/image]

---

🧐 Interpreting the Clock Display

The interface is designed to give you multiple layers of information at a glance. Let's break down what each part represents.

1. The Main Clock Hands (Current Chart Symbol)
The clock hands—hour, minute, and second—are dedicated to the symbol on your current active chart.

[*] Minute Hand: Displays the base currency of the current symbol (e.g., USDT, USD) at its tip.
[*] Hour Hand: Displays the percentage of the winning volume side (buy vs. sell) at its tip.
[*] Color Gauge: The color of the text characters at the tip of both the hour and minute hands acts as your primary volume gauge for the current symbol.

[*] If buy volume is dominant, the text will be green.
[*] If sell volume is dominant, the text will be red.

[*] Tooltip: Hovering your mouse over the text at the tip of the hour or minute or other spherical elements hand will reveal a detailed tooltip with the precise Buy Volume, Sell Volume, Total Volume, Buy %, and Sell % for the current chart's symbol.

2. The Volume Scanner: Bulls & Bears (Symbols Inside the Clock) 🐂🐻
The circular symbols scattered inside the clock face are your multi-symbol volume scanner. They represent the assets you've selected in the indicator's settings.

[*] Green Circles (Bulls - Upper Half): These represent symbols from your list where the total buy volume is greater than the total sell volume over the defined "Lookback" period. They are considered to be under bullish accumulation. The size of the circle and its text grows larger as the buy percentage becomes more dominant. The percentage shown within the circle represents the buy volume's share of the total volume, calculated over the 'Lookback (Bars)' you've set.
[*] Red Circles (Bears - Lower Half): These represent symbols where the total sell volume is greater than the total buy volume. They are considered to be under bearish distribution or selling pressure. The size of the circle indicates the dominance of the sell-side volume. The percentage shown within the circle represents the sell volume's share of the total volume, calculated over the 'Lookback (Bars)' you've set.

3. The Bullish Watchlist (Symbols Above the Clock) ⭐
The symbols arranged neatly along the top edge of the clock are the "best of the bulls." They are symbols that are not only bullish but have also passed an additional, powerful strength filter.

[*] What it Means: A symbol appears here when it shows signs of sustained, high-volume buying interest. It's a way to filter out noise and focus on assets with potentially significant accumulation phases.
[*] The Filter Logic: For a bullish symbol (where total buy volume > total sell volume) to be promoted to the watchlist, its trading volume must meet specific criteria based on this formula:
[pine]
ta.barssince(not(volume > ta.sma(volume, X))) >= Y
[/pine]

[*] In plain English, this means: The indicator checks how many consecutive bars the `volume` has been greater than its `X`-bar Simple Moving Average (`ta.sma(volume, X)`). If this count is greater than or equal to `Y` bars, the condition is met.
[*] (You can configure `X` (Volume MA Length) and `Y` (Consecutive Days Above MA) in the settings.)

[*] Why it's Useful: This filter is powerful because it looks for consistency. A single spike in volume can be an anomaly. However, when an asset's volume remains consistently above its recent average for several consecutive days, it strongly suggests that larger players or a significant portion of the market are actively accumulating the asset. This sustained interest can often precede a significant upward price trend.

---

⚙️ Indicator Settings Explained

The Volume Rotor Clock is highly customizable. Here’s a detailed walkthrough of every setting available in the "Inputs" tab.

🎨 Color Scheme
This group allows you to control the entire aesthetic of the clock.

[*] Template: Choose from a wide variety of professionally designed color themes.
[*] Use Template: A simple checkbox to switch between using a pre-designed theme and creating your own.

[*] `Checked`: You can select a theme from the dropdown menu, which offers 20 unique templates like "Cyberpunk Neon" or "Forest Green". All custom color settings below will be disabled (grayed out and unclickable).
[*] `Unchecked`: The template dropdown is disabled, and you gain full control over every color element in the sections below.

🖌️ Custom Appearance & Colors
These settings are only active when "Use Template" is unchecked.

[*] Flame Head / Tail: Sets the start and end colors for the dynamic flame effect that traces the clock's border, representing the second hand.
[*] Numbers / Main Numbers: Customize the color of the regular hour numbers (1, 2, 4, 5...) and the main cardinal numbers (3, 6, 9, 12).
[*] Sunburst Colors (1-6): Controls the six colors used in the gradient background for the "sunburst" effect inside the clock face.
[*] Hands & Digital: Fine-tune the colors for the Hour/Minute Hand, Second Hand, central Pivot point, and the digital time display.
[*] Chain Color / Width: Customize the appearance of the two chains holding the clock.

📡 Volume Scanner
Control the behavior of the multi-symbol scanner.

[*] Show Scanner Labels: A master switch to show or hide all the bull/bear symbol circles inside the clock.
[*] Lookback (Bars): A crucial setting that defines the calculation period for buy/sell volume for all scanned symbols. The calculation is a sum over the specified number of recent bars.

[*] `0`: Calculates using the current bar only.
[*] `7`: Calculates the sum of volume over the last 8 bars (the current bar + 7 historical bars).

[*] Symbols List: Here you can enable/disable up to 20 slots and input the ticker for each symbol you want to scan (e.g., [symbol="BINANCE:BTCUSDT"]BINANCE:BTCUSDT[/symbol], [symbol="NASDAQ:AAPL"]NASDAQ:AAPL[/symbol]).

⭐ Bullish Watchlist Filter
Configure the criteria for the elite watchlist symbols displayed above the clock.

[*] Enable Watchlist: A master switch to turn the entire watchlist feature on or off.
[*] Volume MA Length: Sets the lookback period `(X)` for the Simple Moving Average of volume used in the filter.
[*] Consecutive Days Above MA: Sets the minimum number of consecutive days `(Y)` that volume must close above its MA to qualify.
[*] Symbols Per Row: Determines the maximum number of watchlist symbols that can fit in a single row before a new row is created above it.
[*] Background / Text Color: When not using a template, you can set custom colors for the watchlist symbols' background and text.

📏 Position & Size
Adjust the clock's placement and dimensions on your chart.

[*] Clock Timezone: Sets the timezone for the digital and analog time display. You can use standard formats like "America/New_York" or enter "Exchange" to sync with the chart's timezone.
[*] Radius (Bars): Controls the overall size of the clock. The radius is measured in terms of the number of bars on the x-axis.
[*] X Offset (Bars): Moves the entire clock horizontally. Positive values shift it to the right; negative values shift it to the left.
[*] Y Offset (Price %): Moves the entire clock vertically as a percentage of your screen's price pane. Positive values move it up; negative values move it down.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hapharmonic

//@version=6
indicator('Volume Rotor Clock [hapharmonic]','Volume Rotor Clock', overlay=true, max_lines_count=500, max_polylines_count=100, max_labels_count=150, calc_bars_count=1000)

// --- UDTs (User-Defined Types) ---
type Snowflake
    float x_offset
    float y_offset
    float speed
    float sway
    label lbl

type SymbolStats
    string name
    string baseCurrency
    float totalBuyVol
    float totalSellVol
    bool isOnWatchlist
    label lbl_text
    label lbl_bg

type ColorScheme
    color flame1
    color flame2
    color numbers
    color mainNumbers
    color sunburst1
    color sunburst2
    color sunburst3
    color sunburst4
    color sunburst5
    color sunburst6
    color hands
    color second
    color pivot
    color digital
    color chain
    color watchlistBg
    color watchlistText

// --- Enums ---
enum ColorTemplate
    Default
    OceanBlue
    SunsetOrange
    ForestGreen
    CyberpunkNeon
    Monochrome
    RoyalGold
    RubyRed
    EmeraldGreen
    ArcticIce
    NeonBlade
    DataStream
    QuantumPink
    BioHazard
    NightRider
    ArcadeFlash
    HoloGlow
    Synthwave
    GlitchCore
    PlasmaBurn

import n00btraders/Timezone/1 as TZ

// --- Helper Functions ---
f_getRainbowColor(float value, color c1, color c2, color c3, color c4, color c5, color c6) =>
    if value < 1.0 / 6.0
        color.from_gradient(value, 0.0, 1.0 / 6.0, c1, c2)
    else if value < 2.0 / 6.0
        color.from_gradient(value, 1.0 / 6.0, 2.0 / 6.0, c2, c3)
    else if value < 3.0 / 6.0
        color.from_gradient(value, 2.0 / 6.0, 3.0 / 6.0, c3, c4)
    else if value < 4.0 / 6.0
        color.from_gradient(value, 3.0 / 6.0, 4.0 / 6.0, c4, c5)
    else if value < 5.0 / 6.0
        color.from_gradient(value, 4.0 / 6.0, 5.0 / 6.0, c5, c6)
    else
        color.from_gradient(value, 5.0 / 6.0, 1.0, c6, c1)

f_calculateBuySellVolume(float o, float h, float l, float c, float v) =>
    float buyVolume = 0.0
    float sellVolume = 0.0
    if h > l
        buyVolume := v * (c - l) / (h - l)
        sellVolume := v * (h - c) / (h - l)
    else
        buyVolume := v / 2
        sellVolume := v / 2
    [math.max(0, buyVolume), math.max(0, sellVolume)]

f_formatVolume(float value) =>
    if value >= 1e9
        str.tostring(value / 1e9, "#.##B")
    else if value >= 1e6
        str.tostring(value / 1e6, "#.##M")
    else if value >= 1e3
        str.tostring(value / 1e3, "#.##K")
    else
        str.tostring(value, "#.##")

f_getCircleSize(float percentage) =>
    if percentage >= 75
        size.huge
    else if percentage >= 50
        size.large
    else if percentage >= 25
        size.normal
    else
        size.small

f_getTextSize(float percentage) =>
    if percentage >= 75
        size.normal
    else if percentage >= 50
        size.small
    else
        size.tiny

f_getColorScheme(ColorTemplate template) =>
    color handsColor = #c0c0c0c2
    color digitalColor = #36454F
    color chainColor = #964B00
    color watchlistBg = color.new(color.yellow, 60)
    color watchlistText = color.new(color.white, 0)
    switch template
        ColorTemplate.Default => ColorScheme.new(#FF00FF, #4B0082, #FFFFFF, #FFFF00, #FF0000, #FFA500, #FFFF00, #008000, #0000FF, #4B0082, handsColor, #FF0000, #FF0000, digitalColor, chainColor, watchlistBg, watchlistText)
        ColorTemplate.OceanBlue => ColorScheme.new(#00FFFF, #00008B, #FFFFFF, #ADD8E6, #00FFFF, #7DF9FF, #ADD8E6, #B0E0E6, #87CEEB, #6495ED, handsColor, #32CD32, #32CD32, digitalColor, chainColor, color.new(#6495ED, 50), watchlistText)
        ColorTemplate.SunsetOrange => ColorScheme.new(#FF4500, #483D8B, #FFFFE0, #FFD700, #FF6347, #FFA07A, #FFDAB9, #F0E68C, #FFDEAD, #D2B48C, handsColor, #FF6347, #FF6347, digitalColor, chainColor, color.new(#FF6347, 50), watchlistText)
        ColorTemplate.ForestGreen => ColorScheme.new(#9ACD32, #006400, #F5F5DC, #9ACD32, #006400, #32CD32, #ADFF2F, #6B8E23, #556B2F, #2E8B57, handsColor, #9ACD32, #9ACD32, digitalColor, chainColor, color.new(#6B8E23, 50), watchlistText)
        ColorTemplate.CyberpunkNeon => ColorScheme.new(#FF00FF, #00FFFF, #FFFFFF, #00FF00, #FF1493, #00BFFF, #7FFF00, #FF00FF, #00FFFF, #FFD700, handsColor, #FF0000, #FF0000, digitalColor, #8A2BE2, color.new(#FF1493, 50), watchlistText)
        ColorTemplate.Monochrome => ColorScheme.new(#FFFFFF, #000000, #FFFFFF, #000000, #FFFFFF, #D3D3D3, #A9A9A9, #808080, #696969, #000000, handsColor, #FF0000, #FF0000, digitalColor, #696969, color.new(color.gray, 50), watchlistText)
        ColorTemplate.RoyalGold => ColorScheme.new(#FFD700, #4B0082, #FFFFFF, #FFFF00, #800080, #9400D3, #BA55D3, #DA70D6, #FFD700, #B8860B, handsColor, #FF0000, #FF0000, digitalColor, #B8860B, color.new(#B8860B, 50), watchlistText)
        ColorTemplate.RubyRed => ColorScheme.new(#FF4500, #8B0000, #FFFFFF, #FFD700, #8B0000, #B22222, #CD5C5C, #E9967A, #F08080, #FFA07A, handsColor, #FFFFFF, #FFFFFF, digitalColor, chainColor, color.new(#B22222, 50), watchlistText)
        ColorTemplate.EmeraldGreen => ColorScheme.new(#00FF7F, #006400, #FFFFFF, #ADFF2F, #006400, #2E8B57, #3CB371, #66CDAA, #98FB98, #F0FFF0, handsColor, #FFFFFF, #FFFFFF, digitalColor, chainColor, color.new(#3CB371, 50), watchlistText)
        ColorTemplate.ArcticIce => ColorScheme.new(#00FFFF, #00008B, #000000, #FFFFFF, #F0FFFF, #E0FFFF, #AFEEEE, #7FFFD4, #66CDAA, #5F9EA0, handsColor, #00FFFF, #00FFFF, digitalColor, chainColor, color.new(#AFEEEE, 50), watchlistText)
        ColorTemplate.NeonBlade => ColorScheme.new(#F31559, #00BFFF, #FFFFFF, #76E5B1, #00F5D4, #00EAD3, #00E0C7, #00D5BB, #00CBAF, #00C1A3, handsColor, #FF2E63, #FF2E63, digitalColor, #00BFFF, color.new(#76E5B1, 50), watchlistText)
        ColorTemplate.DataStream => ColorScheme.new(#42C2FF, #006400, #EFFFFD, #B8FFD9, #00A19D, #00B8A9, #00CFB2, #00E6B9, #00FFBE, #00FFB2, handsColor, #07F2F2, #07F2F2, digitalColor, #00A19D, color.new(#B8FFD9, 50), watchlistText)
        ColorTemplate.QuantumPink => ColorScheme.new(#FF00A8, #4B0082, #F0F0F0, #FFB6C1, #FF007F, #FF3399, #FF66B2, #FF99CC, #FFCCE5, #FFE5F2, handsColor, #FF33A1, #FF33A1, digitalColor, #FF00A8, color.new(#FFB6C1, 50), watchlistText)
        ColorTemplate.BioHazard => ColorScheme.new(#BFFF00, #8A2BE2, #1A1A1A, #FFFFFF, #ADFF2F, #9ACD32, #6B8E23, #556B2F, #334411, #112200, handsColor, #FFD700, #FFD700, digitalColor, #6B8E23, color.new(#ADFF2F, 50), watchlistText)
        ColorTemplate.NightRider => ColorScheme.new(#E02929, #B00000, #FFFFFF, #CCCCCC, #FF0000, #E60000, #CC0000, #B30000, #990000, #800000, handsColor, #FF3030, #FF3030, digitalColor, #800000, color.new(color.gray, 50), watchlistText)
        ColorTemplate.ArcadeFlash => ColorScheme.new(#FF7B00, #800080, #FFFFFF, #00FFD1, #FFAC42, #FFC173, #FFD6A3, #FFEB00, #FFF599, #FFFF00, handsColor, #FF4500, #FF4500, digitalColor, #800080, color.new(#FFEB00, 50), watchlistText)
        ColorTemplate.HoloGlow => ColorScheme.new(#9370DB, #00FFFF, #F0F0F0, #FFFFFF, #C792EA, #D1A4EA, #DCB6EC, #E7C8EE, #F2DAF0, #FDECF2, handsColor, #00FFFF, #00FFFF, digitalColor, #9370DB, color.new(#E7C8EE, 50), watchlistText)
        ColorTemplate.Synthwave => ColorScheme.new(#FF00C1, #FF8C00, #FFFFFF, #00E5FF, #FF00A8, #FF24B2, #FF47BC, #FF6BC6, #FF8FD0, #FFB2DA, handsColor, #F200A2, #F200A2, digitalColor, #FF00C1, color.new(#FFB2DA, 50), watchlistText)
        ColorTemplate.GlitchCore => ColorScheme.new(#00FF41, #FF0054, #F0F0F0, #FFFFFF, #00FF00, #33FF33, #66FF66, #FF0033, #FF3366, #FF6699, handsColor, #FFFF00, #FFFF00, digitalColor, #FF0054, color.new(color.yellow, 50), watchlistText)
        ColorTemplate.PlasmaBurn => ColorScheme.new(#FF8000, #0000CD, #FFFFE0, #FFD700, #FF2400, #FF5349, #FF8066, #FFAC80, #FFD599, #FFFFB3, handsColor, #FF0000, #FF0000, digitalColor, #FF8000, color.new(#FFD700, 50), watchlistText)

// --- Settings ---
dis = display.none
string GRP_COLORS = "Color Scheme"
bool i_useTemplate = input.bool(true, "", group = GRP_COLORS,inline = 'c1', tooltip = "Enable to use pre-defined color templates. Disable to set custom colors.")
ColorTemplate i_template = input.enum(ColorTemplate.CyberpunkNeon, "Use Template", group = GRP_COLORS, active = i_useTemplate, inline = 'c1', tooltip = "Select a pre-defined color theme for the clock.",display = dis)

string GRP_CUSTOM_APPEARANCE = "Custom Appearance"
color i_flameColor1 = input.color(color.new(color.fuchsia, 0), "Flame Head", group = GRP_CUSTOM_APPEARANCE, inline = "g2", active = not i_useTemplate, tooltip = "Sets the start color (head) of the flame effect on the clock's border.")
color i_flameColor2 = input.color(color.new(color.blue, 70), "Flame Tail", group = GRP_CUSTOM_APPEARANCE, inline = "g2", active = not i_useTemplate, tooltip = "Sets the end color (tail) of the flame effect.")
color i_numberColor = input.color(color.new(color.white, 10), "Numbers", group = GRP_CUSTOM_APPEARANCE, active = not i_useTemplate, tooltip = "Sets the color for the regular hour numbers (1, 2, 4, 5, etc.).")
color i_mainNumberColor = input.color(color.new(color.yellow, 0), "Main Numbers", group = GRP_CUSTOM_APPEARANCE, active = not i_useTemplate, tooltip = "Sets the color for the main hour numbers (3, 6, 9, 12).")

string GRP_CUSTOM_SUNBURST = "Custom Sunburst Colors"
color i_sunburst1 = input.color(color.red, "1", group=GRP_CUSTOM_SUNBURST, inline="s1", active = not i_useTemplate, tooltip = "Sets the first of six colors for the sunburst background effect.")
color i_sunburst2 = input.color(color.orange, "2", group=GRP_CUSTOM_SUNBURST, inline="s1", active = not i_useTemplate, tooltip = "Sets the second of six colors for the sunburst background effect.")
color i_sunburst3 = input.color(color.yellow, "3", group=GRP_CUSTOM_SUNBURST, inline="s1", active = not i_useTemplate, tooltip = "Sets the third of six colors for the sunburst background effect.")
color i_sunburst4 = input.color(color.green, "4", group=GRP_CUSTOM_SUNBURST, inline="s2", active = not i_useTemplate, tooltip = "Sets the fourth of six colors for the sunburst background effect.")
color i_sunburst5 = input.color(color.blue, "5", group=GRP_CUSTOM_SUNBURST, inline="s2", active = not i_useTemplate, tooltip = "Sets the fifth of six colors for the sunburst background effect.")
color i_sunburst6 = input.color(#4B0082, "6", group=GRP_CUSTOM_SUNBURST, inline="s2", active = not i_useTemplate, tooltip = "Sets the sixth of six colors for the sunburst background effect.")

string GRP_CUSTOM_HANDS = "Custom Hands & Digital"
color i_hourColor = input.color(#c0c0c0c2, "Hour/Minute Hand", group = GRP_CUSTOM_HANDS, inline = "g3", active = not i_useTemplate, tooltip = "Sets the color for the hour and minute hands.")
color i_secColor = input.color(color.new(color.red, 0), "Second", group = GRP_CUSTOM_HANDS, inline = "g3", active = not i_useTemplate, tooltip = "Sets the color for the second hand.")
color i_pivotColor = input.color(color.new(color.red, 0), "Pivot", group = GRP_CUSTOM_HANDS, inline = "g3", active = not i_useTemplate, tooltip = "Sets the color for the central pivot point of the hands.")
color i_digitalColor = input.color(#36454F, "Digital", group = GRP_CUSTOM_HANDS, active = not i_useTemplate, tooltip = "Sets the color for the digital time display text.")
color i_chainColor = input.color(#964B00, "Chain", group = GRP_CUSTOM_HANDS, active = not i_useTemplate, tooltip = "Sets the color of the hanging chains.")
int i_chainWidth = input.int(4, "Chain Width", minval=1, maxval=10, group = GRP_CUSTOM_HANDS, active = not i_useTemplate, tooltip = "Sets the width of the hanging chains.",display = dis)

string GRP_SCANNER = "Volume Scanner"
bool i_showScanner = input.bool(true, "Show Scanner Labels", group = GRP_SCANNER, tooltip = "Show or hide the volume scanner symbol labels inside the clock.")
int i_lookbackBars = input.int(3, "Lookback (Bars)", minval=0, group = GRP_SCANNER, tooltip = "Number of recent bars to calculate the total buy/sell volume for the scanner.",display = dis)

string GRP_WATCHLIST = "Bullish Watchlist Filter"
bool i_enableWatchlist = input.bool(true, "Enable Watchlist", group = GRP_WATCHLIST, tooltip = "Enable the special watchlist filter for bullish symbols that meet the volume criteria.")
int i_watchlistMaLength = input.int(10, "Volume MA Length", minval=1, group = GRP_WATCHLIST, active = i_enableWatchlist, tooltip = "The lookback period for the Volume Moving Average.",display = dis)
int i_consecutiveDays = input.int(3, "Consecutive Days Above MA", minval=1, group = GRP_WATCHLIST, active = i_enableWatchlist, tooltip = "The minimum number of consecutive bars the volume must be above its MA to be included in the watchlist.",display = dis)
int i_watchlistSymbolsPerRow = input.int(5, "Symbols Per Row", minval=1, maxval=6, group = GRP_WATCHLIST, active = i_enableWatchlist, tooltip = "Maximum number of watchlist symbols to display in a single row above the clock.",display = dis)
float i_watchlistVOffset = 1.1 //Adjusts how far the watchlist symbols appear above the clock. >1 moves them further away.
color i_watchlistBgColor = input.color(color.new(color.yellow, 60), "Background", group = GRP_WATCHLIST, inline = "w1", active = i_enableWatchlist and not i_useTemplate, tooltip = "Set the custom background color for watchlist symbols.")
color i_watchlistTextColor = input.color(color.new(color.white, 0), "Text", group = GRP_WATCHLIST, inline = "w1", active = i_enableWatchlist and not i_useTemplate, tooltip = "Set the custom text color for watchlist symbols.")

string GRP_SCANNER_TABLE = "  ON/OFF || Symbols"
bool show_s01 = input.bool(true, "", inline = "s01", group = GRP_SCANNER_TABLE), string s01 = input.symbol("BINANCE:BTCUSDT" , "", inline = "s01", group = GRP_SCANNER_TABLE, active=show_s01 and i_showScanner,display = dis)
bool show_s02 = input.bool(true, "", inline = "s02", group = GRP_SCANNER_TABLE), string s02 = input.symbol("BINANCE:ETHUSDT" , "", inline = "s02", group = GRP_SCANNER_TABLE, active=show_s02 and i_showScanner,display = dis)
bool show_s03 = input.bool(true, "", inline = "s03", group = GRP_SCANNER_TABLE), string s03 = input.symbol("BINANCE:SOLUSDT" , "", inline = "s03", group = GRP_SCANNER_TABLE, active=show_s03 and i_showScanner,display = dis)
bool show_s04 = input.bool(true, "", inline = "s04", group = GRP_SCANNER_TABLE), string s04 = input.symbol("BINANCE:BNBUSDT" , "", inline = "s04", group = GRP_SCANNER_TABLE, active=show_s04 and i_showScanner,display = dis)
bool show_s05 = input.bool(true, "", inline = "s05", group = GRP_SCANNER_TABLE), string s05 = input.symbol("BINANCE:ADAUSDT" , "", inline = "s05", group = GRP_SCANNER_TABLE, active=show_s05 and i_showScanner,display = dis)
bool show_s06 = input.bool(true, "", inline = "s06", group = GRP_SCANNER_TABLE), string s06 = input.symbol("BINANCE:DOTUSDT" , "", inline = "s06", group = GRP_SCANNER_TABLE, active=show_s06 and i_showScanner,display = dis)
bool show_s07 = input.bool(true, "", inline = "s07", group = GRP_SCANNER_TABLE), string s07 = input.symbol("BINANCE:DOGEUSDT", "", inline = "s07", group = GRP_SCANNER_TABLE, active=show_s07 and i_showScanner,display = dis)
bool show_s08 = input.bool(true, "", inline = "s08", group = GRP_SCANNER_TABLE), string s08 = input.symbol("BINANCE:AVAXUSDT", "", inline = "s08", group = GRP_SCANNER_TABLE, active=show_s08 and i_showScanner,display = dis)
bool show_s09 = input.bool(true, "", inline = "s09", group = GRP_SCANNER_TABLE), string s09 = input.symbol("BINANCE:LUNAUSDT", "", inline = "s09", group = GRP_SCANNER_TABLE, active=show_s09 and i_showScanner,display = dis)
bool show_s10 = input.bool(true, "", inline = "s10", group = GRP_SCANNER_TABLE), string s10 = input.symbol("BINANCE:LINKUSDT", "", inline = "s10", group = GRP_SCANNER_TABLE, active=show_s10 and i_showScanner,display = dis)
bool show_s11 = input.bool(true, "", inline = "s11", group = GRP_SCANNER_TABLE), string s11 = input.symbol("BINANCE:UNIUSDT" , "", inline = "s11", group = GRP_SCANNER_TABLE, active=show_s11 and i_showScanner,display = dis)
bool show_s12 = input.bool(true, "", inline = "s12", group = GRP_SCANNER_TABLE), string s12 = input.symbol("BINANCE:SHIBUSDT", "", inline = "s12", group = GRP_SCANNER_TABLE, active=show_s12 and i_showScanner,display = dis)
bool show_s13 = input.bool(true, "", inline = "s13", group = GRP_SCANNER_TABLE), string s13 = input.symbol("BINANCE:TRXUSDT" , "", inline = "s13", group = GRP_SCANNER_TABLE, active=show_s13 and i_showScanner,display = dis)
bool show_s14 = input.bool(true, "", inline = "s14", group = GRP_SCANNER_TABLE), string s14 = input.symbol("BINANCE:XRPUSDT" , "", inline = "s14", group = GRP_SCANNER_TABLE, active=show_s14 and i_showScanner,display = dis)
bool show_s15 = input.bool(true, "", inline = "s15", group = GRP_SCANNER_TABLE), string s15 = input.symbol("BINANCE:LTCUSDT" , "", inline = "s15", group = GRP_SCANNER_TABLE, active=show_s15 and i_showScanner,display = dis)
bool show_s16 = input.bool(true, "", inline = "s16", group = GRP_SCANNER_TABLE), string s16 = input.symbol("BINANCE:ALGOUSDT", "", inline = "s16", group = GRP_SCANNER_TABLE, active=show_s16 and i_showScanner,display = dis)
bool show_s17 = input.bool(true, "", inline = "s17", group = GRP_SCANNER_TABLE), string s17 = input.symbol("BINANCE:ATOMUSDT", "", inline = "s17", group = GRP_SCANNER_TABLE, active=show_s17 and i_showScanner,display = dis)
bool show_s18 = input.bool(true, "", inline = "s18", group = GRP_SCANNER_TABLE), string s18 = input.symbol("BINANCE:TONUSDT" , "", inline = "s18", group = GRP_SCANNER_TABLE, active=show_s18 and i_showScanner,display = dis)
bool show_s19 = input.bool(true, "", inline = "s19", group = GRP_SCANNER_TABLE), string s19 = input.symbol("BINANCE:AXSUSDT" , "", inline = "s19", group = GRP_SCANNER_TABLE, active=show_s19 and i_showScanner,display = dis)
bool show_s20 = input.bool(true, "", inline = "s20", group = GRP_SCANNER_TABLE), string s20 = input.symbol("BINANCE:SANDUSDT", "", inline = "s20", group = GRP_SCANNER_TABLE, active=show_s20 and i_showScanner,display = dis)
string GRP_POS = "Position & Size"
string i_timezone = str.tostring(input.enum(TZ.TimezoneID.EXCHANGE, "Clock Timezone", group = GRP_POS, tooltip = "Set the timezone for the clock's time display. Use 'Exchange' for the chart's timezone or format like 'Asia/Bangkok'.",display = dis))
string effectiveTimezone = i_timezone == str.tostring(TZ.TimezoneID.EXCHANGE) ? syminfo.timezone : i_timezone
int i_radius = input.int(25, "Radius (Bars)", minval=10, group = GRP_POS, inline = "g4", tooltip = "Adjusts the overall size (radius) of the clock face, measured in bars.",display = dis)
int i_xOffset = input.int(30, "X Offset (Bars)", group = GRP_POS, inline = "g4", tooltip = "Moves the clock horizontally. Positive values move it to the right, negative to the left.",display = dis)
float i_yOffset = input.float(0, "Y Offset (Price %)", step = 5, group = GRP_POS, tooltip = "Moves the clock vertically. Positive values move it up, negative down, as a percentage of the price pane.",display = dis)

// --- Color Logic ---
ColorScheme cs = i_useTemplate ? f_getColorScheme(i_template) : ColorScheme.new(i_flameColor1, i_flameColor2, i_numberColor, i_mainNumberColor, i_sunburst1, i_sunburst2, i_sunburst3, i_sunburst4, i_sunburst5, i_sunburst6, i_hourColor, i_secColor, i_pivotColor, i_digitalColor, i_chainColor, i_watchlistBgColor, i_watchlistTextColor)

// --- Global Scope Calculations ---
var symbolStats = array.new<SymbolStats>()

f_getSymbolStats(bool show, string symbol) =>
    SymbolStats result = SymbolStats.new(symbol, isOnWatchlist=false)
    if show
        [o, h, l, c, v, b, barsSince] = request.security(symbol, '', [open, high, low, close, volume, syminfo.basecurrency, ta.barssince(not(volume > ta.sma(volume, i_watchlistMaLength)))], ignore_invalid_symbol=true)
        result.baseCurrency := b
        [buy, sell] = f_calculateBuySellVolume(o, h, l, c, v)
        result.totalBuyVol := math.sum(buy, i_lookbackBars + 1)
        result.totalSellVol := math.sum(sell, i_lookbackBars + 1)
        if i_enableWatchlist and barsSince >= i_consecutiveDays
            result.isOnWatchlist := true
    result

array.clear(symbolStats)
symbolStats.push(f_getSymbolStats(show_s01, s01))
symbolStats.push(f_getSymbolStats(show_s02, s02))
symbolStats.push(f_getSymbolStats(show_s03, s03))
symbolStats.push(f_getSymbolStats(show_s04, s04))
symbolStats.push(f_getSymbolStats(show_s05, s05))
symbolStats.push(f_getSymbolStats(show_s06, s06))
symbolStats.push(f_getSymbolStats(show_s07, s07))
symbolStats.push(f_getSymbolStats(show_s08, s08))
symbolStats.push(f_getSymbolStats(show_s09, s09))
symbolStats.push(f_getSymbolStats(show_s10, s10))
symbolStats.push(f_getSymbolStats(show_s11, s11))
symbolStats.push(f_getSymbolStats(show_s12, s12))
symbolStats.push(f_getSymbolStats(show_s13, s13))
symbolStats.push(f_getSymbolStats(show_s14, s14))
symbolStats.push(f_getSymbolStats(show_s15, s15))
symbolStats.push(f_getSymbolStats(show_s16, s16))
symbolStats.push(f_getSymbolStats(show_s17, s17))
symbolStats.push(f_getSymbolStats(show_s18, s18))
symbolStats.push(f_getSymbolStats(show_s19, s19))
symbolStats.push(f_getSymbolStats(show_s20, s20))

// --- Drawing Objects & State ---
var array<line> sunburstLines = array.new<line>(), var array<line> flameBorder = array.new<line>()
var polyline hourHand = na, var polyline minHand = na, var polyline leftChain = na, var polyline rightChain = na, var polyline leftChainWrap = na, var polyline rightChainWrap = na
var line secHand = na, var line leftExtendLine = na, var line rightExtendLine = na
var label pivotPoint = na, var label digitalDisplay = na, var label currentSymbolNameLabel = na, var label currentSymbolPctLabel = na, var label leftDrillHole = na, var label rightDrillHole = na
var array<label> hourLabels = array.new<label>(), var array<Snowflake> snowflakes = array.new<Snowflake>()
var bool isInitialized = false

// --- Main Logic ---
if barstate.islast
    // --- Cleanup ---
    for item in sunburstLines 
        item.delete()
    for item in flameBorder 
        item.delete()
    for item in hourLabels 
        item.delete()
    for item in symbolStats
        if not na(item.lbl_text)
            item.lbl_text.delete()
        if not na(item.lbl_bg)
            item.lbl_bg.delete()
    sunburstLines.clear(), flameBorder.clear(), hourLabels.clear()
    hourHand.delete(), minHand.delete(), secHand.delete()
    leftChain.delete(), rightChain.delete(), leftChainWrap.delete(), rightChainWrap.delete()
    leftExtendLine.delete(), rightExtendLine.delete()
    leftDrillHole.delete(), rightDrillHole.delete()
    pivotPoint.delete(), digitalDisplay.delete(), currentSymbolNameLabel.delete(), currentSymbolPctLabel.delete()

    // --- Positioning & Time ---
    float yCenter = (high + low) / 2 * (1 + i_yOffset / 100), int xCenter = bar_index + i_xOffset
    string effectiveTimezone = i_timezone == str.tostring(TZ.TimezoneID.EXCHANGE) ? syminfo.timezone : i_timezone
    float yRadius = i_radius * ta.tr * 1.5, int h = hour(timenow, effectiveTimezone), int m = minute(timenow, effectiveTimezone), int s = second(timenow, effectiveTimezone)

    // --- Draw Clock Face & Details ---
    for i = 0 to 359
        float angle = i * math.pi / 180, color rainbowColor = f_getRainbowColor(i / 359.0, cs.sunburst1, cs.sunburst2, cs.sunburst3, cs.sunburst4, cs.sunburst5, cs.sunburst6)
        sunburstLines.push(line.new(chart.point.from_index(xCenter, yCenter), chart.point.from_index(int(xCenter + i_radius * math.cos(angle)), yCenter + yRadius * math.sin(angle)), xloc=xloc.bar_index, color=color.new(rainbowColor, 80), width=1))

    float secFraction = s / 59.0, tailFraction = 0.80, numSegments = 120.0
    for i = 0 to int(numSegments - 1)
        float segmentFraction = i / numSegments, float diff = secFraction - segmentFraction
        if diff < 0
            diff += 1
        color segmentColor = diff <= tailFraction ? color.new(color.from_gradient(diff / tailFraction, 0, 1, cs.flame1, cs.flame2), int(math.pow(diff / tailFraction, 2) * 90)) : color.new(cs.flame2, 95)
        float angle1 = (math.pi / 2) - (segmentFraction * 2 * math.pi), float angle2 = (math.pi / 2) - (((i + 1) / numSegments) * 2 * math.pi)
        flameBorder.push(line.new(chart.point.from_index(int(xCenter + i_radius * math.cos(angle1)), yCenter + yRadius * math.sin(angle1)), chart.point.from_index(int(xCenter + i_radius * math.cos(angle2)), yCenter + yRadius * math.sin(angle2)), xloc=xloc.bar_index, color=segmentColor, width=5))
    
    // --- Draw Hanging Chains ---
    int chainSegments = 100
    float chainHeight = yRadius * 1.2
    float swayAmplitude = i_radius * 0.1
    color chainColor = color.new(cs.chain, 40)
    int chainWidth = i_useTemplate ? 4 : i_chainWidth

    array<chart.point> leftChainPoints = array.new<chart.point>()
    array<chart.point> leftChainWrapPoints = array.new<chart.point>()
    float leftStartAngle = 135 * math.pi / 180
    int leftStartX = int(xCenter + i_radius * math.cos(leftStartAngle))
    float leftStartY = yCenter + yRadius * math.sin(leftStartAngle)
    leftDrillHole := label.new(leftStartX, leftStartY, '', style=label.style_circle, color=color.new(color.black, 30), size=size.tiny)
    leftChainPoints.push(chart.point.from_index(leftStartX, leftStartY))
    leftChainWrapPoints.push(chart.point.from_index(leftStartX, leftStartY))
    for i = 1 to chainSegments
        float progress = i / float(chainSegments)
        int x = int(leftStartX + math.sin(progress * math.pi * 5) * swayAmplitude * (1 - progress))
        float y = leftStartY + progress * chainHeight
        leftChainPoints.push(chart.point.from_index(x, y))
        float wrapRadius = chainWidth * 0.75 * (1 - progress)
        int wrapX = x + int(math.cos(progress * 40 * math.pi) * wrapRadius)
        leftChainWrapPoints.push(chart.point.from_index(wrapX, y))

    leftChain := polyline.new(leftChainPoints, line_color=chainColor, line_width=chainWidth)
    leftChainWrap := polyline.new(leftChainWrapPoints, line_color=color.new(cs.chain, 0), line_width=1)
    chart.point leftTopPoint = leftChainPoints.get(-1)
    leftExtendLine := line.new(leftTopPoint, chart.point.from_index(leftTopPoint.index, leftTopPoint.price + yRadius*0.1), color=chainColor, width=chainWidth, extend=extend.right)

    array<chart.point> rightChainPoints = array.new<chart.point>()
    array<chart.point> rightChainWrapPoints = array.new<chart.point>()
    float rightStartAngle = 45 * math.pi / 180
    int rightStartX = int(xCenter + i_radius * math.cos(rightStartAngle))
    float rightStartY = yCenter + yRadius * math.sin(rightStartAngle)
    rightDrillHole := label.new(rightStartX, rightStartY, '', style=label.style_circle, color=color.new(color.black, 30), size=size.tiny)
    rightChainPoints.push(chart.point.from_index(rightStartX, rightStartY))
    rightChainWrapPoints.push(chart.point.from_index(rightStartX, rightStartY))
    for i = 1 to chainSegments
        float progress = i / float(chainSegments)
        int x = int(rightStartX - math.sin(progress * math.pi * 5) * swayAmplitude * (1 - progress))
        float y = rightStartY + progress * chainHeight
        rightChainPoints.push(chart.point.from_index(x, y))
        float wrapRadius = chainWidth * 0.75 * (1 - progress)
        int wrapX = x - int(math.cos(progress * 40 * math.pi) * wrapRadius)
        rightChainWrapPoints.push(chart.point.from_index(wrapX, y))
        
    rightChain := polyline.new(rightChainPoints, line_color=chainColor, line_width=chainWidth)
    rightChainWrap := polyline.new(rightChainWrapPoints, line_color=color.new(cs.chain, 0), line_width=1)
    chart.point rightTopPoint = rightChainPoints.get(-1)
    rightExtendLine := line.new(rightTopPoint, chart.point.from_index(rightTopPoint.index, rightTopPoint.price + yRadius*0.1), color=chainColor, width=chainWidth, extend=extend.right)

    // --- Place Volume Scanner Labels ---
    if i_showScanner
        array<SymbolStats> bulls = array.new<SymbolStats>()
        array<SymbolStats> bears = array.new<SymbolStats>()
        array<SymbolStats> watchlistBulls = array.new<SymbolStats>()

        for stat in symbolStats
            if stat.totalBuyVol > stat.totalSellVol
                if stat.isOnWatchlist
                    watchlistBulls.push(stat)
                else
                    bulls.push(stat)
            else if stat.totalSellVol > stat.totalBuyVol
                bears.push(stat)

        for [i, stat] in bulls
            float totalVol = stat.totalBuyVol + stat.totalSellVol, float buyPct = totalVol > 0 ? (stat.totalBuyVol / totalVol) * 100 : 0, float sellPct = 100 - buyPct
            string displayName = stat.baseCurrency
            string labelText = str.format("{0,number,#.##}%\n{1}", buyPct, displayName)
            string tooltipText = str.format("Symbol: {0}\nBuy Vol: {1}\nSell Vol: {2}\nTotal Vol: {3}\nBuy %: {4,number,#.##}%\nSell %: {5,number,#.##}%", stat.name, f_formatVolume(stat.totalBuyVol), f_formatVolume(stat.totalSellVol), f_formatVolume(totalVol), buyPct, sellPct)
            float angle = (math.pi * 0.9) - (i * (math.pi * 0.8) / math.max(1, bulls.size() - 1)), float r = i % 2 == 0 ? 0.65 : 0.45
            int x_pos = int(xCenter + i_radius * r * math.cos(angle)), float y_pos = yCenter + yRadius * r * math.sin(angle)
            stat.lbl_bg := label.new(x_pos, y_pos, "", xloc=xloc.bar_index, style=label.style_circle, color=color.new(color.green, 70), size=f_getCircleSize(buyPct))
            stat.lbl_text := label.new(x_pos, y_pos, labelText, xloc=xloc.bar_index, style=label.style_label_center, color=#00000000, textcolor=color.new(color.white, 0), size=f_getTextSize(buyPct), textalign=text.align_center, tooltip=tooltipText)

        for [i, stat] in bears
            float totalVol = stat.totalBuyVol + stat.totalSellVol, float sellPct = totalVol > 0 ? (stat.totalSellVol / totalVol) * 100 : 0, float buyPct = 100 - sellPct
            string displayName = stat.baseCurrency
            string labelText = str.format("{0,number,#.##}%\n{1}", sellPct, displayName)
            string tooltipText = str.format("Symbol: {0}\nBuy Vol: {1}\nSell Vol: {2}\nTotal Vol: {3}\nBuy %: {4,number,#.##}%\nSell %: {5,number,#.##}%", stat.name, f_formatVolume(stat.totalBuyVol), f_formatVolume(stat.totalSellVol), f_formatVolume(totalVol), buyPct, sellPct)
            float angle = (math.pi * 1.9) - (i * (math.pi * 0.8) / math.max(1, bears.size() - 1)), float r = i % 2 == 0 ? 0.65 : 0.45
            int x_pos = int(xCenter + i_radius * r * math.cos(angle)), float y_pos = yCenter + yRadius * r * math.sin(angle)
            stat.lbl_bg := label.new(x_pos, y_pos, "", xloc=xloc.bar_index, style=label.style_circle, color=color.new(color.red, 70), size=f_getCircleSize(sellPct))
            stat.lbl_text := label.new(x_pos, y_pos, labelText, xloc=xloc.bar_index, style=label.style_label_center, color=#00000000, textcolor=color.new(color.white, 0), size=f_getTextSize(sellPct), textalign=text.align_center, tooltip=tooltipText)
        
        int watchlistSize = watchlistBulls.size()
        if watchlistSize > 0
            float startAngle = 130 * math.pi / 180, float endAngle = 50 * math.pi / 180, float totalAngleSpan = startAngle - endAngle
            int numRows = math.ceil(watchlistSize / i_watchlistSymbolsPerRow)
            
            for i = 0 to watchlistSize - 1
                int row = math.floor(i / i_watchlistSymbolsPerRow), int col = i % i_watchlistSymbolsPerRow
                int symbolsInThisRow = math.min(i_watchlistSymbolsPerRow, watchlistSize - row * i_watchlistSymbolsPerRow)
                
                float angleStep = totalAngleSpan / (symbolsInThisRow + 1), float angle = startAngle - (col + 1) * angleStep
                
                float verticalSpacing = yRadius * 0.25
                float r_y = yRadius * i_watchlistVOffset + (row * verticalSpacing)
                float r_x = i_radius * i_watchlistVOffset + (row * verticalSpacing * (i_radius/yRadius))

                int x_pos = int(xCenter + r_x * math.cos(angle)), float y_pos = yCenter + r_y * math.sin(angle)

                SymbolStats stat = watchlistBulls.get(i)
                float totalVol = stat.totalBuyVol + stat.totalSellVol, float buyPct = totalVol > 0 ? (stat.totalBuyVol / totalVol) * 100 : 0, float sellPct = 100 - buyPct
                string displayName = stat.baseCurrency
                string labelText = str.format("{0,number,#.##}%\n{1}", buyPct, displayName)
                string tooltipText = str.format("WATCHLIST\nSymbol: {0}\nBuy Vol: {1}\nSell Vol: {2}\nTotal Vol: {3}\nBuy %: {4,number,#.##}%\nSell %: {5,number,#.##}%", stat.name, f_formatVolume(stat.totalBuyVol), f_formatVolume(stat.totalSellVol), f_formatVolume(totalVol), buyPct, sellPct)

                stat.lbl_bg := label.new(x_pos, y_pos, "", xloc=xloc.bar_index, style=label.style_circle, color=cs.watchlistBg, size=f_getCircleSize(buyPct))
                stat.lbl_text := label.new(x_pos, y_pos, labelText, xloc=xloc.bar_index, style=label.style_label_center, color=#00000000, textcolor=cs.watchlistText, size=f_getTextSize(buyPct), textalign=text.align_center, tooltip=tooltipText)

    for i = 1 to 12
        bool isMainHour = i % 3 == 0, float angle = (math.pi / 2) - (i / 12.0 * 2 * math.pi)
        hourLabels.push(label.new(int(xCenter + i_radius * 0.85 * math.cos(angle)), yCenter + yRadius * 0.85 * math.sin(angle), str.tostring(i), xloc=xloc.bar_index, style=label.style_text_outline, color=color.black, textcolor=isMainHour ? cs.mainNumbers : cs.numbers, size=isMainHour ? size.large : size.normal, textalign=text.align_center, text_font_family=isMainHour ? font.family_monospace : font.family_default))
        
    if not isInitialized
        for i = 0 to 20
            label l = label.new(na, na, "•", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=color.new(color.white, math.random(30, 70)), size=size.tiny)
            snowflakes.push(Snowflake.new(math.random(-i_radius, i_radius), math.random(-yRadius, yRadius), math.random(0.01, 0.05) * yRadius, math.random(-0.5, 0.5), l))
        isInitialized := true
    
    for flake in snowflakes
        flake.y_offset -= flake.speed, flake.x_offset += math.sin(bar_index + flake.y_offset * 0.1) * flake.sway
        if flake.y_offset < -yRadius
            flake.y_offset := yRadius, flake.x_offset := math.random(-i_radius, i_radius)
        float snowX = xCenter + flake.x_offset, float snowY = yCenter + flake.y_offset
        if math.pow(snowX - xCenter, 2) / math.pow(i_radius, 2) + math.pow(snowY - yCenter, 2) / math.pow(yRadius, 2) < 1
            flake.lbl.set_xy(int(snowX), snowY), flake.lbl.set_text("•")
        else
            flake.lbl.set_text("")

    string displayTimezoneName = i_timezone == str.tostring(TZ.TimezoneID.EXCHANGE) ? "EXCHANGE" : str.split(i_timezone, "/").get(str.split(i_timezone, "/").size() - 1)
    digitalDisplay := label.new(xCenter, yCenter - yRadius * 0.15, str.format("{0,number,00}:{1,number,00}:{2,number,00}\n({3})", h, m, s, displayTimezoneName), xloc=xloc.bar_index, style=label.style_text_outline, color=color.rgb(255, 255, 255, 36), textcolor=cs.digital, size=size.normal, textalign=text.align_center)
    
    float hourAngle = (math.pi / 2) - ((h % 12 + m / 60.0) / 12.0 * 2 * math.pi), float minAngle = (math.pi / 2) - ((m + s / 60.0) / 60.0 * 2 * math.pi), float secAngle = (math.pi / 2) - (s / 60.0 * 2 * math.pi)
    float baseWidthRatio = 0.05, chart.point p_center = chart.point.from_index(xCenter, yCenter)

    chart.point p_hour_tip = chart.point.from_index(int(xCenter + i_radius * 0.5 * math.cos(hourAngle)), yCenter + yRadius * 0.5 * math.sin(hourAngle))
    chart.point p_hour_l = chart.point.from_index(int(xCenter + i_radius * baseWidthRatio * math.cos(hourAngle + math.pi / 2)), yCenter + yRadius * baseWidthRatio * math.sin(hourAngle + math.pi / 2))
    chart.point p_hour_r = chart.point.from_index(int(xCenter + i_radius * baseWidthRatio * math.cos(hourAngle - math.pi / 2)), yCenter + yRadius * baseWidthRatio * math.sin(hourAngle - math.pi / 2))
    hourHand := polyline.new(array.from(p_hour_l, p_hour_tip, p_hour_r), xloc=xloc.bar_index, closed=true, line_color=na, fill_color=cs.hands)
    
    chart.point p_min_tip = chart.point.from_index(int(xCenter + i_radius * 0.8 * math.cos(minAngle)), yCenter + yRadius * 0.8 * math.sin(minAngle))
    chart.point p_min_l = chart.point.from_index(int(xCenter + i_radius * baseWidthRatio * math.cos(minAngle + math.pi / 2)), yCenter + yRadius * baseWidthRatio * math.sin(minAngle + math.pi / 2))
    chart.point p_min_r = chart.point.from_index(int(xCenter + i_radius * baseWidthRatio * math.cos(minAngle - math.pi / 2)), yCenter + yRadius * baseWidthRatio * math.sin(minAngle - math.pi / 2))
    minHand := polyline.new(array.from(p_min_l, p_min_tip, p_min_r), xloc=xloc.bar_index, closed=true, line_color=na, fill_color=cs.hands)

    secHand := line.new(p_center, chart.point.from_index(int(xCenter + i_radius * 0.9 * math.cos(secAngle)), yCenter + yRadius * 0.9 * math.sin(secAngle)), xloc=xloc.bar_index, color=cs.second, width=2)
    pivotPoint := label.new(xCenter, yCenter, "", xloc=xloc.bar_index, style=label.style_circle, color=cs.pivot, size=size.tiny)
    
    // --- Current Symbol on Hands ---
    float currentTotalBuy = 0.0, float currentTotalSell = 0.0
    for i = 0 to i_lookbackBars
        if not na(volume[i])
            [buyVol, sellVol] = f_calculateBuySellVolume(open[i], high[i], low[i], close[i], volume[i])
            currentTotalBuy += buyVol, currentTotalSell += sellVol
            
    float currentTotalVol = currentTotalBuy + currentTotalSell
    string currentSymbolName = syminfo.basecurrency
    color currentSymbolColor = currentTotalBuy >= currentTotalSell ? color.new(color.green, 0) : color.new(color.red, 0)
    string currentSymbolPctText = "", string currentTooltipText = ""
    if currentTotalVol > 0
        float buyPct = (currentTotalBuy / currentTotalVol) * 100, float sellPct = 100 - buyPct
        currentSymbolPctText := str.format("{0,number,#.##}%", currentTotalBuy >= currentTotalSell ? buyPct : sellPct)
        currentTooltipText := str.format("Symbol: {0}\nBuy Vol: {1}\nSell Vol: {2}\nTotal Vol: {3}\nBuy %: {4,number,#.##}%\nSell %: {5,number,#.##}%", syminfo.tickerid, f_formatVolume(currentTotalBuy), f_formatVolume(currentTotalSell), f_formatVolume(currentTotalVol), buyPct, sellPct)

    currentSymbolNameLabel := label.new(p_min_tip.index, p_min_tip.price, currentSymbolName, xloc=xloc.bar_index, style=label.style_text_outline, color=color.white, textcolor=currentSymbolColor, size=size.normal, tooltip = currentTooltipText)
    currentSymbolPctLabel := label.new(p_hour_tip.index, p_hour_tip.price, currentSymbolPctText, xloc=xloc.bar_index, style=label.style_text_outline, color=color.white, textcolor=currentSymbolColor, size=size.normal, tooltip = currentTooltipText)
````
