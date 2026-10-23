//+------------------------------------------------------------------+
//|                                            Invest System 4.5.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
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
input ushort   InpStopLoss    = 240;      // Stop Loss (in pips)
input ushort   InpTakeProfit  = 40;       // Take Profit (in pips)  
input ulong    m_magic        = 12455489; // magic number
//---
ulong          m_slippage=10;             // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points

double Lots1    =0.1;
double Lots2    =0.2;
double Lots3    =0.7;
double Lots4    =1.4;

bool Work=true;
string Symb;

bool Opn_B=false;
bool Opn_S=false;
bool Vhod=false;
bool LTS=false;
bool PlanB=false;
bool L2Stop=true;
bool L3Stop=true;
bool L4Stop=true;
bool L5Stop=true;
bool L6Stop=true;

datetime Chas;
double Pribl=-1.0;
double Lots=100;
double maxBalance=0.1;
double minBalanse=0.1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Pribl=-1.0;
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
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
//---
   int Total=0;
   double SL=0.0;
   double TP=0.0;
   if(minBalanse==0.1)
      minBalanse=m_account.Balance();
   if(m_account.Balance()>(minBalanse*2) && L2Stop)
     {
      Lots1=0.2;Lots2=0.4;Lots3=1.4;Lots4=2.8;L2Stop=false;
     }
   if(m_account.Balance()>(minBalanse*3) && L3Stop)
     {
      Lots1=0.3;Lots2=0.6;Lots3=2.1;Lots4=4.2;L3Stop=false;
     }
   if(m_account.Balance()>(minBalanse*4) && L4Stop)
     {
      Lots1=0.4;Lots2=0.8;Lots3=2.8;Lots4=5.6;L4Stop=false;
     }
   if(m_account.Balance()>(minBalanse*5) && L5Stop)
     {
      Lots1=0.5;Lots2=1;Lots3=3.5;Lots4=7;L5Stop=false;
     }
   if(m_account.Balance()>(minBalanse*6) && L6Stop)
     {
      Lots1=0.6;Lots2=1.2;Lots3=4.2;Lots4=8.4;L6Stop=false;
     }
   double Lot1=Lots1;
   double Lot2=Lots3;
//--- 3
   if(Bars(m_symbol.Name(),Period())<24) // Недостаточно баров
     {
      Alert("Недостаточно баров в окне. Эксперт не работает.");
      return;                                   // Выход из start()
     }
   if(!Work) // Критическая ошибка
     {
      Alert("Критическая ошибка. Эксперт не работает.");
      return;                                   // Выход из start()
     }
//--- 4
   Total=0;                                     // Количество ордеров
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            Total++;
//--- 5
   if(m_symbol.Name()!="EURUSD")
     {
      Comment("Рекомендуется использовать эксперта не на валют.паре ",Symbol(),
              ",а на EURUSD.Для ",Symbol()," нужно подбирать стоп и профит.");
     }

   double Balance=m_account.Balance();
   if(Lots==100)
      Lots=Lot1;
   if(Total!=0)
      LTS=true;

   if(Total==0 && Balance>maxBalance)
     {
      PlanB=false;Lot1=Lots1;Lot2=Lots3;maxBalance=Balance;
     }
   if(Total==0 && PlanB)
     {
      Lot1=Lots2;Lot2=Lots4;
     }
   if(LTS && Total==0 && Pribl<0 && Lots==Lot2)
     {
      PlanB=true;LTS=false;
     }
   if(LTS && Total==0 && Pribl<0 && Lots==Lot1)
     {
      Lots=Lot2;LTS=false;
     }
   if(LTS && Total==0 && Pribl>0)
     {
      Lots=Lot1;LTS=false;
     }
   if(LTS && Total==0 && Pribl<0)
     {
      Lots=Lot2;LTS=false;
     }
   if(iClose(1,"EURUSD",PERIOD_H4)>iOpen(1,"EURUSD",PERIOD_H4))
     {
      Opn_S=false;Opn_B=true;
     }
   if(iClose(1,"EURUSD",PERIOD_H4)<iOpen(1,"EURUSD",PERIOD_H4))
     {
      Opn_S=true;Opn_B=false;
     }
   if(Total!=0)
     {
      Vhod=false;
     }
   if(Chas!=iTime(0,"EURUSD",PERIOD_H4))
     {
      Chas=iTime(0,"EURUSD",PERIOD_H4);
      Vhod=true;
     }
//--- 6  
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(Total==0 && Opn_B && str1.min<=15 && Vhod)
     {
      if(!RefreshRates())
         return;
      SL=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      TP=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      if(m_trade.Buy(Lots,m_symbol.Name(),m_symbol.Ask(),
         m_symbol.NormalizePrice(SL),
         m_symbol.NormalizePrice(TP)))
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
      return;
     }
   if(Total==0 && Opn_S && str1.min<=15 && Vhod) // Открытых орд. нет +
     {                                       // критерий откр. Sell
      if(!RefreshRates())
         return;
      SL=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      TP=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      if(m_trade.Sell(Lots,m_symbol.Name(),m_symbol.Bid(),
         m_symbol.NormalizePrice(SL),
         m_symbol.NormalizePrice(TP)))
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
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   double res=0.0;
   int losses=0.0;
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
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            Pribl=deal_commission+deal_swap+deal_profit;
           }
     }
  }
//+------------------------------------------------------------------+ 
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0)
      open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0)
      close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
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
   DebugBreak();
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
