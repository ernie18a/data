# BoaBias: MTF ALMA SuperTrend & Stats

- url: https://www.tradingview.com/script/oeKAfDjS-BoaBias-MTF-ALMA-SuperTrend-Stats/
- type: indicator
- pine_id: PUB;7408d7e899fd4cceb598331ca6abab3e
- version: 1.0

## Description

█ [b]WHAT IT DOES[/b]

Multi-timeframe [b]ALMA[/b] with [b]SuperTrend-style[/b] regime logic on [b]15m, 1H, 4H, 1D, 1W[/b] on one chart. Per-TF [b]ALMA lines[/b]; [b]separate[/b] bar colors for regime; optional [b]filled bands[/b] between adjacent TF ALMAs. Optional [b]statistics table[/b]: average and current run lengths, [b]State[/b] ([b]BULL[/b] / [b]BEAR[/b] / [b]NEUT[/b]), 1-bar and short-run (≤[i]N[/i] bars) counts, max runs, and [b]Avg OH[/b] stretch columns. [b]OH vs avg (per TF)[/b] controls how [b]Cur Short / Cur Long[/b] cells highlight vs their rolling averages. [b]MTF overheat labels[/b] on history (toggle in settings; [b]on[/b] in default preset): [b]·S[/b] (bear run stretch) [i]below[/i] the bar, [b]·L[/b] (bull run stretch) [i]above[/i] the bar; one timeframe per text line; minimum overheated TF count is [b]separate[/b] for bear vs bull; vertical stack spacing limits overlap on consecutive bars. [b]No[/b] [i]alert()[/i] in Pine — use TradingView’s alert UI if needed.


█ [b]HOW IT WORKS[/b]

[list]
[*][b]ALMA:[/b] Arnaud Legoux moving average via [i]ta.alma()[/i] (length, sigma, offset).
[*][b]SuperTrend-style bands:[/b] upper = ALMA + factor × stdev; lower = ALMA − factor × stdev; regime flips on band-cross style logic.
[*][b]MTF:[/b] [i]request.security[/i] with [b]barmerge.gaps_off[/b] and [b]barmerge.lookahead_off[/b] (no lookahead). Parameters are per timeframe.
[*][b]Statistics:[/b] Rolling window per TF for completed and current regime runs; chop metrics for very short runs; max run and Avg OH scans use [i]min(window, Max bars for Max/OH scan)[/i] internally.
[*][b]Labels:[/b] Toggle in inputs (on in defaults). Same heat thresholds as table [i]per TF[/i]; label fill colors follow [i]bar regime colors[/i] (bear / bull) with white text.
[/list]


█ [b]ORIGINALITY[/b]

MTF overlay of ALMA-based SD SuperTrend combined with a [b]per-TF run statistics[/b] layer, [b]per-TF overheat multipliers[/b], and [b]MTF overheat labels[/b] (separate bear/bull gating + stack spacing; toggleable). Pine v6, self-contained. Inspired by public ALMA / SuperTrend discussion; wiring, table, heat logic, and labels are specific to this script.


█ [b]HOW TO USE[/b]

[list]
[*][b]First use:[/b] Wrong scale? Right-click → Pin to scale → Pin to right scale.
[*]Enable/disable each timeframe; tune Factor, SD length, ALMA length, sigma, offset per TF.
[*][b]Statistics:[/b] Set window length and [i]Max bars for Max/OH scan[/i] (performance vs accuracy).
[*][b]OH vs avg (per TF):[/b] Adjust each TF’s multiplier — drives red highlight on Cur Short/Long vs average and optional label conditions.
[*][b]MTF overheat labels:[/b] On in the default preset (you can disable or change which TFs are included). Tune Min TFs [i]per side[/i] (·S vs ·L), stack step (× ATR), and max label count (platform cap 500). Optional: [b]only if chart ALMA flips[/b] — MTF overheat (min TFs + list) is read from the [b]previous[/b] bar; [i]·S[/i] prints on the current bar if that prior bar was MTF·S overheated and the chart closes BEAR→BULL; [i]·L[/i] if prior was MTF·L and chart BULL→BEAR. With the option off, overheat and label stay on the same bar.
[*][b]Chop rows:[/b] “Runs ≤ N bars” counts short regime lengths for context — not broker “fake” fills.
[*][b]Interpretation:[/b] Stretched runs vs average are [i]context[/i], not predictions.
[*][b]Performance:[/b] First attach or long history: full recalculation may take [b]several seconds[/b] — wait until processing finishes. To speed up: less chart history, turn off the table or MTF labels, or reduce statistics windows / Max bars for Max/OH scan.
[/list]


█ [b]PERFORMANCE / LOAD TIME[/b]

The script runs [b]multiple MTF security calls[/b] and statistics on each bar. On [b]first load[/b] or a [b]long[/b] visible history, TradingView may need [b]several seconds[/b] to finish — [b]wait[/b] before assuming the table or labels failed. If the chart feels heavy, reduce loaded history, disable the table or overheat labels, or lower window sizes and the Max/OH scan cap.


█ [b]LIMITATIONS[/b]

Trend logic lags; ranges whipsaw; MTF adds context, not certainty. Combine with other analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// BoaBias: MTF ALMA SD SuperTrend + statistics (table)
// TradingView publication copy (BBCode): indicators/TV_DESCRIPTION_ALMA_STATISTICS_FULL_EN.md
// @version=6
indicator(title="BoaBias: MTF ALMA SuperTrend & Stats",
     shorttitle="BoaBias: MTF ALMA ST & Stats",
     overlay=true, scale=scale.right, max_lines_count=500, max_labels_count=500)

// ============================================================================
// IMPORT LIBRARIES
// ============================================================================
import TradingView/ta/9 as ta

// ============================================================================
// HELPERS
// ============================================================================
fmt1(x) => na(x) ? "na" : str.format("{0,number,#.0}", x)     // one decimal place
fmt2(x) => na(x) ? "na" : str.format("{0,number,#.##}", x)    // two decimal places

// ============================================================================
// ALMA SD SUPERTREND SETTINGS (per timeframe)
// ============================================================================
groupALMA = "ALMA SD SuperTrend Settings"

// 15m
groupALMA_15m = "15m ALMA"
showALMA_15m = input.bool(true, "Show 15m ALMA", group=groupALMA_15m)
factor_15m = input.float(1.0, "Factor", step=0.05, group=groupALMA_15m)
sdlen_15m = input.int(2, "SD Length", group=groupALMA_15m)
almalen_15m = input.int(3, "Alma Length", group=groupALMA_15m)
almasig_15m = input.float(2.0, "Alma Sigma", group=groupALMA_15m)
almaoffset_15m = input.float(1.0, "Alma Offset", step=0.1, group=groupALMA_15m)

