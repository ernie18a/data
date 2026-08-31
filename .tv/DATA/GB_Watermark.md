<!-- tradingview-pine-id: PUB;d66eae7ad1954d64852ba8a912a5ea58 -->
<!-- tradingviewscripts-format: 1 -->
# GB Watermark°

Source: https://www.tradingview.com/script/RQESuu05-GB-Textbox-Watermark/

## Description

Show text in two different boxes, optionally in different time frames.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//© Guido Buitendijk!
//@version=6

indicator("GB Watermark°", overlay=true) 

//#region[FUNCTIONS]
boxLoc(_loc) =>
    loc = switch _loc
        "Top-Left"      => position.top_left
        "Top-Center"    => position.top_center
        "Top-Right"     => position.top_right
        "Middle-Left"   => position.middle_left
        "Middle-Center" => position.middle_center
        "Middle-Right"  => position.middle_right
        "Bottom-Left"   => position.bottom_left
        "Bottom-Center" => position.bottom_center
        "Bottom-Right"  => position.bottom_right
    loc

_size(string _size, bool _l=false) =>
    size = switch _size
        "Tiny"   => not(_l) ? size.tiny   : size.small
        "Small"  => not(_l) ? size.small  : size.normal
        "Normal" => not(_l) ? size.normal : size.large
        "Large"  => not(_l) ? size.large  : size.huge
        "Huge"   => not(_l) ? size.huge   : size.huge
    size

// Returns true when the textbox may be shown on the current chart timeframe.
// " " (empty) = show on every timeframe. timeframe.period is "W", "D", "240" (4h) or "15" (15m).
showInTF(string _tf) =>
    switch _tf
        "W"   => timeframe.period == "W"
        "D"   => timeframe.period == "D"
        "4h"  => timeframe.period == "240"
        "15m" => timeframe.period == "15"
        => true

// Picks the text for the current chart symbol from a multi-symbol text area.
// Format: plain lines at the top = default text, shown on every symbol without its own section.
// A line like [EURUSD] starts a symbol section; the lines below it are shown only on that symbol.
symbolText(string _raw) =>
    string _sym     = str.upper(syminfo.ticker)
    string _section = "DEFAULT"
    string _def     = na
    string _match   = na
    for _line in str.split(_raw, "\n")
        string _trim = str.trim(_line)
        if str.startswith(_trim, "[") and str.endswith(_trim, "]")
            _section := str.upper(str.trim(str.substring(_trim, 1, str.length(_trim) - 1)))
        else if _section == "DEFAULT"
            _def := na(_def) ? _line : _def + "\n" + _line
        else if _section == _sym
            _match := na(_match) ? _line : _match + "\n" + _line
    string _result = na(_match) ? _def : _match
    na(_result) ? "" : _result
//#endregion


