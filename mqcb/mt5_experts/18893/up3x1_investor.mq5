//+------------------------------------------------------------------+
//|                      up3x1 Investor(barabashkakvn's edition).mq5 |
//|                                Copyright © 2006, izhutov aKa PPP |
//|                                                izhutov@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedMargin m_money;
//--- input parameters
sinput string  InpTradeParameters="*-*-*-*"; // Trade parameters
input ushort   InpStopLoss          = 50;    // Stop Loss (in pips)
input ushort   InpTakeProfit        = 20;    // Take Profit (in pips)
input ushort   InpTrailingStop      = 30;    // Trailing Stop (in pips)
input ushort   InpTrailingStep      = 5;     // Trailing Step (in pips)
input double   InpRisk              = 5;     // Risk in percent for a deal from a free margin
input ushort   InpDecreasedFactor   = 3;     // Decreased factor (based on the history of trading)
input ushort   InpHistoryDays       = 10;    // History days (only if "Decreased factor" > 0)
sinput string  InpDifferenceParameters="*-*-*-*";// Difference parameters
input ushort   InpDifference_H1_L1=50;       // Difference high#1 minus low#1 (in pips)
input ushort   InpDifference_O1_C1=20;       // Difference open#1 minus close#1 (in pips)
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0;
double         ExtTakeProfit=0;
double         ExtTrailingStop=0;
double         ExtTrailingStep=0;
double         ExtDifference_H1_L1=0;
double         ExtDifference_O1_C1=0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
datetime       PrevBars=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   PrevBars=0;

   ExtStopLoss          =InpStopLoss*m_adjusted_point;
   ExtTakeProfit        =InpTakeProfit*m_adjusted_point;
   ExtTrailingStop      =InpTrailingStop*m_adjusted_point;
   ExtTrailingStep      =InpTrailingStep*m_adjusted_point;
   ExtDifference_H1_L1  =InpDifference_H1_L1*m_adjusted_point;
   ExtDifference_O1_C1  =InpDifference_O1_C1*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk);
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
//--- we work only at the time of the birth of new bar
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(!IsTradeAllowed() || str1.day_of_week==1)
      return;

   if(CalculateAllPositions()==0)
      CheckForOpen();
   else
      Trailing();
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
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
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotsOptimized(ENUM_ORDER_TYPE order_type,double sl,double tp)
  {
   double result=0.0;

   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   if(order_type==ORDER_TYPE_BUY)
     {
      double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      //Print("sl=",DoubleToString(sl,m_symbol.Digits()),
      //      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
      //      ", Balance: ",    DoubleToString(m_account.Balance(),2),
      //      ", Equity: ",     DoubleToString(m_account.Equity(),2),
      //      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
         return(result);

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(check_volume_lot!=0.0)
         if(check_volume_lot>=check_open_long_lot)
            result=check_open_long_lot;
     }
   else if(order_type==ORDER_TYPE_SELL)
     {
      double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      //Print("sl=",DoubleToString(sl,m_symbol.Digits()),
      //      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
      //      ", Balance: ",    DoubleToString(m_account.Balance(),2),
      //      ", Equity: ",     DoubleToString(m_account.Equity(),2),
      //      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
         return(result);

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(check_volume_lot!=0.0)
         if(check_volume_lot>=check_open_short_lot)
            result=check_open_short_lot;
     }
//---
   if(InpDecreasedFactor>0)
     {
      int losses=0;
      //--- request trade history 
      HistorySelect(TimeCurrent()-InpHistoryDays*60*60*24,TimeCurrent()+60*60*24);
      //--- 
      uint     total=HistoryDealsTotal();
      ulong    ticket=0;
      double   profit;
      string   symbol;
      long     type;
      long     entry;
      long     magic;
      //--- for all deals 
      for(uint i=0;i<total;i++)
        {
         //--- try to get deals ticket 
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- get deals properties 
            symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
            entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
            profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
            //--- only for current symbol 
            if(symbol==m_symbol.Name() && magic==m_magic)
               if(entry==DEAL_ENTRY_OUT)
                  if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL)
                     if(profit<0.0)
                        losses++;
           }
        }

      if(losses>1)
        {
         result=LotCheck(result-result*(double)losses/(double)InpDecreasedFactor);
        }
     }
//---
   return(result);
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
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double OP_1=iOpen(1);
   double HI_1=iHigh(1);
   double LO_1=iLow(1);
   double CL_1=iClose(1);

//--- buy
   if(HI_1-LO_1>ExtDifference_H1_L1 && OP_1<CL_1 && MathAbs(OP_1-CL_1)>ExtDifference_O1_C1)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      double volume=LotsOptimized(ORDER_TYPE_BUY,sl,tp);
      if(volume==0.0)
        {
         Comment("Volume of trade BUY == 0.0");
         return;
        }
      else
         Comment("Volume of trade BUY == ",DoubleToString(volume,2));

      m_trade.Buy(volume,m_symbol.Name(),m_symbol.Ask(),
                  m_symbol.NormalizePrice(sl),
                  m_symbol.NormalizePrice(tp));
      return;
     }
//--- sell
   if(HI_1-LO_1>ExtDifference_H1_L1 && OP_1>CL_1 && OP_1-CL_1>ExtDifference_O1_C1)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      double volume=LotsOptimized(ORDER_TYPE_SELL,sl,tp);
      if(volume==0.0)
        {
         Comment("Volume of trade SELL == 0.0");
         return;
        }
      else
         Comment("Volume of trade SELL == ",DoubleToString(volume,2));

      m_trade.Sell(volume,m_symbol.Name(),m_symbol.Bid(),
                   m_symbol.NormalizePrice(sl),
                   m_symbol.NormalizePrice(tp));
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(ExtTrailingStop>0)
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStep+ExtTrailingStop)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStep+ExtTrailingStop))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStep+ExtTrailingStop)
                     if(m_position.StopLoss()>m_position.PriceCurrent()+(ExtTrailingStep+ExtTrailingStop) || m_position.StopLoss()==0.0)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
              }
  }
//+------------------------------------------------------------------+
