# Aaryan EPS/ Sales

- url: https://www.tradingview.com/script/k0D6FrPm-Aaryan-EPS-Sales/
- type: indicator
- pine_id: PUB;1ce08d6508ac49c6a70daff21c3af4ad
- version: 1.0

## Description

Aaryan EPS/ Sales

A comprehensive earnings and sales overlay that puts fundamental data directly on your price chart — quarterly results at a glance without leaving the chart window.

What it shows

The indicator displays two data tables and result-day labels on the chart:

Yearly Table shows EPS, year-over-year EPS growth, Sales (in Cr), year-over-year Sales growth, OPM%, PE, ROE, and EV/EBITDA for up to N years. Market cap is displayed in the header.

Quarterly Table shows EPS with QoQ growth and Sales with QoQ growth for up to N quarters. Stripped down to essentials — no price clutter.

Result Day Labels an arrow label is placed on the candle where quarterly results were declared. You choose what the label displays by ticking any combination of: EPS absolute value, EPS YoY growth %, and Sales YoY growth %. Multiple selections appear together separated by a pipe (e.g. "Mar-25: EPS:12.3 | E:+25% | S:+18%").

Customizable Settings

Everything is configurable from the settings panel:

- Toggle yearly table, quarterly table, and labels independently on or off
- Choose positive/negative growth colors (not locked to green/red)
- Set number of years and quarters to display
- Position each table anywhere on the chart (top/middle/bottom, left/center/right)
- Pick label size, color, and placement (above or below bar)
- Select which data points appear on result labels (multi-select checkboxes)
- Dark/light theme support

Data Source
All financial data is pulled from TradingView's built-in financial functions using FactSet earnings timestamps for accurate result-day detection. Sales figures are displayed in crores.

---

## Source Code

````pine
//@version=6
indicator(title = 'Aaryan EPS/ Sales', shorttitle = 'Aaryan EPS/ Sales', overlay = true, max_labels_count = 100)

