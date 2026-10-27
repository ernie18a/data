# Adaptive MTF Trend Following [bitpunk]

- url: https://www.tradingview.com/script/updjjC04-Adaptive-MTF-Trend-Following-bitpunk/
- type: indicator
- pine_id: PUB;013afe769b824095b247298661adf501
- version: 3.0

## Description

Adaptive Trend Following MTF Panel [bitpunk]
A confirmed trend track with live price position and multi-timeframe context

[b]1. WHAT THIS IS[/b]

Adaptive Trend Following MTF Panel [bitpunk] combines an EMA50-centred trend track with a panel showing live BIAS, ATR14 and four timeframe states. Its volatility envelope widens immediately as range expands, then contracts gradually as exceptional volatility fades.

[i]The default view: EMA50, one active edge and the Trend Panel.[/i]

[b]2. READING THE TRACK AND PANEL 📈[/b]

[b]2.1 Confirmed track[/b]

A confirmed close crossing above the upper envelope edge establishes bull direction; a close crossing below the lower edge establishes bear direction. Direction persists until an opposing close-confirmed crossing.

[list]
[*][b]Bull track[/b] — EMA50 and the lower edge.
[*][b]Bear track[/b] — EMA50 and the upper edge.
[*][b]Neutral[/b] — only EMA50, before a direction is established.
[/list]

[i]A close-confirmed crossing changes direction and switches the visible edge.[/i]

[b]2.2 Trend Panel[/b]

The panel separates confirmed direction from current price position:

[list]
[*][b]BIAS[/b] — live distance from EMA50 relative to the envelope width. Positive is above EMA50; negative is below. EMA50 is 0%, one envelope width is ±50%, and two widths reach the ±100% display cap.
[*][b]ATR14[/b] — current Average True Range in price units and as a percentage of price.
[*][b]MTF row[/b] — track states on four preset timeframes: 🚀 Strong Bull, 🐂 Bull, 😐 Neutral, 🐻 Bear, 👻 Strong Bear. Strong states mean the established direction agrees with price beyond its corresponding outer edge. Neutral means no confirmed direction yet; n/a means unavailable data or history.
[/list]

BIAS uses the same icons for live location: Bull/Bear means above/below EMA50, Strong Bull/Strong Bear means beyond the upper/lower edge, and Neutral means exactly at EMA50. It can disagree with confirmed track direction during a pullback.

[i]Live BIAS and ATR14 above four timeframe states that need not agree.[/i]

[b]3. USE AND SETTINGS 🧭[/b]

[b]3.1 Reading workflow[/b]

Read the track direction, compare it with live BIAS, then check the MTF row for agreement or different phases across horizons. Use ATR14 to understand current range; choose entries, invalidation and position size separately.

[b]3.2 Settings[/b]

[list]
[*][b]Language[/b] — English by default; Simplified Chinese is also available.
[*][b]Theme Colors[/b] — change bull and bear colours.
[*][b]Trend Panel Position[/b] — bottom-right by default; top-right or none to hide it.
[*][b]Trend Panel Size[/b] — small by default; medium and large are available.
[*][b]MTF Trend Following Preset[/b] — swing by default. Select none to hide only the MTF row, keeping BIAS and ATR14.
[/list]

[i]Preset timeframes[/i]

[list]
[*]Scalping: 1m / 5m / 15m / 1h
[*]Intraday: 5m / 15m / 1h / 4h
[*]Swing: 15m / 1h / 4h / 1D
[*]Trend: 1h / 4h / 1D / 1W
[/list]

[b]4. REALTIME AND MULTI-TIMEFRAME 🕒[/b]

Track direction changes only on a confirmed close. BIAS, ATR14 and the envelope lines can move while the chart bar is open.

MTF cells use the local state for the chart timeframe, the previous confirmed state for a higher timeframe, and the latest completed intrabar available for a lower timeframe. A higher-timeframe cell therefore waits for that larger bar to close; missing lower-timeframe data can show n/a.

[b]5. WHAT IT ISN'T ℹ️[/b]

This is a visual trend reference, with no alerts or automated execution. Track states are observations, and the active edge is a conditional reference rather than an assured support, resistance or protective stop. BIAS measures distance, not confidence or expected return. Use standard candlestick charts and interpret unavailable history separately from Neutral.

[i]For informational and educational use only. Trading involves risk; execution and risk management remain with the user.[/i]

## Source Code

````pine
//@version=6
// SPDX-License-Identifier: MPL-2.0
// BUILD: release
// Adaptive Trend Following is an independent visual track. It observes a
// confirmed directional break and live price distance around one EMA50 axis.
indicator(
    title='Adaptive Trend Following MTF Panel [bitpunk]',
    shorttitle='bitpunk.tf',
    overlay=true,
    behind_chart=false,
    max_bars_back=500,
    dynamic_requests=true
)

