//+------------------------------------------------------------------+
//|                                                  Master_Info.mq4 |
//|                                                  Girard Matthieu |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Girard Matthieu"
#property link      "https://forge.mql5.io"
#property version   "1.08"

#import "user32.dll"
int      PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int      GetWindow(int hWnd,int uCmd);
int      GetParent(int hWnd);
#import
#property script_show_inputs
#property indicator_chart_window
#property indicator_buffers 17
#property strict

extern string           text1="Global Information";            //Description
extern bool             CurrencySymbolRight=True;              //is your currency symbol (€ $ Ł) at the Right?
extern double           LotSize=1;                             //your default Lot Size
extern string           MasterHide="H";                        //hide or show the tool
extern bool             IndicatorValue=true;                   //show indicator information
extern bool             ShowGrid=true;                         //show horizontal grid 
extern int              PipInterval=10;                        //default 10 interval for grid
extern int              ColorVariation=1;                      //1 to 8, smaller the grid color is close to the background color
extern string           MasterToolConf="O";                    //show the option tool
extern bool             ShowDailyOpen=false;                   //show DailyOpen 
extern bool             ShowPivot=false;                       //show Pivot 
extern bool             ShowPivotFibo=false;                   //show Pivot based on Fibonacci
extern bool             SLTPalert=false;                       //sound alert when TP or SL is close to be touch
extern int              SLTPalertPips=5;                       //pips before alert TP or SL
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum filename  // enumeration of sound filename
  {
   none,               //no sound
   pong,               //pong sound
   tone,               //tone sound
   spacial,            //spacial sound
   blop,               //blop sound
   startrek,           //startrek sound
   scan                //scan sound
  };
extern string           textc="";                              //====================================
extern string           text2="Support & Resistance Management Tool";  //Description
extern string           text3="==First Line";                    //Description
extern string           LineHorizontal="A";                    //Key to Create a SR Line (1)
extern color            LineResistcolor=clrDodgerBlue;         //Resistance Line Color (1)
extern color            LineSupportcolor=clrDarkOrange;        //Support Line Color (1)
extern ENUM_LINE_STYLE  LineStyle=STYLE_SOLID;                 //Style of SR Lines (1)
extern int              Linewidth=2;                           //Choose the width of the line (1)
extern bool             AlarmCrossWhithAlert=true;             //Send an Alert
extern bool             AlarmCrossWhithPushSmartphone=false;   //Send a Notification
extern filename         soundname=none;                        //Choose a pair of Sound (high/deep tone)
extern string           text4="==Second Line";                   //Description
extern string           LineHorizontalSecond="Q";              //Key to Create a SR Line (2)
extern color            LineResistcolorSecond=clrDodgerBlue;   //Resistance Line Color (2)
extern color            LineSupportcolorSecond=clrDarkOrange;  //Support Line Color (2)
extern ENUM_LINE_STYLE  LineStyleSecond=STYLE_DOT;             //Style of SR Lines (2)
extern int              LinewidthSecond=1;                     //Choose the width of the line (2)
extern bool             AlarmCrossWhithAlertSecond=true;             //Send an Alert
extern bool             AlarmCrossWhithPushSmartphoneSecond=false;   //Send a Notification
extern filename         soundnameSecond=none;                        //Choose a pair of Sound (high/deep tone)
extern string           text5="==TrendLine";                     //Description
extern bool             TakecareManualTrendline=true;          //Take care of your Trendline added manually  
extern string           text6="==Other";                       //Description
extern string           DeleteLastLine="X";                    //Key to Delete Last Line
extern int              history=200;                           //Check on the last x candles
extern int              MaxDeviation=10;                       //Pips deviation for history

extern string           texta="";                              //====================================
extern string           text7="Money Management Tool";         //Description
extern string           BuyLine="B";                           //Key to Create a Buy Line
extern string           SellLine="S";                          //Key to Create a Sell Line
extern double           Risk=1;                                //Your Percentage Risk
extern double           DefaultSL=30;                          //Default SL in Pips
extern double           DefaultTP=60;                          //Default TP in Pips
extern color            ColorBuySell=clrGreen;                 //Color of the Buy or Sell line
extern color            ColorSL=clrRed;                        //Color of the SL line
extern color            ColorTP=clrLawnGreen;                  //Color of the TP line
extern color            ColorTextBox=clrWhite;                 //Color of text in the toolbox
extern ENUM_LINE_STYLE  MMLineStyle=STYLE_DASHDOTDOT;          //Style of Lines
extern int              MMLinewidth=1;                         //Choose the width of the line
extern bool             Account=true;                          //Choose Balance [true] or Equity [false]
extern bool             CreateTP=true;                         //Create a Take Profit line
extern bool             CreateSL=true;                         //Create a Stop Loss line
extern int              MagicNumber=159357;                    //Magic Number
extern bool             ShowAskLine=True;                      //Show Ask Line

int               intParent;
int               intChild;
double            PipValues;
double            point;
double            SwapLong;
double            SwapShort;
double            SpreadPipValue;
double            SpreadPip;
double            ClickValue;
double            ClickPip;
double            ClickPrice;
double            MousePrice;
datetime          MouseDate;
string            CountDown;
double            SLTPbrokerLimit;
double            MaximumLot;
double            MinimumLotSize;
double            LotStep;
color             TextColor=clrWhite;
color             BackgroundColor=clrBlack;
color             BorderColor=clrWhite;
double            riskmoney;
bool              objectclick=false;
datetime          labelposition;                 // label position on screen
datetime          orderlabelposition;
double            ratioposition=0.70;
string            linehistory="";
string            LineId="";
string            objectline;
double            PipGap;
double            PipGapValue;
color             tempalertcolor;
color             tempshowcolor;
bool              showlineA=true;
bool              showlineQ=true;
bool              showmaster=true;
double            PipValuesonelot;
string            onoff;
color             onoffcolor;
bool              followprice=false;
string            YesNo;
color             YesNocolor;
double            SLPips;
double            TPPips;
string            ratio;
double            lotsizemaximum;
long              chartheight=-1;
long              periodmouseover=Period();
int               BullCount;
int               BearCount;
int               MiddleCount;
int               OverSell;
int               OverBuy;
double            Meter[];
datetime          OldCandelTime;
double            DailyOpenArray[];
bool              ShowPrice=true;
double            PPBuffer[];
double            R1Buffer[];
double            R2Buffer[];
double            R3Buffer[];
double            R4Buffer[];
double            S1Buffer[];
double            S2Buffer[];
double            S3Buffer[];
double            S4Buffer[];
double            FPPBuffer[];
double            FR1Buffer[];
double            FR2Buffer[];
double            FR3Buffer[];
double            FS1Buffer[];
double            FS2Buffer[];
double            FS3Buffer[];
double            GridLow;
double            GridHigh;
double            SLTPbrokerLimitnotzero;
long              ColorBidLine;
int               Timer;

ENUM_ACCOUNT_INFO_DOUBLE         accounttype=ACCOUNT_BALANCE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",0);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   EventSetTimer(1);
   intParent= GetParent(WindowHandle(Symbol(),Period()));
   intChild = GetWindow(intParent,0);
   ChartSetInteger(0,CHART_SHIFT,0,true);
   SLTPbrokerLimit=MarketInfo(Symbol(),MODE_STOPLEVEL);
//correction key case
   LineHorizontal=StringChangeToUpperCase(LineHorizontal);
   LineHorizontalSecond=StringChangeToUpperCase(LineHorizontalSecond);
   DeleteLastLine=StringChangeToUpperCase(DeleteLastLine);
   BuyLine=StringChangeToUpperCase(BuyLine);
   SellLine=StringChangeToUpperCase(SellLine);
   MasterHide=StringChangeToUpperCase(MasterHide);

