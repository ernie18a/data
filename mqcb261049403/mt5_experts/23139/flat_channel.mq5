//+------------------------------------------------------------------+
//|                        Flat Channel(barabashkakvn's edition).mq5 |
//|                                                  wsforex@list.ru |
//|                                               http://wsforex.ru/ |
//+------------------------------------------------------------------+
#property copyright "wsforex@list.ru"
#property link      "http://wsforex.ru/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input double   InpLots           = 1.0;      // Lots
input ushort   InpStopLoss       = 0.0;      // Stop Loss, in pips (1.00045-1.00055=1 pips) (if "0.0" -> dynamic SL)
input ushort   InpTakeProfit     = 0.0;      // Take Profit, in pips (1.00045-1.00055=1 pips) (if "0.0" -> dynamic TP)
input ushort   InpTrailingStop   = 5;        // Trailing Stop (min distance from price to Stop Loss, in pips)
input ushort   InpTrailingStep   = 5;        // Trailing Step, in pips (1.00045-1.00055=1 pips)
input bool     InpUseBuy         = true;     // Функция отключения позиции BUY
input bool     InpUseSell        = true;     // Функция отключения позиции SELL
//---
input bool     InpMM             = true;     // Включение функции мани-менеджмента 
input ushort   InpHistoryDays    = 60;       // History days
input int      InpNumberLoss     = 0;        // Количество убыточных сделок
input int      InpMaxLoss        = 4;        // Максимальное количество убыточных сделок
input double   InpMultiLoss      = 4.0;      // Множитель после убыточной сделки
input int      InpNumberProfit   = 0;        // Количество сделок в истории закрытых по ТР
input int      InpMaxProfit      = 4;        // Максимальное количество сделок в истории закрытых по ТР
input double   InpMultiProfit    = 2.0;      // Множитель после прибыльной сделки
//---
input double   DynamicSL         = 1.0;      // StopLoss зависит от ширины канала
input double   DynamicTP         = 1.0;      // Тейкпрофит зависит от ширины канала
input int      InpMaxPositions   = 5;        // Максимальное количество позиций
input ushort   InpIndent         = 0;        // Отступ от границ канала
//---
input string   Блок="  Настройки флэта  ";
input int                  Inp_StdDev_ma_period    = 46;          // period of averaging
input int                  Inp_StdDev_ma_shift     = 0;           // shift
input ENUM_MA_METHOD       Inp_StdDev_ma_method    = MODE_SMA;    // type of smoothing
input ENUM_APPLIED_PRICE   Inp_StdDev_applied_price= PRICE_CLOSE; // type of price
input int      FletBars          = 3;     // Минимальное количество баров
input ushort   InpCanalMax       = 105;   // Максимальная ширина канала
input ushort   InpCanalMin       = 15;    // Минимальная ширина канала
input ulong    m_magic=646689624;// magic number
input bool     InpTimeControl    = true;     // Use time control
input uchar    InpStartHour      = 0;        // Start hour
input uchar    InpEndHour        = 23;       // End hour
//---
ulong  m_slippage=10;                // slippage
double ExtStopLoss      = 0.0;
double ExtTakeProfit    = 0.0;
double ExtTrailingStop  = 0.0;
double ExtTrailingStep  = 0.0;
double ExtIndent        = 0.0;
double ExtCanalMin      = 0.0;
double ExtCanalMax      = 0.0;
int    handle_iCustom;                       // variable for storing the handle of the iCustom indicator 
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
bool   m_need_delete_all_pending_orders=false;// "true" -> need delete all pending orders
//---
bool flagup=false,flagdw=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string err_text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                      "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                      "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
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

   ExtStopLoss       = InpStopLoss        * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit      * m_adjusted_point;
   ExtTrailingStop   = InpTrailingStop    * m_adjusted_point;
   ExtTrailingStep   = InpTrailingStep    * m_adjusted_point;
   ExtIndent         = InpIndent          * m_adjusted_point;
   ExtCanalMax       = InpCanalMax        * m_adjusted_point;
   ExtCanalMin       = InpCanalMin        * m_adjusted_point;
