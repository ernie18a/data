//============================================================================================================================================================================================================================//
#property copyright   "Copyright 2020-2023, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.8"
#property description "\nThe expert is a grid system with option for progressing lot size."
#property description "\nUse expert on pair with tight spread and low commission broker."
//#property icon        "\\Images\\BuildYourGrid-Logo.ico";
#property strict
//============================================================================================================================================================================================================================//
enum Type {Open_Buy_And_Sell, Open__Only_Buy, Open__Only_Sell};
enum Next {Grid_According_Trend, Grid_Contrary_Trend};
enum Step {Statical_Step, Geometrical_Step, Exponetial_Step};
enum Target {Target_In_Pips, Target_In_Currency};
enum Loss {Not_Close_In_Loss, Close_First_Orders, Close_All_Orders};
enum Lot  {Statical_Lot, Geometrical_Lot, Exponetial_Lot};
//============================================================================================================================================================================================================================//
#define MagicSet 101010
//============================================================================================================================================================================================================================//
input string OpenOrdersSets        = "||========== Open Orders Parameters ==========||";
input Type   TypeOrdersPlace       = Open_Buy_And_Sell;//Type Of Orders Place
input Next   TypeOfNextOrders      = Grid_Contrary_Trend;//Type Of Grid Build
input double PipsForNextOrder      = 50.0;//Step For Next Order (Pips)
input Step   TypeOfStepProgress    = Geometrical_Step;//Type Step Progress
input string CloseProfitSets       = "||========== Close At Profit Parameters ==========||";
input Target TypeTargetClose       = Target_In_Pips;//Type Of Target Close At Profit
input double PipsCloseInProfit     = 10.0;//Target In Pips Close At Profit
input double CurrCloseInProfit     = 10.0;//Target In Currency Close At Profit
input string CloseLossSets         = "||========== Close At Loss Parameters ==========||";
input Loss   ModeCloseInLoss       = Close_All_Orders;//Mode Close In Loss
input double PipsForCloseInLoss    = 100.0;//Losses For Close (Pips)
input string HedgeModeSets         = "||==========  Hedge Mode Parameters ==========||";
input bool   PlaceHedgeOrder       = false;//Place Hedge Order
input double LevelLossForHedge     = 10.0;//Level Loss For Hedge (% Of Balance)
input double MuliplierHedgeLot     = 1.0;//Multiplier Hedge Lot
input string Money_Management      = "||========== Money Management Parameters ==========||";
input bool   AutoLotSize           = false;//Auto Money Management
input double RiskFactor            = 1.0;//Risk Money Management (From 0.01 To 100)
input double ManualLotSize         = 0.01;//Manual Lot Size
input Lot    TypeOfLotProgress     = Statical_Lot;//Type Lot Progress
input double MaxMultiplierLot      = 50.0;//Maximum Multiplier Lot (0=No Limit)
input string SetChartStr           = "||========== Set Chart Parameters ==========||";
input bool   SetChartRun           = false;//Set Automatically Chart To Run
input string SymbolPairRun         = "EURUSD";//Set Symbol Pair To Run
input ENUM_TIMEFRAMES TimeFrameRun = PERIOD_M1;//Set Time Frame To Run
input string InformationSets       = "||========== Information On Cahrt Parameters ==========||";
input bool   ShowComments          = false;//Show Comments On Chart
input color  ColorOffLines         = clrGray;//Color Off Lines
input color  ColorExpertName       = clrDodgerBlue;//Color Expert Name
input color  ColorSpreadInfo       = clrChocolate;//Color Spread Information
input color  ColorMoneyManagement  = clrOrange;//Color Money Management
input color  ColorCurrentOrders    = clrNavajoWhite;//Color Current Orders
input color  ColorHistoryOrders    = clrIvory;//Color History Orders
input string GeneralSets           = "||========== General Options Parameters ==========||";
input int    MagicNumber           = 0;//Orders' ID (0=Generate Automatically)
input double MaxSpread             = 0.0;//Max Accepted Spread (0=No Limit)
input int    MaxOrders             = 0;//Max Opened Orders (0=No Limit)
input int    Slippage              = 3;//Accepted Slippage
input bool   UseCompletedBar       = false;//Use Completed Bar
input bool   SoundAlert            = false;//Play Sound Alerts
input bool   PrintOperations       = false;//Print Information Log
input string CommentsOrders        = "BuildYourGridEA";//Orders' Comment
//============================================================================================================================================================================================================================//
string SoundAtClose="alert2.wav";
string SoundAtOpen="alert.wav";
string SymbolSuffix="";
string ExpertName;
string SymbolTrade;
string BackgroundName;
string WarningMessage;
//----------------------------------------------
double DigitPoints;
double Spread;
double LastBid=0;
double LastAsk=0;
double TotalHistoryProfitLoss;
double BuyProfits;
double SellProfits;
double PriceOpenLastBuy;
double PriceOpenLastSell;
double TotalLotsBuy;
double TotalLotsSell;
double MaxDD=-9999999999;
double MaxTotalLots=0;
double MinFreeMargin=999999999999999;
double LotLastBuy;
double LotLastSell;
double LotFirstBuy;
double LotFirstSell;
double BuyPips;
double SellPips;
//----------------------------------------------
int SignalsMessageWarning;
int LastHistoryOrders=0;
int OrdersID;
int TotalHistoryOrders;
int MultiplierPoint;
int SumOrders;
int BuyOrders;
int SellOrders;
int cnt;
int i,k;
int CountTimes;
int LastHistoryDeals=0;
int AcceptMaxOrders=0;
int TypeLastOpenOrder;
int MaxTotalOrders=0;
int TypeFirstOpenOrder;
//----------------------------------------------
long TicketFirstBuy;
long TicketFirstSell;
//----------------------------------------------
bool AcceptedSpread;
bool TimeToTrade;
bool OpenBuy=false;
bool OpenSell=false;
bool CloseOrdersInProfit=false;
bool CloseOrdersInLoss=false;
bool OpenHedgeOrder=false;
bool UnderHedgePair=false;
//----------------------------------------------
datetime TimeHour=0;
datetime TimeLastBar=0;
//----------------------------------------------
color ChartColor;
//============================================================================================================================================================================================================================//
//OnInit function
//============================================================================================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//Skip results
   if(MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if((PlaceHedgeOrder==true)&&(LevelLossForHedge==0)&&(MuliplierHedgeLot!=1))
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//Check parameters
   if((RiskFactor<0.01)||(RiskFactor>100))
     {
      PrintFormat("Invalid RiskFactor input value: %d",RiskFactor);
      if(MQLInfoInteger(MQL_OPTIMIZATION))
         return(INIT_PARAMETERS_INCORRECT);
      else
         return(INIT_FAILED);
     }
//---
   if(MaxSpread<0)
     {
      PrintFormat("Invalid MaxSpread input value: %d",MaxSpread);
      if(MQLInfoInteger(MQL_OPTIMIZATION))
         return(INIT_PARAMETERS_INCORRECT);
      else
         return(INIT_FAILED);
     }
//---
   if(MaxOrders<0)
     {
      PrintFormat("Invalid MaxOrders input value: %d",MaxOrders);
      if(MQLInfoInteger(MQL_OPTIMIZATION))
         return(INIT_PARAMETERS_INCORRECT);
      else
         return(INIT_FAILED);
     }
//---------------------------------------------------------------------
//Get expert name and symbol name
   ExpertName=MQLInfoString(MQL_PROGRAM_NAME);
   SymbolTrade=Symbol();
//---------------------------------------------------------------------
//Get symbol suffix
   if(StringLen(SymbolTrade)>6)
      SymbolSuffix=StringSubstr(SymbolTrade,6,0);
//---------------------------------------------------------------------
//Set chart
   if(SetChartRun==true)
     {
      if(SymbolSelect(SymbolPairRun+SymbolSuffix,true))
         Print(" # "+ExpertName+" # "+SymbolPairRun+SymbolSuffix+" is ok");
      if((ChartSymbol()!=SymbolPairRun+SymbolSuffix)||(ChartPeriod()!=TimeFrameRun))
        {
         if((MQLInfoInteger(MQL_TESTER))||(MQLInfoInteger(MQL_VISUAL_MODE))||(MQLInfoInteger(MQL_OPTIMIZATION)))
           {
            Comment("\n\nPlease set chart symbol and time frame...");
            Print(" # "+ExpertName+" # "+"please set chart symbol: "+SymbolPairRun+" and time frame: "+EnumToString(TimeFrameRun));
            return(INIT_FAILED);
           }
         else
           {
            Comment("\n\nExpert set chart symbol and time frame...");
            Print(" # "+ExpertName+" # "+"Set chart symbol: "+SymbolPairRun+" and time frame: "+EnumToString(TimeFrameRun));
            ChartSetSymbolPeriod(0,SymbolPairRun+SymbolSuffix,TimeFrameRun);
           }
        }
     }
//---------------------------------------------------------------------
//Set symbol name
   SymbolTrade=Symbol();
//---------------------------------------------------------------------
//Background
   if(ShowComments==true)
     {
      if(!MQLInfoInteger(MQL_OPTIMIZATION))
        {
         for(i=1; i<20; i++)
           {
            if(ObjectFind(0,"Com"+IntegerToString(i))>-1)
               ObjectDelete(0,"Com"+IntegerToString(i));
           }
         //---
         ChartColor=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
         BackgroundName="Background-"+ExpertName;
         //---
         if(ObjectFind(0,BackgroundName)==-1)
            DrawObjects(BackgroundName,ChartColor,BORDER_RAISED,false,0,15,312,168);
        }
     }
//---------------------------------------------------------------------
//Broker 4 or 5 digits
   DigitPoints=SymbolInfoDouble(SymbolTrade,SYMBOL_POINT);
   MultiplierPoint=1;
//---
   if(((int)SymbolInfoInteger(SymbolTrade,SYMBOL_DIGITS)==3)||((int)SymbolInfoInteger(SymbolTrade,SYMBOL_DIGITS)==5))
      MultiplierPoint=10;
   if((int)SymbolInfoInteger(SymbolTrade,SYMBOL_DIGITS)==2)
      MultiplierPoint=100;
//---
   DigitPoints*=MultiplierPoint;
//---------------------------------------------------------------------
//Set orders' ID
   OrdersID=MagicNumber;
//---
   if(MagicNumber==0)
     {
      OrdersID=0;
      for(i=0; i<StringLen(SymbolTrade); i++)
         OrdersID+=(StringGetCharacter(SymbolTrade,i)*(i+1));
      OrdersID+=MagicSet;
     }
//---------------------------------------------------------------------
//Set maximum orders
   if((MaxOrders==0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)==0))
      AcceptMaxOrders=0;
   if((MaxOrders>0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)==0))
      AcceptMaxOrders=MaxOrders;
   if((MaxOrders==0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)>0))
      AcceptMaxOrders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if((MaxOrders>0)&&(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)>0))
      AcceptMaxOrders=MathMin((int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),MaxOrders);
