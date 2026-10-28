//+------------------------------------------------------------------+
//|                    The MasterMind 3(barabashkakvn's edition).mq5 |
//|                          Copyright © 2008, CreativeSilence, Inc. |
//|                                  http://www.creative-silence.com |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
#define OrderStr "MasterMind3CE By L.Bigger AKA Silence"
#property copyright "Copyright © 2008, CreativeSilence, Inc."
#property link      "http://www.creative-silence.com"
#property version   "1.001"
input double   Lots=200;
input ushort   InpStopLoss=2000;             // StopLoss
input ushort   InpTakeProfit=0;              // TakeProfit
input bool     TradeAtCloseBar=false;
input ushort   InpTrailingStop=0;            // TrailingStop
input ushort   InpExtTrailingStep=1;         // Trailing step
input ushort   InpBreakEven=0;               // BreakEven
ulong          MagicNumber=75658348;
//For alerts:
input int      Repeat=3;
input int      Periods=5;
input bool     UseAlert=false;
input bool     SendEmail=false;
input string   TradeLog="MasterMind3";
//---
int            mm=-1;                        // -1: Fractional lots, 0: Single Lots, 1 :Full lots
double         Risk=1;
int            Crepeat=0;
datetime       AlertTime=0;
long           AheadTradeSec= 0;
long           AheadExitSec = 0;
int            TradeBar=0;
double         MaxTradeTime=300;

int            NumberOfTries=5;//Number of tries to set, close orders;

double         Ilo=0;

int            DotLoc=7;
static int     TradeLast=0;

string         sound="alert.wav";

double         sig_buy=0,sig_sell=0,sig_high=0,sig_low=0;

string         filename="";

double         ExtTakeProfit=0.0;
double         ExtStopLoss=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         ExtBreakEven=0.0;

int    handle_iWPR_26;                       // variable for storing the handle of the iWPR indicator 
int    handle_iWPR_27;                       // variable for storing the handle of the iWPR indicator 
int    handle_iWPR_29;                       // variable for storing the handle of the iWPR indicator 
int    handle_iWPR_30;                       // variable for storing the handle of the iWPR indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                     // sets symbol name
   m_trade.SetExpertMagicNumber(MagicNumber);   // sets magic number
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtTakeProfit     =InpTakeProfit*digits_adjust;
   ExtStopLoss       =InpStopLoss*digits_adjust;
   ExtTrailingStop   =InpTrailingStop*digits_adjust;
   ExtTrailingStep   =InpTrailingStop*digits_adjust;
   ExtBreakEven      =InpBreakEven*digits_adjust;

   Crepeat=Repeat;

//--- create handle of the indicator iWPR
   handle_iWPR_26=iWPR(m_symbol.Name(),Period(),26);
