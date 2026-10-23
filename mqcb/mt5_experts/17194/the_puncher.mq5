//+------------------------------------------------------------------+
//|                         The Puncher(barabashkakvn's edition).mq5 |
//|                          Copyright © 2008, CreativeSilence, Inc. |
//|                                  http://www.creative-silence.com |
//+------------------------------------------------------------------+
#define pos_comment "The Puncher By L.Bigger AKA Silence"
#property copyright "Copyright © 2008, CreativeSilence, Inc."
#property link      "http://www.creative-silence.com"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedRisk m_money;
//--- input parameters
input double   Lots           =20;           // Lots       
input int      StopLoss       =20;           // Stop Loss (in pips)
input int      TakeProfit     =50;           // Take Profit (in pips)
input bool     TradeAtCloseBar=true;
input int      TrailingStop   =10;           // Trailing Stop Level (in pips)
input int      TrailingStep   =5;            // Trailing step (in pips)
input int      BreakEven      =21;           // BreakEven (in pips)
input ulong    m_magic        =15489;        // magic number
//--- For alerts:
input int      Repeat=3;
input int      Periods=5;
input bool     UseAlert=false;
input bool     SendEmail=true;
//---
int            mm=-1;
double         RiskPercent=1;            // 1% risk
datetime       AlertTime=0;
int            AheadTradeSec= 0;
int            AheadExitSec = 0;
int            TradeBar=0;
long           MaxTradeTime=300;
int            NumberOfTries=5;              //Number of tries to set, close orders;
int            RetryTime=1;
double         Ilo=0;
int            DotLoc=7;
int            TradeLast=0;
string sound="alert.wav";

double sig_buy=0,sig_sell=0,sig_high=0,sig_low=0;
//---
int                        handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
int                        handle_iRSI;                  // variable for storing the handle of the iRSI indicator
ENUM_ACCOUNT_MARGIN_MODE   m_margin_mode;
double                     m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. m_symbol.Bid()=",DoubleToString(m_symbol.Bid(),Digits()),
            ", m_symbol.Ask()=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(RiskPercent); // 1% risk
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),100,3,3,MODE_SMMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),14,PRICE_CLOSE);
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
   TradeLast=0;
//----
   return(0);
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
   if(TradeAtCloseBar)
      TradeBar=1;
   else
      TradeBar=0;
//---
   double   BuyValue=0.0;
   double   SellValue=0.0;

   sig_buy=iStochasticGet(SIGNAL_LINE,0);
   sig_sell=iStochasticGet(SIGNAL_LINE,0);
   sig_high=iRSIGet(0);
   sig_low=iRSIGet(0);

   if(sig_buy<30 && sig_high<30)
      BuyValue=1;

   if(sig_buy>70 && sig_low>70)
      SellValue=1;

   double mode=0,Stop=0,NewBarTime=0;

//--- Here we found if new bar has just opened
   static datetime prevtime=0;
   int NewBar=0,FirstRun=1;

   if(FirstRun==1)
     {
      FirstRun=0;
      prevtime=iTime(m_symbol.Name(),Period(),0);
     }
   if((prevtime==iTime(m_symbol.Name(),Period(),0)) && (TimeCurrent()-prevtime)>MaxTradeTime)
     {
      NewBar=0;
     }
   else
     {
      prevtime=iTime(m_symbol.Name(),Period(),0);
      NewBar=1;
     }

   int   AllowTrade=0,AllowExit=0;
//--- Trade before bar current bar closed
   if(TimeCurrent()>=iTime(m_symbol.Name(),Period(),0)+PeriodSeconds()*60-AheadTradeSec)
      AllowTrade=1;
   else
      AllowTrade=0;

   if(TimeCurrent()>=iTime(m_symbol.Name(),Period(),0)+PeriodSeconds()*60-AheadExitSec)
      AllowExit=1;
   else
      AllowExit=0;

   if(AheadTradeSec==0)
      AllowTrade=1;
   if(AheadExitSec==0)
      AllowExit=1;

   if(!RefreshRates())
      return;

   Ilo=MoneyFixedRisk(m_symbol.Ask(),m_symbol.Bid()-StopLoss*m_adjusted_point);
   if(Ilo==0.0)
     {
      Comment("Lot is calculated: \"0.0\"");
      return;
     }

   int  OpenPos=0,OpenSell=0,OpenBuy=0,CloseSell=0,CloseBuy=0;

   OpenPos=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            OpenPos++;

//--- Conditions to open the position
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
//--- ConditionsConditions to close the positions
   if(SellValue>0)
     {
      CloseBuy=1;
     }

   if(BuyValue>0)
     {
      CloseSell=1;
     }