//---------------------------------------------------------------------
//For show comment if market is closed
   if((!MQLInfoInteger(MQL_OPTIMIZATION))&&(!MQLInfoInteger(MQL_TESTER)))
      MainFunction();
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//OnDeinit function
//============================================================================================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
//Clear chart
   if(ObjectFind(0,"HedgeCom")>-1)
      ObjectDelete(0,"HedgeCom");
//---
   ObjectDelete(0,BackgroundName);
//---
   for(i=1; i<20; i++)
     {
      if(ObjectFind(0,"Com"+IntegerToString(i))>-1)
         ObjectDelete(0,"Com"+IntegerToString(i));
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//OnTick function
//============================================================================================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
//Check for new bar
   if(UseCompletedBar==true)
     {
      if(iTime(Symbol(),PERIOD_CURRENT,0)==TimeLastBar)
         TimeLastBar=iTime(Symbol(),PERIOD_CURRENT,0);
      return;
     }
//---------------------------------------------------------------------
//Call main in tester
   if((MQLInfoInteger(MQL_TESTER))||(MQLInfoInteger(MQL_VISUAL_MODE))||(MQLInfoInteger(MQL_OPTIMIZATION)))
     {
      MainFunction();
      return;
     }
//---------------------------------------------------------------------
//Warning message
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Comment("\n      The trading terminal",
              "\n      of experts do not run",
              "\n\n\n      Turn ON EA Please .......");
      return;
     }
   else
     {
      MainFunction();
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Main function
//============================================================================================================================================================================================================================//
void MainFunction()
  {
//---------------------------------------------------------------------
//Reset value
   AcceptedSpread=true;
//---------------------------------------------------------------------
//Get spread
   Spread=(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)-SymbolInfoDouble(SymbolTrade,SYMBOL_BID))/DigitPoints;
//---------------------------------------------------------------------
//Check spread
   if((Spread>MaxSpread)&&(MaxSpread>0))
     {
      AcceptedSpread=false;
      Print("Spread is greater than Max Spread!!! (Spread: "+DoubleToString(Spread,1)+" || MaxSpread: "+DoubleToString(MaxSpread,1)+")");
     }
//---------------------------------------------------------------------
//Count current orders
   CountCurrentOrders();
//---------------------------------------------------------------------
//Count history orders
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
      CountHistoryOrders();
//---------------------------------------------------------------------
//Check signals
   GetSignals();
//---------------------------------------------------------------------
//Close orders
   if(SumOrders>0)
     {
      if(CloseOrdersInProfit==true)
        {
         if(BuyOrders>0)
            CloseOrders(ORDER_TYPE_BUY,-1);
         if(SellOrders>0)
            CloseOrders(ORDER_TYPE_SELL,-1);
         return;
        }
      //---
      if(ModeCloseInLoss>0)
        {
         if(CloseOrdersInLoss==true)
           {
            if(ModeCloseInLoss==1)
              {
               if(BuyOrders>0)
                  CloseOrders(ORDER_TYPE_BUY,TicketFirstBuy);
               if(SellOrders>0)
                  CloseOrders(ORDER_TYPE_SELL,TicketFirstSell);
               return;
              }
            if(ModeCloseInLoss==2)
              {
               if(BuyOrders>0)
                  CloseOrders(ORDER_TYPE_BUY,-1);
               if(SellOrders>0)
                  CloseOrders(ORDER_TYPE_SELL,-1);
               return;
              }
           }
        }
     }
//---------------------------------------------------------------------
//Make hedge
   if(OpenHedgeOrder==true)
     {
      if(TotalLotsBuy<TotalLotsSell)
         OpenOrders(ORDER_TYPE_BUY);
      if(TotalLotsBuy>TotalLotsSell)
         OpenOrders(ORDER_TYPE_SELL);
      return;
     }
//---------------------------------------------------------------------
//Open orders
   if((AcceptedSpread==true)&&((SumOrders<AcceptMaxOrders)||(AcceptMaxOrders==0)))
     {
      if(OpenBuy==true)
         OpenOrders(ORDER_TYPE_BUY);
      if(OpenSell==true)
         OpenOrders(ORDER_TYPE_SELL);
     }
//---------------------------------------------------------------------
//Call comment
   if(ShowComments==true)
     {
      if(!MQLInfoInteger(MQL_OPTIMIZATION))
         CommentScreen();
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Open orders
//============================================================================================================================================================================================================================//
void OpenOrders(int TypeOfOrder)
  {
//---------------------------------------------------------------------
//Set value
   int OpenOrderTicket=-1;
   double OpenPrice=0;
   color OpenColor=clrNONE;
   string TypeOfOrderStr;
   double OrdrLotSize=CalcLots(TypeOfOrder);
   double CheckMargin=0;
   double TP=0;
   double SL=0;
   bool LowMargin=false;
//---------------------------------------------------------------------
//Info for lot limit
   if(OrdrLotSize==0)
     {
      Print("Volume limit reached. Expert can't open new order.");
      return;
     }
//---------------------------------------------------------------------
//Set buy stop loss and take profit in price
   if(TypeOfOrder==ORDER_TYPE_BUY)
     {
      OpenColor=clrBlue;
      TypeOfOrderStr="Buy";
      OpenPrice=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK),Digits());
      //---Check limitations of lot size
      if((OrdrLotSize+TotalLotsBuy>SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)!=0))
        {
         if((SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)-TotalLotsBuy<SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN)))
           {
            WarningMessage="There are limitation of lot size, expert can't open new buy order!";
            Print(WarningMessage);
            return;
           }
         else
           {
            OrdrLotSize=SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN);
            WarningMessage="There are limitation of lot size, expert use min lot size!";
            Print(WarningMessage);
           }
        }
     }