//GlobalVariable
   if(GlobalVariableCheck("MasIN_Lot_"+string(intParent)))
     {
      LotSize=double(GlobalVariableGet("MasIN_Lot_"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_Risk_"+string(intParent)))
     {
      Risk=double(GlobalVariableGet("MasIN_Risk_"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_ClickPrice_"+string(intParent)))
     {
      ClickPrice=double(GlobalVariableGet("MasIN_ClickPrice_"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_showlineA"+string(intParent)))
     {
      showlineA=double(GlobalVariableGet("MasIN_showlineA"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_AlarmCrossWhithAlert"+string(intParent)))
     {
      AlarmCrossWhithAlert=double(GlobalVariableGet("MasIN_AlarmCrossWhithAlert"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_showlineQ"+string(intParent)))
     {
      showlineQ=double(GlobalVariableGet("MasIN_showlineQ"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_AlarmCrossWhithAlertSecond"+string(intParent)))
     {
      AlarmCrossWhithAlertSecond=double(GlobalVariableGet("MasIN_AlarmCrossWhithAlertSecond"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_IndicatorValue"+string(intParent)))
     {
      IndicatorValue=double(GlobalVariableGet("MasIN_IndicatorValue"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_soundname"+string(intParent)))
     {
      int soundidname=int(GlobalVariableGet("MasIN_soundname"+string(intParent)));
      if(soundidname==0){soundname=0;}
      if(soundidname==1){soundname=1;}
      if(soundidname==2){soundname=2;}
      if(soundidname==3){soundname=3;}
      if(soundidname==4){soundname=4;}
      if(soundidname==5){soundname=5;}
      if(soundidname==6){soundname=6;}
     }
   if(GlobalVariableCheck("MasIN_soundnameSecond"+string(intParent)))
     {
      int soundidname=int(GlobalVariableGet("MasIN_soundnameSecond"+string(intParent)));
      if(soundidname==0){soundnameSecond=0;}
      if(soundidname==1){soundnameSecond=1;}
      if(soundidname==2){soundnameSecond=2;}
      if(soundidname==3){soundnameSecond=3;}
      if(soundidname==4){soundnameSecond=4;}
      if(soundidname==5){soundnameSecond=5;}
      if(soundidname==6){soundnameSecond=6;}
     }
   if(GlobalVariableCheck("MasIN_ShowDailyOpen"+string(intParent)))
     {
      ShowDailyOpen=double(GlobalVariableGet("MasIN_ShowDailyOpen"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_ShowGrid"+string(intParent)))
     {
      ShowGrid=double(GlobalVariableGet("MasIN_ShowGrid"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_ShowPivot"+string(intParent)))
     {
      ShowPivot=double(GlobalVariableGet("MasIN_ShowPivot"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_ShowPivotFibo"+string(intParent)))
     {
      ShowPivotFibo=double(GlobalVariableGet("MasIN_ShowPivotFibo"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_"+Symbol()+"_DefaultSL"+string(intParent)))
     {
      DefaultSL=double(GlobalVariableGet("MasIN_"+Symbol()+"_DefaultSL"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_"+Symbol()+"_DefaultTP"+string(intParent)))
     {
      DefaultTP=double(GlobalVariableGet("MasIN_"+Symbol()+"_DefaultTP"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_"+Symbol()+"_SLTPalert"+string(intParent)))
     {
      SLTPalert=double(GlobalVariableGet("MasIN_"+Symbol()+"_SLTPalert"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_"+Symbol()+"_PipInterval"+string(intParent)))
     {
      PipInterval=int(GlobalVariableGet("MasIN_"+Symbol()+"_PipInterval"+string(intParent)));
     }
   if(GlobalVariableCheck("MasIN_ColorVariation"+string(intParent)))
     {
      ColorVariation=int(GlobalVariableGet("MasIN_ColorVariation"+string(intParent)));
     }

   if(Account){accounttype=ACCOUNT_BALANCE;}else{accounttype=ACCOUNT_EQUITY;}

// TIMEFRAME BUTTON
// Zoom in
   ButtonCreate(0,"MasIN_L_ZommInButton",0,0,15,25,15,2,"Z+","Arial",10,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
// Zoom out
   ButtonCreate(0,"MasIN_L_ZommOutButton",0,24,15,25,15,2,"Z-","Arial",10,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);

// M1 button
   if(Period()==PERIOD_M1)
     {
      ButtonCreate(0,"MasIN_L_M1Button",0,48,15,25,15,2,"M1","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_M1Button",0,48,15,25,15,2,"M1","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_M1Button",OBJPROP_TOOLTIP,"Choose 1 Minute period");
// M5 button
   if(Period()==PERIOD_M5)
     {
      ButtonCreate(0,"MasIN_L_M5Button",0,72,15,25,15,2,"M5","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_M5Button",0,72,15,25,15,2,"M5","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_M5Button",OBJPROP_TOOLTIP,"Choose 5 Minutes period");
// M15 button
   if(Period()==PERIOD_M15)
     {
      ButtonCreate(0,"MasIN_L_M15Button",0,96,15,25,15,2,"M15","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_M15Button",0,96,15,25,15,2,"M15","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_M15Button",OBJPROP_TOOLTIP,"Choose 15 Minutes period");
// M30 button
   if(Period()==PERIOD_M30)
     {
      ButtonCreate(0,"MasIN_L_M30Button",0,120,15,25,15,2,"M30","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_M30Button",0,120,15,25,15,2,"M30","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_M30Button",OBJPROP_TOOLTIP,"Choose 30 Minutes period");
// H1 button
   if(Period()==PERIOD_H1)
     {
      ButtonCreate(0,"MasIN_L_H1Button",0,144,15,25,15,2,"H1","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_H1Button",0,144,15,25,15,2,"H1","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_H1Button",OBJPROP_TOOLTIP,"Choose 1 Hour period");
// H4 button
   if(Period()==PERIOD_H4)
     {
      ButtonCreate(0,"MasIN_L_H4Button",0,168,15,25,15,2,"H4","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_H4Button",0,168,15,25,15,2,"H4","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_H4Button",OBJPROP_TOOLTIP,"Choose 4 Hours period");
// D1 button
   if(Period()==PERIOD_D1)
     {
      ButtonCreate(0,"MasIN_L_D1Button",0,192,15,25,15,2,"D1","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_D1Button",0,192,15,25,15,2,"D1","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_D1Button",OBJPROP_TOOLTIP,"Choose 1 Day period");
// W1 button
   if(Period()==PERIOD_W1)
     {
      ButtonCreate(0,"MasIN_L_W1Button",0,214,15,25,15,2,"W1","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_W1Button",0,214,15,25,15,2,"W1","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_W1Button",OBJPROP_TOOLTIP,"Choose 1 Week period");
// MN button
   if(Period()==PERIOD_MN1)
     {
      ButtonCreate(0,"MasIN_L_MNButton",0,238,15,25,15,2,"MN","Arial",8,BackgroundColor,TextColor,BorderColor,false,false,false,false,0);
        }else{
      ButtonCreate(0,"MasIN_L_MNButton",0,238,15,25,15,2,"MN","Arial",8,TextColor,BackgroundColor,BorderColor,false,false,false,false,0);
     }
   ObjectSetString(0,"MasIN_L_MNButton",OBJPROP_TOOLTIP,"Choose 1 Month period");

//Informations
   point=Point;
   if((Digits==3) || (Digits==5) || (Digits==1))
     {
      point*=10;
     }

   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   SwapLong=NormalizeDouble(MarketInfo(Symbol(),18),2);
   SwapShort=NormalizeDouble(MarketInfo(Symbol(),19),2);
   SpreadPip=MarketInfo(Symbol(),MODE_SPREAD)/point;
   SpreadPipValue=(MarketInfo(Symbol(),MODE_SPREAD)/point)*PipValues;
   SLTPbrokerLimit=MarketInfo(Symbol(),MODE_STOPLEVEL);
   MaximumLot=MarketInfo(Symbol(),MODE_MAXLOT);
   MinimumLotSize=MarketInfo(Symbol(),MODE_MINLOT);
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   riskmoney=double(AccountInfoDouble(accounttype))/100*Risk;
   PipValuesonelot=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*1);

//Show Informations
//L1C1
   EditCreate(0,"MasIN_L1C1",0,0,45,240,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   if(LotSize>MaximumLot || LotSize<MinimumLotSize)
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
     }
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TOOLTIP,"");

//L1C2
   EditCreate(0,"MasIN_L1C2",0,239,45,270,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L1C2",OBJPROP_TEXT,"Click : ");
   ObjectSetString(0,"MasIN_L1C2",OBJPROP_TOOLTIP,"");

//L1C3
   EditCreate(0,"MasIN_L1C3",0,508,45,210,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L1C3",OBJPROP_TEXT,"Swap B/S    : "+DoubleToStr(SwapLong,2)+" / "+DoubleToStr(SwapShort,2));
   ObjectSetString(0,"MasIN_L1C3",OBJPROP_TOOLTIP,"");
//L2C1
   EditCreate(0,"MasIN_L2C1",0,0,30,240,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L2C1",OBJPROP_TEXT,"Spread : ");
   ObjectSetString(0,"MasIN_L2C1",OBJPROP_TOOLTIP,"");
//L2C2
   EditCreate(0,"MasIN_L2C2",0,239,30,270,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L2C2",OBJPROP_TEXT,"Mouse : ");
   ObjectSetString(0,"MasIN_L2C2",OBJPROP_TOOLTIP,"");
//L2C3
   EditCreate(0,"MasIN_L2C3",0,508,30,210,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L2C3",OBJPROP_TEXT,"Next Candle : ");
   ObjectSetString(0,"MasIN_L2C3",OBJPROP_TOOLTIP,"");
//L3C1
   EditCreate(0,"MasIN_L3C1",0,0,60,250,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L3C1",OBJPROP_TEXT,"Risk   :     "+DoubleToStr(Risk,2)+"% / "+CurrencyFormat(riskmoney,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
   ObjectSetString(0,"MasIN_L3C1",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }

//L3C2
   EditCreate(0,"MasIN_L3C2",0,239,60,479,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L3C2",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L3C2",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
// Lot button + 
   ButtonCreate(0,"MasIN_LotSizeButtonPlus",0,70,42,12,12,2,"+","Courier New",10,TextColor,BackgroundColor,BackgroundColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LotSizeButtonPlus",OBJPROP_TOOLTIP,"Use can use 'P' key to increase");
// Lot button - 
   ButtonCreate(0,"MasIN_LotSizeButtonMinus",0,79,42,12,12,2,"-","Courier New",10,TextColor,BackgroundColor,BackgroundColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LotSizeButtonMinus",OBJPROP_TOOLTIP,"Use can use 'M' key to decrease");
// Risk button + 
   ButtonCreate(0,"MasIN_RiskButtonPlus",0,70,57,12,12,2,"+","Courier New",10,TextColor,BackgroundColor,BackgroundColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_RiskButtonPlus",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
// Risk button - 
   ButtonCreate(0,"MasIN_RiskButtonMinus",0,79,57,12,12,2,"-","Courier New",10,TextColor,BackgroundColor,BackgroundColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_RiskButtonMinus",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }

//L0C2
   EditCreate(0,"MasIN_L0C2",0,262,15,227,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L0C2",OBJPROP_TEXT,"Line "+LineHorizontal+" :");
   ObjectSetString(0,"MasIN_L0C2",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_L0C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// Line A alert button
   if(AlarmCrossWhithAlert)
     {
      tempalertcolor=clrGreen;
     }
   else
     {
      tempalertcolor=clrRed;
     }
   ButtonCreate(0,"MasIN_LineAButtonAlert",0,330,13,15,12,2,"A","Courier New",8,tempalertcolor,BackgroundColor,tempalertcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineAButtonAlert",OBJPROP_TOOLTIP,"Alert activated or not");
   ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(showlineA)
     {
      tempshowcolor=clrGreen;
     }
   else
     {
      tempshowcolor=clrRed;
     }
   ButtonCreate(0,"MasIN_LineAButtonShow",0,350,13,50,12,2,"Show","Courier New",8,tempshowcolor,BackgroundColor,tempshowcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineAButtonShow",OBJPROP_TOOLTIP,"Show/hide all Line");
   ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

   ButtonCreate(0,"MasIN_LineAButtonSound",0,405,13,80,12,2,EnumToString(soundname),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineAButtonSound",OBJPROP_TOOLTIP,"Change Sound Alert");
   ObjectSetInteger(0,"MasIN_LineAButtonSound",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
//L0C3
   EditCreate(0,"MasIN_L0C3",0,488,15,230,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L0C3",OBJPROP_TEXT,"Line "+LineHorizontalSecond+" :");
   ObjectSetString(0,"MasIN_L0C3",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_L0C3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
//L4C1 
   EditCreate(0,"MasIN_L4C1",0,0,75,718,16,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,false,0);
   ObjectSetString(0,"MasIN_L4C1",OBJPROP_TEXT,"SL:                                   TP:");
   ObjectSetString(0,"MasIN_L4C1",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BSLM",0,26,73,30,12,2,"Min","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLM",OBJPROP_TOOLTIP,"Minimum SL authorize");
   ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   if(SLTPbrokerLimit==0)
     {
      if((Digits==3) || (Digits==5) || (Digits==1))
        {
         SLTPbrokerLimitnotzero=DefaultSL*10;
        }
      else
        {
         SLTPbrokerLimitnotzero=DefaultSL;
        }
     }
   else
     {
      SLTPbrokerLimitnotzero=SLTPbrokerLimit;
     }
   ButtonCreate(0,"MasIN_L4_BSLM2",0,55,73,40,12,2,string(int(SLTPbrokerLimitnotzero/point*Point*2)),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLM2",OBJPROP_TOOLTIP,"-"+string(int(SLTPbrokerLimitnotzero/point*Point*2))+" Pips");
   ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BSLM3",0,94,73,40,12,2,string(int(SLTPbrokerLimitnotzero/point*Point*3)),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLM3",OBJPROP_TOOLTIP,"-"+string(int(SLTPbrokerLimitnotzero/point*Point*3))+" Pips");
   ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BSLM4",0,133,73,40,12,2,string(int(SLTPbrokerLimitnotzero/point*Point*4)),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLM4",OBJPROP_TOOLTIP,"-"+string(int(SLTPbrokerLimitnotzero/point*Point*4))+" Pips");
   ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BSLM5",0,172,73,40,12,2,string(int(SLTPbrokerLimitnotzero/point*Point*5)),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLM5",OBJPROP_TOOLTIP,"-"+string(int(SLTPbrokerLimitnotzero/point*Point*5))+" Pips");
   ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BSLATR",0,211,73,40,12,2,"ATR","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BSLATR",OBJPROP_TOOLTIP,"ATR");
   ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BTPRR1",0,292,73,40,12,2,"RR1","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BTPRR1",OBJPROP_TOOLTIP,"Risk Reward 1:1");
   ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BTPRR2",0,331,73,40,12,2,"RR2","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BTPRR2",OBJPROP_TOOLTIP,"Risk Reward 1:2");
   ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BTPRR3",0,370,73,40,12,2,"RR3","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BTPRR3",OBJPROP_TOOLTIP,"Risk Reward 1:3");
   ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ButtonCreate(0,"MasIN_L4_BTPRR4",0,409,73,40,12,2,"RR4","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_L4_BTPRR4",OBJPROP_TOOLTIP,"Risk Reward 1:4");
   ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
//Sl Tp P StopLoss TakeProfit PendingOrder
   EditCreate(0,"MasIN_L3C1-error",0,450,73,250,13,"","Courier New",8,ALIGN_LEFT,true,2,clrRed,BackgroundColor,BackgroundColor,false,false,false,0);
   ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

// Line Q alert button
   if(AlarmCrossWhithAlertSecond)
     {
      tempalertcolor=clrGreen;
     }
   else
     {
      tempalertcolor=clrRed;
     }
   ButtonCreate(0,"MasIN_LineQButtonAlert",0,556,13,15,12,2,"A","Courier New",8,tempalertcolor,BackgroundColor,tempalertcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineQButtonAlert",OBJPROP_TOOLTIP,"Alert activated or not");
   ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(showlineQ)
     {
      tempshowcolor=clrGreen;
     }
   else
     {
      tempshowcolor=clrRed;
     }
   ButtonCreate(0,"MasIN_LineQButtonShow",0,576,13,50,12,2,"Show","Courier New",8,tempshowcolor,BackgroundColor,tempshowcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineQButtonShow",OBJPROP_TOOLTIP,"Show/hide all Line");
   ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

   ButtonCreate(0,"MasIN_LineQButtonSound",0,631,13,80,12,2,EnumToString(soundnameSecond),"Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_LineQButtonSound",OBJPROP_TOOLTIP,"Change Sound Alert");
   ObjectSetInteger(0,"MasIN_LineQButtonSound",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// Support Resistance Management
   int i;

   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_KcSR_")>-1)
        {
         objectline=ObjectName(i);
         StringReplace(objectline,"MasIN_KcSR_","");
         if(StringSubstr(objectline,0,StringFind(objectline,"_"))==Symbol())
           {
            ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L0C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L0C3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            if(StringFind(ObjectName(i),"_RS")>-1)
              {
               ObjectSetInteger(0,ObjectName(i),OBJPROP_SELECTABLE,true);
               ObjectSetInteger(0,ObjectName(i),OBJPROP_SELECTED,true);
               ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_LineAButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_LineQButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
              }
           }
         if(StringSubstr(objectline,0,StringFind(objectline,"_"))!=Symbol())
           {
            ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
           }
        }
     }
//Money Manager
// TP button On/Off 
   if(CreateTP){onoff="TP On";onoffcolor=clrGreen;}else{onoff="TP Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_MMGTbox_TPButton",0,245,58,45,12,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_MMGTbox_TPButton",OBJPROP_TOOLTIP,"Tp line On/Off");
   ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
// SL button On/Off 
   if(CreateSL){onoff="SL On";onoffcolor=clrGreen;}else{onoff="SL Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_MMGTbox_SLButton",0,298,58,45,12,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_MMGTbox_SLButton",OBJPROP_TOOLTIP,"Sl line On/Off");
   ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }

   if(followprice){YesNocolor=clrGreen;}else{YesNocolor=clrRed;}
   ButtonCreate(0,"MasIN_MMGTbox_FollowButton",0,350,58,100,12,2,"Follow Price","Courier New",8,YesNocolor,BackgroundColor,YesNocolor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TOOLTIP,"Buy/Sell line follow the actual price");
   ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }

// Order button Sell / Buy / Buy limit / Buy stop / Sell limit / Sell stop 
   ButtonCreate(0,"MasIN_MMGTbox_OrderButton",0,460,58,240,12,2,"","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TOOLTIP,"Open an Order");
   ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
// Close all Money Manager object
   ButtonCreate(0,"MasIN_MMGTbox_CloseButton",0,701,58,15,12,2,"X","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetString(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TOOLTIP,"Close Money Manager");
   ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1 || ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }

//L0C4
   EditCreate(0,"MasIN_L0C4",0,717,15,100,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L0C4",OBJPROP_TOOLTIP,"CCI indicator");
//L1C4
   EditCreate(0,"MasIN_L1C4",0,717,30,100,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L1C4",OBJPROP_TOOLTIP,"Stochastic indicator");
//L2C4
   EditCreate(0,"MasIN_L2C4",0,717,45,100,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L2C4",OBJPROP_TOOLTIP,"RSI indicator");
//L0C5
   EditCreate(0,"MasIN_L0C5",0,816,15,110,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L0C5",OBJPROP_TOOLTIP,"MACD indicator");
//L1C5
   EditCreate(0,"MasIN_L1C5",0,816,30,110,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L1C5",OBJPROP_TOOLTIP,"Momentum indicator");
//L2C5
   EditCreate(0,"MasIN_L2C5",0,816,45,110,15,"","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetString(0,"MasIN_L2C5",OBJPROP_TEXT,"");
   ObjectSetString(0,"MasIN_L2C5",OBJPROP_TOOLTIP,"MA Simple/Exponetial (5/10/20/50/100/200)");
   if(!IndicatorValue)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }
//support lineA
   if(!showlineA)
     {
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_A_label")>-1)
              {
               objectline=ObjectName(i);
               StringReplace(objectline,"_label","_RS");
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
               ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
              }
           }
        }
      tempshowcolor=clrRed;
      ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_COLOR,tempshowcolor);
      ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
     }
   else
     {
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_A_label")>-1)
              {
               objectline=ObjectName(i);
               StringReplace(objectline,"_label","_RS");
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
              }
           }
        }
      tempshowcolor=clrGreen;
      ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_COLOR,tempshowcolor);
      ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
     }
//support line Q
   if(!showlineQ)
     {
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_Q_label")>-1)
              {
               objectline=ObjectName(i);
               StringReplace(objectline,"_label","_RS");
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
               ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
              }
           }
        }
      tempshowcolor=clrRed;
      ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_COLOR,tempshowcolor);
      ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
     }
   else
     {
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_Q_label")>-1)
              {
               objectline=ObjectName(i);
               StringReplace(objectline,"_label","_RS");
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
              }
           }
        }
      tempshowcolor=clrGreen;
      ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_COLOR,tempshowcolor);
      ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
     }

//GRID
   GridColor();
//OPTION TOOL
   RectLabelCreate(0,"MasIN_Option_Tool",0,2,400,300,300,BackgroundColor,0,2,BorderColor,STYLE_SOLID,1,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Tool",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ButtonCreate(0,"MasIN_Option_Button",0,283,395,15,12,2,"X","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ShowGrid){onoff="Grid On";onoffcolor=clrGreen;}else{onoff="Grid Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Button_Grid",0,8,385,65,15,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_Grid",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Grid_Pip_Text",0,80,385,150,15,"Interval Pip :","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BackgroundColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Grid_Pip_Text",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Grid_Pip",0,242,385,40,15,string(PipInterval),"Courier New",8,ALIGN_CENTER,false,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Grid_Pip",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Grid_Pip_Text2",0,80,365,150,15,"Color Variation 0-8 :","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BackgroundColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Grid_Pip_Text2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Grid_Variation",0,242,365,40,15,string(ColorVariation),"Courier New",8,ALIGN_CENTER,false,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Grid_Variation",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Grid_Pip_Text3",0,80,345,150,15,"Show Price :","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BackgroundColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Grid_Pip_Text3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ShowPrice){onoff="On";onoffcolor=clrGreen;}else{onoff="Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Show_Price",0,242,345,40,15,2,"On","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Show_Price",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ShowDailyOpen){onoff="Daily On";onoffcolor=clrGreen;}else{onoff="Daily Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Button_DailyOpen",0,8,325,65,15,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_DailyOpen",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(IndicatorValue){onoff="Indicator On";onoffcolor=clrGreen;}else{onoff="Indicator Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Button_Indicator",0,8,305,105,15,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_Indicator",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ShowPivot){onoff="Pivot On";onoffcolor=clrGreen;}else{onoff="Pivot Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Button_Pivot",0,8,285,105,15,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_Pivot",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   if(ShowPivotFibo){onoff="Pivot Fibonacci On";onoffcolor=clrGreen;}else{onoff="Pivot Fibonacci Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MasIN_Option_Button_PivotFibo",0,120,285,145,15,2,onoff,"Courier New",8,onoffcolor,BackgroundColor,onoffcolor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_PivotFibo",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ButtonCreate(0,"MasIN_Option_Button_Backup",0,8,265,105,15,2,"Backup Lines","Courier New",8,TextColor,BackgroundColor,TextColor,false,false,false,false,0);
   ObjectSetInteger(0,"MasIN_Option_Button_Backup",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetString(0,"MasIN_Option_Button_Backup",OBJPROP_TOOLTIP,"Create a csv file of all Support Resistance Line");
   EditCreate(0,"MasIN_Option_Default_SL_Text",0,8,245,150,15,"Default SL :","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BackgroundColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Default_SL_Text",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Default_SL",0,242,245,40,15,string(DefaultSL),"Courier New",8,ALIGN_CENTER,false,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Default_SL",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Default_TP_Text",0,8,225,150,15,"Default TP :","Courier New",8,ALIGN_LEFT,true,2,TextColor,BackgroundColor,BackgroundColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Default_TP_Text",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   EditCreate(0,"MasIN_Option_Edit_Default_TP",0,242,225,40,15,string(DefaultTP),"Courier New",8,ALIGN_CENTER,false,2,TextColor,BackgroundColor,BorderColor,false,false,true,0);
   ObjectSetInteger(0,"MasIN_Option_Edit_Default_TP",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
//Daily Open
   SetIndexBuffer(0,DailyOpenArray);
   SetIndexStyle(0,DRAW_LINE,STYLE_DASH,1,clrOrange);
   SetIndexLabel(0,"MasIN_DailyOpen");
   SetIndexEmptyValue(0,0.0);
   if(ShowDailyOpen)
     {
      //DailyOpen();
     }
//Pivot
   SetIndexBuffer(1,PPBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_DASH,1,clrOrangeRed);
   SetIndexLabel(1,"MasIN_PIVOT_PP");
   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,S1Buffer);
   SetIndexStyle(2,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(2,"MasIN_PIVOT_S1");
   SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(3,S2Buffer);
   SetIndexStyle(3,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(3,"MasIN_PIVOT_S2");
   SetIndexEmptyValue(3,0.0);
   SetIndexBuffer(4,S3Buffer);
   SetIndexStyle(4,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(4,"MasIN_PIVOT_S3");
   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,S4Buffer);
   SetIndexStyle(5,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(5,"MasIN_PIVOT_S4");
   SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(6,R1Buffer);
   SetIndexStyle(6,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(6,"MasIN_PIVOT_R1");
   SetIndexEmptyValue(6,0.0);
   SetIndexBuffer(7,R2Buffer);
   SetIndexStyle(7,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(7,"MasIN_PIVOT_R2");
   SetIndexEmptyValue(7,0.0);
   SetIndexBuffer(8,R3Buffer);
   SetIndexStyle(8,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(8,"MasIN_PIVOT_R3");
   SetIndexEmptyValue(8,0.0);
   SetIndexBuffer(9,R4Buffer);
   SetIndexStyle(9,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(9,"MasIN_PIVOT_R4");
   SetIndexEmptyValue(9,0.0);
   if(ShowPivot)
     {
      //PivotLine();
     }
//PivotFibo
   SetIndexBuffer(10,FPPBuffer);
   SetIndexStyle(10,DRAW_LINE,STYLE_DASH,1,clrOrangeRed);
   SetIndexLabel(10,"MasIN_PIVOT_FPP");
   SetIndexEmptyValue(10,0.0);
   SetIndexBuffer(11,FS1Buffer);
   SetIndexStyle(11,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(11,"MasIN_PIVOT_FS1");
   SetIndexEmptyValue(11,0.0);
   SetIndexBuffer(12,FS2Buffer);
   SetIndexStyle(12,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(12,"MasIN_PIVOT_FS2");
   SetIndexEmptyValue(12,0.0);
   SetIndexBuffer(13,FS3Buffer);
   SetIndexStyle(13,DRAW_LINE,STYLE_DASH,1,LineSupportcolor);
   SetIndexLabel(13,"MasIN_PIVOT_FS3");
   SetIndexEmptyValue(13,0.0);
   SetIndexBuffer(14,FR1Buffer);
   SetIndexStyle(14,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(14,"MasIN_PIVOT_FR1");
   SetIndexEmptyValue(14,0.0);
   SetIndexBuffer(15,FR2Buffer);
   SetIndexStyle(15,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(15,"MasIN_PIVOT_FR2");
   SetIndexEmptyValue(15,0.0);
   SetIndexBuffer(16,FR3Buffer);
   SetIndexStyle(16,DRAW_LINE,STYLE_DASH,1,LineResistcolor);
   SetIndexLabel(16,"MasIN_PIVOT_FR3");
   SetIndexEmptyValue(16,0.0);

//create line save, if not already exist
   FileToLine();

   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_Order_")>-1)
        {
         ObjectDelete(0,ObjectName(i));
        }
     }
//Bid Color Line
   ChartGetInteger(0,CHART_COLOR_GRID,0,ColorBidLine);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   SpreadPip=MarketInfo(Symbol(),MODE_SPREAD)/point*Point;
   SpreadPipValue=(MarketInfo(Symbol(),MODE_SPREAD)/point*Point)*PipValues;
//real Ask line for Broker who don't do it right
   if(ShowAskLine)
     {
      HLineCreate(0,"MasIN_Ask_"+Symbol(),0,MarketInfo(Symbol(),MODE_ASK),color(ColorBidLine),STYLE_SOLID,1,false,false,false,0,TimeToString(TimeCurrent(),TIME_DATE));
      HLineMove(0,"MasIN_Ask_"+Symbol(),MarketInfo(Symbol(),MODE_ASK));
     }
//countdown
   int timenow,second,minute,hour;
   timenow=(int) time[0]+PeriodSeconds(Period()) -(int) TimeCurrent();
   second=timenow%60;
   minute=(timenow-second);
   if(minute!=0)
     {
      minute=minute/60;
     }
   minute=minute -(minute-minute%60);
   hour=(timenow-second-minute*60);
   if(hour!=0)
     {
      hour=hour/60;
     }
   if(hour!=0)
     {
      hour=hour/60;
     }
   CountDown=IntegerToString(hour,2,'0')+":"+IntegerToString(minute,2,'0')+":"+IntegerToString(second,2,'0');

   if(ClickPrice>MarketInfo(Symbol(),MODE_ASK))
     {
      ClickValue=PipValues*((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point);
      ClickPip=NormalizeDouble(((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point),1);
     }
   else
     {
      ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
      ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
     }
   ObjectSetString(0,"MasIN_L1C2",OBJPROP_TEXT,"Click : "+DoubleToStr(ClickPrice,Digits)+" / "+DoubleToStr(ClickPip,1)+" / "+CurrencyFormat(ClickValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
   ObjectSetString(0,"MasIN_L2C3",OBJPROP_TEXT,"Next Candle : "+CountDown);
   ObjectSetString(0,"MasIN_L2C1",OBJPROP_TEXT,"Spread : "+DoubleToStr(SpreadPip,1)+" / "+CurrencyFormat(SpreadPipValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

// Support Resistance Management
   int i;
   string result[];
   bool lineexist=false;
   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
        {
         if(StringFind(ObjectName(i),"_label")>-1)
           {
            lineexist=true;
            objectline=ObjectName(i);
            StringReplace(objectline,"_label","_RS");
            ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
            PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
            PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
            ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
            ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
            ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
           }
         if(StringFind(ObjectName(i),"_Trendline")>-1)
           {
            int k=StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
            objectline=result[3];
            PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGetValueByTime(0,objectline,TimeCurrent()));
            PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
            if(ObjectGetValueByTime(0,objectline,TimeCurrent())<MarketInfo(Symbol(),MODE_BID))
              {
               ObjectSetText(ObjectName(i),DoubleToString(ObjectGetValueByTime(0,objectline,TimeCurrent()),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",LineSupportcolor);
              }
            else
              {
               ObjectSetText(ObjectName(i),DoubleToString(ObjectGetValueByTime(0,objectline,TimeCurrent()),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",LineResistcolor);
              }
            if(ObjectFind(0,objectline)==-1)
              {
               ObjectDelete(0,ObjectName(i));
              }
           }
        }

      if(StringFind(ObjectName(i),"_A_RS")>-1)
        {
         if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)<MarketInfo(Symbol(),MODE_BID))
           { //is support
            if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineSupportcolor)
              { //is already support
              }
            else
              { //was resistance
               ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineSupportcolor);
               objectline=ObjectName(i);
               StringReplace(objectline,"_RS","_label");
               ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineSupportcolor);
               if(AlarmCrossWhithAlert)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                  if(soundname>0)
                    {
                     PlaySound("Beep-"+IntegerToString(soundname)+"-up.wav ");
                    }
                 }
               if(AlarmCrossWhithPushSmartphone)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                 }
              }
           }
         else
           {
            if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineResistcolor)
              { //is already resistance
              }
            else
              { //was support
               ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineResistcolor);
               objectline=ObjectName(i);
               StringReplace(objectline,"_RS","_label");
               ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineResistcolor);
               if(AlarmCrossWhithAlert)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                  if(soundname>0)
                    {
                     PlaySound("Beep-"+IntegerToString(soundname)+"-down.wav ");
                    }
                 }
               if(AlarmCrossWhithPushSmartphone)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                 }
              }
           }
        }
      if(StringFind(ObjectName(i),"_Q_RS")>-1)
        {
         if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)<MarketInfo(Symbol(),MODE_BID))
           { //is support
            if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineSupportcolor)
              { //is already support
              }
            else
              { //was resistance
               ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineSupportcolor);
               objectline=ObjectName(i);
               StringReplace(objectline,"_RS","_label");
               ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineSupportcolor);
               if(AlarmCrossWhithAlertSecond)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                  if(soundnameSecond>0)
                    {
                     PlaySound("Beep-"+IntegerToString(soundnameSecond)+"-up.wav ");
                    }
                 }
               if(AlarmCrossWhithPushSmartphoneSecond)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                 }
              }
           }
         else
           {
            if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineResistcolor)
              { //is already resistance
              }
            else
              { //was support
               ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineResistcolor);
               objectline=ObjectName(i);
               StringReplace(objectline,"_RS","_label");
               ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineResistcolor);
               if(AlarmCrossWhithAlertSecond)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                  if(soundnameSecond>0)
                    {
                     PlaySound("Beep-"+IntegerToString(soundnameSecond)+"-down.wav ");
                    }
                 }
               if(AlarmCrossWhithPushSmartphoneSecond)
                 { //send alarm
                  StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                  SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                 }
              }
           }
        }
      //Trendline
      if(TakecareManualTrendline)
        {
         string objectname=ObjectName(i);
         if(StringFind(objectname,"Trendline ")>-1)
           {
            if(StringFind(objectname,"_Trendline ")==-1)
              {
               if(StringFind(objectname,"SMMC")>-1)
                 {
                 }
               if(ObjectFind(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label")==-1)
                 {
                  datetime labelpositiontrend;
                  double trendlineposition=ObjectGetValueByTime(0,objectname,labelposition);
                  if(ObjectGetValueByTime(0,objectname,labelposition)==0)
                    {
                     trendlineposition=ObjectGet(objectname,OBJPROP_PRICE1);
                     labelpositiontrend=datetime(ObjectGet(objectname,OBJPROP_TIME1));
                    }
                  else
                    {
                     labelpositiontrend=labelposition;
                    }
                  ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",OBJ_TEXT,0,labelpositiontrend,trendlineposition);
                  ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",0,labelpositiontrend,trendlineposition);
                  if(MarketInfo(Symbol(),MODE_BID)>ObjectGetValueByTime(0,objectname,TimeCurrent()))
                    {
                     ObjectSetInteger(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",OBJPROP_COLOR,LineSupportcolor);
                    }
                  else
                    {
                     ObjectSetInteger(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",OBJPROP_COLOR,LineResistcolor);
                    }
                 }
               if(ObjectGet("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",OBJPROP_PRICE1)==0)
                 {
                  datetime labelpositiontrend;
                  double trendlineposition=ObjectGetValueByTime(0,objectname,labelposition);
                  if(ObjectGetValueByTime(0,objectname,labelposition)==0)
                    {
                     trendlineposition=ObjectGet(objectname,OBJPROP_PRICE1);
                     labelpositiontrend=datetime(ObjectGet(objectname,OBJPROP_TIME1));
                    }
                  else
                    {
                     labelpositiontrend=labelposition;
                    }
                  ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",OBJ_TEXT,0,labelpositiontrend,trendlineposition);
                  ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",0,labelpositiontrend,trendlineposition);
                 }
              }
            if(!(ObjectGet(objectname,OBJPROP_COLOR)==LineSupportcolor) && !(ObjectGet(objectname,OBJPROP_COLOR)==LineResistcolor))
              {//just added
               if(ObjectGetValueByTime(0,objectname,TimeCurrent())<MarketInfo(Symbol(),MODE_BID))
                 {
                  ObjectSetInteger(0,objectname,OBJPROP_COLOR,LineSupportcolor);
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGetValueByTime(0,objectname,TimeCurrent()));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",LineSupportcolor);
                 }
               else
                 {
                  ObjectSetInteger(0,objectname,OBJPROP_COLOR,LineResistcolor);
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGetValueByTime(0,objectname,TimeCurrent()));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",LineResistcolor);
                 }
              }
            if(StringFind(objectname,"_Label")==-1)
              {
               if(ObjectGetValueByTime(0,objectname,TimeCurrent())<MarketInfo(Symbol(),MODE_BID))
                 { //is support
                  if(ObjectGet(objectname,OBJPROP_COLOR)==LineSupportcolor)
                    { //is already support
                    }
                  else
                    { //was resistance
                     ObjectSetInteger(0,objectname,OBJPROP_COLOR,LineSupportcolor);
                     //ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label","xxxx  /3 ",10,"Courier New",LineSupportcolor);
                     //ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+objectname+"_Label",0,labelposition,ObjectGetValueByTime(0,objectname,labelposition));
                     if(AlarmCrossWhithAlert)
                       { //send alarm
                        Alert(Symbol()+" Crossed "+DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" - Over Trendline");
                        if(soundname>0)
                          {
                           PlaySound("Beep-"+IntegerToString(soundname)+"-up.wav ");
                          }
                       }
                     if(AlarmCrossWhithPushSmartphone)
                       { //send alarm
                        SendNotification(Symbol()+" Crossed "+DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" - Over Trendline");
                        if(soundname>0)
                          {
                           PlaySound("Beep-"+IntegerToString(soundname)+"-up.wav ");
                          }
                       }
                    }
                 }
               else
                 {
                  if(ObjectGet(objectname,OBJPROP_COLOR)==LineResistcolor)
                    { //is already resistance
                    }
                  else
                    { //was support
                     ObjectSetInteger(0,objectname,OBJPROP_COLOR,LineResistcolor);
                     if(AlarmCrossWhithAlert)
                       { //send alarm
                        Alert(Symbol()+" Crossed "+DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" - Under Trendline");
                       }
                     if(AlarmCrossWhithPushSmartphone)
                       { //send alarm
                        SendNotification(Symbol()+" Crossed "+DoubleToString(ObjectGetValueByTime(0,objectname,TimeCurrent()),Digits)+" - Under Trendline");
                       }
                    }
                 }
              }
           }
        }
     }
   if(!lineexist)
     {
      ObjectSetInteger(0,"MasIN_L0C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L0C3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineAButtonSound",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_LineQButtonSound",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

//Money Management
   string textline="";
   string errorlimit="";
   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_MMGT_"+Symbol())>-1)
        {
         if(StringFind(ObjectName(i),"_Label")>-1)
           {
            objectline=ObjectName(i);
            StringReplace(objectline,"_Label","_Line");
            ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
            if(StringFind(objectline,"Buy_Line")>-1)
              {
               PipGap=(ObjectGet(objectline,OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_ASK));
               ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
              }
            if(StringFind(objectline,"Sell_Line")>-1)
              {
               PipGap=(ObjectGet(objectline,OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
               ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
              }
            if(StringFind(objectline,"SL_Line")>-1)
              {
               if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
                 {
                  textline="Buy";
                  PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                 }
               if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
                 {
                  textline="Sell";
                  PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
                 }
               if(MathRound(MathAbs(PipGap/Point))<SLTPbrokerLimit)
                 {
                  errorlimit=errorlimit+"SL ";
                  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
                 }
               else
                 {
                  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
                 }
               ObjectSetString(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",OBJPROP_TEXT,"SL "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline+" / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline+" / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
              }
            if(StringFind(objectline,"TP_Line")>-1)
              {
               double PipGaptempo=1;
               double SLPipstempo=1;
               double TPPipstempo=1;

               if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
                 {
                  textline="Buy";
                  PipGaptempo=(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                  SLPipstempo=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                  TPPipstempo=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                 }
               if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
                 {
                  textline="Sell";
                  PipGaptempo=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
                  SLPipstempo=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
                  TPPipstempo=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
                 }
               if(MathRound(MathAbs(PipGaptempo/Point))<SLTPbrokerLimit)
                 {
                  errorlimit=errorlimit+"TP ";
                  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
                 }
               else
                 {
                  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
                 }
               if(SLPipstempo!=0)
                 {
                  ratio="1:"+DoubleToString((TPPipstempo/SLPipstempo),1);
                 }
               //ObjectSetString(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",OBJPROP_TEXT,"TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGaptempo/point,1)+" Pips from "+textline+" / "+CurrencyFormat((PipValues*(PipGaptempo/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight)+" / Ratio : "+ratio);
               ObjectSetString(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",OBJPROP_TEXT,"TP "+DoubleToString(PipGaptempo/point,1)+" Pips / "+CurrencyFormat((PipValues*(PipGaptempo/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight)+" / Ratio : "+ratio);
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGaptempo/point,1)+" Pips from "+textline+" / "+CurrencyFormat((PipValues*(PipGaptempo/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight)+" / Ratio : "+ratio);
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGaptempo/point,1)+" Pips from "+textline+" / "+CurrencyFormat((PipValues*(PipGaptempo/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight)+" / Ratio : "+ratio);
              }
           }
        }
     }
   if(followprice)
     {
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
           }
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_BID)-TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)-TPPips);
           }
        }
     }
   else
     {
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         if(MathRound(MathAbs((ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_ASK))/Point))<SLTPbrokerLimit)
           {
            errorlimit=errorlimit+"Pending ";
            ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
           }
         else
           {
            ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
           }
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         if(MathRound(MathAbs((ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID))/Point))<SLTPbrokerLimit)
           {
            errorlimit=errorlimit+"Pending ";
            ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
           }
         else
           {
            if(StringLen(errorlimit)>1)
              {
               ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
              }
            else
              {
               ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
              }
           }
        }
     }
   if(GlobalVariableGet("MasIN_MMGT_EA")==1 && ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_SL_Line")>-1)
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
        }
      else
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
        }
     }
   else
     {
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_SL_Line")>-1)
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
        }
     }

   if(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_Action")==20)
     {
      GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",0);//0=close
      GlobalVariableSet("MasIN_MMGT_ChartID",-1);
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line");
      ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label");
      ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_BORDER_COLOR,clrRed);
      ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      followprice=false;
     }

   if(IndicatorValue)
     {
      ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
      ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
      ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
      ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
      ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
      IndicatorColor();

      BearCount=0;
      BullCount=0;
      MiddleCount=0;
      OverBuy=0;
      OverSell=0;
      if(iMA(Symbol(),int(periodmouseover),5,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),10,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),20,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),50,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),100,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),200,0,MODE_SMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      //iMA

      if(iMA(Symbol(),int(periodmouseover),5,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),10,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),20,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),50,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),100,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      if(iMA(Symbol(),int(periodmouseover),200,0,MODE_EMA,PRICE_MEDIAN,0)>Bid)
        {
         BullCount+=1;
        }
      else
        {
         BearCount+=1;
        }
      ObjectSetString(0,"MasIN_L2C5",OBJPROP_TEXT,"MA  : S="+string(BullCount)+" B="+string(BearCount)+"");
      if(BearCount>8)
        {
         ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_COLOR,clrGreen);
        }
      if(BearCount<=8 && BearCount>4)
        {
         ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_COLOR,TextColor);
        }
      if(BearCount<=4)
        {
         ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_COLOR,clrRed);
        }
     }

//GRID
   string invertaledit;
   ObjectGetString(0,"MasIN_Option_Edit_Grid_Pip",OBJPROP_TEXT,0,invertaledit);
   string coloredit;
   ObjectGetString(0,"MasIN_Option_Edit_Grid_Variation",OBJPROP_TEXT,0,coloredit);
   if(int(invertaledit)!=PipInterval || int(coloredit)!=ColorVariation)
     {
      PipInterval=int(invertaledit);
      ColorVariation=int(coloredit);
      GridColor();
     }
   if(OldCandelTime<time[0])
     {
      GridColor();
      OldCandelTime=time[0];
     }
   if(Bid>GridHigh || Bid<GridLow)
     {
      GridColor();
     }

//DailyOpen
   if(ShowDailyOpen)
     {
      DailyOpen();
     }
//Pivot
   if(ShowPivot)
     {
      PivotLine();
     }
//PivotFibo
   if(ShowPivotFibo)
     {
      PivotLineFibo();
     }

//Sell/Buy/SL/TP label
   string resultorder[];
   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_Order_")>-1)
        {
         StringSplit(ObjectName(i),StringGetCharacter("_",0),resultorder);
         if(OrderSelect(int(resultorder[4]),SELECT_BY_TICKET,MODE_HISTORY)==false) continue;
         if(OrderCloseTime()!=0 || Symbol()!=OrderSymbol() || Symbol()!=resultorder[3])
           {
            ObjectDelete(0,ObjectName(i));
           }
        }
     }
   int total=OrdersTotal();
   long colorlineorder;
   double PipTp=0;
   double PipTpgap=0;
   double PipBgap;
   double PipSgap;
   for(int pos=0;pos<total;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            PipBgap=NormalizeDouble((Ask-OrderOpenPrice())/point,1);
            if(ObjectFind(0,"MasIN_Order_Buy_"+Symbol()+"_"+string(OrderTicket()))>-1)
              {
               ObjectMove(0,"MasIN_Order_Buy_"+Symbol()+"_"+string(OrderTicket()),0,orderlabelposition,OrderOpenPrice());
               ChartGetInteger(0,CHART_COLOR_VOLUME,0,colorlineorder);
               ObjectSetText("MasIN_Order_Buy_"+Symbol()+"_"+string(OrderTicket()),"Buy #"+string(pos)+" ["+DoubleToString(PipBgap,1)+" Pips] "+string(OrderLots()),10,"Courier New",color(colorlineorder));
              }
            else
              {
               ObjectCreate("MasIN_Order_Buy_"+Symbol()+"_"+string(OrderTicket()),OBJ_TEXT,0,orderlabelposition,OrderOpenPrice());
               ChartGetInteger(0,CHART_COLOR_VOLUME,0,colorlineorder);
               ObjectSetText("MasIN_Order_Buy_"+Symbol()+"_"+string(OrderTicket()),"Buy #"+string(pos)+" ["+DoubleToString(PipBgap,1)+" Pips] "+string(OrderLots()),10,"Courier New",color(colorlineorder));
              }
            PipTp=NormalizeDouble((((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*OrderLots()) *((OrderTakeProfit()-OrderOpenPrice())/point),2);
            PipTpgap=NormalizeDouble((OrderTakeProfit()-OrderOpenPrice())/point,1);
           }
         if(OrderType()==OP_SELL)
           {
            PipSgap=NormalizeDouble((OrderOpenPrice()-Bid)/point,1);
            if(ObjectFind(0,"MasIN_Order_Sell_"+Symbol()+"_"+string(OrderTicket()))>-1)
              {
               ObjectMove(0,"MasIN_Order_Sell_"+Symbol()+"_"+string(OrderTicket()),0,orderlabelposition,OrderOpenPrice());
               ChartGetInteger(0,CHART_COLOR_VOLUME,0,colorlineorder);
               ObjectSetText("MasIN_Order_Sell_"+Symbol()+"_"+string(OrderTicket()),"Sell #"+string(pos)+" ["+DoubleToString(PipSgap,1)+" Pips] "+string(OrderLots()),10,"Courier New",color(colorlineorder));
              }
            else
              {
               ObjectCreate("MasIN_Order_Sell_"+Symbol()+"_"+string(OrderTicket()),OBJ_TEXT,0,orderlabelposition,OrderOpenPrice());
               ChartGetInteger(0,CHART_COLOR_VOLUME,0,colorlineorder);
               ObjectSetText("MasIN_Order_Sell_"+Symbol()+"_"+string(OrderTicket()),"Sell #"+string(pos)+" ["+DoubleToString(PipSgap,1)+" Pips] "+string(OrderLots()),10,"Courier New",color(colorlineorder));
              }
            PipTp=NormalizeDouble((((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*OrderLots()) *((OrderOpenPrice()-OrderTakeProfit())/point),2);
            PipTpgap=NormalizeDouble((OrderOpenPrice()-OrderTakeProfit())/point,1);
           }
         if(OrderType()==OP_SELL || OrderType()==OP_BUY)
           {
            if(ObjectFind(0,"MasIN_Order_TP_"+Symbol()+"_"+string(OrderTicket()))>-1)
              {
               ObjectMove(0,"MasIN_Order_TP_"+Symbol()+"_"+string(OrderTicket()),0,orderlabelposition,OrderTakeProfit());
               ChartGetInteger(0,CHART_COLOR_STOP_LEVEL,0,colorlineorder);
               ObjectSetText("MasIN_Order_TP_"+Symbol()+"_"+string(OrderTicket()),"TP #"+string(pos)+" ["+string(PipTpgap)+ " Pips] " +CurrencyFormat(double(PipTp),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",color(colorlineorder));
              }
            else
              {
               ObjectCreate("MasIN_Order_TP_"+Symbol()+"_"+string(OrderTicket()),OBJ_TEXT,0,orderlabelposition,OrderTakeProfit());
               ChartGetInteger(0,CHART_COLOR_STOP_LEVEL,0,colorlineorder);
               ObjectSetText("MasIN_Order_TP_"+Symbol()+"_"+string(OrderTicket()),"TP #"+string(pos)+" ["+string(PipTpgap)+ " Pips] "+CurrencyFormat(double(PipTp),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",color(colorlineorder));
              }
            if(ObjectFind(0,"MasIN_Order_SL_"+Symbol()+"_"+string(OrderTicket()))>-1)
              {
               ObjectMove(0,"MasIN_Order_SL_"+Symbol()+"_"+string(OrderTicket()),0,orderlabelposition,OrderStopLoss());
              }
            else
              {
               ObjectCreate("MasIN_Order_SL_"+Symbol()+"_"+string(OrderTicket()),OBJ_TEXT,0,orderlabelposition,OrderStopLoss());
               ChartGetInteger(0,CHART_COLOR_STOP_LEVEL,0,colorlineorder);
               ObjectSetText("MasIN_Order_SL_"+Symbol()+"_"+string(OrderTicket()),"SL #"+string(pos),10,"Courier New",color(colorlineorder));
              }
           }
        }
     }
//Print(Point);
//correction of SL and TP
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
     {
      SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
      if(SLPips==0)
        {
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultSL*point));
        }
      if(CreateTP)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         if(TPPips==0)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(DefaultTP*point));
           }
        }
     }
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
      if(SLPips==0)
        {
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(DefaultSL*point));
        }
      if(CreateTP)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         if(TPPips==0)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultTP*point));
           }
        }
     }
//correction of Buy Sell TP SL if tick size is not 0.1 or 0.01 or 0.0001 ...
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
     {
      if(MathMod(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1),MarketInfo(Symbol(),MODE_TICKSIZE))>0)
        {
         double pricetemp=ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1);
         pricetemp=MathRound(pricetemp/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",pricetemp);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
           }
        }
      calculatebuy();
     }
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      if(MathMod(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1),MarketInfo(Symbol(),MODE_TICKSIZE))>0)
        {
         double pricetemp=ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1);
         pricetemp=MathRound(pricetemp/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",pricetemp);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
           }
        }
      calculatesell();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   datetime dt    =0;
   double   price =0;
   int      window=0;
   int      k=1;
   int      i=1;
   double   SLprice=0;
   double   TPprice=0;
//+------------------------------------------------------------------+
//| CHARTEVENT_OBJECT_CLICK                                          |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if((StringFind(sparam,"MasIN_L_")>-1))
        {
         if(!(StringFind(sparam,"MasIN_L_Zomm")>-1))
           {
            ObjectSetInteger(0,"MasIN_L_M1Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M1Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_M1Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M5Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M5Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_M5Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M15Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M15Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_M15Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M30Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_M30Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_M30Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_H1Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_H1Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_H1Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_H4Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_H4Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_H4Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_D1Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_D1Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_D1Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_W1Button",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_W1Button",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_W1Button",OBJPROP_BORDER_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_MNButton",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"MasIN_L_MNButton",OBJPROP_BGCOLOR,clrBlack);
            ObjectSetInteger(0,"MasIN_L_MNButton",OBJPROP_BORDER_COLOR,clrWhite);
           }
        }
      if(sparam=="MasIN_L_ZommInButton")
        {
         PostMessageA(intParent,0x0111,33025,0);
        }
      if(sparam=="MasIN_L_ZommOutButton")
        {
         PostMessageA(intParent,0x0111,33026,0);
        }
      if(sparam=="MasIN_L_M1Button")
        {
         PostMessageA(intParent,0x0111,33137,0);
         ObjectSetInteger(0,"MasIN_L_M1Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_M1Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_M5Button")
        {
         PostMessageA(intParent,0x0111,33138,0);
         ObjectSetInteger(0,"MasIN_L_M5Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_M5Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_M15Button")
        {
         PostMessageA(intParent,0x0111,33139,0);
         ObjectSetInteger(0,"MasIN_L_M15Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_M15Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_M30Button")
        {
         PostMessageA(intParent,0x0111,33140,0);
         ObjectSetInteger(0,"MasIN_L_M30Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_M30Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_H1Button")
        {
         PostMessageA(intParent,0x0111,35400,0);
         ObjectSetInteger(0,"MasIN_L_H1Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_H1Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_H4Button")
        {
         PostMessageA(intParent,0x0111,33136,0);
         ObjectSetInteger(0,"MasIN_L_H4Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_H4Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_D1Button")
        {
         PostMessageA(intParent,0x0111,33134,0);
         ObjectSetInteger(0,"MasIN_L_D1Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_D1Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_W1Button")
        {
         PostMessageA(intParent,0x0111,33141,0);
         ObjectSetInteger(0,"MasIN_L_W1Button",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_W1Button",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_L_MNButton")
        {
         PostMessageA(intParent,0x0111,33334,0);
         ObjectSetInteger(0,"MasIN_L_MNButton",OBJPROP_COLOR,BackgroundColor);
         ObjectSetInteger(0,"MasIN_L_MNButton",OBJPROP_BGCOLOR,TextColor);
        }
      if(sparam=="MasIN_LotSizeButtonPlus")
        {
         LotSize=LotSize+LotStep;
         PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,False);
         if(LotSize>MaximumLot || LotSize<MinimumLotSize)
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
           }
         else
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
           }
         ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
              {
               if(StringFind(ObjectName(i),"_label")>-1)
                 {
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_label","_RS");
                  ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            string OrderButtonText="";
            if(followprice)
              {
               OrderButtonText="Order Buy "+DoubleToString(LotSize,2)+" Lot";
              }
            else
              {
               if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
                 {
                  OrderButtonText="Order Buy Stop "+DoubleToString(LotSize,2)+" Lot";
                 }
               else
                 {
                  OrderButtonText="Order Buy Limit "+DoubleToString(LotSize,2)+" Lot";
                 }
              }
            ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            string OrderButtonText="";
            if(followprice)
              {
               OrderButtonText="Order Sell "+DoubleToString(LotSize,2)+" Lot";
              }
            else
              {
               if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
                 {
                  OrderButtonText="Order Sell Limit "+DoubleToString(LotSize,2)+" Lot";
                 }
               else
                 {
                  OrderButtonText="Order Sell Stop "+DoubleToString(LotSize,2)+" Lot";
                 }
              }
            ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
           }
        }
      if(sparam=="MasIN_LotSizeButtonMinus")
        {
         LotSize=LotSize-LotStep;
         PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,False);
         if(LotSize>MaximumLot || LotSize<MinimumLotSize)
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
           }
         else
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
           }
         ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
              {
               if(StringFind(ObjectName(i),"_label")>-1)
                 {
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_label","_RS");
                  ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
           }
        }
      if(sparam=="MasIN_RiskButtonPlus")
        {
         Risk=Risk+0.1;
         riskmoney=double(AccountInfoDouble(accounttype))/100*Risk;
         ObjectSetString(0,"MasIN_L3C1",OBJPROP_TEXT,"Risk   :     "+DoubleToStr(Risk,2)+"% / "+CurrencyFormat(riskmoney,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MasIN_RiskButtonMinus")
        {
         Risk=Risk-0.1;
         riskmoney=double(AccountInfoDouble(accounttype))/100*Risk;
         ObjectSetString(0,"MasIN_L3C1",OBJPROP_TEXT,"Risk   :     "+DoubleToStr(Risk,2)+"% / "+CurrencyFormat(riskmoney,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MasIN_LineAButtonShow")
        {
         if(showlineA)
           {
            for(i=ObjectsTotal() -1; i>=0; i--)
              {
               if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                 {
                  if(StringFind(ObjectName(i),"_A_label")>-1)
                    {
                     objectline=ObjectName(i);
                     StringReplace(objectline,"_label","_RS");
                     ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
                     ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
                    }
                 }
              }
            showlineA=false;
            tempshowcolor=clrRed;
            ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_COLOR,tempshowcolor);
            ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
           }
         else
           {
            for(i=ObjectsTotal() -1; i>=0; i--)
              {
               if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                 {
                  if(StringFind(ObjectName(i),"_A_label")>-1)
                    {
                     objectline=ObjectName(i);
                     StringReplace(objectline,"_label","_RS");
                     ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
                     ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
                    }
                 }
              }
            showlineA=true;
            tempshowcolor=clrGreen;
            ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_COLOR,tempshowcolor);
            ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
           }
        }
      if(sparam=="MasIN_LineAButtonAlert")
        {
         if(AlarmCrossWhithAlert)
           {
            AlarmCrossWhithAlert=false;
            tempalertcolor=clrRed;
            ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_COLOR,tempalertcolor);
            ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_BORDER_COLOR,tempalertcolor);
           }
         else
           {
            AlarmCrossWhithAlert=true;
            tempalertcolor=clrGreen;
            ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_COLOR,tempalertcolor);
            ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_BORDER_COLOR,tempalertcolor);
           }
        }
      if(sparam=="MasIN_LineAButtonSound")
        {
         //change to next sound
         if(soundname<6)
           {
            soundname+=1;
            ObjectSetString(0,"MasIN_LineAButtonSound",OBJPROP_TEXT,EnumToString(soundname));
           }
         else
           {
            soundname=0;
            ObjectSetString(0,"MasIN_LineAButtonSound",OBJPROP_TEXT,EnumToString(soundname));
           }
        }
      if(sparam=="MasIN_LineQButtonSound")
        {
         //change to next sound
         if(soundnameSecond<6)
           {
            soundnameSecond+=1;
            ObjectSetString(0,"MasIN_LineQButtonSound",OBJPROP_TEXT,EnumToString(soundnameSecond));
           }
         else
           {
            soundnameSecond=0;
            ObjectSetString(0,"MasIN_LineQButtonSound",OBJPROP_TEXT,EnumToString(soundnameSecond));
           }
        }
      if(sparam=="MasIN_LineQButtonShow")
        {
         if(showlineQ)
           {
            for(i=ObjectsTotal() -1; i>=0; i--)
              {
               if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                 {
                  if(StringFind(ObjectName(i),"_Q_label")>-1)
                    {
                     objectline=ObjectName(i);
                     StringReplace(objectline,"_label","_RS");
                     ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
                     ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
                    }
                 }
              }
            showlineQ=false;
            tempshowcolor=clrRed;
            ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_COLOR,tempshowcolor);
            ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
           }
         else
           {
            for(i=ObjectsTotal() -1; i>=0; i--)
              {
               if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                 {
                  if(StringFind(ObjectName(i),"_Q_label")>-1)
                    {
                     objectline=ObjectName(i);
                     StringReplace(objectline,"_label","_RS");
                     ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
                     ObjectSetInteger(0,objectline,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
                    }
                 }
              }
            showlineQ=true;
            tempshowcolor=clrGreen;
            ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_COLOR,tempshowcolor);
            ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_BORDER_COLOR,tempshowcolor);
           }
        }
      if(sparam=="MasIN_LineQButtonAlert")
        {
         if(AlarmCrossWhithAlertSecond)
           {
            AlarmCrossWhithAlertSecond=false;
            tempalertcolor=clrRed;
            ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_COLOR,tempalertcolor);
            ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_BORDER_COLOR,tempalertcolor);
           }
         else
           {
            AlarmCrossWhithAlertSecond=true;
            tempalertcolor=clrGreen;
            ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_COLOR,tempalertcolor);
            ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_BORDER_COLOR,tempalertcolor);
           }
        }
      if((StringFind(sparam,"MasIN_KcSR_"+Symbol())>-1))
        {
         double pricetest=ObjectGet(sparam,OBJPROP_PRICE1);
         linehistory="";
         k=1;
         int NumResist=0;
         int NumSupport=0;
         int NumCrossUp=0;
         int NumCrossDown=0;

         while(k<history)
           {
            if(High[k]-pricetest<MaxDeviation*point)
              {
               NumResist++;
              }
            if(Low[k]-pricetest<MaxDeviation*point)
              {
               NumSupport++;
              }
            if(High[k]>pricetest && Low[k]<pricetest)
              {
               if(Open[k]>Close[k])
                 {
                  NumCrossDown++;
                    }else{
                  NumCrossUp++;
                 }
              }
            k++;
           }
         linehistory="Support : "+IntegerToString(NumSupport)+" | Resist : "+IntegerToString(NumResist)+
                     " | Cross Up/Down: "+IntegerToString(NumCrossUp)+"/"+IntegerToString(NumCrossDown);
         Comment(linehistory);
        }

      if((StringFind(sparam,"MasIN_L0")>-1) || (StringFind(sparam,"MasIN_L1")>-1) || (StringFind(sparam,"MasIN_L2")>-1) || (StringFind(sparam,"MasIN_L3")>-1))
        {
         objectclick=true;
        }

      if(sparam=="MasIN_MMGTbox_TPButton")
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_STATE,false);
         if(CreateTP){CreateTP=false;}else{CreateTP=true;}
         if(CreateTP)
           {
            onoff="TP On";
            onoffcolor=clrGreen;
            string tempotxt;
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               TPprice=ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+SLPips*2;
               PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               tempotxt="Buy";
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               TPprice=ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-SLPips*2;
               PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               tempotxt="Sell";
              }
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+tempotxt,10,"Courier New",ColorTP);
           }
         else
           {
            onoff="TP Off";
            onoffcolor=clrRed;
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
           }
         ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_STATE,false);
         ObjectSetString(0,"MasIN_MMGTbox_TPButton",OBJPROP_TEXT,onoff);
         ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_BORDER_COLOR,onoffcolor);
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MasIN_MMGTbox_SLButton")
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_STATE,false);
         if(CreateSL){CreateSL=false;}else{CreateSL=true;}
         if(CreateSL)
           {
            onoff="SL On";
            onoffcolor=clrGreen;
            string tempotxt;
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               TPprice=ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultSL*point);
               PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               tempotxt="Buy";
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLprice=ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(DefaultSL*point);
               PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               tempotxt="Sell";
              }
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+tempotxt,10,"Courier New",ColorSL);

           }
         else
           {
            onoff="SL Off";
            onoffcolor=clrRed;
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
           }
         ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_STATE,false);
         ObjectSetString(0,"MasIN_MMGTbox_SLButton",OBJPROP_TEXT,onoff);
         ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_BORDER_COLOR,onoffcolor);
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MasIN_MMGTbox_FollowButton")
        {
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
         if(followprice){followprice=false;}else{followprice=true;}
         if(followprice)
           {
            YesNocolor=clrGreen;
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_BORDER_COLOR,YesNocolor);
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
               if(CreateTP)
                 {
                  HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
                  ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
                 }
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
               if(CreateTP)
                 {
                  HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_BID)-TPPips);
                  ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)-TPPips);
                 }
              }
           }
         else
           {
            YesNocolor=clrRed;
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
            ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_BORDER_COLOR,YesNocolor);
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MasIN_MMGTbox_CloseButton")
        {
         GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",0);
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line");
         ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label");
         ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
        }
      if(sparam=="MasIN_MMGTbox_OrderButton")
        {
         int OrderProperties;
         double priceorder=0;
         ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_STATE,false);
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            if(followprice)
              {
               OrderProperties=OP_BUY;
               priceorder=MarketInfo(Symbol(),MODE_ASK);
              }
            else
              {
               priceorder=ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1);
               if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
                 {
                  OrderProperties=OP_BUYSTOP;
                 }
               else
                 {
                  OrderProperties=OP_BUYLIMIT;
                 }
              }
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",10);//10=send
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_OrderProp",OrderProperties);
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_LotSize",LotSize);
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Price",NormalizeDouble(priceorder,Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_SL",NormalizeDouble(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_TP",NormalizeDouble(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_MAGIC",MagicNumber);
           }

         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            if(followprice)
              {
               OrderProperties=OP_SELL;
               priceorder=MarketInfo(Symbol(),MODE_BID);
              }
            else
              {
               priceorder=ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1);
               if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
                 {
                  OrderProperties=OP_SELLLIMIT;
                 }
               else
                 {
                  OrderProperties=OP_SELLSTOP;
                 }
              }
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",10);//10=send
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_OrderProp",OrderProperties);
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_LotSize",LotSize);
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Price",NormalizeDouble(priceorder,Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_SL",NormalizeDouble(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_TP",NormalizeDouble(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_MAGIC",MagicNumber);
           }
        }
      if(sparam=="MasIN_Option_Button_Grid")
        {
         if(ShowGrid){onoff="Grid Off";onoffcolor=clrRed;ShowGrid=false;}else{onoff="Grid On";onoffcolor=clrGreen;ShowGrid=true;}
         ObjectSetInteger(0,"MasIN_Option_Button_Grid",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Button_Grid",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Button_Grid",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Button_Grid",OBJPROP_TEXT,onoff);
         GridColor();
        }
      if(sparam=="MasIN_Option_Show_Price")
        {
         if(ShowPrice){onoff="Off";onoffcolor=clrRed;ShowPrice=false;}else{onoff="On";onoffcolor=clrGreen;ShowPrice=true;}
         ObjectSetInteger(0,"MasIN_Option_Show_Price",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Show_Price",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Show_Price",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Show_Price",OBJPROP_TEXT,onoff);
         GridColor();
        }
      if(sparam=="MasIN_Option_Button_Indicator")
        {
         if(IndicatorValue)
           {
            onoff="Indicator Off";
            onoffcolor=clrRed;
            IndicatorValue=false;
            ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
           }
         else
           {
            onoff="Indicator";
            onoffcolor=clrGreen;
            IndicatorValue=true;
            ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
           }
         ObjectSetInteger(0,"MasIN_Option_Button_Indicator",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Button_Indicator",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Button_Indicator",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Button_Indicator",OBJPROP_TEXT,onoff);

        }
      if(sparam=="MasIN_Option_Button_DailyOpen")
        {
         if(ShowDailyOpen)
           {
            onoff="Daily Off";
            onoffcolor=clrRed;
            ShowDailyOpen=false;
            ArrayInitialize(DailyOpenArray,EMPTY_VALUE);
            SetIndexEmptyValue(0,EMPTY_VALUE);
            ObjectSetInteger(0,"MasIN_Daily_"+Symbol()+"_DO_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
           }
         else
           {
            onoff="Daily On";
            onoffcolor=clrGreen;
            ShowDailyOpen=true;
            DailyOpen();
            ObjectSetInteger(0,"MasIN_Daily_"+Symbol()+"_DO_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
           }
         ObjectSetInteger(0,"MasIN_Option_Button_DailyOpen",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Button_DailyOpen",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Button_DailyOpen",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Button_DailyOpen",OBJPROP_TEXT,onoff);

        }
      if(sparam=="MasIN_Option_Button_Pivot")
        {
         if(ShowPivot)
           {
            onoff="Pivot Off";
            onoffcolor=clrRed;
            ShowPivot=false;
            ArrayInitialize(PPBuffer,EMPTY_VALUE);
            ArrayInitialize(R4Buffer,EMPTY_VALUE);
            ArrayInitialize(R3Buffer,EMPTY_VALUE);
            ArrayInitialize(R2Buffer,EMPTY_VALUE);
            ArrayInitialize(R1Buffer,EMPTY_VALUE);
            ArrayInitialize(S4Buffer,EMPTY_VALUE);
            ArrayInitialize(S3Buffer,EMPTY_VALUE);
            ArrayInitialize(S2Buffer,EMPTY_VALUE);
            ArrayInitialize(S1Buffer,EMPTY_VALUE);
            SetIndexEmptyValue(1,EMPTY_VALUE);
            SetIndexEmptyValue(2,EMPTY_VALUE);
            SetIndexEmptyValue(3,EMPTY_VALUE);
            SetIndexEmptyValue(4,EMPTY_VALUE);
            SetIndexEmptyValue(5,EMPTY_VALUE);
            SetIndexEmptyValue(6,EMPTY_VALUE);
            SetIndexEmptyValue(7,EMPTY_VALUE);
            SetIndexEmptyValue(8,EMPTY_VALUE);
            SetIndexEmptyValue(9,EMPTY_VALUE);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S1_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S2_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S3_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S4_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R1_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R2_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R3_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R4_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_PP_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
           }
         else
           {
            onoff="Pivot On";
            onoffcolor=clrGreen;
            ShowPivot=true;
            PivotLine();
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S1_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S2_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S3_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_S4_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R1_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R2_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R3_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_R4_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_Pivot_"+Symbol()+"_PP_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
           }
         ObjectSetInteger(0,"MasIN_Option_Button_Pivot",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Button_Pivot",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Button_Pivot",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Button_Pivot",OBJPROP_TEXT,onoff);
        }
      if(sparam=="MasIN_Option_Button_PivotFibo")
        {
         if(ShowPivotFibo)
           {
            onoff="Pivot Fibonacci Off";
            onoffcolor=clrRed;
            ShowPivotFibo=false;
            ArrayInitialize(FPPBuffer,EMPTY_VALUE);
            ArrayInitialize(FR3Buffer,EMPTY_VALUE);
            ArrayInitialize(FR2Buffer,EMPTY_VALUE);
            ArrayInitialize(FR1Buffer,EMPTY_VALUE);
            ArrayInitialize(FS3Buffer,EMPTY_VALUE);
            ArrayInitialize(FS2Buffer,EMPTY_VALUE);
            ArrayInitialize(FS1Buffer,EMPTY_VALUE);
            SetIndexEmptyValue(10,EMPTY_VALUE);
            SetIndexEmptyValue(11,EMPTY_VALUE);
            SetIndexEmptyValue(12,EMPTY_VALUE);
            SetIndexEmptyValue(13,EMPTY_VALUE);
            SetIndexEmptyValue(14,EMPTY_VALUE);
            SetIndexEmptyValue(15,EMPTY_VALUE);
            SetIndexEmptyValue(16,EMPTY_VALUE);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S1_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S2_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S3_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R1_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R2_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R3_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_PP_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
           }
         else
           {
            onoff="Pivot Fibonacci On";
            onoffcolor=clrGreen;
            ShowPivotFibo=true;
            PivotLineFibo();
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S1_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S2_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_S3_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R1_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R2_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_R3_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_PivotFib_"+Symbol()+"_PP_label",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
           }
         ObjectSetInteger(0,"MasIN_Option_Button_PivotFibo",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_Option_Button_PivotFibo",OBJPROP_COLOR,onoffcolor);
         ObjectSetInteger(0,"MasIN_Option_Button_PivotFibo",OBJPROP_BORDER_COLOR,onoffcolor);
         ObjectSetString(0,"MasIN_Option_Button_PivotFibo",OBJPROP_TEXT,onoff);
        }
      if(sparam=="MasIN_Option_Button")
        {
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_Option_")>-1)
              {
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
              }
           }
        }
      if(sparam=="MasIN_Option_Button_Backup")
        {
         SaveSupportResistanceToFileBackup();
        }
      if(sparam=="MasIN_L4_BSLM")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(SLTPbrokerLimitnotzero*Point));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(SLTPbrokerLimitnotzero*Point));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BSLM2")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(SLTPbrokerLimitnotzero*Point*2));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(SLTPbrokerLimitnotzero*Point*2));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BSLM3")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(SLTPbrokerLimitnotzero*Point*3));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(SLTPbrokerLimitnotzero*Point*3));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BSLM4")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(SLTPbrokerLimitnotzero*Point*4));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(SLTPbrokerLimitnotzero*Point*4));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BSLM5")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(SLTPbrokerLimitnotzero*Point*5));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(SLTPbrokerLimitnotzero*Point*5));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BSLATR")
        {
         if(CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(iATR(Symbol(),PERIOD_CURRENT,20,0)));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(iATR(Symbol(),PERIOD_CURRENT,20,0)));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BTPRR1")
        {
         if(CreateTP && CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BTPRR2")
        {
         if(CreateTP && CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*2));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*2));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BTPRR3")
        {
         if(CreateTP && CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*3));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*3));
               calculatesell();
              }
           }
        }
      if(sparam=="MasIN_L4_BTPRR4")
        {
         if(CreateTP && CreateSL)
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*4));
               calculatebuy();
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*4));
               calculatesell();
              }
           }
        }
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_CLICK                                                 |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_CLICK)
     {
      if(objectclick)
        {
         objectclick=false;
        }
      else
        {
         ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
         if(price>MarketInfo(Symbol(),MODE_ASK))
           {
            ClickValue=PipValues*((price-MarketInfo(Symbol(),MODE_ASK))/point);
            ClickPip=NormalizeDouble(((price-MarketInfo(Symbol(),MODE_ASK))/point),1);
           }
         else
           {
            ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-price)/point);
            ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-price)/point),1);
           }
         ClickPrice=price;
         ObjectSetString(0,"MasIN_L1C2",OBJPROP_TEXT,"Click : "+DoubleToStr(ClickPrice,Digits)+" / "+DoubleToStr(ClickPip,1)+" / "+CurrencyFormat(ClickValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
        }
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_CHART_CHANGE                                          |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(ratioposition==0)
        {
         ratioposition=0.7;
        }
      int newbarpos = int(WindowFirstVisibleBar()*ratioposition);
      labelposition = Time[newbarpos];
      newbarpos=int(WindowFirstVisibleBar()*0.3);
      orderlabelposition=Time[newbarpos];
      ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,chartheight);
      GridColor();
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_OBJECT_DRAG                                           |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      if(StringFind(sparam,"MasIN_KcSR_"+Symbol())>-1)
        {
         if(StringFind(sparam,"_label")>-1)
           {
            labelposition = datetime(ObjectGet(sparam,OBJPROP_TIME1));
            ratioposition = iBarShift(Symbol(),Period(),labelposition,false)/WindowFirstVisibleBar();
           }
         if(StringFind(sparam,"_RS")>-1)
           {
            string labelline=sparam;
            StringReplace(labelline,"_RS","_label");
            PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-(ObjectGet(sparam,OBJPROP_PRICE1)));
            PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
            ObjectSetString(0,labelline,OBJPROP_TEXT,DoubleToString(MousePrice,Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
            ObjectSetString(0,labelline,OBJPROP_TOOLTIP,DoubleToString(MousePrice,Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
            ObjectSetString(0,sparam,OBJPROP_TOOLTIP,DoubleToString(MousePrice,Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
            ObjectMove(0,labelline,0,labelposition,ObjectGet(sparam,OBJPROP_PRICE1));
           }
        }
      if(StringFind(sparam,"Trendline")>-1 && StringFind(sparam,"MasIN_KcSR_")==-1)
        {
         datetime labelpositiontrend;
         double trendlineposition=ObjectGetValueByTime(0,sparam,labelposition);
         if(ObjectGetValueByTime(0,sparam,labelposition)==0)
           {
            trendlineposition=ObjectGet(sparam,OBJPROP_PRICE1);
            labelpositiontrend=datetime(ObjectGet(sparam,OBJPROP_TIME1));
           }
         else
           {
            labelpositiontrend=labelposition;
           }
         ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+sparam+"_Label",0,labelpositiontrend,trendlineposition);
        }

      if(StringFind(sparam,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
           }
         calculatebuy();
        }
      if(StringFind(sparam,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
           }
         calculatesell();
        }
      if(StringFind(sparam,"MasIN_MMGT_"+Symbol()+"_TP_Line")>-1)
        {
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(StringFind(sparam,"MasIN_MMGT_"+Symbol()+"_SL_Line")>-1)
        {
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }

      if(StringFind(sparam,"MasIN_MMGT_"+Symbol())>-1)
        {
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_KEYDOWN                                               |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==(StringGetChar(MasterHide,0)))
        {
         if(showmaster)
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
            showmaster=false;
           }
         else
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L1C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L1C3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L2C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L2C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_L2C3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetInteger(0,"MasIN_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            if(IndicatorValue)
              {
               ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
               ObjectSetInteger(0,"MasIN_L2C5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
              }
            showmaster=true;
           }
        }
      if(lparam==(StringGetChar("P",0)))
        {
         LotSize=LotSize+LotStep;
         PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,False);
         if(LotSize>MaximumLot || LotSize<MinimumLotSize)
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
           }
         else
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
           }
         ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
              {
               if(StringFind(ObjectName(i),"_label")>-1)
                 {
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_label","_RS");
                  ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
           }
        }
      if(lparam==(StringGetChar("M",0)))
        {
         LotSize=LotSize-LotStep;
         PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,False);
         if(LotSize>MaximumLot || LotSize<MinimumLotSize)
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
           }
         else
           {
            ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
           }
         ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
              {
               if(StringFind(ObjectName(i),"_label")>-1)
                 {
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_label","_RS");
                  ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
           }
        }

      LineId=TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS);

      if(lparam==(StringGetChar(LineHorizontal,0)))
        {
         if(MousePrice>MarketInfo(Symbol(),MODE_BID))
           {
            HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",0,(int(MousePrice/point)*point),LineResistcolor,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
            ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",DoubleToString((int(MousePrice/point)*point),Digits),10,"Courier New",LineResistcolor);
           }
         else
           {
            HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",0,(int(MousePrice/point)*point),LineSupportcolor,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
            ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",DoubleToString((int(MousePrice/point)*point),Digits),10,"Courier New",LineSupportcolor);
           }
         PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-(int(MousePrice/point)*point));
         PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJPROP_TEXT,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJPROP_TOOLTIP,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_TOOLTIP,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetInteger(0,"MasIN_L0C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_L0C3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         SaveSupportResistanceToFile();
        }

      if(lparam==(StringGetChar(LineHorizontalSecond,0)))
        {
         if(MousePrice>MarketInfo(Symbol(),MODE_BID))
           {
            HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",0,(int(MousePrice/point)*point),LineResistcolorSecond,LineStyleSecond,LinewidthSecond,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
            ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",DoubleToString((int(MousePrice/point)*point),Digits),10,"Courier New",LineResistcolorSecond);
           }
         else
           {
            HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",0,(int(MousePrice/point)*point),LineSupportcolorSecond,LineStyleSecond,LinewidthSecond,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
            ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",DoubleToString((int(MousePrice/point)*point),Digits),10,"Courier New",LineSupportcolorSecond);
           }
         PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-(int(MousePrice/point)*point));
         PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJPROP_TEXT,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJPROP_TOOLTIP,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_TOOLTIP,DoubleToString((int(MousePrice/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
         ObjectSetInteger(0,"MasIN_L0C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_L0C3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonAlert",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonShow",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineAButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MasIN_LineQButtonSound",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         SaveSupportResistanceToFile();
        }
      if(lparam==(StringGetChar("L",0)))
        {
         FileToLine();
        }
      if(lparam==(StringGetChar(DeleteLastLine,0)))
        {
         bool labelerase=false;
         bool lineerase=false;
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
              {
               if(StringFind(ObjectName(i),"_label")>-1 && !labelerase)
                 {
                  ObjectDelete(0,ObjectName(i));
                  labelerase=true;
                 }
               if(StringFind(ObjectName(i),"_RS")>-1 && !lineerase)
                 {
                  ObjectDelete(0,ObjectName(i));
                  SaveSupportResistanceToFile();
                  lineerase=true;
                 }
              }
           }
        }

      if(lparam==(StringGetChar(BuyLine,0)))
        {
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label");
           }
         //Buy Line
         if(MathMod(MousePrice,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
           {
            MousePrice=MathRound(MousePrice/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
           }
         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",0,MousePrice,ColorBuySell,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_Buy_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_Buy_Label",DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price",10,"Courier New",ColorBuySell);
         //SL Line
         SLprice=MousePrice -(DefaultSL*point);
         PipGap=(SLprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",ColorSL);
         //TakeProfit
         //SL Line
         TPprice=MousePrice+(DefaultTP*point);
         if(CreateTP)
           {
            PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",ColorTP);
           }
         if(CreateTP)
           {
            SLPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            TPPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            ratio="1:"+DoubleToString((TPPips/SLPips),1);
           }
         else
           {
            ratio="no TP";
           }

         calculatebuy();
        }

      if(lparam==(StringGetChar(SellLine,0)))
        {
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label");
           }
         //Sell Line
         if(MathMod(MousePrice,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
           {
            MousePrice=MathRound(MousePrice/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
           }
         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",0,MousePrice,ColorBuySell,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_Sell_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_Sell_Label",DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price",10,"Courier New",ColorBuySell);
         //SL Line
         SLprice=MousePrice+(DefaultSL*point);
         PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-SLprice);
         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",ColorSL);
         //TakeProfit
         //SL Line
         TPprice=MousePrice-(DefaultTP*point);
         if(CreateTP)
           {
            PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPprice);
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",ColorTP);
           }
         if(CreateTP)
           {
            SLPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            TPPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            ratio="1:"+DoubleToString((TPPips/SLPips),1);
           }
         else
           {
            ratio="no TP";
           }

         calculatesell();
        }
      if(lparam==(StringGetChar(MasterToolConf,0)))
        {
         for(i=ObjectsTotal() -1; i>=0; i--)
           {
            if(StringFind(ObjectName(i),"MasIN_Option_")>-1)
              {
               ObjectSetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
              }
           }
        }
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_OBJECT_ENDEDIT                                        |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      if(sparam=="MasIN_Option_Edit_Grid_Pip")
        {
         string invertaledit;
         ObjectGetString(0,"MasIN_Option_Edit_Grid_Pip",OBJPROP_TEXT,0,invertaledit);
         PipInterval=int(invertaledit);
         GridColor();
        }
      if(sparam=="MasIN_Option_Edit_Grid_Variation")
        {
         string coloredit;
         ObjectGetString(0,"MasIN_Option_Edit_Grid_Variation",OBJPROP_TEXT,0,coloredit);
         ColorVariation=int(coloredit);
         GridColor();
        }
      if(sparam=="MasIN_Option_Edit_Default_SL")
        {
         string SLvalue;
         ObjectGetString(0,"MasIN_Option_Edit_Default_SL",OBJPROP_TEXT,0,SLvalue);
         DefaultSL=double(SLvalue);
        }
      if(sparam=="MasIN_Option_Edit_Default_TP")
        {
         string TPvalue;
         ObjectGetString(0,"MasIN_Option_Edit_Default_TP",OBJPROP_TEXT,0,TPvalue);
         DefaultTP=double(TPvalue);
        }
     }
//+------------------------------------------------------------------+
//| CHARTEVENT_MOUSE_MOVE                                            |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      MousePrice=NormalizeDouble(price,Digits);
      MouseDate=dt;
      ObjectSetString(0,"MasIN_L2C2",OBJPROP_TEXT,"Mouse : "+DoubleToStr(MousePrice,Digits)+" / "+TimeToStr(MouseDate,TIME_DATE|TIME_SECONDS));
      periodmouseover=Period();
      //M1 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_M1Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_M1Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_M1;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //M5 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_M5Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_M5Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_M5;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //M15 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_M15Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_M15Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_M15;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //M30 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_M30Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_M30Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_M30;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //H1 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_H1Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_H1Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_H1;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //H4 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_H4Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_H4Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_H4;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //D1 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_D1Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_D1Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_D1;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //W1 button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_W1Button",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_W1Button",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_W1;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
      //MN button
      if((chartheight-dparam)>0 && (chartheight-dparam)<15 && lparam>ObjectGet("MasIN_L_MNButton",OBJPROP_XDISTANCE) && lparam<ObjectGet("MasIN_L_MNButton",OBJPROP_XDISTANCE)+25)
        {
         periodmouseover=PERIOD_MN1;
         ObjectSetString(0,"MasIN_L2C4",OBJPROP_TEXT,"RSI : "+DoubleToStr(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0),1));
         ObjectSetString(0,"MasIN_L1C4",OBJPROP_TEXT,"STO : "+DoubleToStr(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0),0));
         ObjectSetString(0,"MasIN_L0C5",OBJPROP_TEXT,"MACD: "+DoubleToStr(iMACD(NULL,int(periodmouseover),12,26,9,PRICE_CLOSE,MODE_MAIN,0),6));
         ObjectSetString(0,"MasIN_L0C4",OBJPROP_TEXT,"CCI : "+DoubleToStr(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0),0));
         ObjectSetString(0,"MasIN_L1C5",OBJPROP_TEXT,"MOME: "+DoubleToStr(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0),4));
         IndicatorColor();
        }
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//countdown
   int timenow,second,minute,hour;
   timenow=(int) Time[0]+PeriodSeconds(Period()) -(int) TimeCurrent();
   second=timenow%60;
   minute=(timenow-second);
   if(minute!=0)
     {
      minute=minute/60;
     }
   minute=minute -(minute-minute%60);
   hour=(timenow-second-minute*60);
   if(hour!=0)
     {
      hour=hour/60;
     }
   if(hour!=0)
     {
      hour=hour/60;
     }
   CountDown=IntegerToString(hour,2,'0')+":"+IntegerToString(minute,2,'0')+":"+IntegerToString(second,2,'0');

   ObjectSetString(0,"MasIN_L2C3",OBJPROP_TEXT,"Next Candle : "+CountDown);


   //Timer+=1;
   //if(Timer>5000)
   //  {
   //   Timer=0;
   //  }
     
   int total=OrdersTotal();
   for(int pos=0;pos<total;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()==Symbol())
         //SL and TP alert
         if(SLTPalert)
           {
            if(OrderType()==OP_BUY)
              {
               if(MathAbs(OrderTakeProfit()-MarketInfo(Symbol(),MODE_ASK))/point<(SLTPalertPips))
                 {
                  //if(Timer>30)
                  //  {
                     //PlaySound("");
                     PlaySound("sltpalarm.wav");
                    // Timer=1;
                    //}
                 }
               if(MathAbs(OrderStopLoss()-MarketInfo(Symbol(),MODE_ASK))/point<(SLTPalertPips))
                 {
                  //if(Timer>30)
                  //  {
                  //   PlaySound("");
                     PlaySound("sltpalarm.wav");
                    // Timer=1;
                    //}
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(MathAbs(OrderTakeProfit()-MarketInfo(Symbol(),MODE_BID))/point<(SLTPalertPips))
                 {
                  //if(Timer>30)
                  //  {
                  //   PlaySound("");
                     PlaySound("sltpalarm.wav");
                    // Timer=1;
                    //}
                 }
               if(MathAbs(OrderStopLoss()-MarketInfo(Symbol(),MODE_BID))/point<(SLTPalertPips))
                 {
                  //if(Timer>30)
                  //  {
                  //   PlaySound("");
                     PlaySound("sltpalarm.wav");
                    // Timer=1;
                    //}
                 }
              }
           }
     }
  }
//+------------------------------------------------------------------+
//| CurrencyFormat                                                   |
//+------------------------------------------------------------------+
string CurrencyFormat(const double Number=0,
                      const string IsoCurrency="EUR",
                      const bool   CurrencyPosition=true)
  {
   string CurFormat;
   if(IsoCurrency=="ALL"){ CurFormat="\x4c"+"\x65"+"\x6b";}
   if( IsoCurrency == "AFN"){ CurFormat ="\x60b";CurFormat ="AFN";}
   if( IsoCurrency == "ARS"){ CurFormat ="\x24";}
   if( IsoCurrency == "AWG"){ CurFormat ="\x192";}
   if( IsoCurrency == "AUD"){ CurFormat ="\x24";}
   if( IsoCurrency == "AZN"){ CurFormat ="\x43c"+"\x430"+"\x43d";CurFormat ="AZN";}
   if( IsoCurrency == "BSD"){ CurFormat ="\x24";}
   if( IsoCurrency == "BBD"){ CurFormat ="\x24";}
   if( IsoCurrency == "BYR"){ CurFormat ="\x70"+"\x2e";}
   if( IsoCurrency == "BZD"){ CurFormat ="\x42"+"\x5a"+"\x24";}
   if( IsoCurrency == "BMD"){ CurFormat ="\x24";}
   if( IsoCurrency == "BOB"){ CurFormat ="\x24"+"\x62";}
   if( IsoCurrency == "BAM"){ CurFormat ="\x4b"+"\x4d";}
   if( IsoCurrency == "BWP"){ CurFormat ="\x50";}
   if( IsoCurrency == "BGN"){ CurFormat ="\x43b"+"\x432";CurFormat ="BGN";}
   if( IsoCurrency == "BRL"){ CurFormat ="\x52"+"\x24";}
   if( IsoCurrency == "BND"){ CurFormat ="\x24";}
   if( IsoCurrency == "KHR"){ CurFormat ="\x17db";CurFormat ="KHR";}
   if( IsoCurrency == "CAD"){ CurFormat ="\x24";}
   if( IsoCurrency == "KYD"){ CurFormat ="\x24";}
   if( IsoCurrency == "CLP"){ CurFormat ="\x24";}
   if( IsoCurrency == "CNY"){ CurFormat ="\xa5";}
   if( IsoCurrency == "COP"){ CurFormat ="\x24";}
   if( IsoCurrency == "CRC"){ CurFormat ="\x20a1";}
   if( IsoCurrency == "HRK"){ CurFormat ="\x6b"+"\x6e";}
   if( IsoCurrency == "CUP"){ CurFormat ="\x20b1";CurFormat ="CUP";}
   if( IsoCurrency == "CZK"){ CurFormat ="\x4b"+"\x10d";}
   if( IsoCurrency == "DKK"){ CurFormat ="\x6b"+"\x72";}
   if( IsoCurrency == "DOP"){ CurFormat ="\x52"+"\x44"+"\x24";}
   if( IsoCurrency == "XCD"){ CurFormat ="\x24";}
   if( IsoCurrency == "EGP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "SVC"){ CurFormat ="\x24";}
   if( IsoCurrency == "EEK"){ CurFormat ="\x6b"+"\x72";}
   if( IsoCurrency == "EUR"){ CurFormat ="\x20ac";}
   if( IsoCurrency == "FKP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "FJD"){ CurFormat ="\x24";}
   if( IsoCurrency == "GHC"){ CurFormat ="\xa2";}
   if( IsoCurrency == "GIP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "GTQ"){ CurFormat ="\x51";}
   if( IsoCurrency == "GGP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "GYD"){ CurFormat ="\x24";}
   if( IsoCurrency == "HNL"){ CurFormat ="\x4c";}
   if( IsoCurrency == "HKD"){ CurFormat ="\x24";}
   if( IsoCurrency == "HUF"){ CurFormat ="\x46"+"\x74";}
   if( IsoCurrency == "ISK"){ CurFormat ="\x6b"+"\x72";}
   if( IsoCurrency == "INR"){ CurFormat ="\x20B9";CurFormat ="INR";}
   if( IsoCurrency == "IDR"){ CurFormat ="\x52"+"\x70";}
   if( IsoCurrency == "IRR"){ CurFormat ="\xfdfc";}
   if( IsoCurrency == "IMP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "ILS"){ CurFormat ="\x20aa";CurFormat ="ILS";}
   if( IsoCurrency == "JMD"){ CurFormat ="\x4a"+"\x24";}
   if( IsoCurrency == "JPY"){ CurFormat ="\xa5";}
   if( IsoCurrency == "JEP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "KZT"){ CurFormat ="\x43b"+"\x432";CurFormat ="KZT";}
   if( IsoCurrency == "KPW"){ CurFormat ="\x20a9";CurFormat ="KPW";}
   if( IsoCurrency == "KRW"){ CurFormat ="\x20a9";CurFormat ="KRW";}
   if( IsoCurrency == "KGS"){ CurFormat ="\x43b"+"\x432";CurFormat ="KGS";}
   if( IsoCurrency == "LAK"){ CurFormat ="\x20ad";CurFormat ="LAK";}
   if( IsoCurrency == "LVL"){ CurFormat ="\x4c"+"\x73";}
   if( IsoCurrency == "LBP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "LRD"){ CurFormat ="\x24";}
   if( IsoCurrency == "LTL"){ CurFormat ="\x4c"+"\x74";}
   if( IsoCurrency == "MKD"){ CurFormat ="\x434"+"\x435"+"\x43d";CurFormat ="MKD";}
   if( IsoCurrency == "MYR"){ CurFormat ="\x52"+"\x4d";}
   if( IsoCurrency == "MUR"){ CurFormat ="\x20a8";}
   if( IsoCurrency == "MXN"){ CurFormat ="\x24";}
   if( IsoCurrency == "MNT"){ CurFormat ="\x20ae";CurFormat ="MNT";}
   if( IsoCurrency == "MZN"){ CurFormat ="\x4d"+"\x54";}
   if( IsoCurrency == "NAD"){ CurFormat ="\x24";}
   if( IsoCurrency == "NPR"){ CurFormat ="\x20a8";CurFormat ="NPR";}
   if( IsoCurrency == "ANG"){ CurFormat ="\x192";}
   if( IsoCurrency == "NZD"){ CurFormat ="\x24";}
   if( IsoCurrency == "NIO"){ CurFormat ="\x43"+"\x24";}
   if( IsoCurrency == "NGN"){ CurFormat ="\x20a6";CurFormat ="NGN";}
   if( IsoCurrency == "NOK"){ CurFormat ="\x6b"+"\x72";}
   if( IsoCurrency == "OMR"){ CurFormat ="\xfdfc";CurFormat ="OMR";}
   if( IsoCurrency == "PKR"){ CurFormat ="\x20a8";CurFormat ="PKR";}
   if( IsoCurrency == "PAB"){ CurFormat ="\x42"+"\x2f"+"\x2e";}
   if( IsoCurrency == "PYG"){ CurFormat ="\x47"+"\x73";}
   if( IsoCurrency == "PEN"){ CurFormat ="\x53"+"\x2f"+"\x2e";}
   if( IsoCurrency == "PHP"){ CurFormat ="\x20b1";CurFormat ="PHP";}
   if( IsoCurrency == "PLN"){ CurFormat ="\x7a"+"\x142";}
   if( IsoCurrency == "QAR"){ CurFormat ="\xfdfc";CurFormat ="QAR";}
   if( IsoCurrency == "RON"){ CurFormat ="\x6c"+"\x65"+"\x69";}
   if( IsoCurrency == "RUB"){ CurFormat ="\x440"+"\x443"+"\x431";CurFormat ="RUB";}
   if( IsoCurrency == "SHP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "SAR"){ CurFormat ="\xfdfc";CurFormat ="SAR";}
   if( IsoCurrency == "RSD"){ CurFormat ="\x414"+"\x438"+"\x43d"+"\x2e";CurFormat ="RSD";}
   if( IsoCurrency == "SCR"){ CurFormat ="\x20a8";CurFormat ="SCR";}
   if( IsoCurrency == "SGD"){ CurFormat ="\x24";}
   if( IsoCurrency == "SBD"){ CurFormat ="\x24";}
   if( IsoCurrency == "SOS"){ CurFormat ="\x53";}
   if( IsoCurrency == "ZAR"){ CurFormat ="\x52";}
   if( IsoCurrency == "LKR"){ CurFormat ="\x20a8";CurFormat ="LKR";}
   if( IsoCurrency == "SEK"){ CurFormat ="\x6b"+"\x72";}
   if( IsoCurrency == "CHF"){ CurFormat ="\x43"+"\x48"+"\x46";}
   if( IsoCurrency == "SRD"){ CurFormat ="\x24";}
   if( IsoCurrency == "SYP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "TWD"){ CurFormat ="\x4e"+"\x54"+"\x24";}
   if( IsoCurrency == "THB"){ CurFormat ="\xe3f";CurFormat ="THB";}
   if( IsoCurrency == "TTD"){ CurFormat ="\x54"+"\x54"+"\x24";}
   if( IsoCurrency == "TRL"){ CurFormat ="\x20a4";}
   if( IsoCurrency == "TVD"){ CurFormat ="\x24";}
   if( IsoCurrency == "UAH"){ CurFormat ="\x20b4";CurFormat ="UAH";}
   if( IsoCurrency == "GBP"){ CurFormat ="\xa3";}
   if( IsoCurrency == "USD"){ CurFormat ="\x24";}
   if( IsoCurrency == "UYU"){ CurFormat ="\x24"+"\x55";}
   if( IsoCurrency == "UZS"){ CurFormat ="\x43b"+"\x432";CurFormat ="UZS";}
   if( IsoCurrency == "VEF"){ CurFormat ="\x42"+"\x73";}
   if( IsoCurrency == "VND"){ CurFormat ="\x20ab";CurFormat ="VND";}
   if( IsoCurrency == "YER"){ CurFormat ="\xfdfc";CurFormat ="YER";}
   if( IsoCurrency == "ZWD"){ CurFormat ="\x5a"+"\x24";}
   if(CurrencyPosition)
     {
      CurFormat=DoubleToStr(Number,2)+CurFormat;
     }
   else
     {
      CurFormat=CurFormat+DoubleToStr(Number,2);
     }
   return CurFormat;
  }
//+------------------------------------------------------------------+
//| ButtonCreate                                                     |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,// chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               xx=0,                      // X coordinate
                  const int               yy=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  cornerr=CORNER_LEFT_UPPER,// chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return(false);
        }
      //--- set button coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
      //--- set button size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,cornerr);
      //--- set the text
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set text color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- set border color
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- set button state
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      //--- enable (true) or disable (false) the mode of moving the button by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| EditCreate                                                       |
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID=0,// chart's ID
                const string           name="Edit",              // object name
                const int              sub_window=0,             // subwindow index
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const int              font_size=10,             // font size
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE,       // border color
                const bool             back=false,               // in the background
                const bool             selection=false,          // highlight to move
                const bool             hidden=true,              // hidden in the object list
                const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create edit field
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create \"Edit\" object! Error code = ",GetLastError());
         return(false);
        }
      //--- set object coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- set object size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- set the text
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set the type of text alignment in the object
      ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
      //--- enable (true) or cancel (false) read-only mode
      ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
      //--- set the chart's corner, relative to which object coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- set text color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- set border color
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   GlobalVariableSet("MasIN_Lot_"+string(intParent),LotSize);
   GlobalVariableSet("MasIN_Risk_"+string(intParent),Risk);
   GlobalVariableSet("MasIN_ClickPrice_"+string(intParent),ClickPrice);
   GlobalVariableSet("MasIN_showlineA"+string(intParent),showlineA);
   GlobalVariableSet("MasIN_AlarmCrossWhithAlert"+string(intParent),AlarmCrossWhithAlert);
   GlobalVariableSet("MasIN_showlineQ"+string(intParent),showlineQ);
   GlobalVariableSet("MasIN_AlarmCrossWhithAlertSecond"+string(intParent),AlarmCrossWhithAlertSecond);
   GlobalVariableSet("MasIN_soundname"+string(intParent),soundname);
   GlobalVariableSet("MasIN_soundnameSecond"+string(intParent),soundnameSecond);
   GlobalVariableSet("MasIN_IndicatorValue"+string(intParent),IndicatorValue);
   GlobalVariableSet("MasIN_ShowDailyOpen"+string(intParent),ShowDailyOpen);
   GlobalVariableSet("MasIN_ShowGrid"+string(intParent),ShowGrid);
   GlobalVariableSet("MasIN_ShowPivot"+string(intParent),ShowPivot);
   GlobalVariableSet("MasIN_ShowPivotFibo"+string(intParent),ShowPivotFibo);
   GlobalVariableSet("MasIN_"+Symbol()+"_DefaultSL"+string(intParent),DefaultSL);
   GlobalVariableSet("MasIN_"+Symbol()+"_DefaultTP"+string(intParent),DefaultTP);
   GlobalVariableSet("MasIN_"+Symbol()+"_SLTPalert"+string(intParent),SLTPalert);
   GlobalVariableSet("MasIN_"+Symbol()+"_PipInterval"+string(intParent),PipInterval);
   GlobalVariableSet("MasIN_ColorVariation"+string(intParent),ColorVariation);
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN")>-1)
        {
         if(!(StringFind(ObjectName(i),"MasIN_KcSR")>-1))
            ObjectDelete(0,ObjectName(i));
        }

     }
   return;
  }
//+------------------------------------------------------------------+
//| HLineCreate                                                      |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID
                 const string          name="HLine_max",// line name
                 const int             sub_window=0,// subwindow index
                 double                hprice=0,// line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0,         // priority for mouse click
                 const string          tooltip="")
  {
   ObjectDelete(chart_ID,name);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,hprice))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| HLineMove                                                        |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,// chart's ID
               const string name="HLine",// line name
               double       pricel=0) // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!pricel)
      pricel=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,pricel))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| calculatebuy                                                     |
//+------------------------------------------------------------------+
void calculatebuy()
  {
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
//if(SLPips==0)
//  {
//   HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultSL));
//  }
   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
      //if(TPPips==0)
      //  {
      //   HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(DefaultTP));
      //  }

      if(!SLPips==0)
        {
         ratio="1:"+DoubleToString((TPPips/SLPips),1);
        }
     }
   else
     {
      ratio="";
     }
   if(SLPips!=0)
     {
      LotSize=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);;
      LotSize=MathRound(LotSize/LotStep)*LotStep;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   if(LotSize>MaximumLot || LotSize<MinimumLotSize)
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
     }
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

   ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   if(GlobalVariableGet("MasIN_MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

   string OrderButtonText="";
   if(followprice)
     {
      OrderButtonText="Order Buy "+DoubleToString(LotSize,2)+" Lot";
     }
   else
     {
      if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
        {
         OrderButtonText="Order Buy Stop "+DoubleToString(LotSize,2)+" Lot";
        }
      else
        {
         OrderButtonText="Order Buy Limit "+DoubleToString(LotSize,2)+" Lot";
        }
     }
   ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
  }
//+------------------------------------------------------------------+
//| calculatesell                                                    |
//+------------------------------------------------------------------+
void calculatesell()
  {

   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
      if(!SLPips==0)
        {
         ratio="1:"+DoubleToString((TPPips/SLPips),1);
        }
     }
   else
     {
      ratio="";
     }
   if(SLPips!=0)
     {
      LotSize=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);
      LotSize=MathRound(LotSize/LotStep)*LotStep;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   if(LotSize>MaximumLot || LotSize<MinimumLotSize)
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
     }
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot    :     "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

   ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   if(GlobalVariableGet("MasIN_MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

   string OrderButtonText="";
   if(followprice)
     {
      OrderButtonText="Order Sell "+DoubleToString(LotSize,2)+" Lot";
     }
   else
     {
      if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
        {
         OrderButtonText="Order Sell Limit "+DoubleToString(LotSize,2)+" Lot";
        }
      else
        {
         OrderButtonText="Order Sell Stop "+DoubleToString(LotSize,2)+" Lot";
        }
     }
   ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
  }
//+------------------------------------------------------------------+
//| StringChangeToUpperCase                                          |
//+------------------------------------------------------------------+

string StringChangeToUpperCase(string sText)
  {
   int iLen=StringLen(sText),i;
   ushort iChar;
   for(i=0; i<iLen; i++)
     {
      iChar=StringGetChar(sText,i);
      if(iChar>=97 && iChar<=122) sText=StringSetChar(sText,i,ushort(iChar-32));
     }
   return(sText);
  }
//+------------------------------------------------------------------+
//| Indicator color                                                    |
//+------------------------------------------------------------------+
void IndicatorColor()
  {
//RSI
   if(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)<=20)
     {
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_COLOR,clrChocolate);
     }
   if(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)>20 && iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)<=45)
     {
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_COLOR,clrRed);
     }
   if(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)>45 && iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)<=55)
     {
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_COLOR,TextColor);
     }
   if(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)>55 && iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)<=80)
     {
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_COLOR,clrGreen);
     }
   if(iRSI(Symbol(),int(periodmouseover),14,PRICE_CLOSE,0)>80)
     {
      ObjectSetInteger(0,"MasIN_L2C4",OBJPROP_COLOR,clrDarkOliveGreen);
     }
