//+------------------------------------------------------------------+
//|                             EA Trix(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2007, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Forex-Experts"
#property link      "http://www.forex-experts.com"
#property version   "1.002"
#property description "Uses the indicator \"TRIX ARROWS\" (https://www.mql5.com/en/code/19056)"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedMargin m_money;
//---
#define EA_Name "EA Trix"
//--- input parameters
input ushort   InpStopLoss       = 50;                   // StopLoss
input ushort   InpTakeProfit     = 150;                  // TakeProfit
input ushort   InpTrailingStop   = 10;                   // Trailing stop
input ushort   InpTrailingStep   = 1;                    // Trailing step
input bool     InpTradeAtCloseBar= true;                 // Trade at close bar
input ushort   InpBreakEven      = 2;                    // BreakEven
input double   Risk              = 5;                    // Risk in percent for a deal from a free margin
input ulong    m_magic           = 59720786;             // Magic number
input string   Alerts_Setting    = "Alerts Setting";     // Alerts setting
input int      InpRepeatAlerts   = 3;                    // Repeat alerts
input int      InpPeriodAlerts   = 5;                    // Period alerts
input bool     InpAlerts         = false;                // Alerts
input bool     InpEmail          = true;                 // Email
input string   Indicator_Setting = "Indicator Setting";  // Indicator setting
input int      InpPeriodEMA      = 14;                   // EMA period
input int      InpSignalPeriod   = 8;                    // Signal period
//---
int            Crepeat=0;
datetime       AlertTime=0;
int            AheadTradeSec= 0;
int            AheadExitSec = 0;
int              TradeBar=0;
int            MaxTradeTime=300;

static int TradeLast=0;
string sound="alert.wav";
double TRIX_ARROWS_signal_buy=0,TRIX_ARROWS_signal_sell=0;
//---
ulong          m_slippage=30;                            // slippage
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         ExtBreakEven=0.0;
int            handle_iCustom;                           // variable for storing the handle of the iCustom indicator 
double         m_adjusted_point;                         // point value adjusted for 3 or 5 points
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
   ExtBreakEven=InpBreakEven*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"TRIX ARROWS",InpPeriodEMA,InpSignalPeriod);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   Crepeat=InpRepeatAlerts;

   if(m_trade.Sell(10.0,"Si-9.17"))
     {
      if(m_trade.ResultDeal()==0)
        {
         Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResult(m_trade);
         //return(false);
        }
      else
        {
         Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResult(m_trade);
         //return(true);
        }
     }
   else
     {
      Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
      PrintResult(m_trade);
      //return(false);
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
//---
   if(InpTradeAtCloseBar)
      TradeBar=1;
   else
      TradeBar=0;
//---
   double BuyValue=0,SellValue=0;

   TRIX_ARROWS_signal_buy=iCustomGet(handle_iCustom,2,TradeBar);
   TRIX_ARROWS_signal_sell=iCustomGet(handle_iCustom,3,TradeBar);

   if(TRIX_ARROWS_signal_buy!=0.0)
      BuyValue=1;

   if(TRIX_ARROWS_signal_sell!=0.0)
      SellValue=1;

   int  OpenSell=0,OpenBuy=0,CloseSell=0,CloseBuy=0;
   double   mode=0,Stop=0,NewBarTime=0;

//--- here we found if new bar has just opened
   static datetime prevtime=0;
   int NewBar=0,FirstRun=1;

   if(FirstRun==1)
     {
      FirstRun=0;
      prevtime=iTime(0);
     }
   if((prevtime==iTime(0)) && (TimeCurrent()-prevtime)>MaxTradeTime)
     {
      NewBar=0;
     }
   else
     {
      prevtime=iTime(0);
      NewBar=1;
     }

   int   AllowTrade=0,AllowExit=0;
//--- trade before bar current is close
   if(TimeCurrent()>=iTime(0)+Period()*60-AheadTradeSec)
      AllowTrade=1;
   else
      AllowTrade=0;
   if(TimeCurrent()>=iTime(0)+Period()*60-AheadExitSec)
      AllowExit=1;
   else AllowExit=0;
   if(AheadTradeSec==0)
      AllowTrade=1;
   if(AheadExitSec==0)
      AllowExit=1;

   OpenBuy=0; OpenSell=0;
   CloseBuy=0; CloseSell=0;
//--- conditions to open the position
   if(SellValue>0)
     {
      OpenSell=1;
      OpenBuy=0;
     }
   if(BuyValue>0)
     {
      OpenBuy=1;
      OpenSell=0;
     }
//--- conditions to close the positions
   if(SellValue>0)
      CloseBuy=1;

   if(BuyValue>0)
      CloseSell=1;
//---
   subPrintDetails();

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(CloseBuy==1 && AllowExit==1)
                 {
                  if((NewBar==1 && TradeBar>0) || TradeBar==0)
                    {
                     PlaySound("alert.wav");
                     ulong ticket=m_position.Ticket();
                     if(m_trade.PositionClose(ticket))
                        Alerts(0,0,CloseBuy,CloseSell,m_trade.ResultPrice(),0,0,ticket);
                     continue;
                    }
                 }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(CloseSell==1 && AllowExit==1)
                 {
                  if((NewBar==1 && TradeBar>0) || TradeBar==0)
                    {
                     PlaySound("alert.wav");
                     ulong ticket=m_position.Ticket();
                     if(m_trade.PositionClose(ticket))
                        Alerts(0,0,CloseBuy,CloseSell,m_trade.ResultPrice(),0,0,ticket);
                     continue;
                    }
                 }
              }
           }

   double MyStopLoss=0.0,MyTakeProfit=0.0;
   int ticket=0;