//---------------------------------------------------------------------
//Set sell stop loss and take profit in price
   if(TypeOfOrder==ORDER_TYPE_SELL)
     {
      OpenColor=clrRed;
      TypeOfOrderStr="Sell";
      OpenPrice=NormalizeDouble(SymbolInfoDouble(SymbolTrade,SYMBOL_BID),Digits());
      //---Check limitations of lot size
      if((OrdrLotSize+TotalLotsSell>SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)!=0))
        {
         if((SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)-TotalLotsSell<SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN)))
           {
            WarningMessage="There are limitation of lot size, expert can't open new sell order!";
            Print(WarningMessage);
            return;
           }
         else
           {
            OrdrLotSize=SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN);
            WarningMessage="There are limitation of lot size, expert use min lot size!";
            Print(WarningMessage);
           }
        }
     }
//---------------------------------------------------------------------
//Calculate margin
   /*if(OrderCalcMargin((ENUM_ORDER_TYPE)TypeOfOrder,SymbolTrade,OrdrLotSize,OpenPrice,CheckMargin))
     {
      if(AccountInfoDouble(ACCOUNT_MARGIN_FREE)<CheckMargin)
         LowMargin=true;
     }
//---
   if(LowMargin==true)
     {
      Print("<NOTICE...[ "+ExpertName+": Free margin is low ("+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)-CheckMargin,2)+") ]...NOTICE>");
      Comment("\n\nFree margin is low ("+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)-CheckMargin,2)+")");
      return;
     }*/
