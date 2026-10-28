//+------------------------------------------------------------------+
//|                                  Trailing Activate Close All.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property description "Stop Loss, Take Profit and Trailing - in Points (1.00055-1.00045=10 points)"
/*
   barabashkakvn Trading engine 4.017
*/
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
//---
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade         m_trade;                      // object of CTrade class
CSymbolInfo    m_symbol;                     // object of CSymbolInfo class
//+------------------------------------------------------------------+
//| Enum Bar Сurrent                                                 |
//+------------------------------------------------------------------+
enum ENUM_BAR_CURRENT
  {
   bar_0=0,    // bar #0 (at every tick)
   bar_1=1,    // bar #1 (on a new bar)
  };
//--- input parameters
input group             "Trading settings"
input ENUM_TIMEFRAMES      InpWorkingPeriod        = PERIOD_CURRENT; // Working timeframe
input uint                 InpStopLoss             = 150;            // Stop Loss, SL ('0' -> OFF)
input uint                 InpTakeProfit           = 460;            // Take Profit, TP ('0' -> OFF)
input ENUM_BAR_CURRENT     InpTrailingBarCurrent   = bar_1;          // Trailing on ...
input double               InpTargetProfit         = 5;              // Target Profit, in money ('0' -> OFF)
input group             "Trailing"
input uint                 InpTrailingActivate     = 70;             // Trailing activate if profit is >=
input uint                 InpTrailingStop         = 250;            // Trailing Stop, min distance from price to SL ('0' -> OFF)
input uint                 InpTrailingStep         = 50;             // Trailing Step
input group             "Additional features"
input bool                 InpPrintLog             = true;           // Print log
input uchar                InpFreezeCoefficient    = 1;              // Coefficient (if Freeze==0 Or StopsLevels==0)
input ulong                InpDeviation            = 10;             // Deviation, in Points (1.00045-1.00055=10 points)
//---
double   m_stop_loss                = 0.0;      // Stop Loss                  -> double
double   m_take_profit              = 0.0;      // Take Profit                -> double
double   m_trailing_activate        = 0.0;      // Trailing activate          -> double
double   m_trailing_stop            = 0.0;      // Trailing Stop              -> double
double   m_trailing_step            = 0.0;      // Trailing Step              -> double

bool     m_need_close_all           = false;    // close all positions
datetime m_prev_bars                = 0;        // "0" -> D'1970.01.01 00:00';
bool     m_init_error               = false;    // error on InInit
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- forced initialization of variables
   m_stop_loss                = 0.0;      // Stop Loss                  -> double
   m_take_profit              = 0.0;      // Take Profit                -> double
   m_trailing_activate        = 0.0;      // Trailing activate          -> double
   m_trailing_stop            = 0.0;      // Trailing Stop              -> double
   m_trailing_step            = 0.0;      // Trailing Step              -> double
   m_need_close_all           = false;    // close all positions
   m_prev_bars                = 0;        // "0" -> D'1970.01.01 00:00';
   m_init_error               = false;    // error on InInit
//---
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string err_text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                      "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                      "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
         Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
      else // if the Expert Advisor is run on the chart, tell the user about the error
         Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
      //---
      MessageBox(err_text,"INIT_PARAMETERS_INCORRECT");
      //---
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   ResetLastError();
   if(!m_symbol.Name(Symbol())) // sets symbol name
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: CSymbolInfo.Name");
      return(INIT_FAILED);
     }
   RefreshRates();
//---
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(InpDeviation);
//---
   m_stop_loss                = InpStopLoss                 * m_symbol.Point();
   m_take_profit              = InpTakeProfit               * m_symbol.Point();
   m_trailing_activate        = InpTrailingActivate         * m_symbol.Point();
   m_trailing_stop            = InpTrailingStop             * m_symbol.Point();
   m_trailing_step            = InpTrailingStep             * m_symbol.Point();
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
   if(m_init_error)
      return;
//--
   if(m_need_close_all)
     {
      if(IsPositionExists())
        {
         CloseAllPositions();
         return;
        }
      else
        {
         m_need_close_all=false;
        }
     }
//---
   if(InpTargetProfit>0.0)
      if(ProfitAllPositions()>=InpTakeProfit)
        {
         m_need_close_all=true;
         CloseAllPositions();
         return;
        }