// =============================================================================
// 1) PUBLIC INPUTS
// =============================================================================
//
const string opt_panel_none = 'none'
const string opt_panel_bottom = 'bottom'
const string opt_panel_top = 'top'
const string opt_panel_size_small = 'small'
const string opt_panel_size_medium = 'medium'
const string opt_panel_size_large = 'large'
const string opt_mtf_none = 'none'

const string txt_theme_colors = 'Theme Colors'
const string txt_theme_colors_tt = 'Change the primary bull and bear colors.'
const string txt_trend_panel = 'Trend Panel Position'
const string txt_trend_panel_tt = 'Choose the panel position, or none to hide it.'
const string txt_trend_panel_size = 'Trend Panel Size'
const string txt_trend_panel_size_tt = 'Adjust panel and text size.'
const string txt_trend_mtf_tt = 'Select a timeframe, or none to hide this slot. Enabled slots are displayed in input order, two per row. All four set to none leaves only BIAS and ATR14.'

ui_bullColor = input.color(color.rgb(0, 194, 255), title=txt_theme_colors, inline='theme', tooltip=txt_theme_colors_tt)
ui_bearColor = input.color(color.rgb(255, 56, 100), title='', inline='theme')
panelCorner = input.string(opt_panel_bottom, txt_trend_panel, options=[opt_panel_none, opt_panel_bottom, opt_panel_top], tooltip=txt_trend_panel_tt, display=display.none)
panelSize = input.string(opt_panel_size_small, txt_trend_panel_size, options=[opt_panel_size_small, opt_panel_size_medium, opt_panel_size_large], tooltip=txt_trend_panel_size_tt, display=display.none)
panelTf1 = input.string('15m', 'MTF Timeframe 1',
     options=['none', '5m', '15m', '30m', '1h', '2h', '4h', '1D', '1W', '1M'],
     tooltip=txt_trend_mtf_tt, display=display.none)
panelTf2 = input.string('1h', 'MTF Timeframe 2',
     options=['none', '5m', '15m', '30m', '1h', '2h', '4h', '1D', '1W', '1M'],
     tooltip=txt_trend_mtf_tt, display=display.none)
panelTf3 = input.string('4h', 'MTF Timeframe 3',
     options=['none', '5m', '15m', '30m', '1h', '2h', '4h', '1D', '1W', '1M'],
     tooltip=txt_trend_mtf_tt, display=display.none)
panelTf4 = input.string('1D', 'MTF Timeframe 4',
     options=['none', '5m', '15m', '30m', '1h', '2h', '4h', '1D', '1W', '1M'],
     tooltip=txt_trend_mtf_tt, display=display.none)

// =============================================================================
// 2) VISUAL AND STATE HELPERS
// =============================================================================

f_clip(_value, _lower, _upper) =>
    math.max(math.min(_value, _upper), _lower)

f_color_lerp(_from, _to, _amount, _alpha) =>
    _unit = f_clip(_amount, 0.0, 1.0)
    _red = int(math.round(color.r(_from) + (color.r(_to) - color.r(_from)) * _unit))
    _green = int(math.round(color.g(_from) + (color.g(_to) - color.g(_from)) * _unit))
    _blue = int(math.round(color.b(_from) + (color.b(_to) - color.b(_from)) * _unit))
    color.rgb(_red, _green, _blue, _alpha)

f_color_darken(_base, _amount, _alpha) =>
    f_color_lerp(_base, color.black, _amount, _alpha)

f_color_dim(_base, _amount, _alpha) =>
    f_color_lerp(_base, chart.bg_color, _amount, _alpha)

f_color_desaturate(_base, _amount, _alpha) =>
    _luminance = int(math.round(0.299 * color.r(_base) + 0.587 * color.g(_base) + 0.114 * color.b(_base)))
    f_color_lerp(_base, color.rgb(_luminance, _luminance, _luminance), _amount, _alpha)

f_track_state_id(_ready, _direction, _price, _upper, _lower) =>
    not _ready ? na :
     _direction == 1 ? (_price > _upper ? 2 : 1) :
     _direction == -1 ? (_price < _lower ? -2 : -1) : 0

f_bias_state_id(_ready, _price, _anchor, _upper, _lower) =>
    not _ready ? na :
     _price > _upper ? 2 :
     _price > _anchor ? 1 :
     _price < _lower ? -2 :
     _price < _anchor ? -1 : 0