//---------------------------------------------------------------------
//Declare and initialize the trade request and result of trade request
   MqlTradeCheckResult check= {};
   MqlTradeRequest request= {};
   MqlTradeResult result= {};
//---
   request.action=TRADE_ACTION_DEAL;
   request.magic=OrdersID;
   request.symbol=SymbolTrade;
   request.volume=OrdrLotSize;
   request.price=OpenPrice;
   request.type=(ENUM_ORDER_TYPE)TypeOfOrder;
   request.comment=CommentsOrders;
   request.sl=SL;
   request.tp=TP;
//---
   if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==1)
      request.type_filling=ORDER_FILLING_FOK;
   if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==2)
      request.type_filling=ORDER_FILLING_IOC;
//---------------------------------------------------------------------
//Send order
   if(OrderCheck(request,check)==true)
     {
      CountTimes=0;
      while(SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL)
        {
         CountTimes++;
         //---Send the request
         OpenOrderTicket=OrderSend(request,result);
         //---
         if(OpenOrderTicket>0)
           {
            if(SoundAlert==true)
               PlaySound(SoundAtOpen);
            if(PrintOperations==true)
               Print("Open: ",SymbolTrade," ",TypeOfOrderStr,".");
            break;
           }
         else
           {
            Print("Expert get an error: ",GetLastError());
           }
         //---
         Sleep(100);
         //---
         if(CountTimes>3)
           {
            Print("Failed open Order: ",TypeOfOrder);
            break;
           }
        }
     }
   /*else
     {
      if(PrintOperations==true)
         Print("<NOTICE...[ "+ExpertName+": Free margin is low ("+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2)+") ]...NOTICE>");
     }*/
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Close orders
//============================================================================================================================================================================================================================//
void CloseOrders(int TypeOfOrder, long TicketOrders)
  {
//---------------------------------------------------------------------
//Set variables
   bool CloseOrderTicket=false;
   string TypeOfOrderStr;
//---------------------------------------------------------------------
//Set type of order
   if(TypeOfOrder==ORDER_TYPE_BUY)
      TypeOfOrderStr="Buy";
   if(TypeOfOrder==ORDER_TYPE_SELL)
      TypeOfOrderStr="Sell";
//---------------------------------------------------------------------
//Declare and initialize the trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---------------------------------------------------------------------
//Iterate over all open positions
   for(i=PositionsTotal()-1; i>=0; i--)
     {
      //---Parameters of the order
      ulong position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      int digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong magic=PositionGetInteger(POSITION_MAGIC);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //---If the MagicNumber matches
      if((magic==OrdersID)&&(position_symbol==SymbolTrade)&&(type==(ENUM_POSITION_TYPE)TypeOfOrder)&&((position_ticket==TicketOrders)||(TicketOrders==-1)))
        {
         //---Zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //---Setting the operation parameters
         request.action=TRADE_ACTION_DEAL;
         request.position=position_ticket;
         request.symbol=position_symbol;
         request.volume=volume;
         request.deviation=5;
         request.magic=OrdersID;
         request.comment=CommentsOrders;
         //---
         if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==1)
            request.type_filling=ORDER_FILLING_FOK;
         if(SymbolInfoInteger(SymbolTrade,SYMBOL_FILLING_MODE)==2)
            request.type_filling=ORDER_FILLING_IOC;
         //---Set the price and order type depending on the position type
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type=ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type=ORDER_TYPE_BUY;
           }
         //---------------------------------------------------------------------
         //Close position
         CountTimes=0;
         while(SymbolInfoInteger(SymbolTrade,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL)
           {
            CountTimes++;
            //---Send the request
            CloseOrderTicket=OrderSend(request,result);
            //---
            if(CloseOrderTicket>0)
              {
               if(SoundAlert==true)
                  PlaySound(SoundAtClose);
               if(PrintOperations==true)
                  Print("Close: ",SymbolTrade," ",TypeOfOrderStr,".");
               break;
              }
            else
              {
               Print("Expert get an error: ",GetLastError());
              }
            //---
            Sleep(100);
            //---
            if(CountTimes>3)
              {
               Print("Failed close Order: ",TypeOfOrder);
               break;
              }
           }
         //---
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Current results
//============================================================================================================================================================================================================================//
void CountCurrentOrders()
  {
//---------------------------------------------------------------------
//Reset variables
   SumOrders=0;
   BuyOrders=0;
   SellOrders=0;
   BuyProfits=0;
   SellProfits=0;
   PriceOpenLastBuy=0;
   PriceOpenLastSell=0;
   TypeLastOpenOrder=0;
   TypeFirstOpenOrder=0;
   TotalLotsBuy=0;
   TotalLotsSell=0;
   LotLastBuy=0;
   LotLastSell=0;
   TicketFirstBuy=-1;
   TicketFirstSell=-1;
   LotFirstBuy=0;
   LotFirstSell=0;
   BuyPips=0;
   SellPips=0;
//---------------------------------------------------------------------
//Start count
   if(PositionsTotal()>0)
     {
      for(i=0; i<PositionsTotal(); i++)
        {
         if(PositionGetTicket(i))
           {
            if((PositionGetInteger(POSITION_MAGIC)==OrdersID)&&(PositionGetString(POSITION_SYMBOL)==SymbolTrade))
              {
               SumOrders++;
               //---Buy
               if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_BUY)
                 {
                  if(TicketFirstBuy==-1)
                     TicketFirstBuy=PositionGetInteger(POSITION_TICKET);
                  if(TypeFirstOpenOrder==0)
                     TypeFirstOpenOrder=1;
                  if(LotFirstBuy==0)
                     LotFirstBuy=PositionGetDouble(POSITION_VOLUME);
                  BuyProfits+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                  PriceOpenLastBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                  TotalLotsBuy+=PositionGetDouble(POSITION_VOLUME);
                  LotLastBuy=PositionGetDouble(POSITION_VOLUME);
                  TypeLastOpenOrder=1;
                  BuyOrders++;
                  BuyPips+=(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN))/DigitPoints;
                 }
               //---Sell
               if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==(ENUM_POSITION_TYPE)ORDER_TYPE_SELL)
                 {
                  if(TicketFirstSell==-1)
                     TicketFirstSell=PositionGetInteger(POSITION_TICKET);
                  if(TypeFirstOpenOrder==0)
                     TypeFirstOpenOrder=-1;
                  if(LotFirstSell==0)
                     LotFirstSell=PositionGetDouble(POSITION_VOLUME);
                  SellProfits+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
                  PriceOpenLastSell=PositionGetDouble(POSITION_PRICE_OPEN);
                  TotalLotsSell+=PositionGetDouble(POSITION_VOLUME);
                  LotLastSell=PositionGetDouble(POSITION_VOLUME);
                  TypeLastOpenOrder=-1;
                  SellOrders++;
                  SellPips+=(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(SymbolTrade,SYMBOL_ASK))/DigitPoints;
                 }
              }
           }
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//History results
//============================================================================================================================================================================================================================//
void CountHistoryOrders()
  {
//---------------------------------------------------------------------
//Set variables
   ulong Deal_Ticket;
   ulong Order_Ticket;
//---------------------------------------------------------------------
//Request the history of deals in the specified period
   HistorySelect(0,TimeCurrent());
//---------------------------------------------------------------------
   if(LastHistoryDeals==HistoryDealsTotal())
      return;
//---------------------------------------------------------------------
//Reset value
   TotalHistoryOrders=0;
   TotalHistoryProfitLoss=0;
//---------------------------------------------------------------------
//Start count
   if(HistoryDealsTotal()>0)
     {
      for(i=0; i<HistoryDealsTotal(); i++)
        {
         Deal_Ticket=HistoryDealGetTicket(i);
         Order_Ticket=HistoryDealGetInteger(Deal_Ticket,DEAL_ORDER);
         //---
         if((HistoryDealGetInteger(Deal_Ticket,DEAL_MAGIC)==OrdersID)&&(HistoryDealGetString(Deal_Ticket,DEAL_SYMBOL)==SymbolTrade))
           {
            TotalHistoryProfitLoss+=HistoryDealGetDouble(Deal_Ticket,DEAL_PROFIT)+HistoryDealGetDouble(Deal_Ticket,DEAL_COMMISSION)+HistoryDealGetDouble(Deal_Ticket,DEAL_SWAP);
            if(HistoryDealGetInteger(Deal_Ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
               TotalHistoryOrders++;//Get deals out
           }
        }
     }
//---------------------------------------------------------------------
   LastHistoryDeals=HistoryDealsTotal();
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Lot size
//============================================================================================================================================================================================================================//
double CalcLots(int TypeOfOrder)
  {
//---------------------------------------------------------------------
//Set variables
   double LotSize=0;
   double FinalLotSize=0;
//---------------------------------------------------------------------
//Calculate lot size
   if(AutoLotSize==true)
      LotSize=(AccountInfoDouble(ACCOUNT_BALANCE)*RiskFactor)/100000;
   if(AutoLotSize==false)
      LotSize=ManualLotSize;
//---------------------------------------------------------------------
//Statical lot
   if(TypeOfLotProgress==0)
     {
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(BuyOrders==0)
            FinalLotSize=LotSize;
         if(BuyOrders>=1)
            FinalLotSize=LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(SellOrders==0)
            FinalLotSize=LotSize;
         if(SellOrders>=1)
            FinalLotSize=LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Geometrical lot
   if(TypeOfLotProgress==1)
     {
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(BuyOrders==0)
            FinalLotSize=LotSize;
         if(BuyOrders==1)
            FinalLotSize=LotLastBuy*2;
         if(BuyOrders>=2)
            FinalLotSize=LotLastBuy+LotFirstBuy;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(SellOrders==0)
            FinalLotSize=LotSize;
         if(SellOrders==1)
            FinalLotSize=LotLastSell*2;
         if(SellOrders>=2)
            FinalLotSize=LotLastSell+LotFirstSell;
        }
     }
//---------------------------------------------------------------------
//Exponetial lot
   if(TypeOfLotProgress==2)
     {
      if(TypeOfOrder==ORDER_TYPE_BUY)
        {
         if(BuyOrders==0)
            FinalLotSize=LotSize;
         if(BuyOrders>=1)
            FinalLotSize=LotLastBuy*2;
        }
      //---
      if(TypeOfOrder==ORDER_TYPE_SELL)
        {
         if(SellOrders==0)
            FinalLotSize=LotSize;
         if(SellOrders>=1)
            FinalLotSize=LotLastSell*2;
        }
     }
//---------------------------------------------------------------------
//Set hedge lot size
   if(OpenHedgeOrder==true)
     {
      if(TypeOfOrder==ORDER_TYPE_BUY)
         FinalLotSize=(TotalLotsSell-TotalLotsBuy)*MuliplierHedgeLot;
      if(TypeOfOrder==ORDER_TYPE_SELL)
         FinalLotSize=(TotalLotsBuy-TotalLotsSell)*MuliplierHedgeLot;
     }
//---------------------------------------------------------------------
//Set maximum multiplier
   if(MaxMultiplierLot>0)
     {
      if((TypeOfOrder==ORDER_TYPE_BUY)&&(FinalLotSize>LotFirstBuy*MaxMultiplierLot)&&(BuyOrders>0))
         FinalLotSize=LotFirstBuy*MaxMultiplierLot;
      if((TypeOfOrder==ORDER_TYPE_SELL)&&(FinalLotSize>LotFirstSell*MaxMultiplierLot)&&(SellOrders>0))
         FinalLotSize=LotFirstSell*MaxMultiplierLot;
     }
//---------------------------------------------------------------------
//Check limit of lot size
   if(SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)>0)
     {
      if((TypeOfOrder==ORDER_TYPE_BUY)&&(TotalLotsBuy+FinalLotSize>SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)))
         return(0);
      if((TypeOfOrder==ORDER_TYPE_SELL)&&(TotalLotsSell+FinalLotSize>SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_LIMIT)))
         return(0);
     }
//---------------------------------------------------------------------
//Return final lot size
   return(MathMin(MathMax((MathRound(FinalLotSize/SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_STEP)),SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MIN)),SymbolInfoDouble(SymbolTrade,SYMBOL_VOLUME_MAX)));
//---------------------------------------------------------------------
  }
//===============================================================================================================================================================================================================================//
//Draw objects
//===============================================================================================================================================================================================================================//
void DrawObjects(string StringName, color ImageColor, int TypeBorder, bool InBackGround, int Xposition, int Yposition, int Xsize, int Ysize)
  {
//---------------------------------------------------------------------
   ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
   ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
   ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
   ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
   ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,ImageColor);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,TypeBorder);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,clrBlack);
   ObjectSetInteger(0,StringName,OBJPROP_BACK,InBackGround);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
