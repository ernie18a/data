//+------------------------------------------------------------------+
//|                      Quantum Gold & Silver Trader 3.2.mq5        |
//|        Enhanced with Quantum Trailing Stop & Deposit Protection  |
//|             Full Auto-Optimization for Strategy Tester           |
//|              Special settings for Gold and Silver                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "3.2"
#property description "AI-Enhanced Quantum Trading System for Gold and Silver"
#property script_show_inputs

#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Параметры для оптимизации                                       |
//+------------------------------------------------------------------+

input group "Quantum System"
input int      QuantumStates        = 17;      // Количество квантовых состояний [5-50]
input double   QuantumDecayRate     = 0.03;    // Скорость распада состояний [0.01-0.1]
input double   StateUpdateRate      = 0.1;     // Скорость обновления состояний [0.05-0.3]
input double   StateMemoryFactor    = 0.9;     // Фактор памяти состояний [0.8-0.99]

input group "AI Parameters"
input int      LearningPeriod       = 200;     // Период обучения ИИ [50-500]
input double   AdaptiveThreshold    = 0.65;    // Порог принятия решений [0.55-0.75]

input group "Indicator Settings"
input int      RSIPeriod            = 14;      // Период RSI [7-21]
input int      ADXPeriod            = 14;      // Период ADX [10-25]
input int      ATRPeriodInput       = 14;      // Период ATR [10-20]
input int      FastMAPeriodInput    = 50;      // Период быстрой MA [20-100]
input int      SlowMAPeriodInput    = 200;     // Период медленной MA [100-300]
input int      ChaosPeriod          = 20;      // Период расчета хаоса [10-50]
input ENUM_TIMEFRAMES AnalysisTimeframe = PERIOD_M15; // Таймфрейм анализа

input group "AI Modules"
input bool     UseRSI               = true;    // Использовать RSI
input double   RSIWeight            = 1.0;     // Вес RSI [0.1-2.0]
input bool     UseADX               = true;    // Использовать ADX
input double   ADXWeight            = 1.0;     // Вес ADX [0.1-2.0]
input bool     UseMA                = true;    // Использовать MA
input double   MAWeight             = 1.0;     // Вес MA [0.1-2.0]
input bool     UseChaosInAI         = true;    // Использовать хаос
input double   ChaosWeight          = 1.0;     // Вес хаоса [0.1-2.0]
input bool     UseQuantumState      = true;    // Использовать квант. состояние
input double   QuantumStateWeight   = 1.0;     // Вес квант. состояния [0.1-2.0]

input group "Trading Logic"
input double   BaseRiskInput        = 0.5;     // Базовый риск (%) [0.1-1.0]
input double   MaxRisk              = 2.0;     // Макс. риск (%) [1.0-5.0]
input int      MinBarsBetweenTrades = 1;       // Мин. баров между сделками [1-5]
input double   ATRMultiplierSL      = 1.5;     // Множитель ATR для SL [1.0-3.0]
input double   TPtoSLRatio          = 2.0;     // Соотношение TP/SL [1.5-3.0]

input group "Risk Management"
input double   RiskIncreaseFactor   = 1.2;     // Фактор увеличения риска [1.1-1.5]
input double   RiskDecreaseFactor   = 0.7;     // Фактор снижения риска [0.5-0.9]
input int      MaxConsecutiveLosses = 2;       // Макс. число убытков подряд [1-5]

input group "Micro Account Settings"
input bool     MicroAccountMode     = true;    // Режим для малых депозитов
input double   MicroRiskCorrection  = 0.6;     // Коррекция риска [0.3-1.0]
input bool     IgnoreMarginLimitForMinLot = true;  // Игнорировать лимит маржи для мин.лота

input group "Signal Filters"
input bool     UseChaosFilter       = true;    // Фильтр хаотичности рынка
input double   ChaosThreshold       = 0.35;    // Порог хаотичности [0.2-0.5]

input group "===== Deposit Protection System ====="
input bool    UseEquityProtection      = true;   // Включить защиту по эквити
input double  MaxDailyDrawdownPercent  = 5.0;    // Макс. дневная просадка (%) [0-50]
input double  MaxTotalDrawdownPercent  = 20.0;   // Макс. общая просадка (%) [0-50]
input double  DrawdownBuffer           = 2.0;    // Буфер просадки (%) [0-5]
input bool    UseDailyLossLimit        = true;   // Включить лимит дневного убытка
input double  DailyLossLimitPercent    = 3.0;    // Лимит убытка за день (%) [0-10]
input double  DailyLossLimitAbsolute   = 50.0;   // Абсолютный лимит убытка за день [0-5000]
input double  DailyLossLimitATRMultiplier = 3.0; // Множитель ATR для лимита убытка [1.0-10.0]
input bool    UsePositionSizeLimit     = true;   // Ограничить размер позиции
input double  MaxPositionSizePercent   = 2.0;    // Макс. размер позиции (% баланса) [0.1-5]
input bool    UseHardStop              = false;  // Использовать жесткий стоп-лосс (ОТКЛЮЧЕНО)
input double  HardStopLevel            = 20.0;   // Уровень жесткого стопа (%) [10-50]

input group "===== Advanced Quantum Trailing Stop ====="
input bool    UseQuantumTrailing       = true;   // Включить квантовый трейлинг-стоп
input double  BaseTrailATRMultiplier   = 1.5;    // Базовый множитель ATR [1.0-3.0]
input double  MaxTrailATRMultiplier    = 4.0;    // Макс. множитель ATR [2.0-6.0]
input double  TrailActivationProfit    = 1.0;    // Активация при прибыли (в ATR) [0.5-3.0]
input double  ChaosSensitivity         = 0.7;    // Чувствительность к хаосу [0.3-1.5]
input double  QuantumStateInfluence    = 0.5;    // Влияние квантового состояния [0.1-1.0]

input group "===== Auto-Optimization ====="
input bool    AutoOptimizeInTester     = true;   // Автооптимизация в тестере
input int     OptimizationPasses       = 50;     // Количество проходов оптимизации [10-200]

// Специфические параметры для золота и серебра
input group "==== Gold Settings (XAUUSD) ===="
input double   Gold_ATRMultiplierSL      = 1.5;     // Множитель ATR для SL
input double   Gold_TPtoSLRatio          = 2.0;     // Соотношение TP/SL
input double   Gold_BaseRiskInput        = 0.5;     // Базовый риск (%)
input int      Gold_MinBarsBetweenTrades = 1;       // Мин. баров между сделками
input double   Gold_BaseTrailATRMultiplier = 1.5;   // Базовый множитель ATR для трейлинга
input double   Gold_ChaosThreshold       = 0.35;    // Порог хаотичности

input group "==== Silver Settings (XAGUSD) ===="
input double   Silver_ATRMultiplierSL      = 2.0;     // Множитель ATR для SL
input double   Silver_TPtoSLRatio          = 2.5;     // Соотношение TP/SL
input double   Silver_BaseRiskInput        = 0.3;     // Базовый риск (%)
input int      Silver_MinBarsBetweenTrades = 2;       // Мин. баров между сделками
input double   Silver_BaseTrailATRMultiplier = 2.0;   // Базовый множитель ATR для трейлинга
input double   Silver_ChaosThreshold       = 0.4;     // Порог хаотичности

// Внутренние копии параметров для оптимизации
int internalQuantumStates;
double internalQuantumDecayRate;
double internalStateUpdateRate;
double internalStateMemoryFactor;
int internalRSIPeriod;
int internalADXPeriod;
int internalATRPeriod;
int internalFastMAPeriod;
int internalSlowMAPeriod;
double internalBaseRisk;
double internalATRMultiplierSL;
double internalTPtoSLRatio;
int internalMinBarsBetweenTrades;
double internalBaseTrailATRMultiplier;
double internalChaosThreshold;

// Глобальные переменные
CTrade trade;
CAccountInfo accountInfo;
int quantumState = 0;
double waveFunction[];
double stateReturns[];
datetime lastTradeTime;
double positionMatrix[][2];
int lossCounter = 0;
double currentRisk = BaseRiskInput;
double aiWeights[];
double marketMatrix[][4];
int signalHistory[];
int rsiHandle, adxHandle, atrHandle, maFastHandle, maSlowHandle;

