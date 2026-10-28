//+------------------------------------------------------------------+
//|                                                    ForexLine.mq4 |
//|                              Copyright 2015,  3rjfx ~ 22/03/2015 |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015,  3rjfx ~ 22/03/2015"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
/* Update (26/03/2015): 
   ~ Added Alerts (Messages, Email dan Sound) to the indicator.
   ~ Eliminate bugs due to the use of ArraySetAsSeries true.
*/
//--
#include <MovingAverages.mqh>
//-
#property indicator_chart_window
//-
#property indicator_buffers 7
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 clrNONE
#property indicator_color5 clrBlue
#property indicator_color6 clrWhite
#property indicator_color7 clrNONE
//--
#property indicator_width5 3
#property indicator_width6 3
//--
extern bool      SoundAlerts = true;
extern bool      MsgAlerts   = true;
extern bool      eMailAlerts = false;
extern string SoundAlertFile = "alert.wav";
extern color ForexLineColor1 = clrBlue;  // Line Up
extern color ForexLineColor2 = clrWhite;  // Line Down
//-- buffers
double lwma05Buffers[];
double lwma10Buffers[];
double lwma20Buffers[];
double line20Buffers[];
double uplineBuffers[];
double dnlineBuffers[];
double posprc[];
//-
int digit;
int mafast=5;
int maslow=10;
int mdma20=20;
int cural,prval;
//-
bool lup,ldn;
//-
string symbol=_Symbol;
string alBase,alSubj,alMsg;
//-
void EventSetTimer();
//--
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   //-- Checking the Digits Point
   if(Digits==3||Digits==5)
      {digit=Digits;}
   else {digit=Digits+1;}
   //-
   IndicatorDigits(digit);
   //--
//--- indicator buffers mapping
   IndicatorBuffers(7);
   //--
   SetIndexBuffer(0,lwma05Buffers);
   SetIndexBuffer(1,lwma10Buffers);
   SetIndexBuffer(2,lwma20Buffers);
   SetIndexBuffer(3,line20Buffers);
   SetIndexBuffer(4,uplineBuffers);
   SetIndexBuffer(5,dnlineBuffers);
   SetIndexBuffer(6,posprc);
//--- indicator lines
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_LINE,EMPTY,3,ForexLineColor1);
   SetIndexStyle(5,DRAW_LINE,EMPTY,3,ForexLineColor2);
   SetIndexStyle(6,DRAW_NONE);
   //--- name for DataWindow and indicator subwindow label
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,"Rice Above: ");
   SetIndexLabel(5,"Down Below: ");
   SetIndexLabel(6,NULL);
   //--
   SetIndexDrawBegin(4,maslow);
   SetIndexDrawBegin(5,maslow);
   //--
   IndicatorShortName("FXLine");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----  
   //--
   EventKillTimer();
   GlobalVariablesDeleteAll();   
//----
   return;
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
//---
   int i,limit;
   lup=false;
   ldn=false;
//--- check for bars count
   if(rates_total<=maslow) return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) limit--;
   //--
//--- counting from rates_total to 0 
   ArraySetAsSeries(lwma05Buffers,true);
   ArraySetAsSeries(lwma10Buffers,true);
   ArraySetAsSeries(lwma20Buffers,true);
   ArraySetAsSeries(line20Buffers,true);
   ArraySetAsSeries(uplineBuffers,true);
   ArraySetAsSeries(dnlineBuffers,true);
   ArraySetAsSeries(posprc,true);
   ArraySetAsSeries(close,true);
   //--
//--- main cycle
   for(i=limit-1; i>=0; i--) 
     {
       lwma05Buffers[i]=iMA(symbol,0,mafast,0,3,4,i);
       line20Buffers[i]=iMA(symbol,0,mdma20,0,0,4,i);
     }
   //-
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,maslow,lwma05Buffers,lwma10Buffers,i);
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,mdma20,lwma10Buffers,lwma20Buffers,i);
   //-
   for(i=limit-1; i>=0; i--)
     {
       //--
       if((lwma05Buffers[i]>lwma20Buffers[i])) {lup=true; ldn=false;}
       if((lwma05Buffers[i]<lwma20Buffers[i])) {ldn=true; lup=false;}
       if(lup==true)
         {uplineBuffers[i]=line20Buffers[i]; dnlineBuffers[i]=EMPTY_VALUE;}
       if(ldn==true)
         {dnlineBuffers[i]=line20Buffers[i]; uplineBuffers[i]=EMPTY_VALUE;}
       //-
       if((lup==true)&&(close[i]>lwma05Buffers[i]))
         {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=3;}
       if((lup==true)&&(close[i]<lwma05Buffers[i]))
         {posprc[i]=(MathAbs(line20Buffers[i]-close[i]))/Point; cural=1;}
       if((ldn==true)&&(close[i]>lwma05Buffers[i]))
         {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=2;}
       if((ldn==true)&&(close[i]<lwma05Buffers[i]))
         {posprc[i]=(MathAbs(line20Buffers[i]-close[i]))/Point; cural=0;}
       //--
     }
   //--
   posAlerts(cural);
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---//

void doAlerts(string msgText,string eMailSub)
  {
    //--
    if(MsgAlerts) Alert(msgText);
    if(SoundAlerts) PlaySound(SoundAlertFile);
    if(eMailAlerts) SendMail(eMailSub,msgText);
    //--
  }
//---/

//---/
string strTF(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1: return("M1");
       case PERIOD_M5: return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1: return("H1");
       case PERIOD_H4: return("H4");
       case PERIOD_D1: return("D1");
       case PERIOD_W1: return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(_Period);
  }  
//---/

void posAlerts(int alerts)
   {
    //--
    if((cural!=prval)&&(alerts==3))
       {     
         alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
         alSubj=StringConcatenate(alBase," The Price was Up, ",DoubleToStr(posprc[0],0)," Points above the 20 MA.");
         alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         doAlerts(alMsg,alSubj);
         prval=cural;
       }              
    //--
    if((cural!=prval)&&(alerts==0))
       {     
         alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
         alSubj=StringConcatenate(alBase," The Price was Down, ",DoubleToStr(posprc[0],0)," Points below the 20 MA.");
         alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         doAlerts(alMsg,alSubj);
         prval=cural;
       }
    //--
    if((cural!=prval)&&(alerts==2))
       {     
         alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
         alSubj=StringConcatenate(alBase," The Price began to Up, ",DoubleToStr(posprc[0],0)," Points below the 20 MA.");
         alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         doAlerts(alMsg,alSubj);
         prval=cural;
       }              
    //--
    if((cural!=prval)&&(alerts==1))
       {     
         alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
         alSubj=StringConcatenate(alBase," The Price began to Down, ",DoubleToStr(posprc[0],0)," Points above the 20 MA.");
         alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
         doAlerts(alMsg,alSubj);
         prval=cural;
       }                
    //--
    return;
   //----
   } //-end posAlerts()
//---/
//+------------------------------------------------------------------+