//+------------------------------------------------------------------+
//|                              Tengri(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.000"
#property description "Advisor trades on the symbols EURUSD and USDCHF"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input string   InpSymbol                     = "EURUSD";    // символ по которому работаем
input ENUM_TIMEFRAMES InpTimeFrameDeal1=PERIOD_M30;         // таймфрейм для бара направления 1-й позиции
input ENUM_TIMEFRAMES Inp_Silence_timeframe_1=PERIOD_M5;    // таймфрейм 1-й позиции индикатор Silence #1
input int      Inp_Silence_Period_1          = 11;          // "Period" 1-й позиции индикатор Silence #1
input int      Inp_Silence_Interpolation_1   = 220;         // "Interpolation" 1-й позиции индикатор Silence #1
input int      Inp_Silence_Level_1           = 80;          // уровень 1-й позиции индикатор Silence #1
input ENUM_TIMEFRAMES Inp_Silence_timeframe_2=PERIOD_M15;   // таймфрейм колен индикатор Silence #2      
input int      Inp_Silence_Period_2          = 12;          // "Period" колен индикатор Silence #2  
input int      Inp_Silence_Interpolation_2   = 96;          // "Interpolation" колен индикатор Silence #2 
input int      Inp_Silence_Level_2           = 80;          // уровень колен индикатор Silence #2 
input ENUM_TIMEFRAMES    Inp_MA_timeframe=PERIOD_M15;       // таймфрейм колен индикатор MA       
input int      Inp_MA_ma_period              = 30;          // период усреднения колен индикатор MA 
input double   PipStepExponent               = 1;           // если нужен прогрессивный шаг
input double   LotExponent1                  = 1.70;        // прогрессивный лот до StepX
input double   LotExponent2                  = 2.08;        // прогрессивный лот после StepX
input int      StepX                         = 5;           // Step=5, до 5шага увеличивает по экспоненто1, после 5 по экспоненто2
input double   LotSize                       = 0.01;        // размер лота 1-го ордера если FixLot = true;
input bool     FixLot                        = false;       // true - фиксированный лот, если false - то тогда смотрим LotStep
input int      LotStep                       = 2000;        // шаг увеличения лота. т.е. сколько в депозите LotStep востолько увеличится LotSize. если депо 2000 то лот 0.01, если станет 4000 то лот 0.02
input int      PipStep                       = 10;          // шаг между доливками. каждый шаг увиличивается в PipStepExponent раз если Silence ниже Level.
input int      PipStep2                      = 20;          // шаг между доливками. каждый шаг увиличивается в PipStepExponent раз если Silence выше Level.
input ushort   InpSLTP                       =10;           // Stop Loss and Take Profit, in pips (1.00045-1.00055=1 pips)
input int      MaxTrades                     =10;           //максимальное кол-во колен
input bool     InpUseLimit                   = true;        // Закрывать всё при достижении лимита (>=Equity/Лимит)
input double   InpLimit                      = 50;          // Лимит
input ENUM_TIMEFRAMES OpenNewTF=PERIOD_M1;                  // таймфрем для открытия новых позиций 
input ENUM_TIMEFRAMES OpenNextTF=PERIOD_M1;                 // таймфрейм для открытия колен
input bool     CloseFriday                   = true;        // использовать ограничение по времени в пятницу true, не использовать false
input int      CloseFridayHour               = 19;          // время в пятницу после которого не работаем
input ulong    m_magic=14467696;// magic number
//---
ulong          m_slippage=10;                // slippage
double ExtSLTP=0.0;
int    handle_iMA;                           // variable for storing the handle of the iMA indicator 
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
int    handle_iCustom_1;                     // variable for storing the handle of the iCustom indicator 
int    handle_iCustom_2;                     // variable for storing the handle of the iCustom indicator 
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
double m_last_deal_buy_price=0.0;
double m_last_deal_buy_lot=0.0;
double m_last_deal_sell_price=0.0;
double m_last_deal_sell_lot=0.0;

