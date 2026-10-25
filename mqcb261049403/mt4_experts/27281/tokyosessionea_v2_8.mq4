//====================================================================================================================================================//
#property copyright   "Copyright 2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "2.8"
//#property icon        "\\Images\\TokyoSessionEA.ico";
#property strict
//====================================================================================================================================================//
#define MagicSet 3330777
//====================================================================================================================================================//
enum Sign {Contrary_Trend, According_Trend};
enum Sets {Input_Parameters_0, Presets_EURAUD_1, Presets_EURUSD_2, Presets_EURCHF_3, Presets_GBPNZD_4, Presets_GBPCHF_5, Presets_AUDUSD_6,
           Presets_AUDCAD_7, Presets_NZDCAD_8, Presets_NZDCHF_9, Presets_USDCHF_10, Presets_CADCHF_11, Presets_CHFJPY_12
          };
//====================================================================================================================================================//
extern string PresetsInputsStr  = "||========== Presets Inputs ==========||";
extern Sets   PresetsParameters = Input_Parameters_0;
extern string SetSignals        = "||========== Signals Parameter ==========||";
extern int    BrokerOffsetGMT   = 3;//Broker GMT Offset
extern ENUM_TIMEFRAMES TimeFrame= PERIOD_H1;//Time Frame Use
extern Sign   TypeOfSignals     = Contrary_Trend;//Type Of Signals
extern int    TimeSetLevels     = 21;//Time Set Levels
extern int    TimeCheckLevels   = 6;//Time Open Orders
extern double MinDistanceOfLevel= 0.0;//Min Distance Of Levels
extern double MaxDistanceOfLevel= 46.0;//Max Distance Of Levels
extern bool   ReCheckPrices     = true;//Recheck Prices
extern int    TimeRecheckPrices = 3;//Time Recheck Prices
extern bool   CheckAllBars      = true;//Check All Bars
extern bool   CloseInSignal     = true;//Close Orders In Signal
extern bool   CloseOrdersOnTime = true;//Close Orders On Time
extern int    TimeCloseOrders   = 8;//Time Close Orders
extern bool   UseFloatingPoint  = false;//Floating Point Send Orders
extern double PipsFloatingPoint = 1.5;//Pips For Floating Point
extern string SetOrders         = "||========== Orders Parameter ==========||";
extern bool   UseTakeProfit     = true;//Place Take Profit
extern double TakeProfit        = 10.0;//Pips Take Profit
extern bool   UseStopLoss       = true;//Place Stop Loss
extern double StopLoss          = 26.0;//Pips Stop Loss
extern bool   UseTrailingStop   = false;//Use Trailing Stop
extern double TrailingStop      = 5.0;//Pips Trailing Stop
extern double TrailingStep      = 1.0;//Step Trailing Stop
extern bool   UseBreakEven      = false;//Use Break Even
extern double BreakEven         = 2.5;//Pips Break Even
extern double BreakEvenAfter    = 0.0;//Profit Break Even
extern string SetRisk           = "||========== Risk Parameter ==========||";
extern bool   AutoLotSize       = true;//Auto Money Management
extern double RiskFactor        = 25.0;//Risk For Money Management
extern double ManualLotSize     = 0.01;//Manual Lot Size
extern bool   UseRecoveryLot    = false;//Recovery Lot After Loss
extern double MultiplierLot     = 5.0;//Multiplier For Lot Recovery
extern string SetGeneral        = "||========== General Parameter ==========||";
extern double MaxSpread         = 2.5;//Max Accepted Spread (0=Not Limit)
extern int    MaxOrders         = 0;//Max Opened Orders (0=No Limit)
extern int    Slippage          = 3;//Accepted Slippage
extern bool   RunNDDbroker      = false;//For NDD Broker
extern bool   SoundAlert        = true;//Play Sound Alerts
extern bool   PrintOperations   = false;//Print Information Log
extern int    MagicNumber       = 0;//Orders' ID (0=Generate Automatically)
extern string CommentsOrders    = "TokyoSessionEA";//Orders' Comment
extern string SpreadFromTester  = "||========== Spread From Tester ==========||";
extern double TesterSpread      = 1.0;//Spread Set Tester
//====================================================================================================================================================//
string SoundAtClose="alert2.wav";
string SoundAtOpen="alert.wav";
string SoundAtModify="tick.wav";
string SymbolExtension="";
string ExpertName;
string SymbolTrade;
string BackgroundName;
double DigitPoints;
double StopLevel;
double Spread;
double TotalHistoryProfitLoss;
double ProfitBuyOrders;
double ProfitSellOrders;
double SumFloating;
double HistoryPipsBuy;
double HistoryPipsSell;
double LastLotSize;
double NewTakeProfit=0;
double NewStopLoss=0;
double HighPrice=0;
double LowPrice=0;
double GetAskPrice=0;
double GetBidPrice=0;
int WarningMessage;
int OrdersID;
int TotalHistoryOrders;
int MultiplierPoint;
int SumOrders;
int BuyOrders;
int SellOrders;
int i;
int CountTimes;
int ResultsOrder;
int HistoryOrdersBuy;
int HistoryOrdersSell;
bool AcceptedSpread;
bool OpenBuy;
bool OpenSell;
bool CloseBuy;
bool CloseSell;
bool StartFloatingBuy=false;
bool StartFloatingSell=false;
long ChartColor;
datetime TimeLastBuy;
datetime TimeLastSell;
datetime LastTime;
//====================================================================================================================================================//
//OnInit function
//====================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//Started information
   ExpertName=WindowExpertName();
   SymbolTrade=Symbol();
   if(StringLen(SymbolTrade)>6)
      SymbolExtension=StringSubstr(SymbolTrade,6,0);