//#region[INPUTS]
// QUOTE
_showQuote    =      input.bool(true,               title="Show",           inline='s1',   group="Quote")
_showTF1      =    input.string("4h",               title="in timeframe",   inline='s1',   group="Quote", options=[" ","W","D","4h","15m"])
_color1       =     input.color(#000000,          title='',               inline='s1',   group="Quote")
_bgcolor1     =     input.color(#d1d4dc,          title='',               inline='s1',   group="Quote")
_showBrdr1    =      input.bool(false,              title="Hide Border?",   inline='s1',   group="Quote")
_y1           =    input.string("Bottom",           title="",               inline='s1.2', group="Quote", options=["Top","Middle","Bottom"])
_x1           =    input.string("Left",             title="",               inline='s1.2', group="Quote", options=["Left","Center","Right"])
_size1        =    input.string("Normal",           title="",               inline='s1.2', group="Quote", options=["Tiny","Small","Normal","Large","Huge"])
_showItext1   =      input.bool(true,               title="Text",           inline='s1.3', group="Quote")
_showIsym1    =      input.bool(true,               title="Symbol",         inline='s1.3', group="Quote")
_showItf1     =      input.bool(false,              title="Timeframe",      inline='s1.3', group="Quote")
_showIdate1   =      input.bool(false,              title="Date",           inline='s1.3', group="Quote")
_quoteTXT     = input.text_area("GB watermark",     title="Linda Text:",    group="Quote", tooltip="Per-symbol texts: lines at the top are the default text. Start a symbol section with [SYMBOL] (e.g. [EURUSD]); the lines below it are only shown on that symbol.")
_text_halign1 =    input.string("left",             title="Text alignment", inline='s1.3', group="Quote", options=["left","center","right"])


// SYMBOL INFO
_showInfo  =      input.bool(false,        title="Show",         inline='s2.1',      group="Symbol Info")
_showTF2      = input.string("15m",        title="in timeframe", inline='s2.1',      group="Symbol Info", options=[" ","W","D","4h","15m"])
_color2    =     input.color(#000000,    title='',             inline='s2.1',      group="Symbol Info")
_bgcolor2  =     input.color(#d1d4dc,    title='',             inline='s2.1',      group="Symbol Info")
_showBrdr2 =      input.bool(false,        title="Hide Border",  inline='s2.1',      group="Symbol Info")
_y2        =    input.string("Bottom",     title="",             inline='s2.2',      group="Symbol Info", options=["Top","Middle","Bottom"])
_x2        =    input.string("Left",       title="",             inline='s2.2',      group="Symbol Info", options=["Left","Center","Right"])
_size2     =    input.string("Normal",     title="",             inline='s2.2',      group="Symbol Info", options=["Tiny","Small","Normal","Large","Huge"])
_showItext =      input.bool(true,         title="Text",         inline='s2.3',      group="Symbol Info")
_showIsym  =      input.bool(true,         title="Symbol",       inline='s2.3',      group="Symbol Info")
_showItf   =      input.bool(false,        title="Timeframe",    inline='s2.3',      group="Symbol Info")
_showIdate =      input.bool(false,        title="Date",         inline='s2.3',      group="Symbol Info")
_infoTXT   = input.text_area('Extra info', title="Guido Text:",   group="Symbol Info", tooltip="Per-symbol texts: lines at the top are the default text. Start a symbol section with [SYMBOL] (e.g. [EURUSD]); the lines below it are only shown on that symbol.")
_text_halign2 = input.string("left",       title="Text alignment", inline='s2.4', group="Symbol Info", options=["left","center","right"])

//#endregion


//#region[LOGIC]
// TABLE LOCATION
quoteLOC = boxLoc(_y1+"-"+_x1)
infoLOC  = boxLoc(_y2+"-"+_x2)

// PER-SYMBOL TEXTS (inputs and symbol are constant, so parse only once)
var string quoteTXT = symbolText(_quoteTXT)
var string infoTXT  = symbolText(_infoTXT)

// SYMBOL INFO
date     = str.tostring(dayofmonth(time_close)) + "/" + str.tostring(month(time_close)) + "/" + str.tostring(year(time_close))

num_tf   = if timeframe.isminutes
    if str.tonumber(timeframe.period) % 60 == 0
        str.tostring(str.tonumber(timeframe.period)/60)
    else 
        timeframe.period
else
    timeframe.period

text_tf  = if timeframe.isminutes
    if str.tonumber(timeframe.period) % 60 == 0
        "H" +" TIMEFRAME"
    else 
        "m" +" TIMEFRAME"
else 
    na +" TIMEFRAME"

tf = num_tf + text_tf
//#endregion 

//#region[PLOT]
// QUOTE
if _showQuote and showInTF(_showTF1)
    _quote = table.new(quoteLOC,1,4,frame_color=_color1,frame_width=_showBrdr1?0:1)
    if _showIsym1
        table.cell(_quote, 0, 0, syminfo.ticker, text_color=_color1, text_halign=_text_halign1, text_size=_size(_size2, true), bgcolor=_bgcolor1)
    if _showItf1
        table.cell(_quote, 0, 1, tf,            text_color=_color1, text_halign=_text_halign1, text_size=_size(_size1),       bgcolor=_bgcolor1)
    if _showItext1
        table.cell(_quote, 0, 2, quoteTXT,      text_color=_color1, text_halign=_text_halign1, text_size=_size(_size1),       bgcolor=_bgcolor1)
    if _showIdate1
        table.cell(_quote, 0, 3, date,          text_color=_color1, text_halign=_text_halign1, text_size=_size(_size1),       bgcolor=_bgcolor1)

// SYMBOL INFO
if _showInfo and showInTF(_showTF2)
    _info = table.new(infoLOC,1,4,frame_color=_color2,frame_width=_showBrdr2?0:1)
    if _showIsym
        table.cell(_info, 0, 0, syminfo.ticker, text_color=_color2, text_halign=_text_halign2, text_size=_size(_size2, true), bgcolor=_bgcolor2)
    if _showItf
        table.cell(_info, 0, 1, tf,             text_color=_color2, text_halign=_text_halign2, text_size=_size(_size2),       bgcolor=_bgcolor2)
    if _showItext
        table.cell(_info, 0, 2, infoTXT,        text_color=_color2, text_halign=_text_halign2, text_size=_size(_size2),       bgcolor=_bgcolor2)
    if _showIdate
        table.cell(_info, 0, 3, date,           text_color=_color2, text_halign=_text_halign2, text_size=_size(_size2),       bgcolor=_bgcolor2)
//#endregion
````
