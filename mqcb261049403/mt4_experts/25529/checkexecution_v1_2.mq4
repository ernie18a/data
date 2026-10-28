//====================================================================================================================================================//
// email: nikolaospantzos@gmail.com                                                                                                   CheckExecution  //
//====================================================================================================================================================//
#property copyright   "Copyright 2014-2017, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.2"
#property description "This Expert Advisor is a tool to check broker for spread and execution."
#property description "\nThe pending order to send expert, expire after 15 minutes and deleted."
#property description "\nThe market order to send expert, have stop loss to modify it."
#property description "\nExpert use last ticks (accepted from 1 to 500), to count average spread and execution."
//#property icon        "\\Images\\CheckExecutionImage.ico";
#property strict
//====================================================================================================================================================//
enum Ordr{Use_Pending_Order,Use_Market_Order};
//====================================================================================================================================================//
extern string EASetting        = "||======== EA Setting ========||";
extern int    OrdersID         = 1234512345;
extern double ManualLotSize    = 0.01;
extern Ordr   TypeOfOrderUse   = Use_Pending_Order;
extern int    TimesModifyOrder = 30;
//====================================================================================================================================================//
string ExpertComment;
string EAname;
int TicketBuy=-1;
int TotalOrders;
int CntBuyStop;
int MultiplierPoint;
int CountTickSpreadPair=0;
int CountTimesModify=0;
int CountTickSpread=0;
int TimesModify=0;
int i;
int Count;
int CntTick=0;
int TicksGet=0;
int Slippage=3;
double ArraySpreadPair[500];
double AvgSpread;
double AvgExecution;
double SpreadPoints;
double DistanceBuy=100;
double DigitsPoints;
double LotSize;
datetime ArrayExecution[500];
datetime ModifyDelay=0;
datetime TimeToSend=0;
datetime Expire=0;
bool ModifyTicket;
string OrdrCom;
string BackgroundName;
//====================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//Reset
   TicketBuy=-1;
   TicksGet=0;
//---------------------------------------------------------------------
//Background
   BackgroundName="Background-"+WindowExpertName();
   if(ObjectFind(BackgroundName)==-1)
     {
      ObjectCreate(BackgroundName,OBJ_LABEL,0,0,0);
      ObjectSet(BackgroundName,OBJPROP_CORNER,0);
      ObjectSet(BackgroundName,OBJPROP_BACK,FALSE);
      ObjectSet(BackgroundName,OBJPROP_YDISTANCE,14);
      ObjectSet(BackgroundName,OBJPROP_XDISTANCE,0);
      ObjectSetText(BackgroundName,"g",120,"Webdings",clrTeal);
     }
//---------------------------------------------------------------------
//Orders' comment
   if(TypeOfOrderUse==0) OrdrCom="Pending Order Check";
   if(TypeOfOrderUse==1) OrdrCom="Market Order Check";
//---------------------------------------------------------------------
//Symbol suffix and info
   EAname=WindowExpertName();
   ExpertComment=EAname;
   ArrayInitialize(ArraySpreadPair,0);
   ArrayInitialize(ArrayExecution,0);
//---------------------------------------------------------------------
//Confirm points
   MultiplierPoint=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==5) || (MarketInfo(Symbol(),MODE_DIGITS)==3)) MultiplierPoint=10;
   DigitsPoints=Point*MultiplierPoint;
   Slippage*=MultiplierPoint;
   if(TimesModifyOrder<1) TimesModifyOrder=1;
   if(TimesModifyOrder>500) TimesModifyOrder=500;
//---------------------------------------------------------------------
   if((!IsTesting()) || (!IsVisualMode())) OnTick();
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
   ObjectDelete(BackgroundName);
   Comment("");
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
   TotalOrders=0;
   CntBuyStop=0;
//---------------------------------------------------------------------
//Check spread and execution broker
   Expire=TimeCurrent()+(15*60);
//---------------------------------------------------------------------
//Get info of opened orders
   if(OrdersTotal()>0)
     {
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS))
           {
            if((OrderMagicNumber()==OrdersID) && (OrderSymbol()==Symbol())) TotalOrders++;
           }
        }
     }