// 1H
groupALMA_1h = "1H ALMA"
showALMA_1h = input.bool(true, "Show 1H ALMA", group=groupALMA_1h)
factor_1h = input.float(1.0, "Factor", step=0.05, group=groupALMA_1h)
sdlen_1h = input.int(2, "SD Length", group=groupALMA_1h)
almalen_1h = input.int(3, "Alma Length", group=groupALMA_1h)
almasig_1h = input.float(2.0, "Alma Sigma", group=groupALMA_1h)
almaoffset_1h = input.float(1.0, "Alma Offset", step=0.1, group=groupALMA_1h)

// 4H
groupALMA_4h = "4H ALMA"
showALMA_4h = input.bool(true, "Show 4H ALMA", group=groupALMA_4h)
factor_4h = input.float(1.0, "Factor", step=0.05, group=groupALMA_4h)
sdlen_4h = input.int(2, "SD Length", group=groupALMA_4h)
almalen_4h = input.int(3, "Alma Length", group=groupALMA_4h)
almasig_4h = input.float(2.0, "Alma Sigma", group=groupALMA_4h)
almaoffset_4h = input.float(1.0, "Alma Offset", step=0.1, group=groupALMA_4h)

// 1D
groupALMA_1d = "1D ALMA"
showALMA_1d = input.bool(true, "Show 1D ALMA", group=groupALMA_1d)
factor_1d = input.float(1.0, "Factor", step=0.05, group=groupALMA_1d)
sdlen_1d = input.int(2, "SD Length", group=groupALMA_1d)
almalen_1d = input.int(3, "Alma Length", group=groupALMA_1d)
almasig_1d = input.float(2.0, "Alma Sigma", group=groupALMA_1d)
almaoffset_1d = input.float(1.0, "Alma Offset", step=0.1, group=groupALMA_1d)

// 1W
groupALMA_1w = "1W ALMA"
showALMA_1w = input.bool(true, "Show 1W ALMA", group=groupALMA_1w)
factor_1w = input.float(1.0, "Factor", step=0.05, group=groupALMA_1w)
sdlen_1w = input.int(2, "SD Length", group=groupALMA_1w)
almalen_1w = input.int(3, "Alma Length", group=groupALMA_1w)
almasig_1w = input.float(2.0, "Alma Sigma", group=groupALMA_1w)
almaoffset_1w = input.float(1.0, "Alma Offset", step=0.1, group=groupALMA_1w)

// Colors & display (band fill uses alignment tint)
// Match public script: fill = color.new(ALMA Up/Down, 82)
bandBullTint = input.color(color.new(color.rgb(31, 211, 37), 82), "Band tint (shorter ALMA above)", group=groupALMA)
bandBearTint = input.color(color.new(color.rgb(188, 8, 219), 82), "Band tint (shorter ALMA below)", group=groupALMA)
useFilledBands = input.bool(true, "Use filled bands (areas between ALMA)", group=groupALMA)
excludeLastBar = input.bool(false, "Don't color last bar", group=groupALMA)

groupTFlines = "TF colors — ALMA lines"
lineCol_15m = input.color(color.rgb(234, 179, 8), "15m ALMA line", group=groupTFlines)
lineCol_1h = input.color(color.rgb(249, 115, 22), "1H ALMA line", group=groupTFlines)
lineCol_4h = input.color(color.rgb(34, 197, 94), "4H ALMA line", group=groupTFlines)
lineCol_1d = input.color(color.rgb(59, 130, 246), "1D ALMA line", group=groupTFlines)
lineCol_1w = input.color(color.rgb(6, 182, 212), "1W ALMA line", group=groupTFlines)

// Bar coloring (separate from ALMA line colors)
useBarColoring = input.bool(true, "Color bars by ALMA signal", group=groupALMA)
barColoringTF = input.string("Current", "Bar coloring timeframe", 
     options=["Current", "15m", "1H", "4H", "1D", "1W"], 
     group=groupALMA)
barColBull = input.color(color.rgb(31, 211, 37), "Bar color (bullish regime)", group=groupALMA)
barColBear = input.color(color.rgb(188, 8, 219), "Bar color (bearish regime)", group=groupALMA)

src = input.source(close, "Source", group=groupALMA)

// ============================================================================
// STATISTICS SETTINGS (per timeframe)
// ============================================================================
groupStats = "Statistics Settings"
avgWindow_15m = input.int(200, "Window for average (15m)", minval=1, group=groupStats)
avgWindow_1h  = input.int(200, "Window for average (1H)",  minval=1, group=groupStats)
avgWindow_4h  = input.int(200, "Window for average (4H)",  minval=1, group=groupStats)
avgWindow_1d  = input.int(200, "Window for average (1D)",  minval=1, group=groupStats)
avgWindow_1w  = input.int(200, "Window for average (1W)",  minval=1, group=groupStats)

groupChop = "Whipsaw / short-run stats"
fakeBarsThreshold = input.int(3, "Count runs ≤ N bars as short (chop)", minval=1, maxval=100, group=groupChop,
     tooltip="Tracks how often bearish/bullish ALMA regimes last only 1 bar, or ≤N bars — a chop / whipsaw metric, not a broker order or fake fill.")
statsHistCap = input.int(200, "Max bars for Max/OH scan", minval=50, maxval=500, group=groupStats,
     tooltip="Inner loops for Max Short/Long and Avg OH use min(window, this cap). Lower = faster load; very high windows need a larger cap for accuracy.")

// ============================================================================
// OH VS AVG (per TF: Cur table cells + MTF OH labels)
// ============================================================================
groupOHvsAvg = "OH vs avg (per TF)"
ohVsAvg_15m = input.float(4.0, "15m — cur vs avg (×)", minval=1.0, step=0.1, group=groupOHvsAvg,
     tooltip="Red highlight on Cur Short/Long and MTF OH label threshold: current run length strictly greater than this multiple × average over this TF window.")
ohVsAvg_1h = input.float(3.0, "1H — cur vs avg (×)", minval=1.0, step=0.1, group=groupOHvsAvg,
     tooltip="Same as 15m: Cur Short/Long table and MTF OH labels for this TF.")
ohVsAvg_4h = input.float(2.0, "4H — cur vs avg (×)", minval=1.0, step=0.1, group=groupOHvsAvg,
     tooltip="Same as 15m: Cur Short/Long table and MTF OH labels for this TF.")
ohVsAvg_1d = input.float(1.5, "1D — cur vs avg (×)", minval=1.0, step=0.1, group=groupOHvsAvg,
     tooltip="Same as 15m: Cur Short/Long table and MTF OH labels for this TF.")
ohVsAvg_1w = input.float(1.5, "1W — cur vs avg (×)", minval=1.0, step=0.1, group=groupOHvsAvg,
     tooltip="Same as 15m: Cur Short/Long table and MTF OH labels for this TF.")