//--- if the handle is not created 
   if(handle_iWPR_26==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR_27=iWPR(m_symbol.Name(),Period(),27);
//--- if the handle is not created 
   if(handle_iWPR_27==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR_29=iWPR(m_symbol.Name(),Period(),29);
//--- if the handle is not created 
   if(handle_iWPR_29==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR_30=iWPR(m_symbol.Name(),Period(),30);
//--- if the handle is not created 
   if(handle_iWPR_30==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
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
   if(TradeAtCloseBar) TradeBar=1;
   else TradeBar=0;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   filename=m_symbol.Name()+TradeLog+"-"+IntegerToString(str1.mon)+"-"+IntegerToString(str1.day)+".log";
//---- 
   double   BuyValue=0,SellValue=0;
   BuyValue=0; SellValue=0;

   if(CountPositions(POSITION_TYPE_BUY,MagicNumber)>0) TradeLast=1;
   if(CountPositions(POSITION_TYPE_SELL,MagicNumber)>0) TradeLast=-1;

   sig_buy=iWPRGet(handle_iWPR_26,0);
   sig_sell=iWPRGet(handle_iWPR_27,0);
   sig_high=iWPRGet(handle_iWPR_29,0);
   sig_low=iWPRGet(handle_iWPR_30,0);

//Comment("sig_buy=",sig_buy," sig_sell=",sig_sell); 

   if(sig_buy<-99.99 && sig_sell<-99.99 && sig_high<-99.99 && sig_low<-99.99)
     {
      BuyValue=1;
     }

   if(sig_buy>-0.01 && sig_sell>-0.01 && sig_high>-0.01 && sig_low>-0.01)
     {
      SellValue=1;
     }

   int  cnt=0,OpenPos=0,OpenSell=0,OpenBuy=0,CloseSell=0,CloseBuy=0;
   double mode=0,Stop=0,NewBarTime=0;

//--- Here we found if new bar has just opened
   static datetime prevtime=0;
   int NewBar=0,FirstRun=1;

   datetime time_0=iTime(m_symbol.Name(),Period(),0);
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
//Trade before bar current bar closed
   if(TimeCurrent()>= iTime(m_symbol.Name(),Period(),0)+Period()*60-AheadTradeSec) AllowTrade=1; else AllowTrade=0;
   if(TimeCurrent()>= iTime(m_symbol.Name(),Period(),0)+Period()*60-AheadExitSec) AllowExit=1; else AllowExit=0;
   if(AheadTradeSec==0) AllowTrade=1;
   if(AheadExitSec==0) AllowExit=1;

   Ilo=Lots;
   if(mm<0)
     {
      Ilo=MathCeil(m_account.FreeMargin()*Risk/715)/10-0.1;
      if(Ilo<0.1) Ilo=0.1;
     }
   if(mm>0)
     {
      Ilo=MathCeil(m_account.Equity()*Risk/100)/10-1;
      if(Ilo>1) Ilo=MathCeil(Ilo);
      if(Ilo<1) Ilo=1;
     }
   if(Ilo>5) Ilo=5;

   OpenPos=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.Symbol()==m_symbol.Name() && ((m_position.Magic()==MagicNumber))) OpenPos=OpenPos+1;
        }
     }

   if(OpenPos>=1)
     {
      OpenSell=0; OpenBuy=0;
     }

   OpenBuy=0; OpenSell=0;
   CloseBuy=0; CloseSell=0;

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

//--- Conditions to close the positions
   if(SellValue>0)
     {
      CloseBuy=1;
     }

   if(BuyValue>0)
     {
      CloseSell=1;
     }

   subPrintDetails();

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(!RefreshRates())
            return;
         if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Symbol()==m_symbol.Name() && ((m_position.Magic()==MagicNumber)))
           {
            if(CloseBuy==1 && AllowExit==1)
              {
               if(NewBar==1 && TradeBar>0)
                 {
                  SetText(time_0,iHigh(m_symbol.Name(),Period(),0)+1*DotLoc*Point(),"CloseBuy"+TimeToString(time_0),"Close",clrMagenta);
                  PlaySound("alert.wav");
                  OrdClose(m_position.Ticket());
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Bid(),0,0,m_position.Ticket());
                  return;
                 }
               if(TradeBar==0)
                 {
                  SetText(time_0,iHigh(m_symbol.Name(),Period(),0)+1*DotLoc*Point(),"CloseBuy"+TimeToString(time_0),"Close",clrMagenta);
                  PlaySound("alert.wav");
                  OrdClose(m_position.Ticket());
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Bid(),0,0,m_position.Ticket());
                  return;
                 }

              }
           }

         if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==m_symbol.Name() && ((m_position.Magic()==MagicNumber)))
           {
            if(CloseSell==1 && AllowExit==1)
              {
               if(NewBar==1 && TradeBar>0)
                 {
                  SetText(time_0,iHigh(m_symbol.Name(),Period(),0)-0.3*DotLoc*Point(),"CloseSell"+TimeToString(time_0),"Close",clrMagenta);
                  PlaySound("alert.wav");
                  OrdClose(m_position.Ticket());
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Ask(),0,0,m_position.Ticket());
                  return;
                 }
               if(TradeBar==0)
                 {
                  SetText(time_0,iHigh(m_symbol.Name(),Period(),0)-0.3*DotLoc*Point(),"CloseSell"+TimeToString(time_0),"Close",clrMagenta);
                  PlaySound("alert.wav");
                  OrdClose(m_position.Ticket());
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Ask(),0,0,m_position.Ticket());
                  return;
                 }

              }
           }
        }
     }

   double MyStopLoss=0,MyTakeProfit=0;
   ulong ticket=0;

