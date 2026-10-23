//====================================================================================================================================================//
#property copyright   "Copyright 2018-2020, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "2.3"
#property description "This Expert Advisor is a hedge and scalp system."
#property description "\nRun well in any pair with tight spread and low commission."
#property description "Choice a broker with fast execution and zero stop level."
//#property icon        "\\Images\\SailSystem_Logo.ico";
#property strict
//====================================================================================================================================================//
enum Sprd {Use_Average, Use_Current};
enum Actn {Increase_Levels, Close_Orders};
enum Exist {Kepp_All_Orders, Delete_Pending, Close_Market, DeletePending_And_CloseMarket};
//====================================================================================================================================================//
extern string OrdersSetting      = "||======== Orders Setting ========||";
extern bool   UseVirtualLevels   = true;
extern bool   ShowVirtualLevels  = true;
extern double OrdersStopLoss     = 5;
extern bool   PutTakeProfit      = false;
extern double OrdersTakeProfit   = 50.0;
extern int    DelayModifyOrders  = 4;
extern double StepModifyOrders   = 1.0;
extern double PipsReplaceOrders  = 0.0;
extern double SafeMultiplier     = 10.0;
extern bool   UsePendingOrders   = false;
extern double DistancePending    = 1.0;
extern string TimeFilterSets     = "||======== Times Setting ========||";
extern bool   UseTimeFilter      = false;
extern string TimeStartTrade     = "00:00:00";
extern string TimeStopTrade      = "00:00:00";
extern Exist  ManageExistOrders  = DeletePending_And_CloseMarket;
extern string LotSetting         = "||======== Lot Setting ========||";
extern bool   AutoLotSize        = false;
extern double RiskFactor         = 10;
extern double ManualLotSize      = 0.01;
extern string EASetting          = "||======== EA Setting ========||";
extern double AcceptStopLevel    = 2.0;
extern int    Slippage           = 1;
extern string OrdersIDInfo       = "0 = Generate ID per Symbol";
extern int    OrdersID           = 0;
extern string SpreadSetting      = "||======== Spread Setting ========||";
extern string MaxSpreadInfo      = "0 = Not check spread";
extern double MaxSpread          = 1.0;
extern Sprd   TypeOfSpreadUse    = Use_Average;
extern Actn   HighSpreadAction   = Increase_Levels;
extern double MultiplierIncrease = 2.0;
extern string CommisionsSet      = "||======== Commissions Setting ========||";
extern double CommissionInPip    = 0.0;
extern double CommissionInCur    = 0.0;
extern bool   GetCommissionAuto  = true;
extern string InformationSets    = "||======== Information Setting ========||";
extern bool   CountAvgSpread     = false;
extern bool   CountAvgExecution  = false;
extern int    TimesForAverage    = 30;
extern string DeleteObjectsSets  = "||======== Objects Setting ========||";
extern bool   DeleteObjects      = false;
extern int    DeleteMinutes      = 30;
extern string ExpertCommentsSet  = "||======== Comments Setting ========||";
extern string ExpertComments     = "SailSystemEA";
extern bool   BacktesttingInfo   = true;
//====================================================================================================================================================//
string SymbolUse;
string SymbolExtension="";
string SymbolTrade;
string BackgroundName;
string ShowInfoCommission;
string NameOfBuyStopLossLine;
string NameOfBuyTakeProfitLine;
string NameOfSellStopLossLine;
string NameOfSellTakeProfitLine;
string PREFIX="#";
long ChartColor;
int TotalOrders;
int CntBuyLimit;
int CntSellLimit;
int CntBuy;
int CntSell;
int TryTimes;
int TotalTrades;
int MultiplierPoint;
int TimeActionModify;
int MagicNumber;
int CountTickSpreadPair=0;
int CountTimesModify=0;
int CountTickSpread=0;
int TimesModify=0;
int i;
int Count;
int TicksGet=0;
int CountTickModifyBuy=0;
int CountTickModifySell=0;
int WinTrades;
int LossTrades;
int SendMessages=0;
int CountHistory;
double ArraySpreadPair[100];
double HistoryPips=0;
double AvgSpread;
double AvgExecution;
double TotalProfitLoss;
double SpreadPips;
double DigitsPoints;
double LotSize;
double StopLevel;
double CheckMargin1;
double CheckMargin2;
double SumMargin;
double StepModify;
double ModeTickValue;
double BrokerCommission;
double SpreadLimit;
double RealCommission;
double GetCommissionPair=0;
double PipsLevelLoss;
double PipsLevelProfit;
double PipsStepModify;
double AvrgPipsProfit=0;
double AvrgPipsLoss=0;
double AvrgDuration=0;
double LastBid=0;
double LastAsk=0;
double VirtualStopLossBuy=0;
double VirtualStopLossSell=0;
double VirtualTakeProfitBuy=0;
double VirtualTakeProfitSell=0;
double CurrentDistanceBuy;
double CurrentDistanceSell;
datetime ArrayExecution[100];
datetime OperationDelay=0;
datetime LastOperationDelay=0;
datetime TimeToSend=0;
datetime TimeDeleteObjects=0;
bool StopTrade=false;
bool SpreadOK;
bool CallMain=false;
bool ChangeAsk=false;
bool ChangeBid=false;
bool TestingMode=false;
bool NotHaveOpenOrders=true;
bool TimeToTrade;
//---------------------------------------------------------------------
int MagicSet=777333777;
//====================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//Set timer
   EventSetMillisecondTimer(10);
//---------------------------------------------------------------------
//Reset value
   CountTimesModify=0;
   CountTickSpreadPair=0;
   CountHistory=0;
//------------------------------------------------------
//Background
   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   BackgroundName="Background-"+WindowExpertName();
//---
   if(ObjectFind(BackgroundName)==-1)
      ChartBackground(BackgroundName,(color)ChartColor,0,15,182,206);
//---------------------------------------------------------------------
//Names lines on screen
   NameOfBuyStopLossLine=PREFIX+" Buy Stop Loss Level";
   NameOfBuyTakeProfitLine=PREFIX+" Buy Take Profit Level";
   NameOfSellStopLossLine=PREFIX+" Sell Stop Loss Level";
   NameOfSellTakeProfitLine=PREFIX+" Sell Take Profit Level";
//---------------------------------------------------------------------
//Symbol suffix and info
   SymbolUse=Symbol();
   ArrayInitialize(ArraySpreadPair,0);
   ArrayInitialize(ArrayExecution,0);
   if(StringLen(SymbolUse)>6)
      SymbolExtension=StringSubstr(SymbolUse,6,0);
//---------------------------------------------------------------------
//Confirm points
   MultiplierPoint=1;
   if(MarketInfo("EURUSD"+SymbolExtension,MODE_DIGITS)==5)
      MultiplierPoint=10;
   if((MarketInfo(SymbolUse,MODE_BID)>999.999) && (MarketInfo("EURUSD"+SymbolExtension,MODE_DIGITS)==5) && (MarketInfo(SymbolUse,MODE_DIGITS)==3))
      MultiplierPoint=100;
   DigitsPoints=Point*MultiplierPoint;
//---------------------------------------------------------------------
//Commissions
   ModeTickValue=MarketInfo(SymbolUse,MODE_TICKVALUE)*MultiplierPoint;
   BrokerCommission=(CommissionInCur/MathMax(1,ModeTickValue))+CommissionInPip;
