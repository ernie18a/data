//+------------------------------------------------------------------+
//|                                                DayPivotPoint.mq4 |
//|                           Copyright 2019, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2019/03/20"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property description "Indicator DayPivotPoint System with Signal and Alert for MetaTrader 4"
#property description "with options to display signal on the chart."
#property description "This Indicator can use only on TF_M1 to H4, and will visually appealing"
#property description "only on TF-M5 to TF-H1. Recommendation for Day Trading use on TF-M15."
/* Update_01: 2019/03/27 ~ Remove any of bugs and error, and the not used code. */
#property version   "1.00"
#property strict
#property indicator_chart_window
//--
enum YN
 {
   No,  // No
   Yes  // Yes
 };
//--
enum fonts
  {
    Arial_Black,    // Arial Black
    Bodoni_MT_Black // Bodoni MT Black
  };
//---
//--
input YN                     alerts = Yes;           // Display Alerts / Messages (Yes) or (No)
input YN                 EmailAlert = No;            // Email Alert (Yes) or (No)
input YN                 sendnotify = No;            // Send Notification (Yes) or (No)
input YN                displayinfo = Yes;           // Display Trade Info
input color               textcolor = clrSnow;       // Text Color
input fonts             Fonts_Model = Arial_Black;   // Choose Fonts Model
input color              WindColors = clrRed;        // Colors for Wingdings
input color              PvtLColors = clrGold;       // Colors for Pivot Lines
input ENUM_LINE_STYLE  PvtLineStyle = STYLE_SOLID;   // Pivot Line style
input int              PvtLineWidth = 1;             // Pivot Line width
//---
//--
int arrpvt=20;
int font_siz_=7;
color wind_color;
string font_ohlc;
//--
double Pvt,
      PvtO,
      PvtL,
      PvtH,
      PvtO1,
      PvtL1,
      PvtH1,
      PvtC1;
//--
double pivot[];
string label[]={"S7","S6","S5","S4","S3","S2","SS1","S1","P20","P40","P60","P80","R1","SR1","R2","R3","R4","R5","R6","R7"};
             //  0    1    2    3    4     5    6     7     8     9    10    11   12    13   14   15   16   17   18   19
//--
ENUM_TIMEFRAMES
    prsi=PERIOD_M15,
    prdp=PERIOD_D1;
//--
long chart_Id;  
datetime tla,tlu;  
datetime thistm,
         prvtmp,
         prvtmo;
int cur,prv,
    imnn,imnp,
    cmnt,pmnt,
    //lpvt=77,
    limit;
string posisi,
       sigpos,
       iname,
       msgText;
string _model;
string frtext="PivotLine_";
bool drawpivot,
     drawpohl;
//--
//--- bars minimum for calculation
#define DATA_LIMIT  108
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicators
   chart_Id=ChartID();
//---
   //--
   font_ohlc=FontsModel(Fonts_Model);
   wind_color=WindColors;
//---
   //--
   iname="DayPivotPoint ("+TF2Str(_Period)+")";
   IndicatorShortName(iname);
   IndicatorDigits(Digits);
   //--
   _model=FontsModel(Fonts_Model);
   drawpivot=false;
   drawpohl=false;
   prvtmp=iTime(_Symbol,0,1);
   prvtmo=iTime(_Symbol,0,1);
   //--
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
    Comment("");
    string name;
    for(int i=ObjectsTotal()-1; i>=0; i--)
      {
        name=ObjectName(i);
        if(StringFind(name,frtext,0)>-1) ObjectDelete(0,name);
      }
   //--
   GlobalVariablesDeleteAll(); 
//----
   return;
  }  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//--- Set Last error value to Zero
   ResetLastError();
   RefreshRates();
   //--
//--- check for rates total
   if(rates_total<DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) limit++;
   if(limit>=DATA_LIMIT) limit=DATA_LIMIT;
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   //--
   tla=time[0];
   tlu=time[77];
   thistm=time[0];
   imnn=Minute();
   //--
   if((!drawpivot)||(thistm!=prvtmp)) DrawPivotPoint();
   if((!drawpohl)||(close[0]>PvtH||close[0]<PvtL)||(thistm!=prvtmo)) DrawPOHL();
   //--
   if(imnn!=imnp) cur=SignalIndi();
   //--
   if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(cur);
   if(displayinfo==Yes) ChartComm();
   //--
   ChartRedraw(chart_Id);
   //--
