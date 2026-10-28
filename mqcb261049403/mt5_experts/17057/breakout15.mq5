//+------------------------------------------------------------------+
//|                                                   BreakOut15.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin *m_money;
//--- input parameters
input ENUM_TIMEFRAMES      SignalTimeFrame      = PERIOD_M15;     // Working timeframe
input ushort               InpStopLoss          = 50;             // Stop Loss (in pips)
input ushort               InpTakeProfit        = 50;             // Take Profit (in pips)
input ushort               InpTrailingStop      = 15;             // Trailing Stop (in pips)
input ushort               InpTrailingStep      = 5;              // Trailing Step (in pips)
//---
input int                  FastMA_ma_period     = 10;             // MA Fast: averaging period 
input int                  FastMA_ma_shift      = 0;              // MA Fast: horizontal shift 
input ENUM_MA_METHOD       FastMA_ma_method     = MODE_SMA;       // MA Fast: smoothing type 
input ENUM_APPLIED_PRICE   FastMA_applied_price = PRICE_CLOSE;    // MA Fast: type of price or handle 
input int                  SlowMA_ma_period     = 80;             // MA Slow: averaging period 
input int                  SlowMA_ma_shift      = 0;              // MA Slow: horizontal shift 
input ENUM_MA_METHOD       SlowMA_ma_method     = MODE_SMA;       // MA Slow: smoothing type 
input ENUM_APPLIED_PRICE   SlowMA_applied_price = PRICE_CLOSE;    // MA Slow: type of price or handle 
//---
input int                  InpStartHour         = 7;              // Start Hour ("-1" -> OFF "Start Hour" and "Stop Hour")
input int                  InpStopHour          = 16;             // Stop Hour  ("-1" -> OFF "Start Hour" and "Stop Hour")
input int                  InpFridayCloseHour   = 20;             // Friday Close Hour ("-1" -> OFF)
input ushort               InpBreakOutLevel     = 10;             // BreakOut Level
input double               InpLots              = 0;              // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double               Risk                 = 5;              // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input ulong                m_magic              = 8332716;        // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         ExtBreakOutLevel=0.0;

int    handle_iMA_Fast;                      // variable for storing the handle of the iMA indicator 
int    handle_iMA_Slow;                      // variable for storing the handle of the iMA indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//---
bool YesStop=false;
int TradesInThisSymbol=-1;
double LongTradeRate=0.0;
double ShortTradeRate=0.0;
bool Converted=true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()!=PERIOD_M1)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Эксперт необходимо запускать ТОЛЬКО НА таймфрейме M1!":
                  "Expert must be run ONLY ON M1 timeframe!";
      Alert(__FUNCTION__,", ERROR! ",text);
      return(INIT_FAILED);
     }
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                  "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartHour<-1 || InpStartHour>23)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Параметр \"Start Hour\" не может быть меньше \"-1\" или больше \"23\"!":
                  "Parameter \"Start Hour\" can not be less than \"-1\" or greater \"23\"!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStopHour<-1 || InpStopHour>23)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Параметр \"Stop Hour\" не может быть меньше \"-1\" или больше \"23\"!":
                  "Parameter \"Stop Hour\" can not be less than \"-1\" or greater \"23\"!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartHour>=InpStopHour)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Параметр \"Start Hour\" не может быть равен или больше \"Stop Hour\"!":
                  "Parameter \"Start Hour\" can not be equal to or greater than \"Stop Hour\"!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
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
   ExtBreakOutLevel  = InpBreakOutLevel   * m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(m_symbol.Name(),SignalTimeFrame,FastMA_ma_period,FastMA_ma_shift,FastMA_ma_method,FastMA_applied_price);
