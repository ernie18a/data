//+------------------------------------------------------------------+
//|                                    AdvancedTradingCalculator.mq5 |
//|                                  Copyright 2025, Trading Systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "2.00"
#property description "Расширенный калькулятор для трейдера с риск-менеджментом"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Входные параметры - Инвестиции
input double InitialCapital = 1000.0;    // Начальный капитал
input int Years = 10;                    // Количество лет
input double MonthlyDeposit = 100.0;     // Ежемесячное пополнение

// Входные параметры - Торговля
input int TradesPerDay = 3;              // Количество сделок в день
input double WinRate = 55.0;             // Вероятность прибыльной сделки (%)
input double RiskRewardRatio = 1.5;      // Отношение риска к прибыли (1:X)
input double MaxDrawdownLimit = 20.0;     // Психологический барьер просадки (%)
input int RefreshInterval = 1;           // Интервал обновления (в секундах)

// Глобальные переменные
double totalAmount[];
double indicatorBuffer[];
string objPrefix = "TradingCalc_";
int windowWidth = 400;
int windowHeight = 480;
int chartWidth, chartHeight;

// Структура для хранения торговых расчетов
struct TradingMetrics {
    double maxRiskPerTrade;          // Максимальный риск на сделку
    double expectedMonthlyReturn;     // Ожидаемая месячная доходность
    double expectedAnnualReturn;      // Ожидаемая годовая доходность
    int monthlyTrades;               // Количество сделок в месяц
    double probabilityOfRuin;        // Вероятность разорения
    double expectedMonthlyCapital;   // Ожидаемый капитал через месяц
    double expectedAnnualCapital;    // Ожидаемый капитал через год
    double expectedFinalCapital;     // Ожидаемый капитал в конце срока
};

TradingMetrics metrics;

//+------------------------------------------------------------------+
//| Инициализация индикатора                                          |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, indicatorBuffer, INDICATOR_DATA);
    ArrayResize(totalAmount, Years * 12);
    
    if(!ValidateInputs()) return INIT_PARAMETERS_INCORRECT;
    
    CreatePanel();
    EventSetTimer(RefreshInterval);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Проверка входных параметров                                       |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
    if(InitialCapital <= 0 || MonthlyDeposit < 0 || Years <= 0)
        return false;
    if(TradesPerDay <= 0 || WinRate <= 0 || WinRate >= 100)
        return false;
    if(RiskRewardRatio <= 0 || MaxDrawdownLimit <= 0 || MaxDrawdownLimit >= 100)
        return false;
        
    return true;
}

//+------------------------------------------------------------------+
//| Расчет торговых метрик                                            |
//+------------------------------------------------------------------+
void CalculateTradingMetrics()
{
    // Расчет количества сделок
    metrics.monthlyTrades = TradesPerDay * 22; // примерно 22 торговых дня в месяц
    
    // Расчет максимального риска на сделку
    double maxRiskAmount = (InitialCapital * MaxDrawdownLimit / 100) / sqrt(metrics.monthlyTrades);
    metrics.maxRiskPerTrade = NormalizeDouble(maxRiskAmount / InitialCapital * 100, 2);
    
    // Расчет ожидаемой доходности
    double winProb = WinRate / 100;
    double loseProb = 1 - winProb;
    double expectedValuePerTrade = (winProb * RiskRewardRatio) - loseProb;
    
    metrics.expectedMonthlyReturn = expectedValuePerTrade * metrics.monthlyTrades * metrics.maxRiskPerTrade;
    metrics.expectedAnnualReturn = metrics.expectedMonthlyReturn * 12;
    
    // Расчет вероятности разорения (формула Келли)
    double kellyPercentage = (winProb * RiskRewardRatio - loseProb) / RiskRewardRatio;
    metrics.probabilityOfRuin = exp(-2 * pow(InitialCapital / maxRiskAmount, 2) * pow(kellyPercentage, 2));
    
    // Расчет ожидаемого капитала
    CalculateExpectedCapital();
}

//+------------------------------------------------------------------+
//| Расчет ожидаемого капитала                                        |
//+------------------------------------------------------------------+
void CalculateExpectedCapital()
{
    // Через месяц
    metrics.expectedMonthlyCapital = InitialCapital * (1 + metrics.expectedMonthlyReturn/100) + MonthlyDeposit;
    
    // Через год (с учетом ежемесячных пополнений)
    metrics.expectedAnnualCapital = InitialCapital;
    for(int i = 0; i < 12; i++) {
        metrics.expectedAnnualCapital = metrics.expectedAnnualCapital * (1 + metrics.expectedMonthlyReturn/100) + MonthlyDeposit;
    }
    
    // В конце срока
    metrics.expectedFinalCapital = InitialCapital;
    for(int i = 0; i < Years * 12; i++) {
        metrics.expectedFinalCapital = metrics.expectedFinalCapital * (1 + metrics.expectedMonthlyReturn/100) + MonthlyDeposit;
        totalAmount[i] = metrics.expectedFinalCapital;
    }
}

//+------------------------------------------------------------------+
//| Создание информационной панели                                    |
//+------------------------------------------------------------------+
void CreatePanel()
{
    chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    chartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    
    // Создаем фон панели
    ObjectCreate(0, objPrefix + "Background", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_XDISTANCE, chartWidth - windowWidth - 10);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_XSIZE, windowWidth);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_YSIZE, windowHeight);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_BGCOLOR, clrWhiteSmoke);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, objPrefix + "Background", OBJPROP_COLOR, clrBlack);
    
    CreateLabel("Title", "Расширенный калькулятор сложного процента для трейдера", 10, 15, clrBlack, true);
}