// Кэш для индикаторов
double lastRSI = 0, lastADX = 0, lastATR = 0, lastFastMA = 0, lastSlowMA = 0;
datetime lastCacheTime;

// Переменные для системы защиты
double initialEquity = 0;
double maxEquityToday = 0;
double minEquityToday = 0;
datetime lastEquityUpdate = 0;
double totalProfitToday = 0;
double dailyLossLimit;
bool tradingHalted = false;
int marginErrorCount = 0;
datetime lastErrorTime = 0;

// Для трейлинг-стопа
datetime lastTrailTime = 0;
double lastTrailPrice = 0;
double lastTrailSl = 0;

// Внутренняя переменная для режима микро-счета
bool internalMicroMode;

// Для автооптимизации
bool isFirstRun = true;
double bestParams[][2];
bool optimizationCompleted = false;

//+------------------------------------------------------------------+
//| Возвращает описание ошибки                                      |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
{
    switch(error_code)
    {
        case 0:     return ("Нет ошибки");
        case 1:     return ("Нет ошибки, но результат неизвестен");
        case 2:     return ("Общая ошибка");
        case 3:     return ("Неправильные параметры");
        case 4:     return ("Торговый сервер занят");
        case 5:     return ("Старая версия клиента");
        case 6:     return ("Нет связи с торговым сервером");
        case 7:     return ("Недостаточно прав");
        case 8:     return ("Слишком частые запросы");
        case 9:     return ("Недопустимая операция");
        case 64:    return ("Счет заблокирован");
        case 65:    return ("Неправильный номер счета");
        case 128:   return ("Истек срок ожидания совершения сделки");
        case 129:   return ("Неправильная цена");
        case 130:   return ("Неправильные стопы");
        case 131:   return ("Неправильный объем");
        case 132:   return ("Рынок закрыт");
        case 133:   return ("Торговля запрещена");
        case 134:   return ("Недостаточно денег");
        case 135:   return ("Цена изменилась");
        case 136:   return ("Нет цен");
        case 137:   return ("Брокер занят");
        case 138:   return ("Новые цены");
        case 139:   return ("Ордер заблокирован");
        case 140:   return ("Разрешена только покупка");
        case 141:   return ("Слишком много запросов");
        case 145:   return ("Модификация запрещена");
        case 146:   return ("Система торговли занята");
        case 147:   return ("Использование запрещено датой экспирации");
        case 148:   return ("Количество открытых и отложенных ордеров достигло предела");
        case 4756:  return ("Неверные стопы");
        default:    return ("Неизвестная ошибка: " + IntegerToString(error_code));
    }
}

//+------------------------------------------------------------------+
//| Автокоррекция параметров                                         |
//+------------------------------------------------------------------+
void AutoCorrectParameters()
{
    // Коррекция MA периодов
    if(internalFastMAPeriod >= internalSlowMAPeriod)
    {
        internalSlowMAPeriod = internalFastMAPeriod + 10;
        PrintFormat("Автокоррекция: SlowMAPeriod изменен с %d на %d (должен быть > FastMAPeriod)", 
                    internalSlowMAPeriod, internalSlowMAPeriod);
    }

    // Коррекция ATR периода
    if(internalATRPeriod < 10)
    {
        internalATRPeriod = 10;
        PrintFormat("Автокоррекция: ATRPeriod изменен с %d на %d (минимум 10)", internalATRPeriod, internalATRPeriod);
    }
    
    // Коррекция квантовых состояний
    if(internalQuantumStates < 5)
    {
        PrintFormat("Предупреждение: QuantumStates=%d слишком мал (рекомендуется >=5)", internalQuantumStates);
    }
    
    // Коррекция риска
    if(internalBaseRisk > MaxRisk)
    {
        internalBaseRisk = MaxRisk;
        PrintFormat("Автокоррекция: BaseRisk изменен с %.2f на %.2f (не может быть > MaxRisk)", internalBaseRisk, internalBaseRisk);
    }
}

//+------------------------------------------------------------------+
//| Расчет среднего значения                                         |
//+------------------------------------------------------------------+
double MathMean(double &array[])
{
    double sum = 0.0;
    int count = ArraySize(array);
    if(count == 0) return 0;
    
    for(int i = 0; i < count; i++)
        sum += array[i];
    return sum / count;
}

//+------------------------------------------------------------------+
//| Расчет стандартного отклонения                                  |
//+------------------------------------------------------------------+
double MathStandardDeviation(double &array[])
{
    double mean = MathMean(array);
    double sum = 0.0;
    int count = ArraySize(array);
    if(count == 0) return 0;
    
    for(int i = 0; i < count; i++)
        sum += MathPow(array[i] - mean, 2);
    return MathSqrt(sum / count);
}

//+------------------------------------------------------------------+
//| Расчет хаотичности рынка                                        |
//+------------------------------------------------------------------+
double CalculateChaos()
{
    double returns[];
    int bars = MathMin(ChaosPeriod, Bars(_Symbol, AnalysisTimeframe));
    if(bars < ChaosPeriod) return 0.5;
    
    ArrayResize(returns, ChaosPeriod);
    for(int i = 0; i < ChaosPeriod; i++) 
    {
        returns[i] = MathLog(iClose(_Symbol, AnalysisTimeframe, i)) - 
                     MathLog(iClose(_Symbol, AnalysisTimeframe, i+1));
    }
    
    double mean = MathMean(returns);
    double sd = MathStandardDeviation(returns);
    return (sd != 0) ? MathAbs(mean/sd) : 0.5;
}

//+------------------------------------------------------------------+
//| Получение значения индикатора по хэндлу                         |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle, int buffer=0, int shift=0)
{
    double value[1];
    if(CopyBuffer(handle, buffer, shift, 1, value) != 1)
    {
        Print("Ошибка получения данных индикатора: ", GetLastError());
        return EMPTY_VALUE;
    }
    return value[0];
}

