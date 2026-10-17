# GUAPOXTRADES High-Low Labels (Asia, London, NY)-Teaching Version

- url: https://www.tradingview.com/script/1gZ18vvn-GUAPOXTRADES-High-Low-Labels-Asia-London-NY-Teaching-Version/
- type: indicator
- pine_id: PUB;e8252758d5124f46b204a0ac3187efe6
- version: 2.0

## Description

GuapoxTrades Session High-Low Labels™
Session Liquidity Mapping • Market Structure Reference • Intraday Context

The GuapoxTrades Session High-Low Labels™ indicator automatically identifies and labels the highest and lowest price points formed during the three major forex trading sessions:
Asian Session
London Session
New York Session

As price develops throughout the trading day, the indicator continuously updates session highs and lows in real time, providing traders with a clean visual reference of where liquidity, volatility, and key reaction levels have formed.

Instead of manually tracking session extremes, traders can instantly identify important reference points that institutions, liquidity sweeps, stop hunts, and market reactions often respect.

Core Features
Session High & Low Detection
Automatically tracks:
Asian High
Asian Low
London High
London Low
New York High
New York Low
Real-Time Updating
Labels adjust automatically whenever a new session high or low is established.
Liquidity Mapping

Quickly identify potential:
Liquidity pools
Stop clusters
Session sweeps
Breakout levels
Reversal zones

Custom Session Times
Modify session hours to match:
Broker time
Personal trading schedule
Regional market preferences

Adjustable Label Positioning
Customize:
Horizontal label offset
Vertical label offset
Chart placement

Clean Chart Design
Built specifically for traders who want session context without cluttering the chart with excessive lines, panels, or indicators.

How Traders Commonly Use It
Many traders use session highs and lows as:
Liquidity targets
Draw-on-liquidity objectives
Breakout confirmation zones
Market structure references
Session sweep confirmations
Intraday support and resistance levels

The indicator helps simplify this process by automatically labeling important session reference points throughout the trading day.

Best For:
Forex Traders
Futures Traders
Intraday Traders
Scalpers
Day Traders
Market Structure Traders
Liquidity-Based Trading Models
ICT-Inspired Concepts
Session-Based Strategies

Visual Design Notice
The GuapoxTrades Session High-Low Labels™ indicator was designed, tested, and optimized primarily using dark-theme chart backgrounds.

Label colors, visibility, spacing, and contrast were calibrated for dark-mode environments to maximize readability and reduce chart distraction.

Traders using light-theme charts may customize the appearance through the indicator settings, including:
Label Colors
Text Colors
Horizontal Offset
Vertical Offset
Session Visibility Controls

This allows the indicator to adapt to virtually any chart theme or workspace configuration.

Disclaimer - Educational Use Only
GuapoxTrades Session High-Low Labels™ is provided for educational and informational purposes only.

This indicator does not provide financial advice, investment advice, trade recommendations, or guarantees of future market performance.

Session highs and lows represent historical market data and should not be interpreted as guaranteed support, resistance, reversal, or continuation levels.

All trading involves risk. Past performance does not guarantee future results. Traders are solely responsible for their own decisions, risk management, and financial outcomes.

GuapoxTrades is not responsible for losses incurred through the use of this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GuapoxTrades

//@version=6
indicator("Guapoxtrades Session High-Low Labels (Asia, London, NY) - Multi-Lingual Teaching Module", overlay=true)

// Inputs
language = input.string(
     "English",
     "Label Language",
     options=[
         "English", "Español", "Português", "Français",
         "Deutsch", "Italiano", "Русский", "العربية",
         "हिन्दी", "简体中文", "한국어", "日本語"])

asia_session   = input.session("1600-0300", "Asian Session")
london_session = input.session("0300-0800", "London Session")
ny_session     = input.session("0800-1600", "New York Session")

show_asia   = input.bool(true, "Show Asia High/Low")
show_london = input.bool(true, "Show London High/Low")
show_ny     = input.bool(true, "Show NY High/Low")