//---------------------------------------------------------------------
//Background
   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   BackgroundName="Background-"+WindowExpertName();
//---
   if(ObjectFind(BackgroundName)==-1)
      ChartBackground(BackgroundName,(color)ChartColor,0,15,220,168);
//---------------------------------------------------------------------
//Broker 4 or 5 digits
   DigitPoints=MarketInfo(SymbolTrade,MODE_POINT);
   MultiplierPoint=1;
//---
   if((MarketInfo(SymbolTrade,MODE_DIGITS)==3)||(MarketInfo(SymbolTrade,MODE_DIGITS)==5))
     {
      MultiplierPoint=10;
      DigitPoints*=MultiplierPoint;
     }
//---
   if(MarketInfo(SymbolTrade,MODE_DIGITS)==2)
     {
      MultiplierPoint=10;
      DigitPoints*=MultiplierPoint;
     }
//---------------------------------------------------------------------
//Stop level
   StopLevel=MathMax(MarketInfo(SymbolTrade,MODE_FREEZELEVEL)/MultiplierPoint,MarketInfo(SymbolTrade,MODE_STOPLEVEL)/MultiplierPoint);
//---------------------------------------------------------------------
//Minimum and maximum value
   if((TrailingStop>0)&&(TrailingStop<StopLevel))
      TrailingStop=StopLevel;
   if((BreakEven>0)&&(BreakEven<StopLevel))
      BreakEven=StopLevel;
   if((TakeProfit>0)&&(TakeProfit<StopLevel))
      TakeProfit=StopLevel;
   if((StopLoss>0)&&(StopLoss<StopLevel))
      StopLoss=StopLevel;
   if(RiskFactor<1)
      RiskFactor=1;
   if(RiskFactor>100)
      RiskFactor=100;
   if(BrokerOffsetGMT>24)
      BrokerOffsetGMT=24;
   if(BrokerOffsetGMT<-24)
      BrokerOffsetGMT=-24;
//---------------------------------------------------------------------
//Set parameters
//---For EURAUD 1
   if(PresetsParameters==1)
     {
      SymbolTrade="EURAUD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 19;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 46.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 18;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 23;//Time Close Orders
     }
//---For EURUSD 2
   if(PresetsParameters==2)
     {
      SymbolTrade="EURUSD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 21;//Time Set Levels
      TimeCheckLevels   = 6;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 46.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 3;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = true;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 8;//Time Close Orders
      TakeProfit        = 10.0;//Pips Take Profit
      StopLoss          = 26.0;//Pips Stop Loss
     }
//---For EURCHF 3
   if(PresetsParameters==3)
     {
      SymbolTrade="EURCHF"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 17;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 50.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 19;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 7;//Time Close Orders
     }
//---For GBPNZD 4
   if(PresetsParameters==4)
     {
      SymbolTrade="GBPNZD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 19;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 84.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 17;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 6;//Time Close Orders
     }
//---For GBPCHF 5
   if(PresetsParameters==5)
     {
      SymbolTrade="GBPCHF"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 20;//Time Set Levels
      TimeCheckLevels   = 22;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 18.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 14;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 16;//Time Close Orders
     }
//---For AUDUSD 6
   if(PresetsParameters==6)
     {
      SymbolTrade="AUDUSD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 18;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 36.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 19;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 19;//Time Close Orders
     }
//---For AUDCAD 7
   if(PresetsParameters==7)
     {
      SymbolTrade="AUDCAD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 19;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 1.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 90.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 18;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = false;//Close Orders On Time
      TimeCloseOrders   = 8;//Time Close Orders
     }
//---For NZDCAD 8
   if(PresetsParameters==8)
     {
      SymbolTrade="NZDCAD"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 18;//Time Set Levels
      TimeCheckLevels   = 22;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 32.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 20;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 12;//Time Close Orders
     }
//---For NZDCHF 9
   if(PresetsParameters==9)
     {
      SymbolTrade="NZDCHF"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 19;//Time Set Levels
      TimeCheckLevels   = 22;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 26.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 22;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 12;//Time Close Orders
     }
//---For USDCHF 10
   if(PresetsParameters==10)
     {
      SymbolTrade="USDCHF"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 17;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 12.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 20;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 17;//Time Close Orders
     }
//---For CADCHF 11
   if(PresetsParameters==11)
     {
      SymbolTrade="CADCHF"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 18;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 0.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 90.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 13;//Time Recheck Prices
      CheckAllBars      = false;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 13;//Time Close Orders
     }
//---For CHFJPY 12
   if(PresetsParameters==12)
     {
      SymbolTrade="CHFJPY"+SymbolExtension;
      //---
      if((!IsTesting())&&(!IsVisualMode())&&(!IsOptimization()))
        {
         if((SymbolSelect(SymbolTrade,true)))
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" is ok");
         else
            Print(" # "+WindowExpertName()+" # "+SymbolTrade+" not found");
         if((ChartSymbol()!=SymbolTrade)||(ChartPeriod()!=PERIOD_H1))
           {
            Comment("\n\nExpert set chart symbol...");
            Print(" # "+WindowExpertName()+" # "+"Set chart symbol: "+SymbolTrade+" and Period: H1");
            ChartSetSymbolPeriod(0,SymbolTrade,PERIOD_H1);
           }
        }
      TimeSetLevels     = 18;//Time Set Levels
      TimeCheckLevels   = 21;//Time Open Orders
      MinDistanceOfLevel= 1.0;//Min Distance Of Levels
      MaxDistanceOfLevel= 24.0;//Max Distance Of Levels
      ReCheckPrices     = true;//Recheck Prices
      TimeRecheckPrices = 20;//Time Recheck Prices
      CheckAllBars      = true;//Check All Bars
      CloseInSignal     = false;//Close Orders In Signal
      CloseOrdersOnTime = true;//Close Orders On Time
      TimeCloseOrders   = 6;//Time Close Orders
     }