// ============================================================================
// TABLE SETTINGS
// ============================================================================
groupTable = "Table"
showTable = input.bool(true, "Show table", group=groupTable)
tablePosOpt = input.string("Bottom Right", "Position", 
     options=["Top Left","Top Right","Bottom Left","Bottom Right","Top Center","Bottom Center","Middle Right"], 
     group=groupTable)
tableBgColor = input.color(color.black, "Table background", group=groupTable)
tableHdrColor = input.color(color.new(color.gray, 0), "Header background", group=groupTable)
tableTextColor = input.color(color.white, "Text color", group=groupTable)
tableTextSizeOp = input.string("Small", "Text size", 
     options=["Tiny","Small","Normal","Large"], 
     group=groupTable)

// ============================================================================
// MTF OVERHEAT LABELS (current run > K × avg on that TF)
// ============================================================================
groupOHLabels = "MTF overheat labels"
showOverheatLabels = input.bool(true, "Show MTF overheat labels", group=groupOHLabels,
     tooltip="History labels: Min TFs counted separately for bear (·S, below bar) and bull (·L, above bar). Colors match bar regime colors; white text.")
overheatLabelMax = input.int(400, "Max labels (cap)", minval=50, maxval=500, group=groupOHLabels,
     tooltip="Pine allows max 500 labels per indicator. Excess oldest labels are removed — long history may show fewer marks on the left.")
ohLbl_15m = input.bool(false, "Include 15m", group=groupOHLabels)
ohLbl_1h = input.bool(false, "Include 1H", group=groupOHLabels)
ohLbl_4h = input.bool(true, "Include 4H", group=groupOHLabels)
ohLbl_1d = input.bool(true, "Include 1D", group=groupOHLabels)
ohLbl_1w = input.bool(true, "Include 1W", group=groupOHLabels)
overheatMinTfs = input.int(2, "Min TFs overheated (simultaneous)", minval=1, maxval=5, group=groupOHLabels,
     tooltip="Separate threshold for ·S (bear) and ·L (bull): MTF OH·S only if at least this many TFs are overheated in short-run; MTF OH·L for long-run. Bear and bull are not summed (avoids one-TF text when Min=2 with 1 bear + 1 bull).")
ohLblSizeStr = input.string("Small", "Label text size", options=["Tiny", "Small", "Normal", "Large"], group=groupOHLabels)
ohLblStackStep = input.float(0.36, "Label stack step (× ATR)", minval=0.1, maxval=1.5, step=0.02, group=groupOHLabels,
     tooltip="When ·S or ·L labels occur on consecutive bars, each next label offsets further from price (step × ATR) to reduce overlap.")
ohLblStackMax = input.int(12, "Max stack levels", minval=2, maxval=25, group=groupOHLabels,
     tooltip="Caps vertical stacking so labels do not drift too far on long streaks.")
ohRequireCurrentTfReversal = input.bool(false, "Only if chart ALMA flips (current TF)", group=groupOHLabels,
     tooltip="If on: MTF overheat (min TFs, line list) is evaluated on the previous bar. Label prints on the current bar if that prior bar was overheated and the chart-TF ALMA flips: ·S after prior MTF·S and BEAR→BULL here; ·L after prior MTF·L and BULL→BEAR. Off: overheat and label on the same bar (original).")

// ============================================================================
// ALMA SD SUPERTREND LOGIC FUNCTION
// ============================================================================
// SuperTrend-style band helper
f_st(_src, _alma, _factor, _sdlength) =>
    _sd = ta.stdev(_src, _sdlength)
    _upperband = _alma + _factor * _sd
    _lowerband = _alma - _factor * _sd
    _prevupperband = nz(_upperband[1])
    _prevlowerband = nz(_lowerband[1])

    _upperband := _upperband < _prevupperband or _src[1] > _prevupperband ? _upperband : _prevupperband
    _lowerband := _lowerband > _prevlowerband or _src[1] < _prevlowerband ? _lowerband : _prevlowerband
    int _direction = 1
    float _supertrend = na
    _prevsupertrend = _supertrend[1]
    if na(_sd[1])
        _direction := 1
    else if _prevsupertrend == _prevupperband
        _direction := _src > _upperband ? -1 : 1
    else
        _direction := _src < _lowerband ? 1 : -1
    _supertrend := _direction == -1 ? _lowerband : _upperband
    [_supertrend, _direction]

// ALMA + regime signal for one timeframe
f_alma_signal(_src, _factor, _sdlen, _almalen, _almasig, _almaoffset) =>
    _alma = ta.alma(_src, _almalen, _almaoffset, _almasig)
    [_st_result, _dir_result] = f_st(_src, _alma, _factor, _sdlen)
    _long = _dir_result < 0 
    _short = _dir_result > 0 
    
    int _signal = 0
    if _long and not _short
        _signal := 1
    if _short 
        _signal := -1
    
    [_signal, _alma]

