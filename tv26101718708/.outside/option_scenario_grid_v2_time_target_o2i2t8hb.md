# Option Scenario Grid v2 (Time Target)

- url: https://www.tradingview.com/script/O2I2T8hB-Option-Scenario-Grid-v2-Time-Target/
- type: indicator
- pine_id: PUB;0110d304cc594e9a81cd1c1cc3b2de86
- version: 3.0

## Description

[b]Overview[/b]

Option Scenario Grid v2 is an interactive option price simulator built directly onto your underlying asset's chart. Unlike traditional option calculators that only show you prices for "today," this tool is specifically designed for forward-looking scenario planning.It answers the ultimate trader question: “How much will my option (CALL or PUT) be worth if the underlying price hits a specific level at a specific date and time in the future?”

The script is completely self-contained, utilizes a high-precision mathematical approximation of the Black-Scholes model, and is fully optimized for Pine Script v6.

[b]Key Features[/b]

Time Target Modeling: Define the exact date and time you expect the price movement to happen. The script automatically calculates the precise theta decay up to that specific point, showing you the option's value with the remaining time-to-expiry.

Visual Scenario Grid: Plots price levels above and below the current market price using a customizable percentage step. Each level displays the theoretical option value at that exact price boundary.

Visual Timelines on Chart: Automatically draws vertical dashed lines for your Target Time (Blue) and Expiration Date (Red) so you can visually track your trade's time horizon.

Current Price Highlight: The 0% move level (current close) is highlighted with a distinct yellow line, showing what the option will be worth at your target time if the asset price remains completely flat.

[b]How It Works[/b]

The script calculates the time remaining for the option ($T$) as the difference between the Expiry Date and your Target Time. This value is plugged into the Black-Scholes formula alongside your custom Implied Volatility (IV) and chosen Strike. 
The calculation loops through each price level only on the historical last bar, ensuring maximum chart performance without lagging your interface.

[b]Settings & Inputs[/b]

Option Type: Toggle between a CALL or PUT option.
IV %: Set the Implied Volatility of the option.
Step %: The percentage interval between each price level on the grid.
Levels Up/Down: Number of grid levels to display above and below the current price (ranges from 1 to 10).
Target Time: The exact date and time you expect the price target to be met.
Expiry: The option's contract expiration date and time.

Strike Price: Needed option Strike Price.

## Source Code

