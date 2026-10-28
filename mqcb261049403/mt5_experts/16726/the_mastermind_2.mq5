//+------------------------------------------------------------------+
//|                         MasterMind2(barabashkakvn's edition).mq5 |
//|                          Copyright © 2008, CreativeSilence, Inc. |
//|                                  http://www.creative-silence.com |
//+------------------------------------------------------------------+
#define PosStr "MasterMind2 By L.Bigger AKA Silence"
#property copyright "Copyright © 2008, CreativeSilence, Inc."
#property link      "http://www.creative-silence.com"
#property version   "1.001"

#include <Trade\SymbolInfo.mqh> 
#include <Trade\PositionInfo.mqh> 
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
CSymbolInfo    m_symbol;                     // symbol info object
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double   Lots=0.1;                     // volume of trade
input int      StopLoss=500;                 // stop loss
input int      TakeProfit=500;               // take profit
input bool     TradeAtCloseBar=true;
input int      TrailingStop=50;              // trailing stop
input int      TrailingStep=100;             // trailing step
input int      BreakEven=150;                // break-even point
input ulong    MagicNumber=94586789;         // magic
//--- for alerts:
input int      Repeat=3;
input int      AlertPeriods=5;
input bool     UseAlert=false;
input bool     SendEmail=true;
input ulong    Slippage=3;
//---
int            Crepeat=0;
datetime       AlertTime=0;
long           AheadTradeSec= 0;
long           AheadExitSec = 0;
int            TradeBar=0;

static int TradeLast=0;
string sound="alert.wav";
double sig_buy=0,sig_sell=0,sig_high=0,sig_low=0;
int Spread=0;

int    handle_iStochastic;                   // variable for storing the handle of the iStochastic indicator 
int    handle_iWPR;                          // variable for storing the handle of the iWPR indicator 
bool   FirstRun=true;                        // first run
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                     // sets symbol name
   m_symbol.Refresh();
   m_trade.SetExpertMagicNumber(MagicNumber);   // sets magic number
   m_trade.SetDeviationInPoints(Slippage);      // sets slippage
   Crepeat=Repeat;
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(Symbol(),Period(),100,3,3,MODE_SMMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR=iWPR(Symbol(),Period(),100);
//--- if the handle is not created 
   if(handle_iWPR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   FirstRun=true;
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
   if(TradeAtCloseBar)
      TradeBar=1;
   else
      TradeBar=0;

   Spread=m_symbol.Spread();

//---
   int   i=0;

   double   BuyValue=0,SellValue=0;
   BuyValue=0; SellValue=0;

   if(CntPos(POSITION_TYPE_BUY,MagicNumber)>0)
      TradeLast=1;
   if(CntPos(POSITION_TYPE_SELL,MagicNumber)>0)
      TradeLast=-1;

   sig_buy=iStochasticGet(SIGNAL_LINE,0);
   sig_sell=iStochasticGet(SIGNAL_LINE,0);
   sig_high=iWPRGet(1);
   sig_low=iWPRGet(1);

   if(sig_buy<3 && sig_high<-99.9)
     {
      BuyValue=1;
     }

   if(sig_sell>97 && sig_low>-0.1)
     {
      SellValue=1;
     }

   int  OpenPos=0,OpenSell=0,OpenBuy=0,CloseSell=0,CloseBuy=0;
   double mode=0,Stop=0,NewBarTime=0;

//--- here we found if new bar has just opened
   static datetime prevtime=0;
   int NewBar=0;

   if(FirstRun)
     {
      FirstRun=false;
      prevtime=iTime(m_symbol.Name(),Period(),0);
     }

   if(prevtime==iTime(m_symbol.Name(),Period(),0))
     {
      NewBar=0;
     }
   else
     {
      prevtime=iTime(m_symbol.Name(),Period(),0);
      NewBar=1;
     }

   int   AllowTrade=0,AllowExit=0;

//--- trade before bar current bar closed
   if(TimeCurrent()>=iTime(m_symbol.Name(),Period(),0)+PeriodSeconds()-AheadTradeSec)
      AllowTrade=1;
   else
      AllowTrade=0;
   if(TimeCurrent()>=iTime(m_symbol.Name(),Period(),0)+PeriodSeconds()-AheadExitSec)
      AllowExit=1;
   else AllowExit=0;
   if(AheadTradeSec==0)
      AllowTrade=1;
   if(AheadExitSec==0)
      AllowExit=1;

   OpenPos=0;
   for(int cnt=PositionsTotal()-1;cnt>=0;cnt--)
     {
      if(m_position.SelectByIndex(i))
         if((m_position.PositionType()==POSITION_TYPE_SELL || m_position.PositionType()==POSITION_TYPE_BUY) && 
            m_position.Symbol()==Symbol() && ((m_position.Magic()==MagicNumber) || MagicNumber==0))
            OpenPos=OpenPos+1;
     }

   if(OpenPos>=1)
     {
      OpenSell=0; OpenBuy=0;
     }

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
     {
      CloseBuy=1;
     }

   if(BuyValue>0)
     {
      CloseSell=1;
     }

   subPrintDetails();

   for(int cnt=PositionsTotal()-1;cnt>=0;cnt--)
     {
      if(m_position.SelectByIndex(i))
         if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==Symbol() && 
            ((m_position.Magic()==MagicNumber) || MagicNumber==0))
           {
            if(CloseBuy==1 && AllowExit==1)
              {
               if(NewBar==1 && TradeBar>0)
                 {
                  PlaySound("alert.wav");
                  m_trade.PositionClose(m_position.Ticket());
                  if(!RefreshRates())
                     return;
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Bid(),0,0,m_position.Ticket());
                  return;
                 }
               if(TradeBar==0)
                 {
                  PlaySound("alert.wav");
                  m_trade.PositionClose(m_position.Ticket());
                  if(!RefreshRates())
                     return;
                  Alerts(0,0,CloseBuy,CloseSell,m_symbol.Bid(),0,0,m_position.Ticket());
                  return;
                 }
              }
           }

      if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==Symbol() && ((m_position.Magic()==MagicNumber) || MagicNumber==0))
        {
         if(CloseSell==1 && AllowExit==1)
           {
            if(NewBar==1 && TradeBar>0)
              {
               PlaySound("alert.wav");
               m_trade.PositionClose(m_position.Ticket());
               if(!RefreshRates())
                  return;
               Alerts(0,0,CloseBuy,CloseSell,m_symbol.Ask(),0,0,m_position.Ticket());
               return;
              }
            if(TradeBar==0)
              {
               PlaySound("alert.wav");
               m_trade.PositionClose(m_position.Ticket());
               if(!RefreshRates())
                  return;
               Alerts(0,0,CloseBuy,CloseSell,m_symbol.Ask(),0,0,m_position.Ticket());
               return;
              }
           }
        }
     }

   double MyStopLoss=0,MyTakeProfit=0;
   ulong m_ticket=0;

