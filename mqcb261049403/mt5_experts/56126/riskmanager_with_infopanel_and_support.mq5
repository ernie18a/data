//+----------------------------------------------------------------------+
//|    RiskManager_with_InfoPanel_and_Support_noDLL.mq5                  |
//|Объединённый эксперт: информационная панель с фоновым прямоугольником |
//| без использования DLL                                                |
//|                                                                      |
//| Автор: YourName                                                      |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.02"
#property strict

#include <Trade\Trade.mqh>

// Удалён импорт DLL и функция OpenURL

//======================================================================
// ВХОДНЫЕ ПАРАМЕТРЫ РИСК-МЕНЕДЖМЕНТА
//======================================================================
input double RiskPercent         = 1.0;      
input double EntryPrice          = 1.1000;   
input double StopLossPercent     = 0.2;      
input double TakeProfitPercent   = 0.5;      
input double MaxDailyRiskPercent = 2.0;      

//======================================================================
// ПАРАМЕТРЫ ОФОРМЛЕНИЯ ИНФОПАНЕЛИ
//======================================================================
input int    UpdateIntervalSeconds = 10;         
input int    InfoPanelXDistance    = 10;          
input int    InfoPanelYDistance    = 10;          
input int    InfoPanelWidth        = 350;         
input int    InfoPanelHeight       = 300;         
input int    InfoPanelFontSize     = 12;          
input string InfoPanelFontName     = "Arial";     
input color  InfoPanelFontColor    = clrWhite;    
input color  InfoPanelBackColor    = clrDarkGray; 

//======================================================================
// ПАРАМЕТРЫ ПАНЕЛИ ПОДДЕРЖКИ ПРОЕКТА
// Если хотите оставить кнопку поддержки, оставьте ее, 
// но удалите из OnChartEvent вызов функции открытия URL
//======================================================================
input bool   UseSupportPanel       = true;       
input string SupportPanelText      = "Поддержи проект, зарегистрируйся!";
input color  SupportPanelFontColor = clrRed;   
input int    SupportPanelFontSize  = 10;          
input string SupportPanelFontName  = "Arial";     
input int    SupportPanelXDistance = 10;          
input int    SupportPanelYDistance = 320;         
input int    SupportPanelXSize     = 250;         
input int    SupportPanelYSize     = 30;          

//======================================================================
// ИМЕНА ОБЪЕКТОВ НА ГРАФИКЕ
//======================================================================
string RiskPanelBgName   = "RiskManagerInfoBg";
string RiskPanelName     = "RiskManagerInfo";
string SupportButtonName = "SupportButton";

//======================================================================
// ГЛОБАЛЫЕ ПЕРЕМЕННЫЕ
//======================================================================
datetime lastUpdate = 0;

//======================================================================
// Функции CalculateLotSize, GetDailyProfit, BuildRiskPanelText
// оставляем без изменений (как в предыдущих примерах)
//======================================================================
double CalculateLotSize(double entry, double computedSL)
{
   double equity    = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * (RiskPercent / 100.0);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double riskPips  = MathAbs(entry - computedSL) / tick_size;
   double tickValue      = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double pipValuePerLot = tickValue / tick_size;
   double riskPerLot = riskPips * pipValuePerLot;
   if(riskPerLot <= 0) return 0;
   double lots = riskMoney / riskPerLot;
   return(lots);
}

double GetDailyProfit()
{
   double profit = 0.0;
   int totalDeals = HistoryDealsTotal();
   MqlDateTime dealTime, currentTime;
   TimeToStruct(TimeCurrent(), currentTime);
   for(int i = 0; i < totalDeals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      datetime dealTimeRaw = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      TimeToStruct(dealTimeRaw, dealTime);
      if(dealTime.year == currentTime.year &&
         dealTime.mon  == currentTime.mon  &&
         dealTime.day  == currentTime.day)
      {
         profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
      }
   }
   return(profit);
}