//--- return value of prev_calculated for next call
   return(rates_total);
  } //- Done! 
//---------//
//+------------------------------------------------------------------+

bool DrawPivotPoint()
  {
//---
   ArrayResize(pivot,arrpvt);
   ArrayResize(label,arrpvt);
   ArraySetAsSeries(pivot,false);
   ArraySetAsSeries(label,false);
   //--
   RefreshRates();
   //--
   PvtL1=iLow(_Symbol,prdp,1);
   PvtH1=iHigh(_Symbol,prdp,1);
   PvtC1=iClose(_Symbol,prdp,1);
   PvtO1=iOpen(_Symbol,prdp,1);
   //--
   Pvt=(PvtH1+PvtL1+PvtC1)/3;
   //-
   double sup1=((Pvt*2)-PvtH1);          // support_1
   double res1=((Pvt*2)-PvtL1);          // resistance_1
   double disr=res1-sup1;                // distance R1 - S1
   double disl=disr*0.20;                // distance line
   //--
   pivot[19]=(Pvt*6)+(PvtH1)-(PvtL1*6);  // resistance_7
   pivot[18]=(Pvt*5)+(PvtH1)-(PvtL1*5);  // resistance_6
   pivot[17]=(Pvt*4)+(PvtH1)-(PvtL1*4);  // resistance_5
   pivot[16]=(Pvt*3)+(PvtH1)-(PvtL1*3);  // resistance_4
   pivot[15]=(Pvt*2)+(PvtH1)-(PvtL1*2);  // resistance_3
   pivot[14]=(Pvt+PvtH1-PvtL1);          // resistance_2
   pivot[13]=res1+(disl*0.618);          // strong_resistance_1
   pivot[12]=res1;                       // resistance_1
   pivot[11]=(sup1+(disr*0.8));          // point_80
   pivot[10]=(sup1+(disr*0.6));          // point_60
   pivot[9] =(sup1+(disr*0.4));          // point_40
   pivot[8] =(sup1+(disr*0.2));          // point_20
   pivot[7] =sup1;                       // support_1
   pivot[6]=sup1-(disl*0.618);           // strong_suppot_1
   pivot[5]=(Pvt-PvtH1+PvtL1);           // support_2
   pivot[4]=(Pvt*2)-((PvtH1*2)-(PvtL1)); // support_3
   pivot[3]=(Pvt*3)-((PvtH1*3)-(PvtL1)); // support_4
   pivot[2]=(Pvt*4)-((PvtH1*4)-(PvtL1)); // support_5
   pivot[1]=(Pvt*5)-((PvtH1*5)-(PvtL1)); // support_6
   pivot[0]=(Pvt*6)-((PvtH1*6)-(PvtL1)); // support_7
   //--
   for(int x=0; x<arrpvt; x++)
     {
       CreateTrendLine(chart_Id,frtext+label[x],tla,pivot[x],tlu,pivot[x],PvtLineWidth,PvtLineStyle,PvtLColors,false,true);
       CreateText(chart_Id,frtext+"PDW"+string(x),tla,pivot[x],CharToString(108),"Wingdings",font_siz_,wind_color,ANCHOR_LEFT);
       CreateText(chart_Id,frtext+"PPP"+string(x),tla,pivot[x],"   "+label[x]+" - "+DoubleToString(pivot[x],_Digits),_model,font_siz_,textcolor,ANCHOR_LEFT); 
       prvtmp=thistm;
       drawpivot=true;
     }
   //--
   return(drawpivot);
//---
  } //-end DrawPivotPoint()   
//---------//