//---------------------------------------------------------------------
//Set ID
   OrdersID=MagicNumber;
//---
   if(MagicNumber==0)
     {
      OrdersID=0;
      for(i=0; i<StringLen(SymbolTrade); i++)
         OrdersID+=(StringGetChar(SymbolTrade,i)*(i+1));
      OrdersID+=MagicSet;
     }
//---------------------------------------------------------------------
//Set time clock
   TimeSetLevels+=BrokerOffsetGMT;
   TimeCheckLevels+=BrokerOffsetGMT;
   TimeRecheckPrices+=BrokerOffsetGMT;
   TimeCloseOrders+=BrokerOffsetGMT;
//---
   if(TimeSetLevels<0)
      TimeSetLevels+=24;
   if(TimeSetLevels>=24)
      TimeSetLevels-=24;
//---
   if(TimeCheckLevels<0)
      TimeCheckLevels+=24;
   if(TimeCheckLevels>=24)
      TimeCheckLevels-=24;
//---
   if(TimeRecheckPrices<0)
      TimeRecheckPrices+=24;
   if(TimeRecheckPrices>=24)
      TimeRecheckPrices-=24;
//---
   if(TimeCloseOrders<0)
      TimeCloseOrders+=24;
   if(TimeCloseOrders>=24)
      TimeCloseOrders-=24;