string BuildRiskPanelText()
{
   string txt;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit  = AccountInfoDouble(ACCOUNT_PROFIT);
   string login   = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   datetime curTime = TimeCurrent();
   string timeStr   = TimeToString(curTime, TIME_MINUTES);
   txt  = "Risk Manager for " + _Symbol + "\r\n";
   txt += "-----------------------------\r\n";
   txt += "Счет: "      + login          + "\r\n";
   txt += "Баланс: $"   + DoubleToString(balance,2) + "\r\n";
   txt += "Эквити: $"   + DoubleToString(equity,2)  + "\r\n";
   txt += "Прибыль: $"  + DoubleToString(profit,2)  + "\r\n";
   txt += "Время: "     + timeStr        + "\r\n\r\n";
   txt += "Risk/Trade: " + DoubleToString(RiskPercent,2) + "%\r\n";
   txt += "Entry Price: " + DoubleToString(EntryPrice, _Digits) + "\r\n";
   double computedSL = EntryPrice - (EntryPrice * (StopLossPercent / 100.0));
   double computedTP = EntryPrice + (EntryPrice * (TakeProfitPercent / 100.0));
   txt += "Stop Loss: "  + DoubleToString(computedSL, _Digits) + " (" + DoubleToString(StopLossPercent,2) + "%)\r\n";
   txt += "Take Profit: "+ DoubleToString(computedTP, _Digits) + " (" + DoubleToString(TakeProfitPercent,2) + "%)\r\n\r\n";
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double riskPips  = MathAbs(EntryPrice - computedSL) / tick_size;
   txt += "Distance (pips): " + DoubleToString(riskPips,1) + "\r\n";
   double riskMoney = equity * (RiskPercent / 100.0);
   txt += "Risk ($): " + DoubleToString(riskMoney,2) + "\r\n";
   double lots = CalculateLotSize(EntryPrice, computedSL);
   txt += "Recommended Lot Size: " + DoubleToString(lots,2) + "\r\n";
   if(TakeProfitPercent > 0)
   {
      double rewardPips = MathAbs(computedTP - EntryPrice) / tick_size;
      string rr = (riskPips > 0) ? DoubleToString(rewardPips / riskPips,2) : "N/A";
      txt += "Reward:Risk Ratio: " + rr + "\r\n\r\n";
   }
   double dailyProfit    = GetDailyProfit();
   double dailyRiskLimit = equity * (MaxDailyRiskPercent / 100.0);
   txt += "Daily P/L: $" + DoubleToString(dailyProfit,2) + "\r\n";
   txt += "Daily Risk Limit: $" + DoubleToString(dailyRiskLimit,2) + "\r\n";
   if(dailyProfit < -dailyRiskLimit)
      txt += "\r\n*** DAILY RISK LIMIT EXCEEDED! Trading suspended.";
   return(txt);
}

//======================================================================
// ФУНКЦИЯ: CreateRiskPanelBackground
// Создаёт фоновый объект в виде прямоугольника для информационной панели
//======================================================================
void CreateRiskPanelBackground()
{
   if(ObjectFind(0, RiskPanelBgName) < 0)
   {
      if(!ObjectCreate(0, RiskPanelBgName, OBJ_RECTANGLE, 0, 0, 0))
      {
         Print("Ошибка создания фона информационной панели!");
         return;
      }
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_XDISTANCE, InfoPanelXDistance - 5);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_YDISTANCE, InfoPanelYDistance - 5);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_XSIZE, InfoPanelWidth + 10);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_YSIZE, InfoPanelHeight + 10);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_COLOR, InfoPanelBackColor);
      ObjectSetInteger(0, RiskPanelBgName, OBJPROP_SELECTABLE, false);
   }
}