````pine
//@version=6
indicator("Option Scenario Grid v2 (Time Target)", overlay=true, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────
// Inputs
// ─────────────────────────────
type_opt    = input.string("CALL", "Option Type", options=["CALL", "PUT"])
iv_pct      = input.float(70.0, "IV %")
step_pct    = input.float(1.0, "Step %")
levels_cnt  = input.int(5, "Levels Up/Down", minval=1, maxval=10)

// Настройки дат (установлены базовые значения на июнь 2026)
target_time = input.time(timestamp("2026-06-10 09:00 +0000"), "Target Time (When price arrives)")
expiry      = input.time(timestamp("2026-06-15 09:00 +0000"), "Expiry Date")

// Страйк опциона
strike      = input.float(0.0, "Strike Price (0 = Use Current Close)", confirm=true)
def_strike  = strike == 0.0 ? close : strike

// ─────────────────────────────
// Math helpers
// ─────────────────────────────

// Высокоточная аппроксимация нормального распределения (CDF)
norm_cdf(x) =>
    if x < -7.0
        0.0
    else if x > 7.0
        1.0
    else
        p_x = math.exp(-x * x / 2.0) / math.sqrt(2.0 * math.pi)
        t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
        c1 = 0.319381530
        c2 = -0.356563782
        c3 = 1.781477937
        c4 = -1.821255978
        c5 = 1.330274429
        
        prob = 1.0 - p_x * (c1 * t + c2 * math.pow(t, 2) + c3 * math.pow(t, 3) + c4 * math.pow(t, 4) + c5 * math.pow(t, 5))
        x >= 0 ? prob : 1.0 - prob

// Black-Scholes Formula
bs_price(S, K, T, IV, isCall) =>
    if T <= 0
        math.max(isCall ? S - K : K - S, 0)
    else
        vol = IV
        d1 = (math.log(S / K) + (0.5 * vol * vol) * T) / (vol * math.sqrt(T))
        d2 = d1 - vol * math.sqrt(T)

        if isCall
            S * norm_cdf(d1) - K * norm_cdf(d2)
        else
            K * norm_cdf(-d2) - S * norm_cdf(-d1)

// ─────────────────────────────
// Расчет времени (ОТ целевого времени ДО экспирации)
// ─────────────────────────────
ms_year = 365.0 * 24 * 60 * 60 * 1000

// Теперь T считает сколько времени ОСТАНЕТСЯ у опциона в момент достижения целевой даты
T_at_target = math.max((expiry - target_time) / ms_year, 0)
// T_now: Настоящее оставшееся время от ТЕКУЩЕГО момента до ЭКСПИРАЦИИ (для 0% уровня)
T_now       = math.max((expiry - time) / ms_year, 0)


iv = iv_pct / 100.0
isCall = type_opt == "CALL"

// ─────────────────────────────
// Хранилище графических объектов
// ─────────────────────────────
var line[]  lvl_lines  = array.new<line>()
var label[] lvl_labels = array.new<label>()

// ─────────────────────────────
// Логика отрисовки на последнем баре
// ─────────────────────────────
if barstate.islast

    // Очистка старых линий и меток
    if array.size(lvl_lines) > 0
        for i = 0 to array.size(lvl_lines) - 1
            line.delete(array.get(lvl_lines, i))
    if array.size(lvl_labels) > 0
        for i = 0 to array.size(lvl_labels) - 1
            label.delete(array.get(lvl_labels, i))

    array.clear(lvl_lines)
    array.clear(lvl_labels)

    S0 = close
    K  = def_strike

    // 1. Вертикальная линия: ТАРГЕТ ПО ВРЕМЕНИ
    t_line = line.new(target_time, S0, target_time, S0 * 1.01, xloc=xloc.bar_time, extend=extend.both, color=color.blue, style=line.style_dashed, width=1)
    t_label = label.new(target_time, S0*1.02, "Target Time", xloc=xloc.bar_time, style=label.style_label_down, color=color.blue, textcolor=color.white, size=size.small)
    array.push(lvl_lines, t_line)
    array.push(lvl_labels, t_label)

    // 2. Вертикальная линия: ЭКСПИРАЦИЯ
    e_line = line.new(expiry, S0, expiry, S0 * 1.01, xloc=xloc.bar_time, extend=extend.both, color=color.red, style=line.style_dashed, width=1)
    e_label = label.new(expiry, S0*1.02, "Expiration Date", xloc=xloc.bar_time, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    array.push(lvl_lines, e_line)
    array.push(lvl_labels, e_label)

    // 3. Горизонтальная линия: СТРАЙК
    strike_ln = line.new(bar_index, K, bar_index + 40, K, color=color.orange, style=line.style_solid, width=2, extend=extend.right)
    strike_lb = label.new(bar_index, K, "Strike: " + str.tostring(K, "#.##"), style=label.style_label_right, textcolor=color.orange, color=color.new(color.black, 100))
    array.push(lvl_lines, strike_ln)
    array.push(lvl_labels, strike_lb)

    // 4. Цикл отрисовки уровней сценария цены
    for i = -levels_cnt to levels_cnt
        move = i * step_pct
        S = S0 * (1 + move / 100.0)


        // Настройки стиля для разных уровней
        color ln_color = color.new(color.gray, 60)
        color txt_color = color.white
        int ln_width = 1
        string prefix = str.tostring(move, "#.##") + "%"
        float current_T = T_at_target

        // Выделяем уровень текущей цены (0%)
        if i == 0
            ln_color := color.yellow
            txt_color := color.yellow
            ln_width := 2
            prefix    := "Now (0%)"
            current_T := T_now

        // Считаем стоимость опциона в этой точке цены S, но в ЦЕЛЕВОЕ время (T_at_target)
        opt_val = bs_price(S, K, current_T, iv, isCall)

        // Отрисовка уровня цены
        ln = line.new(bar_index, S, bar_index + 100, S, color=ln_color, width=ln_width)
        lb = label.new(
              bar_index + 25,
              S,
              prefix + " | Opt: " + str.tostring(opt_val, "#.##"),
              style=label.style_label_left,
              textcolor=txt_color,
              color=color.new(color.black, 50)
        )
        
        array.push(lvl_lines, ln)
        array.push(lvl_labels, lb)
````
