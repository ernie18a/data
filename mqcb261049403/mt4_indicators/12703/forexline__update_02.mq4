//+------------------------------------------------------------------+
//|                                                    ForexLine.mq4 |
//|                              Copyright 2015,  3rjfx ~ 22/03/2015 |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015,  3rjfx ~ 22/03/2015"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
//--
/* Update (26/03/2015): 
   ~ Added Alerts (Messages, Email dan Sound) to the indicator.
   ~ Eliminate bugs due to the use of ArraySetAsSeries true.
   //--
   Update (08/04/2015):
   ~ Eliminate bugs due to the use of LinearWeightedMAOnBuffer.
   ~ Enhance the signal alerts.
*/
//--
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
int prvAlertBar;
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
   //--
   prvAlertBar=Bars-1;   
//--- initialization done
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
   cural=-1;
   lup=false;
   ldn=false;
//--- check for bars count
   if(rates_total<=maslow) return(0);
//--- Set Last error value to Zero
   ResetLastError();
   RefreshRates();   
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) limit++;
   //--
//--- counting from rates_total to 0
   ArraySetAsSeries(lwma05Buffers,true);
   ArraySetAsSeries(lwma10Buffers,true);
   ArraySetAsSeries(lwma20Buffers,true);
   ArraySetAsSeries(line20Buffers,true);
   ArraySetAsSeries(uplineBuffers,true);
   ArraySetAsSeries(dnlineBuffers,true);
   ArraySetAsSeries(posprc,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   //--
//--- main cycle
   for(i=limit-1; i>=0; i--)
     {
       lwma05Buffers[i]=iMA(symbol,0,mafast,0,3,4,i);
       line20Buffers[i]=iMA(symbol,0,mdma20,0,0,4,i);
     }
   //-
   for(i=limit-1; i>=0; i--)
     {lwma10Buffers[i]=iMAOnArray(lwma05Buffers,0,maslow,0,3,i);}
   for(i=limit-1; i>=0; i--)
     {lwma20Buffers[i]=iMAOnArray(lwma10Buffers,0,mdma20,0,3,i);} 
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
       if(i==0)
         {
           //--
           if((lup==true)&&(lwma05Buffers[i]>lwma05Buffers[i+1])&&(close[i]>open[i])&&(close[i]>=lwma05Buffers[i]))
             {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=3;}
           if((lup==true)&&(lwma05Buffers[i]>lwma05Buffers[i+1])&&(open[i]>=lwma05Buffers[i])&&(close[i]<lwma05Buffers[i]))
             {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=1;}
           if((ldn==true)&&(lwma05Buffers[i]<lwma05Buffers[i+1])&&(close[i]<open[i])&&(close[i]<=lwma05Buffers[i]))
             {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=2;}
           if((ldn==true)&&(lwma05Buffers[i]<lwma05Buffers[i+1])&&(open[i]<=lwma05Buffers[i])&&(close[i]>lwma05Buffers[i]))
             {posprc[i]=(MathAbs(close[i]-line20Buffers[i]))/Point; cural=0;}
           //--
         }
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
          alSubj=StringConcatenate(alBase," The Price still goes Up, ",DoubleToStr(posprc[0],0)," Points above the 20 MA.");
          alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
          if(Bars>prvAlertBar) {prvAlertBar=Bars; doAlerts(alMsg,alSubj);}
        }       
     //--
     if((cural!=prval)&&(alerts==2))
        {     
          alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
          alSubj=StringConcatenate(alBase," The Price still goes Down, ",DoubleToStr(posprc[0],0)," Points below the 20 MA.");
          alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
          if(Bars>prvAlertBar) {prvAlertBar=Bars; doAlerts(alMsg,alSubj);}
        }
     //--
     if((cural!=prval)&&(alerts==0))
        {     
          alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
          alSubj=StringConcatenate(alBase," The Price began to Up, ",DoubleToStr(posprc[0],0)," Points below the 20 MA.");
          alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
          if(Bars>prvAlertBar) {prvAlertBar=Bars; doAlerts(alMsg,alSubj);}
        }              
     //--
     if((cural!=prval)&&(alerts==1))
        {     
          alBase=StringConcatenate(symbol,", TF: ",strTF(_Period),", ForexLine: ");
          alSubj=StringConcatenate(alBase," The Price began to Down, ",DoubleToStr(posprc[0],0)," Points above the 20 MA.");
          alMsg=StringConcatenate(alSubj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
          if(Bars>prvAlertBar) {prvAlertBar=Bars; doAlerts(alMsg,alSubj);}
        }                
     //--
     prval=cural;
     return;
     //--
   //----
   } //-end posAlerts()
//---/
//+------------------------------------------------------------------+