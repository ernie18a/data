//+------------------------------------------------------------------+
//|                                                   StepUpDown.mq4 |
//|                              Copyright 2014,  Roy Philips Jacobs |
//|       Create: 28/03/2014   http://www.gol2you.com ~ Forex Videos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014,  Roy Philips Jacobs"
#property link      "http://www.gol2you.com ~ Forex Videos"
#property description "Price Direction movement Step Up and Down Forex Indicator"
#property description "Last Update 2014/06/23"
//---
//--- indicator parameters
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrRed
#property indicator_width1 1
//-- Global scope
extern string PriceDirection="Copyright © 2014 3RJ ~ Roy Philips-Jacobs";
extern bool   MsgSignalAlerts =true;
extern bool  SoundAlertsSignal=true;
extern bool  eMailSignalAlerts=false;
extern string  FileSoundAlert="alert.wav";
//-- indicator buffer
double ma20c[];
int per=30;
int posH,posL;
int curAlert,prvAlert;
//--
bool dirBuy,dirSell;
//--
void EventSetTimer();
string symbol;
string CR;
string Sibase,SiSubj,SiMsg;
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   //--
   symbol=_Symbol;
   CR="Copyright © 2014 3RJ ~ Roy Philips-Jacobs"; 
//----
   IndicatorBuffers(1);
   //--- 1 indicator buffers mapping
   SetIndexBuffer(0,ma20c);
   //--- indicator line drawing
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,EMPTY,clrRed);
   //--- name for DataWindow and indicator subwindow label   
   SetIndexLabel(0,"BuySellLimit");
   //--
   IndicatorShortName("StepUpDown");
   IndicatorDigits(Digits);
   //--   
//--- initialization done
   return;
  }   
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
    EventKillTimer();
    GlobalVariablesDeleteAll();
    //--
    ObjectDelete("DirBUY");
    ObjectDelete("DirSELL");
    ObjectDelete("DirBUYArr");
    ObjectDelete("DirSELLArr");    
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//---
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
    {
//------
    if (PriceDirection!=CR) return(0);
    int i,j,limit;
    if(rates_total<=per) return(0);
//--- last counted bar will be recounted
    limit=rates_total-prev_calculated;
    if(prev_calculated>0) {limit++;}
    //--
    ResetLastError();
    ChartSetInteger(ChartPeriod(0),CHART_AUTOSCROLL,0,true);
    WindowRedraw();
    ChartRedraw(0);
    Sleep(500);
    RefreshRates();
    limit=WindowFirstVisibleBar();
    int pr=9;
    //--
    dirBuy=false;
    dirSell=false;
    //--
    double divma520;
    double divma521;
    double MAHi=iMA(symbol,0,5,0,0,4,1);
    double MALo=iMA(symbol,0,5,0,0,4,1);
    //--
    for(i=pr; i>=0; i--)
      {
       if(iMA(symbol,0,5,0,0,4,i)>MAHi) {MAHi=iMA(symbol,0,5,0,0,4,i); int mlHi=i;}
       if(iMA(symbol,0,5,0,0,4,i)<MALo) {MALo=iMA(symbol,0,5,0,0,4,i); int mlLo=i;}
       divma520=iMA(symbol,0,5,0,0,4,i)-iMA(symbol,0,20,0,0,4,i);
       divma521=iMA(symbol,0,5,0,0,4,i+1)-iMA(symbol,0,20,0,0,4,i+1);  
      }
    //----
    for(i=0,j=limit; i<=limit; i++,j--)
      {
        //--
        RefreshRates();
        //--
        ma20c[i]=iMA(symbol,0,20,0,MODE_SMMA,PRICE_MEDIAN,i);
        //--
        posH=iHighest(symbol,0,MODE_HIGH,pr,j);
        posL=iLowest(symbol,0,MODE_LOW,pr,j);
        //--
        if((mlHi>mlLo)&&(iMA(symbol,0,5,0,0,4,j)>MALo))
           {dirBuy=TRUE; dirSell=FALSE;}
        if((mlHi>mlLo)&&(divma520<divma521))
           {dirSell=TRUE; dirBuy=FALSE;}
        if((mlHi<mlLo)&&(iMA(symbol,0,5,0,0,4,j)<MAHi))
           {dirSell=TRUE; dirBuy=FALSE;}
        if((mlHi<mlLo)&&(divma520>divma521))
           {dirBuy=TRUE; dirSell=FALSE;}
        //---
        if(j==0)
          {
           //---
           ObjectDelete("DirBUY");
           ObjectDelete("DirSELL");
           ObjectDelete("DirBUYArr");
           ObjectDelete("DirSELLArr");
           //--
           //---
           if(dirBuy==true) // Buy direction
             {
              if(ObjectFind(0,"DirBUY")<0)
                {
                  ObjectCreate(0,"DirBUY",OBJ_TEXT,0,Time[posL],Low[posL]);
                  ObjectSetString(0,"DirBUY",OBJPROP_TEXT,StringConcatenate("  BUY"));
                  ObjectSetInteger(0,"DirBUY",OBJPROP_COLOR,clrAquamarine);
                  ObjectSetString(0,"DirBUY",OBJPROP_FONT,"Bodoni MT Black");
                  ObjectSetInteger(0,"DirBUY",OBJPROP_FONTSIZE,9);
                  ObjectSetInteger(0,"DirBUY",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
                  //--
                  ObjectCreate(0,"DirBUYArr",OBJ_TEXT,0,Time[posL-1],Low[posL]);
                  ObjectSetString(0,"DirBUYArr",OBJPROP_TEXT,CharToStr(217));
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_COLOR,clrAquamarine);
                  ObjectSetString(0,"DirBUYArr",OBJPROP_FONT,"Wingdings");
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_FONTSIZE,15);
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
                }
              else
                {
                  ObjectSetString(0,"DirBUY",OBJPROP_TEXT,StringConcatenate("  BUY"));
                  ObjectSetInteger(0,"DirBUY",OBJPROP_COLOR,clrAquamarine);
                  ObjectSetString(0,"DirBUY",OBJPROP_FONT,"Bodoni MT Black");
                  ObjectSetInteger(0,"DirBUY",OBJPROP_FONTSIZE,9);
                  ObjectSetInteger(0,"DirBUY",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
                  //--
                  ObjectSetString(0,"DirBUYArr",OBJPROP_TEXT,CharToStr(217));
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_COLOR,clrAquamarine);
                  ObjectSetString(0,"DirBUYArr",OBJPROP_FONT,"Wingdings");
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_FONTSIZE,15);
                  ObjectSetInteger(0,"DirBUYArr",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
                }
              //--
              curAlert=0;
              ChartRedraw(0);
              WindowRedraw();
              Sleep(500);
              RefreshRates();
              CkAlerts(curAlert);
              //--
             }
           //---
           if(dirSell==true) // Sell direction
             {
              if(ObjectFind(0,"DirSELL")<0)
                {            
                  ObjectCreate(0,"DirSELL",OBJ_TEXT,0,Time[posH],High[posH]);
                  ObjectSetString(0,"DirSELL",OBJPROP_TEXT,StringConcatenate("  SELL"));
                  ObjectSetInteger(0,"DirSELL",OBJPROP_COLOR,clrSnow);
                  ObjectSetString(0,"DirSELL",OBJPROP_FONT,"Bodoni MT Black");
                  ObjectSetInteger(0,"DirSELL",OBJPROP_FONTSIZE,9);
                  ObjectSetInteger(0,"DirSELL",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
                  //--
                  ObjectCreate(0,"DirSELLArr",OBJ_TEXT,0,Time[posH-1],High[posH]);
                  ObjectSetString(0,"DirSELLArr",OBJPROP_TEXT,CharToStr(218));
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_COLOR,clrSnow);
                  ObjectSetString(0,"DirSELLArr",OBJPROP_FONT,"Wingdings");
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_FONTSIZE,15);
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
                }
              else
                {
                  ObjectSetString(0,"DirSELL",OBJPROP_TEXT,StringConcatenate("  SELL"));
                  ObjectSetInteger(0,"DirSELL",OBJPROP_COLOR,clrSnow);
                  ObjectSetString(0,"DirSELL",OBJPROP_FONT,"Bodoni MT Black");
                  ObjectSetInteger(0,"DirSELL",OBJPROP_FONTSIZE,9);
                  ObjectSetInteger(0,"DirSELL",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
                  //--
                  ObjectSetString(0,"DirSELLArr",OBJPROP_TEXT,CharToStr(218));
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_COLOR,clrSnow);
                  ObjectSetString(0,"DirSELLArr",OBJPROP_FONT,"Wingdings");
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_FONTSIZE,15);
                  ObjectSetInteger(0,"DirSELLArr",OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
                }
              //--
              curAlert=1;
              ChartRedraw(0);
              WindowRedraw();
              Sleep(500);
              RefreshRates();
              CkAlerts(curAlert);
              //--
             }
          //--- end if(j)
          }
      //---
      }
   //--- end for(j)
   //----      