//Stochastic
   if(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)<=20)
     {
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_COLOR,clrChocolate);
     }
   if(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)>20 && iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)<45)
     {
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_COLOR,clrRed);
     }
   if(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)>=45 && iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)<=55)
     {
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_COLOR,TextColor);
     }
   if(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)>55 && iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)<80)
     {
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_COLOR,clrGreen);
     }
   if(iStochastic(Symbol(),int(periodmouseover),9,6,3,MODE_SMA,1,MODE_SIGNAL,0)>=80)
     {
      ObjectSetInteger(0,"MasIN_L1C4",OBJPROP_COLOR,clrDarkOliveGreen);
     }
//MACD
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)<0)
     {
      ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_COLOR,clrRed);
     }
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)==0)
     {
      ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_COLOR,TextColor);
     }
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)>0)
     {
      ObjectSetInteger(0,"MasIN_L0C5",OBJPROP_COLOR,clrGreen);
     }
//CCI 
   if(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)<=-100)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_COLOR,clrChocolate);
     }
   if(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)>-100 && iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)<=-50)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_COLOR,clrRed);
     }
   if(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)>-50 && iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)<=50)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_COLOR,TextColor);
     }
   if(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)>50 && iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)<=100)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_COLOR,clrGreen);
     }
   if(iCCI(Symbol(),int(periodmouseover),12,PRICE_TYPICAL,0)>100)
     {
      ObjectSetInteger(0,"MasIN_L0C4",OBJPROP_COLOR,clrDarkOliveGreen);
     }