//--- should we open a position?
   if(CalculateAllPositions()==0)
     {
      if(!RefreshRates())
         return;
      if(OpenSell==1 && AllowTrade==1)
        {
         if((NewBar==1 && TradeBar>0) || TradeBar==0)
           {
            if(InpTakeProfit==0)
               MyTakeProfit=0.0;
            else
               MyTakeProfit=m_symbol.Bid()-ExtTakeProfit;
            if(InpStopLoss==0)
               MyStopLoss=0.0;
            else
               MyStopLoss=m_symbol.Bid()+ExtStopLoss;
            PlaySound("alert.wav");
            if(OpenSell(MyStopLoss,MyTakeProfit))
              {
               Alerts(OpenBuy,OpenSell,0,0,m_trade.ResultPrice(),MyStopLoss,MyTakeProfit,m_trade.ResultDeal());
               OpenSell=0;
              }
            return;
           }
        }
      if(OpenBuy==1 && AllowTrade==1)
        {
         if((NewBar==1 && TradeBar>0) || TradeBar==0)
           {
            if(InpTakeProfit==0)
               MyTakeProfit=0.0;
            else
               MyTakeProfit=m_symbol.Ask()+ExtTakeProfit;
            if(InpStopLoss==0)
               MyStopLoss=0.0;
            else
               MyStopLoss=m_symbol.Ask()-ExtStopLoss;
            PlaySound("alert.wav");
            if(OpenBuy(MyStopLoss,MyTakeProfit))
              {
               Alerts(OpenBuy,OpenSell,0,0,m_trade.ResultPrice(),MyStopLoss,MyTakeProfit,m_trade.ResultDeal());
               OpenBuy=0;
              }
            return;
           }
        }
     }
