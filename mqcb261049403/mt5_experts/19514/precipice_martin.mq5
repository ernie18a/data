//+------------------------------------------------------------------+
//|                    Precipice MartIn(barabashkakvn's edition).mq5 |
//|                                                  Maximus_genuine |
//|                                               gladmxm@bigmir.net |
//+------------------------------------------------------------------+
#property copyright "Maximus_genuine  "
#property link      "gladmxm@bigmir.net"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input bool     InpBUY               = true;  // Use Buy
input ushort   InpStepBUY           = 89;    // SL/TP Buy (in pips)
input bool     InpSELL              = true;  // Use Sell
input ushort   InpStepSELL          = 89;    // SL/TP Sell (in pips)
input bool     InpUseMartin         = true;  // Use Martin
input double   InpMartinCoefficient = 1.6;   // Martin Coefficient
input ulong    m_magic=196067025;            // magic number
//---
double         ExtStepBUY=0.0;
double         ExtStepSELL=0.0;
ulong          m_slippage=30;                // slippage
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!InpBUY && !InpSELL)
     {
      Print("Trade is impossible: both parameters (\"Use Buy\" and \"Use Sell\") are off");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpBUY && InpStepBUY==0)
     {
      Print("Trade BUY is impossible: parameter \"SL/TP Buy\" is zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpSELL && InpStepSELL==0)
     {
      Print("Trade SELL is impossible: parameter \"SL/TP Sell\" is zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
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

   ExtStepBUY=InpStepBUY*m_adjusted_point;
   ExtStepSELL=InpStepSELL*m_adjusted_point;
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
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   double lot=CalculateLot();
   if(lot==0.0)
      return;

   int count_buys=0;
   int count_sells=0;
   CalculatePositions(count_buys,count_sells);

   if(InpBUY && count_buys==0)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStepBUY==0)?0.0:m_symbol.Ask()-ExtStepBUY;
      double tp=(InpStepBUY==0)?0.0:m_symbol.Ask()+ExtStepBUY;
      OpenBuy(sl,tp,lot);
     }
   if(InpSELL && count_sells==0)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=(InpStepBUY==0)?0.0:m_symbol.Bid()+ExtStepSELL;
      double tp=(InpStepBUY==0)?0.0:m_symbol.Bid()-ExtStepSELL;
      OpenSell(sl,tp,lot);
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
//| Calculate lot                                                    |
//+------------------------------------------------------------------+
double CalculateLot()
  {
   double k=1.0;
   if(!InpUseMartin)
      return(m_symbol.LotsMin());

//--- request trade history 
   datetime from_date=TimeCurrent()-60*60*24*100;
   datetime to_date=TimeCurrent()+60*60*24*3;
   HistorySelect(from_date,to_date);
   int total_deals=HistoryDealsTotal();
   ulong ticket_history_deal=0;
//--- for all deals 
   for(int i=total_deals-1;i>=0;i--) // for(uint i=0;i<total_deals;i++) => i #0 - 2016, i #1045 - 2017
     {
      //--- try to get deals ticket_history_deal 
      if((ticket_history_deal=HistoryDealGetTicket(i))>0)
        {
         long     deal_ticket       =HistoryDealGetInteger(ticket_history_deal,DEAL_TICKET);
         long     deal_order        =HistoryDealGetInteger(ticket_history_deal,DEAL_ORDER);
         long     deal_time         =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME);
         long     deal_time_msc     =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME_MSC);
         long     deal_type         =HistoryDealGetInteger(ticket_history_deal,DEAL_TYPE);
         long     deal_entry        =HistoryDealGetInteger(ticket_history_deal,DEAL_ENTRY);
         long     deal_magic        =HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
         long     deal_reason       =HistoryDealGetInteger(ticket_history_deal,DEAL_REASON);
         long     deal_position_id  =HistoryDealGetInteger(ticket_history_deal,DEAL_POSITION_ID);

         double   deal_volume       =HistoryDealGetDouble(ticket_history_deal,DEAL_VOLUME);
         double   deal_price        =HistoryDealGetDouble(ticket_history_deal,DEAL_PRICE);
         double   deal_commission   =HistoryDealGetDouble(ticket_history_deal,DEAL_COMMISSION);
         double   deal_swap         =HistoryDealGetDouble(ticket_history_deal,DEAL_SWAP);
         double   deal_profit       =HistoryDealGetDouble(ticket_history_deal,DEAL_PROFIT);

         string   deal_symbol       =HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL);
         string   deal_comment      =HistoryDealGetString(ticket_history_deal,DEAL_COMMENT);
         string   deal_external_id  =HistoryDealGetString(ticket_history_deal,DEAL_EXTERNAL_ID);

         if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
            if(deal_entry==DEAL_ENTRY_OUT && (deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL))
              {
               if(deal_commission+deal_swap+deal_profit>0.0)
                  break;
               k*=InpMartinCoefficient;
              }
         int d=0;
        }
     }
//---
   return(LotCheck(k*m_symbol.LotsMin()));
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot*2.0,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
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
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp,double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot*2.0,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
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
//DebugBreak();
  }
//+------------------------------------------------------------------+
