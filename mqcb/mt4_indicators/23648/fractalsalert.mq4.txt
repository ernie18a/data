//+------------------------------------------------------------------+
//|                                                FractalsAlert.mq4 |
//|                 Copyright © 2005-2014, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "FractalsAlert is base of the Indicator Fractals with Alert"
#property description "Added Alert and modify by Roberto Jacobs 3rjfx @ 2018/12/12"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_width1 2
#property indicator_width2 2
//---
enum YN
 {
   No,
   Yes
 };
//--
//---- input parameters
input YN            alerts = Yes;     // Display Alerts / Messages (Yes) or (No)
input YN        EmailAlert = No;      // Email Alert (Yes) or (No)
input YN       displayinfo = Yes;     // Display Trade Info
//--
//---- buffers
double ExtUpFractalsBuffer[];
double ExtDownFractalsBuffer[];
//--
datetime fbartime,
         pbartime,
         cbartime;
int i,cur,prv;
int cmnt,pmnt,
    fbar,pvb;
string posisi,
       sigpos,
       msgText;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,ExtUpFractalsBuffer);
    SetIndexBuffer(1,ExtDownFractalsBuffer);   
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,119);
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,119);
//----
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Fractal Up");
    SetIndexLabel(1,"Fractal Down");
//---- initialization done   
   return(0);
  }
//---------//
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
    Comment("");
    ObjectsDeleteAll();
    GlobalVariablesDeleteAll();
//----
   return(0);
  }
//---------//
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
   int    nCountedBars;
   bool   bFound;
   double dCurrent;
   cur=0;
   nCountedBars=prev_calculated;
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   //--
//---- last counted bar will be recounted   
   if(nCountedBars<=2)
      i=rates_total-nCountedBars-3;
   if(nCountedBars>2)
      i=rates_total-nCountedBars+2;
   //--
