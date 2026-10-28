//====================================================================================================================================================//
#property copyright   "Copyright 2016-2020, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.5"
#property description "The expert can manage up 100 orders simultaneously."
//#property icon        "\\Images\\VTPSLTSL_Logo.ico";
#property strict
//====================================================================================================================================================//
enum Ordrs {Chart_Symbol_Orders,Account_All_Orders};
//====================================================================================================================================================//
#define MaximumOrders 100
//====================================================================================================================================================//
extern Ordrs  OrdersManage     = Account_All_Orders;//Symbol Of Orders Manage
extern double Takeprofit       = 20.0;//Take Profit Pips
extern double Stoploss         = 20.0;//Stop Loss Pips
extern double TrailingStop     = 10.0;//Trailing Stop Pips
extern double TrailingStep     = 1.0;//Trailing Step Pips
extern double TrailingAfter    = 5.0;//Start Trailing After Profit
extern string MagicNumberInfo1 = ">0 = manage identifier orders";//Set Orders Manage Info
extern string MagicNumberInfo2 = "0  = manage all orders";//Set Orders Manage Info
extern string MagicNumberInfo3 = "-1 = manage only manual orders";//Set Orders Manage Info
extern int    MagicNumber      = 0;//Set Orders Manage Magic Number
extern bool   ShowLines        = true;//Show Lines Of Levels
extern bool   SoundAlert       = true;//Play Sound Each Operation
//====================================================================================================================================================//
string SoundModify="tick.wav";
string SoundClose="alert2.wav";
string BackgroundName;
double LastTrailingBuy[MaximumOrders];
double LastTrailingSell[MaximumOrders];
int TicketBuy[MaximumOrders];
int TicketSell[MaximumOrders];
int MultiplierPoint;
int Slippage=30;
long ChartColor;
string MagicStr;
string SoundsStr;
bool CallMain;
//====================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------
//Set timer
   EventSetMillisecondTimer(100);
//---------------------------------------------------------------------
//Set background
   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   BackgroundName="Background-"+WindowExpertName();
//---
   if(ObjectFind(BackgroundName)==-1)
      ChartBackground(BackgroundName,(color)ChartColor,BORDER_FLAT,FALSE,0,16,140,157);
//---------------------------------------------------------------------
//Confirm value
   if(MagicNumber<-1)
      MagicNumber=-1;
//---
   if(Stoploss<0)
      Stoploss=0;
//---
   if(Takeprofit<0)
      Takeprofit=0;
//---
   if(TrailingStop<0)
      TrailingStop=0;
//---
   if(TrailingStep<0)
      TrailingStep=0;
//---
   if(TrailingAfter<0)
      TrailingAfter=0;
//---------------------------------------------------------------------
//Broker 4 or 5 digits
   MultiplierPoint=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==3)||(MarketInfo(Symbol(),MODE_DIGITS)==5))
      MultiplierPoint=10;
   if((MarketInfo(Symbol(),MODE_DIGITS)==1)||(MarketInfo(Symbol(),MODE_DIGITS)==2))
      MultiplierPoint=10;
//---------------------------------------------------------------------
//External comment
   if(SoundAlert==true)
      SoundsStr="TRUE";
   else
      SoundsStr="FALSE";
   if(MagicNumber>0)
      MagicStr=DoubleToStr(MagicNumber,0);
   if(MagicNumber==0)
      MagicStr="All Orders";
   if(MagicNumber==-1)
      MagicStr="Manual Orders";
//---------------------------------------------------------------------
//Reset value
   ArrayInitialize(LastTrailingBuy,-999999);
   ArrayInitialize(LastTrailingSell,999999);
   ArrayInitialize(TicketBuy,-1);
   ArrayInitialize(TicketSell,-1);
//---------------------------------------------------------------------
//Show comments
   CommentsScreen();
//---------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------
//Clear chart
   for(int i=ObjectsTotal()-1; i>=0; i--)
      ObjectDelete(ObjectName(i));
   Comment("");