//--- Should we open a position?
   if(OpenPos<=2)
     {
      if(!RefreshRates())
         return;
      if(OpenSell==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            SetText(time_0,iHigh(m_symbol.Name(),Period(),0)+1*DotLoc*Point(),"Sell"+TimeToString(time_0),"Sell",clrRed);
            if(ExtTakeProfit==0) MyTakeProfit=0; else MyTakeProfit=m_symbol.Bid()-ExtTakeProfit*Point();
            if(ExtStopLoss==0) MyStopLoss=0; else MyStopLoss=m_symbol.Bid()+ExtStopLoss*Point();
            PlaySound("alert.wav");
            ticket=OrdSend(m_symbol.Name(),POSITION_TYPE_SELL,Ilo,m_symbol.Bid(),MyStopLoss,MyTakeProfit,OrderStr);
            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Bid(),MyStopLoss,MyTakeProfit,ticket);
            OpenSell=0;
            return;
           }
         if(TradeBar==0)
           {
            SetText(time_0,iHigh(m_symbol.Name(),Period(),0)+1*DotLoc*Point(),"Sell"+TimeToString(time_0),"Sell",clrRed);
            if(ExtTakeProfit==0) MyTakeProfit=0; else MyTakeProfit=m_symbol.Bid()-ExtTakeProfit*Point();
            if(ExtStopLoss==0) MyStopLoss=0; else MyStopLoss=m_symbol.Bid()+ExtStopLoss*Point();
            PlaySound("alert.wav");
            ticket=OrdSend(m_symbol.Name(),POSITION_TYPE_SELL,Ilo,m_symbol.Bid(),MyStopLoss,MyTakeProfit,OrderStr);
            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Bid(),MyStopLoss,MyTakeProfit,ticket);
            OpenSell=0;
            return;
           }
        }
      if(OpenBuy==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            SetText(time_0,iLow(m_symbol.Name(),Period(),0)-0.3*DotLoc*Point(),"Buy"+TimeToString(time_0),"Buy",clrLime);
            if(ExtTakeProfit==0) MyTakeProfit=0; else MyTakeProfit=m_symbol.Ask()+ExtTakeProfit*Point();
            if(ExtStopLoss==0) MyStopLoss=0; else MyStopLoss=m_symbol.Ask()-ExtStopLoss*Point();
            PlaySound("alert.wav");
            ticket=OrdSend(m_symbol.Name(),POSITION_TYPE_BUY,Ilo,m_symbol.Ask(),MyStopLoss,MyTakeProfit,OrderStr);
            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Ask(),MyStopLoss,MyTakeProfit,ticket);
            OpenBuy=0;
            return;
           }
         if(TradeBar==0)
           {
            SetText(time_0,iLow(m_symbol.Name(),Period(),0)-0.3*DotLoc*Point(),"Buy"+TimeToString(time_0),"Buy",clrLime);
            if(ExtTakeProfit==0) MyTakeProfit=0; else MyTakeProfit=m_symbol.Ask()+ExtTakeProfit*Point();
            if(ExtStopLoss==0) MyStopLoss=0; else MyStopLoss=m_symbol.Ask()-ExtStopLoss*Point();
            PlaySound("alert.wav");
            ticket=OrdSend(m_symbol.Name(),POSITION_TYPE_BUY,Ilo,m_symbol.Ask(),MyStopLoss,MyTakeProfit,OrderStr);
            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Ask(),MyStopLoss,MyTakeProfit,ticket);
            OpenBuy=0;
            return;
           }
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==MagicNumber)
            TrailingPositions();

   Alerts(0,0,0,0,0,0,0,0);