///+------------------------------------------------------------------+
//| Форматирование числа с разрядами                                  |
//+------------------------------------------------------------------+
string FormatMoney(double value)
{
    string result = DoubleToString(value, 2);
    int pos = StringFind(result, ".");
    if(pos == -1) pos = StringLen(result);
    
    while(pos > 3)
    {
        pos -= 3;
        result = StringSubstr(result, 0, pos) + " " + StringSubstr(result, pos);
    }
    return result;
}

//+------------------------------------------------------------------+
//| Склонение слова "год" в зависимости от числа                      |
//+------------------------------------------------------------------+
string YearDeclension(int years)
{
    string result;
    int remainder100 = years % 100;
    int remainder10 = years % 10;
    
    if(remainder100 >= 11 && remainder100 <= 19)
        result = "лет";
    else if(remainder10 == 1)
        result = "год";
    else if(remainder10 >= 2 && remainder10 <= 4)
        result = "года";
    else
        result = "лет";
        
    return result;
}

//+------------------------------------------------------------------+
//| Обновление панели                                                 |
//+------------------------------------------------------------------+
void UpdatePanel()
{
    CalculateTradingMetrics();
    
    int y = 40;
    
    // Секция капитала
    CreateLabel("Section1", "== Параметры капитала ==", 10, y, clrNavy, true); y += 25;
    CreateLabel("InitialCapital", "Начальный капитал: $" + FormatMoney(InitialCapital), 10, y, clrBlack); y += 20;
    CreateLabel("MonthlyDeposit", "Ежемесячное пополнение: $" + FormatMoney(MonthlyDeposit), 10, y, clrBlack); y += 20;
    
    // Секция торговых параметров
    y += 10;
    CreateLabel("Section2", "== Торговые параметры ==", 10, y, clrNavy, true); y += 25;
    CreateLabel("TradesInfo", "Сделок в день: " + IntegerToString(TradesPerDay) + " (" + IntegerToString(metrics.monthlyTrades) + " в месяц)", 10, y, clrBlack); y += 20;
    CreateLabel("WinRate", "Вероятность успеха: " + DoubleToString(WinRate, 1) + "%", 10, y, clrBlack); y += 20;
    CreateLabel("RRR", "Риск/Прибыль: 1:" + DoubleToString(RiskRewardRatio, 1), 10, y, clrBlack); y += 20;
    
    // Секция риск-менеджмента
    y += 10;
    CreateLabel("Section3", "== Риск-менеджмент ==", 10, y, clrNavy, true); y += 25;
    CreateLabel("MaxRiskTrade", "Максимальный риск на сделку: " + DoubleToString(metrics.maxRiskPerTrade, 2) + "%", 10, y, clrBlack); y += 20;
    CreateLabel("MaxDrawdown", "Лимит просадки: " + DoubleToString(MaxDrawdownLimit, 1) + "%", 10, y, clrBlack); y += 20;
    CreateLabel("ProbRuin", "Вероятность разорения: " + DoubleToString(metrics.probabilityOfRuin * 100, 4) + "%", 10, y, clrBlack); y += 20;
    
    // Секция ожидаемой доходности
    y += 10;
    CreateLabel("Section4", "== Ожидаемая доходность ==", 10, y, clrNavy, true); y += 25;
    CreateLabel("MonthlyReturn", "Месячная доходность: " + DoubleToString(metrics.expectedMonthlyReturn, 2) + "%", 10, y, clrGreen); y += 20;
    CreateLabel("AnnualReturn", "Годовая доходность: " + DoubleToString(metrics.expectedAnnualReturn, 2) + "%", 10, y, clrGreen); y += 20;
    
    // Секция прогноза капитала
    y += 10;
    CreateLabel("Section5", "== Прогноз капитала ==", 10, y, clrNavy, true); y += 25;
    CreateLabel("MonthCapital", "Через месяц: $" + FormatMoney(metrics.expectedMonthlyCapital), 10, y, clrGreen); y += 20;
    CreateLabel("YearCapital", "Через год: $" + FormatMoney(metrics.expectedAnnualCapital), 10, y, clrGreen); y += 20;
    CreateLabel("FinalCapital", "Через " + IntegerToString(Years) + " " + YearDeclension(Years) + ": $" + FormatMoney(metrics.expectedFinalCapital), 10, y, clrGreen); y += 40;
    
    UpdateChart();
}

//+------------------------------------------------------------------+
//| Базовые функции                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, objPrefix);
    EventKillTimer();
}

void OnTimer()
{
    UpdatePanel();
}

void CreateLabel(string name, string text, int x, int y, color clr, bool isBold = false)
{
    ObjectCreate(0, objPrefix + name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objPrefix + name, OBJPROP_XDISTANCE, chartWidth - windowWidth - 10 + x);
    ObjectSetInteger(0, objPrefix + name, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, objPrefix + name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, objPrefix + name, OBJPROP_COLOR, clr);
    ObjectSetString(0, objPrefix + name, OBJPROP_FONT, isBold ? "Arial Bold" : "Arial");
    ObjectSetInteger(0, objPrefix + name, OBJPROP_FONTSIZE, isBold ? 10 : 9);
}

void UpdateChart()
{
    ObjectDelete(0, objPrefix + "Graph");
    
    ObjectCreate(0, objPrefix + "Graph", OBJ_TREND, 0, 0, totalAmount[0], Years * 12, totalAmount[Years * 12 - 1]);
    ObjectSetInteger(0, objPrefix + "Graph", OBJPROP_COLOR, clrBlue);
    ObjectSetInteger(0, objPrefix + "Graph", OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, objPrefix + "Graph", OBJPROP_RAY_RIGHT, false);
    
    ChartRedraw();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    for(int i = 0; i < rates_total && i < ArraySize(totalAmount); i++)
    {
        indicatorBuffer[i] = totalAmount[i];
    }
    
    return(rates_total);
}