string OutputGroup = '════════ Options ═════════'
string OutTableSize = input.string('small', 'Table Size', group = OutputGroup, options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'])
bool OutDarkTheme = input.bool(defval = true, title = 'Enable Dark Theme', group = OutputGroup)

// ── Growth Colors ────────────────────────────────────────────────────────────
string ColorGroup = '════════ Growth Colors ═════════'
color GrowthPositiveColor = input.color(defval = color.green, title = 'Positive Growth Color', group = ColorGroup)
color GrowthNegativeColor = input.color(defval = color.red, title = 'Negative Growth Color', group = ColorGroup)

// ── Table Visibility ─────────────────────────────────────────────────────────
string VisibilityGroup = '════════ Table Visibility ═════════'
bool ShowYearlyTable = input.bool(defval = true, title = 'Show Yearly Table', group = VisibilityGroup)
bool ShowQuarterlyTable = input.bool(defval = true, title = 'Show Quarterly Table', group = VisibilityGroup)

// ── Label Settings (multi-select via checkboxes) ─────────────────────────────
string LabelGroup = '════════ Label Settings ═════════'
bool ShowLabels = input.bool(defval = true, title = 'Show Labels on Chart', group = LabelGroup)
bool LabelShowEPSValue = input.bool(defval = true, title = 'Show EPS Value', group = LabelGroup)
bool LabelShowEPSGrowth = input.bool(defval = false, title = 'Show EPS Growth % (YoY)', group = LabelGroup)
bool LabelShowSalesGrowth = input.bool(defval = false, title = 'Show Sales Growth % (YoY)', group = LabelGroup)
string LabelSize = input.string('large', 'Label Size', group = LabelGroup, options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'])
color LabelColor = input.color(defval = color.blue, title = 'Label Color', group = LabelGroup)
string LabelPosition = input.string('Below Bar', 'Label Position', options = ['Above Bar', 'Below Bar'], group = LabelGroup)

string YearlyGroup = '════════ Yearly ═════════'
int TotalYears = input.int(defval = 4, title = 'Total Years:', inline = '31', tooltip = 'Total years for which to display data', group = YearlyGroup)
string YearlyTableY = input.string('middle', '↕', inline = '31', group = YearlyGroup, options = ['top', 'middle', 'bottom'])
string YearlyTableX = input.string('left', '↔', inline = '31', group = YearlyGroup, options = ['left', 'center', 'right'])

string QuarterlyGroup = '════════ Quarterly ═════════'
int TotalQuarters = input.int(defval = 6, title = 'Total Quarters:', inline = '41', tooltip = 'Total quarters for which to display data', group = QuarterlyGroup)
string QuarterlyTableY = input.string('bottom', '↕', inline = '41', group = QuarterlyGroup, options = ['top', 'middle', 'bottom'])
string QuarterlyTableX = input.string('right', '↔', inline = '41', group = QuarterlyGroup, options = ['left', 'center', 'right'])

// Global Variables
var string PeriodYear = 'FY'
var string PeriodQuarter = 'FQ'
var string FieldEPS = 'EARNINGS_PER_SHARE_DILUTED'
var string FieldSales = 'TOTAL_REVENUE'
var string FieldEVEBITDA = 'ENTERPRISE_VALUE_EBITDA'
var string FieldOPM = 'EBITDA_MARGIN'
var string FieldROE = 'RETURN_ON_EQUITY'
var int YearlyDataSize = TotalYears + 1
var int QuarterlyDataSize = TotalQuarters + 5
var ESDSymbolPrefix = 'ESD_FACTSET:' + syminfo.prefix + ';' + syminfo.ticker

var TableFrameColor = OutDarkTheme ? color.new(#999999, 50) : color.rgb(241, 241, 241)
var TableBorderColor = OutDarkTheme ? color.new(#999999, 50) : color.rgb(241, 241, 241)
var TableTextSize = OutTableSize

type FinancialData
	int Time
	float EPS
	float Sales
	float Price
	float EVEBITDA
	float OPM
    float ROE

method PushData(array<FinancialData> _array, int _time, float _eps, float _sales, float _price, float _evebitda = 0.0, float _opm = 0.0, float _roe = 0.0) =>
    array.unshift(id = _array, value = FinancialData.new(Time = _time, EPS = _eps, Sales = _sales, Price = _price, EVEBITDA = _evebitda, OPM = _opm, ROE = _roe))
    array.pop(id = _array)

TableCell(_table, _row, _column, _value, _txtcolor) =>
    table.cell(table_id = _table, column = _column, row = _row, text = _value, text_color = _txtcolor, text_size = TableTextSize)

SanitizeValue(_no, _default) =>
    na(_no) or _no == 0 or math.round(_no, 1) == 0 or math.round(_no, 1) == -0 ? _default : _no

CalculateRoundedPercentageDifference(_no1, _no2) =>
    _diff = _no1 - _no2
    _percent_diff = _diff / math.abs(_no2) * 100
    math.round(_percent_diff)

DefautColor() =>
    OutDarkTheme ? color.white : color.black

WriteAndComputeGrowth(_table_id, _row, _col, _cur_no, _prv_no, _show_growth) =>
    _no1 = SanitizeValue(_cur_no, 0.1)
    _no0 = SanitizeValue(_prv_no, 0.1)
    TableCell(_table = _table_id, _row = _row, _column = _col, _value = str.tostring(_no1, '#.#'), _txtcolor = DefautColor())
    if _show_growth
        _growth = CalculateRoundedPercentageDifference(_no1, _no0)
        _txt = na(_growth) ? '' : (_growth > 0 ? '+' + str.tostring(_growth) : str.tostring(_growth)) + '%'
        _color = na(_growth) ? color.yellow : _growth > 0 ? GrowthPositiveColor : GrowthNegativeColor
        TableCell(_table = _table_id, _row = _row, _column = _col + 1, _value = _txt, _txtcolor = _color)

IsValidDateTime(_time) =>
    na(_time) or _time == 0 or year(_time) <= 1970 ? false : true

WriteDate(_table_id, _row, _col, _time) =>
    _txt = not IsValidDateTime(_time) ? '' : str.format('{0, date, MMM-yy}', _time)
    TableCell(_table = _table_id, _row = _row, _column = _col, _value = _txt, _txtcolor = DefautColor())

WriteTableHeader(_table_id, _is_yearly) =>
    _fin_txt = _is_yearly ? 'YoY' : 'QoQ'
    _color = OutDarkTheme ? color.white : color.black
    TableCell(_table = _table_id, _row = 0, _column = 1, _value = 'EPS', _txtcolor = _color)
    TableCell(_table = _table_id, _row = 0, _column = 2, _value = _fin_txt, _txtcolor = _color)
    TableCell(_table = _table_id, _row = 0, _column = 3, _value = 'Sales', _txtcolor = _color)
    TableCell(_table = _table_id, _row = 0, _column = 4, _value = _fin_txt, _txtcolor = _color)
    if _is_yearly
        TableCell(_table = _table_id, _row = 0, _column = 5, _value = 'OPM%', _txtcolor = _color)
        TableCell(_table = _table_id, _row = 0, _column = 6, _value = 'PE', _txtcolor = _color)
        TableCell(_table = _table_id, _row = 0, _column = 7, _value = 'ROE', _txtcolor = _color)
        TableCell(_table = _table_id, _row = 0, _column = 9, _value = 'EVEBITDA', _txtcolor = _color)

WriteYearlyTable(_table_id, _data, _market_cap) =>
    WriteTableHeader(_table_id, _is_yearly = true)
    for i = 0 to TotalYears - 1 by 1
        _cur_data = array.get(id = _data, index = i)
        _prv_data = array.get(id = _data, index = i + 1)
        _valid_prv_data = IsValidDateTime(_prv_data.Time)
        TableCell(_table = _table_id, _row = 0, _column = 0, _value = 'MCAP ' + str.tostring(_market_cap, '#'), _txtcolor = DefautColor())
        WriteDate(_table_id = _table_id, _row = i + 1, _col = 0, _time = _cur_data.Time)
        WriteAndComputeGrowth(_table_id = _table_id, _row = i + 1, _col = 1, _cur_no = _cur_data.EPS, _prv_no = _prv_data.EPS, _show_growth = _valid_prv_data)
        WriteAndComputeGrowth(_table_id = _table_id, _row = i + 1, _col = 3, _cur_no = _cur_data.Sales, _prv_no = _prv_data.Sales, _show_growth = _valid_prv_data)
        TableCell(_table = _table_id, _row = i + 1, _column = 5, _value = str.tostring(_cur_data.OPM, '#.#'), _txtcolor = DefautColor())
        TableCell(_table = _table_id, _row = i + 1, _column = 6, _value = str.tostring(_cur_data.Price / _cur_data.EPS, '#.#'), _txtcolor = DefautColor())
        TableCell(_table = _table_id, _row = i + 1, _column = 7, _value = str.tostring(_cur_data.ROE, '#.#'), _txtcolor = DefautColor())
        TableCell(_table = _table_id, _row = i + 1, _column = 9, _value = str.tostring(_cur_data.EVEBITDA, '#.#'), _txtcolor = DefautColor())
        if _valid_prv_data == false
            break

// ── CHANGED: Quarterly table without Price columns ───────────────────────────
WriteQuarterlyTable(_table_id, _data) =>
    WriteTableHeader(_table_id, _is_yearly = false)
    for i = 0 to TotalQuarters - 1 by 1
        _cur_data = array.get(id = _data, index = i)
        if IsValidDateTime(_cur_data.Time) == false
            break
        _prv_data = array.get(id = _data, index = i + 4)
        _valid_prv_data = _prv_data.Time == 0 ? false : true
        WriteDate(_table_id = _table_id, _row = i + 1, _col = 0, _time = _cur_data.Time)
        WriteAndComputeGrowth(_table_id = _table_id, _row = i + 1, _col = 1, _cur_no = _cur_data.EPS, _prv_no = _prv_data.EPS, _show_growth = _valid_prv_data)
        WriteAndComputeGrowth(_table_id = _table_id, _row = i + 1, _col = 3, _cur_no = _cur_data.Sales, _prv_no = _prv_data.Sales, _show_growth = _valid_prv_data)

GetFinancial(_period, _field) =>
    _d = request.financial(symbol = syminfo.tickerid, financial_id = _field, period = _period, gaps = barmerge.gaps_on, ignore_invalid_symbol = true)
    na(_d) ? 0 : _d

var EmptyData = FinancialData.new(0, 0, 0, 0)
var yearly_data = array.new<FinancialData>(size = YearlyDataSize + 1, initial_value = EmptyData)
var quarterly_data = array.new<FinancialData>(size = QuarterlyDataSize + 1, initial_value = EmptyData)

yearly_eps = GetFinancial(PeriodYear, FieldEPS)
yearly_sales = math.round(GetFinancial(PeriodYear, FieldSales) / 10000000)
yearly_ev_ebitda = GetFinancial(PeriodYear, FieldEVEBITDA)
yearly_opm = GetFinancial(PeriodYear, FieldOPM)
yearly_roe = GetFinancial(PeriodYear, FieldROE)

quaterly_eps = GetFinancial(PeriodQuarter, FieldEPS)
quaterly_sales = math.round(GetFinancial(PeriodQuarter, FieldSales) / 10000000)

market_cap = request.financial(symbol = syminfo.tickerid, financial_id = 'TOTAL_SHARES_OUTSTANDING', period = 'FQ', gaps = barmerge.gaps_on, ignore_invalid_symbol = true) * close / 10000000

esd_published_timestamp = request.security(symbol = ESDSymbolPrefix + ';EARNINGS', timeframe = 'D', expression = time, gaps = barmerge.gaps_on)

var show_label = false
var current_quarter_sales = 0.0
var current_quarter_eps = 0.0
var quarterly_result_timestamp = 0

if quaterly_sales != 0 and current_quarter_sales != quaterly_sales
    current_quarter_sales := quaterly_sales
if quaterly_eps != 0 and current_quarter_eps != quaterly_eps
    show_label := true
    quarterly_result_timestamp := time
    current_quarter_eps := quaterly_eps

if na(esd_published_timestamp) == false and show_label == true
    show_label := false

    if ShowLabels
        _date_txt = not IsValidDateTime(quarterly_result_timestamp) ? '' : str.format('{0, date, MMM-yy}', quarterly_result_timestamp)

        // ── Build label from independently selected items ────────────────
        _parts = array.new_string(0)
        _prev_year_data = array.get(quarterly_data, 3)
        _has_prev = IsValidDateTime(_prev_year_data.Time)

        if LabelShowEPSValue
            array.push(_parts, 'EPS:' + str.tostring(current_quarter_eps, '#.#'))

        if LabelShowEPSGrowth and _has_prev
            _prev_eps = SanitizeValue(_prev_year_data.EPS, 0.1)
            _g = CalculateRoundedPercentageDifference(current_quarter_eps, _prev_eps)
            array.push(_parts, 'E:' + (_g > 0 ? '+' : '') + str.tostring(_g) + '%')

        if LabelShowSalesGrowth and _has_prev
            _prev_sales = SanitizeValue(_prev_year_data.Sales, 0.1)
            _g = CalculateRoundedPercentageDifference(current_quarter_sales, _prev_sales)
            array.push(_parts, 'S:' + (_g > 0 ? '+' : '') + str.tostring(_g) + '%')

        // Fallback if nothing selected
        if array.size(_parts) == 0
            array.push(_parts, str.tostring(current_quarter_eps, '#.#'))

        _label_txt = _date_txt + ': ' + array.join(_parts, ' | ')

        // ── Arrow position ───────────────────────────────────────────────
        _yloc = LabelPosition == "Above Bar" ? yloc.abovebar : yloc.belowbar
        _style = LabelPosition == "Above Bar" ? label.style_arrowdown : label.style_arrowup

        label.new(x = bar_index, y = close, yloc = _yloc, text = _label_txt, size = LabelSize, style = _style, textcolor = LabelColor, color = LabelColor)

    quarterly_data.PushData(_time = quarterly_result_timestamp, _eps = current_quarter_eps, _sales = current_quarter_sales, _price = close)

if bool(yearly_sales)
    yearly_data.PushData(_time = time, _eps = yearly_eps, _sales = yearly_sales, _price = close, _evebitda = yearly_ev_ebitda, _opm = yearly_opm, _roe = yearly_roe)

// ── Tables (only if toggled on) ──────────────────────────────────────────────
var table yearly_table = na
var table quarterly_table = na

if ShowYearlyTable
    yearly_table := table.new(YearlyTableY + '_' + YearlyTableX, columns = 10, rows = TotalYears + 1, frame_color = TableFrameColor, frame_width = 1, border_color = TableBorderColor, border_width = 1)
if ShowQuarterlyTable
    quarterly_table := table.new(QuarterlyTableY + '_' + QuarterlyTableX, columns = 5, rows = TotalQuarters + 1, frame_color = TableFrameColor, frame_width = 1, border_color = TableBorderColor, border_width = 1)

if barstate.islast
    if ShowYearlyTable and not na(yearly_table)
        WriteYearlyTable(_table_id = yearly_table, _data = yearly_data, _market_cap = market_cap)
    if ShowQuarterlyTable and not na(quarterly_table)
        WriteQuarterlyTable(_table_id = quarterly_table, _data = quarterly_data)
````