//---------------------------------------------------------------------
//Destroy timer
   EventKillTimer();
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnTick()
  {
//---------------------------------------------------------------------
//Reset value
   CallMain=false;
//---------------------------------------------------------------------
//Expert not enabled
   if((!IsExpertEnabled())&&(!IsTesting()))
     {
      Comment("==================",
              "\n\n    ",WindowExpertName(),
              "\n\n==================",
              "\n\n    Expert Not Enabled ! ! !",
              "\n\n    Please Turn On Expert",
              "\n\n\n\n==================");
      return;
     }
//---------------------------------------------------------------------
//Call main
   CallMain=true;
//---------------------------------------------------------------------
  }
//===============================================================================================================================================================================================================================================================//
void OnTimer()
  {
//---------------------------------------------------------------------
//Call main function
   if(CallMain==true)
      MainFunction();
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void MainFunction()
  {
//---------------------------------------------------------------------
   string SymbolOfOrders="";
   double OpenOrdersPrice=0;
   double OrdersSL=0;
   double OrdersTP=0;
   double PriceBid=0;
   double PriceAsk=0;
   double SymbolPoints=0;
   double TrailingBuy=0;
   double TrailingSell=0;
   bool CloseOrders=false;
   bool CopyForFirstTimeTicketBuy=false;
   bool CopyForFirstTimeTicketSell=false;
   int TypeOfOrders=-1;
   int SymbolDigits=0;
   int CountBuyOrders=0;
   int CountSellOrders=0;
   int OrderTicketNumber=0;
   int i,j;
//---------------------------------------------------------------------
//Delete objects
   for(i=ObjectsTotal()-1; i>=0; i--)
     {
      if(ObjectName(i)!=BackgroundName)
         ObjectDelete(ObjectName(i));
     }
//---------------------------------------------------------------------
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         //---Set orders' informations
         TypeOfOrders=OrderType();
         SymbolOfOrders=OrderSymbol();
         PriceAsk=MarketInfo(SymbolOfOrders,MODE_ASK);
         PriceBid=MarketInfo(SymbolOfOrders,MODE_BID);
         SymbolPoints= MarketInfo(SymbolOfOrders,MODE_POINT)*MultiplierPoint;
         SymbolDigits=(int)MarketInfo(SymbolOfOrders,MODE_DIGITS);
         OpenOrdersPrice=NormalizeDouble(OrderOpenPrice(),SymbolDigits);
         OrderTicketNumber=OrderTicket();
         //---Start manage orders
         if(((OrderMagicNumber()==MagicNumber)||(MagicNumber==0))||((OrderMagicNumber()==0)&&(MagicNumber==-1)))
           {
            //---Check type
            if(((SymbolOfOrders==Symbol())&&(OrdersManage==0))||(OrdersManage==1))
              {
               //---Start for buy orders
               if(TypeOfOrders==OP_BUY)
                 {
                  CountBuyOrders++;
                  //---Set levels
                  if(Takeprofit>0)
                     OrdersTP=OpenOrdersPrice+Takeprofit*SymbolPoints;
                  //---
                  if(Stoploss>0)
                     OrdersSL=OpenOrdersPrice-Stoploss*SymbolPoints;
                  //---
                  if(TrailingStop>0)
                    {
                     TrailingBuy=0;
                     for(j=0; j<MaximumOrders; j++)
                       {
                        if(TicketBuy[j]==OrderTicketNumber)
                          {
                           if((PriceBid-TrailingStop*SymbolPoints)-LastTrailingBuy[j]>TrailingStep*SymbolPoints)
                             {
                              if(SoundAlert==true)
                                 PlaySound(SoundModify);
                              LastTrailingBuy[j]=PriceBid-TrailingStop*SymbolPoints;
                             }
                           TrailingBuy=LastTrailingBuy[j];
                           break;
                          }
                        else
                          {
                           if(j==MaximumOrders-1)
                              CopyForFirstTimeTicketBuy=true;
                          }
                       }
                     //---
                     if(CopyForFirstTimeTicketBuy==true)
                       {
                        for(j=0; j<MaximumOrders; j++)
                          {
                           if((TrailingAfter==0)||(PriceBid-OpenOrdersPrice>=TrailingAfter*SymbolPoints))
                             {
                              if(TicketBuy[j]==-1)
                                {
                                 if(SoundAlert==true)
                                    PlaySound(SoundModify);
                                 TicketBuy[j]=OrderTicketNumber;
                                 LastTrailingBuy[j]=PriceBid-TrailingStop*SymbolPoints;
                                 TrailingBuy=LastTrailingBuy[j];
                                 CopyForFirstTimeTicketBuy=false;
                                 break;
                                }
                             }
                           else
                             {
                              CopyForFirstTimeTicketBuy=false;
                              break;
                             }
                          }
                       }
                     //---
                     if(TrailingBuy!=0)
                        OrdersSL=TrailingBuy;
                    }
                  //---Creat lines of levels
                  if((SymbolOfOrders==ChartSymbol())&&(ShowLines==true))
                    {
                     if(ObjectFind("Price Open Buy "+IntegerToString(OrderTicketNumber))==-1)
                        DrawLines("Price Open Buy "+IntegerToString(OrderTicketNumber),OpenOrdersPrice,clrYellow,1);
                     //---
                     if(OrdersSL>0)
                       {
                        if(ObjectFind("Stop Loss Buy "+IntegerToString(OrderTicketNumber))==-1)
                           DrawLines("Stop Loss Buy "+IntegerToString(OrderTicketNumber),OrdersSL,clrRed,1);
                       }
                     //---
                     if(OrdersTP>0)
                       {
                        if(ObjectFind("Take Profit Buy "+IntegerToString(OrderTicketNumber))==-1)
                           DrawLines("Take Profit Buy "+IntegerToString(OrderTicketNumber),OrdersTP,clrBlue,1);
                       }
                    }
                  //---Check stop loss and take profit
                  if(((OrdersSL>0)&&(PriceBid<=OrdersSL))||((OrdersTP>0)&&(PriceBid>=OrdersTP)))
                    {
                     if(SoundAlert==true)
                        PlaySound(SoundClose);
                     CloseOrders=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(PriceBid,SymbolDigits),Slippage,clrNONE);
                    }
                 }//End if(TypeOfOrders==OP_BUY)
               //---Start for sell orders
               if(TypeOfOrders==OP_SELL)
                 {
                  CountSellOrders++;
                  //---Set levels
                  if(Takeprofit>0)
                     OrdersTP=OpenOrdersPrice-Takeprofit*SymbolPoints;
                  //---
                  if(Stoploss>0)
                     OrdersSL=OpenOrdersPrice+Stoploss*SymbolPoints;
                  //---
                  if(TrailingStop>0)
                    {
                     TrailingSell=0;
                     for(j=0; j<MaximumOrders; j++)
                       {
                        if(TicketSell[j]==OrderTicketNumber)
                          {
                           if(LastTrailingSell[j]-(PriceAsk+TrailingStop*SymbolPoints)>TrailingStep*SymbolPoints)
                             {
                              if(SoundAlert==true)
                                 PlaySound(SoundModify);
                              LastTrailingSell[j]=PriceAsk+TrailingStop*SymbolPoints;
                             }
                           TrailingSell=LastTrailingSell[j];
                           break;
                          }
                        else
                          {
                           if(j==MaximumOrders-1)
                              CopyForFirstTimeTicketSell=true;
                          }
                       }
                     //---
                     if(CopyForFirstTimeTicketSell==true)
                       {
                        for(j=0; j<MaximumOrders; j++)
                          {
                           if((TrailingAfter==0)||(OpenOrdersPrice-PriceAsk>=TrailingAfter*SymbolPoints))
                             {
                              if(TicketSell[j]==-1)
                                {
                                 if(SoundAlert==true)
                                    PlaySound(SoundModify);
                                 TicketSell[j]=OrderTicketNumber;
                                 LastTrailingSell[j]=PriceAsk+TrailingStop*SymbolPoints;
                                 TrailingSell=LastTrailingSell[j];
                                 CopyForFirstTimeTicketSell=false;
                                 break;
                                }
                             }
                           else
                             {
                              CopyForFirstTimeTicketSell=false;
                              break;
                             }
                          }
                       }
                     //---
                     if(TrailingSell!=0)
                        OrdersSL=TrailingSell;
                    }
                  //---Creat lines of levels
                  if((SymbolOfOrders==ChartSymbol())&&(ShowLines==true))
                    {
                     if(ObjectFind("Price Open Sell "+IntegerToString(OrderTicketNumber))==-1)
                        DrawLines("Price Open Sell "+IntegerToString(OrderTicketNumber),OpenOrdersPrice,clrYellow,1);
                     //---
                     if(OrdersSL>0)
                       {
                        if(ObjectFind("Stop Loss Sell "+IntegerToString(OrderTicketNumber))==-1)
                           DrawLines("Stop Loss Sell "+IntegerToString(OrderTicketNumber),OrdersSL,clrRed,1);
                       }
                     //---
                     if(OrdersTP>0)
                       {
                        if(ObjectFind("Take Profit Sell "+IntegerToString(OrderTicketNumber))==-1)
                           DrawLines("Take Profit Sell "+IntegerToString(OrderTicketNumber),OrdersTP,clrBlue,1);
                       }
                    }
                  //---Check stop loss and take profit
                  if(((OrdersSL>0)&&(PriceAsk>=OrdersSL))||((OrdersTP>0)&&(PriceAsk<=OrdersTP)))
                    {
                     if(SoundAlert==true)
                        PlaySound(SoundClose);
                     CloseOrders=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(PriceAsk,SymbolDigits),Slippage,clrNONE);
                    }
                 }//End if(TypeOfOrders==OP_SELL)
              }
           }
        }
     }