//----Up and Down Fractals
   while(i>=2)
     {
      //----Fractals up
      bFound=false;
      dCurrent=high[i];
      if(dCurrent>high[i+1] && dCurrent>high[i+2] && dCurrent>high[i-1] && dCurrent>high[i-2])
        {
         bFound=true;
         ExtUpFractalsBuffer[i]=dCurrent;
         cur=-1;
         cbartime=time[i];
         fbar=iBarShift(_Symbol,0,cbartime,false);
        }
      //----6 bars Fractal
      if(!bFound && (Bars-i-1)>=3)
        {
         if(dCurrent==high[i+1] && dCurrent>high[i+2] && dCurrent>high[i+3] &&
            dCurrent>high[i-1] && dCurrent>high[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
            cur=-1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }
        }         
      //----7 bars Fractal
      if(!bFound && (Bars-i-1)>=4)
        {   
         if(dCurrent>=high[i+1] && dCurrent==high[i+2] && dCurrent>high[i+3] && dCurrent>high[i+4] &&
            dCurrent>high[i-1] && dCurrent>high[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
            cur=-1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }
        }  
      //----8 bars Fractal                          
      if(!bFound && (Bars-i-1)>=5)
        {   
         if(dCurrent>=high[i+1] && dCurrent==high[i+2] && dCurrent==high[i+3] && dCurrent>high[i+4] && dCurrent>high[i+5] && 
            dCurrent>high[i-1] && dCurrent>high[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
            cur=-1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }
        } 
      //----9 bars Fractal                                        
      if(!bFound && (Bars-i-1)>=6)
        {   
         if(dCurrent>=high[i+1] && dCurrent==high[i+2] && dCurrent>=high[i+3] && dCurrent==high[i+4] && dCurrent>high[i+5] && 
            dCurrent>high[i+6] && dCurrent>high[i-1] && dCurrent>high[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
            cur=-1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }
        }                                    
      //----Fractals down
      bFound=false;
      dCurrent=low[i];
      if(dCurrent<low[i+1] && dCurrent<low[i+2] && dCurrent<low[i-1] && dCurrent<low[i-2])
        {
         bFound=true;
         ExtDownFractalsBuffer[i]=dCurrent;
         cur=1;
         cbartime=time[i];
         fbar=iBarShift(_Symbol,0,cbartime,false);
        }
      //----6 bars Fractal
      if(!bFound && (Bars-i-1)>=3)
        {
         if(dCurrent==low[i+1] && dCurrent<low[i+2] && dCurrent<low[i+3] &&
            dCurrent<low[i-1] && dCurrent<low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
            cur=1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }                      
        }         
      //----7 bars Fractal
      if(!bFound && (Bars-i-1)>=4)
        {   
         if(dCurrent<=low[i+1] && dCurrent==low[i+2] && dCurrent<low[i+3] && dCurrent<low[i+4] &&
            dCurrent<low[i-1] && dCurrent<low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
            cur=1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }                      
        }  
      //----8 bars Fractal                          
      if(!bFound && (Bars-i-1)>=5)
        {   
         if(dCurrent<=low[i+1] && dCurrent==low[i+2] && dCurrent==low[i+3] && dCurrent<low[i+4] && dCurrent<low[i+5] && 
            dCurrent<low[i-1] && dCurrent<low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
            cur=1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }                      
        } 
      //----9 bars Fractal                                        
      if(!bFound && (Bars-i-1)>=6)
        {   
         if(dCurrent<=low[i+1] && dCurrent==low[i+2] && dCurrent<=low[i+3] && dCurrent==low[i+4] && dCurrent<low[i+5] && 
            dCurrent<low[i+6] && dCurrent<low[i-1] && dCurrent<low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
            cur=1;
            cbartime=time[i];
            fbar=iBarShift(_Symbol,0,cbartime,false);
           }                      
        }                                    
      i--;
     }
   //--
   if((alerts==Yes||EmailAlert==Yes)&&(cur!=0 && cbartime!=pbartime)) Do_Alerts(cur,fbar);
   //---
   if(displayinfo==Yes) ChartComm();
   //---
//----
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

void Do_Alerts(int fcur,int fb)
  {
    //--
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="Fractals Lower Found"+" at bars: "+string(fb);
            posisi="Bullish"; 
            sigpos="Open BUY Order";
            fbartime=iTime(_Symbol,0,fb);
          }
        if(fcur==-1)
          {
            msgText="Fractals Upper Found"+" at bars: "+string(fb);
            posisi="Bearish"; 
            sigpos="Open SELL Order";
            fbartime=iTime(_Symbol,0,fb);
          }
        //--
        if(fcur!=prv || fbartime!=pbartime)
          {
            Print(WindowExpertName(),"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(WindowExpertName(),"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(WindowExpertName(),"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            prv=fcur;
            pvb=fb;
            pbartime=fbartime;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //---
  }
//---------//

string TF2Str(int period)
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
   return(string(period));
  }  
//---------//

string AccountMode() // function: to known account trade mode
   {
//----
//--- Demo, Contest or Real account 
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
 //---
   string trade_mode;
   //--
   switch(account_type) 
     { 
      case  ACCOUNT_TRADE_MODE_DEMO: 
         trade_mode="Demo"; 
         break; 
      case  ACCOUNT_TRADE_MODE_CONTEST: 
         trade_mode="Contest"; 
         break; 
      default: 
         trade_mode="Real"; 
         break; 
     }
   //--
   return(trade_mode);
//----
   } //-end AccountMode()
//---------//

void ChartComm() // function: write comments on the chart
  {
//----
   //--
   string fpos=prv==-1 ? "Upper" : "Lower";
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ", TerminalCompany(), 
      "\n      :: Acc. Name       :  ", AccountName(), 
      "\n      :: Acc, Number    :  ", (string)AccountNumber(),
      "\n      :: Acc,TradeMode :  ", AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ", (string)AccountLeverage(), 
      "\n      :: Acc. Balance     :  ", DoubleToString(AccountBalance(),2),
      "\n      :: Acc. Equity       :  ", DoubleToString(AccountEquity(),2), 
      "\n     --------------------------------------------",
     "\n      :: Indicator Name  :  ",WindowExpertName(),
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: Fractals Found   :  ",fpos," at bar ",string(iBarShift(_Symbol,0,fbartime,false)),
      "\n      :: Indicator Signal  :  ",posisi,
      "\n      :: Suggested         :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//
//+------------------------------------------------------------------+