offset_ticks = input.int(5, "Vertical Offset (Ticks)", minval=1)
x_shift      = input.int(3, "Label Shift Right (Bars)", minval=0)

label_offset = syminfo.mintick * offset_ticks

// Translated label text:
// Asia High, Asia Low, London High, London Low, NY High, NY Low.
f_labelWords(string selected) =>
    switch selected
        "Español" =>
            str.split("Máximo de Asia¦Mínimo de Asia¦Máximo de Londres¦Mínimo de Londres¦Máximo de Nueva York¦Mínimo de Nueva York", "¦")
        "Português" =>
            str.split("Máxima da Ásia¦Mínima da Ásia¦Máxima de Londres¦Mínima de Londres¦Máxima de Nova York¦Mínima de Nova York", "¦")
        "Français" =>
            str.split("Haut Asie¦Bas Asie¦Haut Londres¦Bas Londres¦Haut New York¦Bas New York", "¦")
        "Deutsch" =>
            str.split("Asien-Hoch¦Asien-Tief¦London-Hoch¦London-Tief¦New-York-Hoch¦New-York-Tief", "¦")
        "Italiano" =>
            str.split("Massimo Asia¦Minimo Asia¦Massimo Londra¦Minimo Londra¦Massimo New York¦Minimo New York", "¦")
        "Русский" =>
            str.split("Максимум Азии¦Минимум Азии¦Максимум Лондона¦Минимум Лондона¦Максимум Нью-Йорка¦Минимум Нью-Йорка", "¦")
        "العربية" =>
            str.split("أعلى آسيا¦أدنى آسيا¦أعلى لندن¦أدنى لندن¦أعلى نيويورك¦أدنى نيويورك", "¦")
        "हिन्दी" =>
            str.split("एशिया उच्च¦एशिया निम्न¦लंदन उच्च¦लंदन निम्न¦न्यूयॉर्क उच्च¦न्यूयॉर्क निम्न", "¦")
        "简体中文" =>
            str.split("亚洲高点¦亚洲低点¦伦敦高点¦伦敦低点¦纽约高点¦纽约低点", "¦")
        "한국어" =>
            str.split("아시아 고점¦아시아 저점¦런던 고점¦런던 저점¦뉴욕 고점¦뉴욕 저점", "¦")
        "日本語" =>
            str.split("アジア高値¦アジア安値¦ロンドン高値¦ロンドン安値¦ニューヨーク高値¦ニューヨーク安値", "¦")
        =>
            str.split("Asia High¦Asia Low¦London High¦London Low¦NY High¦NY Low", "¦")

var array<string> labelWords = f_labelWords(language)

f_labelText(int index) =>
    array.get(labelWords, index)

in_session(sess) =>
    not na(time(timeframe.period, sess))

// Session membership
asia_active   = in_session(asia_session)
london_active = in_session(london_session)
ny_active     = in_session(ny_session)

// Pine v6 Boolean session-start detection
asia_new = asia_active and not asia_active[1]
ld_new   = london_active and not london_active[1]
ny_new   = ny_active and not ny_active[1]

// ASIA
var float asia_high = na
var float asia_low = na
var int asia_high_bar = na
var int asia_low_bar = na

if asia_new
    asia_high := high
    asia_low := low
    asia_high_bar := bar_index
    asia_low_bar := bar_index

if asia_active
    if na(asia_high) or high > asia_high
        asia_high := high
        asia_high_bar := bar_index
    if na(asia_low) or low < asia_low
        asia_low := low
        asia_low_bar := bar_index

// LONDON
var float london_high = na
var float london_low = na
var int london_high_bar = na
var int london_low_bar = na

if ld_new
    london_high := high
    london_low := low
    london_high_bar := bar_index
    london_low_bar := bar_index