//---------------------------------------------------------------------
//Reset value
   if(CountBuyOrders==0)
     {
      ArrayInitialize(LastTrailingBuy,-999999);
      ArrayInitialize(TicketBuy,-1);
     }
//---
   if(CountSellOrders==0)
     {
      ArrayInitialize(LastTrailingSell,999999);
      ArrayInitialize(TicketSell,-1);
     }
//---------------------------------------------------------------------
//Show comments
   CommentsScreen();
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void DrawLines(string Name,double Price,color clr,int Width)
  {
//---------------------------------------------------------------------
   if(ObjectFind(Name)==-1)
     {
      ObjectCreate(Name,OBJ_HLINE,0,0,Price,0,0,0,0);
      ObjectSet(Name,OBJPROP_COLOR,clr);
      ObjectSet(Name,OBJPROP_STYLE,2);
      ObjectSet(Name,OBJPROP_WIDTH,Width);
     }
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void ChartBackground(string StringName,color ImageColor,int TypeBorder,bool InBackGround,int Xposition,int Yposition,int Xsize,int Ysize)
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
//====================================================================================================================================================//
void CommentsScreen()
  {
//---------------------------------------------------------------------
   Comment("==================",
           "\n  ",WindowExpertName(),
           "\n  Ready To Manage Orders",
           "\n==================",
           "\n  Take Profit    : ",DoubleToStr(Takeprofit,2),
           "\n  Stop Loss      : ",DoubleToStr(Stoploss,2),
           "\n  Trailing SL     : ",DoubleToStr(TrailingStop,2),
           "\n  Trailing Step  : ",DoubleToStr(TrailingStep,2),
           "\n  Trailing After : ",DoubleToStr(TrailingAfter,2),
           "\n==================",
           "\n  Orders ID   : ",MagicStr,
           "\n  Sound Alert : ",SoundsStr,
           "\n==================");
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