//---
   if(InpTrailingBarCurrent==bar_0) // trailing at every tick
     {
      Trailing();
     }
   else
      if(InpTrailingBarCurrent==bar_1)// we work only at the time of the birth of new bar
        {
         datetime time_0=iTime(m_symbol.Name(),InpWorkingPeriod,0);
         if(time_0==m_prev_bars)
            return;
         m_prev_bars=time_0;
         if(InpTrailingBarCurrent==bar_1) // trailing only at the time of the birth of new bar
           {
            Trailing();
           }
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
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","Ask == 0.0 OR Bid == 0.0");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
void FreezeStopsLevels(double &freeze,double &stops)
  {
//--- check Freeze and Stops levels
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------

   SYMBOL_TRADE_STOPS_LEVEL determines the number of points for minimum indentation of the
      StopLoss and TakeProfit levels from the current closing price of the open position
   ------------------------------------------------|------------------------------------------
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|------------------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid                        |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   ------------------------------------------------------------------------------------------
   */
   double coeff=(double)InpFreezeCoefficient;
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
     {
      if(InpFreezeCoefficient>0)
         freeze_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
     }
   else
      freeze_level*=coeff;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
     {
      if(InpFreezeCoefficient>0)
         stop_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
     }
   else
      stop_level*=coeff;
//---
   freeze=freeze_level;
   stops=stop_level;
//---
   return;
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0) // Trailing Stop, min distance from price to SL ('0' -> OFF)
      return;
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   double max_levels=(freeze>stops)?freeze:stops;
   /*
   SYMBOL_TRADE_STOPS_LEVEL determines the number of points for minimum indentation of the
      StopLoss and TakeProfit levels from the current closing price of the open position
   ------------------------------------------------|------------------------------------------
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|------------------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid                        |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   ------------------------------------------------------------------------------------------

   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
//---
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name())
           {
            double price_current = m_position.PriceCurrent();
            double price_open    = m_position.PriceOpen();
            double stop_loss     = m_position.StopLoss();
            double take_profit   = m_position.TakeProfit();
            double ask           = m_symbol.Ask();
            double bid           = m_symbol.Bid();
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((stop_loss==0.0 && m_stop_loss>0.0) || (take_profit==0.0 && m_take_profit>0.0))
                 {
                  //--- if the position does not have SL or (and) TP
                  m_prev_bars=0;
                  if(stop_loss==0.0 && m_stop_loss>0.0)
                    {
                     stop_loss=m_symbol.Ask()-m_stop_loss;
                     if(m_symbol.Bid()-stop_loss<max_levels)
                        stop_loss=m_symbol.Bid()-max_levels;
                    }
                  if(take_profit==0.0 && m_take_profit>0.0)
                    {
                     take_profit=m_symbol.Ask()+m_take_profit;
                     if(take_profit-m_symbol.Ask()<max_levels)
                        take_profit=m_symbol.Ask()+max_levels;
                    }
                  //---
                  m_trade.SetExpertMagicNumber(m_position.Magic());
                  if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(stop_loss),m_symbol.NormalizePrice(take_profit)))
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                  if(InpPrintLog)
                    {
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                    }
                 }
               else
                 {
                  //--- regular trailing
                  if(price_current-price_open>=m_trailing_stop+m_trailing_step)
                     if(price_current-m_trailing_stop>=price_open+m_trailing_activate)
                        if(stop_loss<price_current-(m_trailing_stop+m_trailing_step))
                           if(m_trailing_stop>=max_levels && (take_profit-bid>=max_levels || take_profit==0.0))
                             {
                              m_trade.SetExpertMagicNumber(m_position.Magic());
                              if(!m_trade.PositionModify(m_position.Ticket(),
                                                         m_symbol.NormalizePrice(price_current-m_trailing_stop),
                                                         take_profit))
                                 if(InpPrintLog)
                                    Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify BUY ",m_position.Ticket(),
                                          " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                          ", description of result: ",m_trade.ResultRetcodeDescription());
                              if(InpPrintLog)
                                {
                                 RefreshRates();
                                 m_position.SelectByIndex(i);
                                 PrintResultModify(m_trade,m_symbol,m_position);
                                }
                              continue;
                             }
                 }
              }
            else
              {
               if((stop_loss==0.0 && m_stop_loss>0.0) || (take_profit==0.0 && m_take_profit>0.0))
                 {
                  //--- if the position does not have SL or (and) TP
                  m_prev_bars=0;
                  if(stop_loss==0.0 && m_stop_loss>0.0)
                    {
                     stop_loss=m_symbol.Bid()+m_stop_loss;
                     if(stop_loss-m_symbol.Ask()<max_levels)
                        stop_loss=m_symbol.Ask()+max_levels;
                    }
                  if(take_profit==0.0 && m_take_profit>0.0)
                    {
                     take_profit=m_symbol.Bid()-m_take_profit;
                     if(m_symbol.Bid()-take_profit<max_levels)
                        take_profit=m_symbol.Bid()-max_levels;
                    }
                  //---
                  m_trade.SetExpertMagicNumber(m_position.Magic());
                  if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(stop_loss),m_symbol.NormalizePrice(take_profit)))
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                  if(InpPrintLog)
                    {
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                    }
                 }
               else
                 {
                  if(price_open-price_current>=m_trailing_stop+m_trailing_step)
                     if(price_current+m_trailing_stop<=price_open-m_trailing_activate)
                        if((stop_loss>(price_current+(m_trailing_stop+m_trailing_step))) || (stop_loss==0))
                           if(m_trailing_stop>=max_levels && ask-take_profit>=max_levels)
                             {
                              m_trade.SetExpertMagicNumber(m_position.Magic());
                              if(!m_trade.PositionModify(m_position.Ticket(),
                                                         m_symbol.NormalizePrice(price_current+m_trailing_stop),
                                                         take_profit))
                                 if(InpPrintLog)
                                    Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify SELL ",m_position.Ticket(),
                                          " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                          ", description of result: ",m_trade.ResultRetcodeDescription());
                              if(InpPrintLog)
                                {
                                 RefreshRates();
                                 m_position.SelectByIndex(i);
                                 PrintResultModify(m_trade,m_symbol,m_position);
                                }
                             }
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Freeze Level: "+DoubleToString(symbol.FreezeLevel(),0),", Stops Level: "+DoubleToString(symbol.StopsLevel(),0));
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }

//+------------------------------------------------------------------+
//| Profit all positions                                             |
//+------------------------------------------------------------------+
double ProfitAllPositions(void)
  {
   double profit=0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
            profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
//---
   return(profit);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(void)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            m_trade.SetExpertMagicNumber(m_position.Magic());
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 && m_position.TakeProfit()-m_position.PriceCurrent()>=freeze) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 && m_position.PriceCurrent()-m_position.StopLoss()>=freeze) || m_position.StopLoss()==0.0;
               if(take_profit_level && stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","BUY PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 && m_position.PriceCurrent()-m_position.TakeProfit()>=freeze) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 && m_position.StopLoss()-m_position.PriceCurrent()>=freeze) || m_position.StopLoss()==0.0;
               if(take_profit_level && stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","SELL PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
              }
           }
  }
//+------------------------------------------------------------------+