//Momentum
   if(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0)>100)
     {
      ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_COLOR,clrGreen);
     }
   if(iMomentum(Symbol(),int(periodmouseover),12,PRICE_CLOSE,0)<100)
     {
      ObjectSetInteger(0,"MasIN_L1C5",OBJPROP_COLOR,clrRed);
     }
  }
//+------------------------------------------------------------------+
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,// chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index 
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle! Error code = ",GetLastError());
         return(false);
        }
      //--- set rectangle color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set the style of rectangle lines
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      //--- set width of the rectangle lines
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
      //--- when creating a graphical object using ObjectCreate function, the object cannot be
      //--- highlighted and moved by default. Inside this method, selection parameter
      //--- is true by default making it possible to highlight and move the object
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of rectangle's anchor points and set default    |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,// chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
   if(ObjectFind(chart_ID,name)<0)
     {
      //--- create a rectangle label
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle label! Error code = ",GetLastError());
         return(false);
        }
      //--- set label coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- set label size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- set border type
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- set flat border color (in Flat mode)
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set flat border line style
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      //--- set flat border width
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| GridColor                                                        |
//+------------------------------------------------------------------+
void GridColor()
  {
   double m;
   double pipinterval=PipInterval*point;
   int    b=0;
   int digit=Digits;

   if((Digits==3) || (Digits==5) || (Digits==1))
     {
      digit=Digits-1;
     }
   double firsstartprice=int((int(WindowPriceMin()/point))/PipInterval)*PipInterval*point;
   double lastprice= int((WindowPriceMax()+pipinterval)/pipinterval)*pipinterval;
   bool   colorgrid=false;
   long   colorbackground=clrNONE;
   long   coloralternative;
   int    i;
   int    numbershow=int((WindowPriceMax()-WindowPriceMin())/pipinterval);
   long   variationin;

   ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,colorbackground);
   if(colorbackground>9000000)
     {
      coloralternative=colorbackground -(1118481*ColorVariation);
      variationin=colorbackground -(1118481*(ColorVariation+2));
     }
   else
     {
      coloralternative=colorbackground+(1118481*ColorVariation);
      variationin=colorbackground+(1118481*(ColorVariation+2));
     }
   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MasIN_Grid_")>-1)
        {
         ObjectDelete(0,ObjectName(i));
        }
     }
   double testprice=MathCeil(firsstartprice/point/PipInterval);
   if(MathMod(testprice,2)==0)
     {
      colorgrid=true;
     }
   if(ShowGrid)
     {
      for(m=firsstartprice;m<lastprice;m+=pipinterval)
        {
         b+=1;
         if(colorgrid)
           {
            colorgrid=false;
            if(( Bid>m && Bid<(m+pipinterval)))
              {
               GridLow=m;
               GridHigh=m+pipinterval;
               RectangleCreate(0,"MasIN_Grid_"+string(m),0,Time[WindowFirstVisibleBar()],m,Time[0]+(Period()*800),(m+pipinterval),color(variationin),STYLE_SOLID,1,true,true,false,false,0);
              }
            else
              {
               RectangleCreate(0,"MasIN_Grid_"+string(m),0,Time[WindowFirstVisibleBar()],m,Time[0]+(Period()*800),(m+pipinterval),color(coloralternative),STYLE_SOLID,1,true,true,false,false,0);
              }
            if(ShowPrice && numbershow<=110)
              {
               ArrowRightPriceCreate(0,"MasIN_Grid_Price_"+string(b),0,0,m,clrGray,STYLE_SOLID,1,false,false,false,0);
              }
            b+=1;
           }
         else
           {
            colorgrid=true;
            if(( Bid>m && Bid<(m+pipinterval)))
              {
               GridLow=m;
               GridHigh=m+pipinterval;
               RectangleCreate(0,"MasIN_Grid_"+string(m),0,Time[WindowFirstVisibleBar()],m,Time[0]+(Period()*800),(m+pipinterval),color(variationin),STYLE_SOLID,1,true,true,false,false,0);
              }
            else
              {
               //RectangleCreate(0,"MasIN_Grid_"+string(m),0,Time[WindowFirstVisibleBar()],m,Time[0]+(Period()*800),(m+pipinterval),color(colorbackground),STYLE_SOLID,1,true,true,false,false,0);
              }
            if(ShowPrice && numbershow<=60) //if numbershow >60 too much Price and its not readable
              {
               ArrowRightPriceCreate(0,"MasIN_Grid_Price_"+string(b),0,0,m,clrGray,STYLE_SOLID,1,false,false,false,0);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| DailyOpen                                                        |
//+------------------------------------------------------------------+
int DailyOpen()
  {
   int i;
   double openat= iOpen(Symbol(),PERIOD_D1,0);
   int BarsCount=iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,0));
   ObjectCreate("MasIN_Daily_"+Symbol()+"_DO_label",OBJ_TEXT,0,Time[2],openat);
   ObjectMove(0,"MasIN_Daily_"+Symbol()+"_DO_label",0,Time[2],openat);
   ObjectSetText("MasIN_Daily_"+Symbol()+"_DO_label","Daily Open",7,"Courier New",clrGray);

   for(i=1; i<BarsCount; i++)
     {
      DailyOpenArray[i]=openat;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Create the right price label                                     |
//+------------------------------------------------------------------+
bool ArrowRightPriceCreate(const long            chart_ID=0,// chart's ID
                           const string          name="RightPrice", // price label name
                           const int             sub_window=0,      // subwindow index
                           datetime              time=0,            // anchor point time
                           double                price=0,           // anchor point price
                           const color           clr=clrRed,        // price label color
                           const ENUM_LINE_STYLE style=STYLE_SOLID, // border line style
                           const int             width=1,           // price label size
                           const bool            back=false,        // in the background
                           const bool            selection=true,    // highlight to move
                           const bool            hidden=true,       // hidden in the object list
                           const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a price label
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create the right price label! Error code = ",GetLastError());
      return(false);
     }
//--- set the label color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the label size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//| PivotLine                                                        |
//+------------------------------------------------------------------+
int PivotLine()
  {
   double yesterdayhight=iHigh(NULL,PERIOD_D1,1);
   double yesterdaylow=iLow(NULL,PERIOD_D1,1);
   double yesterdayclose=iClose(Symbol(),PERIOD_D1,1);
   double pivot=(yesterdayhight+yesterdaylow+yesterdayclose)/3;
   double r4 = pivot + ((yesterdayhight - yesterdaylow)*3);
   double r3 = pivot + ((yesterdayhight - yesterdaylow)*2);
   double r2 = pivot + ((yesterdayhight - yesterdaylow));
   double r1 = (2 * pivot) - yesterdaylow;
   double s1 = (2 * pivot) - yesterdayhight;
   double s2 = pivot - (yesterdayhight - yesterdaylow);
   double s3 = pivot - ((yesterdayhight - yesterdaylow)*2);
   double s4 = pivot - ((yesterdayhight - yesterdaylow)*3);
   int i;

   ObjectCreate("MasIN_Pivot_"+Symbol()+"_S1_label",OBJ_TEXT,0,Time[2],s1);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_S1_label",0,Time[2],s1);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_S1_label","Classic Pivot S1",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_S2_label",OBJ_TEXT,0,Time[2],s2);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_S2_label",0,Time[2],s2);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_S2_label","Classic Pivot S2",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_S3_label",OBJ_TEXT,0,Time[2],s3);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_S3_label",0,Time[2],s3);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_S3_label","Classic Pivot S3",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_S4_label",OBJ_TEXT,0,Time[2],s4);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_S4_label",0,Time[2],s4);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_S4_label","Classic Pivot S4",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_R1_label",OBJ_TEXT,0,Time[2],r1);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_R1_label",0,Time[2],r1);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_R1_label","Classic Pivot R1",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_R2_label",OBJ_TEXT,0,Time[2],r2);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_R2_label",0,Time[2],r2);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_R2_label","Classic Pivot R2",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_R3_label",OBJ_TEXT,0,Time[2],r3);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_R3_label",0,Time[2],r3);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_R3_label","Classic Pivot R3",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_R4_label",OBJ_TEXT,0,Time[2],r4);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_R4_label",0,Time[2],r4);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_R4_label","Classic Pivot R4",7,"Courier New",clrGray);
   ObjectCreate("MasIN_Pivot_"+Symbol()+"_PP_label",OBJ_TEXT,0,Time[2],pivot);
   ObjectMove(0,"MasIN_Pivot_"+Symbol()+"_PP_label",0,Time[2],pivot);
   ObjectSetText("MasIN_Pivot_"+Symbol()+"_PP_label","Pivot P",7,"Courier New",clrGray);

   int BarsCount=iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,0));
   for(i=0; i<BarsCount; i++)
     {
      PPBuffer[i]=pivot;
      R4Buffer[i]=r4;
      R3Buffer[i]=r3;
      R2Buffer[i]=r2;
      R1Buffer[i]=r1;
      S1Buffer[i]=s1;
      S2Buffer[i]=s2;
      S3Buffer[i]=s3;
      S4Buffer[i]=s4;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| PivotLineFibo                                                    |
//+------------------------------------------------------------------+
int PivotLineFibo()
  {
   double yesterdayhight=iHigh(NULL,PERIOD_D1,1);
   double yesterdaylow=iLow(NULL,PERIOD_D1,1);
   double yesterdayclose=iClose(Symbol(),PERIOD_D1,1);
   double pivot=(yesterdayhight+yesterdaylow+yesterdayclose)/3;
   double r3 = pivot + ((yesterdayhight - yesterdaylow)*1);
   double r2 = pivot + ((yesterdayhight - yesterdaylow)*0.618);
   double r1 = pivot + ((yesterdayhight - yesterdaylow)*0.382);
   double s1 = pivot - ((yesterdayhight - yesterdaylow)*0.382);
   double s2 = pivot - ((yesterdayhight - yesterdaylow)*0.618);
   double s3 = pivot - ((yesterdayhight - yesterdaylow)*1);
   int i;

   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_S1_label",OBJ_TEXT,0,Time[2],s1);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_S1_label",0,Time[2],s1);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_S1_label","Fibot Pivot S1",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_S2_label",OBJ_TEXT,0,Time[2],s2);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_S2_label",0,Time[2],s2);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_S2_label","Fibot Pivot S2",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_S3_label",OBJ_TEXT,0,Time[2],s3);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_S3_label",0,Time[2],s3);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_S3_label","Fibot Pivot S3",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_R1_label",OBJ_TEXT,0,Time[2],r1);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_R1_label",0,Time[2],r1);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_R1_label","Fibot Pivot R1",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_R2_label",OBJ_TEXT,0,Time[2],r2);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_R2_label",0,Time[2],r2);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_R2_label","Fibot Pivot R2",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_R3_label",OBJ_TEXT,0,Time[2],r3);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_R3_label",0,Time[2],r3);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_R3_label","Fibot Pivot R3",7,"Courier New",clrGray);
   ObjectCreate("MasIN_PivotFib_"+Symbol()+"_PP_label",OBJ_TEXT,0,Time[2],pivot);
   ObjectMove(0,"MasIN_PivotFib_"+Symbol()+"_PP_label",0,Time[2],pivot);
   ObjectSetText("MasIN_PivotFib_"+Symbol()+"_PP_label","Pivot P",7,"Courier New",clrGray);

   int BarsCount=iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,0));
   for(i=0; i<BarsCount; i++)
     {
      FPPBuffer[i]=pivot;
      FR3Buffer[i]=r3;
      FR2Buffer[i]=r2;
      FR1Buffer[i]=r1;
      FS1Buffer[i]=s1;
      FS2Buffer[i]=s2;
      FS3Buffer[i]=s3;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| SaveSupportResistanceToFile                                      |
//+------------------------------------------------------------------+
int SaveSupportResistanceToFile()
  {
   FileDelete("SupportResistance-"+Symbol()+"-.csv");
   int handle=FileOpen("SupportResistance-"+Symbol()+"-.csv",FILE_CSV|FILE_READ|FILE_WRITE,';');
   if(handle<1)
     {
      Print("File SupportResistance-"+Symbol()+"-.csv not found, the last error is ",GetLastError());
      return(false);
     }
   else
     {
      for(int i=ObjectsTotal() -1; i>=0; i--)
        {

         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_A_RS")>-1)
              {
               FileWrite(handle,Symbol(),ObjectGet(ObjectName(i),OBJPROP_PRICE1),"A");
              }
            if(StringFind(ObjectName(i),"_Q_RS")>-1)
              {
               FileWrite(handle,Symbol(),ObjectGet(ObjectName(i),OBJPROP_PRICE1),"Q");
              }
           }
        }
     }
   FileClose(handle);
   return(0);
  }
