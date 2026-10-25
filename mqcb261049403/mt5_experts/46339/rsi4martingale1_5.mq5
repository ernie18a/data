//+------------------------------------------------------------------+
//|                                               RSI&Martingale.mq5 |
//|                                          Copyright 2023, Daodzin |
//|                            https://www.mql5.com/ru/users/daodzin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Daodzin"
#property link      "https://www.mql5.com/ru/users/daodzin"
#property version   "1.05"


#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Indicators\Indicator.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\SymbolInfo.mqh>
CDealInfo m_deal;
CTrade trade;
CPositionInfo positionInfo;
CSymbolInfo    m_symbol;                     // object of CSymbolInfo class

// General Settings
input string GeneralSettings = "---- General Settings ----"; // ---- General Settings ----
input int MagicNumber = 12345; // Unique identifier for the EA's orders
input double InitialLot = 1; // Initial lot size for the first trade
input int MaxSpread = 10; // Maximum acceptable spread in points
input int MaxSlippage = 3; // Maximum acceptable slippage in points

// Indicator Settings
input string IndicatorSettings = "---- Indicator Settings ----"; // ---- Indicator Settings ----
input int RSI_Period = 14; // Period for RSI indicator
input int BarsForCondition = 20; // Number of bars to evaluate for trading conditions

// Profit and Loss Settings
input string ProfitLossSettings = "---- Profit and Loss Settings ----"; // ---- Profit and Loss Settings ----
input int TakeProfit = 300; // Take profit in points, 0 to disable
input int StopLoss = 150; // Stop loss in points, 0 to disable

// Martingale Settings
input string MartingaleSettings = "---- Martingale Settings ----"; // ---- Martingale Settings ----
input bool Upheaval = true; // Enable or disable lot size increase on reversal
input double MartingaleMultiplier = 2.0; // Multiplier for martingale strategy

input string FinancialSettings = "---- Financial Settings ----"; // ---- Financial Settings ----
input bool DailyLossAndIncrease = false;
input double SufficientDailyIncrease = 1.0; //financial target during the day
input double MaxDailyLossPercent = 2.0; // Daily Loss Percent
input int startHour = 0;
input int endHour = 22;