//--- check the input parameter "Lots"
   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Standard Deviation smoothing",Inp_StdDev_ma_period,
                          Inp_StdDev_ma_shift,Inp_StdDev_ma_method,Inp_StdDev_applied_price);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
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
   if(m_need_delete_all_pending_orders)
     {
      if(IsPendingOrdersExists())
         DeleteAllPendingOrders();
      else
         m_need_delete_all_pending_orders=false;   // "true" -> need delete all pending orders
      //---
      return;
     }
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);
   Comment("\nСоветник "+__FILE__+" весь в работе:  ",TimeControl(),
           "\nДень:  ",Dayof(STimeCurrent),
           "\nТорговый счёт:  ",m_account.Login(),
           "\nCompany:  ",m_account.Company(),
           "\nEquity:  ",m_account.Equity(),
           "\nВремя по GMT:  "+TimeToString(TimeGMT(),TIME_DATE|TIME_SECONDS),
           "\nSpread:  ",m_symbol.Spread(),
           "\nStopLevel:  ",m_symbol.StopsLevel(),
           "\nПлечо:  ",m_account.Leverage()
           );
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
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
                           
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(!RefreshRates() || !m_symbol.Refresh())
     {
      PrevBars=0;
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
      PrevBars=0;
      return;
     }
   double level=(stop_level>freeze_level)?stop_level:freeze_level;
   Trailing(stop_level);
//---
   int flat_bars=CheckBars();
   if(flat_bars==0)
     {
      HLineDelete(0,"Flat Channel Max");
      HLineDelete(0,"Flat Channel Min");
      return;
     }
   int count_buy_stops=0,count_sell_stops=0;
   CalculateAllPendingOrders(count_buy_stops,count_sell_stops);
//---
   double highest=DBL_MIN,lowest=DBL_MAX;
   if(!PriceFlatBar(flat_bars,highest,lowest))
      return;

   HLineCreate(0,"Flat Channel Max",0,highest,clrLimeGreen);
   HLineCreate(0,"Flat Channel Min",0,lowest,clrDarkViolet);

   double ChannelHeight=highest-lowest;

   double TPBuy   = highest   + ChannelHeight   * DynamicTP;
   double TPSell  = lowest    - ChannelHeight   * DynamicTP;
   double SLBuy   = highest   - ChannelHeight   * DynamicSL;
   double SLSell  = lowest    + ChannelHeight   * DynamicSL;
//---
   if(ChannelHeight>ExtCanalMin && ChannelHeight<ExtCanalMax)
      if(TimeControl() && m_symbol.Bid()>lowest+stop_level && m_symbol.Ask()<highest-stop_level)
        {
         //--- 
         double Lot=GetLots();
         if(InpUseBuy)
            if(flagup && count_buy_stops==0 && CalculateAllPositions()<InpMaxPositions/* && FlagPos*/)
              {
               double price=highest+ExtIndent;
               double sl=(InpStopLoss==0)?SLBuy:price-ExtStopLoss;
               double tp=(InpTakeProfit==0)?TPBuy:price+ExtTakeProfit;
               if(((sl!=0 && price-sl>=stop_level) || sl==0.0) && ((tp!=0 && tp-price>=stop_level) || tp==0.0))
                 {
                  if(PendingOrder(ORDER_TYPE_BUY_STOP,Lot,price,sl,tp))
                     flagup=false;
                  return;
                 }
              }
         //---
         if(InpUseSell)
            if(flagdw && count_sell_stops==0 && CalculateAllPositions()<InpMaxPositions/* && FlagPos*/)
              {
               double price=lowest-ExtIndent;
               double sl=(InpStopLoss==0)?SLSell:price+ExtStopLoss;
               double tp=(InpTakeProfit==0)?TPSell:price-ExtTakeProfit;
               if(((sl!=0 && sl-price>=stop_level) || sl==0.0) && ((tp!=0 && price-tp>=stop_level) || tp==0.0))
                 {
                  if(PendingOrder(ORDER_TYPE_SELL_STOP,Lot,price,sl,tp))
                     flagdw=false;
                  return;
                 }
              }
        }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
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
      if(deal_reason!=-1)
         DebugBreak();
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
              {
               m_need_delete_all_pending_orders=true;
               HLineDelete(0,"Flat Channel Max");
               HLineDelete(0,"Flat Channel Min");
              }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
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
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_DOT,   // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,// highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
     }
   else
      HLineMove(chart_ID,name,price);
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(!RefreshRates() || !m_symbol.Refresh())
               continue;
            double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               if(MathAbs(m_symbol.Ask()-m_order.PriceOpen())>=freeze_level)
                  m_trade.OrderDelete(m_order.Ticket());
            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               if(MathAbs(m_symbol.Bid()-m_order.PriceOpen())>=freeze_level)
                  m_trade.OrderDelete(m_order.Ticket());
           }
  }