// ============================================================================
// STATISTICS FUNCTION (adapted from EMA fakes)
// ============================================================================
// Avg/current run lengths on NATIVE TF (window _win, bars of that TF).
// + 1-bar runs and runs length <= _fakeThr (chop stats)
// Returns: [avgShort, avgLong, curShort, curLong, cntShort, cntLong, fake1Short, fake1Long, fakeThrShort, fakeThrLong]
f_sessions_native_full(_signal, _win, _fakeThr) =>
    // Regime: long (1) or short (-1)
    // Ignore 0/na — use last valid signal
    _sig = _signal == 1 or _signal == -1 ? _signal : nz(_signal[1], 0)
    // Still invalid — skip bar for counter updates
    _isValid = _sig == 1 or _sig == -1
    _isLong = _sig == 1
    _isShort = _sig == -1

    // Current incomplete run lengths (var persists across bars on native TF)
    var int _shortRun = 0    // length of current SHORT run
    var int _longRun = 0     // length of current LONG run
    
    // Always update counters (same idea as legacy EMA version)
    // Increment if same regime, else reset; invalid signal resets like a regime change
    _longRun := _isLong ? _longRun + 1 : 0
    _shortRun := _isShort ? _shortRun + 1 : 0

    // Crosses on long/short regime change
    // Previous bar valid signal
    _prevSig = _signal[1] == 1 or _signal[1] == -1 ? _signal[1] : nz(_signal[2], 0)
    _prevIsValid = _prevSig == 1 or _prevSig == -1
    _prevIsLong = _prevSig == 1
    _prevIsShort = _prevSig == -1
    
    // Cross to LONG: was SHORT, now LONG (both valid)
    _crossToLong = _isValid and _prevIsValid and _isLong and _prevIsShort
    // Cross to SHORT: was LONG, now SHORT (both valid)
    _crossToShort = _isValid and _prevIsValid and _isShort and _prevIsLong

    // Completed run lengths on regime-change bar (counter from prior bar before this bar's update)
    _shortLen = _crossToLong ? nz(_shortRun[1]) : 0  // SHORT run ended
    _longLen = _crossToShort ? nz(_longRun[1]) : 0   // LONG run ended
    _shortCnt = _shortLen > 0 ? 1 : 0
    _longCnt = _longLen > 0 ? 1 : 0

    // 1-bar runs
    _fake1ShortInc = _shortLen == 1 ? 1 : 0
    _fake1LongInc = _longLen == 1 ? 1 : 0

    // Runs length <= _fakeThr bars
    _fakeThrShortInc = _shortLen > 0 and _shortLen <= _fakeThr ? 1 : 0
    _fakeThrLongInc = _longLen > 0 and _longLen <= _fakeThr ? 1 : 0

    // Rolling sums over window _win (native TF)
    _cumShortLen      = ta.cum(_shortLen)
    _cumShortCnt      = ta.cum(_shortCnt)
    _cumLongLen       = ta.cum(_longLen)
    _cumLongCnt       = ta.cum(_longCnt)
    _cumFake1Short    = ta.cum(_fake1ShortInc)
    _cumFake1Long     = ta.cum(_fake1LongInc)
    _cumFakeThrShort  = ta.cum(_fakeThrShortInc)
    _cumFakeThrLong   = ta.cum(_fakeThrLongInc)

    _sumShort       = _cumShortLen      - nz(_cumShortLen[_win])
    _cntShort       = _cumShortCnt      - nz(_cumShortCnt[_win])
    _sumLong        = _cumLongLen       - nz(_cumLongLen[_win])
    _cntLong        = _cumLongCnt       - nz(_cumLongCnt[_win])
    _fake1Short     = _cumFake1Short    - nz(_cumFake1Short[_win])
    _fake1Long      = _cumFake1Long     - nz(_cumFake1Long[_win])
    _fakeThrShort   = _cumFakeThrShort  - nz(_cumFakeThrShort[_win])
    _fakeThrLong    = _cumFakeThrLong   - nz(_cumFakeThrLong[_win])

    _avgShort = _cntShort > 0 ? (_sumShort / _cntShort) : na
    _avgLong = _cntLong > 0 ? (_sumLong / _cntLong) : na

    // Current run lengths (0 if not in that regime)
    _curShort = _isShort ? _shortRun : 0
    _curLong = _isLong ? _longRun : 0

    // Max S/L and Avg OH: scan min(window, statsHistCap) only — cheaper than full 500-bar scan
    int _histLim = math.min(_win, statsHistCap)
    float _maxShort = 0.0
    float _maxLong = 0.0
    for i = 0 to _histLim - 1
        if _shortLen[i] > _maxShort
            _maxShort := _shortLen[i]
        if _longLen[i] > _maxLong
            _maxLong := _longLen[i]

    // Avg overheat ratio (run length / rolling avg at completion)
    float _sumOverheatShort = 0.0
    float _sumOverheatLong = 0.0
    int _cntOverheatShort = 0
    int _cntOverheatLong = 0
    for i = 0 to _histLim - 1
        _cntSi = _cumShortCnt[i] - nz(_cumShortCnt[i + _win])
        _cntLi = _cumLongCnt[i] - nz(_cumLongCnt[i + _win])
        _avS = _cntSi > 0 ? (_cumShortLen[i] - nz(_cumShortLen[i + _win])) / _cntSi : na
        _avL = _cntLi > 0 ? (_cumLongLen[i] - nz(_cumLongLen[i + _win])) / _cntLi : na
        if _shortLen[i] > 0 and not na(_avS) and _avS > 0
            _sumOverheatShort := _sumOverheatShort + _shortLen[i] / _avS
            _cntOverheatShort := _cntOverheatShort + 1
        if _longLen[i] > 0 and not na(_avL) and _avL > 0
            _sumOverheatLong := _sumOverheatLong + _longLen[i] / _avL
            _cntOverheatLong := _cntOverheatLong + 1

    _avgOverheatShort = _cntOverheatShort > 0 ? _sumOverheatShort / _cntOverheatShort : na
    _avgOverheatLong = _cntOverheatLong > 0 ? _sumOverheatLong / _cntOverheatLong : na

    [_avgShort, _avgLong, _curShort, _curLong, _cntShort, _cntLong, _fake1Short, _fake1Long, _fakeThrShort, _fakeThrLong, _maxShort, _maxLong, _avgOverheatShort, _avgOverheatLong]

// Ternary cannot return tuples in Pine (CE10163) — use if/else.
f_stats_security_row(simple string _tf, _signal, simple int _win) =>
    if showTable or showOverheatLabels
        request.security(syminfo.tickerid, _tf, f_sessions_native_full(_signal, _win, fakeBarsThreshold), barmerge.gaps_off, barmerge.lookahead_off)
    else
        [na, na, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, na, na]

// ============================================================================
// CALCULATE ALMA SIGNALS FOR EACH TIMEFRAME
// ============================================================================
// request.security for ALMA signal per HTF
[signal_15m, alma_15m] = request.security(syminfo.tickerid, "15", 
    f_alma_signal(src, factor_15m, sdlen_15m, almalen_15m, almasig_15m, almaoffset_15m), 
    barmerge.gaps_off, barmerge.lookahead_off)

[signal_1h, alma_1h] = request.security(syminfo.tickerid, "60", 
    f_alma_signal(src, factor_1h, sdlen_1h, almalen_1h, almasig_1h, almaoffset_1h), 
    barmerge.gaps_off, barmerge.lookahead_off)

[signal_4h, alma_4h] = request.security(syminfo.tickerid, "240", 
    f_alma_signal(src, factor_4h, sdlen_4h, almalen_4h, almasig_4h, almaoffset_4h), 
    barmerge.gaps_off, barmerge.lookahead_off)

[signal_1d, alma_1d] = request.security(syminfo.tickerid, "D", 
    f_alma_signal(src, factor_1d, sdlen_1d, almalen_1d, almasig_1d, almaoffset_1d), 
    barmerge.gaps_off, barmerge.lookahead_off)

[signal_1w, alma_1w] = request.security(syminfo.tickerid, "W", 
    f_alma_signal(src, factor_1w, sdlen_1w, almalen_1w, almasig_1w, almaoffset_1w), 
    barmerge.gaps_off, barmerge.lookahead_off)

// ============================================================================
// CALCULATE CURRENT TIMEFRAME ALMA SIGNAL (for bar coloring)
// ============================================================================
// Chart TF signal (Bar coloring = Current). Handles period aliases and custom minute bars.
currentTfStr = timeframe.period
currentTfIsDaily = timeframe.isdaily
currentTfIsWeekly = timeframe.isweekly

int currentSignal = 0
int _secChart = timeframe.in_seconds()

if currentTfStr == "15"
    [s, a] = f_alma_signal(src, factor_15m, sdlen_15m, almalen_15m, almasig_15m, almaoffset_15m)
    currentSignal := s