//--- the end
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(datetime X1,double Y1,string TEXT_NAME,string TEXT_VALUE,int TEXT_COLOR)
  {
   if(ObjectFind(0,TEXT_NAME)!=0)
     {
      ObjectCreate(0,TEXT_NAME,OBJ_TEXT,0,X1,Y1);
      ObjectSetInteger(0,TEXT_NAME,OBJPROP_COLOR,TEXT_COLOR);
      ObjectSetString(0,TEXT_NAME,OBJPROP_TEXT,TEXT_VALUE);
      ObjectSetInteger(0,TEXT_NAME,OBJPROP_FONTSIZE,10);
     }
   else
     {
      ObjectMove(0,TEXT_NAME,0,X1,Y1);
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

//--- Alert system
   if(UseAlert)
     {
      if(_buy==1)
        {
         if(Crepeat==Repeat)
           {
            AlertTime=0;
           }
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>Periods)
           {
            if(_buy==1)
              {
               AlertStr=AlertStr+"Buy @ "+DoubleToString(_op,Digits())+
                        "; SL: "+DoubleToString(_sl,Digits())+
                        "; TP: "+DoubleToString(_tp,Digits())+
                        " at "+CurDate+
                        " Ticket:"+IntegerToString(_ticket)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
                 }
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }

      if(_sell==1)
        {
         if(Crepeat==Repeat)
           {
            AlertTime=0;
           }
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>Periods)
           {
            if(_sell==1)
              {
               AlertStr=AlertStr+"Sell @ "+DoubleToString(_op,Digits())+
                        "; SL: "+DoubleToString(_sl,Digits())+
                        "; TP: "+DoubleToString(_tp,Digits())+
                        " at "+CurDate+
                        " Ticket:"+IntegerToString(_ticket)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
                 }
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }

      if(_exitsell==1)
        {
         if(Crepeat==Repeat)
           {
            AlertTime=0;
           }
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>Periods)
           {
            if(_exitsell==1)
              {
               AlertStr=AlertStr+" Close Sell @ "+DoubleToString(_op,Digits())+
                        " at "+CurDate+" Order:"+IntegerToString(_ticket)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
                 }
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }

      if(_exitbuy==1)
        {
         if(Crepeat==Repeat)
           {
            AlertTime=0;
           }
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>Periods)
           {
            if(_exitbuy==1)
              {
               AlertStr=AlertStr+" Close Buy @ "+DoubleToString(_op,Digits())+
                        " at "+CurDate+" Order:"+IntegerToString(_ticket)+".";
               Alert(m_symbol.Name()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(m_symbol.Name()+" "+EnumToString(Period())+": ",m_symbol.Name()+" "+EnumToString(Period())+": "+AlertStr);
                 }
               Crepeat=Crepeat-1;
               AlertTime=TimeCurrent();
              }
           }
        }

      if(_exitbuy==0 && _exitsell==0 && _buy==0 && _sell==0)
        {
         Crepeat=Repeat;
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
//return;
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
   sComment = "The MasterMind3 By L.Bigger AKA Silence" + NL;
   sComment = sComment + "ExtStopLoss=" + DoubleToString(ExtStopLoss,0) + " | ";
   sComment = sComment + "ExtTakeProfit=" + DoubleToString(ExtTakeProfit,0) + " | ";
   sComment = sComment + "ExtTrailingStop=" + DoubleToString(ExtTrailingStop,0) + NL;
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToString(Ilo,2) + " | ";
   sComment = sComment + "LastTrade=" + DoubleToString(TradeLast,0) + NL;
   sComment = sComment + "sig_buy=" + DoubleToString(sig_buy,Digits()) + NL;
   sComment = sComment + "sig_sell=" + DoubleToString(sig_sell,Digits()) + NL;
   sComment = sComment + sp;
   Comment(sComment);
  }
//+------------------------------------------------------------------+
//| Return number of orders with specific parameters                 |
//+------------------------------------------------------------------+
int CountPositions(ENUM_POSITION_TYPE type,ulong magic)
  {
//return number of orders with specific parameters
   int _CntPos=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==magic)
            _CntPos++;
   return(_CntPos);
  }
//+------------------------------------------------------------------+
//| Write log file                                                   |
//+------------------------------------------------------------------+
void Write(string str)
  {
   int handle;
   handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,"/t");
   FileSeek(handle,0,SEEK_END);
   FileWrite(handle," Time "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+": "+str);
   FileClose(handle);
   Print(str);
  }
//+------------------------------------------------------------------+
//| Send order with retry capabilities and log                       |
//+------------------------------------------------------------------+
ulong OrdSend(string _symbol,ENUM_POSITION_TYPE _cmd,double _volume,double _price,double _stoploss,double _takeprofit,string _comment="")
  {
   int _stoplevel=m_symbol.StopsLevel();
   ulong  ticket=0;

   if(!RefreshRates())
      return(ticket);

   switch(_cmd)
     {
      case POSITION_TYPE_BUY:
         if(IsTradeAllowed())
           {
            if(!m_trade.Buy(_volume,_symbol,m_symbol.Ask(),NormalizeDouble(_stoploss,Digits()),NormalizeDouble(_takeprofit,Digits()),_comment))
              {
               Write("Error Occured : "+m_trade.ResultRetcodeDescription());
               Write(_symbol+" Buy @ "+DoubleToString(m_symbol.Ask(),Digits())+
                     " SL @ "+DoubleToString(_stoploss,Digits())+
                     " TP @"+DoubleToString(_takeprofit,Digits()));
              }
            else
              {
               ticket=m_trade.ResultDeal();
               Write("Order opened : "+m_symbol.Name()+" Buy @ "+DoubleToString(m_symbol.Ask(),Digits())+
                     " SL @ "+DoubleToString(_stoploss,Digits())+
                     " TP @"+DoubleToString(_takeprofit,Digits())+
                     " ticket ="+IntegerToString(ticket));
              }
           }
         return(ticket);
      case POSITION_TYPE_SELL:
         if(IsTradeAllowed())
           {
            if(!m_trade.Sell(_volume,_symbol,m_symbol.Bid(),NormalizeDouble(_stoploss,Digits()),NormalizeDouble(_takeprofit,Digits()),_comment))
              {
               Write("Error Occured : "+m_trade.ResultRetcodeDescription());
               Write(_symbol+" Buy @ "+DoubleToString(m_symbol.Ask(),Digits())+
                     " SL @ "+DoubleToString(_stoploss,Digits())+
                     " TP @"+DoubleToString(_takeprofit,Digits()));
              }
            else
              {
               ticket=m_trade.ResultDeal();
               Write("Order opened : "+m_symbol.Name()+" Buy @ "+DoubleToString(m_symbol.Ask(),Digits())+
                     " SL @ "+DoubleToString(_stoploss,Digits())+
                     " TP @"+DoubleToString(_takeprofit,Digits())+
                     " ticket ="+IntegerToString(ticket));
              }
           }
         return(ticket);
     }
   return(ticket);
  }