//+------------------------------------------------------------------+
//| Is pendinf orders exists                                         |
//+------------------------------------------------------------------+
bool IsPendingOrdersExists(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| TimeControl                                                      |
//+------------------------------------------------------------------+
bool TimeControl(void)
  {
   if(!InpTimeControl)
      return(true);
   MqlDateTime STimeCurrent;
   datetime time_current=TimeCurrent();
   if(time_current==D'1970.01.01 00:00')
      return(false);
   TimeToStruct(time_current,STimeCurrent);
   if(InpStartHour<InpEndHour) // intraday time interval
     {
/*
Example:
input uchar    InpStartHour      = 5;        // Start hour
input uchar    InpEndHour        = 10;       // End hour
0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
_  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _
*/
      if(STimeCurrent.hour>=InpStartHour && STimeCurrent.hour<InpEndHour)
         return(true);
     }
   else if(InpStartHour>InpEndHour) // time interval with the transition in a day
     {
/*
Example:
input uchar    InpStartHour      = 10;       // Start hour
input uchar    InpEndHour        = 5;        // End hour
0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
_  _  _  _  _  _  _  _  _  _  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  _  _  _  _  _  +  +  +  +  +  +
*/
      if(STimeCurrent.hour>=InpStartHour || STimeCurrent.hour<InpEndHour)
         return(true);
     }
   else
      return(false);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Dayof(MqlDateTime &STimeCurrent)
  {
   string dd="NULL";
   switch(STimeCurrent.day_of_week)
     {
      case 1: dd="Понедельник"; break;
      case 2: dd="Вторник";     break;
      case 3: dd="Среда";       break;
      case 4: dd="Четверг";     break;
      case 5: dd="Пятница";     break;
      case 6: dd="Суббота";     break;
      case 7: dd="Воскресенье"; break;
     }
   return(dd);
  }
//+------------------------------------------------------------------+
//| Check bars                                                       |
//+------------------------------------------------------------------+
int CheckBars()
  {
   double StdDev_smoothing[];
   ArraySetAsSeries(StdDev_smoothing,true);
   int buffer=0,start_pos=0,count=(FletBars<5)?5:FletBars+2;
/*
   count=FletBars+2;

   FletBars=3;
   Flat:
   #4                #3                #2                #1                #0
   0.0596            0.0486            0.0376            0.0266            0.0156
                                                                           i=0;result=1;
                                                         i=1;result=2;
                                       i=2;result=3;
                     i=3;result=4;

   Trend:
   #4                #3                #2                #1                #0
   0.0156            0.0266            0.0376            0.0486            0.0596
                                                                           i=0;result=1;
                                                         i=1;result=2;
                                       i=2;result=3;
                     i=3;result=4;
*/
   if(!iGetArray(handle_iCustom,buffer,start_pos,count,StdDev_smoothing))
      return(0);
   int count_trend=0,count_flat=0;
//--- init
/*FlagPos=false;*/ flagup=false; flagdw=false;/*
//--- chek trend
   int result=0;
   for(int i=0;i<count-1;i++)
     {
      if(StdDev_smoothing[i]<StdDev_smoothing[i+1])
        {
         FlagPos=false; break;
        }
      else
        {
         result++;
         if(result>3)
           {
            FlagPos=true; break;
           }
        }
     }*/
//--- check flat
   int result=0;
   for(int i=0;i<count-1;i++)
     {
      if(StdDev_smoothing[i]>StdDev_smoothing[i+1])
        {
         break;
        }
      else
        {
         result++;
         if(result>FletBars)
           {
            flagup=true;flagdw=true;break;
           }
        }
     }
//---
   if(result>FletBars)
      return(result);
   else
      return(0);
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
//| Calculate all pending orders                                     |
//+------------------------------------------------------------------+
void CalculateAllPendingOrders(int &count_buy_stops,int &count_sell_stops)
  {
   count_buy_stops   = 0;
   count_sell_stops  = 0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               count_buy_stops++;
            else if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               count_sell_stops++;
           }
  }
//+------------------------------------------------------------------------------+
//| Price max and min flat bar                                                   |
//+------------------------------------------------------------------------------+
bool PriceFlatBar(int bar,double &highest,double &lowest)
  {
   if(bar<=0)
      return(false);
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int start_pos=0,count=bar+1;
   if(CopyRates(m_symbol.Name(),Period(),start_pos,count,rates)!=count)
      return(false);
//---
   highest  = DBL_MIN;
   lowest   = DBL_MAX;
//---
   for(int i=0;i<count;i++)
     {
      if(rates[i].high>highest)
         highest=rates[i].high;
      if(rates[i].low<lowest)
         lowest=rates[i].low;
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| InpUseTrailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void Trailing(const double stop_level)
  {
   if(!InpTrailingStop)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                     if(ExtTrailingStop>=stop_level)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                        continue;
                       }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                     if(ExtTrailingStop>=stop_level)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                       }
              }

           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
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
   Print("Freeze Level: "+DoubleToString(m_symbol.FreezeLevel(),2));
   Print("Stops Level: "+DoubleToString(m_symbol.StopsLevel(),2));
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   digits--;
   if(digits<0)
      digits=0;
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------------------+
//| Get lots                                                                     |
//+------------------------------------------------------------------------------+
double GetLots()
  {
/*
   input bool     InpMM             = true;     // Включение функции мани-менеджмента 
   input ushort   InpHistoryDays    = 60;       // History days
   input int      InpNumberLoss     = 0;        // Количество убыточных сделок
   input int      InpMaxLoss        = 4;        // Максимальное количество убыточных сделок
   input double   InpMultiLoss      = 4.0;      // Множитель после убыточной сделки
   input int      InpNumberProfit   = 0;        // Количество сделок в истории закрытых по ТР
   input int      InpMaxProfit      = 4;        // Максимальное количество сделок в истории закрытых по ТР
   input double   InpMultiProfit    = 2.0;      // Множитель после прибыльной сделки
*/
   double   Lot   = InpLots;
   int      Loss  = 0;
   int      Profit= 0;
   if(!InpMM)
      return(InpLots);
//--- select history for access
   datetime time=TimeTradeServer();
   HistorySelect(time-InpHistoryDays*60*60*24,time+60*60*24);
//---
   int    deals=HistoryDealsTotal();   // total history deals
   int    losses=0;                    // number of losses deals without a break
   int    profits=0;                   // number of profits deals without a break

   for(int i=deals-1;i>=0;i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         Print("HistoryDealGetTicket failed, no trade history");
         break;
        }
      //--- check symbol
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=m_symbol.Name())
         continue;
      //--- check Expert Magic number
      if(HistoryDealGetInteger(ticket,DEAL_MAGIC)!=m_magic)
         continue;
      //--- check reason and profit
      long     deal_reason = HistoryDealGetInteger(ticket,DEAL_REASON);
      double   deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);

      if(deal_reason==DEAL_REASON_SL)
        {
         losses++;
         if(profits>0)
            break;
        }
      if(deal_reason==DEAL_REASON_TP)
        {
         profits++;
         if(losses>0)
            break;
        }
     }