else if currentTfStr == "60"
    [s, a] = f_alma_signal(src, factor_1h, sdlen_1h, almalen_1h, almasig_1h, almaoffset_1h)
    currentSignal := s
else if currentTfStr == "240"
    [s, a] = f_alma_signal(src, factor_4h, sdlen_4h, almalen_4h, almasig_4h, almaoffset_4h)
    currentSignal := s
else if currentTfStr == "D" or currentTfStr == "1D" or currentTfIsDaily
    [s, a] = f_alma_signal(src, factor_1d, sdlen_1d, almalen_1d, almasig_1d, almaoffset_1d)
    currentSignal := s
else if currentTfStr == "W" or currentTfStr == "1W" or currentTfIsWeekly
    [s, a] = f_alma_signal(src, factor_1w, sdlen_1w, almalen_1w, almasig_1w, almaoffset_1w)
    currentSignal := s
else if timeframe.ismonthly
    [s, a] = f_alma_signal(src, factor_1w, sdlen_1w, almalen_1w, almasig_1w, almaoffset_1w)
    currentSignal := s
else
    // Non-standard period (5m, 30m, 2h, …): pick parameter set by bar duration
    if _secChart > 0 and _secChart < 3600
        [s, a] = f_alma_signal(src, factor_15m, sdlen_15m, almalen_15m, almasig_15m, almaoffset_15m)
        currentSignal := s
    else if _secChart >= 3600 and _secChart < 14400
        [s, a] = f_alma_signal(src, factor_1h, sdlen_1h, almalen_1h, almasig_1h, almaoffset_1h)
        currentSignal := s
    else if _secChart >= 14400 and _secChart < 86400
        [s, a] = f_alma_signal(src, factor_4h, sdlen_4h, almalen_4h, almasig_4h, almaoffset_4h)
        currentSignal := s
    else if _secChart >= 86400 and _secChart < 604800
        [s, a] = f_alma_signal(src, factor_1d, sdlen_1d, almalen_1d, almasig_1d, almaoffset_1d)
        currentSignal := s
    else if _secChart >= 604800
        [s, a] = f_alma_signal(src, factor_1w, sdlen_1w, almalen_1w, almasig_1w, almaoffset_1w)
        currentSignal := s

// Bar coloring signal source
int barColoringSignal = 0
if useBarColoring
    if barColoringTF == "Current"
        // Chart TF: use locally computed signal
        barColoringSignal := currentSignal
    else if barColoringTF == "15m"
        barColoringSignal := nz(signal_15m, 0)
    else if barColoringTF == "1H"
        barColoringSignal := nz(signal_1h, 0)
    else if barColoringTF == "4H"
        barColoringSignal := nz(signal_4h, 0)
    else if barColoringTF == "1D"
        // On daily chart use currentSignal (avoid redundant security)
        barColoringSignal := currentTfIsDaily ? currentSignal : nz(signal_1d, 0)
    else if barColoringTF == "1W"
        // On weekly chart use currentSignal
        barColoringSignal := currentTfIsWeekly ? currentSignal : nz(signal_1w, 0)

// Bar color series
color barColors = na
if useBarColoring and barColoringSignal != 0
    if barColoringSignal == 1
        barColors := barColBull
    else if barColoringSignal == -1
        barColors := barColBear

// ============================================================================
// CALCULATE STATISTICS FOR EACH TIMEFRAME (5× security if table or MTF OH labels)
// ============================================================================
[avgShort_15m, avgLong_15m, curShort_15m, curLong_15m, cntShort_15m, cntLong_15m, fake1Short_15m, fake1Long_15m, fakeThrShort_15m, fakeThrLong_15m, maxShort_15m, maxLong_15m, avgOverheatShort_15m, avgOverheatLong_15m] = f_stats_security_row("15", signal_15m, avgWindow_15m)

[avgShort_1h, avgLong_1h, curShort_1h, curLong_1h, cntShort_1h, cntLong_1h, fake1Short_1h, fake1Long_1h, fakeThrShort_1h, fakeThrLong_1h, maxShort_1h, maxLong_1h, avgOverheatShort_1h, avgOverheatLong_1h] = f_stats_security_row("60", signal_1h, avgWindow_1h)

[avgShort_4h, avgLong_4h, curShort_4h, curLong_4h, cntShort_4h, cntLong_4h, fake1Short_4h, fake1Long_4h, fakeThrShort_4h, fakeThrLong_4h, maxShort_4h, maxLong_4h, avgOverheatShort_4h, avgOverheatLong_4h] = f_stats_security_row("240", signal_4h, avgWindow_4h)

[avgShort_1d, avgLong_1d, curShort_1d, curLong_1d, cntShort_1d, cntLong_1d, fake1Short_1d, fake1Long_1d, fakeThrShort_1d, fakeThrLong_1d, maxShort_1d, maxLong_1d, avgOverheatShort_1d, avgOverheatLong_1d] = f_stats_security_row("D", signal_1d, avgWindow_1d)

[avgShort_1w, avgLong_1w, curShort_1w, curLong_1w, cntShort_1w, cntLong_1w, fake1Short_1w, fake1Long_1w, fakeThrShort_1w, fakeThrLong_1w, maxShort_1w, maxLong_1w, avgOverheatShort_1w, avgOverheatLong_1w] = f_stats_security_row("W", signal_1w, avgWindow_1w)

// ============================================================================
// TABLE HELPERS
// ============================================================================
f_pos(_s) =>
    _s == "Top Left" ? position.top_left :    _s == "Top Right" ? position.top_right :    _s == "Bottom Left" ? position.bottom_left :    _s == "Bottom Right" ? position.bottom_right :    _s == "Top Center" ? position.top_center :    _s == "Bottom Center" ? position.bottom_center :    position.middle_right

f_tsize(_s) =>
    _s == "Tiny" ? size.tiny :    _s == "Small" ? size.small :    _s == "Normal" ? size.normal :    size.large