//---------------------------------------------------------------------
   if(!IsTesting())
      OnTick();//For show comment if market is closed
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//OnDeinit function
//====================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
//Clear chart
   ObjectDelete(BackgroundName);
   Comment("");
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//OnTick function
//====================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
//Call main function
   MainFunction();
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//OnTick function
//====================================================================================================================================================//
void MainFunction()
  {
//---------------------------------------------------------------------
   AcceptedSpread=true;
   OpenBuy=false;
   OpenSell=false;
   CloseBuy=false;
   CloseSell=false;
//---------------------------------------------------------------------
//Market spread
   Spread=(Ask-Bid)/DigitPoints;
//---------------------------------------------------------------------
//Check spread
   if((Spread>MaxSpread)&&(MaxSpread>0))
      AcceptedSpread=false;
//---------------------------------------------------------------------
//Count orders
   CountOrders();
//---------------------------------------------------------------------
//Set stop loss and take profit with out control spread
   if(MaxSpread==0)
     {
      //Spread for optimization=1.5
      if(Spread>TesterSpread)
        {
         NewTakeProfit=TakeProfit-(Spread-TesterSpread);
         NewStopLoss=StopLoss-(Spread-TesterSpread);
        }
      if((NewTakeProfit>0)&&(NewTakeProfit<StopLevel))
         NewTakeProfit=StopLevel;
      if((NewStopLoss>0)&&(NewStopLoss<StopLevel))
         NewStopLoss=StopLevel;
     }
   else
     {
      NewTakeProfit=TakeProfit;
      NewStopLoss=StopLoss;
     }
//---
   if((Spread>=TakeProfit)||(Spread>=StopLoss))
      AcceptedSpread=false;
//---------------------------------------------------------------------
//Check signals
   GetSignals();
//---------------------------------------------------------------------
//Call comment and history orders function
   if(!IsTesting())
     {
      CommentScreen();
      HistoryResults();
     }
//---------------------------------------------------------------------
//Close orders
   if((CloseOrdersOnTime==true)&&(TimeHour(TimeCurrent())>=TimeCloseOrders))
     {
      if(BuyOrders>0)
         CloseOrders(OP_BUY);
      if(SellOrders>0)
         CloseOrders(OP_SELL);
     }
//---
   if(CloseInSignal==true)
     {
      if((BuyOrders>0)&&(CloseBuy==true))
         CloseOrders(OP_BUY);
      if((SellOrders>0)&&(CloseSell==true))
         CloseOrders(OP_SELL);
     }
//---------------------------------------------------------------------
//Call modify orders functions
   if(SumOrders>0)
     {
      if((UseTrailingStop==true)||(UseBreakEven==true))
         ModifyOrders();
     }
//---------------------------------------------------------------------
//Open orders
   if((AcceptedSpread==true)&&((SumOrders<MaxOrders)||(MaxOrders==0)))
     {
      //---Open without floating
      if(UseFloatingPoint==false)
        {
         //---Open buy
         if((OpenBuy==true)&&(BuyOrders==0))
           {
            OpenOrders(OP_BUY);
            return;
           }
         //---Open sell
         if((OpenSell==true)&&(SellOrders==0))
           {
            OpenOrders(OP_SELL);
            return;
           }
        }
      //---Open with floating
      if(UseFloatingPoint==true)
        {
         //---Set starting floating switches
         if((OpenBuy==true)&&(BuyOrders==0))
            StartFloatingBuy=true;
         if((OpenSell==true)&&(SellOrders==0))
            StartFloatingSell=true;
         //---Start for buy
         if(StartFloatingBuy==true)
           {
            if(GetAskPrice==0)
               GetAskPrice=NormalizeDouble(Ask+PipsFloatingPoint*DigitPoints,Digits);
            if((GetAskPrice!=0)&&(GetAskPrice>NormalizeDouble(Ask+PipsFloatingPoint*DigitPoints,Digits)))
               GetAskPrice=NormalizeDouble(Ask+PipsFloatingPoint*DigitPoints,Digits);
            if((NormalizeDouble(Ask,Digits)>=GetAskPrice)&&(GetAskPrice!=0))
              {
               GetAskPrice=0;
               StartFloatingBuy=false;
               OpenOrders(OP_BUY);
               return;
              }
           }
         //---Start for sell
         if(StartFloatingSell==true)
           {
            if(GetBidPrice==0)
               GetBidPrice=NormalizeDouble(Bid-PipsFloatingPoint*DigitPoints,Digits);
            if((GetBidPrice!=0)&&(GetBidPrice<NormalizeDouble(Bid-PipsFloatingPoint*DigitPoints,Digits)))
               GetBidPrice=NormalizeDouble(Bid-PipsFloatingPoint*DigitPoints,Digits);
            if((NormalizeDouble(Bid,Digits)<=GetBidPrice)&&(GetBidPrice!=0))
              {
               GetBidPrice=0;
               StartFloatingSell=false;
               OpenOrders(OP_SELL);
               return;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Print if there are signals but blocked trade from spread filter
   if((AcceptedSpread==false)&&((SumOrders<MaxOrders)||(MaxOrders==0)))
     {
      if((OpenBuy==true)&&(BuyOrders==0))
         Print("There are BUY signal for "+Symbol()+" but spread is too high ("+DoubleToStr(Spread,2)+")!!!");
      if((OpenSell==true)&&(SellOrders==0))
         Print("There are SELL signal for "+Symbol()+" but spread is too high ("+DoubleToStr(Spread,2)+")!!!");
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Open orders
//====================================================================================================================================================//
void OpenOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   int OpenOrderTicket=0;
   bool WasOrderModified;
   double OpenPrice=0;
   color OpenColor=clrNONE;
   string TypeOfOrderStr;
   double OrdrLotSize=CalcLots();
   double CheckMargin=0;
   double TP=0;
   double SL=0;
//---------------------------------------------------------------------
//Calculate take profit and stop loss
   double OrderTP=NormalizeDouble(NewTakeProfit*DigitPoints,Digits);
   double OrderSL=NormalizeDouble(NewStopLoss*DigitPoints,Digits);
   double TrailingSL=NormalizeDouble(TrailingStop*DigitPoints,Digits);
//---------------------------------------------------------------------
//Recovery lot
   if(UseRecoveryLot==true)
     {
      HistoryResults();
      if(ResultsOrder==-1)
         OrdrLotSize=LastLotSize*MultiplierLot;
     }
//---------------------------------------------------------------------
//Calculate free margin base lot from open orders
   if(OrdrLotSize!=0)
      CheckMargin=AccountFreeMarginCheck(SymbolTrade,TypeOfOrder,OrdrLotSize);
   if(CheckMargin<=0)
     {
      Print("<NOTICE...[ "+ExpertName+": Free margin is low ("+DoubleToStr(CheckMargin,2)+") ]...NOTICE>");
      Comment("\n\nFree margin is low ("+DoubleToStr(CheckMargin,2)+")");
      return;
     }
//---------------------------------------------------------------------
   CountTimes=0;
//---------------------------------------------------------------------
   while(true)
     {
      CountTimes++;
      //---------------------------------------------------------------------
      //Buy stop loss and take profit in price
      if(TypeOfOrder==OP_BUY)
        {
         TP=0;
         SL=0;
         OpenColor=clrBlue;
         TypeOfOrderStr="Buy";
         OpenPrice=NormalizeDouble(Ask,Digits);
         if((NewTakeProfit>0)&&(UseTakeProfit==true))
            TP=NormalizeDouble(Ask+OrderTP,Digits);
         if((NewStopLoss>0)&&(UseStopLoss==true))
            SL=NormalizeDouble(Bid-OrderSL,Digits);
         if((TrailingStop>0)&&(UseStopLoss==false)&&(UseTrailingStop==true)&&(SL==0))
            SL=NormalizeDouble(Bid-TrailingSL,Digits);
        }
      //---------------------------------------------------------------------
      //Sell stop loss and take profit in price
      if(TypeOfOrder==OP_SELL)
        {
         TP=0;
         SL=0;
         OpenColor=clrRed;
         TypeOfOrderStr="Sell";
         OpenPrice=NormalizeDouble(Bid,Digits);
         if((NewTakeProfit>0)&&(UseTakeProfit==true))
            TP=NormalizeDouble(Bid-OrderTP,Digits);
         if((NewStopLoss>0)&&(UseStopLoss==true))
            SL=NormalizeDouble(Ask+OrderSL,Digits);
         if((TrailingStop>0)&&(UseStopLoss==false)&&(UseTrailingStop==true)&&(SL==0))
            SL=NormalizeDouble(Ask+TrailingSL,Digits);
        }
      //---------------------------------------------------------------------
      //NDD broker, no sl no tp
      if(RunNDDbroker==true)
        {
         TP=0;
         SL=0;
        }
      //---------------------------------------------------------------------
      //Send orders
      OpenOrderTicket=OrderSend(SymbolTrade,TypeOfOrder,OrdrLotSize,OpenPrice,Slippage,SL,TP,CommentsOrders,OrdersID,0,OpenColor);
      //---
      if(OpenOrderTicket>0)
        {
         if(SoundAlert==true)
            PlaySound(SoundAtOpen);
         if(PrintOperations==true)
            Print(ExpertName+" M"+DoubleToStr(Period(),0)+" Open: "+TypeOfOrderStr+", Ticket: "+DoubleToStr(OpenOrderTicket,0));
         break;
        }
      else
        {
         if(PrintOperations==true)
            Print(ExpertName+": receives new data and try again open "+TypeOfOrderStr+" order");
         Sleep(100);
         RefreshRates();
        }
      //---
      if(CountTimes>=3)
         break;
      //---
     }//End while(true)
//---------------------------------------------------------------------
//NDD send stop loss and take profit
   if((RunNDDbroker==true)&&(OpenOrderTicket>0)&&((UseTakeProfit==true)||(UseStopLoss==true)||(UseTrailingStop==true)))
     {
      if(OrderSelect(OpenOrderTicket,SELECT_BY_TICKET))
        {
         //---------------------------------------------------------------------
         //Modify stop loss and take profit buy order
         if((OrderType()==OP_BUY)&&(OrderStopLoss()==0)&&(OrderTakeProfit()==0))
           {
            //---------------------------------------------------------------------
            CountTimes=0;
            //---------------------------------------------------------------------
            while(true)
              {
               CountTimes++;
               TP=0;
               SL=0;
               //---
               if((NewTakeProfit>0)&&(UseTakeProfit==true))
                  TP=NormalizeDouble(Ask+OrderTP,Digits);
               if((NewStopLoss>0)&&(UseStopLoss==true))
                  SL=NormalizeDouble(Bid-OrderSL,Digits);
               if((TrailingStop>0)&&(UseStopLoss==false)&&(UseTrailingStop==true))
                  SL=NormalizeDouble(Bid-TrailingStop,Digits);
               //---
               if((TP==0)&&(SL==0))
                  break;
               //---
               WasOrderModified=OrderModify(OrderTicket(),NormalizeDouble(OrderOpenPrice(),Digits),SL,TP,0,clrBlue);
               //---Errors
               if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                  break;
               //---
               if(WasOrderModified>0)
                 {
                  if(SoundAlert==true)
                     PlaySound(SoundAtModify);
                  if(PrintOperations==true)
                     Print(ExpertName+": modify buy by NDDmode, ticket: "+DoubleToStr(OrderTicket(),0));
                  break;
                 }
               else
                 {
                  if(PrintOperations==true)
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again modify order: "+DoubleToStr(OrderTicket(),0));
                  RefreshRates();
                 }
               //---
               if(CountTimes>=3)
                  break;
               //---
              }//End while(true)
           }//End if((OrderType()
         //---------------------------------------------------------------------
         //Modify stop loss and take profit sell order
         if((OrderType()==OP_SELL)&&(OrderStopLoss()==0)&&(OrderTakeProfit()==0))
           {
            //---------------------------------------------------------------------
            CountTimes=0;
            //---------------------------------------------------------------------
            while(true)
              {
               CountTimes++;
               TP=0;
               SL=0;
               //---
               if((NewTakeProfit>0)&&(UseTakeProfit==true))
                  TP=NormalizeDouble(Bid-OrderTP,Digits);
               if((NewStopLoss>0)&&(UseStopLoss==true))
                  SL=NormalizeDouble(Ask+OrderSL,Digits);
               if((TrailingStop>0)&&(UseStopLoss==false)&&(UseTrailingStop==true))
                  SL=NormalizeDouble(Ask+TrailingStop,Digits);
               //---
               if((TP==0)&&(SL==0))
                  break;
               //---
               WasOrderModified=OrderModify(OrderTicket(),NormalizeDouble(OrderOpenPrice(),Digits),SL,TP,0,clrRed);
               //---Errors
               if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                  break;
               //---
               if(WasOrderModified>0)
                 {
                  if(SoundAlert==true)
                     PlaySound(SoundAtModify);
                  if(PrintOperations==true)
                     Print(ExpertName+": modify sell by NDDmode, ticket: "+DoubleToStr(OrderTicket(),0));
                  break;
                 }
               else
                 {
                  if(PrintOperations==true)
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again modify order: "+DoubleToStr(OrderTicket(),0));
                  RefreshRates();
                 }
               //---
               if(CountTimes>=3)
                  break;
               //---
              }//End while(true)
           }//End if((OrderType()
         //---------------------------------------------------------------------
        }//End OrderSelect(...
      //---------------------------------------------------------------------
     }//End if(RunNDDbroker==true)
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Modify orders
//====================================================================================================================================================//
void ModifyOrders()
  {
//---------------------------------------------------------------------
   double PriceComad=0;
   double LocalStopLoss=0;
   bool WasOrderModified;
   string CommentModify;
//---------------------------------------------------------------------
//Select order
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if((OrderSymbol()==SymbolTrade)&&(OrderMagicNumber()==OrdersID))
           {
            //---------------------------------------------------------------------
            //Modify buy
            if(OrderType()==OP_BUY)
              {
               LocalStopLoss=0.0;
               WasOrderModified=false;
               CountTimes=0;
               //---------------------------------------------------------------------
               while(true)
                 {
                  CountTimes++;
                  //---------------------------------------------------------------------
                  //Break even
                  if((LocalStopLoss==0)&&(BreakEven>0)&&(UseBreakEven==true)&&(Bid-OrderOpenPrice()>=(BreakEven+BreakEvenAfter)*DigitPoints)&&(NormalizeDouble(OrderOpenPrice()+BreakEven*DigitPoints,Digits)<=Bid-(StopLevel*DigitPoints)))//&&(OrderStopLoss()<OrderOpenPrice()))
                    {
                     PriceComad=NormalizeDouble(OrderOpenPrice()+BreakEven*DigitPoints,Digits);
                     LocalStopLoss=BreakEven;
                     CommentModify="break even";
                    }
                  //---------------------------------------------------------------------
                  //Trailing stop
                  if((LocalStopLoss==0)&&(TrailingStop>0)&&(UseTrailingStop==true)&&((NormalizeDouble(Bid-((TrailingStop+TrailingStep)*DigitPoints),Digits)>OrderStopLoss())))
                    {
                     PriceComad=NormalizeDouble(Bid-TrailingStop*DigitPoints,Digits);
                     LocalStopLoss=TrailingStop;
                     CommentModify="trailing stop";
                    }
                  //---------------------------------------------------------------------
                  //Modify
                  if((LocalStopLoss>0)&&(PriceComad!=NormalizeDouble(OrderStopLoss(),Digits)))
                     WasOrderModified=OrderModify(OrderTicket(),0,PriceComad,NormalizeDouble(OrderTakeProfit(),Digits),0,clrBlue);
                  else
                     break;
                  //---Errors
                  if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                     break;
                  //---
                  if(WasOrderModified>0)
                    {
                     if(SoundAlert==true)
                        PlaySound(SoundAtModify);
                     if(PrintOperations==true)
                        Print(ExpertName+": modify buy by "+CommentModify+", ticket: "+DoubleToStr(OrderTicket(),0));
                     break;
                    }
                  else
                    {
                     if(PrintOperations==true)
                        Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again modify order: "+DoubleToStr(OrderTicket(),0));
                     RefreshRates();
                    }
                  //---
                  if(CountTimes>=3)
                     break;
                  //---
                 }//End while(true)
              }//End if(OrderType()
            //---------------------------------------------------------------------
            //Modify sell
            if(OrderType()==OP_SELL)
              {
               WasOrderModified=false;
               LocalStopLoss=0.0;
               CountTimes=0;
               while(true)
                 {
                  CountTimes++;
                  //---------------------------------------------------------------------
                  //Break even
                  if((LocalStopLoss==0)&&(BreakEven>0)&&(UseBreakEven==true)&&(OrderOpenPrice()-Ask>=(BreakEven+BreakEvenAfter)*DigitPoints)&&(NormalizeDouble(OrderOpenPrice()-BreakEven*DigitPoints,Digits)>=Ask+(StopLevel*DigitPoints)))//&&(OrderStopLoss()>OrderOpenPrice()))
                    {
                     PriceComad=NormalizeDouble(OrderOpenPrice()-BreakEven*DigitPoints,Digits);
                     LocalStopLoss=BreakEven;
                     CommentModify="break even";
                    }
                  //---------------------------------------------------------------------
                  //Trailing stop
                  if((LocalStopLoss==0)&&(TrailingStop>0)&&(UseTrailingStop==true)&&((NormalizeDouble(Ask+((TrailingStop+TrailingStep)*DigitPoints),Digits)<OrderStopLoss())))
                    {
                     PriceComad=NormalizeDouble(Ask+TrailingStop*DigitPoints,Digits);
                     LocalStopLoss=TrailingStop;
                     CommentModify="trailing stop";
                    }
                  //---------------------------------------------------------------------
                  //Modify
                  if((LocalStopLoss>0)&&(PriceComad!=NormalizeDouble(OrderStopLoss(),Digits)))
                     WasOrderModified=OrderModify(OrderTicket(),0,PriceComad,NormalizeDouble(OrderTakeProfit(),Digits),0,clrRed);
                  else
                     break;
                  //---Errors
                  if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                     break;
                  //---
                  if(WasOrderModified>0)
                    {
                     if(SoundAlert==true)
                        PlaySound(SoundAtModify);
                     if(PrintOperations==true)
                        Print(ExpertName+": modify sell by "+CommentModify+", ticket: "+DoubleToStr(OrderTicket(),0));
                     break;
                    }
                  else
                    {
                     if(PrintOperations==true)
                        Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again modify order: "+DoubleToStr(OrderTicket(),0));
                     RefreshRates();
                    }
                  //---
                  if(CountTimes>=3)
                     break;
                  //---
                 }//End while(true)
              }//End if(OrderType()
            //---------------------------------------------------------------------
           }//End if((OrderSymbol()...
        }//End OrderSelect(...
     }//End for(...
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Close positions
//====================================================================================================================================================//
void CloseOrders(int OrdrType)
  {
//---------------------------------------------------------------------
   bool WasOrderClosed;
//---------------------------------------------------------------------
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderMagicNumber()==OrdersID)&&(OrderSymbol()==SymbolTrade))
           {
            //---------------------------------------------------------------------
            //Close buy
            if((OrderType()==OP_BUY)&&(OrdrType==OP_BUY))
              {
               CountTimes=0;
               WasOrderClosed=false;
               //---close order
               while(true)
                 {
                  WasOrderClosed=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),Slippage,clrMediumAquamarine);
                  CountTimes++;
                  //---
                  if(WasOrderClosed>0)
                     break;
                  //---Errors
                  if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                     break;
                  //---try 3 times to close
                  if(CountTimes>=3)
                    {
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": Could not close, ticket: "+DoubleToStr(OrderTicket(),0));
                     break;
                    }
                  else
                    {
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again close order - "+DoubleToStr(OrderTicket(),0));
                     RefreshRates();
                    }
                 }//End while(...
              }//End if(OrderType()==OP_BUY)
            //---------------------------------------------------------------------
            //Close sell
            if((OrderType()==OP_SELL)&&(OrdrType==OP_SELL))
              {
               CountTimes=0;
               WasOrderClosed=false;
               //---close order
               while(true)
                 {
                  WasOrderClosed=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),Slippage,clrDarkSalmon);
                  CountTimes++;
                  //---
                  if(WasOrderClosed>0)
                     break;
                  //---Errors
                  if((GetLastError()==1)||(GetLastError()==132)||(GetLastError()==133)||(GetLastError()==137)||(GetLastError()==4108)||(GetLastError()==4109))
                     break;
                  //---try 3 times to close
                  if(CountTimes>=3)
                    {
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": Could not close, ticket: "+DoubleToStr(OrderTicket(),0));
                     break;
                    }
                  else
                    {
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertName+": receives new data and try again close order - "+DoubleToStr(OrderTicket(),0));
                     RefreshRates();
                    }
                 }//End while(...
              }//End if(OrderType()==OP_SELL)
            //---------------------------------------------------------------------
           }//End if((OrderSymbol()...
        }//End OrderSelect(...
     }//End for(...
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Check orders
//====================================================================================================================================================//
void CountOrders()
  {
//---------------------------------------------------------------------
//Reset value
   SumOrders=0;
   BuyOrders=0;
   SellOrders=0;
   ProfitBuyOrders=0;
   ProfitSellOrders=0;
   SumFloating=0;
//---------------------------------------------------------------------
//Start count
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderMagicNumber()==OrdersID)&&(OrderSymbol()==SymbolTrade))
           {
            //---Calculate buy
            if(OrderType()==OP_BUY)
              {
               ProfitBuyOrders+=OrderProfit()+OrderCommission()+OrderSwap();
               BuyOrders++;
              }
            //---Calculate sell
            if(OrderType()==OP_SELL)
              {
               ProfitSellOrders+=OrderProfit()+OrderCommission()+OrderSwap();
               SellOrders++;
              }
            //---Calculate sum orders
            SumOrders++;
            SumFloating+=OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//History results
//====================================================================================================================================================//
void HistoryResults()
  {
//---------------------------------------------------------------------
   TotalHistoryOrders=0;
   TotalHistoryProfitLoss=0;
   HistoryPipsBuy=0;
   HistoryPipsSell=0;
   ResultsOrder=0;
   LastLotSize=0;
   TimeLastBuy=0;
   TimeLastSell=0;
   HistoryOrdersBuy=0;
   HistoryOrdersSell=0;
//---------------------------------------------------------------------
   for(i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if((OrderMagicNumber()==OrdersID)&&(OrderSymbol()==SymbolTrade))
           {
            //---Check last order
            if(OrderProfit()+OrderCommission()+OrderSwap()<0)
               ResultsOrder=-1;
            if(OrderProfit()+OrderCommission()+OrderSwap()>0)
               ResultsOrder=1;
            LastLotSize=OrderLots();
            //---Results of total orders
            TotalHistoryOrders++;
            TotalHistoryProfitLoss+=OrderProfit()+OrderCommission()+OrderSwap();
            //---Results of buy
            if(OrderType()==OP_BUY)
              {
               HistoryOrdersBuy++;
               TimeLastBuy=OrderOpenTime();
               HistoryPipsBuy+=(OrderClosePrice()-OrderOpenPrice())/(MarketInfo(OrderSymbol(),MODE_POINT)*MultiplierPoint);
              }
            //---Results of sell
            if(OrderType()==OP_SELL)
              {
               HistoryOrdersSell++;
               TimeLastSell=OrderOpenTime();
               HistoryPipsSell+=(OrderOpenPrice()-OrderClosePrice())/(MarketInfo(OrderSymbol(),MODE_POINT)*MultiplierPoint);
              }
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Lot size
//====================================================================================================================================================//
double CalcLots()
  {
//---------------------------------------------------------------------
   double LotSize=0;
//---------------------------------------------------------------------
   if(IsConnected())
     {
      if(AutoLotSize==true)
         LotSize=MathMin(MathMax((MathRound((AccountFreeMargin()*RiskFactor/100000)/MarketInfo(SymbolTrade,MODE_LOTSTEP))*MarketInfo(SymbolTrade,MODE_LOTSTEP)),MarketInfo(SymbolTrade,MODE_MINLOT)),MarketInfo(SymbolTrade,MODE_MAXLOT));
      if(AutoLotSize==false)
         LotSize=MathMin(MathMax((MathRound(ManualLotSize/MarketInfo(SymbolTrade,MODE_LOTSTEP))*MarketInfo(SymbolTrade,MODE_LOTSTEP)),MarketInfo(SymbolTrade,MODE_MINLOT)),MarketInfo(SymbolTrade,MODE_MAXLOT));
     }
   else
     {
      LotSize=ManualLotSize;
     }
//---------------------------------------------------------------------
   return(LotSize);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Comment's background
//====================================================================================================================================================//
void ChartBackground(string StringName, color ImageColor, int Xposition, int Yposition, int Xsize, int Ysize)
  {
//---------------------------------------------------------------------
   if(ObjectFind(0,StringName)==-1)
     {
      ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
      ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
      ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
      ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
      ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,ImageColor);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,clrBlack);
      ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Comment in chart
//====================================================================================================================================================//
void CommentScreen()
  {
//---------------------------------------------------------------------
   string MMstring="";
   string StringSpread="";
//---------------------------------------------------------------------
//String money management
   if(AutoLotSize==true)
      MMstring="Auto";
   if(AutoLotSize==false)
      MMstring="Manual";
//---------------------------------------------------------------------
//String spread
   if(MaxSpread==0)
      StringSpread="EA NOT CHECK SPREAD,  Expert running";
   if((Spread<=MaxSpread)&&(MaxSpread>0))
      StringSpread="Acceptable Spread ,  Expert is running";
   if((Spread>MaxSpread)&&(MaxSpread>0))
      StringSpread="Unacceptable Spread. EA stop running";
//---------------------------------------------------------------------
//Comment in chart
   Comment("=============================="+"\n"+
           "GMT Time: "+TimeToStr(TimeGMT(),TIME_MINUTES)+" || Server Time: "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"   ("+IntegerToString(PresetsParameters)+")"+"\n"+
           "=============================="+"\n"+
           StringSpread+"\n"+
           "Max Spread: "+DoubleToStr(MaxSpread,2)+" || Current Spread: "+DoubleToStr(Spread,2)+"\n"+
           "=============================="+"\n"+
           "Money Management: "+MMstring+" || Lot: "+DoubleToStr(CalcLots(),2)+"\n"+
           "=============================="+"\n"+
           "Buy Orders: "+DoubleToStr(BuyOrders,0)+" || Buy Floating: "+DoubleToStr(ProfitBuyOrders,2)+"\n"+
           "Sell Orders: "+DoubleToStr(SellOrders,0)+" || Sell Floating: "+DoubleToStr(ProfitSellOrders,2)+"\n"+
           "=============================="+"\n"+
           "         H I S T O R Y    R E S U L T S"+"\n"+
           "Orders: "+DoubleToStr(TotalHistoryOrders,0)+" || Pips: "+DoubleToStr(HistoryPipsBuy+HistoryPipsSell,2)+" || PnL: "+DoubleToStr(TotalHistoryProfitLoss,2)+"\n"+
           "==============================");
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Orders signals
//====================================================================================================================================================//
void GetSignals()
  {
//---------------------------------------------------------------------
//Set value
   double AveragePrice=0;
   bool CheckBarsBuy=true;
   bool CheckBarsSell=true;
   bool CheckPricesBuy=true;
   bool CheckPricesSell=true;
   int Counter=1;
//---------------------------------------------------------------------
//Set counter
   if(Period()==PERIOD_M1)
      Counter=1440;
   if(Period()==PERIOD_M5)
      Counter=288;
   if(Period()==PERIOD_M15)
      Counter=96;
   if(Period()==PERIOD_M30)
      Counter=48;
   if(Period()==PERIOD_H1)
      Counter=24;
   if(Period()==PERIOD_H4)
      Counter=6;
   if(Period()==PERIOD_D1)
      Counter=1;
//---------------------------------------------------------------------
//Set high and low levels
   if(iTime(NULL,TimeFrame,0)!=LastTime)
     {
      if(TimeHour(iTime(NULL,TimeFrame,0))==TimeCheckLevels)
        {
         //---Get levels
         for(i=0; i<Counter; i++)
           {
            AveragePrice+=iClose(Symbol(),TimeFrame,i);
            if(TimeHour(iTime(NULL,TimeFrame,i))==TimeSetLevels)
              {
               HighPrice=iHigh(Symbol(),TimeFrame,i);
               LowPrice=iLow(Symbol(),TimeFrame,i);
               break;
              }
           }
         //---
         AveragePrice/=i+1;
         //---Check all bars
         if(CheckAllBars==true)
           {
            for(i=0; i<Counter; i++)
              {
               if(iClose(Symbol(),TimeFrame,i)>HighPrice)
                  CheckBarsBuy=false;
               if(iClose(Symbol(),TimeFrame,i)<LowPrice)
                  CheckBarsSell=false;
               if(TimeHour(iTime(NULL,TimeFrame,i))==TimeSetLevels)
                  break;
              }
           }
         //---Recheck prices
         if(ReCheckPrices==true)
           {
            for(i=0; i<Counter; i++)
              {
               if(TimeHour(iTime(NULL,TimeFrame,i))==TimeRecheckPrices)
                 {
                  if((AveragePrice>iClose(Symbol(),TimeFrame,i))&&(iClose(Symbol(),TimeFrame,i)<iClose(Symbol(),TimeFrame,1)))
                     CheckPricesBuy=false;
                  if((AveragePrice<iClose(Symbol(),TimeFrame,i))&&(iClose(Symbol(),TimeFrame,i)>iClose(Symbol(),TimeFrame,1)))
                     CheckPricesSell=false;
                  break;
                 }
              }
           }
         //---------------------------------------------------------------------
         //Signals open orders
         switch(TypeOfSignals)
           {
            case 0:
               if((iClose(Symbol(),TimeFrame,1)<LowPrice-MinDistanceOfLevel*DigitPoints)&&(iClose(Symbol(),TimeFrame,1)>LowPrice-MaxDistanceOfLevel*DigitPoints)&&(CheckBarsBuy==true)&&(CheckPricesBuy==true))
                  OpenBuy=true;
               if((iClose(Symbol(),TimeFrame,1)>HighPrice+MinDistanceOfLevel*DigitPoints)&&(iClose(Symbol(),TimeFrame,1)<HighPrice+MaxDistanceOfLevel*DigitPoints)&&(CheckBarsSell==true)&&(CheckPricesSell==true))
                  OpenSell=true;
               break;
            case 1:
               if((iClose(Symbol(),TimeFrame,1)>HighPrice+MinDistanceOfLevel*DigitPoints)&&(iClose(Symbol(),TimeFrame,1)<HighPrice+MaxDistanceOfLevel*DigitPoints)&&(CheckBarsSell==true)&&(CheckPricesSell==true))
                  OpenBuy=true;
               if((iClose(Symbol(),TimeFrame,1)<LowPrice-MinDistanceOfLevel*DigitPoints)&&(iClose(Symbol(),TimeFrame,1)>LowPrice-MaxDistanceOfLevel*DigitPoints)&&(CheckBarsBuy==true)&&(CheckPricesBuy==true))
                  OpenSell=true;
               break;
           }
        }
      //---------------------------------------------------------------------
      //Signals close orders
      if(CloseInSignal==true)
        {
         switch(TypeOfSignals)
           {
            case 0:
               if(iClose(Symbol(),TimeFrame,1)>LowPrice+MinDistanceOfLevel*DigitPoints)
                  CloseBuy=true;
               if(iClose(Symbol(),TimeFrame,1)<HighPrice-MinDistanceOfLevel*DigitPoints)
                  CloseSell=true;
               break;
            case 1:
               if(iClose(Symbol(),TimeFrame,1)<HighPrice-MinDistanceOfLevel*DigitPoints)
                  CloseBuy=true;
               if(iClose(Symbol(),TimeFrame,1)>LowPrice+MinDistanceOfLevel*DigitPoints)
                  CloseSell=true;
               break;
           }
        }
      //---------------------------------------------------------------------
      LastTime=iTime(NULL,TimeFrame,0);
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//End code
//====================================================================================================================================================//
