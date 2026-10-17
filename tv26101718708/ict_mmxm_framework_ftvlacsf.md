# Ict Mmxm Framework

- url: https://www.tradingview.com/script/ftvLAcsF-Ict-Mmxm-Framework/
- type: indicator
- pine_id: PUB;8dee6e3db7ca493b88bdcf8e9f3dabbe
- version: 5.0

## Description

ict mmxm framework is a session-based market structure tool designed to organize intraday price delivery around fpi zones, macro windows, order blocks, imbalances, breakaway gap order blocks, opening ranges, and session range structure.

The script is built to help traders study how price behaves during the asian, london, new york morning, lunch, and new york afternoon sessions. It separates each major session into its own visual components so the user can compare pre-session ranges, active session ranges, macro windows, fpi areas, imbalance areas, order block zones, breakaway gap order blocks, and opening range levels.

[b]Main components:[/b]

[i]* pre-asian range from 7:00 pm to 9:00 pm new york time
* asian range from 9:00 pm to 12:00 am new york time
* asian macro windows at 6:50 pm to 7:10 pm, 8:50 pm to 9:10 pm, and 12:50 am to 1:10 am
* pre-london range from 2:00 am to 3:00 am new york time
* london range from 3:00 am to 5:00 am new york time
* london macro windows at 1:50 am to 2:10 am, 2:50 am to 3:10 am, and 4:50 am to 5:10 am
* new york morning, lunch, and afternoon session structure
* fpi visualization for asian, london, and new york sessions
* separate fpi detection for asian and london macro windows
* selected-bias imbalance mapping
* selected-bias order block mapping
* breakaway gap order block mapping
* high, midpoint, and low price labels for imbalance, order block, and breakaway gap order block zones
* opening range levels for the new york morning and afternoon sessions
* configurable session visibility and visual settings[/i]

The asian and london sections include range boxes, high and low references, midpoint references, macro windows, fpi areas, selected-bias imbalance zones, selected-bias order block zones, and breakaway gap order block context. These components are intended to help traders compare how price develops from one session into the next.

The selected expected bias controls how the main imbalance and order block zones are emphasized. When bearish bias is selected, the framework focuses on the highest relevant bullish order block and premium-side imbalance context. When bullish bias is selected, the framework focuses on the lowest relevant bearish order block and discount-side imbalance context.

The order block, imbalance, and breakaway gap order block zones use soft transparent colors based on the selected expected bias. Bearish bias uses red-toned zones, while bullish bias uses green-toned zones. This is intended to keep the chart visually aligned with the selected directional framework.

The purpose of this script is to provide a structured visual framework for studying session-based delivery, liquidity reference points, fpi behavior, macro timing, order blocks, imbalances, breakaway gap order blocks, and projected levels. It is intended for market context, discretionary planning, and research.


This script does not generate guaranteed trade signals, does not predict future price movement, and does not provide financial advice. It should be used together with independent analysis and proper risk management.



[b]Asian Session:[/b]
[image]https://www.tradingview.com/x/XqJ5VfWj/[/image]

[b]London Session:[/b]
[image]https://www.tradingview.com/x/R2vVOoe3/[/image]

[b]Ny Session:[/b]
[image]https://www.tradingview.com/x/219nefVK/[/image]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SunovaBeach (Modified)