f_track_emoji(_stateId) =>
    na(_stateId) ? 'n/a' :
     _stateId == 2 ? '🚀' :
     _stateId == 1 ? '🐂' :
     _stateId == -2 ? '👻' :
     _stateId == -1 ? '🐻' : '😐'

f_bias_name(_stateId) =>
    na(_stateId) ? 'n/a' :
     _stateId == 2 ? '🚀Strong Bull' :
     _stateId == 1 ? '🐂Bull' :
     _stateId == -2 ? '👻Strong Bear' :
     _stateId == -1 ? '🐻Bear' : '😐Neutral'

f_bias_percent(_ready, _price, _anchor, _width, _fullScaleWidths) =>
    _widthSafe = math.max(_width, syminfo.mintick)
    _fullScale = _widthSafe * math.max(_fullScaleWidths, 0.0001)
    _value = not _ready ? 0.0 : 100.0 * f_clip((_price - _anchor) / _fullScale, -1.0, 1.0)
    math.abs(_value) < 1e-6 ? 0.0 : _value

f_direction_from_crosses(_bullCross, _bearCross) =>
    _barsSinceBull = ta.barssince(_bullCross)
    _barsSinceBear = ta.barssince(_bearCross)
    na(_barsSinceBull) and na(_barsSinceBear) ? 0 :
     na(_barsSinceBear) or (not na(_barsSinceBull) and _barsSinceBull <= _barsSinceBear) ? 1 : -1

// Match readable dropdown labels to Pine's request timeframe strings.
f_panel_timeframe(simple string _selection) =>
    switch _selection
        '1h' => '60'
        '2h' => '120'
        '4h' => '240'
        => str.endswith(_selection, 'm') ? str.substring(_selection, 0, str.length(_selection) - 1) : _selection

// Keep timeframe.in_seconds() on simple input-derived strings, outside loops.
f_panel_seconds(simple string _tf) =>
    _tf == opt_mtf_none ? int(na) : timeframe.in_seconds(_tf)

f_timeframe_label(_tf) =>
    _length = str.length(_tf)
    _last = _length > 0 ? str.substring(_tf, _length - 1, _length) : ''
    _hasSuffix = _last == 'D' or _last == 'W' or _last == 'M'
    if _hasSuffix
        _numberText = _length > 1 ? str.substring(_tf, 0, _length - 1) : '1'
        _numberRaw = str.tonumber(_numberText)
        _number = na(_numberRaw) ? 1 : int(_numberRaw)
        _suffix = _last == 'D' ? 'd' : _last == 'W' ? 'w' : 'mo'
        str.tostring(_number) + _suffix
    else
        _minutesRaw = str.tonumber(_tf)
        if na(_minutesRaw)
            _tf
        else
            _minutes = int(_minutesRaw)
            _minutes >= 60 and math.floor(_minutes / 60) * 60 == _minutes ? str.tostring(int(_minutes / 60)) + 'h' : str.tostring(_minutes) + 'm'

f_panel_cell_text(_text) =>
    _length = str.length(_text)
    _length >= 5 ? _text :
     _length == 4 ? ' ' + _text :
     _length == 3 ? ' ' + _text + ' ' :
     _length == 2 ? '  ' + _text + ' ' : '  ' + _text + '  '