//--- if the handle is not created 
   if(handle_iMA_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(SignalTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Slow=iMA(m_symbol.Name(),SignalTimeFrame,SlowMA_ma_period,SlowMA_ma_shift,SlowMA_ma_method,SlowMA_applied_price);
//--- if the handle is not created 
   if(handle_iMA_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(SignalTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   if(!LotsOrRisk(InpLots,Risk,digits_adjust))
      return(INIT_PARAMETERS_INCORRECT);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Trailing();
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=Time(0,m_symbol.Name(),SignalTimeFrame);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
//---
   bool buy_exit;
   bool sell_exit;
   CheckExitCondition(buy_exit,sell_exit);
   if(buy_exit)
      ClosePositions(POSITION_TYPE_BUY);
   if(sell_exit)
      ClosePositions(POSITION_TYPE_SELL);
//--- only allow 1 trade per Symbol
   if(IsPositionExists())
      return;
//---
   bool buy_entry;
   bool sell_entry;
   CheckEntryCondition(buy_entry,sell_entry);
//--- check open
   if(LongTradeRate>0.1 && buy_entry)
      HandleOpenBuy();
   if(ShortTradeRate>0.1 && sell_entry)
      HandleOpenSell();

   if(buy_entry && LongTradeRate==0.0)
     {
      LongTradeRate=m_symbol.Ask()+ExtBreakOutLevel;
      ShortTradeRate=0.0;
      return;
     }
   if(sell_entry && ShortTradeRate==0.0)
     {
      ShortTradeRate=m_symbol.Bid()-ExtBreakOutLevel;
      LongTradeRate=0.0;
     }
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

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
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Lots or risk in percent for a deal from a free margin            |
//+------------------------------------------------------------------+
bool LotsOrRisk(const double lots,const double risk,const int digits_adjust)
  {
   if(lots<0.0 && risk<0.0)
     {
      Print(__FUNCTION__,", ERROR: Parameter (\"lots\" or \"risk\") can't be less than zero");
      return(false);
     }
   if(lots==0.0 && risk==0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" == 0.0 and \"risk\" == 0.0");
      return(false);
     }
   if(lots>0.0 && risk>0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" > 0.0 and \"risk\" > 0.0");
      return(false);
     }
   if(lots>0.0)
     {
      string err_text="";
      if(!CheckVolumeValue(lots,err_text))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(false);
        }
     }
   else if(risk>0.0)
     {
      if(m_money!=NULL)
         delete m_money;
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(risk);
        }
      else
        {
         Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
         return(INIT_FAILED);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime Time(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0; // datetime "0" -> D'1970.01.01 00:00:00'
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=0.0;
   if(Risk>0.0)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenLong returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_long_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenLong ("+DoubleToString(check_open_long_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=0.0;
   if(Risk>0.0)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenShort returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_short_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenShort ("+DoubleToString(check_open_short_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(InpLots,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
//int d=0;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//+------------------------------------------------------------------+
void CheckExitCondition(bool &buy_exit,bool &sell_exit)
  {
   buy_exit=false;
   sell_exit=false;

   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);

   if(InpFridayCloseHour!=-1 && STimeCurrent.day_of_week==5 && STimeCurrent.hour>=InpFridayCloseHour)
     {
      buy_exit=true;
      sell_exit=true;
      return;
     }
   double FastMA=iMAGet(handle_iMA_Fast,0);
   double SlowMA=iMAGet(handle_iMA_Slow,0);
   if(FastMA==0.0 || SlowMA==0.0)
     {
      buy_exit=false;
      sell_exit=false;
      return;
     }
//--- check for cross down
   if(FastMA<SlowMA)
      buy_exit=true;
//--- check for cross up
   if(FastMA>SlowMA)
      sell_exit=true;
//---
   return;
  }
//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//+------------------------------------------------------------------+
void CheckEntryCondition(bool &buy_entry,bool &sell_entry)
  {
   buy_entry=false;
   sell_entry=false;

   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);

   if((InpStartHour!=-1 && InpStopHour!=-1) && (STimeCurrent.hour<InpStartHour || STimeCurrent.hour>InpStopHour))
     {
      buy_entry=false;
      sell_entry=false;
      return;
     }
   double FastMA=iMAGet(handle_iMA_Fast,0);
   double SlowMA=iMAGet(handle_iMA_Slow,0);
   if(FastMA==0.0 || SlowMA==0.0)
     {
      buy_entry=false;
      sell_entry=false;
      return;
     }
//--- check for cross up
   if(FastMA>SlowMA)
      buy_entry=true;
//--- check for cross down
   if(FastMA<SlowMA)
      sell_entry=true;
//---
   return;
  }
//+------------------------------------------------------------------+
//| Handle Buy                                                       |
//+------------------------------------------------------------------+
void HandleOpenBuy()
  {
//--- check if still a valid breakout
   if(m_symbol.Ask()>=LongTradeRate)
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(sl,tp);
      LongTradeRate=0.0;
     }
//---

  }
//+------------------------------------------------------------------+
//| Handle Sell                                                      |
//+------------------------------------------------------------------+
void HandleOpenSell()
  {
   return;
//--- check if still a valid breakout
   if(m_symbol.Bid()<=ShortTradeRate)
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(sl,tp);
      ShortTradeRate=0.0;
     }
//---

  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