//---------------------------------------------------------------------
  }
//===============================================================================================================================================================================================================================//
//Draw Text
//===============================================================================================================================================================================================================================//
void DisplayText(string StringName, string Image, int FontSize, string TypeImage, color FontColor, int Xposition, int Yposition)
  {
//---------------------------------------------------------------------
   ObjectCreate(0,StringName,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,StringName,OBJPROP_CORNER,0);
   ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
   ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
   ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,StringName,OBJPROP_COLOR,FontColor);
   ObjectSetInteger(0,StringName,OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(0,StringName,OBJPROP_TEXT,Image);
   ObjectSetString(0,StringName,OBJPROP_FONT,TypeImage);
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Comment in chart
//============================================================================================================================================================================================================================//
void CommentScreen()
  {
//---------------------------------------------------------------------
//Set variables
   string MMstring="";
   string StringSpread1="";
   string StringSpread2="";
   string MoneyManagementStr="";
   string BuyOrdersStr="";
   string SellOrdersStr="";
   string HistoryResStr="";
   string MaxSpreadStr;
   double BaseLot=0;
   double ShowMaxDD=0;
   double ShowMinFreeMargin=0;
   double AccountMarginLevel=0;
//---------------------------------------------------------------------
//String money management
   if(AutoLotSize==true)
     {
      MMstring="Auto";
      BaseLot=(AccountInfoDouble(ACCOUNT_BALANCE)*RiskFactor)/100000;
     }
   if(AutoLotSize==false)
     {
      MMstring="Manual";
      BaseLot=ManualLotSize;
     }
//---------------------------------------------------------------------
//String spread
   if(MaxSpread==0)
     {
      MaxSpreadStr="None";
      StringSpread1="EA NOT CHECK SPREAD.  Expert running...";
     }
//---
   if((Spread<=MaxSpread)&&(MaxSpread>0))
      StringSpread1="Acceptable Spread.  Expert is running";
   if((Spread>MaxSpread)&&(MaxSpread>0))
      StringSpread1="Unacceptable Spread. EA stop running";
   if(MaxSpread!=0)
      MaxSpreadStr=DoubleToString(MaxSpread,2);
//---------------------------------------------------------------------
//Strings
   StringSpread2="Max Spread: "+MaxSpreadStr+" || Current Spread: "+DoubleToString(Spread,2);
   MoneyManagementStr="Money Management: "+MMstring+" || Lot Size: "+DoubleToString(BaseLot,2);
   BuyOrdersStr="Buy Orders: "+IntegerToString(BuyOrders)+" || Buy P/L: "+DoubleToString(BuyProfits,2)+" || Buy Lots: "+DoubleToString(TotalLotsBuy,2);
   SellOrdersStr="Sell Orders: "+IntegerToString(SellOrders)+" || Sell P/L: "+DoubleToString(SellProfits,2)+" || Sell Lots: "+DoubleToString(TotalLotsSell,2);
   HistoryResStr="History Orders: "+DoubleToString(TotalHistoryOrders,0)+" || History Results: "+DoubleToString(TotalHistoryProfitLoss,2);
//---------------------------------------------------------------------
//Show hedge info
   if(PlaceHedgeOrder==true)
     {
      if(UnderHedgePair==true)
        {
         if(ObjectFind(0,"HedgeCom")==-1)
            DisplayText("HedgeCom","Expert works under hedge mode!",12,"Arial Black",clrKhaki,4,190);
        }
      else
        {
         if(ObjectFind(0,"HedgeCom")>-1)
            ObjectDelete(0,"HedgeCom");
        }
     }
//---------------------------------------------------------------------
//Lines on chart
   if(ObjectFind(0,"Com1")==-1)
      DisplayText("Com1",StringSubstr(ExpertName,0,16)+"-2022 by Pannik ®",11,"Arial Black",ColorExpertName,5,16);
   if(ObjectFind(0,"Com2")==-1)
      DisplayText("Com2","___________________________________________",10,"Arial Black",ColorOffLines,5,22);
   if(ObjectFind(0,"Com3")==-1)
      DisplayText("Com3","___________________________________________",10,"Arial Black",ColorOffLines,5,60);
   if(ObjectFind(0,"Com5")==-1)
      DisplayText("Com5","___________________________________________",10,"Arial Black",ColorOffLines,5,84);
   if(ObjectFind(0,"Com6")==-1)
      DisplayText("Com6","___________________________________________",10,"Arial Black",ColorOffLines,5,126);

//---------------------------------------------------------------------
//Comment on chart
   if(ObjectFind(0,"Com7")==-1)
      DisplayText("Com7",StringSpread1,10,"Arial",ColorSpreadInfo,4,40);
//---
   if(ObjectFind(0,"Com8")==-1)
      ObjectDelete(0,"Com8");
   DisplayText("Com8",StringSpread2,10,"Arial",ColorSpreadInfo,4,56);
//---
   if(ObjectFind(0,"Com9")>-1)
      ObjectDelete(0,"Com9");
   DisplayText("Com9",MoneyManagementStr,10,"Arial",ColorMoneyManagement,4,78);
//---
   if(ObjectFind(0,"Com10")>-1)
      ObjectDelete(0,"Com10");
   DisplayText("Com10",BuyOrdersStr,10,"Arial",ColorCurrentOrders,4,102);
//---
   if(ObjectFind(0,"Com11")>-1)
      ObjectDelete(0,"Com11");
   DisplayText("Com11",SellOrdersStr,10,"Arial",ColorCurrentOrders,4,120);
//---
   if(ObjectFind(0,"Com12")>-1)
      ObjectDelete(0,"Com12");
   DisplayText("Com12","          H I S T O R Y    R E S U L T S",10,"Arial",ColorHistoryOrders,4,144);
//---
   if(ObjectFind(0,"Com13")>-1)
      ObjectDelete(0,"Com13");
   DisplayText("Com13",HistoryResStr,10,"Arial",ColorHistoryOrders,4,160);
//---------------------------------------------------------------------
//Print
   /*if(SumOrders>0)
     {
      MaxDD=MathMax(((AccountInfoDouble(ACCOUNT_BALANCE)-AccountInfoDouble(ACCOUNT_EQUITY))*100)/AccountInfoDouble(ACCOUNT_BALANCE),MaxDD);
      MaxTotalOrders=MathMax(MaxTotalOrders,BuyOrders+SellOrders);
      MaxTotalLots=MathMax(MaxTotalLots,TotalLotsBuy+TotalLotsSell);
     }
   if(MaxDD!=-9999999999)
      ShowMaxDD=MaxDD;
//---
   AccountMarginLevel=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(AccountMarginLevel!=0)
      MinFreeMargin=MathMin(MinFreeMargin,AccountMarginLevel);
   if(MinFreeMargin!=999999999999999)
      ShowMinFreeMargin=MinFreeMargin;
//---
   if(iTime(SymbolTrade,PERIOD_D1,0)!=TimeHour)
     {
      Print("LowerFreeMargin: ",DoubleToString(ShowMinFreeMargin,2),"% || FreeMargin: ",DoubleToString(AccountMarginLevel,2),"% || MaxLots: ",DoubleToString(MaxTotalLots,2)," || Lots: ",DoubleToString(TotalLotsBuy+TotalLotsSell,2)," || MaxOrders: ",IntegerToString(MaxTotalOrders)," || Orders: ",IntegerToString(BuyOrders+SellOrders)," || MaxFloating: -",DoubleToString(ShowMaxDD,2),"% || Floating: ",DoubleToString(BuyProfits+SellProfits,2));
      TimeHour=iTime(SymbolTrade,PERIOD_D1,0);
     }
//---------------------------------------------------------------------
//Comment in chart
   Comment("=============================="+
           "\n BuildYourGridEA | 2021 by Pannik ®"
           "\n =============================="+
           "\n "+StringSpread1+
           "\n Max Spread: "+MaxSpreadStr+" || Current Spread: "+DoubleToString(Spread,2)+
           "\n =============================="+
           "\n Money Management: "+MMstring+" || Lot: "+DoubleToString(BaseLot,2)+
           "\n =============================="+
           "\n Buy Orders: "+IntegerToString(BuyOrders)+" / "+DoubleToString(BuyProfits,2)+"   (Lots Buy: "+DoubleToString(TotalLotsBuy,2)+")"+
           "\n Sell Orders: "+IntegerToString(SellOrders)+" / "+DoubleToString(SellProfits,2)+"   (Lots Sell: "+DoubleToString(TotalLotsSell,2)+")"+
           "\n =============================="+
           "\n        H I S T O R Y    R E S U L T S"+
           "\n Total Orders: "+DoubleToString(TotalHistoryOrders,0)+" || Total PnL: "+DoubleToString(TotalHistoryProfitLoss,2)+
           "\n ==============================");*/
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//Orders signals
//============================================================================================================================================================================================================================//
void GetSignals()
  {
//---------------------------------------------------------------------
//Set variables
   double PipsForNextBuyOrder=0;
   double PipsForNextSellOrder=0;
//---------------------------------------------------------------------
//Reset variables
   OpenBuy=false;
   OpenSell=false;
   CloseOrdersInProfit=false;
   CloseOrdersInLoss=false;
   OpenHedgeOrder=false;
//---------------------------------------------------------------------
//Reset and set hedged switch
   if(BuyOrders+SellOrders==0)
      UnderHedgePair=false;
   if((BuyOrders>1)&&(SellOrders>1)&&(TotalLotsBuy==TotalLotsSell))
      UnderHedgePair=true;
//---------------------------------------------------------------------
//Check close orders in profit
   if(BuyOrders+SellOrders>0)
     {
      if(((BuyPips+SellPips>=PipsCloseInProfit)&&(TypeTargetClose==0))||((BuyProfits+SellProfits>=CurrCloseInProfit)&&(TypeTargetClose==1)))
        {
         CloseOrdersInProfit=true;
         return;
        }
      //---------------------------------------------------------------------
      //Check close ordres in loss
      if((BuyPips+SellPips<=-PipsForCloseInLoss)&&(ModeCloseInLoss>0))
        {
         CloseOrdersInLoss=true;
         return;
        }
      //---------------------------------------------------------------------
      //Check for hedge order
      if((PlaceHedgeOrder==true)&&(LevelLossForHedge>0))
        {
         if(((MathAbs(BuyProfits+SellProfits)*100)/AccountInfoDouble(ACCOUNT_BALANCE)>=LevelLossForHedge)&&(BuyProfits+SellProfits<0)&&(UnderHedgePair==false))
           {
            UnderHedgePair=true;
            OpenHedgeOrder=true;
            return;
           }
        }
     }
//---------------------------------------------------------------------
//Open first orders
   if(((BuyOrders==0)&&((TypeOrdersPlace==0)||(TypeOrdersPlace==1)))||((SellOrders==0)&&((TypeOrdersPlace==0)||(TypeOrdersPlace==2))))
     {
      if((BuyOrders==0)&&((TypeOrdersPlace==0)||(TypeOrdersPlace==1)))
         OpenBuy=true;
      if((SellOrders==0)&&((TypeOrdersPlace==0)||(TypeOrdersPlace==2)))
         OpenSell=true;
      return;
     }
//---------------------------------------------------------------------
//Set step
   if(TypeOfStepProgress==0)//Statickal
     {
      PipsForNextBuyOrder=PipsForNextOrder;
      PipsForNextSellOrder=PipsForNextOrder;
     }
//---
   if(TypeOfStepProgress==1)//Geometrical
     {
      PipsForNextBuyOrder=PipsForNextOrder*BuyOrders;
      PipsForNextSellOrder=PipsForNextOrder*SellOrders;
     }
//---
   if(TypeOfStepProgress==1)//Exponential
     {
      PipsForNextBuyOrder=PipsForNextOrder*MathMax(1,MathPow(2,BuyOrders-1));
      PipsForNextSellOrder=PipsForNextOrder*MathMax(1,MathPow(2,SellOrders-1));
     }
//---------------------------------------------------------------------
//Open next orders
   if(((BuyOrders>0)||(TypeOrdersPlace==2))&&((SellOrders>0)||(TypeOrdersPlace==1)))
     {
      //---According trend
      if(TypeOfNextOrders==0)
        {
         if(((TypeOrdersPlace==0)||(TypeOrdersPlace==1))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)>=PriceOpenLastBuy+(PipsForNextBuyOrder*DigitPoints)))
            OpenBuy=true;
         if(((TypeOrdersPlace==0)||(TypeOrdersPlace==2))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)<=PriceOpenLastSell-(PipsForNextSellOrder*DigitPoints)))
            OpenSell=true;
         return;
        }
      //---Contrary trend
      if(TypeOfNextOrders==1)
        {
         if(((TypeOrdersPlace==0)||(TypeOrdersPlace==1))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_ASK)<=PriceOpenLastBuy-(PipsForNextBuyOrder*DigitPoints)))
            OpenBuy=true;
         if(((TypeOrdersPlace==0)||(TypeOrdersPlace==2))&&(SymbolInfoDouble(SymbolTrade,SYMBOL_BID)>=PriceOpenLastSell+(PipsForNextSellOrder*DigitPoints)))
            OpenSell=true;
         return;
        }
     }
//---------------------------------------------------------------------
  }
//============================================================================================================================================================================================================================//
//End code
//============================================================================================================================================================================================================================//
