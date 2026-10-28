//+------------------------------------------------------------------+
//|                             freeman(barabashkakvn's edition).mq5 |
//|                              Copyright 2011 www.all-webmoney.com |
//|                                          http://all-webmoney.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011 www.all-webmoney.com"
#property link      "http://all-webmoney.com"
#property version   "1.000"
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
input string   _Section_1_       = "--- Base settings ---";
input uchar    InpATRStopLoss    = 3;        // Stop Loss
input uchar    InpATRTakeProfit  = 2;        // Take Profit
input int      InpMaxPositions   = 5;        // Maximum positions
input ushort   InpDistance       = 5;        // Distance (in pips)
input bool     InpUseBarsControl = true;     // Bars Control
input int      Inp_ATR_ma_period = 9;        // ATR: averaging period  
input string   _Section_2_       = "--- Money Managment ---";
input double   InpLots           = 0;        // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double   Risk              = 15;       // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input string   _Section_3_       = "--- Trailing ---";
input ushort   InpTrailingStop   = 5;        // Trailing Stop (min distance from price to Stop Loss) (in pips)
input ushort   InpTrailingStep   = 5;        // Trailing Step (in pips)
input string   _Section_4_       = "--- Strategy ---";
input uchar    InpCurrentBar     = 0;        // Current Bar 
input bool     InpUseTrendFilter = true;     // Trend filter MA
input ushort   InpDistanceMA     = 5;        // Minimum distance between price and indicator MA (in pips)
input int                  Inp_MA_ma_period     = 30;             // MA: averaging period 
input int                  Inp_MA_ma_shift      = 1;              // MA: horizontal shift 
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_SMA;       // MA: smoothing type 
input ENUM_APPLIED_PRICE   Inp_MA_applied_price = PRICE_MEDIAN;   // MA: type of price 
input bool     InpUseRSIFilter      = true;  // RSI filter
input double   InpRSILevelUP        = 65.0;  // RSI level UP
input double   InpRSILevelDOWN      = 25.0;  // RSI level DOWN
input int                  Inp_RSI_ma_period    = 25;             // RSI: averaging period 
input ENUM_APPLIED_PRICE   Inp_RSI_applied_price= PRICE_MEDIAN;   // RSI: type of price
input ulong    m_magic=849410218;            // magic number
//---
ulong  m_slippage=10;               // slippage

double ExtDistance=0.0;
double ExtTrailingStop=0.0;
double ExtTrailingStep=0.0;
double ExtDistanceMA=0.0;

int    handle_iMA;                  // variable for storing the handle of the iMA indicator 
int    handle_iATR;                 // variable for storing the handle of the iATR indicator 
int    handle_iRSI;                 // variable for storing the handle of the iRSI indicator

double m_adjusted_point;            // point value adjusted for 3 or 5 points