//@version=6
indicator("Ict Mmxm Framework", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

timezone = "America/New_York"

// ============================= selected session engine
groupEngine = "█▓▒░ Selected Session Engine ░▒▓█"
visualTheme = input.string("Light", "Theme", options=["Light", "Dark"], group=groupEngine, tooltip="Light keeps current MMXM signature label/price text colors. Dark forces all MMXM signature label/price text to white.")
activeDetailSession = input.string("New York", "Active detail session", options=["Asian", "London", "New York"], group=groupEngine, display=display.none, tooltip="Only this selected session draws the full concept engine. Session range boxes remain separately toggleable below.")
nyDetailWindow = input.string("Morning", "New York detail window", options=["Morning", "Lunch", "Afternoon"], group=groupEngine, display=display.none, tooltip="When active detail session is New York, choose which New York window draws the concept engine.")
biasEngineMode = input.string("Auto Session FPI", "Bias engine", options=["Auto Session FPI", "Manual"], group=groupEngine, tooltip="Auto uses the selected-session FPI first, then lets the respective macro FPI override dynamically when price is above or below that macro FPI. Manual uses the setting below.")
expectedBias = input.string("Bullish", "Manual / initial bias", options=["Bearish", "Bullish"], group=groupEngine, tooltip="Manual fallback used before auto bias is calibrated, and the fixed bias when Bias engine is Manual.")
obImbDrawingTransparency = input.int(0, "OB/IMB Drawing Transparency", minval=0, maxval=100, group=groupEngine, tooltip="Adds this many transparency points only to OB/IMB drawing fills and borders. Session range boxes/labels are not affected. 0 = normal. 1 = one step more transparent. 100 = invisible.")

// ============================= session range box toggles
groupSessionToggles = "█▓▒░ SESSION RANGE BOXES ░▒▓█"
showPreAsianBox = input.bool(true, "Show pre-asian box", group=groupSessionToggles, display=display.none, tooltip="Draws the 7:00 pm to 9:00 pm New York pre-asian session range box. This remains independent from the selected detail session.")
showAsianBox = input.bool(true, "Show asian box", group=groupSessionToggles, display=display.none, tooltip="Draws the 9:00 pm to 12:00 am New York asian session range box. This remains independent from the selected detail session.")
showPreLondonBox = input.bool(true, "Show pre-london box", group=groupSessionToggles, display=display.none, tooltip="Draws the 2:00 am to 3:00 am New York pre-london session range box. This remains independent from the selected detail session.")
showLondonBox = input.bool(true, "Show london box", group=groupSessionToggles, display=display.none, tooltip="Draws the 3:00 am to 5:00 am New York london session range box. This remains independent from the selected detail session.")
showNyMorningBox = input.bool(true, "Show NY AM box", group=groupSessionToggles, display=display.none, tooltip="Draws the 9:30 am to 11:30 am NY AM session range box. This remains independent from the selected detail session.")
showNyLunchBox = input.bool(true, "Show NY Lunch box", group=groupSessionToggles, display=display.none, tooltip="Draws the 11:30 am to 1:30 pm NY Lunch session range box. This remains independent from the selected detail session.")
showNyAfternoonBox = input.bool(true, "Show NY PM box", group=groupSessionToggles, display=display.none, tooltip="Draws the 1:30 pm to 4:59 pm NY PM session range box. This remains independent from the selected detail session.")

// ============================= visual constants - code only
// All settings between the NY PM box toggle and MMXM signature controls are intentionally hard-coded.
// Edit this section directly in code if you want to change visual behavior.

// Session range visual constants
sessionBoxTransparency = 80
sessionLineTransparency = 80
sessionTextTransparency = 0
sessionTextOffsetBars = 0
sessionCenterXPlacement = "Middle"
sessionPriceXPlacement = "Right"
sessionCenterLabelTransparency = 35
sessionCenterLabelSizeInput = "normal"
showSessionPriceLabels = true
showSessionMidpoints = false
overallMidpointLineTransparency = 60

// Price label cascade constants
useStrengthPriceCascade = true
strengthCascadeFineOffsetBars = 0
// MMXM signature right-extension is session-end based only.
mmxmSignatureLabelBgColor = color.gray
mmxmSignatureLabelBgTransparency = 70
mmxmSignatureLabelAfterPriceBars = 8
preMacroReversalLineTransparency = 25
preMacroReversalBoxTransparency = 88

// FPI visual constants
fpiBoxTransparency = 70
fpiLineTransparency = 15
fpiTextTransparency = 35
fpiTextOffsetBars = 0
fpiCenterXPlacement = "Middle left"
fpiPriceXPlacement = "Right"
fpiCenterLabelTransparency = 35
fpiCenterLabelSizeInput = "normal"

// Projection visual constants
projectionBoxTransparency = 85
projectionLineTransparency = 15
projectionTextTransparency = 35
projectionTextOffsetBars = 0
projectionCenterXPlacement = "Middle"
projectionPriceXPlacement = "Right"
projectionCenterLabelTransparency = 35
projectionCenterLabelSizeInput = "normal"

// Macro visual constants
macroBoxTransparency = 85
macroLineTransparency = 15
macroTextTransparency = 35
macroTextOffsetBars = 0
macroCenterXPlacement = "Middle"
macroPriceXPlacement = "Right"
macroCenterLabelTransparency = 35
macroCenterLabelSizeInput = "normal"

// ============================= MMXM signature enable controls
groupMmxmSignatureControls = "█▓▒░ mmxm signature controls ░▒▓█"
showSessionFpiSignature = input.bool(true, "Enable session FPI", group=groupMmxmSignatureControls)
showMacroSignature = input.bool(true, "Enable respective macro", group=groupMmxmSignatureControls)
showBullishImbSignature = input.bool(true, "Enable bullish IMB", group=groupMmxmSignatureControls)
showBearishImbSignature = input.bool(true, "Enable bearish IMB", group=groupMmxmSignatureControls)
showOrderBlockSignature = input.bool(true, "Enable order block", group=groupMmxmSignatureControls)
showBgobSignature = input.bool(true, "Enable BGOB", group=groupMmxmSignatureControls)
showPreMacroReversalOb = input.bool(true, "Enable pre-macro reversal OB", group=groupMmxmSignatureControls)

// ============================= MMXM signature visual constants - code only
groupImbVisual = "imbalance visuals"
imbBoxTransparency = 75
imbLineTransparency = 15
selectedBiasImbLineExtraTransparency = 10
imbTextTransparency = 35
imbTextOffsetBars = 0
imbCenterXPlacement = "Middle right"
imbPriceXPlacement = "Right"
imbCenterLabelTransparency = 35
imbCenterLabelSizeInput = "normal"

groupObVisual = "order block visuals"
obBoxTransparency = 65
obLineTransparency = 15
obTextTransparency = 35
obTextOffsetBars = 0
obCenterXPlacement = "Middle"
obPriceXPlacement = "Right"
obCenterLabelTransparency = 35
obCenterLabelSizeInput = "normal"

groupBgobVisual = "breakaway gap order block visuals"
bgobBoxTransparency = 80
bgobLineTransparency = 15
bgobTextTransparency = 35
bgobTextOffsetBars = 0
bgobCenterXPlacement = "Middle"
bgobPriceXPlacement = "Right"
bgobCenterLabelTransparency = 35
bgobCenterLabelSizeInput = "normal"

// ============================= OB/IMB visual filter
f_transparency(_baseTransparency) =>
    int(math.min(100, math.max(0, _baseTransparency)))

f_obimb_transparency(_baseTransparency) =>
    int(math.min(100, math.max(0, _baseTransparency + obImbDrawingTransparency)))

f_color(color _baseColor, _baseTransparency) =>
    color.new(_baseColor, f_transparency(_baseTransparency))

f_obimb_color(color _baseColor, _baseTransparency) =>
    color.new(_baseColor, f_obimb_transparency(_baseTransparency))

// ============================= constants and colors
int manualBiasDir = expectedBias == "Bullish" ? 1 : -1
var int activeBiasDir = manualBiasDir
f_expected_bullish() =>
    activeBiasDir == 1
f_bias_base() =>
    f_expected_bullish() ? color.green : color.red
f_opposite_bias_base() =>
    f_expected_bullish() ? color.red : color.green
bool darkTheme = visualTheme == "Dark"
color biasBase = f_bias_base()
color oppositeBiasBase = f_opposite_bias_base()

color themeTextColor = darkTheme ? f_color(color.white, 0) : f_color(color.black, 0)

color sessionBoxColor = f_color(color.silver, sessionBoxTransparency)
color sessionLineColor = f_color(color.gray, sessionLineTransparency)
color midpointDashLineColor = f_color(color.white, overallMidpointLineTransparency)
color sessionTextColor = themeTextColor
color preMacroReversalLineColor = f_obimb_color(color.rgb(70, 145, 255), preMacroReversalLineTransparency)
color preMacroReversalBoxColor = f_obimb_color(color.rgb(70, 145, 255), preMacroReversalBoxTransparency)

color fpiBoxColor = f_color(color.blue, fpiBoxTransparency)
color fpiBullBorderColor = f_color(color.green, fpiLineTransparency)
color fpiBearBorderColor = f_color(color.red, fpiLineTransparency)
color fpiLineColor = f_color(color.blue, fpiLineTransparency)
color fpiTextColor = themeTextColor

color projectionBoxColor = f_color(color.blue, projectionBoxTransparency)
color projectionLineColor = f_color(color.black, projectionLineTransparency)
color projectionTextColor = themeTextColor

color macroBoxColor = f_color(color.rgb(40, 40, 40), macroBoxTransparency)
color macroLineColor = f_color(color.black, macroLineTransparency)
color macroTextColor = themeTextColor

color bullImbBoxColor = f_obimb_color(color.green, imbBoxTransparency)
color bearImbBoxColor = f_obimb_color(color.red, imbBoxTransparency)
color bullImbLineColor = f_obimb_color(color.green, imbLineTransparency)
color bearImbLineColor = f_obimb_color(color.red, imbLineTransparency)
color selectedBiasBullImbLineColor = f_obimb_color(color.green, imbLineTransparency + selectedBiasImbLineExtraTransparency)
color selectedBiasBearImbLineColor = f_obimb_color(color.red, imbLineTransparency + selectedBiasImbLineExtraTransparency)
color bullImbTextColor = f_color(color.black, 0)
color bearImbTextColor = f_color(color.black, 0)
color imbBoxColor = f_expected_bullish() ? bullImbBoxColor : bearImbBoxColor
color imbLineColor = f_expected_bullish() ? bullImbLineColor : bearImbLineColor
color imbTextColor = f_expected_bullish() ? bullImbTextColor : bearImbTextColor

color obBoxColor = f_obimb_color(biasBase, obBoxTransparency)
color obLineColor = f_obimb_color(color.black, obLineTransparency)
color obTextColor = f_color(color.black, 0)

color bgobBoxColor = f_obimb_color(biasBase, bgobBoxTransparency)
color bgobLineColor = f_obimb_color(color.black, bgobLineTransparency)
color bgobTextColor = f_color(color.black, 0)

f_ob_box_color() =>
    f_obimb_color(f_bias_base(), obBoxTransparency)
f_bgob_box_color() =>
    f_obimb_color(f_bias_base(), bgobBoxTransparency)

color sessionCenterTextColor = themeTextColor
color fpiCenterTextColor = themeTextColor
color projectionCenterTextColor = themeTextColor
color macroCenterTextColor = themeTextColor
color imbCenterTextColor = f_color(color.black, 0)
color obCenterTextColor = f_color(color.black, 0)
color bgobCenterTextColor = f_color(color.black, 0)

// ============================= helpers
f_in_clock_window(_t, _sh, _sm, _eh, _em) =>
    if na(_t)
        false
    else
        _cur = hour(_t, timezone) * 60 + minute(_t, timezone)
        _s = _sh * 60 + _sm
        _e = _eh * 60 + _em
        _s <= _e ? (_cur >= _s and _cur < _e) : (_cur >= _s or _cur < _e)

f_session_start_time(_sh, _sm, _eh, _em) =>
    _cur = hour(time, timezone) * 60 + minute(time, timezone)
    _s = _sh * 60 + _sm
    _e = _eh * 60 + _em
    _st = timestamp(timezone, year(time, timezone), month(time, timezone), dayofmonth(time, timezone), _sh, _sm)
    _e <= _s and _cur < _e ? _st - 86400000 : _st

f_session_end_time(_sh, _sm, _eh, _em) =>
    _cur = hour(time, timezone) * 60 + minute(time, timezone)
    _s = _sh * 60 + _sm
    _e = _eh * 60 + _em
    _en = timestamp(timezone, year(time, timezone), month(time, timezone), dayofmonth(time, timezone), _eh, _em)
    _e <= _s and _cur >= _s ? _en + 86400000 : _en

f_offset_time(_t, _bars) =>
    _t + _bars * timeframe.in_seconds() * 1000

f_place_x(_left, _right, _placement, _fineBars) =>
    _width = _right - _left
    _base = _placement == "Left outside" ? _left - int(math.round(_width * 0.05)) : _placement == "Left" ? _left + int(math.round(_width * 0.06)) : _placement == "Middle left" ? _left + int(math.round(_width * 0.33)) : _placement == "Middle" ? _left + int(math.round(_width * 0.50)) : _placement == "Middle right" ? _left + int(math.round(_width * 0.67)) : _placement == "Right" ? _right - int(math.round(_width * 0.06)) : _right + int(math.round(_width * 0.05))
    _base + _fineBars * timeframe.in_seconds() * 1000

f_strength_price_x(_idx, _left, _right, _fineBars) =>
    _width = _right - _left
    _pct = _idx == 8 ? 0.67 : _idx == 0 ? 0.75 : (_idx == 6 or _idx == 7) ? 0.83 : _idx == 9 ? 0.91 : (_idx == 1 or _idx == 2) ? 0.97 : 0.91
    _base = _left + int(math.round(_width * _pct))
    _base + (_fineBars + strengthCascadeFineOffsetBars) * timeframe.in_seconds() * 1000

f_concept_price_x_placement(_idx) =>
    _idx == 0 ? fpiPriceXPlacement : _idx == 1 or _idx == 2 ? projectionPriceXPlacement : _idx >= 3 and _idx <= 5 ? macroPriceXPlacement : _idx == 6 or _idx == 7 ? imbPriceXPlacement : _idx == 8 ? obPriceXPlacement : _idx == 9 ? bgobPriceXPlacement : "Right"

f_concept_price_x(_idx, _left, _right, _fineBars) =>
    useStrengthPriceCascade ? f_strength_price_x(_idx, _left, _right, _fineBars) : f_place_x(_left, _right, f_concept_price_x_placement(_idx), _fineBars)

f_mid(_top, _bottom) =>
    (_top + _bottom) / 2.0

f_text_size(_sizeInput) =>
    _sizeInput == "tiny" ? size.tiny : _sizeInput == "small" ? size.small : _sizeInput == "large" ? size.large : _sizeInput == "huge" ? size.huge : size.normal

f_text_size_plus_one(_sizeInput) =>
    _sizeInput == "tiny" ? size.small : _sizeInput == "small" ? size.normal : _sizeInput == "normal" ? size.large : size.huge

f_text_size_plus_two(_sizeInput) =>
    _sizeInput == "tiny" ? size.normal : _sizeInput == "small" ? size.large : size.huge

f_macro_label(_sh, _sm) =>
    _hour12 = _sh % 12 == 0 ? 12 : _sh % 12
    _ampm = _sh >= 12 ? "PM" : "AM"
    // Fixes Asian/London macro labels so 20:50 displays as 8:50 PM, not 2050.
    str.tostring(_hour12) + ":" + str.tostring(_sm, "00") + " " + _ampm + " macro"

f_is_signature_concept(_idx) =>
    _idx == 0 or _idx == 1 or _idx == 2 or _idx == 6 or _idx == 7 or _idx == 8 or _idx == 9

f_is_macro_shell(_idx) =>
    _idx >= 3 and _idx <= 5

f_is_ob_imb_horizontal_only(_idx) =>
    _idx == 6 or _idx == 7 or _idx == 8 or _idx == 9 or _idx == 10 or _idx == 11 or _idx == 12 or _idx == 13

f_concept_strength_transparency(_idx) =>
    _idx == 8 ? obBoxTransparency : _idx == 0 ? fpiBoxTransparency : _idx == 6 or _idx == 7 ? imbBoxTransparency : _idx == 9 ? bgobBoxTransparency : _idx == 1 or _idx == 2 ? projectionBoxTransparency : 80

f_concept_strength_base_color(_idx) =>
    if _idx == 0 or _idx == 1 or _idx == 2
        color.blue
    else if _idx == 6
        color.green
    else if _idx == 7
        color.red
    else if f_expected_bullish()
        _idx == 8 ? color.rgb(0, 70, 0) : _idx == 9 ? color.rgb(35, 195, 35) : f_bias_base()
    else
        _idx == 8 ? color.rgb(110, 0, 0) : _idx == 9 ? color.rgb(235, 65, 65) : f_bias_base()

f_concept_strength_color(_idx) =>
    (_idx == 6 or _idx == 7 or _idx == 8 or _idx == 9) ? f_obimb_color(f_concept_strength_base_color(_idx), f_concept_strength_transparency(_idx)) : f_color(f_concept_strength_base_color(_idx), f_concept_strength_transparency(_idx))

f_concept_box_color(_idx, _fallback) =>
    _idx == 0 ? fpiBoxColor : _idx == 1 or _idx == 2 ? projectionBoxColor : _idx == 6 ? bullImbBoxColor : _idx == 7 ? bearImbBoxColor : f_is_signature_concept(_idx) ? f_concept_strength_color(_idx) : _fallback

f_concept_text_color(_idx, _fallback) =>
    f_color(color.black, 0)

f_concept_center_text_color(_idx) =>
    f_color(color.black, 0)

f_is_mmxm_signature(_idx) =>
    _idx == 6 or _idx == 7 or _idx == 8 or _idx == 9

f_mmxm_signature_label_text_color(_idx, color _lineColor) =>
    _resolvedLineColor = na(_lineColor) ? (_idx == 8 ? obLineColor : _idx == 9 ? bgobLineColor : _idx == 6 ? selectedBiasBullImbLineColor : _idx == 7 ? selectedBiasBearImbLineColor : f_color(color.black, 0)) : _lineColor
    darkTheme ? f_color(color.white, 0) : ((_idx == 6 or _idx == 7) ? f_color(color.black, 0) : _resolvedLineColor)

f_concept_label_bg_color(_idx, _lineColor) =>
    f_color(color.white, 100)

f_concept_price_label_bg_color(_idx, _lineColor) =>
    f_color(color.white, 100)

f_concept_center_text_size(_idx) =>
    _idx == 0 ? f_text_size_plus_one(fpiCenterLabelSizeInput) : _idx == 1 or _idx == 2 ? f_text_size(projectionCenterLabelSizeInput) : _idx >= 3 and _idx <= 5 ? f_text_size(macroCenterLabelSizeInput) : _idx == 6 or _idx == 7 ? f_text_size(imbCenterLabelSizeInput) : _idx == 8 ? f_text_size(obCenterLabelSizeInput) : _idx == 9 ? f_text_size(bgobCenterLabelSizeInput) : size.normal

f_concept_center_x_placement(_idx) =>
    _idx == 0 ? fpiCenterXPlacement : _idx == 1 or _idx == 2 ? projectionCenterXPlacement : _idx >= 3 and _idx <= 5 ? macroCenterXPlacement : _idx == 6 or _idx == 7 ? imbCenterXPlacement : _idx == 8 ? obCenterXPlacement : _idx == 9 ? bgobCenterXPlacement : "Middle"

f_concept_border_width(_idx) =>
    _idx == 8 ? 4 : _idx == 0 ? 2 : _idx == 6 or _idx == 7 ? 2 : _idx == 9 ? 1 : _idx >= 10 and _idx <= 12 ? 1 : 1

// MMXM signature labels sit in the lower-middle-right of their respective box.
// Text color inherits the same color/transparency as that signature's border.
f_mmxm_signature_text(_idx) =>
    _idx == 6 ? "Bullish IMB" : _idx == 7 ? "Bearish IMB" : _idx == 8 ? (f_expected_bullish() ? "+OB" : "-OB") : _idx == 9 ? "BGOB" : ""

f_mmxm_signature_label_x(_idx, _left, _right, _fineBars) =>
    math.min(((_idx == 6 or _idx == 7 or _idx == 9) ? f_place_x(_left, _right, "Middle", _fineBars) : f_concept_price_x(_idx, _left, _right, _fineBars) + mmxmSignatureLabelAfterPriceBars * timeframe.in_seconds() * 1000), _right)

f_mmxm_signature_y(_top, _bottom) =>
    f_mid(_top, _bottom)

f_mmxm_signature_text_size(_idx) =>
    _idx == 8 ? size.large : size.normal

f_mmxm_signature_priority(_idx) =>
    _idx == 8 ? 0 : _idx == 6 ? 1 : _idx == 7 ? 2 : _idx == 9 ? 3 : 9

// ============================= session range object state
var bool[] rActive = array.new_bool(7, false)
var float[] rHi = array.new_float(7, na)
var float[] rLo = array.new_float(7, na)
var int[] rStart = array.new_int(7, na)
var box[] rBox = array.new_box(7, na)
var line[] rHiLine = array.new_line(7, na)
var line[] rMidLine = array.new_line(7, na)
var line[] rLoLine = array.new_line(7, na)
var label[] rTextLab = array.new_label(7, na)
var label[] rHiLab = array.new_label(7, na)
var label[] rMidLab = array.new_label(7, na)
var label[] rLoLab = array.new_label(7, na)

f_session_label_y(_hi, _lo) =>
    _height = math.abs(_hi - _lo)
    _lo - math.max(_height * 0.06, syminfo.mintick * 20)

f_delete_range(_idx) =>
    _b = array.get(rBox, _idx)
    _h = array.get(rHiLine, _idx)
    _m = array.get(rMidLine, _idx)
    _l = array.get(rLoLine, _idx)
    _t = array.get(rTextLab, _idx)
    _hl = array.get(rHiLab, _idx)
    _ml = array.get(rMidLab, _idx)
    _ll = array.get(rLoLab, _idx)
    if not na(_b)
        box.delete(_b)
    if not na(_h)
        line.delete(_h)
    if not na(_m)
        line.delete(_m)
    if not na(_l)
        line.delete(_l)
    if not na(_t)
        label.delete(_t)
    if not na(_hl)
        label.delete(_hl)
    if not na(_ml)
        label.delete(_ml)
    if not na(_ll)
        label.delete(_ll)
    array.set(rBox, _idx, na)
    array.set(rHiLine, _idx, na)
    array.set(rMidLine, _idx, na)
    array.set(rLoLine, _idx, na)
    array.set(rTextLab, _idx, na)
    array.set(rHiLab, _idx, na)
    array.set(rMidLab, _idx, na)
    array.set(rLoLab, _idx, na)

f_process_range(_idx, _enabled, _name, _sh, _sm, _eh, _em) =>
    _in = _enabled and f_in_clock_window(time, _sh, _sm, _eh, _em)
    _was = array.get(rActive, _idx)
    if _in and not _was
        f_delete_range(_idx)
        _start = f_session_start_time(_sh, _sm, _eh, _em)
        _right = f_session_end_time(_sh, _sm, _eh, _em)
        array.set(rHi, _idx, high)
        array.set(rLo, _idx, low)
        array.set(rStart, _idx, _start)
        _b = box.new(_start, high, _right, low, xloc=xloc.bar_time, bgcolor=sessionBoxColor, border_color=sessionLineColor, text="")
        _hi = line.new(_start, high, _right, high, xloc=xloc.bar_time, color=sessionLineColor, width=1)
        _lo = line.new(_start, low, _right, low, xloc=xloc.bar_time, color=sessionLineColor, width=1)
        _mid = showSessionMidpoints ? line.new(_start, f_mid(high, low), _right, f_mid(high, low), xloc=xloc.bar_time, color=midpointDashLineColor, width=1, style=line.style_dashed) : na
        _xCenter = f_place_x(_start, _right, sessionCenterXPlacement, sessionTextOffsetBars)
        _xText = f_place_x(_start, _right, sessionPriceXPlacement, sessionTextOffsetBars)
        _txt = label.new(_xCenter, f_session_label_y(high, low), _name + " range", xloc=xloc.bar_time, style=label.style_none, color=f_color(sessionBoxColor, 100), textcolor=f_color(sessionTextColor, sessionTextTransparency), size=size.huge)
        _hl = showSessionPriceLabels ? label.new(_xText, high, str.tostring(high, format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(sessionBoxColor, 100), textcolor=sessionTextColor, size=size.normal) : na
        _ml = showSessionPriceLabels ? label.new(_xText, f_mid(high, low), str.tostring(f_mid(high, low), format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(sessionBoxColor, 100), textcolor=sessionTextColor, size=size.normal) : na
        _ll = showSessionPriceLabels ? label.new(_xText, low, str.tostring(low, format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(sessionBoxColor, 100), textcolor=sessionTextColor, size=size.normal) : na
        array.set(rBox, _idx, _b)
        array.set(rHiLine, _idx, _hi)
        array.set(rMidLine, _idx, _mid)
        array.set(rLoLine, _idx, _lo)
        array.set(rTextLab, _idx, _txt)
        array.set(rHiLab, _idx, _hl)
        array.set(rMidLab, _idx, _ml)
        array.set(rLoLab, _idx, _ll)
    if _in
        _start = array.get(rStart, _idx)
        _start := na(_start) ? f_session_start_time(_sh, _sm, _eh, _em) : _start
        _newHi = math.max(nz(array.get(rHi, _idx), high), high)
        _newLo = math.min(nz(array.get(rLo, _idx), low), low)
        _right = f_session_end_time(_sh, _sm, _eh, _em)
        _mp = f_mid(_newHi, _newLo)
        _xCenter = f_place_x(_start, _right, sessionCenterXPlacement, sessionTextOffsetBars)
        _xText = f_place_x(_start, _right, sessionPriceXPlacement, sessionTextOffsetBars)
        array.set(rHi, _idx, _newHi)
        array.set(rLo, _idx, _newLo)
        _b = array.get(rBox, _idx)
        _hi = array.get(rHiLine, _idx)
        _midLine = array.get(rMidLine, _idx)
        _lo = array.get(rLoLine, _idx)
        _txt = array.get(rTextLab, _idx)
        _hl = array.get(rHiLab, _idx)
        _ml = array.get(rMidLab, _idx)
        _ll = array.get(rLoLab, _idx)
        if not na(_b)
            box.set_right(_b, _right)
            box.set_top(_b, _newHi)
            box.set_bottom(_b, _newLo)
        if not na(_hi)
            line.set_x2(_hi, _right)
            line.set_y1(_hi, _newHi)
            line.set_y2(_hi, _newHi)
        if not na(_midLine)
            line.set_x2(_midLine, _right)
            line.set_y1(_midLine, _mp)
            line.set_y2(_midLine, _mp)
        if not na(_lo)
            line.set_x2(_lo, _right)
            line.set_y1(_lo, _newLo)
            line.set_y2(_lo, _newLo)
        if not na(_txt)
            label.set_x(_txt, _xCenter)
            label.set_y(_txt, f_session_label_y(_newHi, _newLo))
            label.set_text(_txt, _name + " range")
            label.set_textcolor(_txt, f_color(sessionTextColor, sessionTextTransparency))
            label.set_size(_txt, size.huge)
        if not na(_hl)
            label.set_x(_hl, _xText)
            label.set_y(_hl, _newHi)
            label.set_text(_hl, str.tostring(_newHi, format.mintick))
            label.set_textcolor(_hl, sessionTextColor)
        if not na(_ml)
            label.set_x(_ml, _xText)
            label.set_y(_ml, _mp)
            label.set_text(_ml, str.tostring(_mp, format.mintick))
            label.set_textcolor(_ml, sessionTextColor)
        if not na(_ll)
            label.set_x(_ll, _xText)
            label.set_y(_ll, _newLo)
            label.set_text(_ll, str.tostring(_newLo, format.mintick))
            label.set_textcolor(_ll, sessionTextColor)
    array.set(rActive, _idx, _in)

// ============================= concept object state
var box[] cBox = array.new_box(20, na)
var int[] cLeft = array.new_int(20, na)
var line[] cHiLine = array.new_line(20, na)
var line[] cMidLine = array.new_line(20, na)
var line[] cLoLine = array.new_line(20, na)
var label[] cTextLab = array.new_label(20, na)
var label[] cHiLab = array.new_label(20, na)
var label[] cMidLab = array.new_label(20, na)
var label[] cLoLab = array.new_label(20, na)

f_delete_concept(_idx) =>
    _b = array.get(cBox, _idx)
    _h = array.get(cHiLine, _idx)
    _m = array.get(cMidLine, _idx)
    _l = array.get(cLoLine, _idx)
    _t = array.get(cTextLab, _idx)
    _hl = array.get(cHiLab, _idx)
    _ml = array.get(cMidLab, _idx)
    _ll = array.get(cLoLab, _idx)
    if not na(_b)
        box.delete(_b)
    if not na(_h)
        line.delete(_h)
    if not na(_m)
        line.delete(_m)
    if not na(_l)
        line.delete(_l)
    if not na(_t)
        label.delete(_t)
    if not na(_hl)
        label.delete(_hl)
    if not na(_ml)
        label.delete(_ml)
    if not na(_ll)
        label.delete(_ll)
    array.set(cBox, _idx, na)
    array.set(cLeft, _idx, na)
    array.set(cHiLine, _idx, na)
    array.set(cMidLine, _idx, na)
    array.set(cLoLine, _idx, na)
    array.set(cTextLab, _idx, na)
    array.set(cHiLab, _idx, na)
    array.set(cMidLab, _idx, na)
    array.set(cLoLab, _idx, na)

f_draw_concept(_idx, _left, _right, _top, _bottom, _name, _boxColor, _lineColor, _textColor, _showPriceLabels, _showMid, _textOffsetBars) =>
    f_delete_concept(_idx)
    _mp = f_mid(_top, _bottom)
    _isSignature = f_is_mmxm_signature(_idx)
    _isMacroShell = f_is_macro_shell(_idx)
    _horizontalOnly = f_is_ob_imb_horizontal_only(_idx)
    _xCenter = _isSignature ? f_mmxm_signature_label_x(_idx, _left, _right, _textOffsetBars) : f_place_x(_left, _right, f_concept_center_x_placement(_idx), _textOffsetBars)
    _xText = f_concept_price_x(_idx, _left, _right, _textOffsetBars)
    _lineWidth = _isMacroShell ? 1 : f_concept_border_width(_idx)
    _effectiveBoxColor = _isMacroShell ? f_color(color.white, 100) : f_concept_box_color(_idx, _boxColor)
    _effectiveBorderColor = (_isMacroShell or _horizontalOnly) ? f_color(_lineColor, 100) : _lineColor
    _labelText = _isMacroShell ? "" : (_isSignature ? f_mmxm_signature_text(_idx) : _name)
    _labelStyle = label.style_none
    _labelBg = f_concept_label_bg_color(_idx, _lineColor)
    _b = box.new(_left, _top, _right, _bottom, xloc=xloc.bar_time, bgcolor=_effectiveBoxColor, border_color=_effectiveBorderColor, border_width=_lineWidth, text="")
    _hi = line.new(_left, _top, _right, _top, xloc=xloc.bar_time, color=_lineColor, width=_lineWidth)
    _lo = line.new(_left, _bottom, _right, _bottom, xloc=xloc.bar_time, color=_lineColor, width=_lineWidth)
    _midLineColor = midpointDashLineColor
    line _mid = (_showMid and not _isMacroShell) ? line.new(_left, _mp, _right, _mp, xloc=xloc.bar_time, color=_midLineColor, width=1, style=line.style_dashed) : na
    _txtY = _isSignature ? f_mmxm_signature_y(_top, _bottom) : _mp
    _txtColor = _isSignature ? f_mmxm_signature_label_text_color(_idx, _lineColor) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0))
    _priceLabelStyle = label.style_none
    _priceTextColor = _isSignature ? f_mmxm_signature_label_text_color(_idx, _lineColor) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0))
    label _txt = _isMacroShell ? na : label.new(_xCenter, _txtY, _labelText, xloc=xloc.bar_time, style=_labelStyle, color=_labelBg, textcolor=_txtColor, size=_isSignature ? f_mmxm_signature_text_size(_idx) : f_concept_center_text_size(_idx), textalign=text.align_center)
    label _hl = _showPriceLabels ? label.new(_xText, _top, str.tostring(_top, format.mintick), xloc=xloc.bar_time, style=_priceLabelStyle, color=f_concept_price_label_bg_color(_idx, _lineColor), textcolor=_priceTextColor, size=size.normal) : na
    label _ml = (_showPriceLabels and not _isMacroShell) ? label.new(_xText, _mp, str.tostring(_mp, format.mintick), xloc=xloc.bar_time, style=_priceLabelStyle, color=f_concept_price_label_bg_color(_idx, _lineColor), textcolor=_priceTextColor, size=size.normal) : na
    label _ll = _showPriceLabels ? label.new(_xText, _bottom, str.tostring(_bottom, format.mintick), xloc=xloc.bar_time, style=_priceLabelStyle, color=f_concept_price_label_bg_color(_idx, _lineColor), textcolor=_priceTextColor, size=size.normal) : na
    array.set(cBox, _idx, _b)
    array.set(cLeft, _idx, _left)
    array.set(cHiLine, _idx, _hi)
    array.set(cMidLine, _idx, _mid)
    array.set(cLoLine, _idx, _lo)
    array.set(cTextLab, _idx, _txt)
    array.set(cHiLab, _idx, _hl)
    array.set(cMidLab, _idx, _ml)
    array.set(cLoLab, _idx, _ll)

