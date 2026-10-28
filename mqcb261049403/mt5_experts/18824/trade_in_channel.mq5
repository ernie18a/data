//+------------------------------------------------------------------+
//|                    Trade in Channel(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, George-on-Don"
#property link      "http://www.forex.aaanet.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin m_money;
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//--- input parameters
input double   InpRisk           = 2;        // Risk in percent for a deal from a free margin
input bool     InpSendMail       = true;     // Send mail
input bool     InpLotsOnHistory  = true;     // Lot based on history (if true -> means "Risk ..." is disabled
input uchar    InpDcF            = 3;        // Factor to optimisation (only if "Lot based on history = true")
input uchar    InpDaysAgo        = 30;       // Days ago (only if "Lot based on history = true")
input int      Inp_ma_period_ATR = 4;        // ATR averaging period  
input int      Inp_rChannel      = 20;       // Periods channel
input double   InpTrailingStop   = 30;       // Trailing Stop (in pips)
//---
ulong          m_magic=439237695;            // magic number
ulong          m_slippage=30;                // slippage
//--- global variables
double Resist=0.0;
double ResistPrev=0.0;
double Support=0.0;
double SupportPrev=0.0;
double Pivot=0.0;
//---
datetime       PrevBars=0;
double         ExtTrailingStop=0;
int            handle_iATR;                  // variable for storing the handle of the iATR indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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

   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk);
//--- create handle of the indicator iATR
   handle_iATR=iATR(m_symbol.Name(),Period(),Inp_ma_period_ATR);
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
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   if(Bars(m_symbol.Name(),Period())<25 || !IsTradeAllowed())
      return;
   if(!RefreshRates())
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }
//--- calculate open positions by current symbol
   if(CalculateAllPositions()==0)
     {
      CheckForOpen();
     }
   else
      CheckForClose();
//---
  }
//+------------------------------------------------------------------+
//| calculate value trade lots                                       |
//+------------------------------------------------------------------+
double LotsOptimized(ENUM_ORDER_TYPE order_type)
  {
   if(order_type!=ORDER_TYPE_BUY && order_type!=ORDER_TYPE_SELL)
      return(0.0);
   double check_open_lot=0.0;
   if(order_type==ORDER_TYPE_BUY)
      check_open_lot=m_money.CheckOpenLong(m_symbol.Ask(),0.0);
   if(order_type==ORDER_TYPE_SELL)
      check_open_lot=m_money.CheckOpenShort(m_symbol.Bid(),0.0);
   if(check_open_lot==0.0)
      return(0.0);

   double lot=check_open_lot;
   if(InpLotsOnHistory && InpDcF>0) // if InpLotsOnHistory true then optimise value lots else value lots = const
     {
      int      losses=0;            // number of losses orders without a break

      datetime from_date= TimeCurrent()-InpDaysAgo*60*60*24;   // from date 
      datetime to_date  = TimeCurrent()+60*60*24;              // to date 
      if(!HistorySelect(from_date,to_date))
         return(0.0);
      uint     deals_total       = HistoryDealsTotal();
      ulong    deal_ticket       = 0;
      long     deal_entry        = 0;
      double   deal_profit       = 0.0;
      string   deal_symbol       = "";
      long     deal_magic        = 0;
      //--- for all deals 
      for(uint i=0;i<deals_total;i++)
        {
         //--- try to get deals ticket 
         if((deal_ticket=HistoryDealGetTicket(i))>0)
           {
            //--- get deals properties 
            deal_entry  = HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
            deal_profit = HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
            deal_symbol = HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
            deal_magic  = HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
            //--- only for current symbol and magic and for "entry out"
            if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
               if(deal_entry==DEAL_ENTRY_OUT)
                  if(deal_profit<0)
                     losses++;
           }
        }
      if(losses>1)
        {
         lot=lot-lot*losses/InpDcF;
         lot=LotCheck(lot);
        }
     }
//--- return lot size
   return(lot);
  }
//+------------------------------------------------------------------+
//| Calculate channel periods                                        |
//+------------------------------------------------------------------+
void defPcChannel()
  {
   Resist=iHighest(m_symbol.Name(),Period(),MODE_HIGH,Inp_rChannel,1); // up channel   
   ResistPrev=iHighest(m_symbol.Name(),Period(),MODE_HIGH,Inp_rChannel,2);
   Support=iLowest(m_symbol.Name(),Period(),MODE_LOW,Inp_rChannel,1);
   SupportPrev=iLowest(m_symbol.Name(),Period(),MODE_LOW,Inp_rChannel,2);
   Pivot=(Resist+Support+iClose(m_symbol.Name(),Period(),1))/3;
  }
//+------------------------------------------------------------------+
//| Is open trade BUY?                                               |
//+------------------------------------------------------------------+
bool isOpenBuy()
  {
   bool result=false;
   if(iHigh(m_symbol.Name(),Period(),1)>=Resist && Resist==ResistPrev)
      return(true);
   double close_1=iClose(m_symbol.Name(),Period(),1);
   if(close_1<Resist && Resist==ResistPrev && close_1>Pivot)
      return(true);

   return(result);
  }
//+------------------------------------------------------------------+
//| Is open trade SELL?                                              |
//+------------------------------------------------------------------+
bool isOpenSell()
  {
   bool result=false;
   if(iLow(m_symbol.Name(),Period(),1)<=Support && Support==SupportPrev)
      return(true);

   double close_1=iClose(m_symbol.Name(),Period(),1);
   if(close_1>Support && Support==SupportPrev && close_1<Pivot)
      return(true);

   return(result);
  }