//--- should we open a position?
   if(OpenPos<=2)
     {
      if(OpenSell==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            if(!RefreshRates())
               return;
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Bid()-TakeProfit*Point();
            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Bid()+StopLoss*Point();

            if(!CheckMoneyForTrade(Symbol(),Lots,ORDER_TYPE_SELL))
               return;
            PlaySound("alert.wav");

            if(m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),MyStopLoss,MyTakeProfit,PosStr))
              {
               m_ticket=m_trade.ResultDeal();
              }

            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Bid(),MyStopLoss,MyTakeProfit,m_ticket);
            OpenSell=0;
            return;
           }
         if(TradeBar==0)
           {
            if(!RefreshRates())
               return;
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Bid()-TakeProfit*Point();
            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Bid()+StopLoss*Point();

            if(!CheckMoneyForTrade(Symbol(),Lots,ORDER_TYPE_SELL))
               return;
            PlaySound("alert.wav");

            if(m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),MyStopLoss,MyTakeProfit,PosStr))
              {
               m_ticket=m_trade.ResultDeal();
              }

            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Bid(),MyStopLoss,MyTakeProfit,m_ticket);
            OpenSell=0;
            return;
           }
        }
      if(OpenBuy==1 && AllowTrade==1)
        {
         if(NewBar==1 && TradeBar>0)
           {
            if(!RefreshRates())
               return;
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Ask()+TakeProfit*Point();
            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Ask()-StopLoss*Point();

            if(!CheckMoneyForTrade(Symbol(),Lots,ORDER_TYPE_BUY))
               return;
            PlaySound("alert.wav");

            if(m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),MyStopLoss,MyTakeProfit,PosStr))
              {
               m_ticket=m_trade.ResultDeal();
              }

            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Ask(),MyStopLoss,MyTakeProfit,m_ticket);
            OpenBuy=0;
            return;
           }
         if(TradeBar==0)
           {
            if(!RefreshRates())
               return;
            if(TakeProfit==0)
               MyTakeProfit=0;
            else
               MyTakeProfit=m_symbol.Ask()+TakeProfit*Point();
            if(StopLoss==0)
               MyStopLoss=0;
            else
               MyStopLoss=m_symbol.Ask()-StopLoss*Point();

            if(!CheckMoneyForTrade(Symbol(),Lots,ORDER_TYPE_BUY))
               return;
            PlaySound("alert.wav");

            if(m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),MyStopLoss,MyTakeProfit,PosStr))
              {
               m_ticket=m_trade.ResultDeal();
              }

            Alerts(OpenBuy,OpenSell,0,0,m_symbol.Ask(),MyStopLoss,MyTakeProfit,m_ticket);
            OpenBuy=0;
            return;
           }
        }
     }

   for(int cnt=PositionsTotal()-1;cnt>=0;cnt--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.Symbol()==Symbol() && ((m_position.Magic()==MagicNumber) || MagicNumber==0))
           {
            TrailingPositions(m_position.Ticket());
           }
        }
     }
   Alerts(0,0,0,0,0,0,0,0);