//---------------------------------------------------------------------
//Get spread
   SpreadPoints=MarketInfo(Symbol(),MODE_SPREAD)/MultiplierPoint;
   if(TimesModifyOrder-TicksGet>0) GetAvrgSpread();
//---------------------------------------------------------------------
//Count lot size
   LotSize=MathMin(MathMax((MathRound(ManualLotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT));
//---------------------------------------------------------------------
//Comment in chart
   ScreenComment();
//---------------------------------------------------------------------
//Check margin
   if(AccountFreeMargin()-(AccountFreeMargin()-AccountFreeMarginCheck(Symbol(),OP_BUY,LotSize))<=0)
     {
      OrdrCom="Free Margin Is Too Low";
      Print("Free margin is too low!!!");
      return;
     }
//---------------------------------------------------------------------
//Send order to check execution
   if(TotalOrders==0)
     {
      if((TicketBuy<0)&&(TypeOfOrderUse==0)) TicketBuy=OrderSend(Symbol(),OP_BUYSTOP,LotSize,NormalizeDouble(Ask+DistanceBuy*DigitsPoints,Digits),Slippage,0,0,ExpertComment,OrdersID,Expire,clrBlue);
      if((TicketBuy<0)&&(TypeOfOrderUse==1)) TicketBuy=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,NormalizeDouble(Ask-100*DigitsPoints,Digits),0,ExpertComment,OrdersID,Expire,clrBlue);
     }
//---
   if(TotalOrders>0)
     {
      TimeToSend=GetTickCount();
      ProcessCurrentOrders();
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ProcessCurrentOrders()
  {
//---------------------------------------------------------------------
   ModifyTicket=false;
   ModifyDelay=0;
//---------------------------------------------------------------------
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      RefreshRates();
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderMagicNumber()==OrdersID) && (OrderSymbol()==Symbol()))
           {
            //---------------------------------------------------------------------
            //Modify market order
            if((OrderType()==OP_BUY) && (NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(Ask-100*DigitsPoints,Digits)))
              {
               ModifyTicket=0;
               ModifyTicket=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-100*DigitsPoints,Digits),0,Expire,clrBlue);
               if(ModifyTicket>0) ModifyDelay=GetTickCount()-TimeToSend;
              }
            //---------------------------------------------------------------------
            //Modify pending order
            if((OrderType()==OP_BUYSTOP) && (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(Ask+DistanceBuy*DigitsPoints,Digits)))
              {
               ModifyTicket=0;
               ModifyTicket=OrderModify(OrderTicket(),NormalizeDouble(Ask+DistanceBuy*DigitsPoints,Digits),0,0,Expire,clrBlue);
               if(ModifyTicket>0) ModifyDelay=GetTickCount()-TimeToSend;
              }
            //---
           }
        }
     }
//---------------------------------------------------------------------
//Count average execution
   if(ModifyDelay>0)
     {
      if(TicksGet<TimesModifyOrder)
        {
         TicksGet++;
         CountAvrgExecution();
        }
     }
//---------------------------------------------------------------------
//Delete pending order
   if((TicksGet>=TimesModifyOrder) && (TypeOfOrderUse==0))
     {
      TimeToSend=GetTickCount();
      DeletePendingOrder();
     }