//+------------------------------------------------------------------+
//| File To Support Resistance                                       |
//+------------------------------------------------------------------+
int FileToLine()
  {
   string     arr[3];
   int        iname=0;
   if(FileIsExist("SupportResistance-"+Symbol()+"-.csv"))
     {
      int handle=FileOpen("SupportResistance-"+Symbol()+"-.csv",FILE_CSV|FILE_READ,'~');
      if(handle<1)
        {
         Print("File SupportResistance-"+Symbol()+"-.csv not found, the last error is ",GetLastError());
         return(false);
        }
      else
        {
         while(!FileIsEnding(handle))
           {
            string tmp=FileReadString(handle);
            iname+=1;
            bool CreateLine=true;
            if(FileIsEnding(handle)) break;
            int k=StringSplit(tmp,StringGetChar(";",0),arr);
            //arr[0] Symbol;
            //arr[1] Price;
            //arr[2] Line Style;

            if(arr[2]==LineHorizontal)
              {
               for(int i=ObjectsTotal() -1; i>=0; i--)
                 {
                  if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                    {
                     if(StringFind(ObjectName(i),"_A_RS")>-1)
                       {
                        if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)==double(arr[1]))
                          {
                           CreateLine=false;
                          }
                       }
                    }
                 }
               if(CreateLine)
                 {
                  LineId=TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS)+string(iname);
                  if(double(arr[1])>MarketInfo(Symbol(),MODE_BID))
                    {
                     HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",0,((double(arr[1])/point)*point),LineResistcolor,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
                     ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
                     ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
                     ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",DoubleToString((int(double(arr[1])/point)*point),Digits),10,"Courier New",LineResistcolor);
                    }
                  else
                    {
                     HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",0,((double(arr[1])/point)*point),LineSupportcolor,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
                     ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
                     ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_PRICE1));
                     ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",DoubleToString((int(double(arr[1])/point)*point),Digits),10,"Courier New",LineSupportcolor);
                    }

                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-((double(arr[1])/point)*point));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJPROP_TEXT,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_label",OBJPROP_TOOLTIP,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_A_RS",OBJPROP_TOOLTIP,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
            if(arr[2]==LineHorizontalSecond)
              {
               for(int i=ObjectsTotal() -1; i>=0; i--)
                 {
                  if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
                    {
                     if(StringFind(ObjectName(i),"_Q_RS")>-1)
                       {
                        if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)==double(arr[1]))
                          {
                           CreateLine=false;
                          }
                       }
                    }
                 }
               if(CreateLine)
                 {
                  LineId=TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS)+string(iname);
                  if(double(arr[1])>MarketInfo(Symbol(),MODE_BID))
                    {
                     HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",0,((double(arr[1])/point)*point),LineResistcolorSecond,LineStyleSecond,LinewidthSecond,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
                     ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
                     ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
                     ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",DoubleToString((int(double(arr[1])/point)*point),Digits),10,"Courier New",LineResistcolorSecond);
                    }
                  else
                    {
                     HLineCreate(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",0,((double(arr[1])/point)*point),LineSupportcolorSecond,LineStyleSecond,LinewidthSecond,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
                     ObjectCreate("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
                     ObjectMove(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",0,labelposition,ObjectGet("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_PRICE1));
                     ObjectSetText("MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",DoubleToString((int(double(arr[1])/point)*point),Digits),10,"Courier New",LineSupportcolorSecond);
                    }
                  PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-((double(arr[1])/point)*point));
                  PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJPROP_TEXT,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_label",OBJPROP_TOOLTIP,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                  ObjectSetString(0,"MasIN_KcSR_"+Symbol()+"_"+LineId+"_Q_RS",OBJPROP_TOOLTIP,DoubleToString((int(double(arr[1])/point)*point),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+CurrencyFormat(PipGapValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
                 }
              }
           }
         FileClose(handle);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Special Backup                                                   |
//+------------------------------------------------------------------+
int SaveSupportResistanceToFileBackup()
  {
   int handle=FileOpen("SupportResistance-"+Symbol()+"-"+TimeToString(TimeCurrent(),TIME_DATE)+".csv",FILE_CSV|FILE_READ|FILE_WRITE,';');
   if(handle<1)
     {
      return(false);
     }
   else
     {
      for(int i=ObjectsTotal() -1; i>=0; i--)
        {
         if(StringFind(ObjectName(i),"MasIN_KcSR_"+Symbol())>-1)
           {
            if(StringFind(ObjectName(i),"_A_RS")>-1)
              {
               FileWrite(handle,Symbol(),ObjectGet(ObjectName(i),OBJPROP_PRICE1),"A");
              }
            if(StringFind(ObjectName(i),"_Q_RS")>-1)
              {
               FileWrite(handle,Symbol(),ObjectGet(ObjectName(i),OBJPROP_PRICE1),"Q");
              }
           }
        }
     }
   FileClose(handle);
   return(0);
  }
//+------------------------------------------------------------------+