// Time Settings
input string TimeSettings = "---- Time Settings ----"; // ---- Time Settings ----
input int StartTime = 0; // EA start time in hours (24-hour format)
input int EndTime = 23; // EA end time in hours (24-hour format)
input int SecondsBeforeAfterCandleClose = 30; // Seconds before and after candle close to check conditions
input string TimeSettings2 = "---- Time Newd Avoid ----"; // ---- Time Newd Avoid ----
input bool Hour_00 = false; // Avoid trading at 00:00-00:59
input bool Hour_01 = false; // Avoid trading at 01:00-01:59
input bool Hour_02 = false; // Avoid trading at 02:00-02:59
input bool Hour_03 = false; // Avoid trading at 03:00-03:59
input bool Hour_04 = false; // Avoid trading at 04:00-04:59
input bool Hour_05 = false; // Avoid trading at 05:00-05:59
input bool Hour_06 = false; // Avoid trading at 06:00-06:59
input bool Hour_07 = false; // Avoid trading at 07:00-07:59
input bool Hour_08 = false; // Avoid trading at 08:00-08:59
input bool Hour_09 = false; // Avoid trading at 09:00-09:59
input bool Hour_10 = false; // Avoid trading at 10:00-10:59
input bool Hour_11 = false; // Avoid trading at 11:00-11:59
input bool Hour_12 = false; // Avoid trading at 12:00-12:59
input bool Hour_13 = false; // Avoid trading at 13:00-13:59
input bool Hour_14 = false; // Avoid trading at 14:00-14:59
input bool Hour_15 = false; // Avoid trading at 15:00-15:59
input bool Hour_16 = false; // Avoid trading at 16:00-16:59
input bool Hour_17 = false; // Avoid trading at 17:00-17:59
input bool Hour_18 = false; // Avoid trading at 18:00-18:59
input bool Hour_19 = false; // Avoid trading at 19:00-19:59
input bool Hour_20 = false; // Avoid trading at 20:00-20:59
input bool Hour_21 = false; // Avoid trading at 21:00-21:59
input bool Hour_22 = false; // Avoid trading at 22:00-22:59
input bool Hour_23 = false; // Avoid trading at 23:00-23:59
input string Other = "---- Other ----"; // ---- Other ----
input bool inpLog = false;
input bool inpShortLog = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int handle_iRSI_1; // variable for storing the handle of the iRSI indicator

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   handle_iRSI_1=iRSI(_Symbol,0,RSI_Period,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double rsiArray[],rsi_2[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  //Print(NewOrderAllowedVolume(_Symbol));
  
     if (ShouldStopTrading() && DailyLossAndIncrease == true)
   {
       
       CloseAllOpenPositions();
       
       return;
   }
     
  
   ArraySetAsSeries(rsiArray,true);
   int start_pos=0,count=6;
   iGetArray(handle_iRSI_1,0,start_pos,BarsForCondition+1,rsiArray);
   
      
     /*

   string debugInfo[9];
   debugInfo[0] = "Current RSI: " + DoubleToString(rsiArray[0], 2);
   debugInfo[1] = "Is within 15 seconds of close: " + (IsWithinSecondsOfCandleClose() ? "Yes" : "No");
   debugInfo[2] = "CheckBuyCondition: " + (CheckBuyCondition() ? "True" : "False");
   debugInfo[3] = "CheckSellCondition: " + (CheckSellCondition() ? "True" : "False");
   debugInfo[4] = "IsMaxRSIForBars: " + (IsMaxRSIForBars() ? "True" : "False");
   debugInfo[5] = "IsMinRSIForBars: " + (IsMinRSIForBars() ? "True" : "False");
   debugInfo[6] = "Check Time: " + (IsTradingTimeAllowed() ? "True" : "False");*/

   ENUM_DEAL_TYPE closedDealType;
   double lastNegativeDealProfit;
   double lastNegativeDealLot;
   WasLastPositionNegative(_Symbol, closedDealType, lastNegativeDealProfit,lastNegativeDealLot);
/*
   debugInfo[7] = "Last  deal found: " + EnumToString(closedDealType) + ", Profit: " + DoubleToString(lastNegativeDealProfit, 2);
   debugInfo[8] = "-------------";*/

//DisplayDebugInfoScreen(debugInfo);

   if(OpenReversedPositionWithIncreasedLot())
     {
      return;
     }

   if(ShouldAvoidTrading())
     {
      if(inpLog) {Print("Avoiding trading due to news time.");}
      return;
     }

   if(!IsTradingTimeAllowed())
     {
      if(inpLog) {Print("Trading is not allowed at this time. Waiting for the permitted time.");}
      return;
     }

   if(SecondsLeftToCandleClose() > SecondsBeforeAfterCandleClose)
     {
      return;
     }

   double currentRSI = rsiArray[1]; // Текущее значение RSI

   double Lot =  LotCheck(InitialLot);
   if(Lot==0.0)
     {
      if(inpLog){
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","LotCheck returned the 0.0");
         }
       return;
     }
      
      double volume =0;
      double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_LIMIT);
      if(max_volume==0)  volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);



   if(CheckBuyCondition() && !IsBuyPositionOpen(_Symbol)  && currentRSI < 50
      && (lastNegativeDealProfit==0 || lastNegativeDealProfit > 0) &&  Lot <volume)
     {
      OpenBuy(Lot);
     }

   if(CheckSellCondition() && !IsSellPositionOpen(_Symbol) && currentRSI > 50
      && (lastNegativeDealProfit==0 || lastNegativeDealProfit > 0)   &&  Lot <volume)
     {
      OpenSell(Lot);
     }

   if(lastNegativeDealProfit==0 || lastNegativeDealProfit > 0)
     {
      CloseBuy(currentRSI);
      CloseSell(currentRSI);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsWithinSecondsOfCandleClose()
  {
   datetime currentTime = TimeCurrent();
   datetime timeOfLastCandle = iTime(_Symbol, 0, 1);

   datetime intervalStart = timeOfLastCandle + (60 - SecondsBeforeAfterCandleClose);
   datetime intervalEnd = timeOfLastCandle + 60;

   if(currentTime >= intervalStart && currentTime <= intervalEnd)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBuyCondition()
  {
   bool isMinRSI = IsMinRSIForBars();

   if(isMinRSI)
     {
      return true;
     }

   return false;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellCondition()
  {
   bool isMaxRSI = IsMaxRSIForBars();

   if(isMaxRSI)
     {
      return true;
     }

   return false;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuy(double Lot)
  {
   double ask;
   long spread;

   if(!SymbolInfoDouble(_Symbol, SYMBOL_ASK, ask)
      || !SymbolInfoInteger(_Symbol, SYMBOL_SPREAD, spread))
     {
      if(inpLog) {Print("Failed to get symbol info.");}
      return;
     }

// Проверка на максимальный спред
   if(MaxSpread > 0 && spread > MaxSpread)
     {
      if(inpLog) {Print("Spread is too high to open a Buy position.");}
      return;
     }

   double takeProfitPrice = 0;
   double stopLossPrice = 0;

   if(TakeProfit > 0)
     {
      takeProfitPrice = ask + TakeProfit * _Point;
     }

   if(StopLoss > 0)
     {
      stopLossPrice = ask - StopLoss * _Point;
     }

   if(!trade.Buy(Lot, _Symbol, ask, stopLossPrice, takeProfitPrice))
     {
      if(inpLog) {Print("Failed to open buy position.");}
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell(double Lot)
  {
   double bid;
   long spread;

   if(!SymbolInfoDouble(_Symbol, SYMBOL_BID, bid)
      || !SymbolInfoInteger(_Symbol, SYMBOL_SPREAD, spread))
     {
      Print("Failed to get symbol info.");
      return;
     }

   if(MaxSpread > 0 && spread > MaxSpread)
     {
      if(inpLog) {Print("Spread is too high to open a Sell position.");}
      return;
     }

   double takeProfitPrice = 0;
   double stopLossPrice = 0;

   if(TakeProfit > 0)
     {
      takeProfitPrice = bid - TakeProfit * _Point;
     }

   if(StopLoss > 0)
     {
      stopLossPrice = bid + StopLoss * _Point;
     }

   if(!trade.Sell(Lot, _Symbol, bid, stopLossPrice, takeProfitPrice))
     {
     if(inpLog) { Print("Failed to open sell position.");}
     }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy(double currentRSI)
  {
   if(positionInfo.Select(_Symbol) && positionInfo.PositionType() == POSITION_TYPE_BUY)
     {
      if(currentRSI > 50)
        {
         trade.PositionClose(_Symbol);
         if(inpLog) {PrintDebugInfo("Closed BUY position for symbol " + _Symbol + " because RSI crossed 50: " + DoubleToString(currentRSI, 2));}
        }
     }
   else
     {
      //if(inpLog) {PrintDebugInfo("No open buy position to close for symbol: " + _Symbol);}
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell(double currentRSI)
  {
   if(positionInfo.Select(_Symbol) && positionInfo.PositionType() == POSITION_TYPE_SELL)
     {
      if(currentRSI < 50)
        {
         trade.PositionClose(_Symbol);
         if(inpLog) {PrintDebugInfo("Closed SELL position for symbol " + _Symbol + " because RSI crossed 50: " + DoubleToString(currentRSI, 2));}
        }
     }
   else
     {
      //if(inpLog) {PrintDebugInfo("No open sell position to close for symbol: " + _Symbol);}
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMinRSIForBars()
  {
   double currentRSI = rsiArray[0];
   bool isMinRSI = true;

   for(int i = 1; i < BarsForCondition; i++)
     {
      if(currentRSI > rsiArray[i])
        {
         isMinRSI = false;
         break;
        }
     }

   return isMinRSI;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMaxRSIForBars()
  {
   double currentRSI = rsiArray[0];
   bool isMaxRSI = true;

   for(int i = 1; i < BarsForCondition; i++)
     {
      if(currentRSI < rsiArray[i])
        {
         isMaxRSI = false;
         break;
        }
     }

   return isMaxRSI;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SecondsLeftToCandleClose()
  {
   datetime currentTime = TimeCurrent();
   datetime currentCandleOpenTime = iTime(_Symbol,PERIOD_CURRENT,0);
   int timeFrameSeconds = PeriodSeconds();
   datetime currentCandleCloseTime = currentCandleOpenTime + timeFrameSeconds;
   int secondsLeft = (int)currentCandleCloseTime - (int)currentTime;
   return secondsLeft;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintDebugInfo(string message)
  {
   if(inpLog) {Print("[" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + "] DEBUG: " + message);}
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayDebugInfoScreen(string &debugLine[], int startLine = 0)
  {
   int lineCount = ArraySize(debugLine);  // Automatically determine the array size

// Clear old labels
   for(int i = 0; i < lineCount; i++)
     {
      string oldLabelName = "DebugInfo_" + IntegerToString(startLine + i);
      ObjectDelete(0, oldLabelName);
     }

// Display new debug information
   for(int i = 0; i < lineCount; i++)
     {
      string labelName = "DebugInfo_" + IntegerToString(startLine + i);

      // Create the text label
      if(ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0))
        {
         ObjectSetString(0, labelName, OBJPROP_TEXT, debugLine[i]);
         ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 50);
         ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 50 + (startLine + i) * 20);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
        }
     }
  }



// Функция для проверки наличия открытой позиции на покупку
bool IsBuyPositionOpen(string symbol)
  {

   if(positionInfo.Select(symbol))
     {

      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
         return true;
        }
     }
   return false;
  }

// Функция для проверки наличия открытой позиции на продажу
bool IsSellPositionOpen(string symbol)
  {

   if(positionInfo.Select(symbol))
     {
      if(positionInfo.PositionType() == POSITION_TYPE_SELL)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
bool iGetArray(const int handle,const int buffer,const int start_pos,
               const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      PrintFormat("ERROR! EA: %s, FUNCTION: %s, this a no dynamic array!",__FILE__,__FUNCTION__);
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code

      PrintFormat("ERROR! EA: %s, FUNCTION: %s, amount to copy: %d, copied: %d, error code %d",
                  __FILE__,__FUNCTION__,count,copied,GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
   return(result);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradingTimeAllowed()
  {
   datetime serverTime = TimeCurrent();

   datetime curTime = TimeCurrent();
   MqlDateTime mqlTime;
   TimeToStruct(curTime, mqlTime);
   int currentHour = mqlTime.hour;

   if(currentHour >= StartTime && currentHour <= EndTime)
     {
      return true;
     }
   else
     {
      return false;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WasLastPositionNegative(string symbol, ENUM_DEAL_TYPE &closedDealType, double &lastNegativeDealProfit, double &lastNegativeDealLot)
  {

   datetime from_date = TimeCurrent() - 60*60*24*100;
   datetime to_date = TimeCurrent() + 60*60*24*3;
   HistorySelect(from_date, to_date);

   int total_deals = HistoryDealsTotal();
   ulong ticket_history_deal = 0;


   for(int i = total_deals - 1; i >= 0; i--)
     {
      if((ticket_history_deal = HistoryDealGetTicket(i)) > 0)
        {
         if(m_deal.SelectByIndex(i))
           {
            if(m_deal.Symbol() == symbol && m_deal.Entry()==DEAL_ENTRY_OUT)
              {
               lastNegativeDealProfit = m_deal.Profit();
               closedDealType = m_deal.DealType();
               lastNegativeDealLot = m_deal.Volume();

               return true;
              }
           }
        }
     }
   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WasLastPositionNegativeShort(string symbol)
  {

   datetime from_date = TimeCurrent() - 60*60*24*100;
   datetime to_date = TimeCurrent() + 60*60*24*3;
   HistorySelect(from_date, to_date);

   int total_deals = HistoryDealsTotal();
   ulong ticket_history_deal = 0;

   for(int i = total_deals - 1; i >= 0; i--)
     {
      if((ticket_history_deal = HistoryDealGetTicket(i)) > 0)
        {
         if(m_deal.SelectByIndex((int)ticket_history_deal))
           {
            if(m_deal.Symbol() == symbol && m_deal.Profit() < 0 && m_deal.Entry()==DEAL_ENTRY_OUT)
              {
               return true;
              }
           }
        }
     }

   return false;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenReversedPositionWithIncreasedLot()
  {
   ENUM_DEAL_TYPE closedDealType;
   double lastNegativeDealProfit;
   double lastNegativeDealVolume;
   WasLastPositionNegative(_Symbol, closedDealType, lastNegativeDealProfit, lastNegativeDealVolume);

   double Lot;
   double newLotSize;

   if(lastNegativeDealProfit<0)
     {
     if(Upheaval==true){
       newLotSize = lastNegativeDealVolume * MartingaleMultiplier;
      }
      else{ newLotSize = InitialLot;}
      if(!IsPositionWithSameVolumeOpen(newLotSize))
        {
         if(closedDealType == DEAL_TYPE_BUY )
           {
            Lot = LotCheck(newLotSize);
            if(Lot==0.0)
              {
               if(inpLog)
                  Print(__FILE__," ",__FUNCTION__,", ERROR: ","LotCheck returned the 0.0");
               return false;
              }
            OpenBuy(Lot);return true;
            
           }
         else
            if(closedDealType == DEAL_TYPE_SELL )
              {
               Lot = LotCheck(newLotSize);
               if(Lot==0.0)
                 {
                  if(inpLog)
                     Print(__FILE__," ",__FUNCTION__,", ERROR: ","LotCheck returned the 0.0");
                  return false;
                 }
               OpenSell(Lot);
               return true;
              }
        }
     }
   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPositionWithSameVolumeOpen(double targetVolume)
  {
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i))
        {
         if(StringFind(positionInfo.Symbol(), _Symbol) != -1 && positionInfo.Volume() == targetVolume)
           {
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShouldAvoidTrading()
  {
   MqlDateTime mqlTime;
   TimeToStruct(TimeCurrent(), mqlTime);
   bool hoursToAvoid[24] = {Hour_00, Hour_01, Hour_02, Hour_03, Hour_04, Hour_05, Hour_06, Hour_07, Hour_08, Hour_09, Hour_10, Hour_11, Hour_12, Hour_13, Hour_14, Hour_15, Hour_16, Hour_17, Hour_18, Hour_19, Hour_20, Hour_21, Hour_22, Hour_23};
   if(hoursToAvoid[mqlTime.hour])
     {
      if(inpLog) {Print("Avoiding trading due to news time. Current time falls within the range: ", IntegerToString(mqlTime.hour), ":00-", IntegerToString(mqlTime.hour), ":59");}
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check Lot Size                                                   |
//+------------------------------------------------------------------+
double LotCheck(double ImpLots)
{
  m_symbol.Name(Symbol());
  double volume = NormalizeDouble(ImpLots, 2);
  double stepvol = m_symbol.LotsStep();

  if(stepvol > 0.0)
  {
    volume = stepvol * MathFloor(volume / stepvol);
  }

  //---
  double minvol = m_symbol.LotsMin();
  
  if(volume < minvol)
  {
    volume = minvol;
  }

  //---
  double maxvol = m_symbol.LotsMax();
  
  if(volume > maxvol)
  {
    volume = maxvol;
  }  
  return(volume);
}



double NewOrderAllowedVolume(string symbol)
  {
   double allowed_volume=0;
   double symbol_max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_LIMIT);

   double opened_volume=PositionVolume(symbol);
   if(opened_volume>=0)
     {
      if(max_volume-opened_volume<=0)
         return(0);

      double orders_volume_on_symbol=PendingsVolume(symbol);
      allowed_volume=max_volume-opened_volume-orders_volume_on_symbol;
      if(allowed_volume>symbol_max_volume) allowed_volume=symbol_max_volume;
     }
   return(allowed_volume);
  }
  
double PositionVolume(string symbol)
  {
   bool selected=PositionSelect(symbol);
   if(selected)
      return(PositionGetDouble(POSITION_VOLUME));
   else
     {
      return(-1);
     }
  }

double   PendingsVolume(string symbol)
  {
   double volume_on_symbol=0;
   ulong ticket;
   int all_orders=OrdersTotal();

   for(int i=0;i<all_orders;i++)
     {
      ticket=OrderGetTicket(i);
      if(ticket>0)
        {
         if(symbol==OrderGetString(ORDER_SYMBOL))
            volume_on_symbol+=OrderGetDouble(ORDER_VOLUME_INITIAL);
        }
     }

   return(volume_on_symbol);
  }
  
  double DayStartBalance = -1; 

double StartingBalance;
datetime LastCheckedDay;

bool ShouldStopTrading()
{
   MqlDateTime mqlTime;
   TimeToStruct(TimeCurrent(), mqlTime);
   
    datetime current_time = TimeCurrent();
    int current_hour = mqlTime.hour;
    int current_day = mqlTime.day;
    
    if (current_day != LastCheckedDay)
    {
        LastCheckedDay = current_day;
        StartingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }

    if (current_hour >= startHour && current_hour < endHour)
    {
        double totalProfit = AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_PROFIT); // баланс + профит от открытых позиций
        double profitPercentage = (totalProfit - StartingBalance) / StartingBalance * 100.0;
        Comment("Profit Now % = ", profitPercentage);

        if (profitPercentage >= SufficientDailyIncrease)
        {
            return true; // Торговля должна быть прекращена
        }
        
       if (profitPercentage <= -MaxDailyLossPercent)
          {
              return true;
          }
    
    }

    return false;
}

void CloseAllOpenPositions()
{
    int totalPositions = PositionsTotal();
    for(int i = totalPositions-1; i >= 0; i--)
    {
        if(positionInfo.SelectByIndex(i))
        {
            ulong ticket = positionInfo.Ticket();
            if(positionInfo.PositionType() == POSITION_TYPE_BUY)
            {
                trade.PositionClose(ticket);
            }
            else if(positionInfo.PositionType() == POSITION_TYPE_SELL)
            {
                trade.PositionClose(ticket);
            }
        }
    }
}