//---------------------------------------------------------------------
//Close market order
   if((TicksGet>=TimesModifyOrder) && (TypeOfOrderUse==1))
     {
      TimeToSend=GetTickCount();
      CloseMarketOrder();
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CloseMarketOrder()
  {
//---------------------------------------------------------------------
   bool CloseCheckOrder=false;
   for(int iPos=0; iPos<OrdersTotal(); iPos++)
     {
      if(OrderSelect(iPos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==OrdersID)
           {
            if(OrderType()==OP_BUY) CloseCheckOrder=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrRed);
            if(CloseCheckOrder>0) ModifyDelay=GetTickCount()-TimeToSend;
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void DeletePendingOrder()
  {
//---------------------------------------------------------------------
   bool DeleteCheckOrder=false;
   for(int iPos=0; iPos<OrdersTotal(); iPos++)
     {
      if(OrderSelect(iPos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==OrdersID)
           {
            if(OrderType()==OP_BUYSTOP) DeleteCheckOrder=OrderDelete(OrderTicket());
            if(DeleteCheckOrder>0) ModifyDelay=GetTickCount()-TimeToSend;
           }
        }
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void GetAvrgSpread()
  {
//---------------------------------------------------------------------
   double SumSpread=0;
   int LoopCount=TimesModifyOrder-1;
   AvgSpread=0;
//---------------------------------------------------------------------
   if(CountTickSpreadPair<TimesModifyOrder) CountTickSpreadPair++;
   CountTickSpread=CountTickSpreadPair;
   ArrayCopy(ArraySpreadPair,ArraySpreadPair,0,1,TimesModifyOrder-1);
   ArraySpreadPair[TimesModifyOrder-1]=SpreadPoints;
//---------------------------------------------------------------------
   for(Count=0; Count<CountTickSpreadPair; Count++)
     {
      SumSpread+=ArraySpreadPair[LoopCount];
      LoopCount--;
     }
//---------------------------------------------------------------------
   if(CountTickSpread>0) AvgSpread=NormalizeDouble(SumSpread/CountTickSpread,2);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CountAvrgExecution()
  {
//---------------------------------------------------------------------
   datetime SumExecution=0;
   int LoopCount=TimesModifyOrder-1;
   AvgExecution=0;
//---------------------------------------------------------------------
   if(CountTimesModify<TimesModifyOrder) CountTimesModify++;
   TimesModify=CountTimesModify;
//---------------------------------------------------------------------
   ArrayCopy(ArrayExecution,ArrayExecution,0,1,TimesModifyOrder-1);
   ArrayExecution[TimesModifyOrder-1]=ModifyDelay;
//---------------------------------------------------------------------
   for(Count=0; Count<CountTimesModify; Count++)
     {
      SumExecution+=ArrayExecution[LoopCount];
      LoopCount--;
     }
//---------------------------------------------------------------------
   if(TimesModify>0) AvgExecution=NormalizeDouble(SumExecution/TimesModify,2);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ScreenComment()
  {
//---------------------------------------------------------------------
//Uncompleted
   if(TicksGet<TimesModifyOrder)
     {
      Comment("---------------------------------------------------"
              +"\n          "+EAname
              +"\n"+StringSubstr(Symbol(),0,6)+" || "+OrdrCom
              +"\n---------------------------------------------------"
              +"\nOrders ID         :  "+DoubleToStr(OrdersID,0)
              +"\nLot Size            :  "+DoubleToStr(LotSize,2)
              +"\nTicks Use         :  "+DoubleToStr(TimesModifyOrder,0)
              +"\n---------------------------------------------------"
              +"\nEXPERT CHECK BROKER SERVER"
              +"\nFOR SPREAD AND EXECUTION"
              +"\nPLEASE WAIT FOR ("+DoubleToStr(TimesModifyOrder-TicksGet,0)+") TICKS"
              +"\nTO COMPLETED OPERATION"
              +"\n---------------------------------------------------");
     }
//---------------------------------------------------------------------
//Completed
   if(TicksGet==TimesModifyOrder)
     {
      Comment("---------------------------------------------------"
              +"\n          "+EAname
              +"\n"+StringSubstr(Symbol(),0,6)+" || "+OrdrCom
              +"\n---------------------------------------------------"
              +"\nOrders ID         :  "+DoubleToStr(OrdersID,0)
              +"\nLot Size            :  "+DoubleToStr(LotSize,2)
              +"\nTicks Use         :  "+DoubleToStr(TimesModifyOrder,0)
              +"\n---------------------------------------------------"
              +"\nCHECK WAS COMPLETED"
              +"\nRESULTS SPREAD / EXECUTION"
              +"\nAvrg Spread    : "+DoubleToStr(AvgSpread,2)+" pips"
              +"\nAvrg Execution : "+DoubleToStr(AvgExecution,0)+" ms"
              +"\n---------------------------------------------------");
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