//+------------------------------------------------------------------+
//| Инициализация ИИ системы                                        |
//+------------------------------------------------------------------+
void InitAISystem()
{
    ArrayResize(aiWeights, 6);
    ArrayInitialize(aiWeights, 0.5);
    
    // Автокоррекция параметров перед инициализацией
    AutoCorrectParameters();
    
    // Загрузка сохраненных весов ИИ
    string fileName = "QuantumAI_"+_Symbol+".txt";
    int fileHandle = FileOpen(fileName, FILE_READ|FILE_TXT|FILE_COMMON);
    if(fileHandle != INVALID_HANDLE)
    {
        for(int i = 0; i < 6 && !FileIsEnding(fileHandle); i++)
            aiWeights[i] = StringToDouble(FileReadString(fileHandle));
        FileClose(fileHandle);
        Print("Весы ИИ успешно загружены из файла");
    }
    else
    {
        Print("Файл весов не найден, используются значения по умолчанию");
    }
    
    ArrayResize(marketMatrix, LearningPeriod);
    ArrayResize(signalHistory, LearningPeriod);
    ArrayInitialize(signalHistory, 0);
    
    // Создание хэндлов индикаторов
    rsiHandle = iRSI(_Symbol, AnalysisTimeframe, internalRSIPeriod, PRICE_CLOSE);
    adxHandle = iADX(_Symbol, AnalysisTimeframe, internalADXPeriod);
    atrHandle = iATR(_Symbol, AnalysisTimeframe, internalATRPeriod);
    maFastHandle = iMA(_Symbol, AnalysisTimeframe, internalFastMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    maSlowHandle = iMA(_Symbol, AnalysisTimeframe, internalSlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    
    // Проверка создания хэндлов
    if(rsiHandle == INVALID_HANDLE || adxHandle == INVALID_HANDLE || 
       atrHandle == INVALID_HANDLE || maFastHandle == INVALID_HANDLE || 
       maSlowHandle == INVALID_HANDLE)
    {
        Print("Ошибка создания индикаторов: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Адаптивное обучение ИИ                                          |
//+------------------------------------------------------------------+
void UpdateAI(int signal, double profit)
{
    // Обновление истории сигналов
    for(int i = LearningPeriod-1; i > 0; i--)
        signalHistory[i] = signalHistory[i-1];
    signalHistory[0] = (profit > 0) ? signal : -signal;
    
    // Рассчитываем новые веса
    double rsi = GetIndicatorValue(rsiHandle) / 100.0;
    double adx = GetIndicatorValue(adxHandle, 0) / 100.0;
    double atr = GetIndicatorValue(atrHandle) / 100.0;
    double chaos = CalculateChaos();
    
    // Обновление матрицы рынка
    for(int i = LearningPeriod-1; i > 0; i--)
    {
        marketMatrix[i][0] = marketMatrix[i-1][0];
        marketMatrix[i][1] = marketMatrix[i-1][1];
        marketMatrix[i][2] = marketMatrix[i-1][2];
        marketMatrix[i][3] = marketMatrix[i-1][3];
    }
    marketMatrix[0][0] = rsi;
    marketMatrix[0][1] = adx;
    marketMatrix[0][2] = atr;
    marketMatrix[0][3] = chaos;
    
    // Адаптация весов
    double successRate = 0;
    int count = 0;
    for(int i = 0; i < MathMin(100, LearningPeriod); i++)
    {
        if(signalHistory[i] != 0)
        {
            count++;
            if(signalHistory[i] > 0) successRate++;
        }
    }
    successRate = (count > 0) ? successRate/count : 0.5;
    
    double adjustment = (successRate - 0.5) * 0.1;
    for(int i = 0; i < 6; i++)
        aiWeights[i] = MathMin(1.0, MathMax(0.1, aiWeights[i] + adjustment));
}

//+------------------------------------------------------------------+
//| Обновление кэша индикаторов                                     |
//+------------------------------------------------------------------+
void UpdateIndicatorCache()
{
    datetime currentTime = iTime(_Symbol, AnalysisTimeframe, 0);
    if(currentTime != lastCacheTime)
    {
        lastRSI = GetIndicatorValue(rsiHandle);
        lastADX = GetIndicatorValue(adxHandle, 0);
        lastATR = GetIndicatorValue(atrHandle);
        lastFastMA = GetIndicatorValue(maFastHandle);
        lastSlowMA = GetIndicatorValue(maSlowHandle);
        lastCacheTime = currentTime;
    }
}

//+------------------------------------------------------------------+
//| Генерация торгового сигнала                                     |
//+------------------------------------------------------------------+
int GenerateTradeSignal()
{
    if(tradingHalted) return -1; // Блокировка сигналов при остановке
    
    UpdateIndicatorCache();
    
    // Проверка валидности данных
    if(lastRSI == EMPTY_VALUE || lastADX == EMPTY_VALUE || 
       lastATR == EMPTY_VALUE || lastFastMA == EMPTY_VALUE || 
       lastSlowMA == EMPTY_VALUE)
    {
        Print("Недостаточно данных индикаторов");
        return -1;
    }
    
    double chaos = CalculateChaos();
    
    // Фильтр хаоса
    if(UseChaosFilter && chaos < internalChaosThreshold)
        return -1;
    
    // Квантовый коллапс
    quantumState = MathRand() % internalQuantumStates;
    
    // Модульная система ИИ
    double signalStrength = 0;
    
    if(UseRSI)
        signalStrength += RSIWeight * aiWeights[0] * (lastRSI - 50.0) / 50.0;
    
    if(UseADX)
        signalStrength += ADXWeight * aiWeights[1] * (lastADX - 20.0) / 30.0;
    
    if(UseMA)
        signalStrength += MAWeight * aiWeights[2] * (lastFastMA - lastSlowMA) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    if(UseChaosInAI)
        signalStrength += ChaosWeight * aiWeights[3] * chaos;
    
    if(UseQuantumState)
        signalStrength += QuantumStateWeight * aiWeights[4] * (quantumState - internalQuantumStates/2.0) / internalQuantumStates;
    
    // Генерация сигнала
    if(signalStrength > AdaptiveThreshold) return ORDER_TYPE_BUY;
    if(signalStrength < -AdaptiveThreshold) return ORDER_TYPE_SELL;
    
    return -1;
}

//+------------------------------------------------------------------+
//| Адаптивное управление риском                                    |
//+------------------------------------------------------------------+
double CalculateAdaptiveRisk()
{
    double chaos = CalculateChaos();
    double risk = internalBaseRisk * (1.0 + MathSin(chaos * M_PI));
    
    // Коррекция для микро-депозитов
    if(internalMicroMode) 
    {
        double equity = accountInfo.Equity();
        if(equity < 1000) 
        {
            risk *= MicroRiskCorrection * MathSqrt(equity/1000);
        }
    }
    
    return MathMin(MaxRisk, MathMax(0.1, risk));
}

//+------------------------------------------------------------------+
//| Улучшенная нормализация цены                                    |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
{
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    if(tickSize == 0) return price; // Защита от деления на ноль
    
    // Рассчитываем количество знаков после запятой
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    
    // Нормализуем к размеру тика
    return NormalizeDouble(MathRound(price / tickSize) * tickSize, digits);
}

//+------------------------------------------------------------------+
//| Проверка корректности уровней SL/TP                             |
//+------------------------------------------------------------------+
bool CheckStopLossTakeprofit(int type, double currentPrice, double sl, double tp)
{
    if(sl <= 0 && tp <= 0) return true;
    
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int stopLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double minDist = stopLevel * point;
    
    if(minDist <= 0) minDist = 10 * point; // Защитное значение
    
    // Добавляем буфер 20% от ATR
    double atr = GetIndicatorValue(atrHandle);
    if(atr != EMPTY_VALUE && atr > 0)
    {
        minDist = MathMax(minDist, atr * 0.2);
    }

    if(type == POSITION_TYPE_BUY)
    {
        if(sl > 0)
        {
            // SL должен быть ниже текущей цены
            if(sl >= currentPrice - minDist)
            {
                PrintFormat("Ошибка: SL=%.5f слишком близок к текущей цене=%.5f (min_dist=%.5f)", sl, currentPrice, minDist);
                return false;
            }
        }
        if(tp > 0)
        {
            // TP должен быть выше текущей цены
            if(tp <= currentPrice + minDist)
            {
                PrintFormat("Ошибка: TP=%.5f слишком близок к текущей цене=%.5f (min_dist=%.5f)", tp, currentPrice, minDist);
                return false;
            }
        }
    }
    else if(type == POSITION_TYPE_SELL)
    {
        if(sl > 0)
        {
            // SL должен быть выше текущей цены
            if(sl <= currentPrice + minDist)
            {
                PrintFormat("Ошибка: SL=%.5f слишком близок к текущей цене=%.5f (min_dist=%.5f)", sl, currentPrice, minDist);
                return false;
            }
        }
        if(tp > 0)
        {
            // TP должен быть ниже текущей цены
            if(tp >= currentPrice - minDist)
            {
                PrintFormat("Ошибка: TP=%.5f слишком близок к текущей цене=%.5f (min_dist=%.5f)", tp, currentPrice, minDist);
                return false;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Обновление данных о дневной эквити                              |
//+------------------------------------------------------------------+
void UpdateDailyEquity()
{
    datetime current = TimeCurrent();
    MqlDateTime now;
    TimeToStruct(current, now);
    
    static MqlDateTime lastDay;
    static bool firstRun = true;
    
    if(firstRun)
    {
        firstRun = false;
        lastDay = now;
        initialEquity = accountInfo.Equity();
        maxEquityToday = initialEquity;
        minEquityToday = initialEquity;
        totalProfitToday = 0;
        lastEquityUpdate = current;
        
        // Динамический лимит на основе волатильности
        double atr = GetIndicatorValue(atrHandle);
        double atrBasedLimit = (atr != EMPTY_VALUE) ? atr * DailyLossLimitATRMultiplier : DailyLossLimitAbsolute;
        
        dailyLossLimit = MathMin(
            accountInfo.Balance() * (DailyLossLimitPercent / 100.0), 
            MathMax(DailyLossLimitAbsolute, atrBasedLimit)
        );
        tradingHalted = false;
        return;
    }
    
    // Если наступил новый день, сбрасываем
    if(now.day != lastDay.day || now.mon != lastDay.mon || now.year != lastDay.year)
    {
        initialEquity = accountInfo.Equity();
        maxEquityToday = initialEquity;
        minEquityToday = initialEquity;
        totalProfitToday = 0;
        lastDay = now;
        lastEquityUpdate = current;
        
        // Динамический лимит на основе волатильности
        double atr = GetIndicatorValue(atrHandle);
        double atrBasedLimit = (atr != EMPTY_VALUE) ? atr * DailyLossLimitATRMultiplier : DailyLossLimitAbsolute;
        
        dailyLossLimit = MathMin(
            accountInfo.Balance() * (DailyLossLimitPercent / 100.0), 
            MathMax(DailyLossLimitAbsolute, atrBasedLimit)
        );
        tradingHalted = false;
        Print("Новый торговый день начат. Сброс параметров защиты.");
        return;
    }
    
    // Обновляем максимум и минимум эквити
    double equity = accountInfo.Equity();
    if(equity > maxEquityToday || maxEquityToday == 0) maxEquityToday = equity;
    if(equity < minEquityToday || minEquityToday == 0) minEquityToday = equity;
    
    // Обновляем суммарную прибыль за день
    if(current - lastEquityUpdate >= 60)
    {
        totalProfitToday = equity - initialEquity;
        lastEquityUpdate = current;
    }
}

//+------------------------------------------------------------------+
//| Проверка ограничений по просадке                                |
//+------------------------------------------------------------------+
bool CheckDrawdownLimits()
{
    if(!UseEquityProtection) return true;
    if(tradingHalted) return false;
    
    double equity = accountInfo.Equity();
    double balance = accountInfo.Balance();
    
    // Защита от нулевого баланса
    if(balance <= 0) balance = 0.01;
    
    // Общая просадка
    double totalDrawdown = (balance - equity) / balance * 100.0;
    if(totalDrawdown >= MaxTotalDrawdownPercent)
    {
        PrintFormat("Превышена максимальная общая просадка: %.2f%% >= %.2f%%. Торговля остановлена.", 
                    totalDrawdown, MaxTotalDrawdownPercent);
        tradingHalted = true;
        return false;
    }
    else if (totalDrawdown >= (MaxTotalDrawdownPercent - DrawdownBuffer))
    {
        PrintFormat("Внимание: общая просадка приближается к лимиту: %.2f%% (лимит %.2f%%, буфер %.2f%%)", 
                    totalDrawdown, MaxTotalDrawdownPercent, DrawdownBuffer);
    }
    
    // Дневная просадка
    double dailyDrawdown = 0.0;
    if (maxEquityToday > 0)
        dailyDrawdown = (maxEquityToday - equity) / maxEquityToday * 100.0;
    
    if (maxEquityToday > 0 && dailyDrawdown >= MaxDailyDrawdownPercent)
    {
        PrintFormat("Превышена максимальная дневная просадка: %.2f%% >= %.2f%%. Торговля приостановлена до следующего дня.", 
                    dailyDrawdown, MaxDailyDrawdownPercent);
        tradingHalted = true;
        return false;
    }
    else if (maxEquityToday > 0 && dailyDrawdown >= (MaxDailyDrawdownPercent - DrawdownBuffer))
    {
        PrintFormat("Внимание: дневная просадка приближается к лимиту: %.2f%% (лимит %.2f%%, буфер %.2f%%)", 
                    dailyDrawdown, MaxDailyDrawdownPercent, DrawdownBuffer);
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Проверка лимита убытка за день                                  |
//+------------------------------------------------------------------+
bool CheckDailyLossLimit()
{
    if(!UseDailyLossLimit) return true;
    if(tradingHalted) return false;
    
    double todayProfit = totalProfitToday;
    if(todayProfit >= 0) return true;
    
    double loss = -todayProfit;
    if(loss >= dailyLossLimit)
    {
        double atr = GetIndicatorValue(atrHandle);
        PrintFormat("Достигнут лимит убытка за день: %.2f >= %.2f. Текущий ATR: %.2f. Торговля остановлена до следующего дня.",
                    loss, dailyLossLimit, atr);
        tradingHalted = true;
        EventSetTimer(3600); // Авто-восстановление через 1 час
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Проверка размера позиции                                        |
//+------------------------------------------------------------------+
bool CheckPositionSize(double lotSize, double price)
{
    if(!UsePositionSizeLimit) return true;
    
    // Рассчитываем стоимость позиции в валюте депозита
    double margin_required;
    if(!OrderCalcMargin(
        ORDER_TYPE_BUY, // тип для расчета (не влияет на стоимость)
        _Symbol,
        lotSize,
        price,
        margin_required
    )) {
        Print("Ошибка расчета маржи: ", GetLastError());
        return true; // Разрешить сделку при ошибке
    }
    
    // Рассчитываем допустимый лимит
    double max_allowed_percent = MaxPositionSizePercent;
    double max_allowed_margin = accountInfo.Equity() * (max_allowed_percent / 100.0);
    
    // Проверяем превышение
    if(margin_required > max_allowed_margin)
    {
        // Проверяем, можно ли проигнорировать для минимального лота на микро-счете
        if (IgnoreMarginLimitForMinLot && internalMicroMode && 
            lotSize <= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
        {
            PrintFormat("Предупреждение: минимальный лот (%.2f) требует маржи (%.2f %s), что превышает лимит (%.2f %s, %.1f%%). Разрешено по настройке.",
                        lotSize, margin_required, accountInfo.Currency(),
                        max_allowed_margin, accountInfo.Currency(), max_allowed_percent);
            return true;
        }
        else
        {
            PrintFormat("Стоимость позиции превышена: %.2f %s > %.2f %s (%.1f%% от эквити)",
                margin_required, accountInfo.Currency(),
                max_allowed_margin, accountInfo.Currency(),
                max_allowed_percent
            );
            return false;
        }
    }
    return true;
}

//+------------------------------------------------------------------+
//| Квантовый адаптивный трейлинг-стоп                              |
//+------------------------------------------------------------------+
void ApplyQuantumTrailing()
{
    if(!UseQuantumTrailing) 
    {
        static int tickCount = 0;
        if(tickCount % 100 == 0) Print("Квантовый трейлинг-стоп отключен");
        tickCount++;
        return;
    }
    
    // Ограничение частоты модификаций
    if(TimeCurrent() - lastTrailTime < 30) return;
    
    double atr = GetIndicatorValue(atrHandle);
    if(atr <= 0) 
    {
        Print("Ошибка получения ATR для трейлинг-стопа");
        return;
    }
    
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double chaos = CalculateChaos();
    
    // Рассчитываем динамический множитель
    double trailMultiplier = internalBaseTrailATRMultiplier + 
                           (MaxTrailATRMultiplier - internalBaseTrailATRMultiplier) * 
                           MathMin(1.0, chaos * ChaosSensitivity + 
                                   quantumState * QuantumStateInfluence / internalQuantumStates);
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) 
        {
            Print("Ошибка получения билета позиции. Код: ", GetLastError());
            continue;
        }
        
        string symbol = PositionGetString(POSITION_SYMBOL);
        if(symbol != _Symbol) continue;

        double currentSl = PositionGetDouble(POSITION_SL);
        double positionOpen = PositionGetDouble(POSITION_PRICE_OPEN);
        int positionType = (int)PositionGetInteger(POSITION_TYPE);
        double currentPrice = (positionType == POSITION_TYPE_BUY) ? currentBid : currentAsk;
        
        // Рассчитываем активационный уровень
        double activationLevel = positionType == POSITION_TYPE_BUY ? 
            positionOpen + TrailActivationProfit * atr : 
            positionOpen - TrailActivationProfit * atr;
        
        // Рассчитываем целевой стоп
        double proposedSl = positionType == POSITION_TYPE_BUY ? 
            currentBid - trailMultiplier * atr : 
            currentAsk + trailMultiplier * atr;
        
        // Квантовая коррекция
        double stateCorrection = (quantumState - internalQuantumStates/2.0) * atr * 0.05;
        proposedSl += positionType == POSITION_TYPE_BUY ? -stateCorrection : stateCorrection;
        
        // Адаптивная защита
        double minAllowedDistance = MathMax(
            SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point,
            atr * 0.3
        );
        
        // Проверка активации
        if((positionType == POSITION_TYPE_BUY && currentPrice < activationLevel) ||
           (positionType == POSITION_TYPE_SELL && currentPrice > activationLevel))
        {
            continue;
        }
        
        // Проверка минимального изменения (минимум 3 пункта)
        double minChange = 3 * point;
        if(MathAbs(proposedSl - currentSl) < minChange) 
        {
            PrintFormat("Изменение SL слишком мало: %.5f->%.5f. Пропускаем", currentSl, proposedSl);
            continue;
        }
        
        // Проверка улучшения позиции
        bool canModify = false;
        if(positionType == POSITION_TYPE_BUY)
        {
            if(proposedSl > currentSl && proposedSl < currentBid - minAllowedDistance)
            {
                canModify = true;
            }
        }
        else
        {
            if(proposedSl < currentSl && proposedSl > currentAsk + minAllowedDistance)
            {
                canModify = true;
            }
        }
        
        if(canModify)
        {
            // Фильтр волатильности
            double priceChange = MathAbs(currentPrice - positionOpen);
            if(priceChange < atr * 0.3) continue;
            
            // Дополнительная проверка на минимальное расстояние
            if(!CheckStopLossTakeprofit(positionType, currentPrice, proposedSl, PositionGetDouble(POSITION_TP)))
            {
                Print("Новый SL не прошел проверку. Отмена модификации.");
                continue;
            }
            
            // Проверка изменения параметров
            if(MathAbs(proposedSl - lastTrailSl) < 10*point && MathAbs(currentPrice - lastTrailPrice) < 10*point)
                continue;
                
            // Модифицируем стоп
            double newSl = NormalizePrice(proposedSl);
            if(trade.PositionModify(ticket, newSl, PositionGetDouble(POSITION_TP)))
            {
                // Обновление квантового состояния
                quantumState = (quantumState + 1) % internalQuantumStates;
                
                PrintFormat("Трейлинг-стоп обновлен: Тип=%s, Старый SL=%.5f, Новый SL=%.5f",
                            EnumToString((ENUM_POSITION_TYPE)positionType), currentSl, newSl);
                            
                // Обновляем время последней модификации
                lastTrailTime = TimeCurrent();
                lastTrailSl = newSl;
                lastTrailPrice = currentPrice;
            }
            else
            {
                uint errorCode = GetLastError();
                Print("Ошибка модификации трейлинг-стопа: ", ErrorDescription(errorCode));
                
                // Специальная обработка ошибки "Invalid stops"
                if(errorCode == 4756)
                {
                    double adjustedSl = newSl + (positionType==POSITION_TYPE_BUY ? -point : point);
                    adjustedSl = NormalizePrice(adjustedSl);
                    
                    if(CheckStopLossTakeprofit(positionType, currentPrice, adjustedSl, PositionGetDouble(POSITION_TP)))
                    {
                        if(trade.PositionModify(ticket, adjustedSl, PositionGetDouble(POSITION_TP)))
                        {
                            Print("SL скорректирован на 1 пункт");
                            lastTrailTime = TimeCurrent();
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Жесткий стоп-лосс для всех позиций                              |
//+------------------------------------------------------------------+
void CheckHardStop()
{
    if(!UseHardStop) return;
    
    double equity = accountInfo.Equity();
    double balance = accountInfo.Balance();
    double drawdown = (balance - equity) / balance * 100.0;
    
    if(drawdown >= HardStopLevel)
    {
        PrintFormat("Активирован жесткий стоп! Просадка: %.2f%% >= %.2f%%", 
                    drawdown, HardStopLevel);
        
        // Закрываем все позиции
        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                trade.PositionClose(ticket);
            }
        }
        
        // Отправляем уведомление
        SendNotification("QuantumTrader: Активирован жесткий стоп! Все позиции закрыты.");
        
        // Останавливаем советник
        ExpertRemove();
    }
}

//+------------------------------------------------------------------+
//| Расчет размера позиции с учетом маржи                            |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent, double price, double slDistance)
{
    double balance = accountInfo.Balance();
    double riskAmount = balance * (riskPercent / 100.0);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    if(slDistance == 0 || tickValue == 0) return minLot;

    // Базовый расчет лота
    double lotSize = riskAmount / (slDistance / SymbolInfoDouble(_Symbol, SYMBOL_POINT) * tickValue);
    lotSize = MathRound(lotSize / volumeStep) * volumeStep;
    
    // Ограничения по мин/макс лоту
    lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
    lotSize = MathMax(lotSize, minLot);
    lotSize = NormalizeDouble(lotSize, 2);

    // Проверка доступности маржи
    double marginRequired;
    if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, marginRequired))
    {
        double freeMargin = accountInfo.FreeMargin();
        
        // Постепенное уменьшение лота при недостатке маржи
        while(marginRequired > freeMargin && lotSize > minLot)
        {
            lotSize = NormalizeDouble(lotSize - volumeStep, 2);
            if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, marginRequired)) break;
        }
        
        // Если даже минимальный лот недоступен
        if(marginRequired > freeMargin)
        {
            // Для микро-счета: если разрешено игнорировать лимит для минимального лота, попробуем минимальный лот
            if(internalMicroMode && IgnoreMarginLimitForMinLot)
            {
                if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, minLot, price, marginRequired))
                {
                    if(marginRequired <= freeMargin)
                    {
                        return minLot;
                    }
                }
            }
            PrintFormat("Недостаточно маржи для минимального лота %.2f. Требуется: %.2f %s, Свободно: %.2f %s",
                        minLot, marginRequired, accountInfo.Currency(),
                        freeMargin, accountInfo.Currency());
            return -1;
        }
    }
    return lotSize;
}

//+------------------------------------------------------------------+
//| Запуск автооптимизации в тестере                                |
//+------------------------------------------------------------------+
void RunAutoOptimization()
{
    if(!MQLInfoInteger(MQL_TESTER) || !AutoOptimizeInTester) 
        return;

    Print("Запуск автооптимизации...");
    
    // Список оптимизируемых параметров
    string params[] = {
        "QuantumStates", "QuantumDecayRate", "StateUpdateRate", "StateMemoryFactor",
        "RSIPeriod", "ADXPeriod", "ATRPeriod", "FastMAPeriod", "SlowMAPeriod",
        "BaseRisk", "ATRMultiplierSL", "TPtoSLRatio"
    };
    
    // Случайный поиск лучших параметров
    ArrayResize(bestParams, ArraySize(params));
    double bestResult = -DBL_MAX;
    
    for(int pass = 0; pass < OptimizationPasses; pass++)
    {
        // Генерация случайных параметров
        internalQuantumStates = MathRand() % 46 + 5; // 5-50
        internalQuantumDecayRate = MathRand()/32767.0*0.09 + 0.01; // 0.01-0.1
        internalStateUpdateRate = MathRand()/32767.0*0.25 + 0.05; // 0.05-0.3
        internalStateMemoryFactor = MathRand()/32767.0*0.19 + 0.8; // 0.8-0.99
        internalRSIPeriod = MathRand() % 15 + 7; // 7-21
        internalADXPeriod = MathRand() % 16 + 10; // 10-25
        internalATRPeriod = MathRand() % 11 + 10; // 10-20
        internalFastMAPeriod = MathRand() % 81 + 20; // 20-100
        internalSlowMAPeriod = MathRand() % 201 + 100; // 100-300
        internalBaseRisk = MathRand()/32767.0*0.9 + 0.1; // 0.1-1.0
        internalATRMultiplierSL = MathRand()/32767.0*2.0 + 1.0; // 1.0-3.0
        internalTPtoSLRatio = MathRand()/32767.0*1.5 + 1.5; // 1.5-3.0
        
        // Корректируем параметры
        AutoCorrectParameters();
        
        // Запуск теста с текущими параметрами
        double result = OnTester();
        
        // Сохранение лучшего результата
        if(result > bestResult)
        {
            bestResult = result;
            bestParams[0][1] = internalQuantumStates;
            bestParams[1][1] = internalQuantumDecayRate;
            bestParams[2][1] = internalStateUpdateRate;
            bestParams[3][1] = internalStateMemoryFactor;
            bestParams[4][1] = internalRSIPeriod;
            bestParams[5][1] = internalADXPeriod;
            bestParams[6][1] = internalATRPeriod;
            bestParams[7][1] = internalFastMAPeriod;
            bestParams[8][1] = internalSlowMAPeriod;
            bestParams[9][1] = internalBaseRisk;
            bestParams[10][1] = internalATRMultiplierSL;
            bestParams[11][1] = internalTPtoSLRatio;
        }
    }
    
    // Применяем лучшие параметры
    internalQuantumStates = (int)bestParams[0][1];
    internalQuantumDecayRate = bestParams[1][1];
    internalStateUpdateRate = bestParams[2][1];
    internalStateMemoryFactor = bestParams[3][1];
    internalRSIPeriod = (int)bestParams[4][1];
    internalADXPeriod = (int)bestParams[5][1];
    internalATRPeriod = (int)bestParams[6][1];
    internalFastMAPeriod = (int)bestParams[7][1];
    internalSlowMAPeriod = (int)bestParams[8][1];
    internalBaseRisk = bestParams[9][1];
    internalATRMultiplierSL = bestParams[10][1];
    internalTPtoSLRatio = bestParams[11][1];
    
    // Корректируем параметры
    AutoCorrectParameters();
    
    Print("Автооптимизация завершена! Лучший результат: ", bestResult);
    SaveOptimizedParams(); // Сохраняем параметры
    
    optimizationCompleted = true;
}

//+------------------------------------------------------------------+
//| Сохранение оптимизированных параметров                           |
//+------------------------------------------------------------------+
void SaveOptimizedParams()
{
    int handle = FileOpen("OptimizedParams_"+_Symbol+".bin", FILE_WRITE|FILE_BIN);
    if(handle == INVALID_HANDLE) return;
    
    FileWriteInteger(handle, internalQuantumStates);
    FileWriteDouble(handle, internalQuantumDecayRate);
    FileWriteDouble(handle, internalStateUpdateRate);
    FileWriteDouble(handle, internalStateMemoryFactor);
    FileWriteInteger(handle, internalRSIPeriod);
    FileWriteInteger(handle, internalADXPeriod);
    FileWriteInteger(handle, internalATRPeriod);
    FileWriteInteger(handle, internalFastMAPeriod);
    FileWriteInteger(handle, internalSlowMAPeriod);
    FileWriteDouble(handle, internalBaseRisk);
    FileWriteDouble(handle, internalATRMultiplierSL);
    FileWriteDouble(handle, internalTPtoSLRatio);
    
    FileClose(handle);
    Print("Оптимизированные параметры сохранены");
}

//+------------------------------------------------------------------+
//| Загрузка оптимизированных параметров                             |
//+------------------------------------------------------------------+
void LoadOptimizedParams()
{
    int handle = FileOpen("OptimizedParams_"+_Symbol+".bin", FILE_READ|FILE_BIN);
    if(handle == INVALID_HANDLE) return;
    
    internalQuantumStates = FileReadInteger(handle);
    internalQuantumDecayRate = FileReadDouble(handle);
    internalStateUpdateRate = FileReadDouble(handle);
    internalStateMemoryFactor = FileReadDouble(handle);
    internalRSIPeriod = FileReadInteger(handle);
    internalADXPeriod = FileReadInteger(handle);
    internalATRPeriod = FileReadInteger(handle);
    internalFastMAPeriod = FileReadInteger(handle);
    internalSlowMAPeriod = FileReadInteger(handle);
    internalBaseRisk = FileReadDouble(handle);
    internalATRMultiplierSL = FileReadDouble(handle);
    internalTPtoSLRatio = FileReadDouble(handle);
    
    FileClose(handle);
    Print("Оптимизированные параметры загружены");
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    MathSrand(GetTickCount());
    
    // Инициализация внутренних параметров
    internalQuantumStates = QuantumStates;
    internalQuantumDecayRate = QuantumDecayRate;
    internalStateUpdateRate = StateUpdateRate;
    internalStateMemoryFactor = StateMemoryFactor;
    internalRSIPeriod = RSIPeriod;
    internalADXPeriod = ADXPeriod;
    internalATRPeriod = ATRPeriodInput;
    internalFastMAPeriod = FastMAPeriodInput;
    internalSlowMAPeriod = SlowMAPeriodInput;
    internalBaseRisk = BaseRiskInput;
    internalATRMultiplierSL = ATRMultiplierSL;
    internalTPtoSLRatio = TPtoSLRatio;
    internalMinBarsBetweenTrades = MinBarsBetweenTrades;
    internalBaseTrailATRMultiplier = BaseTrailATRMultiplier;
    internalChaosThreshold = ChaosThreshold;
    
    ArrayResize(waveFunction, internalQuantumStates);
    ArrayResize(stateReturns, internalQuantumStates);
    ArrayResize(positionMatrix, internalQuantumStates);
    ArrayInitialize(waveFunction, 1.0/internalQuantumStates);
    ArrayInitialize(stateReturns, 0);
    
    // Автозагрузка параметров
    if(AutoOptimizeInTester && MQLInfoInteger(MQL_TESTER))
        LoadOptimizedParams();
    
    // Корректировка параметров
    AutoCorrectParameters();

    // Переопределение параметров для инструмента
    string symbol = Symbol();
    if (symbol == "XAUUSD" || symbol == "GOLD")
    {
        internalATRMultiplierSL = Gold_ATRMultiplierSL;
        internalTPtoSLRatio = Gold_TPtoSLRatio;
        internalBaseRisk = Gold_BaseRiskInput;
        internalMinBarsBetweenTrades = Gold_MinBarsBetweenTrades;
        internalBaseTrailATRMultiplier = Gold_BaseTrailATRMultiplier;
        internalChaosThreshold = Gold_ChaosThreshold;
    }
    else if (symbol == "XAGUSD" || symbol == "SILVER")
    {
        internalATRMultiplierSL = Silver_ATRMultiplierSL;
        internalTPtoSLRatio = Silver_TPtoSLRatio;
        internalBaseRisk = Silver_BaseRiskInput;
        internalMinBarsBetweenTrades = Silver_MinBarsBetweenTrades;
        internalBaseTrailATRMultiplier = Silver_BaseTrailATRMultiplier;
        internalChaosThreshold = Silver_ChaosThreshold;
    }
    
    InitAISystem();
    lastTradeTime = 0;
    lossCounter = 0;
    lastCacheTime = 0;
    lastTrailTime = 0;
    lastTrailSl = 0;
    lastTrailPrice = 0;
    marginErrorCount = 0;
    lastErrorTime = 0;
    
    // Инициализация системы защиты
    UpdateDailyEquity();
    
    // Для депозита $500 устанавливаем минимальный порог $300
    if(accountInfo.Equity() < 300) 
    {
        tradingHalted = true;
        Print("Депозит ниже $300. Торговля будет остановлена.");
    }
    
    // Автоактивация микро-режима
    internalMicroMode = MicroAccountMode;
    if(accountInfo.Equity() < 500)
    {
        internalMicroMode = true;
        Print("Автоактивация режима микро-счета: депозит < $500");
    }
    
    Print("Советник успешно инициализирован для торговли на ", symbol);
    PrintFormat("Депозит: $%.2f", accountInfo.Equity());
    PrintFormat("Базовый риск: %.1f%%, Макс. риск: %.1f%%", internalBaseRisk, MaxRisk);
    PrintFormat("Макс. размер позиции: %.1f%%", MaxPositionSizePercent);
    PrintFormat("Защита депозита: %s", UseEquityProtection ? "Включена" : "Отключена");
    
    isFirstRun = true;
    optimizationCompleted = false;
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Проверка минимального депозита ($300)
    if(accountInfo.Equity() < 300) 
    {
        Print("СТОП! Депозит ниже $300. Торговля остановлена.");
        tradingHalted = true;
        return;
    }
    
    // Проверка статуса торговли
    if(tradingHalted) 
    {
        static datetime lastAlert = 0;
        if(TimeCurrent() - lastAlert > 3600)
        {
            Print("Торговля приостановлена системой защиты");
            lastAlert = TimeCurrent();
        }
        return;
    }
    
    // Запуск автооптимизации при первом запуске в тестере
    if(isFirstRun && MQLInfoInteger(MQL_TESTER) && AutoOptimizeInTester && !optimizationCompleted)
    {
        RunAutoOptimization();
        isFirstRun = false;
        return; // Пропускаем первый тик после оптимизации
    }
    
    // Применяем квантовый трейлинг-стоп
    ApplyQuantumTrailing();
    
    // Проверяем жесткий стоп
    CheckHardStop();
    
    static datetime lastBarTime = 0;
    datetime currentBarTime = iTime(_Symbol, AnalysisTimeframe, 0);
    
    // Работаем только на открытии нового бара
    if(currentBarTime == lastBarTime) return;
    lastBarTime = currentBarTime;
    
    // Обновляем данные о эквити
    UpdateDailyEquity();
    
    // Проверяем лимиты перед торговлей
    if(!CheckDrawdownLimits()) return;
    if(!CheckDailyLossLimit()) return;
    
    // Генерация сигнала
    int signal = GenerateTradeSignal();
    if(signal < 0) return;
    
    // Защита от частых сделок
    if(TimeCurrent() - lastTradeTime < internalMinBarsBetweenTrades * PeriodSeconds(AnalysisTimeframe)) 
        return;
    
    // Расчет параметров сделки
    double atr = lastATR;
    double price = (signal == ORDER_TYPE_BUY) ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Расчет SL и TP
    double sl = (signal == ORDER_TYPE_BUY) ? 
         price - atr * internalATRMultiplierSL : 
         price + atr * internalATRMultiplierSL;
    
    double tp = (signal == ORDER_TYPE_BUY) ? 
         price + atr * internalTPtoSLRatio : 
         price - atr * internalTPtoSLRatio;
    
    // Гарантируем минимальное расстояние для TP
    double minTpDistance = atr * 0.5; // 50% от ATR
    if(MathAbs(price - tp) < minTpDistance)
    {
        tp = (signal == ORDER_TYPE_BUY) ? 
             price + minTpDistance : 
             price - minTpDistance;
        PrintFormat("Коррекция TP: Установлено минимальное расстояние %.2f пунктов", minTpDistance);
    }
    
    // Нормализация цен
    price = NormalizePrice(price);
    sl = NormalizePrice(sl);
    tp = NormalizePrice(tp);
    
    // Проверка корректности SL/TP
    double checkPrice = (signal == ORDER_TYPE_BUY) ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    if(!CheckStopLossTakeprofit(signal == ORDER_TYPE_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL, 
                               checkPrice, sl, tp))
    {
        Print("Некорректные уровни SL/TP. Сделка отклонена.");
        return;
    }
    
    // Адаптивный риск
    currentRisk = CalculateAdaptiveRisk();
    
    // Расчет размера позиции с учетом маржи
    double slDistance = MathAbs(price - sl);
    double lotSize = CalculateLotSize(currentRisk, price, slDistance);
    
    // Проверка на ошибку расчета
    if(lotSize < 0)
    {
        Print("Сделка невозможна: недостаточно маржи даже для минимального лота");
        marginErrorCount++;
        lastErrorTime = TimeCurrent();
        
        if(marginErrorCount >= 3)
        {
            tradingHalted = true;
            Print("Торговля приостановлена: 3 подряд ошибки маржи");
            EventSetTimer(3600); // Автоматическое возобновление через 1 час
        }
        return;
    }
    else
    {
        marginErrorCount = 0; // Сброс счетчика при успешном расчете
    }
    
    // Дополнительная проверка для микро-счетов
    if(internalMicroMode)
    {
        double maxMicroLot = accountInfo.FreeMargin() / (price * 0.01); // Упрощенный расчет
        if(lotSize > maxMicroLot)
        {
            lotSize = MathMin(lotSize, maxMicroLot);
            PrintFormat("Коррекция лота для микро-счета: %.2f", lotSize);
        }
    }
    
    // Финальная проверка перед открытием
    double marginCheck = accountInfo.MarginCheck(_Symbol, 
        (signal == ORDER_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
        lotSize, price);
        
    if(marginCheck > accountInfo.FreeMargin())
    {
        Print("Ошибка маржи: требуется ", marginCheck, " ", accountInfo.Currency(), 
              ", доступно ", accountInfo.FreeMargin());
        return;
    }
    
    // Проверка размера позиции
    if(!CheckPositionSize(lotSize, price))
    {
        Print("Размер позиции превышает установленные лимиты. Сделка отклонена.");
        return;
    }
    
    // Открытие позиции
    bool success = false;
    if(signal == ORDER_TYPE_BUY)
        success = trade.Buy(lotSize, _Symbol, price, sl, tp, "Quantum AI Buy");
    else
        success = trade.Sell(lotSize, _Symbol, price, sl, tp, "Quantum AI Sell");

    if(success) 
    {
        lastTradeTime = TimeCurrent();
        PrintFormat("Сделка: %s Лот: %.2f Риск: %.1f%% ATR: %.2f",
                    EnumToString((ENUM_ORDER_TYPE)signal),
                    lotSize,
                    currentRisk,
                    atr);
        
        // Ежедневный отчет
        MqlDateTime timeStruct;
        TimeCurrent(timeStruct);
        if(timeStruct.hour == 8)
        {
            double equity = accountInfo.Equity();
            double riskPerTrade = equity * (currentRisk/100);
            SendNotification("QuantumTrader: Депозит="+DoubleToString(equity,2)+
                             " | Риск/сделку="+DoubleToString(riskPerTrade,2));
        }
    }
    else
    {
        uint errorCode = GetLastError();
        Print("Ошибка открытия ордера: Код ", errorCode, " - ", ErrorDescription(errorCode));
        currentRisk = MathMax(0.1, currentRisk * RiskDecreaseFactor);
    }
    
    isFirstRun = false;
}

//+------------------------------------------------------------------+
//| Обработчик таймера                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    if(tradingHalted)
    {
        // Снижаем риск на 30% при восстановлении
        currentRisk = MathMax(0.1, currentRisk * 0.7);
        tradingHalted = false;
        marginErrorCount = 0;
        Print("Торговля возобновлена. Риск снижен до ", currentRisk, "%");
    }
}

//+------------------------------------------------------------------+
//| Обновление системы после сделки                                  |
//+------------------------------------------------------------------+
void OnTrade()
{
    if(HistoryDealSelect(HistoryDealsTotal()-1))
    {
        double profit = HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1), DEAL_PROFIT);
        int type = (int)HistoryDealGetInteger(HistoryDealGetTicket(HistoryDealsTotal()-1), DEAL_TYPE);
        int signal = (type == DEAL_TYPE_BUY) ? 1 : -1;
        
        UpdateAI(signal, profit);
        
        // Обновление квантовых состояний
        stateReturns[quantumState] = stateReturns[quantumState] * internalStateMemoryFactor 
                                   + profit * internalStateUpdateRate;
        
        // Адаптация риска
        if(profit < 0) 
        {
            lossCounter++;
            if(lossCounter >= MaxConsecutiveLosses) 
                currentRisk = MathMax(0.1, currentRisk * RiskDecreaseFactor);
        }
        else
        {
            lossCounter = 0;
            currentRisk = MathMin(MaxRisk, currentRisk * RiskIncreaseFactor);
        }
        
        // Обновляем данные о дневной прибыли
        UpdateDailyEquity();
    }
}

//+------------------------------------------------------------------+
//| Tester function with automatic 70/30 OOS validation              |
//+------------------------------------------------------------------+
double OnTester()
{
    HistorySelect(0, TimeCurrent());
    int total_deals = HistoryDealsTotal();
    if(total_deals <= 0) return 0;

    datetime first_deal_time = (datetime)HistoryDealGetInteger(HistoryDealGetTicket(0), DEAL_TIME);
    datetime last_deal_time = (datetime)HistoryDealGetInteger(HistoryDealGetTicket(total_deals-1), DEAL_TIME);
    
    datetime IS_end = first_deal_time + (datetime)((last_deal_time - first_deal_time) * 0.7);
    datetime OOS_start = IS_end + 1;
    datetime OOS_end = last_deal_time;
    
    if(OOS_start >= last_deal_time) {
        Print("Warning: OOS period too small. Using last 30% of data.");
        OOS_start = first_deal_time + (datetime)((last_deal_time - first_deal_time) * 0.7);
        OOS_end = last_deal_time;
    }

    double deposit = 10000;
    double balance = deposit;
    double max_balance = deposit;
    
    double IS_dd = 0;
    double IS_profit = 0;
    double IS_positive = 0, IS_negative = 0;
    int IS_trades = 0;
    double IS_max_profit = -DBL_MAX, IS_min_profit = DBL_MAX;
    
    double OOS_dd = 0;
    double OOS_profit = 0;
    double OOS_positive = 0, OOS_negative = 0;
    int OOS_trades = 0;
    double OOS_max_profit = -DBL_MAX, OOS_min_profit = DBL_MAX;
    
    for(int i = 0; i < total_deals; i++)
    {
        ulong ticket = HistoryDealGetTicket(i);
        if(ticket == 0) continue;
        
        datetime time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
        double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
        double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
        double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
        double total = profit + commission + swap;
        
        balance += total;
        
        if(balance > max_balance) max_balance = balance;
        double dd = max_balance - balance;
        
        if(time <= IS_end)
        {
            IS_trades++;
            IS_profit += total;
            
            if(total > 0) IS_positive += total;
            else IS_negative -= total;
            
            if(total > IS_max_profit) IS_max_profit = total;
            if(total < IS_min_profit) IS_min_profit = total;
            
            if(dd > IS_dd) IS_dd = dd;
        }
        else if(time >= OOS_start && time <= OOS_end)
        {
            OOS_trades++;
            OOS_profit += total;
            
            if(total > 0) OOS_positive += total;
            else OOS_negative -= total;
            
            if(total > OOS_max_profit) OOS_max_profit = total;
            if(total < OOS_min_profit) OOS_min_profit = total;
            
            if(dd > OOS_dd) OOS_dd = dd;
        }
    }
    
    double IS_pf = (IS_negative > 0) ? IS_positive / IS_negative : 100;
    double IS_rf = (IS_dd > 0) ? IS_profit / IS_dd : IS_profit * 100;
    double IS_win_rate = (IS_trades > 0) ? (double)IS_positive/(IS_positive+IS_negative) : 0;
    double IS_avg_win = (IS_positive > 0 && IS_win_rate > 0) ? IS_positive/(IS_trades * IS_win_rate) : 0;
    double IS_avg_loss = (IS_negative > 0 && (1-IS_win_rate) > 0) ? IS_negative/(IS_trades * (1-IS_win_rate)) : 0;
    double IS_payoff = (IS_avg_loss != 0) ? IS_avg_win/IS_avg_loss : 10;
    double IS_sharpe = (IS_avg_loss > 0) ? (IS_avg_win - IS_avg_loss) / MathSqrt(0.5*(IS_avg_win*IS_avg_win + IS_avg_loss*IS_avg_loss)) : 10;
    
    double OOS_pf = (OOS_negative > 0) ? OOS_positive / OOS_negative : 100;
    double OOS_rf = (OOS_dd > 0) ? OOS_profit / OOS_dd : OOS_profit * 100;
    double OOS_win_rate = (OOS_trades > 0) ? (double)OOS_positive/(OOS_positive+OOS_negative) : 0;
    double OOS_avg_win = (OOS_positive > 0 && OOS_win_rate > 0) ? OOS_positive/(OOS_trades * OOS_win_rate) : 0;
    double OOS_avg_loss = (OOS_negative > 0 && (1-OOS_win_rate) > 0) ? OOS_negative/(OOS_trades * (1-OOS_win_rate)) : 0;
    double OOS_payoff = (OOS_avg_loss != 0) ? OOS_avg_win/OOS_avg_loss : 10;
    double OOS_sharpe = (OOS_avg_loss > 0) ? (OOS_avg_win - OOS_avg_loss) / MathSqrt(0.5*(OOS_avg_win*OOS_avg_win + OOS_avg_loss*OOS_avg_loss)) : 10;
    
    if(OOS_trades < 20) return -1e9;
    if(OOS_profit <= 0) return -1e8;
    if(IS_profit <= 0) return -1e7;
    if(OOS_rf < 1.0) return -1e6;
    
    double score = 0;
    
    score += 15.0 * MathLog(OOS_rf + 1);
    score += 10.0 * MathLog(OOS_pf + 1);
    score += 7.5 * MathLog(OOS_sharpe + 1);
    score += 7.5 * MathLog(OOS_payoff + 1);
    
    double consistency = 1.0;
    consistency *= 0.7 + 0.3 * MathMin(OOS_win_rate / IS_win_rate, 1.5);
    consistency *= 0.7 + 0.3 * MathMin(OOS_payoff / IS_payoff, 1.5);
    consistency *= 0.7 + 0.3 * MathMin(OOS_rf / IS_rf, 1.5);
    score += 30.0 * consistency;
    
    double stability = 1.0;
    stability -= 0.2 * MathAbs(IS_win_rate - OOS_win_rate);
    stability -= 0.2 * MathAbs(IS_payoff - OOS_payoff);
    stability -= 0.1 * MathAbs(IS_sharpe - OOS_sharpe);
    stability -= 0.1 * (OOS_max_profit - OOS_min_profit) / (OOS_avg_win + OOS_avg_loss);
    score += 20.0 * MathMax(0, stability);
    
    double risk_penalty = 1.0;
    risk_penalty -= 0.3 * MathMin(1.0, OOS_dd / deposit);
    risk_penalty -= 0.2 * MathMin(1.0, (OOS_max_profit - OOS_min_profit) / (OOS_avg_win + OOS_avg_loss));
    score *= MathMax(0.5, risk_penalty);
    
    score *= 1.0 + 0.1 * MathLog(1 + OOS_trades);
    
    return score;
}

//+------------------------------------------------------------------+
//| Функция деинициализации                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Сохранение состояния ИИ
    string fileName = "QuantumAI_"+_Symbol+".txt";
    int handle = FileOpen(fileName, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(handle != INVALID_HANDLE)
    {
        for(int i = 0; i < 6; i++)
            FileWrite(handle, DoubleToString(aiWeights[i], 8));
        FileClose(handle);
        Print("Весы ИИ успешно сохранены");
    }
    else
    {
        Print("Ошибка сохранения весов ИИ: ", GetLastError());
    }
    
    // Сохранение оптимизированных параметров
    if(optimizationCompleted && AutoOptimizeInTester && MQLInfoInteger(MQL_TESTER))
    {
        SaveOptimizedParams();
    }
    
    // Освобождение хэндлов индикаторов
    if(rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
    if(adxHandle != INVALID_HANDLE) IndicatorRelease(adxHandle);
    if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
    if(maFastHandle != INVALID_HANDLE) IndicatorRelease(maFastHandle);
    if(maSlowHandle != INVALID_HANDLE) IndicatorRelease(maSlowHandle);
    
    // Сохраняем состояние защиты
    if(reason == REASON_INITFAILED || reason == REASON_PROGRAM)
    {
        Print("Советник остановлен по защите. Требуется перезапуск вручную.");
    }
    
    // Удаление таймера
    EventKillTimer();
}
//+------------------------------------------------------------------+