//---------------------------------------------------------------------
//Set minimum and maximum range
   if(RiskFactor<1)
      RiskFactor=1;
   if(RiskFactor>50)
      RiskFactor=50;
   if(OrdersID<0)
      OrdersID=0;
   if(MaxSpread<0)
      MaxSpread=0;
   if(TimesForAverage>100)
      TimesForAverage=100;
   if(TimesForAverage<1)
      TimesForAverage=1;
//if(StepModifyOrders>OrdersStopLoss) StepModifyOrders=OrdersStopLoss;
//---------------------------------------------------------------------
//Confirm pips for xauusd
   if((MarketInfo(SymbolUse,MODE_BID)>999.999) && (MarketInfo("EURUSD"+SymbolExtension,MODE_DIGITS)==5) && (MarketInfo(SymbolUse,MODE_DIGITS)==3))
      MaxSpread*=10;
//---------------------------------------------------------------------
//Expert ID
   MagicNumber=OrdersID;
//---
   if(OrdersID==0)
     {
      for(int cnt=0; cnt<StringLen(SymbolUse); cnt++)
         MagicNumber+=(StringGetChar(SymbolUse,cnt)*(cnt+1))+MagicSet;
     }
//---------------------------------------------------------------------
//Get stop level
   StopLevel=NormalizeDouble(MathMax(MarketInfo(SymbolUse,MODE_FREEZELEVEL),MarketInfo(SymbolUse,MODE_STOPLEVEL))/MultiplierPoint,2);
   if(AcceptStopLevel<StopLevel)
      StopTrade=true;
//---------------------------------------------------------------------
//Sets use for backtest
   if(!IsVisualMode())
     {
      if((IsTesting()) || (IsOptimization()))
        {
         ShowVirtualLevels=false;
         TypeOfSpreadUse=1;
         DeleteObjects=false;
        }
     }
//---
   if(IsVisualMode())
      DeleteObjects=false;
//---------------------------------------------------------------------
//Call ontick
   if((!IsTesting()) || (!IsVisualMode()))
      OnTick();
//---------------------------------------------------------------------
//Mode
   if((IsTesting()) || (IsVisualMode()))
      TestingMode=true;
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
//Print information in backtesting
   if((IsTesting()) && (BacktesttingInfo==true))
     {
      HistoryResults();
      Print("<===== BACKTEST/HISTORY REPORT =====>");
      Print("Average Duration: "+DoubleToStr(AvrgDuration,2)+" sec || Total Trades: "+DoubleToStr(TotalTrades,0));
      Print("Average Profits: "+DoubleToStr(AvrgPipsProfit,2)+" pips || Win Trades: "+DoubleToStr(WinTrades,0));
      Print("Average Loss: "+DoubleToStr(AvrgPipsLoss,2)+" pips || Loss Trades: "+DoubleToStr(LossTrades,0));
      Print("Send Messages: "+DoubleToStr(SendMessages,0));
      Print("<===== BACKTEST/HISTORY REPORT =====>");
     }
//---------------------------------------------------------------------
//Clear chart
   EventKillTimer();
   ObjectDelete(BackgroundName);
   Comment("");
   if(ObjectFind(NameOfSellStopLossLine)>-1)
      ObjectDelete(NameOfSellStopLossLine);
   if(ObjectFind(NameOfSellTakeProfitLine)>-1)
      ObjectDelete(NameOfSellTakeProfitLine);
   if(ObjectFind(NameOfBuyStopLossLine)>-1)
      ObjectDelete(NameOfBuyStopLossLine);
   if(ObjectFind(NameOfBuyTakeProfitLine)>-1)
      ObjectDelete(NameOfBuyTakeProfitLine);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
//Reset values
   CallMain=true;
//---------------------------------------------------------------------
//Stop level warning
   if(StopTrade==true)
     {
      if(IsTesting())
         Print("Broker Stop Level Is Too High, Expert Not Trade!!!");
      ScreenComment(4);
      Sleep(300000);
      return;
     }