double m_last_buy_profit=0.0;
double m_last_sell_profit=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Неттинг запрещён! Разрешены только хедж счета!":
                  "Netting is forbidden! Only hedge accounts are allowed!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_FAILED);
     }
   if(InpMaxPositions==0)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Торговля невозможна! \"Maximum positions\" == 0!":
                  "Trade is impossible! \"Maximum positions\" == 0!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                  "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(!InpUseTrendFilter && !InpUseRSIFilter)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Торговля невозможна: оба параметра (\"Trend filter MA\" и \"RSI filter\") имеют значение false!":
                  "Trade is impossible: both parameters (\"Trend filter MA\" and \"RSI filter\") have the meaning of false!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
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

   ExtDistance    = InpDistance     * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
   ExtDistanceMA  = InpDistanceMA   * m_adjusted_point;
//---
   if(InpUseTrendFilter)
     {
      //--- create handle of the indicator iMA
      handle_iMA=iMA(m_symbol.Name(),Period(),Inp_MA_ma_period,Inp_MA_ma_shift,
                     Inp_MA_ma_method,Inp_MA_applied_price);
      //--- if the handle is not created 
      if(handle_iMA==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
//--- create handle of the indicator iATR
   handle_iATR=iATR(m_symbol.Name(),Period(),Inp_ATR_ma_period);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   if(InpUseRSIFilter)
     {
      //--- create handle of the indicator iRSI
      handle_iRSI=iRSI(m_symbol.Name(),Period(),Inp_RSI_ma_period,Inp_RSI_applied_price);
      //--- if the handle is not created 
      if(handle_iRSI==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
//---
   if(!LotsOrRisk(InpLots,Risk,digits_adjust))
      return(INIT_PARAMETERS_INCORRECT);
   return(INIT_SUCCEEDED);
//---
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
//---
   if(InpUseBarsControl)
     {
      //--- we work only at the time of the birth of new bar
      static datetime PrevBars=0;
      datetime time_0=iTime(m_symbol.Name(),Period(),0);
      if(time_0==PrevBars)
         return;
      PrevBars=time_0;
     }
   if(!RefreshRates())
      return;
   int count_buys=0,count_sells=0;
   double price_open_last_buy=DBL_MIN,price_open_last_sell=DBL_MIN;
   CalculateAllPositions(count_buys,count_sells,price_open_last_buy,price_open_last_sell);
   if(count_buys+count_sells>=InpMaxPositions)
      return;
//+------------------------------------------------------------------+
//| Get Signal                                                       |
//|  " 1" --> BUY                                                    |
//|  " 0" --> NONE                                                   |
//|  "-1" --> SELL                                                   |
//+------------------------------------------------------------------+
   int signal=GetSignal();
   if(signal==0)
      return;
   double atr_array[];
   if(!iGetArray(handle_iATR,0,InpCurrentBar,1,atr_array))
      return;
//--- open BUY without locks
   if(count_buys==0 && signal==1)
     {
      double sl=(InpATRStopLoss==0)?0.0:m_symbol.Ask()-InpATRStopLoss*atr_array[0];
      if(sl>=m_symbol.Bid()) // incident: the position isn't opened yet, and has to be already closed
         return;
      double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Ask()+InpATRTakeProfit*atr_array[0];
      OpenBuy(sl,tp,"");
      return;
     }
   if(count_buys>0 && signal==1)
     {
      if(price_open_last_buy!=DBL_MIN && price_open_last_buy-m_symbol.Ask()>=ExtDistance)
        {
         double sl=(InpATRStopLoss==0)?0.0:m_symbol.Ask()-InpATRStopLoss*atr_array[0];
         if(sl>=m_symbol.Bid()) // incident: the position isn't opened yet, and has to be already closed
            return;
         double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Ask()+InpATRTakeProfit*atr_array[0];
         OpenBuy(sl,tp,"");
        }
      return;
     }
//--- open BUY and locks
   if(count_buys>0 && signal==1 && m_last_buy_profit<0.0)
     {
      if(price_open_last_buy!=DBL_MIN && price_open_last_buy-m_symbol.Ask()>=MathAbs(ExtDistance))
        {
         double sl=(InpATRStopLoss==0)?0.0:m_symbol.Ask()-InpATRStopLoss*atr_array[0];
         if(sl>=m_symbol.Bid()) // incident: the position isn't opened yet, and has to be already closed
            return;
         double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Ask()+InpATRTakeProfit*atr_array[0];
         OpenBuy(sl,tp,"locks");
        }
      return;
     }
//--- open SELL without locks
   if(count_sells==0 && signal==-1)
     {
      double sl=(InpATRStopLoss==0)?0.0:m_symbol.Bid()+InpATRStopLoss*atr_array[0];
      if(sl<=m_symbol.Ask()) // incident: the position isn't opened yet, and has to be already closed
         return;
      double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Bid()-InpATRTakeProfit*atr_array[0];
      OpenSell(sl,tp,"");
      return;
     }
   if(count_sells>0 && signal==-1)
     {
      if(price_open_last_sell!=DBL_MIN && m_symbol.Bid()-price_open_last_sell>=ExtDistance)
        {
         double sl=(InpATRStopLoss==0)?0.0:m_symbol.Bid()+InpATRStopLoss*atr_array[0];
         if(sl<=m_symbol.Ask()) // incident: the position isn't opened yet, and has to be already closed
            return;
         double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Bid()-InpATRTakeProfit*atr_array[0];
         OpenSell(sl,tp,"");
        }
      return;
     }
//--- open SELL and locks
   if(count_sells>0 && signal==-1 && m_last_sell_profit<0.0)
     {
      if(price_open_last_sell!=DBL_MIN && m_symbol.Bid()-price_open_last_sell>=MathAbs(ExtDistance))
        {
         double sl=(InpATRStopLoss==0)?0.0:m_symbol.Bid()+InpATRStopLoss*atr_array[0];
         if(sl<=m_symbol.Ask()) // incident: the position isn't opened yet, and has to be already closed
            return;
         double tp=(InpATRTakeProfit==0)?0.0:m_symbol.Bid()-InpATRTakeProfit*atr_array[0];
         OpenSell(sl,tp,"locks");
        }
      return;
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
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_type==DEAL_TYPE_BUY)
               m_last_buy_profit=deal_profit;
            else if(deal_type==DEAL_TYPE_SELL)
               m_last_sell_profit=deal_profit;
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
//| Trailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
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
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Calculate all positions Buy and Sell                             |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,int &count_sells,
                           double &price_open_last_buy,double &price_open_last_sell)
  {
   count_buys=0;
   count_sells=0;
   datetime time_open_last_buy=0;
   datetime time_open_last_sell=0;
   price_open_last_buy=DBL_MIN;
   price_open_last_sell=DBL_MIN;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               if(m_position.Time()>time_open_last_buy)
                 {
                  time_open_last_buy=m_position.Time();
                  price_open_last_buy=m_position.PriceOpen();
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               count_sells++;
               if(m_position.Time()>time_open_last_sell)
                 {
                  time_open_last_sell=m_position.Time();
                  price_open_last_sell=m_position.PriceOpen();
                 }
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Get Signal                                                       |
//|  " 1" --> BUY                                                    |
//|  " 0" --> NONE                                                   |
//|  "-1" --> SELL                                                   |
//+------------------------------------------------------------------+
int GetSignal()
  {
   double ma_curr=DBL_MIN;
   double ma_prev=DBL_MIN;
   double rsi_curr=DBL_MIN;
   int ma_signal=0;
   int rsi_signal=0;
   if(InpUseTrendFilter)
     {
      double ma_array[];
      ArraySetAsSeries(ma_array,true);
      if(!iGetArray(handle_iMA,0,InpCurrentBar,2,ma_array))
         return(0);
      if(ma_array[0]>ma_array[1])
         ma_signal=1;
      else if(ma_array[0]<ma_array[1])
         ma_signal=-1;
      if(ma_signal==0)
         return(0);
      //---
      if(InpDistanceMA!=0.0)
        {
         double price=(ma_signal==-1)?m_symbol.Bid():m_symbol.Ask();
         if(ma_signal==1 && price-ma_array[0]<ExtDistanceMA)
            return(0);
         if(ma_signal==-1 && ma_array[0]-price<ExtDistanceMA)
            return(0);
        }
     }
   if(InpUseRSIFilter)
     {
      double rsi_array[];
      if(!iGetArray(handle_iRSI,0,InpCurrentBar,1,rsi_array))
         return(0);
      if(rsi_array[0]>InpRSILevelUP)
         rsi_signal=-11;
      else if(rsi_array[0]<InpRSILevelDOWN)
         rsi_signal=1;
      if(rsi_signal==0)
         return(0);
      //---

     }
//---
   if(!InpUseTrendFilter)
      return(rsi_signal);
   if(!InpUseRSIFilter)
      return(ma_signal);
   if(ma_signal==rsi_signal)
      return(ma_signal);
//---
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,string comment)
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
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp,comment))
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
void OpenSell(double sl,double tp,string comment)
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
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp,comment))
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