// Equal timeframes read local state; HTFs expose previous confirmed state.
f_panel_mtf_state(_tf, _tfSeconds, _chartTfSeconds, _requestedStateId, _chartStateId) =>
    _sameTf = _tf == timeframe.period or (not na(_tfSeconds) and not na(_chartTfSeconds) and _tfSeconds == _chartTfSeconds)
    _lowerTf = not na(_chartTfSeconds) and _tfSeconds < _chartTfSeconds
    if _sameTf
        _chartStateId
    else if _lowerTf
        array<int> _states = request.security_lower_tf(syminfo.tickerid, _tf, _requestedStateId, ignore_invalid_timeframe=true)
        array.size(_states) > 0 ? array.last(_states) : na
    else
        request.security(syminfo.tickerid, _tf, _requestedStateId[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// =============================================================================
// 3) TREND TRACK
// =============================================================================

const int ema_length = 50
const int atr_length = 14
const float band_atr_multiple = 1.75
const float band_price_cap_pct = 20.0
const float shock_half_life = 7.0
const float bias_full_scale_widths = 2.0

ema50 = ta.ema(close, ema_length)
atr14 = ta.atr(atr_length)
atrSafe = na(atr14) ? na : math.max(atr14, syminfo.mintick)

bandAnchor = ema50
shockDecay = math.pow(0.5, 1.0 / shock_half_life)
var float bandAtr = na
bandAtr := na(bandAtr[1]) ? atrSafe : atrSafe + shockDecay * math.max(bandAtr[1] - atrSafe, 0.0)
bandWidthRaw = bandAtr * band_atr_multiple
bandWidthCap = math.max(math.abs(close), syminfo.mintick) * band_price_cap_pct * 0.01
bandWidth = math.min(bandWidthRaw, bandWidthCap)
bandUpper = bandAnchor + bandWidth
bandLower = bandAnchor - bandWidth
bandReady = not na(bandUpper) and not na(bandLower)

closeCrossOverUpper = ta.crossover(close, bandUpper)
closeCrossUnderLower = ta.crossunder(close, bandLower)
requestedDirection = f_direction_from_crosses(closeCrossOverUpper, closeCrossUnderLower)
var int trackDirection = 0
if barstate.isconfirmed and closeCrossOverUpper
    trackDirection := 1
else if barstate.isconfirmed and closeCrossUnderLower
    trackDirection := -1
else
    trackDirection := nz(trackDirection[1], 0)

trackStateId = f_track_state_id(bandReady, trackDirection, close, bandUpper, bandLower)
requestedStateId = f_track_state_id(bandReady, requestedDirection, close, bandUpper, bandLower)
biasStateId = f_bias_state_id(bandReady, close, bandAnchor, bandUpper, bandLower)
biasPercent = f_bias_percent(bandReady, close, bandAnchor, bandWidth, bias_full_scale_widths)

// =============================================================================
// 4) MULTI-TIMEFRAME STATE
// =============================================================================

// Compact enabled slots once; input changes restart the script.
configuredTf1 = f_panel_timeframe(panelTf1)
configuredTf2 = f_panel_timeframe(panelTf2)
configuredTf3 = f_panel_timeframe(panelTf3)
configuredTf4 = f_panel_timeframe(panelTf4)
var array<string> configuredTimeframes = array.from(configuredTf1, configuredTf2, configuredTf3, configuredTf4)
var array<int> configuredSeconds = array.from(f_panel_seconds(configuredTf1), f_panel_seconds(configuredTf2), f_panel_seconds(configuredTf3), f_panel_seconds(configuredTf4))
var array<string> panelTimeframes = array.new<string>()
var array<int> panelTimeframeSeconds = array.new<int>()
if barstate.isfirst
    for [index, panelTf] in configuredTimeframes
        if panelTf != opt_mtf_none
            array.push(panelTimeframes, panelTf)
            array.push(panelTimeframeSeconds, array.get(configuredSeconds, index))

panelMtfCount = array.size(panelTimeframes)
chartTfSeconds = timeframe.isticks ? na : timeframe.in_seconds()
panelNeedsMtf = (barstate.islastconfirmedhistory or barstate.islast) and panelCorner != opt_panel_none and panelMtfCount > 0
var array<int> panelMtfStates = array.new<int>(panelMtfCount, na)
if panelNeedsMtf
    for [index, panelTf] in panelTimeframes
        tfSeconds = array.get(panelTimeframeSeconds, index)
        array.set(panelMtfStates, index, f_panel_mtf_state(panelTf, tfSeconds, chartTfSeconds, requestedStateId, trackStateId))

// =============================================================================
// 5) TRACK RENDERING
// =============================================================================

const float band_tone_trim = 0.24
const float neutral_desaturate = 0.55
const float band_neutral_dim = 0.32
const float band_edge_trim_add = 0.08
const float band_fill_trim_add = 0.16
const int band_edge_alpha = 84
const int band_fill_alpha = 88
const float band_basis_tone_trim = 0.08
const int band_basis_alpha = 42

themeMidpoint = f_color_lerp(ui_bullColor, ui_bearColor, 0.5, 0)
neutralColor = f_color_desaturate(themeMidpoint, neutral_desaturate, 0)
bandNeutralColor = f_color_dim(neutralColor, band_neutral_dim, 0)
bandThemeColor = trackDirection == 1 ? ui_bullColor : trackDirection == -1 ? ui_bearColor : bandNeutralColor
bandBasisColor = color.new(trackDirection == 0 ? bandNeutralColor : f_color_darken(bandThemeColor, band_basis_tone_trim, 0), band_basis_alpha)
bandUpperColor = color.new(f_color_darken(ui_bearColor, band_tone_trim + band_edge_trim_add, 0), band_edge_alpha)
bandLowerColor = color.new(f_color_darken(ui_bullColor, band_tone_trim + band_edge_trim_add, 0), band_edge_alpha)
bandUpperFillColor = color.new(f_color_darken(ui_bearColor, band_tone_trim + band_fill_trim_add, 0), band_fill_alpha)
bandLowerFillColor = color.new(f_color_darken(ui_bullColor, band_tone_trim + band_fill_trim_add, 0), band_fill_alpha)
overlayDisplay = display.all - display.data_window - display.status_line - display.price_scale

bandAnchorPlot = plot(bandAnchor, title='EMA50 Axis', color=bandBasisColor, linewidth=2, display=overlayDisplay)
bandUpperPlot = plot(trackDirection == -1 ? bandUpper : na, title='Bear Track Edge', color=bandUpperColor, linewidth=1, style=plot.style_linebr, display=overlayDisplay)
bandLowerPlot = plot(trackDirection == 1 ? bandLower : na, title='Bull Track Edge', color=bandLowerColor, linewidth=1, style=plot.style_linebr, display=overlayDisplay)
fill(bandAnchorPlot, bandUpperPlot, color=bandUpperFillColor)
fill(bandAnchorPlot, bandLowerPlot, color=bandLowerFillColor)

// =============================================================================
// 6) TREND PANEL
// =============================================================================

const int panel_bg_alpha_strong = 52
const int panel_bg_alpha_regular = 66
const int panel_bg_alpha_neutral = 74
const int panel_grid_alpha = 78
// Up to two timeframe/state pairs per row; no reserved disabled-slot rows.
panelColumns = panelMtfCount > 1 ? 4 : 2
panelRows = 2 + int(math.ceil(panelMtfCount / 2.0))

panelTextColor = color.new(chart.fg_color, 0)
panelGridColor = color.new(panelTextColor, panel_grid_alpha)
panelNeutralBaseColor = f_color_lerp(ui_bullColor, ui_bearColor, 0.5, 0)
panelBgColor = biasStateId == 2 ? color.new(ui_bullColor, panel_bg_alpha_strong) :
     biasStateId == 1 ? color.new(ui_bullColor, panel_bg_alpha_regular) :
     biasStateId == -2 ? color.new(ui_bearColor, panel_bg_alpha_strong) :
     biasStateId == -1 ? color.new(ui_bearColor, panel_bg_alpha_regular) :
     color.new(panelNeutralBaseColor, panel_bg_alpha_neutral)

var table trendPanel = table.new(position.bottom_right, panelColumns, panelRows, frame_color=panelGridColor, frame_width=1, border_color=panelGridColor, border_width=1)
var bool panelDrawn = false
if barstate.isfirst and panelColumns > 2
    table.merge_cells(trendPanel, 1, 0, panelColumns - 1, 0)
    table.merge_cells(trendPanel, 1, 1, panelColumns - 1, 1)
    if panelMtfCount == 3
        table.merge_cells(trendPanel, 1, 3, panelColumns - 1, 3)

if barstate.islast or barstate.islastconfirmedhistory
    if barstate.islast and panelCorner != opt_panel_none
        biasName = f_bias_name(biasStateId)
        biasLabel = 'BIAS'
        biasText = na(biasStateId) ? 'n/a' : biasName + ' (' + str.tostring(biasPercent, '#') + '%)'
        atrPct = not na(atrSafe) and not na(close) and close != 0.0 ? atrSafe / math.abs(close) * 100.0 : na
        atrText = na(atrSafe) ? 'n/a' : str.tostring(atrSafe, format.mintick) + '(' + (na(atrPct) ? '--' : str.tostring(atrPct, '#.##') + '%') + ')'
        textSize = panelSize == opt_panel_size_small ? size.tiny : panelSize == opt_panel_size_large ? size.normal : size.small
        table.set_position(trendPanel, panelCorner == opt_panel_top ? position.top_right : position.bottom_right)
        table.cell(trendPanel, 0, 0, biasLabel, text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
        table.cell(trendPanel, 1, 0, biasText, text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
        table.cell(trendPanel, 0, 1, 'ATR14', text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
        table.cell(trendPanel, 1, 1, atrText, text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
        for [index, panelTf] in panelTimeframes
            column = (index % 2) * 2
            row = 2 + int(math.floor(index / 2.0))
            table.cell(trendPanel, column, row, f_panel_cell_text(f_timeframe_label(panelTf)), text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
            table.cell(trendPanel, column + 1, row, f_panel_cell_text(f_track_emoji(array.get(panelMtfStates, index))), text_color=panelTextColor, text_size=textSize, text_halign=text.align_center, bgcolor=panelBgColor)
        panelDrawn := true
    else if barstate.islast and panelDrawn
        table.clear(trendPanel, 0, 0, panelColumns - 1, panelRows - 1)
        panelDrawn := false
````