//---------------------------------------------------------------------
//For testing
   if((IsTesting()) || (IsOptimization()) || (IsVisualMode()))
     {
      CallMain=false;
      MainFunction();
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnTimer()
  {
//---------------------------------------------------------------------
//For testing
   if((IsTesting())||(IsOptimization())||(IsVisualMode()))
      return;
//---------------------------------------------------------------------
//Call main function
   if(IsTradeAllowed()==true)
     {
      if(CallMain==true)
         MainFunction();
     }
   else
      ScreenComment(5);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void MainFunction()
  {
//---------------------------------------------------------------------
//Reset value
   ChangeAsk=false;
   ChangeBid=false;
   SpreadOK=true;
//---------------------------------------------------------------------
//Check Different price
   if((NormalizeDouble(Bid,Digits)!=NormalizeDouble(LastBid,Digits)) || (NormalizeDouble(Ask,Digits)!=NormalizeDouble(LastAsk,Digits)) || (IsTesting()))
     {
      //---------------------------------------------------------------------
      //Time filter
      if(UseTimeFilter==true)
        {
         TimeToTrade=false;
         //---
         if((StringToTime(TimeStartTrade)<StringToTime(TimeStopTrade))&&((TimeGMT()>=StringToTime(TimeStartTrade))&&(TimeGMT()<StringToTime(TimeStopTrade))))
            TimeToTrade=true;
         if((StringToTime(TimeStartTrade)>StringToTime(TimeStopTrade))&&((TimeGMT()>=StringToTime(TimeStartTrade))||(TimeGMT()<StringToTime(TimeStopTrade))))
            TimeToTrade=true;
         //---
         if(TimeToTrade==false)
           {
            ScreenComment(6);
           }
        }
      else
         TimeToTrade=true;
      //---------------------------------------------------------------------
      //Check orders
      CountOrders();
      //---------------------------------------------------------------------
      //If change prices
      if(NormalizeDouble(Ask,Digits)!=NormalizeDouble(LastAsk,Digits))
         ChangeAsk=true;
      if(NormalizeDouble(Bid,Digits)!=NormalizeDouble(LastBid,Digits))
         ChangeBid=true;
      //---------------------------------------------------------------------
      //Get last prices
      LastBid=NormalizeDouble(Bid,Digits);
      LastAsk=NormalizeDouble(Ask,Digits);
      //---------------------------------------------------------------------
      //Get spread
      SpreadPips=(Ask-Bid)/DigitsPoints;
      if(CountAvgSpread==true)
         GetAvrgSpread(SpreadPips);
      if(TypeOfSpreadUse==0)
         SpreadLimit=AvgSpread;//Use average
      if(TypeOfSpreadUse==1)
         SpreadLimit=SpreadPips;//Use current
      //---------------------------------------------------------------------
      //Set commission
      if(GetCommissionAuto==false)
         RealCommission=BrokerCommission;
      if((GetCommissionAuto==true) && (CntBuy+CntSell==0) && (NotHaveOpenOrders==true))
        {
         RealCommission=BrokerCommission;
         ShowInfoCommission="Waiting Trades...";
        }
      if((GetCommissionAuto==true) && (CntBuy+CntSell!=0))
        {
         RealCommission=(GetCommissionPair/MathMax(1,ModeTickValue));
         ShowInfoCommission=DoubleToStr(RealCommission,2)+" (pips)";
         NotHaveOpenOrders=false;
        }
      //---------------------------------------------------------------------
      //Spread warning
      if(TimeToTrade==true)
        {
         if((SpreadLimit+RealCommission>MaxSpread) && (MaxSpread>0))
           {
            if(IsTesting())
               Print("Spread Is Too High, Expert Not Trade!!!");
            ScreenComment(2);
            SpreadOK=false;
           }
         else
           {
            ScreenComment(1);
           }
        }
      //---------------------------------------------------------------------
      //Count lot size
      if(AutoLotSize==true)
         LotSize=MathMin(MathMax((MathRound((AccountEquity()*RiskFactor/100000)/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
      if(AutoLotSize==false)
         LotSize=MathMin(MathMax((MathRound(ManualLotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
      //---------------------------------------------------------------------
      //Reset value
      if(CntBuy==0)
        {
         CountTickModifyBuy=0;
         VirtualStopLossBuy=0;
         VirtualTakeProfitBuy=0;
        }
      //---
      if(CntSell==0)
        {
         CountTickModifySell=0;
         VirtualStopLossSell=0;
         VirtualTakeProfitSell=0;
        }
      //---------------------------------------------------------------------
      //Set levels for orders
      PipsLevelLoss=OrdersStopLoss;
      PipsLevelProfit=OrdersTakeProfit;
      PipsStepModify=StepModifyOrders;
      //---------------------------------------------------------------------
      //Confirm pips levels
      if(PipsLevelLoss<StopLevel)
         PipsLevelLoss=StopLevel;
      if(PipsLevelProfit<StopLevel)
         PipsLevelProfit=StopLevel;
      //---------------------------------------------------------------------
      //Delete pending and close market in out of time range
      if((TimeToTrade==false)&&(ManageExistOrders>0))
        {
         //---Close market
         if((ManageExistOrders==2)||(ManageExistOrders==3))
           {
            if(CntBuy>0)
               CloseOrders(OP_BUY);
            if(CntSell>0)
               CloseOrders(OP_SELL);
           }
         //---Delete pending
         if((ManageExistOrders==1)||(ManageExistOrders==3))
           {
            if(CntBuyLimit>0)
               DeleteOrders(OP_BUYLIMIT);
            if(CntSellLimit>0)
               DeleteOrders(OP_SELLLIMIT);
           }
        }
      //---------------------------------------------------------------------
      //Operation on high spread
      if(TotalOrders>0)
        {
         if(SpreadOK==false)
           {
            //---Move levels
            if(HighSpreadAction==0)
              {
               PipsLevelLoss*=MultiplierIncrease;
               PipsLevelProfit*=MultiplierIncrease;
               PipsStepModify*=MultiplierIncrease;
              }
            //---Close and delete orders
            if(HighSpreadAction==1)
              {
               if(CntBuy>0)
                  CloseOrders(OP_BUY);
               if(CntSell>0)
                  CloseOrders(OP_SELL);
               if(CntBuyLimit>0)
                  DeleteOrders(OP_BUYLIMIT);
               if(CntSellLimit>0)
                  DeleteOrders(OP_SELLLIMIT);
               return;
              }
           }
         //---------------------------------------------------------------------
         //Modify orders
         if(CntBuy>0)
            ModifyMarketOrders(OP_BUY);
         if(CntSell>0)
            ModifyMarketOrders(OP_SELL);
         //---------------------------------------------------------------------
         //Get history results
         if(CountHistory<3)
           {
            CountHistory++;
            HistoryResults();
           }
         //---------------------------------------------------------------------
         //Clear chart
         if(DeleteObjects==true)
            ClearChart();
         //---------------------------------------------------------------------
         //Return if are opened buy and sell or there are limitation
         if((CntBuy==1)&&(CntSell==1)&&(((CntBuyLimit==1)&&(CntSellLimit==1))||(UsePendingOrders==false)))
            return;
         if(SpreadOK==false)
            return;
        }
      //---------------------------------------------------------------------
      //Open market orders
      if(((CntBuy==0) || (CntSell==0)) && (CheckMargin()==1)&&(TimeToTrade==true))
        {
         HistoryResults();
         //---
         if(PipsReplaceOrders>0)
           {
            if((((CurrentDistanceBuy>=PipsReplaceOrders) || (CurrentDistanceBuy<=-(PipsReplaceOrders*SafeMultiplier))) && (CntBuy==0)) || (CntBuy+CntSell==0))
               OpenOrders(OP_BUY);
            if((((CurrentDistanceSell>=PipsReplaceOrders) || (CurrentDistanceSell<=-(PipsReplaceOrders*SafeMultiplier))) && (CntSell==0)) || (CntBuy+CntSell==0))
               OpenOrders(OP_SELL);
           }
         //---
         if(PipsReplaceOrders<0)
           {
            if((((CurrentDistanceBuy<=PipsReplaceOrders) || (CurrentDistanceBuy>=-(PipsReplaceOrders*SafeMultiplier))) && (CntBuy==0)) || (CntBuy+CntSell==0))
               OpenOrders(OP_BUY);
            if((((CurrentDistanceSell<=PipsReplaceOrders) || (CurrentDistanceSell>=-(PipsReplaceOrders*SafeMultiplier))) && (CntSell==0)) || (CntBuy+CntSell==0))
               OpenOrders(OP_SELL);
           }
         //---
         if(PipsReplaceOrders==0)
           {
            if(CntBuy==0)
               OpenOrders(OP_BUY);
            if(CntSell==0)
               OpenOrders(OP_SELL);
           }
        }
      //---------------------------------------------------------------------
      //Open pending orders
      if((UsePendingOrders==true) && (CntBuy>0) && (CntSell>0)&&(TimeToTrade==true))
        {
         if(((CntBuyLimit==0) || (CntSellLimit==0)) && (CheckMargin()==1))
           {
            HistoryResults();
            //---
            if(CntBuyLimit==0)
               OpenOrders(OP_BUYLIMIT);
            if(CntSellLimit==0)
               OpenOrders(OP_SELLLIMIT);
           }
        }
      //---
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
int CheckMargin()
  {
//---------------------------------------------------------------------
   CheckMargin1=0;
   CheckMargin2=0;
   SumMargin=0;
//---------------------------------------------------------------------
   CheckMargin1=AccountFreeMargin()-AccountFreeMarginCheck(Symbol(),OP_BUY,LotSize);
   CheckMargin2=AccountFreeMargin()-AccountFreeMarginCheck(Symbol(),OP_SELL,LotSize);
   SumMargin=AccountFreeMargin()-MathMax(CheckMargin1,CheckMargin2);
//---------------------------------------------------------------------
   if(SumMargin<=0.0)
     {
      if(IsTesting())
         Print("Margin Account Is Too Low, Expert Not Trade!!!");
      ScreenComment(3);
      return(0);
     }
//---------------------------------------------------------------------
   return(1);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OpenOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   int TicketBuy=-1;
   int TicketSell=-1;
   int TicketBuyLimit=-1;
   int TicketSellLimit=-1;
   double SL_Buy=0;
   double TP_Buy=0;
   double SL_Sell=0;
   double TP_Sell=0;
   double PriceBuyLimit=0;
   double PriceSellLimit=0;
//---------------------------------------------------------------------
   TryTimes=0;
//---------------------------------------------------------------------
//Open orders
   while(true)
     {
      TryTimes++;
      OperationDelay=0;
      TimeToSend=GetTickCount();
      //---Open Buy
      if(TypeOfOrder==OP_BUY)
        {
         if(UseVirtualLevels==false)
           {
            SL_Buy=NormalizeDouble(Bid-(PipsLevelLoss*DigitsPoints),Digits);
            if(PutTakeProfit==true)
               TP_Buy=NormalizeDouble(Ask+(PipsLevelProfit*DigitsPoints),Digits);
           }
         //---
         TicketBuy=OrderSend(Symbol(),OP_BUY,LotSize,NormalizeDouble(Ask,Digits),Slippage,SL_Buy,TP_Buy,ExpertComments,MagicNumber,0,clrBlue);
         //---
         if(TestingMode==true)
            SendMessages++;
         //---Exit loop
         if(TicketBuy>0)
           {
            OperationDelay=GetTickCount()-TimeToSend;
            if(OperationDelay>0)
              {
               LastOperationDelay=OperationDelay;
               if(TicksGet<30)
                  TicksGet++;
               if(CountAvgExecution==true)
                  CountAvrgExecution(OperationDelay);
              }
            break;
           }
         else
           {
            RefreshRates();
            Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again open buy order");
            if(TryTimes>=3)
               break;
           }
        }
      //---Open BuyLimit
      if(TypeOfOrder==OP_BUYLIMIT)
        {
         PriceBuyLimit=NormalizeDouble(Bid-((PipsLevelLoss+DistancePending)*DigitsPoints),Digits);
         //---
         TicketBuyLimit=OrderSend(Symbol(),OP_BUYLIMIT,LotSize,PriceBuyLimit,Slippage,0,0,ExpertComments,MagicNumber,0,clrBlue);
         //---
         if(TestingMode==true)
            SendMessages++;
         //---Exit loop
         if(TicketBuyLimit>0)
           {
            OperationDelay=GetTickCount()-TimeToSend;
            if(OperationDelay>0)
              {
               LastOperationDelay=OperationDelay;
               if(TicksGet<30)
                  TicksGet++;
               if(CountAvgExecution==true)
                  CountAvrgExecution(OperationDelay);
              }
            break;
           }
         else
           {
            RefreshRates();
            Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again open buy limit order");
            if(TryTimes>=3)
               break;
           }
        }
      //---Open Sell
      if(TypeOfOrder==OP_SELL)
        {
         if(UseVirtualLevels==false)
           {
            SL_Sell=NormalizeDouble(Ask+(PipsLevelLoss*DigitsPoints),Digits);
            if(PutTakeProfit==true)
               TP_Sell=NormalizeDouble(Bid-(PipsLevelProfit*DigitsPoints),Digits);
           }
         //---
         TicketSell=OrderSend(Symbol(),OP_SELL,LotSize,NormalizeDouble(Bid,Digits),Slippage,SL_Sell,TP_Sell,ExpertComments,MagicNumber,0,clrRed);
         //---
         if(TestingMode==true)
            SendMessages++;
         //---Exit loop
         if(TicketSell>0)
           {
            OperationDelay=GetTickCount()-TimeToSend;
            if(OperationDelay>0)
              {
               LastOperationDelay=OperationDelay;
               if(TicksGet<30)
                  TicksGet++;
               if(CountAvgExecution==true)
                  CountAvrgExecution(OperationDelay);
              }
            break;
           }
         else
           {
            RefreshRates();
            Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again open sell order");
            if(TryTimes>=3)
               break;
           }
        }
      //---Open SellLimit
      if(TypeOfOrder==OP_SELLLIMIT)
        {
         PriceSellLimit=NormalizeDouble(Ask+((PipsLevelLoss+DistancePending)*DigitsPoints),Digits);
         //---
         TicketSellLimit=OrderSend(Symbol(),OP_SELLLIMIT,LotSize,PriceSellLimit,Slippage,0,0,ExpertComments,MagicNumber,0,clrRed);
         //---
         if(TestingMode==true)
            SendMessages++;
         //---Exit loop
         if(TicketSellLimit>0)
           {
            OperationDelay=GetTickCount()-TimeToSend;
            if(OperationDelay>0)
              {
               LastOperationDelay=OperationDelay;
               if(TicksGet<30)
                  TicksGet++;
               if(CountAvgExecution==true)
                  CountAvrgExecution(OperationDelay);
              }
            break;
           }
         else
           {
            RefreshRates();
            Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again open sell limit order");
            if(TryTimes>=3)
               break;
           }
        }
      //---------------------------------------------------------------------
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ModifyMarketOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   bool ModifyBuy=false;
   bool ModifySell=false;
   double SL_Buy=0;
   double TP_Buy=0;
   double SL_Sell=0;
   double TP_Sell=0;
   double OrderStopLossBuy=0;
   double OrderStopLossSell=0;
   double OrderTakeProfitBuy=0;
   double OrderTakeProfitSell=0;
//---------------------------------------------------------------------
//Count ticks for modify
   if(ChangeAsk==true)
      CountTickModifyBuy++;
   if(ChangeBid==true)
      CountTickModifySell++;
//---------------------------------------------------------------------
//Close orders
   if(UseVirtualLevels==true)
     {
      if((CntBuy>0) && (CntSell>0))
        {
         //--Close buy
         if((CntBuy>0) && (VirtualStopLossBuy>0) && ((VirtualTakeProfitBuy>0) || (PutTakeProfit==false)) && ((Bid<=VirtualStopLossBuy) || ((Bid>=VirtualTakeProfitBuy) && (PutTakeProfit==true))))
           {
            CloseOrders(OP_BUY);
            VirtualStopLossBuy=0;
            VirtualTakeProfitBuy=0;
            return;
           }
         //---Close sell
         if((CntSell>0) && (VirtualStopLossSell>0) && ((VirtualTakeProfitSell>0) || (PutTakeProfit==false)) && ((Ask>=VirtualStopLossSell) || ((Ask<=VirtualTakeProfitSell) && (PutTakeProfit==true))))
           {
            CloseOrders(OP_SELL);
            VirtualStopLossSell=0;
            VirtualTakeProfitSell=0;
            return;
           }
        }
     }
//---------------------------------------------------------------------
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
           {
            //---------------------------------------------------------------------
            //Modify buy
            if(OrderType()==OP_BUY)
              {
               if(((CountTickModifyBuy>=DelayModifyOrders) || ((OrderStopLoss()==0) && (UseVirtualLevels==false)) || ((VirtualStopLossBuy==0) && (UseVirtualLevels==true))) && (TypeOfOrder==OP_BUY))
                 {
                  SL_Buy=NormalizeDouble(Bid-(PipsLevelLoss*DigitsPoints),Digits);
                  if(PutTakeProfit==true)
                     TP_Buy=NormalizeDouble(Ask+(PipsLevelProfit*DigitsPoints),Digits);
                  //---
                  if(UseVirtualLevels==false)
                    {
                     OrderStopLossBuy=NormalizeDouble(OrderStopLoss(),Digits);
                     OrderTakeProfitBuy=NormalizeDouble(OrderTakeProfit(),Digits);
                    }
                  //---
                  if(UseVirtualLevels==true)
                    {
                     OrderStopLossBuy=NormalizeDouble(VirtualStopLossBuy,Digits);
                     OrderTakeProfitBuy=NormalizeDouble(VirtualTakeProfitBuy,Digits);
                    }
                  //---------------------------------------------------------------------
                  if(((((PutTakeProfit==true) && (NormalizeDouble(OrderTakeProfitBuy,Digits)!=NormalizeDouble(TP_Buy,Digits)) &&
                        ((NormalizeDouble(OrderTakeProfitBuy-Ask,Digits)<=NormalizeDouble(((PipsLevelProfit-PipsStepModify)*DigitsPoints),Digits)) ||
                         (NormalizeDouble(OrderTakeProfitBuy-Ask,Digits)>=NormalizeDouble(((PipsLevelProfit+PipsStepModify)*DigitsPoints),Digits)))) ||
                       ((NormalizeDouble(OrderStopLossBuy,Digits)!=NormalizeDouble(SL_Buy,Digits)) &&
                        ((NormalizeDouble(Bid-OrderStopLossBuy,Digits)<=NormalizeDouble(((PipsLevelLoss-PipsStepModify)*DigitsPoints),Digits)) ||
                         (NormalizeDouble(Bid-OrderStopLossBuy,Digits)>=NormalizeDouble(((PipsLevelLoss+PipsStepModify)*DigitsPoints),Digits)))))) ||
                     ((OrderStopLoss()==0) && (UseVirtualLevels==false)) || ((VirtualStopLossBuy==0) && (UseVirtualLevels==true)))
                    {
                     //---Virtual levels
                     if(UseVirtualLevels==true)
                       {
                        VirtualStopLossBuy=SL_Buy;
                        VirtualTakeProfitBuy=TP_Buy;
                        CountTickModifyBuy=0;
                        if(ShowVirtualLevels==true)
                           CreatLines(OP_BUY);
                        if((UsePendingOrders==true)&&(CntBuyLimit>0))
                           ModifyPendingOrders(OP_BUYLIMIT);
                        break;
                       }
                     //---Normal levels
                     if(UseVirtualLevels==false)
                       {
                        TryTimes=0;
                        while(true)
                          {
                           TryTimes++;
                           OperationDelay=0;
                           TimeToSend=GetTickCount();
                           //---Modify
                           ModifyBuy=OrderModify(OrderTicket(),0,SL_Buy,TP_Buy,0,clrBlue);
                           //---
                           if(TestingMode==true)
                              SendMessages++;
                           if(ModifyBuy==true)
                             {
                              //---Modify pending
                              if((UsePendingOrders==true) && (CntBuyLimit>0))
                                 ModifyPendingOrders(OP_BUYLIMIT);
                              //---
                              CountTickModifyBuy=0;
                              OperationDelay=GetTickCount()-TimeToSend;
                              if(OperationDelay>0)
                                {
                                 LastOperationDelay=OperationDelay;
                                 if(TicksGet<30)
                                    TicksGet++;
                                 if(CountAvgExecution==true)
                                    CountAvrgExecution(OperationDelay);
                                }
                              break;
                             }
                           else
                             {
                              RefreshRates();
                              SL_Buy=NormalizeDouble(Bid-(PipsLevelLoss*DigitsPoints),Digits);
                              if(PutTakeProfit==true)
                                 TP_Buy=NormalizeDouble(Ask+(PipsLevelProfit*DigitsPoints),Digits);
                              Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again modify buy order");
                              if(TryTimes>=3)
                                 break;
                             }
                          }
                       }
                    }
                  break;
                 }//End if((CountTickModifyBuy>=............
              }
            //---------------------------------------------------------------------
            //Modify sell
            if(OrderType()==OP_SELL)
              {
               if(((CountTickModifySell>=DelayModifyOrders) || ((OrderStopLoss()==0) && (UseVirtualLevels==false)) || ((VirtualStopLossSell==0) && (UseVirtualLevels==true))) && (TypeOfOrder==OP_SELL))
                 {
                  SL_Sell=NormalizeDouble(Ask+(PipsLevelLoss*DigitsPoints),Digits);
                  if(PutTakeProfit==true)
                     TP_Sell=NormalizeDouble(Bid-(PipsLevelProfit*DigitsPoints),Digits);
                  //---
                  if(UseVirtualLevels==false)
                    {
                     OrderStopLossSell=NormalizeDouble(OrderStopLoss(),Digits);
                     OrderTakeProfitSell=NormalizeDouble(OrderTakeProfit(),Digits);
                    }
                  //---
                  if(UseVirtualLevels==true)
                    {
                     OrderStopLossSell=NormalizeDouble(VirtualStopLossSell,Digits);
                     OrderTakeProfitSell=NormalizeDouble(VirtualTakeProfitSell,Digits);
                    }
                  //---------------------------------------------------------------------
                  if(((((PutTakeProfit==true) && (NormalizeDouble(OrderTakeProfitSell,Digits)!=NormalizeDouble(TP_Sell,Digits)) &&
                        ((NormalizeDouble(Bid-OrderTakeProfitSell,Digits)<=NormalizeDouble(((PipsLevelProfit-PipsStepModify)*DigitsPoints),Digits)) ||
                         (NormalizeDouble(Bid-OrderTakeProfitSell,Digits)>=NormalizeDouble(((PipsLevelProfit+PipsStepModify)*DigitsPoints),Digits)))) ||
                       ((NormalizeDouble(OrderStopLossSell,Digits)!=NormalizeDouble(SL_Sell,Digits)) &&
                        ((NormalizeDouble(OrderStopLossSell-Ask,Digits)<=NormalizeDouble(((PipsLevelLoss-PipsStepModify)*DigitsPoints),Digits)) ||
                         (NormalizeDouble(OrderStopLossSell-Ask,Digits)>=NormalizeDouble(((PipsLevelLoss+PipsStepModify)*DigitsPoints),Digits)))))) ||
                     ((OrderStopLoss()==0) && (UseVirtualLevels==false)) || ((VirtualStopLossSell==0) && (UseVirtualLevels==true)))
                    {
                     //---Virtual levels
                     if(UseVirtualLevels==true)
                       {
                        VirtualStopLossSell=SL_Sell;
                        VirtualTakeProfitSell=TP_Sell;
                        CountTickModifySell=0;
                        if(ShowVirtualLevels==true)
                           CreatLines(OP_SELL);
                        if((UsePendingOrders==true)&&(CntSellLimit>0))
                           ModifyPendingOrders(OP_SELLLIMIT);
                        break;
                       }
                     //---Normal levels
                     if(UseVirtualLevels==false)
                       {
                        TryTimes=0;
                        while(true)
                          {
                           TryTimes++;
                           OperationDelay=0;
                           TimeToSend=GetTickCount();
                           //---Modify
                           ModifySell=OrderModify(OrderTicket(),0,SL_Sell,TP_Sell,0,clrRed);
                           //---
                           if(TestingMode==true)
                              SendMessages++;
                           if(ModifySell==true)
                             {
                              //---Modify pending
                              if((UsePendingOrders==true) && (CntSellLimit>0))
                                 ModifyPendingOrders(OP_SELLLIMIT);
                              //---
                              CountTickModifySell=0;
                              OperationDelay=GetTickCount()-TimeToSend;
                              if(OperationDelay>0)
                                {
                                 LastOperationDelay=OperationDelay;
                                 if(TicksGet<30)
                                    TicksGet++;
                                 if(CountAvgExecution==true)
                                    CountAvrgExecution(OperationDelay);
                                }
                              break;
                             }
                           else
                             {
                              RefreshRates();
                              SL_Sell=NormalizeDouble(Ask+(PipsLevelLoss*DigitsPoints),Digits);
                              if(PutTakeProfit==true)
                                 TP_Sell=NormalizeDouble(Bid-(PipsLevelProfit*DigitsPoints),Digits);
                              Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again modify sell order");
                              if(TryTimes>=3)
                                 break;
                             }
                          }
                       }
                    }
                  break;
                 }//End if((CountTickModifySell>=............
              }
            //---------------------------------------------------------------------
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ModifyPendingOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   bool ModifyBuyLimit=false;
   bool ModifySellLimit=false;
   double StopLossBuyOrder=0;
   double StopLossSellOrder=0;
//---------------------------------------------------------------------
//Get informations
   if(UseVirtualLevels==false)
     {
      for(int j=0; j<OrdersTotal(); j++)
        {
         if(OrderSelect(j,SELECT_BY_POS)==true)
           {
            if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
              {
               if(OrderType()==OP_BUY)
                  StopLossBuyOrder=OrderStopLoss();
               if(OrderType()==OP_SELL)
                  StopLossSellOrder=OrderStopLoss();
              }
           }
        }
     }
//---
   if(UseVirtualLevels==true)
     {
      StopLossBuyOrder=VirtualStopLossBuy;
      StopLossSellOrder=VirtualStopLossSell;
     }
//---------------------------------------------------------------------
//Check orders
   for(int k=0; k<OrdersTotal(); k++)
     {
      if(OrderSelect(k,SELECT_BY_POS)==true)
        {
         if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
           {
            //---------------------------------------------------------------------
            //Buy limit
            if(OrderType()==OP_BUYLIMIT)
              {
               if((NormalizeDouble(StopLossBuyOrder-(DistancePending*DigitsPoints),Digits)!=NormalizeDouble(OrderOpenPrice(),Digits)) && (TypeOfOrder==OP_BUYLIMIT) && (StopLossBuyOrder!=0))
                 {
                  TryTimes=0;
                  while(true)
                    {
                     TryTimes++;
                     OperationDelay=0;
                     TimeToSend=GetTickCount();
                     //---Modify
                     ModifyBuyLimit=OrderModify(OrderTicket(),NormalizeDouble(StopLossBuyOrder-(DistancePending*DigitsPoints),Digits),0,0,0,clrBlue);
                     //---
                     if(TestingMode==true)
                        SendMessages++;
                     if(ModifyBuyLimit==true)
                       {
                        OperationDelay=GetTickCount()-TimeToSend;
                        if(OperationDelay>0)
                          {
                           LastOperationDelay=OperationDelay;
                           if(TicksGet<30)
                              TicksGet++;
                           if(CountAvgExecution==true)
                              CountAvrgExecution(OperationDelay);
                          }
                        break;
                       }
                     else
                       {
                        RefreshRates();
                        Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again modify buy limit order");
                        if(TryTimes>=3)
                           break;
                       }
                    }
                  break;
                 }
              }
            //---------------------------------------------------------------------
            //Sell limit
            if(OrderType()==OP_SELLLIMIT)
              {
               if((NormalizeDouble(StopLossSellOrder+(DistancePending*DigitsPoints),Digits)!=NormalizeDouble(OrderOpenPrice(),Digits)) && (TypeOfOrder==OP_SELLLIMIT) && (StopLossSellOrder!=0))
                 {
                  TryTimes=0;
                  while(true)
                    {
                     TryTimes++;
                     OperationDelay=0;
                     TimeToSend=GetTickCount();
                     //---Modify
                     ModifySellLimit=OrderModify(OrderTicket(),NormalizeDouble(StopLossSellOrder+(DistancePending*DigitsPoints),Digits),0,0,0,clrRed);
                     //---
                     if(TestingMode==true)
                        SendMessages++;
                     if(ModifySellLimit==true)
                       {
                        OperationDelay=GetTickCount()-TimeToSend;
                        if(OperationDelay>0)
                          {
                           LastOperationDelay=OperationDelay;
                           if(TicksGet<30)
                              TicksGet++;
                           if(CountAvgExecution==true)
                              CountAvrgExecution(OperationDelay);
                          }
                        break;
                       }
                     else
                       {
                        RefreshRates();
                        Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again modify sell limit order");
                        if(TryTimes>=3)
                           break;
                       }
                    }
                  break;
                 }
              }
            //---------------------------------------------------------------------
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CloseOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   bool CloseBuy=false;
   bool CloseSell=false;
//---------------------------------------------------------------------
   TryTimes=0;
//---------------------------------------------------------------------
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
           {
            //---Close buy
            if((TypeOfOrder==OP_BUY) && (OrderType()==OP_BUY))
              {
               while(true)
                 {
                  TryTimes++;
                  OperationDelay=0;
                  TimeToSend=GetTickCount();
                  //---
                  CloseBuy=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),Slippage,clrBlue);
                  //---
                  if(TestingMode==true)
                     SendMessages++;
                  //---Exit loop
                  if(CloseBuy==true)
                    {
                     OperationDelay=GetTickCount()-TimeToSend;
                     if(OperationDelay>0)
                       {
                        LastOperationDelay=OperationDelay;
                        if(TicksGet<30)
                           TicksGet++;
                        if(CountAvgExecution==true)
                           CountAvrgExecution(OperationDelay);
                       }
                     break;
                    }
                  else
                    {
                     RefreshRates();
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again close buy order");
                     if(TryTimes>=3)
                        break;
                    }
                 }
              }
            //---Close sell
            if((TypeOfOrder==OP_SELL) && (OrderType()==OP_SELL))
              {
               while(true)
                 {
                  TryTimes++;
                  OperationDelay=0;
                  TimeToSend=GetTickCount();
                  //---
                  CloseSell=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),Slippage,clrRed);
                  //---
                  if(TestingMode==true)
                     SendMessages++;
                  //---Exit loop
                  if(CloseSell==true)
                    {
                     OperationDelay=GetTickCount()-TimeToSend;
                     if(OperationDelay>0)
                       {
                        LastOperationDelay=OperationDelay;
                        if(TicksGet<30)
                           TicksGet++;
                        if(CountAvgExecution==true)
                           CountAvrgExecution(OperationDelay);
                       }
                     break;
                    }
                  else
                    {
                     RefreshRates();
                     Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again close sell order");
                     if(TryTimes>=3)
                        break;
                    }
                 }
              }
            //---------------------------------------------------------------------
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void DeleteOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
   bool DeleteOrders=false;
//---------------------------------------------------------------------
//Delete pending orders
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()) && (OrderType()==TypeOfOrder))
           {
            TryTimes=0;
            while(true)
              {
               TryTimes++;
               OperationDelay=0;
               DeleteOrders=false;
               TimeToSend=GetTickCount();
               //---
               DeleteOrders=OrderDelete(OrderTicket(),clrNONE);
               //---
               if(TestingMode==true)
                  SendMessages++;
               if(DeleteOrders==true)
                 {
                  OperationDelay=GetTickCount()-TimeToSend;
                  if(OperationDelay>0)
                    {
                     LastOperationDelay=OperationDelay;
                     if(TicksGet<30)
                        TicksGet++;
                     if(CountAvgExecution==true)
                        CountAvrgExecution(OperationDelay);
                    }
                  break;
                 }
               else
                 {
                  RefreshRates();
                  Print("Error: ",DoubleToStr(GetLastError(),0)+" || "+ExpertComments+": receives new data and try again delete pending order");
                  if(TryTimes>=3)
                     break;
                 }
              }
            //---------------------------------------------------------------------
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CountOrders()
  {
//---------------------------------------------------------------------
   TotalOrders=0;
   CntBuy=0;
   CntSell=0;
   CntBuyLimit=0;
   CntSellLimit=0;
//---------------------------------------------------------------------
   if(OrdersTotal()>0)
     {
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS)==true)
           {
            if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
              {
               TotalOrders++;
               if(OrderType()==OP_BUY)
                  CntBuy++;
               if(OrderType()==OP_SELL)
                  CntSell++;
               if(OrderType()==OP_BUYLIMIT)
                  CntBuyLimit++;
               if(OrderType()==OP_SELLLIMIT)
                  CntSellLimit++;
               if(((OrderType()==OP_BUY) || (OrderType()==OP_SELL)) && (GetCommissionPair==0))
                  GetCommissionPair=MathAbs(OrderCommission()/OrderLots());
              }
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void HistoryResults()
  {
//---------------------------------------------------------------------
   TotalTrades=0;
   TotalProfitLoss=0;
   HistoryPips=0;
   AvrgDuration=0;
   AvrgPipsProfit=0;
   AvrgPipsLoss=0;
   WinTrades=0;
   LossTrades=0;
   CurrentDistanceBuy=0;
   CurrentDistanceSell=0;
//---------------------------------------------------------------------
   if(OrdersHistoryTotal()>0)
     {
      for(i=0; i<OrdersHistoryTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
           {
            if((OrderMagicNumber()==MagicNumber) && (OrderSymbol()==Symbol()))
              {
               if((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
                 {
                  TotalTrades++;
                  if(TestingMode==true)
                    {
                     if(!((TimeDayOfWeek(OrderOpenTime())==5) && (TimeDayOfWeek(OrderCloseTime())==1)))
                        AvrgDuration+=TimeSeconds(OrderCloseTime()-OrderOpenTime());
                    }
                  TotalProfitLoss+=OrderProfit()+OrderCommission()+OrderSwap();
                  //---For buy
                  if(OrderType()==OP_BUY)
                    {
                     CurrentDistanceBuy=(OrderClosePrice()-Ask)/DigitsPoints;
                     HistoryPips+=(OrderClosePrice()-OrderOpenPrice())/DigitsPoints;
                     if(TestingMode==true)
                       {
                        if(OrderClosePrice()>OrderOpenPrice())
                          {
                           AvrgPipsProfit+=(OrderClosePrice()-OrderOpenPrice())/DigitsPoints;
                           WinTrades++;
                          }
                        if(OrderClosePrice()<OrderOpenPrice())
                          {
                           AvrgPipsLoss+=(OrderClosePrice()-OrderOpenPrice())/DigitsPoints;
                           LossTrades++;
                          }
                       }
                    }
                  //---For sell
                  if(OrderType()==OP_SELL)
                    {
                     CurrentDistanceSell=(Bid-OrderClosePrice())/DigitsPoints;
                     HistoryPips+=(OrderOpenPrice()-OrderClosePrice())/DigitsPoints;
                     if(TestingMode==true)
                       {
                        if(OrderClosePrice()<OrderOpenPrice())
                          {
                           AvrgPipsProfit+=(OrderOpenPrice()-OrderClosePrice())/DigitsPoints;
                           WinTrades++;
                          }
                        if(OrderClosePrice()>OrderOpenPrice())
                          {
                           AvrgPipsLoss+=(OrderOpenPrice()-OrderClosePrice())/DigitsPoints;
                           LossTrades++;
                          }
                       }
                    }
                 }
              }
           }
        }
     }
//---------------------------------------------------------------------
//Get average values
   if(TestingMode==true)
     {
      if(TotalTrades>0)
         AvrgDuration/=TotalTrades;
      if(WinTrades>0)
         AvrgPipsProfit/=WinTrades;
      if(LossTrades>0)
         AvrgPipsLoss/=LossTrades;
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
//Break even close
//====================================================================================================================================================//
void CreatLines(int TypeOfOrder)
  {
//---------------------------------------------------------------------
//Buy lines on screen
   if(TypeOfOrder==OP_BUY)
     {
      if(CntBuy>0)
        {
         //---Creat line stop loss buy
         if(ObjectFind(NameOfBuyStopLossLine)==-1)
           {
            ObjectCreate(NameOfBuyStopLossLine,OBJ_HLINE,0,0,0);
            ObjectSet(NameOfBuyStopLossLine,OBJPROP_COLOR,clrRed);
            ObjectSet(NameOfBuyStopLossLine,OBJPROP_STYLE,STYLE_DOT);
            ObjectSet(NameOfBuyStopLossLine,OBJPROP_PRICE1,VirtualStopLossBuy);
           }
         //---Creat line take profit buy
         if(ObjectFind(NameOfBuyTakeProfitLine)==-1)
           {
            ObjectCreate(NameOfBuyTakeProfitLine,OBJ_HLINE,0,0,0);
            ObjectSet(NameOfBuyTakeProfitLine,OBJPROP_COLOR,clrBlue);
            ObjectSet(NameOfBuyTakeProfitLine,OBJPROP_STYLE,STYLE_DOT);
            ObjectSet(NameOfBuyTakeProfitLine,OBJPROP_PRICE1,VirtualTakeProfitBuy);
           }
         //---Move lines
         if(ObjectFind(NameOfBuyStopLossLine)>-1)
            if(NormalizeDouble(ObjectGet(NameOfBuyStopLossLine,OBJPROP_PRICE1),Digits)!=NormalizeDouble(VirtualStopLossBuy,Digits))
               ObjectMove(0,NameOfBuyStopLossLine,0,Time[0],VirtualStopLossBuy);
         if(ObjectFind(NameOfBuyTakeProfitLine)>-1)
            if(NormalizeDouble(ObjectGet(NameOfBuyTakeProfitLine,OBJPROP_PRICE1),Digits)!=NormalizeDouble(VirtualTakeProfitBuy,Digits))
               ObjectMove(0,NameOfBuyTakeProfitLine,0,Time[0],VirtualTakeProfitBuy);
        }
      //---Delete lines
      if(CntBuy==0)
        {
         if(ObjectFind(NameOfBuyStopLossLine)>-1)
            ObjectDelete(NameOfBuyStopLossLine);
         if(ObjectFind(NameOfBuyTakeProfitLine)>-1)
            ObjectDelete(NameOfBuyTakeProfitLine);
        }
     }
//---------------------------------------------------------------------
//Sell lines on screen
   if(TypeOfOrder==OP_SELL)
     {
      if(CntSell>0)
        {
         //---Creat line stop loss sell
         if(ObjectFind(NameOfSellStopLossLine)==-1)
           {
            ObjectCreate(NameOfSellStopLossLine,OBJ_HLINE,0,0,0);
            ObjectSet(NameOfSellStopLossLine,OBJPROP_COLOR,clrRed);
            ObjectSet(NameOfSellStopLossLine,OBJPROP_STYLE,STYLE_DOT);
            ObjectSet(NameOfSellStopLossLine,OBJPROP_PRICE1,VirtualStopLossSell);
           }
         //---Creat line take profit sell
         if(ObjectFind(NameOfSellTakeProfitLine)==-1)
           {
            ObjectCreate(NameOfSellTakeProfitLine,OBJ_HLINE,0,0,0);
            ObjectSet(NameOfSellTakeProfitLine,OBJPROP_COLOR,clrBlue);
            ObjectSet(NameOfSellTakeProfitLine,OBJPROP_STYLE,STYLE_DOT);
            ObjectSet(NameOfSellTakeProfitLine,OBJPROP_PRICE1,VirtualTakeProfitSell);
           }
         //---Move lines
         if(ObjectFind(NameOfSellStopLossLine)>-1)
            if(NormalizeDouble(ObjectGet(NameOfSellStopLossLine,OBJPROP_PRICE1),Digits)!=NormalizeDouble(VirtualStopLossSell,Digits))
               ObjectMove(0,NameOfSellStopLossLine,0,Time[0],VirtualStopLossSell);
         if(ObjectFind(NameOfSellTakeProfitLine)>-1)
            if(NormalizeDouble(ObjectGet(NameOfSellTakeProfitLine,OBJPROP_PRICE1),Digits)!=NormalizeDouble(VirtualTakeProfitSell,Digits))
               ObjectMove(0,NameOfSellTakeProfitLine,0,Time[0],VirtualTakeProfitSell);
        }
      //---Delete lines
      if(CntSell==0)
        {
         if(ObjectFind(NameOfSellStopLossLine)>-1)
            ObjectDelete(NameOfSellStopLossLine);
         if(ObjectFind(NameOfSellTakeProfitLine)>-1)
            ObjectDelete(NameOfSellTakeProfitLine);
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void GetAvrgSpread(double CurrSpread)
  {
//---------------------------------------------------------------------
   double SumSpread=0;
   int LoopCount=TimesForAverage-1;
   AvgSpread=0;
//---------------------------------------------------------------------
   if(CountTickSpreadPair<TimesForAverage)
      CountTickSpreadPair++;
   CountTickSpread=CountTickSpreadPair;
   ArrayCopy(ArraySpreadPair,ArraySpreadPair,0,1,TimesForAverage-1);
   ArraySpreadPair[TimesForAverage-1]=CurrSpread;
//---------------------------------------------------------------------
   for(Count=0; Count<CountTickSpreadPair; Count++)
     {
      SumSpread+=ArraySpreadPair[LoopCount];
      LoopCount--;
     }
//---------------------------------------------------------------------
   if(CountTickSpread>0)
      AvgSpread=NormalizeDouble(SumSpread/CountTickSpread,2);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CountAvrgExecution(datetime Latency)
  {
//---------------------------------------------------------------------
   datetime SumExecution=0;
   int LoopCount=TimesForAverage-1;
   AvgExecution=0;
//---------------------------------------------------------------------
   if(CountTimesModify<TimesForAverage)
      CountTimesModify++;
   TimesModify=CountTimesModify;
//---------------------------------------------------------------------
   ArrayCopy(ArrayExecution,ArrayExecution,0,1,TimesForAverage-1);
   ArrayExecution[TimesForAverage-1]=Latency;
//---------------------------------------------------------------------
   for(Count=0; Count<CountTimesModify; Count++)
     {
      SumExecution+=ArrayExecution[LoopCount];
      LoopCount--;
     }
//---------------------------------------------------------------------
   if(TimesModify>0)
      AvgExecution=NormalizeDouble(SumExecution/TimesModify,2);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ClearChart()
  {
//---------------------------------------------------------------------
   if(TimeCurrent()-TimeDeleteObjects>=DeleteMinutes*60)
     {
      for(i=ObjectsTotal()-1; i>=0; i--)
        {
         if(ObjectName(i)!=BackgroundName)
            ObjectDelete(ObjectName(i));
         TimeDeleteObjects=TimeCurrent();
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ChartBackground(string StringName,color ImageColor,int Xposition,int Yposition,int Xsize,int Ysize)
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
void ScreenComment(int TypeComm)
  {
//---------------------------------------------------------------------
//Strings
   string LastLine1;
   string LastLine2;
   double ShowAvgSpread;
   double ShowAvgExecution;
//---------------------------------------------------------------------
//---Normal
   if(TypeComm==1)
     {
      LastLine1="History Orders/Pips : "+DoubleToStr(TotalTrades,0)+" / "+DoubleToStr(HistoryPips,2);
      LastLine2="History Profit/Loss   :  "+DoubleToStr(TotalProfitLoss,2);
     }
//---Spread
   if(TypeComm==2)
     {
      LastLine1="  Spread Plus Commission Is Too High!!!";
      LastLine2="  High Spread Action Is Inactive...";
     }
//---Margin
   if(TypeComm==3)
     {
      LastLine1="Account Free Margin Is Too Low!!!";
      LastLine2="      Expert Stopped Trade!!!";
     }
//---Stop level
   if(TypeComm==4)
     {
      LastLine1="    Broker Stop Level Is Too High!!!";
      LastLine2="      Expert Stopped Trade!!!";
     }
//---Auto trading
   if(TypeComm==5)
     {
      LastLine1="    Please Turn On 'Auto Trading'";
      LastLine2="      Expert wait To Trade!!!";
     }
//---Time
   if(TypeComm==6)
     {
      LastLine1="    Out Of Session Market!!!";
      LastLine2="      Expert Stopped To Trade!!!";
     }
//---------------------------------------------------------------------
//Set averages value
   if(CountAvgSpread==false)
      ShowAvgSpread=0;
   else
      ShowAvgSpread=AvgSpread+RealCommission;
   if(CountAvgExecution==false)
      ShowAvgExecution=0;
   else
      ShowAvgExecution=AvgExecution;
//---------------------------------------------------------------------
//Screen info and comments
   Comment("---------------------------------------------------------"
           +"\n"+ExpertComments+" 2018 by Pannik ®"
           +"\n---------------------------------------------------------"
           +"\nOrders ID         :  "+DoubleToStr(MagicNumber,0)
           +"\nLot Size            :  "+DoubleToStr(LotSize,2)
           +"\nStop Level        :  "+DoubleToStr(StopLevel,2)
           +"\nLimit Spread      :  "+DoubleToStr(MaxSpread,2)
           +"\nSpread/Avrg     :  "+DoubleToStr(SpreadPips,2)+" / "+DoubleToStr(ShowAvgSpread,2)+" (pips)"
           +"\nExecution/Avrg  :  "+DoubleToStr(LastOperationDelay,0)+" / "+DoubleToStr(ShowAvgExecution,0)+" (ms)"
           +"\nCommissions     :  "+ShowInfoCommission
           +"\n---------------------------------------------------------"
           +"\nMarket Orders   :  "+IntegerToString(CntBuy)+" / "+IntegerToString(CntSell)
           +"\nPending Orders  :  "+IntegerToString(CntBuyLimit)+" / "+IntegerToString(CntSellLimit)
           +"\n---------------------------------------------------------"
           +"\n"+LastLine1
           +"\n"+LastLine2
           +"\n---------------------------------------------------------");
//---------------------------------------------------------------------
  }
//================================================================================================================================//