//--- trailing
   TrailingPositions();
   Alerts(0,0,0,0,0,0,0,0);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---
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
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if((ENUM_DEAL_TYPE)deal_type==DEAL_TYPE_BUY)
               TradeLast=-1;
            else if((ENUM_DEAL_TYPE)deal_type==DEAL_TYPE_SELL)
               TradeLast=1;
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Alerts(int _buy,int _sell,int _exitbuy,int _exitsell,double _op,double _sl,double _tp,ulong _ticket)
  {
   string AlertStr="";
   AlertStr="";
   string CurDate="";
   CurDate=TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
//--- alert system
   if(InpAlerts)
     {
      if(_buy==1)
        {
         if(Crepeat==InpRepeatAlerts)
            AlertTime=0;
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>InpPeriodAlerts)
           {
            if(_buy==1)
              {
               AlertStr=AlertStr+"Buy @ "+DoubleToString(_op,m_symbol.Digits())+
                        "; SL: "+DoubleToString(_sl,m_symbol.Digits())+
                        "; TP: "+DoubleToString(_tp,m_symbol.Digits())+
                        " at "+CurDate+" Deal:"+DoubleToString(_ticket,0)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(InpEmail)
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+
                           ": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }
      if(_sell==1)
        {
         if(Crepeat==InpRepeatAlerts)
            AlertTime=0;
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>InpPeriodAlerts)
           {
            if(_sell==1)
              {
               AlertStr=AlertStr+"Sell @ "+DoubleToString(_op,m_symbol.Digits())+
                        "; SL: "+DoubleToString(_sl,m_symbol.Digits())+
                        "; TP: "+DoubleToString(_tp,m_symbol.Digits())+
                        " at "+CurDate+" Deal:"+DoubleToString(_ticket,0)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(InpEmail)
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+
                           ": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }
      if(_exitsell==1)
        {
         if(Crepeat==InpRepeatAlerts)
            AlertTime=0;
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>InpPeriodAlerts)
           {
            if(_exitsell==1)
              {
               AlertStr=AlertStr+" Close Sell @ "+DoubleToString(_op,m_symbol.Digits())+
                        " at "+CurDate+" Position:"+DoubleToString(_ticket,0)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(InpEmail)
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+
                           ": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }
      if(_exitbuy==1)
        {
         if(Crepeat==InpRepeatAlerts)
            AlertTime=0;
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>InpPeriodAlerts)
           {
            if(_exitbuy==1)
              {
               AlertStr=AlertStr+" Close Buy @ "+DoubleToString(_op,m_symbol.Digits())+
                        " at "+CurDate+" Position:"+DoubleToString(_ticket,0)+".";
               Alert(Symbol()," ",Period(),": ",AlertStr);
               if(InpEmail)
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+
                           ": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }
      if(_exitbuy==0 && _exitsell==0 && _buy==0 && _sell==0)
        {
         Crepeat=InpRepeatAlerts;
         AlertTime=0;
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| PRINT COMMENT FUNCTION                                           |
//+------------------------------------------------------------------+
void subPrintDetails()
  {
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
   string sDirection = "";
   sComment = "Trix_EA v.1.0" + NL;
   sComment = sComment + "StopLoss=" + IntegerToString(InpStopLoss) + " | ";
   sComment = sComment + "TakeProfit=" + IntegerToString(InpTakeProfit) + " | ";
   sComment = sComment + "TrailingStop=" + IntegerToString(InpTrailingStop) + NL;
   sComment = sComment + sp;
   sComment = sComment + "LastTrade=" + IntegerToString(TradeLast) + NL;
   sComment = sComment + "TRIX_ARROWS_signal_buy=" + DoubleToString(TRIX_ARROWS_signal_buy,m_symbol.Digits()) + NL;
   sComment = sComment + "TRIX_ARROWS_signal_sell=" + DoubleToString(TRIX_ARROWS_signal_sell,m_symbol.Digits()) + NL;
   sComment = sComment + sp;
   Comment(sComment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- BreakEven routine
               if(InpBreakEven>0)
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtBreakEven)
                     if((m_position.StopLoss()-m_position.PriceOpen())<0.0)
                       {
                        PlaySound("alert.wav");
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),
                                               m_position.TakeProfit());
                        continue;
                       }
               if(InpTrailingStop>0)
                  if((m_position.PriceCurrent()-m_position.PriceOpen())>ExtTrailingStop)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                       {
                        PlaySound("alert.wav");
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceCurrent()-ExtTrailingStop,
                                               m_position.TakeProfit());
                        continue;
                       }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(InpBreakEven>0)
                  if((m_position.PriceOpen()-m_position.PriceCurrent())>ExtBreakEven)
                     if((m_position.PriceOpen()-m_position.StopLoss())<0)
                       {
                        PlaySound("alert.wav");
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceCurrent(),
                                               m_position.TakeProfit());
                        continue;
                       }
               if(InpTrailingStop>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop)
                    {
                     if(m_position.StopLoss()>m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep) ||
                        m_position.StopLoss()==0)
                       {
                        PlaySound("alert.wav");
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceCurrent()+ExtTrailingStop,
                                               m_position.TakeProfit());
                        continue;
                       }
                    }
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
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return(false);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade);
               return(false);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade);
               return(true);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return(false);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade);
               return(false);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade);
               return(true);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade);
            return(false);
           }

        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),2));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),2));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),2));
   Print("broker comment: "+trade.ResultComment());
   DebugBreak();
  }
//+------------------------------------------------------------------+