datetime timeprevMIN=0;
datetime timeprevMAX=0;
int CountTrades;
bool LongTradeNew,ShortTradeNew;
double Buy_NextLot,Sell_NextLot,Buy_NewLot,Sell_NewLot,Buy_LastLot,Sell_LastLot,Prof;
string CommentTrades;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(InpSymbol)) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtSLTP=InpSLTP           *m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Inp_MA_timeframe,Inp_MA_ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Inp_MA_timeframe),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),PERIOD_H1,14,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(PERIOD_H1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_1=iCustom(m_symbol.Name(),Inp_Silence_timeframe_1,"Silence",
                            Inp_Silence_Period_1,Inp_Silence_Interpolation_1);
//--- if the handle is not created 
   if(handle_iCustom_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Inp_Silence_timeframe_1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_2=iCustom(m_symbol.Name(),Inp_Silence_timeframe_2,"Silence",
                            Inp_Silence_Period_2,Inp_Silence_Interpolation_2);
//--- if the handle is not created 
   if(handle_iCustom_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Inp_Silence_timeframe_2),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- направление
   int direction=0;
//--- Бары открытие цены 1-й позиции
   double open=iOpen(m_symbol.Name(),InpTimeFrameDeal1,0);  // условие направления для 1-й позиции
   if(open<m_symbol.Bid())
      direction=1;     // условие для бай
   else if(open>m_symbol.Bid())
      direction=-1;    // условие для селл

   LongTradeNew   = true;
   ShortTradeNew  = true;
//--- Закрытие локов при профите
   int count_buys = 0;  double profit_buys   =0.0; double volume_buys   = 0.0;
   int count_sells= 0;  double profit_sells  =0.0; double volume_sells  = 0.0;
   CalculateAllPositions(count_buys,profit_buys,volume_buys,count_sells,profit_sells,volume_sells);

   if((InpUseLimit) && count_buys>0 && count_sells>0 && (profit_buys+profit_sells)>=m_account.Equity()/InpLimit)
     {
      CloseAllPositions();
      return;
     }
//---     
   if(timeprevMIN!=iTime(m_symbol.Name(),OpenNewTF,0))
     {
      MqlDateTime STimeCurrent;
      TimeToStruct(TimeCurrent(),STimeCurrent);

      if(CloseFriday==true && STimeCurrent.day_of_week==5 && TimeCurrent()>=StringToTime((string)CloseFridayHour+":00"))
         return; // сработал запрет в пятницу

      if(direction>0) // условие для 1-й позиции BUY: если цена ниже уровня открытия бара, то позиция BUY не открывается
        {
         double rsi[];
         double silence_1[];
         if(iGetArray(handle_iRSI,0,0,1,rsi) && iGetArray(handle_iCustom_1,0,0,1,silence_1))
            if(rsi[0]<70.0 && silence_1[0]<Inp_Silence_Level_1)
              {
               CalculateAllPositions(count_buys,profit_buys,volume_buys,count_sells,profit_sells,volume_sells);
               if(count_buys==0 && LongTradeNew)
                 {
                  CommentTrades="Tengri "+m_symbol.Name()+" - Buy "+(string)(count_buys+1);
                  Buy_NewLot=NewLot(POSITION_TYPE_BUY);
                  if(Buy_NewLot>0.0)
                    {
                     //--- check Freeze and Stops levels
/*
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask	            |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid	            |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order	      |  Bid	            |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid	            |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL 
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask	            |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
*/
                     if(!RefreshRates() || !m_symbol.Refresh())
                       {
                        //PrevBars=0;
                        return;
                       }
                     //--- FreezeLevel -> for pending order and modification
                     double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
                     if(freeze_level==0.0)
                        freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
                     freeze_level*=1.1;
                     //--- StopsLevel -> for TakeProfit and StopLoss
                     double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
                     if(stop_level==0.0)
                        stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
                     stop_level*=1.1;

                     if(freeze_level<=0.0 || stop_level<=0.0)
                       {
                        //PrevBars=0;
                        return;
                       }
                     //--- buy
                     double price=m_symbol.Ask();
                     double sl=0.0;
                     double tp=(InpSLTP==0)?0.0:price+ExtSLTP;
                     if((tp!=0 && ExtSLTP>=stop_level) || tp==0.0)
                       {
                        OpenBuy(Buy_NewLot,sl,tp,CommentTrades);
                       }
                    }
                 }
              }
        }
      if(direction<0) // условие для 1-й позиции SELL: если цена выше уровня открытия бара, то позиция SELL не открывается
        {
         double rsi[];
         double silence_1[];
         if(iGetArray(handle_iRSI,0,0,1,rsi) && iGetArray(handle_iCustom_1,0,0,1,silence_1))
            if(rsi[0]>30.0 && silence_1[0]<Inp_Silence_Level_1)
              {
               CalculateAllPositions(count_buys,profit_buys,volume_buys,count_sells,profit_sells,volume_sells);
               if(count_sells==0 && ShortTradeNew)
                 {
                  CommentTrades="Tengri "+m_symbol.Name()+" - Sell "+(string)(count_sells+1);
                  Sell_NewLot=NewLot(POSITION_TYPE_SELL);
                  if(Sell_NewLot>0.0)
                    {
                     //--- check Freeze and Stops levels
/*
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask	            |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid	            |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order	      |  Bid	            |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid	            |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL 
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask	            |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
*/
                     if(!RefreshRates() || !m_symbol.Refresh())
                       {
                        //PrevBars=0;
                        return;
                       }
                     //--- FreezeLevel -> for pending order and modification
                     double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
                     if(freeze_level==0.0)
                        freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
                     freeze_level*=1.1;
                     //--- StopsLevel -> for TakeProfit and StopLoss
                     double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
                     if(stop_level==0.0)
                        stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
                     stop_level*=1.1;

                     if(freeze_level<=0.0 || stop_level<=0.0)
                       {
                        //PrevBars=0;
                        return;
                       }
                     //--- sell
                     double price=m_symbol.Bid();
                     double sl=0.0;
                     double tp=(InpSLTP==0)?0.0:price-ExtSLTP;
                     if((tp!=0 && ExtSLTP>=stop_level) || tp==0.0)
                       {
                        OpenSell(Sell_NewLot,sl,tp,CommentTrades);
                       }
                    }
                 }
              }
        }
      timeprevMIN=iTime(m_symbol.Name(),OpenNewTF,0);
     }
//---
   if(timeprevMAX!=iTime(m_symbol.Name(),OpenNextTF,0))
     {
      CalculateAllPositions(count_buys,profit_buys,volume_buys,count_sells,profit_sells,volume_sells);
      RefreshRates();
      if(count_buys>0 && Next(POSITION_TYPE_BUY,count_buys))
        {
         CommentTrades="Tengri "+m_symbol.Name()+" - Buy "+(string)(count_buys+1);
         Buy_NextLot=NextLot(POSITION_TYPE_BUY,count_buys);
         if(Buy_NextLot>0.0)
           {
            RefreshRates();
            OpenBuy(Buy_NextLot,0.0,0.0,CommentTrades);
           }
        }
      CalculateAllPositions(count_buys,profit_buys,volume_buys,count_sells,profit_sells,volume_sells);
      RefreshRates();
      if(count_sells>0 && Next(POSITION_TYPE_SELL,count_sells))
        {
         CommentTrades= "Tengri "+m_symbol.Name()+" - Sell "+(string)(count_sells+1);
         Sell_NextLot = NextLot(POSITION_TYPE_SELL,count_sells);
         if(Sell_NextLot>0.0)
           {
            RefreshRates();
            OpenSell(Sell_NextLot,0.0,0.0,CommentTrades);
           }
        }
      timeprevMAX=iTime(m_symbol.Name(),OpenNextTF,0);
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
           {
            if(deal_type==DEAL_TYPE_BUY)
              {
               m_last_deal_buy_price   = deal_price;
               m_last_deal_buy_lot     = deal_volume;
               m_last_deal_sell_price  = 0.0;
               m_last_deal_sell_lot    = 0.0;
              }
            if(deal_type==DEAL_TYPE_SELL)
              {
               m_last_deal_buy_price   = 0.0;
               m_last_deal_buy_lot     = 0.0;
               m_last_deal_sell_price  = deal_price;
               m_last_deal_sell_lot    = deal_volume;
              }
           }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,double &profit_buys,double &volume_buys,
                           int &count_sells,double &profit_sells,double &volume_sells)
  {
   count_buys  =0;   profit_buys    = 0.0;   volume_buys = 0.0;
   count_sells =0;   profit_sells   = 0.0;   volume_sells= 0.0;
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               profit_buys+=m_position.Commission()+m_position.Swap()+m_position.Profit();
               volume_buys+=m_position.Volume();
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               count_sells++;
               profit_sells+=m_position.Commission()+m_position.Swap()+m_position.Profit();
               volume_sells+=m_position.Volume();
              }
           }
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
double iGetArray(const int handle,const int buffer,const int start_pos,const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
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
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Вычисляем размер первого лота                                    |
//+------------------------------------------------------------------+
double NewLot(ENUM_POSITION_TYPE pos_type)
  {
   double tLots=0.0;

   if(pos_type==POSITION_TYPE_BUY)
     {
      if(FixLot)
         tLots=LotSize;
      else
         tLots=LotCheck(LotSize*(m_account.Equity()/LotStep));
     }
   if(pos_type==POSITION_TYPE_SELL)
     {
      if(FixLot)
         tLots=LotSize;
      else
         tLots=LotCheck(LotSize*(m_account.Equity()/LotStep));
     }
//---
   return(tLots);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Вычисляем размер следующего лота                                 |
//+------------------------------------------------------------------+
double NextLot(ENUM_POSITION_TYPE pos_type,int count_pos_type)
  {
   double tLots=0.0;
   if(pos_type==POSITION_TYPE_BUY)
      if(m_last_deal_buy_lot>0.0)
        {
         if(count_pos_type>=StepX)
            tLots=LotCheck(m_last_deal_buy_lot*LotExponent2);
         else
            tLots=LotCheck(m_last_deal_buy_lot*LotExponent1);
        }
   if(pos_type==POSITION_TYPE_SELL)
      if(m_last_deal_sell_lot>0.0)
        {
         if(count_pos_type>=StepX)
            tLots=LotCheck(m_last_deal_sell_lot*LotExponent2);
         else
            tLots=LotCheck(m_last_deal_sell_lot*LotExponent1);
        }
   return(tLots);
  }
//+------------------------------------------------------------------+
//| Проверяем нужно ли открывать следующую позицию                   |
//+------------------------------------------------------------------+
bool Next(ENUM_POSITION_TYPE pos_type,int count_pos_type)
  {
   bool     next=false;
   double   ma[];
   double   silence_2[];
   if(iGetArray(handle_iMA,0,0,1,ma) && iGetArray(handle_iCustom_2,0,0,1,silence_2))
     {
      int   PipStepEX=0.0;
      if(pos_type==POSITION_TYPE_BUY && ma[0]<m_symbol.Bid())
        {
         if(silence_2[0]<Inp_Silence_Level_2)
            PipStepEX=(int)NormalizeDouble(PipStep*MathPow(PipStepExponent,count_pos_type),0);
         else
            PipStepEX=(int)NormalizeDouble(PipStep2*MathPow(PipStepExponent,count_pos_type),0);
         if(m_last_deal_buy_price>0.0 && 
            m_last_deal_buy_price-m_symbol.Ask()>=PipStepEX*m_adjusted_point && 
            count_pos_type<MaxTrades)
            next=true;
        }
      if(pos_type==POSITION_TYPE_SELL && ma[0]>m_symbol.Bid())
        {
         if(silence_2[0]<Inp_Silence_Level_2)
            PipStepEX=(int)NormalizeDouble(PipStep*MathPow(PipStepExponent,count_pos_type),0);
         else
            PipStepEX=(int)NormalizeDouble(PipStep2*MathPow(PipStepExponent,count_pos_type),0);
         if(m_last_deal_sell_price>0.0 && 
            m_symbol.Bid()-m_last_deal_sell_price>=PipStepEX*m_adjusted_point && 
            count_pos_type<MaxTrades)
            next=true;
        }
     }
//---
   return(next);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double lot,double sl,double tp,string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double long_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp,comment))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double lot,double sl,double tp,string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double short_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp,comment))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