f_update_concept(_idx, _right, _top, _bottom, _name, _textOffsetBars) =>
    _mp = f_mid(_top, _bottom)
    _left = array.get(cLeft, _idx)
    _left := na(_left) ? _right : _left
    _isSignature = f_is_mmxm_signature(_idx)
    _isMacroShell = f_is_macro_shell(_idx)
    _horizontalOnly = f_is_ob_imb_horizontal_only(_idx)
    _xCenter = _isSignature ? f_mmxm_signature_label_x(_idx, _left, _right, _textOffsetBars) : f_place_x(_left, _right, f_concept_center_x_placement(_idx), _textOffsetBars)
    _xText = f_concept_price_x(_idx, _left, _right, _textOffsetBars)
    _labelText = _isMacroShell ? "" : (_isSignature ? f_mmxm_signature_text(_idx) : _name)
    _txtY = _isSignature ? f_mmxm_signature_y(_top, _bottom) : _mp
    _b = array.get(cBox, _idx)
    _hi = array.get(cHiLine, _idx)
    _mid = array.get(cMidLine, _idx)
    _lo = array.get(cLoLine, _idx)
    _txt = array.get(cTextLab, _idx)
    _hl = array.get(cHiLab, _idx)
    _ml = array.get(cMidLab, _idx)
    _ll = array.get(cLoLab, _idx)
    if not na(_b)
        box.set_right(_b, _right)
        box.set_top(_b, _top)
        box.set_bottom(_b, _bottom)
        box.set_text(_b, "")
        if _isMacroShell
            box.set_bgcolor(_b, f_color(color.white, 100))
            box.set_border_color(_b, f_color(macroLineColor, 100))
        if _horizontalOnly
            box.set_border_color(_b, f_color(color.black, 100))
    if not na(_hi)
        line.set_x2(_hi, _right)
        line.set_y1(_hi, _top)
        line.set_y2(_hi, _top)
    if not na(_mid)
        line.set_x2(_mid, _right)
        line.set_y1(_mid, _mp)
        line.set_y2(_mid, _mp)
    if not na(_lo)
        line.set_x2(_lo, _right)
        line.set_y1(_lo, _bottom)
        line.set_y2(_lo, _bottom)
    if not na(_txt)
        label.set_x(_txt, _xCenter)
        label.set_y(_txt, _txtY)
        label.set_text(_txt, _labelText)
        label.set_textcolor(_txt, _isSignature ? f_mmxm_signature_label_text_color(_idx, na) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0)))
    if not na(_hl)
        label.set_x(_hl, _xText)
        label.set_y(_hl, _top)
        label.set_text(_hl, str.tostring(_top, format.mintick))
        label.set_textcolor(_hl, _isSignature ? f_mmxm_signature_label_text_color(_idx, na) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0)))
    if not na(_ml)
        label.set_x(_ml, _xText)
        label.set_y(_ml, _mp)
        label.set_text(_ml, str.tostring(_mp, format.mintick))
        label.set_textcolor(_ml, _isSignature ? f_mmxm_signature_label_text_color(_idx, na) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0)))
    if not na(_ll)
        label.set_x(_ll, _xText)
        label.set_y(_ll, _bottom)
        label.set_text(_ll, str.tostring(_bottom, format.mintick))
        label.set_textcolor(_ll, _isSignature ? f_mmxm_signature_label_text_color(_idx, na) : (_idx == 0 ? fpiTextColor : _idx == 1 or _idx == 2 ? projectionTextColor : _idx >= 3 and _idx <= 5 ? macroTextColor : f_color(color.black, 0)))