//subPrintDetails();

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(CloseBuy==1 && AllowExit==1)
                 {
                  if(NewBar==1 && TradeBar>0)
                    {
                     PlaySound("alert.wav");
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
                  if(TradeBar==0)
                    {
                     PlaySound("alert.wav");
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(CloseSell==1 && AllowExit==1)
                 {
                  if(NewBar==1 && TradeBar>0)
                    {
                     PlaySound("alert.wav");
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
                  if(TradeBar==0)
                    {
                     PlaySound("alert.wav");
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
                 }
              }
           }

   double MyStopLoss=0.0,MyTakeProfit=0.0;
   int ticket=0;

//--- Should we open a position?
   if(OpenPos<=2)
     {
      if(OpenSell==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Bid()-TakeProfit*m_adjusted_point;

            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Bid()+StopLoss*m_adjusted_point;

            PlaySound("alert.wav");
            m_trade.Sell(Ilo,m_symbol.Name(),m_symbol.Bid(),MyStopLoss,MyTakeProfit,pos_comment);
            OpenSell=0;
            return;
           }
         if(TradeBar==0)
           {
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Bid()-TakeProfit*m_adjusted_point;

            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Bid()+StopLoss*m_adjusted_point;

            PlaySound("alert.wav");
            m_trade.Sell(Ilo,m_symbol.Name(),m_symbol.Bid(),MyStopLoss,MyTakeProfit,pos_comment);
            OpenSell=0;
            return;
           }
        }
      if(OpenBuy==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Ask()+TakeProfit*m_adjusted_point;

            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Ask()-StopLoss*m_adjusted_point;

            PlaySound("alert.wav");
            m_trade.Buy(Ilo,m_symbol.Name(),m_symbol.Ask(),MyStopLoss,MyTakeProfit,pos_comment);
            OpenBuy=0;
            return;
           }
         if(TradeBar==0)
           {
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Ask()+TakeProfit*m_adjusted_point;

            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Ask()-StopLoss*m_adjusted_point;

            PlaySound("alert.wav");
            m_trade.Buy(Ilo,m_symbol.Name(),m_symbol.Ask(),MyStopLoss,MyTakeProfit,pos_comment);
            OpenBuy=0;
            return;
           }
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            TrailingPositions();

//--- the end
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
   string sDirection="";
   sComment = "The Puncher By L.Bigger AKA Silence" + NL;
   sComment = sComment + "StopLoss=" + DoubleToString(StopLoss,0) + " | ";
   sComment = sComment + "TakeProfit=" + DoubleToString(TakeProfit,0) + " | ";
   sComment = sComment + "TrailingStop=" + DoubleToString(TrailingStop,0) + NL;
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToString(Ilo,2) + " | ";
   sComment = sComment + "LastTrade=" + DoubleToString(TradeLast,0) + NL;
   sComment = sComment + "sig_buy=" + DoubleToString(sig_buy,Digits()) + NL;
   sComment = sComment + "sig_sell=" + DoubleToString(sig_sell,Digits()) + NL;
   sComment = sComment + sp;
   Comment(sComment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions()
  {
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- BreakEven routine
      if(BreakEven>0)
        {
         if((m_symbol.Bid()-m_position.PriceOpen())>BreakEven*m_adjusted_point)
           {
            if((m_position.StopLoss()-m_position.PriceOpen())<0)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_position.PriceOpen(),
                                      m_position.TakeProfit());
              }
           }
        }

      if(TrailingStop>0)
        {
         if((m_symbol.Bid()-m_position.PriceOpen())>TrailingStop*m_adjusted_point)
           {
            if(m_position.StopLoss()<m_symbol.Bid()-(TrailingStop+TrailingStep)*m_adjusted_point)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_symbol.Bid()-TrailingStop*m_adjusted_point
                                      ,m_position.TakeProfit());
               return;
              }
           }
        }

     }
   if(m_position.PositionType()==POSITION_TYPE_SELL)
     {
      if(BreakEven>0)
        {
         if((m_position.PriceOpen()-m_symbol.Ask())>BreakEven*m_adjusted_point)
           {
            if((m_position.PriceOpen()-m_position.StopLoss())<0)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_position.PriceOpen(),
                                      m_position.TakeProfit());
              }
           }
        }

      if(TrailingStop>0)
        {
         if(m_position.PriceOpen()-m_symbol.Ask()>TrailingStop*m_adjusted_point)
           {
            if(m_position.StopLoss()>m_symbol.Ask()+(TrailingStop+TrailingStep-1)*m_adjusted_point || m_position.StopLoss()==0)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_symbol.Ask()+TrailingStop*m_adjusted_point,
                                      m_position.TakeProfit());
               return;
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
      long     deal_entry        =0;
      long     deal_type         =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
           {
            if(deal_type==DEAL_TYPE_BUY)
              {
               TradeLast=1;
              }
            if(deal_type==DEAL_TYPE_SELL)
              {
               TradeLast=-1;
              }
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MoneyFixedRisk(double price,double sl)
  {
//--- getting lot size for open long position (CMoneyFixedRisk)
   double check_open_long_lot=m_money.CheckOpenLong(price,sl);
//Print("CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return(0.0);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,price,ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
     {
      if(chek_volime_lot>=check_open_long_lot)
        {
         return(check_open_long_lot);
         //m_trade.Buy(chek_volime_lot,NULL,m_symbol.Ask(),m_symbol.Bid()-ExtStopLoss,m_symbol.Bid()+ExtStopLoss);
        }
      else
        {
         //Print("CMoneyFixedRisk lot = ",DoubleToString(check_open_long_lot,2),
         //      ", CTrade lot = ",DoubleToString(chek_volime_lot,2));
         return(0.0);
        }
     }
   return(0.0);
  }
//+------------------------------------------------------------------+