if london_active
    if na(london_high) or high > london_high
        london_high := high
        london_high_bar := bar_index
    if na(london_low) or low < london_low
        london_low := low
        london_low_bar := bar_index

// NEW YORK
var float ny_high = na
var float ny_low = na
var int ny_high_bar = na
var int ny_low_bar = na

if ny_new
    ny_high := high
    ny_low := low
    ny_high_bar := bar_index
    ny_low_bar := bar_index

if ny_active
    if na(ny_high) or high > ny_high
        ny_high := high
        ny_high_bar := bar_index
    if na(ny_low) or low < ny_low
        ny_low := low
        ny_low_bar := bar_index

// Label positions
// High labels: slightly below the high
asiaHighY   = na(asia_high) ? na : asia_high - label_offset
londonHighY = na(london_high) ? na : london_high - label_offset
nyHighY     = na(ny_high) ? na : ny_high - label_offset

// Low labels: slightly above the low
asiaLowY   = na(asia_low) ? na : asia_low + label_offset
londonLowY = na(london_low) ? na : london_low + label_offset
nyLowY     = na(ny_low) ? na : ny_low + label_offset

// Shift labels right
asiaHighX   = na(asia_high_bar) ? na : asia_high_bar + x_shift
asiaLowX    = na(asia_low_bar) ? na : asia_low_bar + x_shift
londonHighX = na(london_high_bar) ? na : london_high_bar + x_shift
londonLowX  = na(london_low_bar) ? na : london_low_bar + x_shift
nyHighX     = na(ny_high_bar) ? na : ny_high_bar + x_shift
nyLowX      = na(ny_low_bar) ? na : ny_low_bar + x_shift

// Labels
var label asiaHighLabel = na
var label asiaLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na
var label nyHighLabel = na
var label nyLowLabel = na

label_color = color.rgb(54, 69, 79)
label_textcolor = color.white

// Update labels during session
if show_asia and asia_active
    if na(asiaHighLabel)
        asiaHighLabel := label.new(
             asiaHighX, asiaHighY, f_labelText(0),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(asiaHighLabel, asiaHighX, asiaHighY)
        label.set_text(asiaHighLabel, f_labelText(0))

    if na(asiaLowLabel)
        asiaLowLabel := label.new(
             asiaLowX, asiaLowY, f_labelText(1),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(asiaLowLabel, asiaLowX, asiaLowY)
        label.set_text(asiaLowLabel, f_labelText(1))

if show_london and london_active
    if na(londonHighLabel)
        londonHighLabel := label.new(
             londonHighX, londonHighY, f_labelText(2),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(londonHighLabel, londonHighX, londonHighY)
        label.set_text(londonHighLabel, f_labelText(2))

    if na(londonLowLabel)
        londonLowLabel := label.new(
             londonLowX, londonLowY, f_labelText(3),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(londonLowLabel, londonLowX, londonLowY)
        label.set_text(londonLowLabel, f_labelText(3))

if show_ny and ny_active
    if na(nyHighLabel)
        nyHighLabel := label.new(
             nyHighX, nyHighY, f_labelText(4),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(nyHighLabel, nyHighX, nyHighY)
        label.set_text(nyHighLabel, f_labelText(4))

    if na(nyLowLabel)
        nyLowLabel := label.new(
             nyLowX, nyLowY, f_labelText(5),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=label_color,
             textcolor=label_textcolor)
    else
        label.set_xy(nyLowLabel, nyLowX, nyLowY)
        label.set_text(nyLowLabel, f_labelText(5))

// Reset labels at new session start
if asia_new
    label.delete(asiaHighLabel)
    label.delete(asiaLowLabel)
    asiaHighLabel := na
    asiaLowLabel := na

if ld_new
    label.delete(londonHighLabel)
    label.delete(londonLowLabel)
    londonHighLabel := na
    londonLowLabel := na

if ny_new
    label.delete(nyHighLabel)
    label.delete(nyLowLabel)
    nyHighLabel := na
    nyLowLabel := na
````