// Fill one statistics table column for one TF
f_fillCol(_tbl, _col, _avgShort, _avgLong, _curShort, _curLong, _signal, _fake1Short, _fake1Long, _fakeThrShort, _fakeThrLong, _cntShort, _cntLong, _maxShort, _maxLong, _avgOverheatShort, _avgOverheatLong, _ohVsAvg) =>
    _avgShortTxt = fmt1(_avgShort)
    _avgLongTxt = fmt1(_avgLong)
    _curShortTxt = str.tostring(_curShort)
    _curLongTxt = str.tostring(_curLong)
    _state = _signal == 1 ? "BULL" : _signal == -1 ? "BEAR" : "NEUT"
    _stateClr = _signal == 1 ? color.lime : _signal == -1 ? color.red : color.gray

    // Cur Short heat vs avg (uses _ohVsAvg for red)
    _curShortClr = color.orange
    if not na(_avgShort) and _avgShort > 0
        if _curShort > _ohVsAvg * _avgShort
            _curShortClr := color.red
        else if _curShort > _avgShort
            _curShortClr := color.yellow

    // Cur Long heat vs avg
    _curLongClr = color.aqua
    if not na(_avgLong) and _avgLong > 0
        if _curLong > _ohVsAvg * _avgLong
            _curLongClr := color.red
        else if _curLong > _avgLong
            _curLongClr := color.yellow

    // Fake-run percentages
    _pctFake1Short = _cntShort > 0 ? 100.0 * _fake1Short / _cntShort : na
    _pctFake1Long = _cntLong > 0 ? 100.0 * _fake1Long / _cntLong : na
    _pctFakeThrShort = _cntShort > 0 ? 100.0 * _fakeThrShort / _cntShort : na
    _pctFakeThrLong = _cntLong > 0 ? 100.0 * _fakeThrLong / _cntLong : na

    _fake1ShortTxt = _cntShort > 0 ? str.tostring(_fake1Short) + " (" + fmt2(_pctFake1Short) + "%)" : str.tostring(_fake1Short)
    _fake1LongTxt = _cntLong > 0 ? str.tostring(_fake1Long) + " (" + fmt2(_pctFake1Long) + "%)" : str.tostring(_fake1Long)
    _fakeThrShortTxt = _cntShort > 0 ? str.tostring(_fakeThrShort) + " (" + fmt2(_pctFakeThrShort) + "%)" : str.tostring(_fakeThrShort)
    _fakeThrLongTxt = _cntLong > 0 ? str.tostring(_fakeThrLong) + " (" + fmt2(_pctFakeThrLong) + "%)" : str.tostring(_fakeThrLong)

    // Fake-run cell colors
    _fake1ShortClr = na(_pctFake1Short) ? tableTextColor : (_pctFake1Short < 30.0 ? color.lime : color.red)
    _fake1LongClr = na(_pctFake1Long) ? tableTextColor : (_pctFake1Long < 30.0 ? color.lime : color.red)
    _fakeThrShortClr = na(_pctFakeThrShort) ? tableTextColor : (_pctFakeThrShort < 50.0 ? color.lime : color.red)
    _fakeThrLongClr = na(_pctFakeThrLong) ? tableTextColor : (_pctFakeThrLong < 50.0 ? color.lime : color.red)

    // Table body cells
    table.cell(_tbl, _col, 1, _avgShortTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 2, _avgLongTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 3, _curShortTxt, text_color=_curShortClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 4, _curLongTxt, text_color=_curLongClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 5, _state, text_color=_stateClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 6, _fake1ShortTxt, text_color=_fake1ShortClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 7, _fake1LongTxt, text_color=_fake1LongClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 8, _fakeThrShortTxt, text_color=_fakeThrShortClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 9, _fakeThrLongTxt, text_color=_fakeThrLongClr, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    // Max series
    _maxShortTxt = _maxShort > 0 ? str.tostring(math.round(_maxShort)) : "—"
    _maxLongTxt = _maxLong > 0 ? str.tostring(math.round(_maxLong)) : "—"
    table.cell(_tbl, _col, 10, _maxShortTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 11, _maxLongTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    // Avg overheat (x)
    _avgOHShortTxt = na(_avgOverheatShort) ? "—" : fmt2(_avgOverheatShort) + "x"
    _avgOHLongTxt = na(_avgOverheatLong) ? "—" : fmt2(_avgOverheatLong) + "x"
    table.cell(_tbl, _col, 12, _avgOHShortTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)
    table.cell(_tbl, _col, 13, _avgOHLongTxt, text_color=tableTextColor, text_size=f_tsize(tableTextSizeOp), bgcolor=tableBgColor)

// ============================================================================
// TABLE DISPLAY
// ============================================================================
var table statsTbl = na

if barstate.isfirst and showTable
    statsTbl := table.new(f_pos(tablePosOpt), 6, 15, border_width=1, frame_color=color.new(color.white, 0))

var string __lastPos = tablePosOpt
if showTable and barstate.islast and (tablePosOpt != __lastPos or na(statsTbl))
    statsTbl := table.new(f_pos(tablePosOpt), 6, 15, border_width=1, frame_color=color.new(color.white, 0))
    __lastPos := tablePosOpt

if showTable and barstate.islast and not na(statsTbl)
    // Header row
    table.cell(statsTbl, 0, 0, "Metric", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 1, 0, "15m", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 2, 0, "1H", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 3, 0, "4H", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 4, 0, "1D", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 5, 0, "1W", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    
    // Metric names
    table.cell(statsTbl, 0, 1, "Avg Short", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 2, "Avg Long", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 3, "Cur Short", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 4, "Cur Long", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 5, "State", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 6, "1-bar bearish runs", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 7, "1-bar bullish runs", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 8, "Bearish runs ≤" + str.tostring(fakeBarsThreshold) + " bars", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 9, "Bullish runs ≤" + str.tostring(fakeBarsThreshold) + " bars", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 10, "Max Short", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 11, "Max Long", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 12, "Avg OH Short (x)", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    table.cell(statsTbl, 0, 13, "Avg OH Long (x)", text_color=color.white, text_size=f_tsize(tableTextSizeOp), bgcolor=tableHdrColor)
    
    // Fill columns for each timeframe
    f_fillCol(statsTbl, 1, avgShort_15m, avgLong_15m, curShort_15m, curLong_15m, signal_15m, fake1Short_15m, fake1Long_15m, fakeThrShort_15m, fakeThrLong_15m, cntShort_15m, cntLong_15m, maxShort_15m, maxLong_15m, avgOverheatShort_15m, avgOverheatLong_15m, ohVsAvg_15m)
    f_fillCol(statsTbl, 2, avgShort_1h, avgLong_1h, curShort_1h, curLong_1h, signal_1h, fake1Short_1h, fake1Long_1h, fakeThrShort_1h, fakeThrLong_1h, cntShort_1h, cntLong_1h, maxShort_1h, maxLong_1h, avgOverheatShort_1h, avgOverheatLong_1h, ohVsAvg_1h)
    f_fillCol(statsTbl, 3, avgShort_4h, avgLong_4h, curShort_4h, curLong_4h, signal_4h, fake1Short_4h, fake1Long_4h, fakeThrShort_4h, fakeThrLong_4h, cntShort_4h, cntLong_4h, maxShort_4h, maxLong_4h, avgOverheatShort_4h, avgOverheatLong_4h, ohVsAvg_4h)
    f_fillCol(statsTbl, 4, avgShort_1d, avgLong_1d, curShort_1d, curLong_1d, signal_1d, fake1Short_1d, fake1Long_1d, fakeThrShort_1d, fakeThrLong_1d, cntShort_1d, cntLong_1d, maxShort_1d, maxLong_1d, avgOverheatShort_1d, avgOverheatLong_1d, ohVsAvg_1d)
    f_fillCol(statsTbl, 5, avgShort_1w, avgLong_1w, curShort_1w, curLong_1w, signal_1w, fake1Short_1w, fake1Long_1w, fakeThrShort_1w, fakeThrLong_1w, cntShort_1w, cntLong_1w, maxShort_1w, maxLong_1w, avgOverheatShort_1w, avgOverheatLong_1w, ohVsAvg_1w)

// ============================================================================
// PLOTTING
// ============================================================================
// Plot ALMA lines for each timeframe
p_15m = plot(showALMA_15m ? alma_15m : na, "15m ALMA", color=lineCol_15m, linewidth=useFilledBands ? 1 : 2)
p_1h  = plot(showALMA_1h ? alma_1h : na, "1H ALMA", color=lineCol_1h, linewidth=useFilledBands ? 1 : 2)
p_4h  = plot(showALMA_4h ? alma_4h : na, "4H ALMA", color=lineCol_4h, linewidth=useFilledBands ? 1 : 2)
p_1d  = plot(showALMA_1d ? alma_1d : na, "1D ALMA", color=lineCol_1d, linewidth=useFilledBands ? 1 : 2)
p_1w  = plot(showALMA_1w ? alma_1w : na, "1W ALMA", color=lineCol_1w, linewidth=useFilledBands ? 1 : 2)

// Filled areas: alignment tint (configurable; independent from bar colors)
fillCol15m1h  = nz(alma_15m) >= nz(alma_1h) ? bandBullTint : bandBearTint
fillCol1h4h   = nz(alma_1h) >= nz(alma_4h) ? bandBullTint : bandBearTint
fillCol4h1d   = nz(alma_4h) >= nz(alma_1d) ? bandBullTint : bandBearTint
fillCol1d1w   = nz(alma_1d) >= nz(alma_1w) ? bandBullTint : bandBearTint

fill(p_15m, p_1h, color=useFilledBands ? fillCol15m1h : color.new(color.gray, 100))
fill(p_1h, p_4h, color=useFilledBands ? fillCol1h4h : color.new(color.gray, 100))
fill(p_4h, p_1d, color=useFilledBands ? fillCol4h1d : color.new(color.gray, 100))
fill(p_1d, p_1w, color=useFilledBands ? fillCol1d1w : color.new(color.gray, 100))

// ============================================================================
// MTF OVERHEAT LABELS (history; cap overheatLabelMax)
// ============================================================================
// Min TF counts per side — do not sum bear+bull (else Min=2 with 1 bear + 1 bull could show ·S with one TF in text).
f_oh_tf_is_hot_bear(_sig, _curS, _avgS, _useTf, _mult) =>
    _useTf and nz(_sig, 0) == -1 and not na(_avgS) and _avgS > 0 and _curS > _mult * _avgS

f_oh_tf_is_hot_bull(_sig, _curL, _avgL, _useTf, _mult) =>
    _useTf and nz(_sig, 0) == 1 and not na(_avgL) and _avgL > 0 and _curL > _mult * _avgL

// Build "TF·S" / "TF·L" fragments; _wantS/_wantL split label sides.
f_oh_tf(_acc, _sep, _tfName, _sig, _curS, _avgS, _curL, _avgL, _useTf, _mult, _wantS, _wantL) =>
    if not _useTf
        _acc
    else
        _sn = nz(_sig, 0)
        string _frag = ""
        if _wantS and _sn == -1 and not na(_avgS) and _avgS > 0 and _curS > _mult * _avgS
            _frag := _tfName + "·S"
        else if _wantL and _sn == 1 and not na(_avgL) and _avgL > 0 and _curL > _mult * _avgL
            _frag := _tfName + "·L"
        str.length(_frag) > 0 ? _acc + (str.length(_acc) > 0 ? _sep : "") + _frag : _acc

var label[] mtfOhLbls = array.new<label>(0)
var int lastOhBarS = na
var int lastOhBarL = na
var int ohStreakS = 0
var int ohStreakL = 0

if barstate.isfirst
    while array.size(mtfOhLbls) > 0
        label.delete(array.get(mtfOhLbls, 0))
        array.remove(mtfOhLbls, 0)
    lastOhBarS := na
    lastOhBarL := na
    ohStreakS := 0
    ohStreakL := 0

// Current chart TF: ALMA regime flip (same `currentSignal` as bar color)
ohFlipBull = currentSignal == 1 and nz(currentSignal[1], 0) == -1
ohFlipBear = currentSignal == -1 and nz(currentSignal[1], 0) == 1

if showOverheatLabels
    // Flip mode: MTF overheat = previous bar; label on this bar if flip now. Otherwise: overheat on same bar.
    int _ohHotCntS = 0
    int _ohHotCntL = 0
    string _ohAccS = ""
    string _ohAccL = ""
    if ohRequireCurrentTfReversal
        _ohHotCntS := (f_oh_tf_is_hot_bear(signal_15m[1], curShort_15m[1], avgShort_15m[1], ohLbl_15m, ohVsAvg_15m) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1h[1], curShort_1h[1], avgShort_1h[1], ohLbl_1h, ohVsAvg_1h) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_4h[1], curShort_4h[1], avgShort_4h[1], ohLbl_4h, ohVsAvg_4h) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1d[1], curShort_1d[1], avgShort_1d[1], ohLbl_1d, ohVsAvg_1d) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1w[1], curShort_1w[1], avgShort_1w[1], ohLbl_1w, ohVsAvg_1w) ? 1 : 0)
        _ohHotCntL := (f_oh_tf_is_hot_bull(signal_15m[1], curLong_15m[1], avgLong_15m[1], ohLbl_15m, ohVsAvg_15m) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1h[1], curLong_1h[1], avgLong_1h[1], ohLbl_1h, ohVsAvg_1h) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_4h[1], curLong_4h[1], avgLong_4h[1], ohLbl_4h, ohVsAvg_4h) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1d[1], curLong_1d[1], avgLong_1d[1], ohLbl_1d, ohVsAvg_1d) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1w[1], curLong_1w[1], avgLong_1w[1], ohLbl_1w, ohVsAvg_1w) ? 1 : 0)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "15m", signal_15m[1], curShort_15m[1], avgShort_15m[1], curLong_15m[1], avgLong_15m[1], ohLbl_15m, ohVsAvg_15m, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1H", signal_1h[1], curShort_1h[1], avgShort_1h[1], curLong_1h[1], avgLong_1h[1], ohLbl_1h, ohVsAvg_1h, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "4H", signal_4h[1], curShort_4h[1], avgShort_4h[1], curLong_4h[1], avgLong_4h[1], ohLbl_4h, ohVsAvg_4h, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1D", signal_1d[1], curShort_1d[1], avgShort_1d[1], curLong_1d[1], avgLong_1d[1], ohLbl_1d, ohVsAvg_1d, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1W", signal_1w[1], curShort_1w[1], avgShort_1w[1], curLong_1w[1], avgLong_1w[1], ohLbl_1w, ohVsAvg_1w, true, false)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "15m", signal_15m[1], curShort_15m[1], avgShort_15m[1], curLong_15m[1], avgLong_15m[1], ohLbl_15m, ohVsAvg_15m, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1H", signal_1h[1], curShort_1h[1], avgShort_1h[1], curLong_1h[1], avgLong_1h[1], ohLbl_1h, ohVsAvg_1h, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "4H", signal_4h[1], curShort_4h[1], avgShort_4h[1], curLong_4h[1], avgLong_4h[1], ohLbl_4h, ohVsAvg_4h, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1D", signal_1d[1], curShort_1d[1], avgShort_1d[1], curLong_1d[1], avgLong_1d[1], ohLbl_1d, ohVsAvg_1d, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1W", signal_1w[1], curShort_1w[1], avgShort_1w[1], curLong_1w[1], avgLong_1w[1], ohLbl_1w, ohVsAvg_1w, false, true)
    else
        _ohHotCntS := (f_oh_tf_is_hot_bear(signal_15m, curShort_15m, avgShort_15m, ohLbl_15m, ohVsAvg_15m) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1h, curShort_1h, avgShort_1h, ohLbl_1h, ohVsAvg_1h) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_4h, curShort_4h, avgShort_4h, ohLbl_4h, ohVsAvg_4h) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1d, curShort_1d, avgShort_1d, ohLbl_1d, ohVsAvg_1d) ? 1 : 0) + (f_oh_tf_is_hot_bear(signal_1w, curShort_1w, avgShort_1w, ohLbl_1w, ohVsAvg_1w) ? 1 : 0)
        _ohHotCntL := (f_oh_tf_is_hot_bull(signal_15m, curLong_15m, avgLong_15m, ohLbl_15m, ohVsAvg_15m) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1h, curLong_1h, avgLong_1h, ohLbl_1h, ohVsAvg_1h) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_4h, curLong_4h, avgLong_4h, ohLbl_4h, ohVsAvg_4h) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1d, curLong_1d, avgLong_1d, ohLbl_1d, ohVsAvg_1d) ? 1 : 0) + (f_oh_tf_is_hot_bull(signal_1w, curLong_1w, avgLong_1w, ohLbl_1w, ohVsAvg_1w) ? 1 : 0)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "15m", signal_15m, curShort_15m, avgShort_15m, curLong_15m, avgLong_15m, ohLbl_15m, ohVsAvg_15m, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1H", signal_1h, curShort_1h, avgShort_1h, curLong_1h, avgLong_1h, ohLbl_1h, ohVsAvg_1h, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "4H", signal_4h, curShort_4h, avgShort_4h, curLong_4h, avgLong_4h, ohLbl_4h, ohVsAvg_4h, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1D", signal_1d, curShort_1d, avgShort_1d, curLong_1d, avgLong_1d, ohLbl_1d, ohVsAvg_1d, true, false)
        _ohAccS := f_oh_tf(_ohAccS, "\n", "1W", signal_1w, curShort_1w, avgShort_1w, curLong_1w, avgLong_1w, ohLbl_1w, ohVsAvg_1w, true, false)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "15m", signal_15m, curShort_15m, avgShort_15m, curLong_15m, avgLong_15m, ohLbl_15m, ohVsAvg_15m, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1H", signal_1h, curShort_1h, avgShort_1h, curLong_1h, avgLong_1h, ohLbl_1h, ohVsAvg_1h, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "4H", signal_4h, curShort_4h, avgShort_4h, curLong_4h, avgLong_4h, ohLbl_4h, ohVsAvg_4h, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1D", signal_1d, curShort_1d, avgShort_1d, curLong_1d, avgLong_1d, ohLbl_1d, ohVsAvg_1d, false, true)
        _ohAccL := f_oh_tf(_ohAccL, "\n", "1W", signal_1w, curShort_1w, avgShort_1w, curLong_1w, avgLong_1w, ohLbl_1w, ohVsAvg_1w, false, true)
    _ohFullS = str.length(_ohAccS) > 0 ? "MTF OH·S:\n" + _ohAccS : ""
    _ohFullL = str.length(_ohAccL) > 0 ? "MTF OH·L:\n" + _ohAccL : ""
    bool _okFlipS = not ohRequireCurrentTfReversal or ohFlipBull
    bool _okFlipL = not ohRequireCurrentTfReversal or ohFlipBear
    float _ohAtr = ta.atr(14)
    float _ohStepUnit = not na(_ohAtr) and _ohAtr > 0 ? _ohAtr : math.max(high - low, syminfo.mintick * 30.0)
    if _ohHotCntS >= overheatMinTfs and str.length(_ohFullS) > 0 and _okFlipS
        int _gapS = na(lastOhBarS) ? 999 : bar_index - lastOhBarS
        ohStreakS := _gapS == 1 ? ohStreakS + 1 : 1
        ohStreakS := math.min(ohStreakS, ohLblStackMax)
        float _offS = _ohStepUnit * (0.38 + (ohStreakS - 1) * ohLblStackStep)
        _newS = label.new(bar_index, low - _offS, _ohFullS, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=barColBear, textcolor=color.white, size=f_tsize(ohLblSizeStr))
        lastOhBarS := bar_index
        array.push(mtfOhLbls, _newS)
        while array.size(mtfOhLbls) > overheatLabelMax
            label.delete(array.get(mtfOhLbls, 0))
            array.remove(mtfOhLbls, 0)
    if _ohHotCntL >= overheatMinTfs and str.length(_ohFullL) > 0 and _okFlipL
        int _gapL = na(lastOhBarL) ? 999 : bar_index - lastOhBarL
        ohStreakL := _gapL == 1 ? ohStreakL + 1 : 1
        ohStreakL := math.min(ohStreakL, ohLblStackMax)
        float _offL = _ohStepUnit * (0.38 + (ohStreakL - 1) * ohLblStackStep)
        _newL = label.new(bar_index, high + _offL, _ohFullL, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=barColBull, textcolor=color.white, size=f_tsize(ohLblSizeStr))
        lastOhBarL := bar_index
        array.push(mtfOhLbls, _newL)
        while array.size(mtfOhLbls) > overheatLabelMax
            label.delete(array.get(mtfOhLbls, 0))
            array.remove(mtfOhLbls, 0)
else
    lastOhBarS := na
    lastOhBarL := na
    ohStreakS := 0
    ohStreakL := 0

// ============================================================================
// BAR COLORING
// ============================================================================
// barcolor only: plotcandle(force_overlay) often hides candles and looks like bars are not colored.
barColorToUse = excludeLastBar and barstate.islast ? na : barColors
barcolor(barColorToUse, title = "Bar color (ALMA regime)")
````