//======================================================================
// ФУНКЦИЯ: UpdateRiskPanel
// Обновляет фон и текст информационной панели
//======================================================================
void UpdateRiskPanel()
{
   string txt = BuildRiskPanelText();
   CreateRiskPanelBackground();
   if(ObjectFind(0, RiskPanelName) < 0)
   {
      if(!ObjectCreate(0, RiskPanelName, OBJ_TEXT, 0, 0, 0))
      {
         Print("Ошибка создания текстовой панели!");
         return;
      }
      ObjectSetInteger(0, RiskPanelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, RiskPanelName, OBJPROP_XDISTANCE, InfoPanelXDistance);
      ObjectSetInteger(0, RiskPanelName, OBJPROP_YDISTANCE, InfoPanelYDistance);
      ObjectSetInteger(0, RiskPanelName, OBJPROP_FONTSIZE, InfoPanelFontSize);
      ObjectSetString (0, RiskPanelName, OBJPROP_FONT, InfoPanelFontName);
      ObjectSetInteger(0, RiskPanelName, OBJPROP_COLOR, InfoPanelFontColor);
      ObjectSetInteger(0, RiskPanelName, OBJPROP_SELECTABLE, false);
   }
   ObjectSetString(0, RiskPanelName, OBJPROP_TEXT, txt);
   ChartRedraw();
}

//======================================================================
// ФУНКЦИЯ: UpdateSupportButton
// Обновляет (или создаёт) кнопку поддержки проекта
//======================================================================
void UpdateSupportButton()
{
   if(UseSupportPanel)
   {
      if(ObjectFind(0, SupportButtonName) < 0)
      {
         if(!ObjectCreate(0, SupportButtonName, OBJ_BUTTON, 0, 0, 0))
         {
            Print("Ошибка создания кнопки поддержки!");
            return;
         }
         ObjectSetInteger(0, SupportButtonName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_XDISTANCE, SupportPanelXDistance);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_YDISTANCE, SupportPanelYDistance);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_FONTSIZE, SupportPanelFontSize);
         ObjectSetString (0, SupportButtonName, OBJPROP_FONT, SupportPanelFontName);
         ObjectSetString (0, SupportButtonName, OBJPROP_TEXT, SupportPanelText);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_COLOR, SupportPanelFontColor);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_BORDER_TYPE, BORDER_RAISED);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_XSIZE, SupportPanelXSize);
         ObjectSetInteger(0, SupportButtonName, OBJPROP_YSIZE, SupportPanelYSize);
      }
   }
   else
   {
      if(ObjectFind(0, SupportButtonName) >= 0)
         ObjectDelete(0, SupportButtonName);
   }
}

//======================================================================
// Обработчик событий графика (OnChartEvent)
// Если нужна дополнительная логика для кнопки поддержки, добавьте её
//======================================================================
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == SupportButtonName)
   {
      // Без DLL-открытия URL – можно вывести сообщение или реализовать иным способом
      Print("Нажата кнопка поддержки. Откройте ссылку вручную: https://partner.bybit.com/b/forexmt5");
   }
}

//======================================================================
// Функция OnTimer – обновляет панель и кнопку поддержки
//======================================================================
void OnTimer()
{
   UpdateRiskPanel();
   UpdateSupportButton();
   lastUpdate = TimeCurrent();
}

//======================================================================
// Функция OnInit – инициализация эксперта, создание объектов и запуск таймера
//======================================================================
int OnInit()
{
   Print("RiskManager_with_InfoPanel_and_Support_noDLL: Инициализация");
   lastUpdate = TimeCurrent();
   UpdateRiskPanel();
   UpdateSupportButton();
   EventSetTimer(UpdateIntervalSeconds);
   return(INIT_SUCCEEDED);
}

//======================================================================
// Функция OnDeinit – деинициализация эксперта, удаление объектов и остановка таймера
//======================================================================
void OnDeinit(const int reason)
{
   ObjectDelete(0, RiskPanelBgName);
   ObjectDelete(0, RiskPanelName);
   ObjectDelete(0, SupportButtonName);
   EventKillTimer();
   Print("RiskManager_with_InfoPanel_and_Support_noDLL: Деинициализация");
}

//======================================================================
// Функция OnTick – дополнительная логика (при необходимости)
//======================================================================
void OnTick()
{
   // Обновление производится через OnTimer()
}