bool DrawPOHL(void)
  {
//--- 
   double POHL[4];
   string labelpric[]={"Pivot","Low","Open","High"};
   color clrPOHL[]={clrAqua,clrDeepPink,clrMediumOrchid,clrBlue};
   POHL[0]=Pvt;
   POHL[1]=iLow(_Symbol,prdp,0);
   POHL[2]=iOpen(_Symbol,prdp,0);
   POHL[3]=iHigh(_Symbol,prdp,0);
   PvtH=POHL[3];
   PvtL=POHL[1];
   //--
   for(int x=0; x<ArraySize(POHL); x++)
     {
       CreateTrendLine(chart_Id,frtext+labelpric[x],tla,POHL[x],tlu,POHL[x],PvtLineWidth,PvtLineStyle,clrPOHL[x],false,true);
       CreateText(chart_Id,frtext+"PWDOHLC"+string(x),tla,POHL[x],CharToString(108),"Wingdings",font_siz_,wind_color,ANCHOR_LEFT);
       CreateText(chart_Id,frtext+"PPDOHLC"+string(x),tla,POHL[x],"   "+labelpric[x]+" - "+DoubleToString(POHL[x],_Digits),
                  FontsModel(0),font_siz_,textcolor,ANCHOR_LEFT);
       prvtmo=thistm;            
       drawpohl=true;
     }
   //--
   return(drawpohl);
//---
  } //-end DrawPOHL()
//---------//

int SignalIndi()
  {
//---
   int res=0;
   int sigbar=5;
   //--
   double DPP1[],
          DPP2[],
          DPP3[];
   double CLOSE[];
   //--
   ArrayResize(DPP1,sigbar);
   ArrayResize(DPP2,sigbar);
   ArrayResize(DPP3,sigbar);
   ArrayResize(CLOSE,sigbar);
   ArraySetAsSeries(DPP1,true);
   ArraySetAsSeries(DPP2,true);
   ArraySetAsSeries(DPP3,true);
   ArraySetAsSeries(CLOSE,true);
   //--
   double iVal0=0,iVal1=0;
   RefreshRates();
   //--
   for(int i=sigbar-2; i>=0; i--)
     {
       CLOSE[i]=iClose(_Symbol,prsi,i);
       DPP1[i]= CLOSE[i] - iBands(_Symbol,prsi,20,2.0,0,PRICE_CLOSE,MODE_MAIN,i);
       DPP2[i]= -(iBearsPower(_Symbol,prsi,13,PRICE_CLOSE,i) + iBullsPower(_Symbol,prsi,13,PRICE_CLOSE,i));
       //--
       if((DPP1[i]>0)&&(DPP2[i]<0)) DPP3[i]=1.0;
       else
       if((DPP1[i]<0)&&(DPP2[i]>0)) DPP3[i]=-1.0;
       else DPP3[i]=0.0;
       //--
       if(i==0)
         {
           iVal0=fabs(DPP1[0])+fabs(DPP2[0]);
           iVal1=fabs(DPP1[1])+fabs(DPP2[1]);
           double dif=iVal1*0.38;
           //--
           if(DPP3[i]==1.0 && (iVal0>iVal1+dif)) res=1;
           else if(DPP3[i]==1.0 && (iVal0<iVal1-dif)) res=10; 
           else if(DPP3[i]==1.0) res=11;
           //--
           if(DPP3[i]==-1.0 && (iVal0>iVal1+dif)) res=-1;
           else if(DPP3[i]==-1.0 && (iVal0<iVal1-dif)) res=-10;
           else if(DPP3[i]==-1.0) res=-11;
         }
     }
   //--
   imnp=imnn;
   //--
   return(res);
//---
  } //-end SignalIndi()
//---------//
  
string FontsModel(int mode)
  { 
   string str_font;
   switch(mode) 
     { 
      case 0: str_font="Arial Black"; break;
      case 1: str_font="Bodoni MT Black"; break; 
     }
   //--
   return(str_font);
//----
  } //-end FontsModel()
//---------//