//+------------------------------------------------------------------+
//| Is open trade on?                                                |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   string sHeaderLetter="";
   string sBodyLetter="";
//---
   double Atr=iATRGet(1);
   defPcChannel();
//--- is Sell?
   if(isOpenBuy())
     {
      bool result=OpenSell(LotsOptimized(ORDER_TYPE_SELL),Resist+Atr,0.0);
      if(InpSendMail && result)
        {
         sHeaderLetter="SELL by "+m_symbol.Name()+"";
         sBodyLetter="Sell by "+m_symbol.Name()+
                     " at "+DoubleToString(m_symbol.Bid(),m_symbol.Digits())+
                     ", and set stop/loss at "+DoubleToString(Resist+Atr,m_symbol.Digits())+"";
         sndMessage(sHeaderLetter,sBodyLetter);
        }
      return;
     }
//--- is Buy?
   if(isOpenSell())
     {
      bool result=OpenBuy(LotsOptimized(ORDER_TYPE_BUY),Support-Atr,0.0);
      if(InpSendMail && result)
        {
         sHeaderLetter="BUY at "+m_symbol.Name()+"";
         sBodyLetter="Buy at "+m_symbol.Name()+
                     " at "+DoubleToString(m_symbol.Ask(),m_symbol.Digits())+
                     ", and set stop/loss at "+DoubleToString(Support-Atr,m_symbol.Digits())+"";
         sndMessage(sHeaderLetter,sBodyLetter);
        }
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Is close trade?                                                  |
//+------------------------------------------------------------------+
bool isCloseSell()
  {
   defPcChannel();
   if(iLow(m_symbol.Name(),Period(),1)<=Support && Support==SupportPrev)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Is close trade?                                                  |
//+------------------------------------------------------------------+
bool isCloseBuy()
  {
   defPcChannel();
   if(iHigh(m_symbol.Name(),Period(),1)>=Resist && Resist==ResistPrev)
      return (true);
//---
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   string sHeaderLetter="";
   string sBodyLetter="";

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(isCloseBuy())
                 {
                  double price_current=m_position.PriceCurrent();
                  bool result=m_trade.PositionClose(m_position.Ticket());
                  if(InpSendMail && result)
                    {
                     sHeaderLetter="CLOSE BUY at"+m_position.Symbol()+"";
                     sBodyLetter="Close Buy at "+m_position.Symbol()+
                                 " at "+DoubleToString(price_current,m_symbol.Digits())+", and finish this Trade";
                     sndMessage(sHeaderLetter,sBodyLetter);
                    }
                  continue;
                 }
               else
                 {
                  if(ExtTrailingStop>0) // is traling stop? 
                     if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop)
                       {
                        if(m_position.StopLoss()<m_position.PriceCurrent()-ExtTrailingStop)
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_position.PriceCurrent()-ExtTrailingStop,
                              m_position.TakeProfit()))
                             {
                              Print("Modify ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                             }
                           continue;
                          }
                       }
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(isCloseSell())
                 {
                  double price_current=m_position.PriceCurrent();
                  bool result=m_trade.PositionClose(m_position.Ticket());
                  if(InpSendMail && result)
                    {
                     sHeaderLetter="CLOSE SELL at"+m_symbol.Name()+"";
                     sBodyLetter="Close Sell at "+m_symbol.Name()+
                                 " at "+DoubleToString(price_current,m_symbol.Digits())+", and finish this Trade";
                     sndMessage(sHeaderLetter,sBodyLetter);
                    }
                  continue;
                 }
               else
                 {
                  if(ExtTrailingStop>0) // is traling stop? 
                     if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop)
                       {
                        if((m_position.StopLoss()>m_position.PriceCurrent()+ExtTrailingStop) || m_position.StopLoss()==0.0)
                          {
                           if(!m_trade.PositionModify(m_position.Ticket(),
                              m_position.PriceCurrent()+ExtTrailingStop,
                              m_position.TakeProfit()))
                             {
                              Print("Modify ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                             }
                           continue;
                          }
                       }
                 }
              }
           }
//---
  }
//+------------------------------------------------------------------+
//| Fumction send e-mail message then open trade                     |
//+------------------------------------------------------------------+
void sndMessage(string HeaderLetter,string BodyLetter)
  {
   ResetLastError();
   if(!SendMail(HeaderLetter,BodyLetter))
      Print("Error, message not send: ",GetLastError());
//---
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
      //Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      //Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         //Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      //Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
      //      " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      //Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
      //        ".\n Perhaps an investor password has been used to connect to the trading account.",
      //        "\n Check the terminal journal for the following entry:",
      //        "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
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
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,index,1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHighest(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int type,
                int count=WHOLE_ARRAY,
                int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_HIGH)
     {
      double High[];
      if(CopyHigh(symbol,timeframe,start,count,High)!=count)
         return(-1);
      return(High[ArrayMaximum(High)]);
     }
//---
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLowest(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int type,
               int count=WHOLE_ARRAY,
               int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      if(CopyLow(symbol,timeframe,start,count,Low)!=count)
         return(-1);
      return(Low[ArrayMinimum(Low)]);
     }
//---
   return(-1);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double lot,double sl,double tp)
  {
   if(lot==0.0)
      return(false);
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double lot,double sl,double tp)
  {
   if(lot==0.0)
      return(false);
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