//----- done
   return(rates_total);
  }
//-----

//+--+
void DoSignalAlerts(string msgSignalText,string eMailSignalSub)
  {
     if (MsgSignalAlerts) Alert(msgSignalText);
     if (SoundAlertsSignal) PlaySound(FileSoundAlert);
     if (eMailSignalAlerts) SendMail(eMailSignalSub,msgSignalText);
  }
//+--+

//+--+
string TF2Str(int period)
  {
   switch(period)
     {
        case PERIOD_M1: return("M1");
        case PERIOD_M5: return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1: return("H1");
        case PERIOD_H4: return("H4");
        case PERIOD_D1: return("D1");
        case PERIOD_W1: return("W1");
        case PERIOD_MN1: return("MN");
     }
   return(_Period);
  }  
//+--+

//+--+
void CkAlerts(int alerts)
   {
    //---
    if((alerts!=prvAlert)&&(alerts==0))
       {
         Sibase=StringConcatenate(symbol,", TF: ",TF2Str(_Period),", StepUpDownAlerts: ");
         SiSubj=StringConcatenate(Sibase," Buy Above: ",DoubleToStr(Low[posL],Digits));
         SiMsg=StringConcatenate(SiSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         DoSignalAlerts(SiMsg,SiSubj);
         prvAlert=alerts;
       }
     //---
     if((alerts!=prvAlert)&&(alerts==1))
       {     
         Sibase=StringConcatenate(symbol,", TF: ",TF2Str(_Period),", StepUpDownAlerts: ");
         SiSubj=StringConcatenate(Sibase," Sell Below: ",DoubleToStr(High[posH],Digits));
         SiMsg=StringConcatenate(SiSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         DoSignalAlerts(SiMsg,SiSubj);
         prvAlert=alerts;
       }
    //---
    return;
   //----
   } //-end CkAlerts()
//+------------------------------------------------------------------+