bool CreateTrendLine(long     chartid, 
                     string   line_name,
                     datetime line_time1,
                     double   line_price1,
                     datetime line_time2,
                     double   line_price2,
                     int      line_width,
                     int      line_style,
                     color    line_color,
                     bool     ray_right,
                     bool     line_hidden)
  {  
//---
   ObjectDelete(chartid,line_name);
   //--
   if(ObjectCreate(chartid,line_name,OBJ_TREND,0,line_time1,line_price1,line_time2,line_price2)) // create trend line
     {
       ObjectSetInteger(chartid,line_name,OBJPROP_WIDTH,line_width);
       ObjectSetInteger(chartid,line_name,OBJPROP_STYLE,line_style);
       ObjectSetInteger(chartid,line_name,OBJPROP_COLOR,line_color);
       ObjectSetInteger(chartid,line_name,OBJPROP_RAY_RIGHT,ray_right);
       ObjectSetInteger(chartid,line_name,OBJPROP_HIDDEN,line_hidden);
       ObjectSetInteger(chartid,line_name,OBJPROP_TIMEFRAMES,0x0001|0x0002|0x0004|0x0008|0x0010|0x0020); 
     } 
   else 
      {Print("Failed to create the object OBJ_TREND ",line_name,", Error code = ", GetLastError()); return(false);}
   //--
   return(true);
//---
  } //-end CreateTrendLine()   
//---------//

bool CreateText(long   chart_id, 
                string text_name,
                datetime txt_time,
                double   txt_price,
                string label_text,
                string font_model,
                int    font_size,
                color  text_color,
                int    anchor)
  { 
//--- 
   ObjectDelete(chart_id,text_name);
   //--
   if(ObjectCreate(chart_id,text_name,OBJ_TEXT,0,txt_time,txt_price))
     { 
       ObjectSetString(chart_id,text_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,text_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,text_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,text_name,OBJPROP_COLOR,text_color);
       ObjectSetInteger(chart_id,text_name,OBJPROP_ANCHOR,anchor);
       ObjectSetInteger(chart_id,text_name,OBJPROP_TIMEFRAMES,0x0001|0x0002|0x0004|0x0008|0x0010|0x0020); 
     } 
   else 
      {Print("Failed to create the object OBJ_TEXT ",text_name,", Error code = ", GetLastError()); return(false);}
   //--
   return(true);
//---
  } //-end CreateText()
//---------//

void Do_Alerts(int fcur)
  {
//---
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="Trend Up";
            posisi="Bullish Strong"; 
            sigpos="Open BUY Order!";
          }
        else
        if(fcur==-1)
          {
            msgText="Trend Down";
            posisi="Bearish Strong"; 
            sigpos="Open SELL Order!";
          }
        else
        if(fcur==10)
          {
            msgText="Trend Up";
            posisi="Bullish Weak"; 
            sigpos="Close BUY Order!";
          }
        else
        if(fcur==11)
          {
            msgText="Trend Up";
            posisi="Bullish Medium"; 
            sigpos="Keep BUY Order!";
          }
        else
        if(fcur==-10)
          {
            msgText="Trend Down";
            posisi="Bearish Weak"; 
            sigpos="Close Sell Order!";
          }
        else
        if(fcur==-11)
          {
            msgText="Trend Down";
            posisi="Bearish Weak"; 
            sigpos="Keep Sell Order!";
          }
        else
          {
            msgText="Trend Not Found!";
            posisi="Not Found!"; 
            sigpos="Wait for Confirmation!";
          }
        //--
        if(fcur!=prv)
          {
            Print(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(sendnotify==Yes) 
              SendNotification(iname+"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);                
            //--
            prv=fcur;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //--
//---
  } //-end Do_Alerts()
//---------//

string TF2Str(int period)
  {
//---
   switch(period)
     {
       //--
       case PERIOD_M1:  return("M1");
       case PERIOD_M5:  return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1:  return("H1");
       case PERIOD_H4:  return("H4");
       case PERIOD_D1:  return("D1");
       case PERIOD_W1:  return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
//---
  } //-end TF2Str()  
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
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ",TerminalCompany(), 
      "\n      :: Acc. Name       :  ",AccountName(), 
      "\n      :: Acc, Number    :  ",(string)AccountNumber(),
      "\n      :: Acc,TradeMode :  ",AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ",(string)AccountLeverage(), 
      "\n      :: Acc. Balance     :  ",DoubleToString(AccountBalance(),2),
      "\n      :: Acc. Equity       :  ",DoubleToString(AccountEquity(),2), 
      "\n      --------------------------------------------",
      "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: Indicator Signal :  ",posisi,
      "\n      :: Suggested        :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//
//+------------------------------------------------------------------+