//+------------------------------------------------------------------+
//| The function close order with log                                |
//+------------------------------------------------------------------+
bool OrdClose(ulong _ticket)
  {
   bool err=false;

   if(IsTradeAllowed())
     {
      if(!RefreshRates())
         return(err);
      if(!m_trade.PositionClose(_ticket))
        {
         err=false;
         Write("Error Occured : "+m_trade.ResultRetcodeDescription());
         Write(m_symbol.Name()+
               " Bid @ "+DoubleToString(m_symbol.Bid(),Digits())+
               " Ask @ "+DoubleToString(m_symbol.Ask(),Digits())+
               " ticket ="+IntegerToString(_ticket));
        }
      else
        {
         err=true;
         Write("Order closed : "+m_symbol.Name()+
               " Bid @ "+DoubleToString(m_symbol.Bid(),Digits())+
               " Ask @ "+DoubleToString(m_symbol.Ask(),Digits())+
               " ticket ="+IntegerToString(_ticket));
        }
     }
   return(err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions()
  {
   double pBid,pAsk,pp;
   if(!RefreshRates())
      return;
   pp=m_symbol.Point();
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      pBid=m_symbol.Bid();
      //--- ExtBreakEven routine
      if(ExtBreakEven>0)
        {
         if((pBid-m_position.PriceOpen())>ExtBreakEven*pp)
           {
            if((m_position.StopLoss()-m_position.PriceOpen())<0)
              {
               ModifyStopLoss(m_position.PriceOpen()+0*pp);
              }
           }
        }
      if(ExtTrailingStop>0)
        {
         if((pBid-m_position.PriceOpen())>ExtTrailingStop*pp)
           {
            if(m_position.StopLoss()<pBid-(ExtTrailingStop+ExtTrailingStep-1)*pp)
              {
               ModifyStopLoss(pBid-ExtTrailingStop*pp);
               return;
              }
           }
        }

     }
   if(m_position.PositionType()==POSITION_TYPE_SELL)
     {
      pAsk=m_symbol.Ask();
      if(ExtBreakEven>0)
        {
         if((m_position.PriceOpen()-pAsk)>ExtBreakEven*pp)
           {
            if((m_position.PriceOpen()-m_position.StopLoss())<0)
              {
               ModifyStopLoss(m_position.PriceOpen()-0*pp);
              }
           }
        }
      if(ExtTrailingStop>0)
        {
         if(m_position.PriceOpen()-pAsk>ExtTrailingStop*pp)
           {
            if(m_position.StopLoss()>pAsk+(ExtTrailingStop+ExtTrailingStep-1)*pp || m_position.StopLoss()==0)
              {
               ModifyStopLoss(pAsk+ExtTrailingStop*pp);
               return;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Modify StopLoss                                                  |
//| Parameters:                                                      |
//|   ldStopLoss - StopLoss Leve                                     |
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStopLoss)
  {
   bool fm;
   PlaySound("alert.wav");
   fm=m_trade.PositionModify(m_position.Ticket(),ldStopLoss,m_position.TakeProfit());
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
//| Get value of buffers for the iWPR                                |
//+------------------------------------------------------------------+
double iWPRGet(const int handle,const int index)
  {
   double WPR[];
   ArraySetAsSeries(WPR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iWPRBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,WPR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iWPR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(WPR[index]);
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