//--- the end
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  SetText(datetime X1,double Y1,string TEXT_NAME,string TEXT_VALUE,int TEXT_COLOR)
  {
   return;
   if(ObjectFind(0,TEXT_NAME)!=-1)
     {
      ObjectCreate(0,TEXT_NAME,OBJ_TEXT,0,X1,Y1);
      ObjectSetInteger(0,TEXT_NAME,OBJPROP_COLOR,TEXT_COLOR);
      ObjectSetString(0,TEXT_NAME,OBJPROP_FONT,"Wingdings");
      //ObjectSetText(TEXT_NAME,TEXT_VALUE,10,"Wingdings",EMPTY);
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

//Alert system
   if(UseAlert)
     {
      if(_buy==1)
        {
         if(Crepeat==Repeat)
           {
            AlertTime=0;
           }
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>AlertPeriods)
           {
            if(_buy==1)
              {
               AlertStr=AlertStr+
                        "Buy @ "+DoubleToString(_op,Digits())+
                        "; SL: "+DoubleToString(_sl,Digits())+
                        "; TP: "+DoubleToString(_tp,Digits())+" at "+CurDate+
                        " Order:"+DoubleToString(_ticket,0)+".";
               Alert(Symbol()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(Symbol()+" "+EnumToString(Period())+": "
                           ,Symbol()+" "+EnumToString(Period())+": "+AlertStr);
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
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>AlertPeriods)
           {
            if(_sell==1)
              {
               AlertStr=AlertStr+
                        "Sell @ "+DoubleToString(_op,Digits())+
                        "; SL: "+DoubleToString(_sl,Digits())+
                        "; TP: "+DoubleToString(_tp,Digits())+" at "+CurDate+
                        " Order:"+DoubleToString(_ticket,0)+".";
               Alert(Symbol()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(Symbol()+" "+EnumToString(Period())+": ",
                           Symbol()+" "+EnumToString(Period())+": "+AlertStr);
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
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>AlertPeriods)
           {
            if(_exitsell==1)
              {
               AlertStr=AlertStr+
                        " Close Sell @ "+DoubleToString(_op,Digits())+" at "+CurDate+
                        " Order:"+DoubleToString(_ticket,0)+".";
               Alert(Symbol()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(Symbol()+" "+EnumToString(Period())+": ",
                           Symbol()+" "+EnumToString(Period())+": "+AlertStr);
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
         if(Crepeat>0 && (TimeCurrent()-AlertTime)>AlertPeriods)
           {
            if(_exitbuy==1)
              {
               AlertStr=AlertStr+
                        " Close Buy @ "+DoubleToString(_op,Digits())+" at "+CurDate+
                        " Order:"+DoubleToString(_ticket,0)+".";
               Alert(Symbol()," ",Period(),": ",AlertStr);
               if(SendEmail)
                 {
                  SendMail(Symbol()+" "+EnumToString(Period())+": ",
                           Symbol()+" "+EnumToString(Period())+": "+AlertStr);
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
//----------------------- PRINT COMMENT FUNCTION
void subPrintDetails()
  {
   return;
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
   sComment = "The MasterMind2 By L.Bigger AKA Silence" + NL;
   sComment = sComment + "StopLoss=" + DoubleToString(StopLoss,0) + " | ";
   sComment = sComment + "TakeProfit=" + DoubleToString(TakeProfit,0) + " | ";
   sComment = sComment + "TrailingStop=" + DoubleToString(TrailingStop,0) + NL;
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToString(Lots,2) + " | ";
   sComment = sComment + "LastTrade=" + DoubleToString(TradeLast,0) + NL;
   sComment = sComment + "sig_buy=" + DoubleToString(sig_buy,Digits()) + NL;
   sComment = sComment + "sig_sell=" + DoubleToString(sig_sell,Digits()) + NL;
   sComment = sComment + sp;
   Comment(sComment);
  }
//+------------------------------------------------------------------+
//|  Number of positions with specific parameters                    |
//+------------------------------------------------------------------+
int CntPos(ENUM_POSITION_TYPE Type,ulong Magic)
  {
   int _CntPos;
   _CntPos=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol())
           {
            if(m_position.PositionType()==Type)
               if(m_position.Magic()==Magic || Magic==0)
                  _CntPos++;
           }
     }
   return(_CntPos);
  }
//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation";                             break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy";                                            break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      //---- mql4 errors
      case 4000: error_string="no error";                                                 break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid m_ticket";                                           break;
      case 4109: error_string="trade is not allowed";                                     break;
      case 4110: error_string="longs are not allowed";                                    break;
      case 4111: error_string="shorts are not allowed";                                   break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions(const ulong ticket)
  {
   double pBid,pAsk;

   if(!RefreshRates())
      return;

   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      pBid=m_symbol.Bid();

      //--- breakEven routine
      if(BreakEven>0)
        {
         if((pBid-m_position.PriceOpen())>BreakEven*Point())
           {
            if((m_position.StopLoss()-m_position.PriceOpen())<0)
              {
               m_trade.PositionModify(ticket,m_position.PriceOpen(),m_position.TakeProfit());
               PlaySound("alert.wav");
              }
           }
        }

      if(TrailingStop>0)
        {
         if((pBid-m_position.PriceOpen())>TrailingStop*Point())
           {
            if(m_position.StopLoss()<pBid-(TrailingStop+TrailingStep-1)*Point())
              {
               m_trade.PositionModify(ticket,pBid-TrailingStop*Point(),m_position.TakeProfit());
               PlaySound("alert.wav");
               return;
              }
           }
        }
     }
   if(m_position.PositionType()==POSITION_TYPE_SELL)
     {
      pAsk=m_symbol.Ask();

      if(BreakEven>0)
        {
         if((m_position.PriceOpen()-pAsk)>BreakEven*Point())
           {
            if((m_position.PriceOpen()-m_position.StopLoss())<0)
              {
               m_trade.PositionModify(ticket,m_position.PriceOpen(),m_position.TakeProfit());
               PlaySound("alert.wav");
              }
           }
        }

      if(TrailingStop>0)
        {
         if(m_position.PriceOpen()-pAsk>TrailingStop*Point())
           {
            if(m_position.StopLoss()>pAsk+(TrailingStop+TrailingStep-1)*Point() || m_position.StopLoss()==0)
              {
               m_trade.PositionModify(ticket,pAsk+TrailingStop*Point(),m_position.TakeProfit());
               PlaySound("alert.wav");
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
   double Stochastic[];
   ArraySetAsSeries(Stochastic,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,0,index+1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iWPR                                |
//+------------------------------------------------------------------+
double iWPRGet(const int index)
  {
   double WPR[];
   ArraySetAsSeries(WPR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iWPRBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iWPR,0,0,index+1,WPR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iWPR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(WPR[index]);
  }
//+------------------------------------------------------------------+
//| Refresh Rates                                                    |
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
//| Check Money For Trade                                            |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   if(!RefreshRates())
      return(false);
//---
   double price=m_symbol.Ask();
   if(type==ORDER_TYPE_SELL)
      price=m_symbol.Bid();
//--- values of the required and free margin
   double margin,free_margin=m_account.FreeMargin();
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