//---
   if(InpNumberLoss>0)
     {
      if(losses<InpMaxLoss && losses>=InpNumberLoss)
         Lot=Lot*InpMultiLoss;
     }
//--- 
   if(InpNumberProfit>0)
     {
      if(profits<InpMaxProfit && profits>=InpNumberProfit)
         Lot=Lot*InpMultiProfit;
     }
//--- normalize and check limits
   double stepvol=m_symbol.LotsStep();
   Lot=stepvol*NormalizeDouble(Lot/stepvol,0);

   double minvol=m_symbol.LotsMin();
   if(Lot<minvol)
      Lot=minvol;

   double maxvol=m_symbol.LotsMax();
   if(Lot>maxvol)
      Lot=maxvol;
//---
   return(Lot);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions(void)
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Pending order                                                    |
//+------------------------------------------------------------------+
bool PendingOrder(ENUM_ORDER_TYPE order_type,double lot,double price,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   ENUM_ORDER_TYPE check_order_type=-1;
   switch(order_type)
     {
      case  ORDER_TYPE_BUY:
         check_order_type=ORDER_TYPE_BUY;
         break;
      case ORDER_TYPE_SELL:
         check_order_type=ORDER_TYPE_SELL;
         break;
      case ORDER_TYPE_BUY_LIMIT:
         check_order_type=ORDER_TYPE_BUY;
         break;
      case ORDER_TYPE_SELL_LIMIT:
         check_order_type=ORDER_TYPE_SELL;
         break;
      case ORDER_TYPE_BUY_STOP:
         check_order_type=ORDER_TYPE_BUY;
         break;
      case ORDER_TYPE_SELL_STOP:
         check_order_type=ORDER_TYPE_SELL;
         break;
      default:
         return(false);
         break;
     }
//---
   double long_lot   = lot;
   double short_lot  = lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_price=0;
   double check_lot=0;
   if(check_order_type==ORDER_TYPE_BUY)
     {
      check_price=m_symbol.Ask();
      check_lot=long_lot;
     }
   else
     {
      check_price=m_symbol.Bid();
      check_lot=short_lot;
     }
//---
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),check_order_type,check_lot,check_price);
   if(free_margin_check>0.0)
     {
      if(m_trade.OrderOpen(m_symbol.Name(),order_type,check_lot,0.0,
         m_symbol.NormalizePrice(price),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
        {
         if(m_trade.ResultOrder()==0)
           {
            Print("#1 ",EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
            return(false);
           }
         else
           {
            Print("#2 ",EnumToString(order_type)," -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
            return(true);
           }
        }
      else
        {
         Print("#3 ",EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
         return(false);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return(false);
     }
//---
   return(false);
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
   Print("Freeze Level: "+DoubleToString(m_symbol.FreezeLevel(),2));
   Print("Stops Level: "+DoubleToString(m_symbol.StopsLevel(),2));
  }
//+------------------------------------------------------------------+
