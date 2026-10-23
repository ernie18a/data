//+------------------------------------------------------------------+
//|                         Fuzzy logic(barabashkakvn's edition).mq5 |
//|                                          Copyright © 2007, B@ss. |
//|                                               albass@mail333.com |
//+------------------------------------------------------------------+
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
input ushort   InpTrailingStop   = 0;
input double   PercentMM         = 8;
input double   DeltaMM           = 0;
input int      InitialBalance    = 10000;
input ushort   InpTakeProfit     = 20;
input ushort   InpStopLoss       = 60;
ulong          m_magic=73948148; // magic number
double Lots=0.1;
bool UseMM=true;
//---
int    handle_iGator;                        // variable for storing the handle of the iGator indicator 
int    handle_iWPR;                          // variable for storing the handle of the iWPR indicator 
int    handle_iDeMarker;                     // variable for storing the handle of the iDeMarker indicator 
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
int    handle_iAC;                           // variable for storing the handle of the iAC indicator 

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iGator
   handle_iGator=iGator(m_symbol.Name(),Period(),13,8,8,5,
                        5,3,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iGator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iGator indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR=iWPR(m_symbol.Name(),Period(),14);
//--- if the handle is not created 
   if(handle_iWPR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iDeMarker
   handle_iDeMarker=iDeMarker(m_symbol.Name(),Period(),14);
//--- if the handle is not created 
   if(handle_iDeMarker==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
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
//--- create handle of the indicator iAC
   handle_iAC=iAC(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iAC==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAC indicator for the symbol %s/%s, error code %d",
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
//---
   if(!IsTradeAllowed())
      return;

   if(CalculatePositions()==0)
      CheckForOpen();

//--- trailing
   if(InpTrailingStop>0)
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_symbol.Bid()-m_position.PriceOpen()>InpTrailingStop*m_adjusted_point)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-InpTrailingStop*m_adjusted_point)
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-InpTrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if((m_position.PriceOpen()-m_symbol.Ask())>(InpTrailingStop*m_adjusted_point))
                    {
                     if((m_position.StopLoss()>(m_symbol.Ask()+InpTrailingStop*m_adjusted_point)) || 
                        (m_position.StopLoss()==0))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+InpTrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }
              }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double volume=0.0,TempVolume=0.0,F=0.0;
   TempVolume=Lots;

   if(UseMM)
      TempVolume=0.00001*(m_account.Balance()*(PercentMM+DeltaMM)-InitialBalance*DeltaMM);

   volume=LotCheck(TempVolume);

   return (volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculatePositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FuzzyLogic()
  {
   double Gator,Gator2,SumGator,WPR,AC1,AC2,AC3,AC4,AC5,tempAC_b=0.0,tempAC_s=0.0,DeMarker,RSI,Decision=0.0;
   double Rang[5,5],Summary[5];
   int x,y;
   double arGator[8]    ={0.010,0.020,0.030,0.040,0.040,0.030,0.020,0.010};
   double arWPR[8]      ={-95,-90,-80,-75,-25,-20,-10,-5};
   double arAC[8]       ={0.05,0.04,0.03,0.02,0.02,0.03,0.04,0.05};
   double arDeMarker[8] ={0.15,0.2,0.25,0.3,0.7,0.75,0.8,0.85};
   double arRSI[8]      ={25,30,35,40,60,65,70,75};
   double Weight[5]     ={0.133,0.133,0.133,0.268,0.333};

   Gator    =iGatorGet(UPPER_HISTOGRAM,1);
   Gator2   =iGatorGet(LOWER_HISTOGRAM,1);
   SumGator =MathAbs(Gator)+MathAbs(Gator2);

   WPR      =iWPRGet(1);
   DeMarker =iDeMarkerGet(1);
   RSI      =iRSIGet(1);

   AC1      =iACGet(1);
   AC2      =iACGet(2);
   AC3      =iACGet(3);
   AC4      =iACGet(4);
   AC5      =iACGet(5);

   ArrayInitialize(Rang,0);
   ArrayInitialize(Summary,0);

//построение нечеткого классификатора
//1)=========================================================Gator==================================================      
   if(SumGator<arGator[0])
     {
      Rang[0,0]=0.5;
      Rang[0,4]=0.5;
     }
   if(SumGator>=arGator[0] && SumGator<arGator[1])
     {
      Rang[0,0]=(1-(SumGator-arGator[0])/(arGator[1]-arGator[0]))/2;
      Rang[0,1]=(1-Rang[0,0]*2)/2;

      Rang[0,4]=Rang[0,0];
      Rang[0,3]=Rang[0,1];
     }
   if(SumGator>=arGator[1] && SumGator<arGator[2])
     {
      Rang[0,1]=0.5;
      Rang[0,3]=0.5;
     }
   if(SumGator>=arGator[2] && SumGator<arGator[3])
     {
      Rang[0,1]=(1-(SumGator-arGator[2])/(arGator[3]-arGator[2]))/2;
      Rang[0,2]=1-Rang[0,1]*2;

      Rang[0,3]=Rang[0,1];
     }
   if(SumGator>=arGator[3] || SumGator>=arGator[4])
     {
      Rang[0,2]=1;
     }
//2)========================================================WPR=======================================================
   if(WPR<arWPR[0]){Rang[1,0]=1;}
   if(WPR>=arWPR[0] && WPR<arWPR[1])
     {
      Rang[1,0]=1-(WPR-arWPR[0])/(arWPR[1]-arWPR[0]);
      Rang[1,1]=1-Rang[1,0];
     }
   if(WPR>=arWPR[1] && WPR<arWPR[2]){Rang[1,1]=1;}
   if(WPR>=arWPR[2] && WPR<arWPR[3])
     {
      Rang[1,1]=1-(WPR-arWPR[2])/(arWPR[3]-arWPR[2]);
      Rang[1,2]=1-Rang[1,1];
     }
   if(WPR>=arWPR[3] && WPR<arWPR[4]){Rang[1,2]=1;}
   if(WPR>=arWPR[4] && WPR<arWPR[5])
     {
      Rang[1,2]=1-(WPR-arWPR[4])/(arWPR[5]-arWPR[4]);
      Rang[1,3]=1-Rang[1,2];
     }
   if(WPR>=arWPR[5] && WPR<arWPR[6]){Rang[1,3]=1;}
   if(WPR>=arWPR[6] && WPR<arWPR[7])
     {
      Rang[1,3]=1-(WPR-arWPR[6])/(arWPR[7]-arWPR[6]);
      Rang[1,4]=1-Rang[1,3];
     }
   if(WPR>=arWPR[7]){Rang[1,4]=1;}
//3)============================================================AC=====================================================     
   if(AC1<AC2 && AC1<0 && AC2<0){tempAC_b=2;}
   if(AC1<AC2 && AC2<AC3 && AC1<0 && AC2<0 && AC3<0){tempAC_b=3;}
   if(AC1<AC2 && AC2<AC3 && AC3<AC4 && AC1<0 && AC2<0 && AC3<0 && AC4<0){tempAC_b=4;}
   if(AC1<AC2 && AC2<AC3 && AC3<AC4 && AC4<AC5 && AC1<0 && AC2<0 && AC3<0 && AC4<0 && AC5<5){tempAC_b=5;}

   if(AC1>AC2 && AC1>0 && AC2>0){tempAC_s=2;}
   if(AC1>AC2 && AC2>AC3 && AC1>0 && AC2>0 && AC3>0){tempAC_s=3;}
   if(AC1>AC2 && AC2>AC3 && AC3>AC4 && AC1>0 && AC2>0 && AC3>0 && AC4>0){tempAC_s=4;}
   if(AC1>AC2 && AC2>AC3 && AC3>AC4 && AC4>AC5 && AC1>0 && AC2>0 && AC3>0 && AC4>0 && AC5>0){tempAC_s=5;}
   if(tempAC_b==arAC[0] || tempAC_b==arAC[1]){Rang[2,0]=1;}
   if(tempAC_b==arAC[2] || tempAC_b==arAC[3]){Rang[2,1]=1;}

   if(tempAC_s==arAC[4] || tempAC_s==arAC[5]){Rang[2,3]=1;}
   if(tempAC_s==arAC[6] || tempAC_s==arAC[7]){Rang[2,4]=1;}

   if(Rang[2,0]==0 && Rang[2,1]==0 && Rang[2,3]==0 && Rang[2,4]==0){Rang[2,2]=1;}
//4)=========================================================DeMarker==================================================
   if(DeMarker<arDeMarker[0]){Rang[3,0]=1;}
   if(DeMarker>=arDeMarker[0] && DeMarker<arDeMarker[1])
     {
      Rang[3,0]=1-(DeMarker-arDeMarker[0])/(arDeMarker[1]-arDeMarker[0]);
      Rang[3,1]=1-Rang[3,0];
     }
   if(DeMarker>=arDeMarker[1] && DeMarker<arDeMarker[2]){Rang[3,1]=1;}
   if(DeMarker>=arDeMarker[2] && DeMarker<arDeMarker[3])
     {
      Rang[3,1]=1-(DeMarker-arDeMarker[2])/(arDeMarker[3]-arDeMarker[2]);
      Rang[3,2]=1-Rang[3,1];
     }
   if(DeMarker>=arDeMarker[3] && DeMarker<arDeMarker[4]){Rang[3,2]=1;}
   if(DeMarker>=arDeMarker[4] && DeMarker<arDeMarker[5])
     {
      Rang[3,2]=1-(DeMarker-arDeMarker[4])/(arDeMarker[5]-arDeMarker[4]);
      Rang[3,3]=1-Rang[3,2];
     }
   if(DeMarker>=arDeMarker[5] && DeMarker<arDeMarker[6]){Rang[3,3]=1;}
   if(DeMarker>=arDeMarker[6] && DeMarker<arDeMarker[7])
     {
      Rang[3,3]=1-(DeMarker-arDeMarker[6])/(arDeMarker[7]-arDeMarker[6]);
      Rang[3,4]=1-Rang[3,3];
     }
   if(DeMarker>=arDeMarker[7]){Rang[3,4]=1;}

//5)==========================================================RSI======================================================
   if(RSI<arRSI[0]){Rang[4,0]=1;}
   if(RSI>=arRSI[0] && RSI<arRSI[1])
     {
      Rang[4,0]=1-(RSI-arRSI[0])/(arRSI[1]-arRSI[0]);
      Rang[4,1]=1-Rang[4,0];
     }
   if(RSI>=arRSI[1] && RSI<arRSI[2]){Rang[4,1]=1;}
   if(RSI>=arRSI[2] && RSI<arRSI[3])
     {
      Rang[4,1]=1-(RSI-arRSI[2])/(arRSI[3]-arRSI[2]);
      Rang[4,2]=1-Rang[4,1];
     }
   if(RSI>=arRSI[3] && RSI<arRSI[4]){Rang[4,2]=1;}
   if(RSI>=arRSI[4] && RSI<arRSI[5])
     {
      Rang[4,2]=1-(RSI-arRSI[4])/(arRSI[5]-arRSI[4]);
      Rang[4,3]=1-Rang[4,2];
     }
   if(RSI>=arRSI[5] && RSI<arRSI[6]){Rang[4,3]=1;}
   if(RSI>=arRSI[6] && RSI<arRSI[7])
     {
      Rang[4,3]=1-(RSI-arRSI[6])/(arRSI[7]-arRSI[6]);
      Rang[4,4]=1-Rang[4,3];
     }
   if(RSI>=arRSI[7]){Rang[4,4]=1;}
//________________________________________________________________свертка для рангов__________________________________________________      
   for(x=0;x<4;x++)
     {
      for(y=0;y<4;y++)
        {Summary[x]=Summary[x]+Rang[y,x]*Weight[x];}
      if(Summary[x]>1) {Print(Summary[x]," x=",x);}
     }

   for(x=0;x<4;x++)
     {Decision=Decision+Summary[x]*(0.2*(x+1)-0.1);}

//Print("Gator-     ",SumGator,"==",Rang[0,0],"--",Rang[0,1],"--",Rang[0,2],"--",Rang[0,3],"--",Rang[0,4]);
//Print("WPR-       ",WPR,"==",Rang[1,0],"--",Rang[1,1],"--",Rang[1,2],"--",Rang[1,3],"--",Rang[1,4]);
//Print("tempAC_b- ",tempAC_b,"       ","tempAC_s- ",tempAC_s,"    ==",Rang[2,0],"--",Rang[2,1],"--",Rang[2,2],"--",Rang[2,3],"--",Rang[2,4]);
//Print("DeMarker-  ",DeMarker,"==",Rang[3,0],"--",Rang[3,1],"--",Rang[3,2],"--",Rang[3,3],"--",Rang[3,4]);
//Print("RSI-       ",RSI,"==",Rang[4,0],"--",Rang[4,1],"--",Rang[4,2],"--",Rang[4,3],"--",Rang[4,4]);

   return(Decision);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   if(FuzzyLogic()>0.75/*<0.25*/)
     {
      double lots=LotsOptimized();
      if(lots==0)
         return;

      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lots,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=lots)
           {
            if(m_trade.Sell(lots,NULL,m_symbol.Bid(),
               m_symbol.NormalizePrice(m_symbol.Bid()+InpStopLoss*m_adjusted_point),
               m_symbol.NormalizePrice(m_symbol.Bid()-InpTakeProfit*m_adjusted_point)))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  time_0=iTime(1);
                  return;
                 }
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               time_0=iTime(1);
               return;
              }
           }
     }

   if(FuzzyLogic()<0.25/*>0.75*/)
     {
      double lots=LotsOptimized();
      if(lots==0)
         return;

      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lots,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=lots)
           {
            if(m_trade.Buy(lots,NULL,m_symbol.Ask(),
               m_symbol.NormalizePrice(m_symbol.Ask()-InpStopLoss*m_adjusted_point),
               m_symbol.NormalizePrice(m_symbol.Ask()+InpTakeProfit*m_adjusted_point)))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  time_0=iTime(1);
                  return;
                 }
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               time_0=iTime(1);
               return;
              }
           }
     }
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
//| Get value of buffers for the iGator                              |
//|  Buffer numbers:                                                 |
//|   0 - UPPER_HISTOGRAM, 1 - color buffer of the upper histogram,  |
//|   2 - LOWER_HISTOGRAM, 3 - color buffer of the lower histogram   |
//+------------------------------------------------------------------+
double iGatorGet(const int buffer,const int index)
  {
   double Gator[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iGator array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iGator,buffer,index,1,Gator)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iGator indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Gator[0]);
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
//| Get value of buffers for the iDeMarker                           |
//+------------------------------------------------------------------+
double iDeMarkerGet(const int index)
  {
   double DeMarker[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iDeMarker array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iDeMarker,0,index,1,DeMarker)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iDeMarker indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(DeMarker[0]);
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
//| Get value of buffers for the iAC                                |
//+------------------------------------------------------------------+
double iACGet(const int index)
  {
   double AC[];
   ArraySetAsSeries(AC,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iACBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAC,0,0,index+1,AC)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAC indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(AC[index]);
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