f_mmxm_signature_is_active(_idx) =>
    not na(array.get(cBox, _idx))

f_mmxm_signature_other_beats(_idx, _otherIdx, _top, _bottom) =>
    _otherBox = array.get(cBox, _otherIdx)
    if na(_otherBox) or _idx == _otherIdx
        false
    else
        _otherTop = box.get_top(_otherBox)
        _otherBottom = box.get_bottom(_otherBox)
        _otherPriority = f_mmxm_signature_priority(_otherIdx)
        _thisPriority = f_mmxm_signature_priority(_idx)
        // Bullish: lowest low extends farthest. Bearish: highest high extends farthest.
        f_expected_bullish() ? (_otherBottom < _bottom or (_otherBottom == _bottom and _otherPriority < _thisPriority)) : (_otherTop > _top or (_otherTop == _top and _otherPriority < _thisPriority))

f_mmxm_signature_rank(_idx) =>
    _box = array.get(cBox, _idx)
    if na(_box)
        0
    else
        _top = box.get_top(_box)
        _bottom = box.get_bottom(_box)
        _rank = 0
        _rank += f_mmxm_signature_other_beats(_idx, 8, _top, _bottom) ? 1 : 0
        _rank += f_mmxm_signature_other_beats(_idx, 6, _top, _bottom) ? 1 : 0
        _rank += f_mmxm_signature_other_beats(_idx, 7, _top, _bottom) ? 1 : 0
        _rank += f_mmxm_signature_other_beats(_idx, 9, _top, _bottom) ? 1 : 0
        _rank

f_set_mmxm_signature_right(_idx, _right) =>
    _box = array.get(cBox, _idx)
    if not na(_box)
        _top = box.get_top(_box)
        _bottom = box.get_bottom(_box)
        _mp = f_mid(_top, _bottom)
        box.set_right(_box, _right)
        _hi = array.get(cHiLine, _idx)
        _mid = array.get(cMidLine, _idx)
        _lo = array.get(cLoLine, _idx)
        _txt = array.get(cTextLab, _idx)
        _hl = array.get(cHiLab, _idx)
        _ml = array.get(cMidLab, _idx)
        _ll = array.get(cLoLab, _idx)
        if not na(_hi)
            line.set_x2(_hi, _right)
        if not na(_mid)
            line.set_x2(_mid, _right)
        if not na(_lo)
            line.set_x2(_lo, _right)
        if not na(_txt)
            label.set_x(_txt, f_mmxm_signature_label_x(_idx, array.get(cLeft, _idx), _right, 0))
            label.set_y(_txt, f_mmxm_signature_y(_top, _bottom))
            label.set_text(_txt, f_mmxm_signature_text(_idx))
        if not na(_hl)
            label.set_x(_hl, _right)
            label.set_y(_hl, _top)
        if not na(_ml)
            label.set_x(_ml, _right)
            label.set_y(_ml, _mp)
        if not na(_ll)
            label.set_x(_ll, _right)
            label.set_y(_ll, _bottom)

f_mmxm_signature_session_right(_idx, _sessionEnd) =>
    _box = array.get(cBox, _idx)
    if na(_box)
        _sessionEnd
    else
        _left = array.get(cLeft, _idx)
        _left := na(_left) ? box.get_left(_box) : _left
        _rank = f_mmxm_signature_rank(_idx)
        _factor = _rank == 0 ? 1.0 : _rank == 1 ? 0.75 : _rank == 2 ? 0.50 : 0.25
        _span = math.max(_sessionEnd - _left, 1)
        _candidate = _left + int(math.round(_span * _factor))
        math.min(_candidate, _sessionEnd)

f_apply_mmxm_signature_right_cascade(_sessionEnd) =>
    if f_mmxm_signature_is_active(8)
        f_set_mmxm_signature_right(8, f_mmxm_signature_session_right(8, _sessionEnd))
    if f_mmxm_signature_is_active(6)
        f_set_mmxm_signature_right(6, f_mmxm_signature_session_right(6, _sessionEnd))
    if f_mmxm_signature_is_active(7)
        f_set_mmxm_signature_right(7, f_mmxm_signature_session_right(7, _sessionEnd))
    if f_mmxm_signature_is_active(9)
        f_set_mmxm_signature_right(9, f_mmxm_signature_session_right(9, _sessionEnd))

// Redraw mmxm signatures from strongest to weakest so weaker signatures sit visually on top.
// Pine draws newer objects above older objects. This intentionally redraws rank 0 first,
// then rank 1, rank 2, and rank 3 last.
f_redraw_mmxm_signature(_idx) =>
    _b = array.get(cBox, _idx)
    if not na(_b)
        _left = array.get(cLeft, _idx)
        _right = box.get_right(_b)
        _top = box.get_top(_b)
        _bottom = box.get_bottom(_b)
        if _idx == 8
            f_draw_concept(8, _left, _right, _top, _bottom, "order block", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
            f_set_mmxm_signature_right(8, _right)
        if _idx == 6
            f_draw_concept(6, _left, _right, _top, _bottom, "bullish imbalance", bullImbBoxColor, bullImbLineColor, bullImbTextColor, true, true, imbTextOffsetBars)
            f_set_mmxm_signature_right(6, _right)
        if _idx == 7
            f_draw_concept(7, _left, _right, _top, _bottom, "bearish imbalance", bearImbBoxColor, bearImbLineColor, bearImbTextColor, true, true, imbTextOffsetBars)
            f_set_mmxm_signature_right(7, _right)
        if _idx == 9
            f_draw_concept(9, _left, _right, _top, _bottom, "breakaway gap order block", f_bgob_box_color(), bgobLineColor, bgobTextColor, true, true, bgobTextOffsetBars)
            f_set_mmxm_signature_right(9, _right)

f_redraw_mmxm_signature_rank(_rank) =>
    if f_mmxm_signature_is_active(8) and f_mmxm_signature_rank(8) == _rank
        f_redraw_mmxm_signature(8)
    if f_mmxm_signature_is_active(6) and f_mmxm_signature_rank(6) == _rank
        f_redraw_mmxm_signature(6)
    if f_mmxm_signature_is_active(7) and f_mmxm_signature_rank(7) == _rank
        f_redraw_mmxm_signature(7)
    if f_mmxm_signature_is_active(9) and f_mmxm_signature_rank(9) == _rank
        f_redraw_mmxm_signature(9)

f_reorder_mmxm_signatures_weak_on_top() =>
    f_redraw_mmxm_signature_rank(0)
    f_redraw_mmxm_signature_rank(1)
    f_redraw_mmxm_signature_rank(2)
    f_redraw_mmxm_signature_rank(3)

// ============================= session boxes always available
f_process_range(0, showPreAsianBox, "pre-asian", 19, 0, 21, 0)
f_process_range(1, showAsianBox, "asian", 21, 0, 0, 0)
f_process_range(2, showPreLondonBox, "pre-london", 2, 0, 3, 0)
f_process_range(3, showLondonBox, "london", 3, 0, 5, 0)
f_process_range(4, showNyMorningBox, "NY AM", 9, 30, 11, 30)
f_process_range(5, showNyLunchBox, "NY Lunch", 11, 30, 13, 30)
f_process_range(6, showNyAfternoonBox, "NY PM", 13, 30, 16, 59)

// ============================= active detail selection
bool asianSelected = activeDetailSession == "Asian"
bool londonSelected = activeDetailSession == "London"
bool nySelected = activeDetailSession == "New York"
int dSh = asianSelected ? 21 : londonSelected ? 3 : nyDetailWindow == "Morning" ? 9 : nyDetailWindow == "Lunch" ? 11 : 13
int dSm = asianSelected ? 0 : londonSelected ? 0 : nyDetailWindow == "Morning" ? 30 : nyDetailWindow == "Lunch" ? 30 : 30
int dEh = asianSelected ? 0 : londonSelected ? 5 : nyDetailWindow == "Morning" ? 11 : nyDetailWindow == "Lunch" ? 13 : 16
int dEm = asianSelected ? 0 : londonSelected ? 0 : nyDetailWindow == "Morning" ? 30 : nyDetailWindow == "Lunch" ? 30 : 59
string detailName = nySelected ? (nyDetailWindow == "Morning" ? "NY AM" : nyDetailWindow == "Lunch" ? "NY Lunch" : "NY PM") : str.lower(activeDetailSession)
bool detailIn = f_in_clock_window(time, dSh, dSm, dEh, dEm)
bool detailMidIn = f_in_clock_window(time[1], dSh, dSm, dEh, dEm)
int detailEnd = f_session_end_time(dSh, dSm, dEh, dEm)

// ============================= macro time selection
int m1Sh = asianSelected ? 18 : londonSelected ? 1 : nyDetailWindow == "Morning" ? 9 : nyDetailWindow == "Lunch" ? 12 : 13
int m1Sm = 50
int m1Eh = asianSelected ? 19 : londonSelected ? 2 : nyDetailWindow == "Morning" ? 10 : nyDetailWindow == "Lunch" ? 13 : 14
int m1Em = 10
int m2Sh = asianSelected ? 20 : londonSelected ? 2 : m1Sh
int m2Sm = 50
int m2Eh = asianSelected ? 21 : londonSelected ? 3 : m1Eh
int m2Em = 10
int m3Sh = asianSelected ? 0 : londonSelected ? 4 : m1Sh
int m3Sm = 50
int m3Eh = asianSelected ? 1 : londonSelected ? 5 : m1Eh
int m3Em = 10
bool useThreeMacros = asianSelected or londonSelected

var bool[] macroActive = array.new_bool(3, false)
var float[] macroHi = array.new_float(3, na)
var float[] macroLo = array.new_float(3, na)
var int[] macroStart = array.new_int(3, na)

// First presented imbalance per active macro window.
// These are separate from the selected-bias highest/lowest imbalance signatures.
var bool[] macroFirstImbFound = array.new_bool(3, false)
var bool[] macroFirstImbBullish = array.new_bool(3, false)
var float[] macroFirstImbTop = array.new_float(3, na)
var float[] macroFirstImbBot = array.new_float(3, na)
var int[] macroFirstImbStart = array.new_int(3, na)

// Selected-bias order block made during macro #1, e.g. 9:50-10:10 in NY AM.
// Bullish expected bias: draw the lowest consecutive bearish-candle group made inside the macro.
// If the lowest single bearish OB inside that group later displaces upward and then retests/holds its body high, refine the drawdown to that smaller OB.
// Bearish expected bias: draw the highest consecutive bullish-candle group made inside the macro.
// If the highest single bullish OB inside that group later displaces downward and then retests/holds its body low, refine the drawdown to that smaller OB.
var bool macroBullishBiasBearRunActive = false
var float macroBullishBiasBearRunTop = na
var float macroBullishBiasBearRunBot = na
var int macroBullishBiasBearRunStart = na
var bool macroBullishBiasObGroupFound = false
var float macroBullishBiasObGroupTop = na
var float macroBullishBiasObGroupBot = na
var int macroBullishBiasObGroupStart = na
var bool macroBullishBiasRefinedObFound = false
var bool macroBullishBiasRefinedObDisplaced = false
var bool macroBullishBiasRefinedObConfirmed = false
var int macroBullishBiasRefinedObDisplacedTime = na
var float macroBullishBiasRefinedObTop = na
var float macroBullishBiasRefinedObBot = na
var int macroBullishBiasRefinedObStart = na

var bool macroBearishBiasBullRunActive = false
var float macroBearishBiasBullRunTop = na
var float macroBearishBiasBullRunBot = na
var int macroBearishBiasBullRunStart = na
var bool macroBearishBiasObGroupFound = false
var float macroBearishBiasObGroupTop = na
var float macroBearishBiasObGroupBot = na
var int macroBearishBiasObGroupStart = na
var bool macroBearishBiasRefinedObFound = false
var bool macroBearishBiasRefinedObDisplaced = false
var bool macroBearishBiasRefinedObConfirmed = false
var int macroBearishBiasRefinedObDisplacedTime = na
var float macroBearishBiasRefinedObTop = na
var float macroBearishBiasRefinedObBot = na
var int macroBearishBiasRefinedObStart = na

f_process_macro(_midx, _conceptIdx, _enabled, _name, _sh, _sm, _eh, _em) =>
    _in = _enabled and f_in_clock_window(time, _sh, _sm, _eh, _em)
    _was = array.get(macroActive, _midx)
    if _in and not _was
        array.set(macroHi, _midx, high)
        array.set(macroLo, _midx, low)
        _start = f_session_start_time(_sh, _sm, _eh, _em)
        _right = f_session_end_time(_sh, _sm, _eh, _em)
        array.set(macroStart, _midx, _start)
        if showMacroSignature
            f_draw_concept(_conceptIdx, _start, _right, high, low, _name, macroBoxColor, macroLineColor, macroTextColor, true, true, macroTextOffsetBars)
    if _in
        _newHi = math.max(nz(array.get(macroHi, _midx), high), high)
        _newLo = math.min(nz(array.get(macroLo, _midx), low), low)
        _right = f_session_end_time(_sh, _sm, _eh, _em)
        array.set(macroHi, _midx, _newHi)
        array.set(macroLo, _midx, _newLo)
        if showMacroSignature
            f_update_concept(_conceptIdx, _right, _newHi, _newLo, _name, macroTextOffsetBars)
        else
            f_delete_concept(_conceptIdx)
    if (not _enabled or not showMacroSignature) and _was
        f_delete_concept(_conceptIdx)
    array.set(macroActive, _midx, _in)

f_process_macro_first_imb(_midx, _conceptIdx, _enabled, _name, _sh, _sm, _eh, _em) =>
    _midIn = _enabled and f_in_clock_window(time[1], _sh, _sm, _eh, _em)
    _found = array.get(macroFirstImbFound, _midx)
    _right = f_session_end_time(_sh, _sm, _eh, _em)
    if not _found and _midIn
        _bullFirst = close[1] > open[1] and high[2] < low
        _bearFirst = close[1] < open[1] and low[2] > high
        if _bullFirst or _bearFirst
            _top = _bullFirst ? low : low[2]
            _bot = _bullFirst ? high[2] : high
            _left = time[2]
            array.set(macroFirstImbFound, _midx, true)
            array.set(macroFirstImbBullish, _midx, _bullFirst)
            array.set(macroFirstImbTop, _midx, _top)
            array.set(macroFirstImbBot, _midx, _bot)
            array.set(macroFirstImbStart, _midx, _left)
            _boxCol = _bullFirst ? bullImbBoxColor : bearImbBoxColor
            _lineCol = _bullFirst ? bullImbLineColor : bearImbLineColor
            _txt = _name + (_bullFirst ? " first bullish imbalance" : " first bearish imbalance")
            if showMacroSignature
                f_draw_concept(_conceptIdx, _left, _right, _top, _bot, _txt, _boxCol, _lineCol, f_color(color.black, 0), true, true, imbTextOffsetBars)
    if array.get(macroFirstImbFound, _midx)
        _top = array.get(macroFirstImbTop, _midx)
        _bot = array.get(macroFirstImbBot, _midx)
        _bullStored = array.get(macroFirstImbBullish, _midx)
        _txt = _name + (_bullStored ? " first bullish imbalance" : " first bearish imbalance")
        if showMacroSignature
            f_update_concept(_conceptIdx, _right, _top, _bot, _txt, imbTextOffsetBars)
        else
            f_delete_concept(_conceptIdx)

f_process_macro(0, 3, true, f_macro_label(m1Sh, m1Sm), m1Sh, m1Sm, m1Eh, m1Em)
f_process_macro(1, 4, useThreeMacros, f_macro_label(m2Sh, m2Sm), m2Sh, m2Sm, m2Eh, m2Em)
f_process_macro(2, 5, useThreeMacros, f_macro_label(m3Sh, m3Sm), m3Sh, m3Sm, m3Eh, m3Em)

f_process_macro_first_imb(0, 10, true, f_macro_label(m1Sh, m1Sm), m1Sh, m1Sm, m1Eh, m1Em)
f_process_macro_first_imb(1, 11, useThreeMacros, f_macro_label(m2Sh, m2Sm), m2Sh, m2Sm, m2Eh, m2Em)
f_process_macro_first_imb(2, 12, useThreeMacros, f_macro_label(m3Sh, m3Sm), m3Sh, m3Sm, m3Eh, m3Em)

// ============================= selected session detail state
var bool detailWasIn = false
var bool fpiFound = false
var bool fpiBullishDirection = false
var float detailFpiTop = na
var float detailFpiBot = na
var bool bgobFound = false
var bool bgobActive = false
var bool bgobBullish = false
var int bgobFormTime = na
var float bgobHigh = na
var float bgobLow = na
var bool bullImbFound = false
var bool bearImbFound = false
var float bullImbTop = na
var float bullImbBot = na
var int bullImbStart = na
var float bearImbTop = na
var float bearImbBot = na
var int bearImbStart = na
var bool obFound = false
var float obTop = na
var float obBot = na
var int obStart = na

var float detailHi = na
var float detailLo = na
var int detailStartTime = na
var label reversalPossibleLabel = na
var bool reversalWarningTriggered = false
var string reversalWarningBias = ""
var string reversalWarningReason = ""
var int sessionMacroOverrideDir = 0
var int sessionBiasDir = 0
var string sessionBiasText = "Pending"
var string sessionBiasReason = "Waiting for Session FPI"

var bool preMacroBearCandidateFound = false
var float preMacroBearOpen = na
var float preMacroBearLow = na
var float preMacroBearHigh = na
var int preMacroBearTime = na
var bool preMacroBullCandidateFound = false
var float preMacroBullOpen = na
var float preMacroBullHigh = na
var float preMacroBullLow = na
var int preMacroBullTime = na
var bool preMacroRevTriggered = false
var float preMacroRevOpen = na
var float preMacroRevTop = na
var float preMacroRevBottom = na
var int preMacroRevTime = na
var string preMacroRevObLabelText = ""
var box preMacroRevBox = na
var line preMacroRevLine = na
var line preMacroRevHighLine = na
var line preMacroRevLowLine = na
var label preMacroRevMidLabel = na
var label preMacroRevPriceLabel = na
var label preMacroRevHighLabel = na
var label preMacroRevLowLabel = na
var label preMacroRevObLabel = na

f_reset_detail() =>
    for _i = 0 to 19
        f_delete_concept(_i)
    for _i = 0 to 2
        array.set(macroActive, _i, false)
        array.set(macroHi, _i, na)
        array.set(macroLo, _i, na)
        array.set(macroStart, _i, na)
        array.set(macroFirstImbFound, _i, false)
        array.set(macroFirstImbBullish, _i, false)
        array.set(macroFirstImbTop, _i, na)
        array.set(macroFirstImbBot, _i, na)
        array.set(macroFirstImbStart, _i, na)
if detailIn and not detailWasIn
    f_reset_detail()
    fpiFound := false
    fpiBullishDirection := false
    detailFpiTop := na
    detailFpiBot := na
    bgobFound := false
    bgobActive := false
    bgobBullish := false
    bgobFormTime := na
    bgobHigh := na
    bgobLow := na
    bullImbFound := false
    bearImbFound := false
    bullImbTop := na
    bullImbBot := na
    bullImbStart := na
    bearImbTop := na
    bearImbBot := na
    bearImbStart := na
    obFound := false
    obTop := na
    obBot := na
    obStart := na
    macroBullishBiasBearRunActive := false
    macroBullishBiasBearRunTop := na
    macroBullishBiasBearRunBot := na
    macroBullishBiasBearRunStart := na
    macroBullishBiasObGroupFound := false
    macroBullishBiasObGroupTop := na
    macroBullishBiasObGroupBot := na
    macroBullishBiasObGroupStart := na
    macroBullishBiasRefinedObFound := false
    macroBullishBiasRefinedObDisplaced := false
    macroBullishBiasRefinedObConfirmed := false
    macroBullishBiasRefinedObDisplacedTime := na
    macroBullishBiasRefinedObTop := na
    macroBullishBiasRefinedObBot := na
    macroBullishBiasRefinedObStart := na
    macroBearishBiasBullRunActive := false
    macroBearishBiasBullRunTop := na
    macroBearishBiasBullRunBot := na
    macroBearishBiasBullRunStart := na
    macroBearishBiasObGroupFound := false
    macroBearishBiasObGroupTop := na
    macroBearishBiasObGroupBot := na
    macroBearishBiasObGroupStart := na
    macroBearishBiasRefinedObFound := false
    macroBearishBiasRefinedObDisplaced := false
    macroBearishBiasRefinedObConfirmed := false
    macroBearishBiasRefinedObDisplacedTime := na
    macroBearishBiasRefinedObTop := na
    macroBearishBiasRefinedObBot := na
    macroBearishBiasRefinedObStart := na
    detailHi := high
    detailLo := low
    detailStartTime := f_session_start_time(dSh, dSm, dEh, dEm)
    reversalWarningTriggered := false
    reversalWarningBias := ""
    reversalWarningReason := ""
    sessionMacroOverrideDir := 0
    sessionBiasDir := biasEngineMode == "Manual" ? manualBiasDir : 0
    sessionBiasText := sessionBiasDir == 1 ? "Bullish" : sessionBiasDir == -1 ? "Bearish" : "Pending"
    sessionBiasReason := biasEngineMode == "Manual" ? "Manual bias" : "Waiting for Session FPI"
    activeBiasDir := sessionBiasDir != 0 ? sessionBiasDir : manualBiasDir
    preMacroBearCandidateFound := false
    preMacroBearOpen := na
    preMacroBearLow := na
    preMacroBearHigh := na
    preMacroBearTime := na
    preMacroBullCandidateFound := false
    preMacroBullOpen := na
    preMacroBullHigh := na
    preMacroBullLow := na
    preMacroBullTime := na
    preMacroRevTriggered := false
    preMacroRevOpen := na
    preMacroRevTop := na
    preMacroRevBottom := na
    preMacroRevTime := na
    preMacroRevObLabelText := ""
    if not na(preMacroRevBox)
        box.delete(preMacroRevBox)
        preMacroRevBox := na
    if not na(preMacroRevLine)
        line.delete(preMacroRevLine)
        preMacroRevLine := na
    if not na(preMacroRevHighLine)
        line.delete(preMacroRevHighLine)
        preMacroRevHighLine := na
    if not na(preMacroRevLowLine)
        line.delete(preMacroRevLowLine)
        preMacroRevLowLine := na
    if not na(preMacroRevMidLabel)
        label.delete(preMacroRevMidLabel)
        preMacroRevMidLabel := na
    if not na(preMacroRevPriceLabel)
        label.delete(preMacroRevPriceLabel)
        preMacroRevPriceLabel := na
    if not na(preMacroRevHighLabel)
        label.delete(preMacroRevHighLabel)
        preMacroRevHighLabel := na
    if not na(preMacroRevLowLabel)
        label.delete(preMacroRevLowLabel)
        preMacroRevLowLabel := na
    if not na(preMacroRevObLabel)
        label.delete(preMacroRevObLabel)
        preMacroRevObLabel := na
    if not na(reversalPossibleLabel)
        label.delete(reversalPossibleLabel)
        reversalPossibleLabel := na

if detailIn
    detailHi := na(detailHi) ? high : math.max(detailHi, high)
    detailLo := na(detailLo) ? low : math.min(detailLo, low)
    detailStartTime := na(detailStartTime) ? f_session_start_time(dSh, dSm, dEh, dEm) : detailStartTime

detailWasIn := detailIn

// ============================= fvg detection shared by fpi / imbalance / bgob
bool bullFvg = detailMidIn and close[1] > open[1] and high[2] < low
bool bearFvg = detailMidIn and close[1] < open[1] and low[2] > high
bool correctBiasFvg = false
float bullTop = low
float bullBot = high[2]
float bearTop = low[2]
float bearBot = high
int fvgLeft = time[2]

// ============================= selected-session fpi and projection
// FPI is allowed to form from either bullish or bearish FVG, regardless of selected expected bias.
int detailFpiWindowEnd = na(detailStartTime) ? na : detailStartTime + 30 * 60000
bool detailFpiWindow = detailIn and not na(detailFpiWindowEnd) and time >= detailStartTime and time < detailFpiWindowEnd
if detailFpiWindow and not fpiFound and (bullFvg or bearFvg)
    fpiFound := true
    _fpiBullish = bullFvg
    fpiBullishDirection := _fpiBullish
    _top = _fpiBullish ? bullTop : bearTop
    _bot = _fpiBullish ? bullBot : bearBot
    detailFpiTop := _top
    detailFpiBot := _bot
    _height = math.abs(_top - _bot)
    _fpiActualBoxColor = fpiBoxColor
    _fpiName = detailName + (_fpiBullish ? " bullish fpi" : " bearish fpi")
    if showSessionFpiSignature
        f_draw_concept(0, fvgLeft, detailEnd, _top, _bot, _fpiName, _fpiActualBoxColor, _fpiBullish ? fpiBullBorderColor : fpiBearBorderColor, fpiTextColor, true, true, fpiTextOffsetBars)
        f_draw_concept(1, fvgLeft, detailEnd, _top + _height * 4.0, _bot + _height * 4.0, detailName + " fpi 4x up", projectionBoxColor, projectionLineColor, projectionTextColor, true, true, projectionTextOffsetBars)
        f_draw_concept(2, fvgLeft, detailEnd, _top - _height * 4.0, _bot - _height * 4.0, detailName + " fpi 4x down", projectionBoxColor, projectionLineColor, projectionTextColor, true, true, projectionTextOffsetBars)

// ============================= PO3 MMXM bias engine
// Selected-session FPI calibrates the first bias, but the active bias must not stay locked
// bullish after price closes below both the session FPI and the respective macro FPI.
// Priority:
// 1) Manual mode = fixed manual bias.
// 2) If price is above/below the respective macro FPI, macro location controls bias dynamically.
// 3) Otherwise, if price is above/below the selected-session FPI, session FPI location controls bias.
// 4) If price is inside both calibration zones, keep the original selected-session FPI direction.
bool biasMacroFpiReady = array.get(macroFirstImbFound, 0) and not na(array.get(macroFirstImbTop, 0)) and not na(array.get(macroFirstImbBot, 0))
float biasMacroFpiTop = array.get(macroFirstImbTop, 0)
float biasMacroFpiBot = array.get(macroFirstImbBot, 0)
bool biasSessionFpiReady = fpiFound and not na(detailFpiTop) and not na(detailFpiBot)
int sessionFpiDir = fpiFound ? (fpiBullishDirection ? 1 : -1) : 0
int sessionFpiLiveDir = biasEngineMode == "Auto Session FPI" and biasSessionFpiReady ? (close > detailFpiTop ? 1 : close < detailFpiBot ? -1 : 0) : 0
int sessionMacroLiveDir = biasEngineMode == "Auto Session FPI" and biasMacroFpiReady ? (close > biasMacroFpiTop ? 1 : close < biasMacroFpiBot ? -1 : 0) : 0
sessionMacroOverrideDir := biasEngineMode == "Auto Session FPI" ? sessionMacroLiveDir : 0
sessionBiasDir := biasEngineMode == "Manual" ? manualBiasDir : sessionMacroLiveDir != 0 ? sessionMacroLiveDir : sessionFpiLiveDir != 0 ? sessionFpiLiveDir : sessionFpiDir
sessionBiasText := sessionBiasDir == 1 ? "Bullish" : sessionBiasDir == -1 ? "Bearish" : "Pending"
sessionBiasReason := biasEngineMode == "Manual" ? "Manual bias" : sessionMacroLiveDir == 1 ? "Price above macro FPI" : sessionMacroLiveDir == -1 ? "Price below macro FPI" : sessionFpiLiveDir == 1 ? "Price above session FPI" : sessionFpiLiveDir == -1 ? "Price below session FPI" : sessionFpiDir == 1 ? "Auto Session FPI: bullish FPI" : sessionFpiDir == -1 ? "Auto Session FPI: bearish FPI" : "Waiting for Session FPI"
activeBiasDir := sessionBiasDir != 0 ? sessionBiasDir : manualBiasDir
correctBiasFvg := f_expected_bullish() ? bullFvg : bearFvg

// ============================= 9:50 / respective macro selected-bias OB
// Macro #1 is 9:50-10:10 in NY AM.
// Bullish bias first draws the lowest consecutive bearish-candle macro group.
// It only refines down to the lowest single bearish OB after price displaces above and later retests/holds that OB's body high.
// Bearish bias mirrors this: draw the highest consecutive bullish-candle macro group,
// then refine to the highest single bullish OB only after price displaces below and later retests/holds that OB's body low.
bool macroOneMidIn = detailMidIn and f_in_clock_window(time[1], m1Sh, m1Sm, m1Eh, m1Em)
if macroOneMidIn
    _macroBodyTop = math.max(open[1], close[1])
    _macroBodyBot = math.min(open[1], close[1])
    _macroBearishCandle = close[1] < open[1]
    _macroBullishCandle = close[1] > open[1]

    if _macroBearishCandle
        if not macroBullishBiasBearRunActive
            macroBullishBiasBearRunActive := true
            macroBullishBiasBearRunTop := _macroBodyTop
            macroBullishBiasBearRunBot := _macroBodyBot
            macroBullishBiasBearRunStart := time[1]
        else
            macroBullishBiasBearRunTop := math.max(macroBullishBiasBearRunTop, _macroBodyTop)
            macroBullishBiasBearRunBot := math.min(macroBullishBiasBearRunBot, _macroBodyBot)

        _replaceBullishGroup = not macroBullishBiasObGroupFound or macroBullishBiasBearRunBot < macroBullishBiasObGroupBot
        if _replaceBullishGroup
            macroBullishBiasObGroupFound := true
            macroBullishBiasObGroupTop := macroBullishBiasBearRunTop
            macroBullishBiasObGroupBot := macroBullishBiasBearRunBot
            macroBullishBiasObGroupStart := macroBullishBiasBearRunStart

        _replaceBullishRefined = not macroBullishBiasRefinedObFound or _macroBodyBot < macroBullishBiasRefinedObBot
        if _replaceBullishRefined
            macroBullishBiasRefinedObFound := true
            macroBullishBiasRefinedObDisplaced := false
            macroBullishBiasRefinedObConfirmed := false
            macroBullishBiasRefinedObDisplacedTime := na
            macroBullishBiasRefinedObTop := _macroBodyTop
            macroBullishBiasRefinedObBot := _macroBodyBot
            macroBullishBiasRefinedObStart := time[1]
    else
        macroBullishBiasBearRunActive := false

    if _macroBullishCandle
        if not macroBearishBiasBullRunActive
            macroBearishBiasBullRunActive := true
            macroBearishBiasBullRunTop := _macroBodyTop
            macroBearishBiasBullRunBot := _macroBodyBot
            macroBearishBiasBullRunStart := time[1]
        else
            macroBearishBiasBullRunTop := math.max(macroBearishBiasBullRunTop, _macroBodyTop)
            macroBearishBiasBullRunBot := math.min(macroBearishBiasBullRunBot, _macroBodyBot)

        _replaceBearishGroup = not macroBearishBiasObGroupFound or macroBearishBiasBullRunTop > macroBearishBiasObGroupTop
        if _replaceBearishGroup
            macroBearishBiasObGroupFound := true
            macroBearishBiasObGroupTop := macroBearishBiasBullRunTop
            macroBearishBiasObGroupBot := macroBearishBiasBullRunBot
            macroBearishBiasObGroupStart := macroBearishBiasBullRunStart

        _replaceBearishRefined = not macroBearishBiasRefinedObFound or _macroBodyTop > macroBearishBiasRefinedObTop
        if _replaceBearishRefined
            macroBearishBiasRefinedObFound := true
            macroBearishBiasRefinedObDisplaced := false
            macroBearishBiasRefinedObConfirmed := false
            macroBearishBiasRefinedObDisplacedTime := na
            macroBearishBiasRefinedObTop := _macroBodyTop
            macroBearishBiasRefinedObBot := _macroBodyBot
            macroBearishBiasRefinedObStart := time[1]
    else
        macroBearishBiasBullRunActive := false

// Refined OB confirmation is intentionally stricter than a simple cross-through.
// Bullish example: price must first displace/close above the bearish OB body high,
// then later come back down and retest that body high while holding above it.
if detailIn and macroBullishBiasRefinedObFound and not macroBullishBiasRefinedObConfirmed and not na(macroBullishBiasRefinedObStart) and time > macroBullishBiasRefinedObStart
    if not macroBullishBiasRefinedObDisplaced and close > macroBullishBiasRefinedObTop
        macroBullishBiasRefinedObDisplaced := true
        macroBullishBiasRefinedObDisplacedTime := time
    if macroBullishBiasRefinedObDisplaced and not na(macroBullishBiasRefinedObDisplacedTime) and time > macroBullishBiasRefinedObDisplacedTime and low <= macroBullishBiasRefinedObTop and close >= macroBullishBiasRefinedObTop
        macroBullishBiasRefinedObConfirmed := true

// Bearish mirror: price must first displace/close below the bullish OB body low,
// then later come back up and retest that body low while holding below it.
if detailIn and macroBearishBiasRefinedObFound and not macroBearishBiasRefinedObConfirmed and not na(macroBearishBiasRefinedObStart) and time > macroBearishBiasRefinedObStart
    if not macroBearishBiasRefinedObDisplaced and close < macroBearishBiasRefinedObBot
        macroBearishBiasRefinedObDisplaced := true
        macroBearishBiasRefinedObDisplacedTime := time
    if macroBearishBiasRefinedObDisplaced and not na(macroBearishBiasRefinedObDisplacedTime) and time > macroBearishBiasRefinedObDisplacedTime and high >= macroBearishBiasRefinedObBot and close <= macroBearishBiasRefinedObBot
        macroBearishBiasRefinedObConfirmed := true

bool showMacroBullishRefinedOb = detailIn and showOrderBlockSignature and f_expected_bullish() and macroBullishBiasRefinedObFound and macroBullishBiasRefinedObConfirmed and not na(macroBullishBiasRefinedObTop) and not na(macroBullishBiasRefinedObBot) and not na(macroBullishBiasRefinedObStart)
bool showMacroBullishGroupOb = detailIn and showOrderBlockSignature and f_expected_bullish() and macroBullishBiasObGroupFound and not na(macroBullishBiasObGroupTop) and not na(macroBullishBiasObGroupBot) and not na(macroBullishBiasObGroupStart)
bool showMacroBearishRefinedOb = detailIn and showOrderBlockSignature and not f_expected_bullish() and macroBearishBiasRefinedObFound and macroBearishBiasRefinedObConfirmed and not na(macroBearishBiasRefinedObTop) and not na(macroBearishBiasRefinedObBot) and not na(macroBearishBiasRefinedObStart)
bool showMacroBearishGroupOb = detailIn and showOrderBlockSignature and not f_expected_bullish() and macroBearishBiasObGroupFound and not na(macroBearishBiasObGroupTop) and not na(macroBearishBiasObGroupBot) and not na(macroBearishBiasObGroupStart)

if showMacroBullishRefinedOb
    f_draw_concept(13, macroBullishBiasRefinedObStart, detailEnd, macroBullishBiasRefinedObTop, macroBullishBiasRefinedObBot, f_macro_label(m1Sh, m1Sm) + " refined lowest bearish OB", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
else if showMacroBullishGroupOb
    f_draw_concept(13, macroBullishBiasObGroupStart, detailEnd, macroBullishBiasObGroupTop, macroBullishBiasObGroupBot, f_macro_label(m1Sh, m1Sm) + " bearish OB group", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
else if showMacroBearishRefinedOb
    f_draw_concept(13, macroBearishBiasRefinedObStart, detailEnd, macroBearishBiasRefinedObTop, macroBearishBiasRefinedObBot, f_macro_label(m1Sh, m1Sm) + " refined highest bullish OB", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
else if showMacroBearishGroupOb
    f_draw_concept(13, macroBearishBiasObGroupStart, detailEnd, macroBearishBiasObGroupTop, macroBearishBiasObGroupBot, f_macro_label(m1Sh, m1Sm) + " bullish OB group", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
else if detailIn
    f_delete_concept(13)

// Bottom-center bias status label. A table is used so it stays pinned to the screen bottom instead of floating at a price level.
var table biasStatusTable = table.new(position.bottom_center, 1, 1, bgcolor=color.new(color.white, 100), frame_color=color.new(color.white, 100), border_width=0)
if barstate.islast
    table.cell(biasStatusTable, 0, 0, "Bias= " + sessionBiasText, text_color=themeTextColor, bgcolor=color.new(color.white, 100), text_size=size.small)

// ============================= pre-macro reversal orderblock warning
// Reversal OB candidate tracking is ACTIVE-SESSION based.
// Bearish session FPI + bearish expected bias:
//   can only use a bearish candle body, ranked by the lowest body-open line.
//   if a new lower bearish body appears later, the warning zone updates to that lower body.
// Bullish session FPI + bullish expected bias:
//   can only use a bullish candle body, ranked by the highest body-open line.
//   if a new higher bullish body appears later, the warning zone updates to that higher body.
if detailIn and detailMidIn
    if close[1] < open[1]
        // Bearish candle body only: open = body high, close = body low.
        _bodyHigh = open[1]
        _bodyLow = close[1]
        // Lowest bearish body means the lowest bearish body OPEN, because the reversal line is anchored at the open.
        if not preMacroBearCandidateFound or _bodyHigh < preMacroBearOpen
            preMacroBearCandidateFound := true
            preMacroBearOpen := _bodyHigh
            preMacroBearLow := _bodyLow
            preMacroBearHigh := _bodyHigh
            preMacroBearTime := time[1]
    if close[1] > open[1]
        // Bullish candle body only: close = body high, open = body low.
        _bodyHigh = close[1]
        _bodyLow = open[1]
        // Highest bullish body means the highest bullish body OPEN, because the reversal line is anchored at the open.
        if not preMacroBullCandidateFound or _bodyLow > preMacroBullOpen
            preMacroBullCandidateFound := true
            preMacroBullOpen := _bodyLow
            preMacroBullHigh := _bodyHigh
            preMacroBullLow := _bodyLow
            preMacroBullTime := time[1]

// Display is gated by session FPI direction and expected bias alignment.
// Important: this is not a one-shot candidate. If a more correct lower/higher body forms,
// the reversal OB redraws to the better body as long as the trigger condition is true.
bool bearishSessionFpiWithBearishExpected = detailIn and fpiFound and not fpiBullishDirection and not f_expected_bullish()
bool bullishSessionFpiWithBullishExpected = detailIn and fpiFound and fpiBullishDirection and f_expected_bullish()
bool bearFpiReversalTrigger = showPreMacroReversalOb and bearishSessionFpiWithBearishExpected and preMacroBearCandidateFound and not na(preMacroBearOpen) and close > preMacroBearOpen
bool bullFpiReversalTrigger = showPreMacroReversalOb and bullishSessionFpiWithBullishExpected and preMacroBullCandidateFound and not na(preMacroBullOpen) and close < preMacroBullOpen
bool preMacroRevTriggerNow = bearFpiReversalTrigger or bullFpiReversalTrigger

if preMacroRevTriggerNow
    preMacroRevTriggered := true
    preMacroRevOpen := bearFpiReversalTrigger ? preMacroBearOpen : preMacroBullOpen
    preMacroRevTop := bearFpiReversalTrigger ? preMacroBearHigh : preMacroBullHigh
    preMacroRevBottom := bearFpiReversalTrigger ? preMacroBearLow : preMacroBullLow
    preMacroRevTime := bearFpiReversalTrigger ? preMacroBearTime : preMacroBullTime
    preMacroRevObLabelText := bearFpiReversalTrigger ? "Lowest Bearish Body Reversal OB" : "Highest Bullish Body Reversal OB"
    _lineStart = preMacroRevTime
    _lineEnd = detailEnd
    _lineY = preMacroRevOpen
    _zoneMid = f_mid(preMacroRevTop, preMacroRevBottom)
    if na(preMacroRevBox)
        preMacroRevBox := box.new(_lineStart, preMacroRevTop, _lineEnd, preMacroRevBottom, xloc=xloc.bar_time, bgcolor=preMacroReversalBoxColor, border_color=f_color(preMacroReversalLineColor, 100), border_width=1)
    if na(preMacroRevLine)
        preMacroRevLine := line.new(_lineStart, _lineY, _lineEnd, _lineY, xloc=xloc.bar_time, color=preMacroReversalLineColor, width=2, style=line.style_dashed)
    if na(preMacroRevHighLine)
        preMacroRevHighLine := line.new(_lineStart, preMacroRevTop, _lineEnd, preMacroRevTop, xloc=xloc.bar_time, color=preMacroReversalLineColor, width=1)
    if na(preMacroRevLowLine)
        preMacroRevLowLine := line.new(_lineStart, preMacroRevBottom, _lineEnd, preMacroRevBottom, xloc=xloc.bar_time, color=preMacroReversalLineColor, width=1)
    if na(preMacroRevMidLabel)
        preMacroRevMidLabel := label.new(f_place_x(_lineStart, _lineEnd, "Middle", 0), _lineY, "pre-macro reversal warning", xloc=xloc.bar_time, style=label.style_none, color=f_color(color.white, 100), textcolor=preMacroReversalLineColor, size=size.normal, textalign=text.align_center)
    if na(preMacroRevPriceLabel)
        preMacroRevPriceLabel := label.new(_lineEnd, _lineY, str.tostring(_lineY, format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(color.white, 100), textcolor=preMacroReversalLineColor, size=size.normal)
    if na(preMacroRevHighLabel)
        preMacroRevHighLabel := label.new(_lineEnd, preMacroRevTop, str.tostring(preMacroRevTop, format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(color.white, 100), textcolor=preMacroReversalLineColor, size=size.normal)
    if na(preMacroRevLowLabel)
        preMacroRevLowLabel := label.new(_lineEnd, preMacroRevBottom, str.tostring(preMacroRevBottom, format.mintick), xloc=xloc.bar_time, style=label.style_none, color=f_color(color.white, 100), textcolor=preMacroReversalLineColor, size=size.normal)
    if na(preMacroRevObLabel)
        preMacroRevObLabel := label.new(f_place_x(_lineStart, _lineEnd, "Middle", 0), _zoneMid, preMacroRevObLabelText, xloc=xloc.bar_time, style=label.style_none, color=f_color(color.white, 100), textcolor=f_color(color.black, 0), size=size.normal, textalign=text.align_center)

if detailIn and preMacroRevTriggered and showPreMacroReversalOb and not na(preMacroRevLine)
    _lineStart = preMacroRevTime
    _lineEnd = detailEnd
    _lineY = preMacroRevOpen
    _zoneMid = f_mid(preMacroRevTop, preMacroRevBottom)
    if not na(preMacroRevBox)
        box.set_left(preMacroRevBox, _lineStart)
        box.set_right(preMacroRevBox, _lineEnd)
        box.set_top(preMacroRevBox, preMacroRevTop)
        box.set_bottom(preMacroRevBox, preMacroRevBottom)
        box.set_bgcolor(preMacroRevBox, preMacroReversalBoxColor)
        box.set_border_color(preMacroRevBox, f_color(preMacroReversalLineColor, 100))
    line.set_x1(preMacroRevLine, _lineStart)
    line.set_x2(preMacroRevLine, _lineEnd)
    line.set_y1(preMacroRevLine, _lineY)
    line.set_y2(preMacroRevLine, _lineY)
    line.set_color(preMacroRevLine, preMacroReversalLineColor)
    if not na(preMacroRevHighLine)
        line.set_x1(preMacroRevHighLine, _lineStart)
        line.set_x2(preMacroRevHighLine, _lineEnd)
        line.set_y1(preMacroRevHighLine, preMacroRevTop)
        line.set_y2(preMacroRevHighLine, preMacroRevTop)
        line.set_color(preMacroRevHighLine, preMacroReversalLineColor)
    if not na(preMacroRevLowLine)
        line.set_x1(preMacroRevLowLine, _lineStart)
        line.set_x2(preMacroRevLowLine, _lineEnd)
        line.set_y1(preMacroRevLowLine, preMacroRevBottom)
        line.set_y2(preMacroRevLowLine, preMacroRevBottom)
        line.set_color(preMacroRevLowLine, preMacroReversalLineColor)
    if not na(preMacroRevMidLabel)
        label.set_x(preMacroRevMidLabel, f_place_x(_lineStart, _lineEnd, "Middle", 0))
        label.set_y(preMacroRevMidLabel, _lineY)
        label.set_textcolor(preMacroRevMidLabel, preMacroReversalLineColor)
    if not na(preMacroRevPriceLabel)
        label.set_x(preMacroRevPriceLabel, _lineEnd)
        label.set_y(preMacroRevPriceLabel, _lineY)
        label.set_text(preMacroRevPriceLabel, str.tostring(_lineY, format.mintick))
        label.set_textcolor(preMacroRevPriceLabel, preMacroReversalLineColor)
    if not na(preMacroRevHighLabel)
        label.set_x(preMacroRevHighLabel, _lineEnd)
        label.set_y(preMacroRevHighLabel, preMacroRevTop)
        label.set_text(preMacroRevHighLabel, str.tostring(preMacroRevTop, format.mintick))
        label.set_textcolor(preMacroRevHighLabel, preMacroReversalLineColor)
    if not na(preMacroRevLowLabel)
        label.set_x(preMacroRevLowLabel, _lineEnd)
        label.set_y(preMacroRevLowLabel, preMacroRevBottom)
        label.set_text(preMacroRevLowLabel, str.tostring(preMacroRevBottom, format.mintick))
        label.set_textcolor(preMacroRevLowLabel, preMacroReversalLineColor)
    if not na(preMacroRevObLabel)
        label.set_x(preMacroRevObLabel, f_place_x(_lineStart, _lineEnd, "Middle", 0))
        label.set_y(preMacroRevObLabel, _zoneMid)
        label.set_text(preMacroRevObLabel, preMacroRevObLabelText)
        label.set_textcolor(preMacroRevObLabel, f_color(color.black, 0))

// ============================= selected-bias imbalances
if detailIn and bullFvg
    _replaceBull = not bullImbFound or (f_expected_bullish() ? bullBot < bullImbBot : bullTop > bullImbTop)
    if _replaceBull
        bullImbFound := true
        bullImbTop := bullTop
        bullImbBot := bullBot
        bullImbStart := fvgLeft
        if showBullishImbSignature
            f_draw_concept(6, bullImbStart, detailEnd, bullImbTop, bullImbBot, detailName + " bullish imbalance", bullImbBoxColor, selectedBiasBullImbLineColor, bullImbTextColor, true, true, imbTextOffsetBars)

if detailIn and bearFvg
    _replaceBear = not bearImbFound or (f_expected_bullish() ? bearBot < bearImbBot : bearTop > bearImbTop)
    if _replaceBear
        bearImbFound := true
        bearImbTop := bearTop
        bearImbBot := bearBot
        bearImbStart := fvgLeft
        if showBearishImbSignature
            f_draw_concept(7, bearImbStart, detailEnd, bearImbTop, bearImbBot, detailName + " bearish imbalance", bearImbBoxColor, selectedBiasBearImbLineColor, bearImbTextColor, true, true, imbTextOffsetBars)

// ============================= selected-bias order block
bool bullishOb = detailMidIn and close[1] > open[1]
bool bearishOb = detailMidIn and close[1] < open[1]
if detailIn
    if not f_expected_bullish() and bullishOb
        _bodyTop = math.max(open[1], close[1])
        _bodyBot = math.min(open[1], close[1])
        _replaceOb = not obFound or _bodyTop > obTop
        if _replaceOb
            obFound := true
            obTop := _bodyTop
            obBot := _bodyBot
            obStart := time[1]
            if showOrderBlockSignature
                f_draw_concept(8, obStart, detailEnd, obTop, obBot, detailName + " highest bullish order block", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)
    if f_expected_bullish() and bearishOb
        _bodyTop = math.max(open[1], close[1])
        _bodyBot = math.min(open[1], close[1])
        _replaceOb = not obFound or _bodyBot < obBot
        if _replaceOb
            obFound := true
            obTop := _bodyTop
            obBot := _bodyBot
            obStart := time[1]
            if showOrderBlockSignature
                f_draw_concept(8, obStart, detailEnd, obTop, obBot, detailName + " lowest bearish order block", f_ob_box_color(), obLineColor, obTextColor, true, true, obTextOffsetBars)

// ============================= selected-session breakaway gap order block
if detailIn and not bgobFound and correctBiasFvg
    bgobFound := true
    bgobActive := true
    bgobBullish := f_expected_bullish()
    bgobHigh := high
    bgobLow := low
    bgobFormTime := time
    _bgobName = f_expected_bullish() ? detailName + " bullish breakaway gap order block" : detailName + " bearish breakaway gap order block"
    if showBgobSignature
        f_draw_concept(9, time, detailEnd, bgobHigh, bgobLow, _bgobName, f_bgob_box_color(), bgobLineColor, bgobTextColor, true, true, bgobTextOffsetBars)

if bgobActive and time <= detailEnd
    _failed = bgobBullish ? low < bgobLow : high > bgobHigh
    if _failed
        f_delete_concept(9)
        bgobFound := false
        bgobActive := false
        bgobHigh := na
        bgobLow := na
        bgobFormTime := na

// Reversal conflict popup removed.
// The former yellow top label/text is intentionally disabled to keep the chart clean.
if not na(reversalPossibleLabel)
    label.delete(reversalPossibleLabel)
    reversalPossibleLabel := na

// keep active zones extended to selected detail end and honor text offsets while session develops
if detailIn
    if fpiFound
        _fpiBox = array.get(cBox, 0)
        if not na(_fpiBox)
            f_update_concept(0, detailEnd, box.get_top(_fpiBox), box.get_bottom(_fpiBox), detailName + (fpiBullishDirection ? " bullish fpi" : " bearish fpi"), fpiTextOffsetBars)
    if bullImbFound and showBullishImbSignature
        f_update_concept(6, detailEnd, bullImbTop, bullImbBot, detailName + " bullish imbalance", imbTextOffsetBars)
    if bearImbFound and showBearishImbSignature
        f_update_concept(7, detailEnd, bearImbTop, bearImbBot, detailName + " bearish imbalance", imbTextOffsetBars)
    if obFound and showOrderBlockSignature
        _obName = f_expected_bullish() ? detailName + " lowest bearish order block" : detailName + " highest bullish order block"
        f_update_concept(8, detailEnd, obTop, obBot, _obName, obTextOffsetBars)
    if bgobActive and showBgobSignature
        _bgobName = bgobBullish ? detailName + " bullish breakaway gap order block" : detailName + " bearish breakaway gap order block"
        f_update_concept(9, detailEnd, bgobHigh, bgobLow, _bgobName, bgobTextOffsetBars)
    f_reorder_mmxm_signatures_weak_on_top()
    f_apply_mmxm_signature_right_cascade(detailEnd)
````
