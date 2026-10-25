//+------------------------------------------------------------------+
//|                                                   StepUpDown.mq5 |
//|                           Copyright 2017, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 11/01/2017"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property strict
#property description "Price Direction movement Step Up and Down Forex Indicator for MetaTrader 5."
#property description "version: 1.00 ~ Update number: 1 ~ Last update: 2022/01/27 @ 19:38 (PM) WIT (Western Indonesian Time)"
/*
== Last Update: 2026/03/24 ==
*/
//--
#property indicator_chart_window
//--
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_style1 DRAW_NONE
#property indicator_style2 DRAW_NONE
//-- Global scope
input bool     MsgSignalAlerts = true;          // PopUp Message Alert
input bool   SoundAlertsSignal = true;          // Sound Alert 
input bool   eMailSignalAlerts = false;         // Send Email Alert
input string    FileSoundAlert = "alert.wav";   // Sound Alert file name
input color           UpsColor = clrAqua;       // UP Color
input color           DnsColor = clrOrangeRed;  // Down Color
//---
//-- indicator buffers
double naik[],
       turun[];
double FastMA[],
       SlowMA[];
//--
int barcount=77,
    wavecount=13,
    periodturn=3,
    slowperiod=36;
//--
int limit;
int mina,minx;
int posH,posL;
int curAlert,prvAlert;
//--
//--
long Chart_Id;
bool ups,dns;
//--
string name_arr_ups,
       name_arr_dns,
       name_dir_ups,
       name_dir_dwn;
//--
double pips=Point()*10;
double diff=5*pips;
string ind_name;
string Sibase,SiSubj,SiMsg;
//--
int iFEMAT,
    iSMMAT;
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   //--
   SetIndexBuffer(0,naik,INDICATOR_DATA);
   SetIndexBuffer(1,turun,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"Up");
   PlotIndexSetString(1,PLOT_LABEL,"Down");
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//----
   Chart_Id=ChartID();
   ind_name="StepUpDown";
   IndicatorSetString(INDICATOR_SHORTNAME,ind_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   //--
   iFEMAT=iMA(Symbol(),0,periodturn,0,MODE_EMA,PRICE_TYPICAL);
   iSMMAT=iMA(Symbol(),0,slowperiod,0,MODE_SMMA,PRICE_TYPICAL);
   //--
//--- initialization done
   return(INIT_SUCCEEDED);
  }  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
    IndicatorRelease(iFEMAT);
    IndicatorRelease(iSMMAT);
    ObjectDelete(ChartID(),name_arr_dns);
    ObjectDelete(ChartID(),name_arr_ups);
    ObjectDelete(ChartID(),name_dir_dwn);
    ObjectDelete(ChartID(),name_dir_ups);
    //--
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
     ResetLastError();
     int i,j;
     int mlhi=0,mllo=0,wbar=wavecount;
     if(rates_total<barcount) return(0);
     if(prev_calculated==0) limit=barcount;
     if(prev_calculated>0) limit++;
     //--
     ArrayResize(FastMA,limit,limit);
     ArrayResize(SlowMA,limit,limit);
     CopyBuffer(iFEMAT,0,0,limit,FastMA);
     CopyBuffer(iSMMAT,0,0,limit,SlowMA);
     //--
     ArraySetAsSeries(high,true);
     ArraySetAsSeries(low,true);
     ArraySetAsSeries(time,true);
     ArraySetAsSeries(FastMA,true);
     ArraySetAsSeries(SlowMA,true);
     //--
     ups=false;
     dns=false;
     //--
     double divma0=0;
     double divma1=0;
     double mahi=FastMA[1];
     double malo=FastMA[1];
     //--
     for(i=wbar-1; i>=0; i--)
       {
         if(FastMA[i]>mahi+diff) 
           {mahi=FastMA[i]; mlhi=i;}
         if(FastMA[i]<malo-diff)
           {malo=FastMA[i]; mllo=i;}
         divma0=FastMA[i]-SlowMA[i];
         divma1=FastMA[i+1]-SlowMA[i+1];
       }
    //---
    //--
    for(j=barcount-1; j>=0; j--)
      {
       //--
       if((mlhi>mllo)&&(FastMA[j]>malo+diff))
          {ups=true; dns=false;}
       if((mlhi>mllo)&&(divma0<divma1))
          {dns=true; ups=false;}
       if((mlhi<mllo)&&(FastMA[j]<mahi-diff))
          {dns=true; ups=false;}
       if((mlhi<mllo)&&(divma0>divma1))
          {ups=true; dns=false;}
       //---
       //--
       if(j==0)
         {
          //---
          posH=iHighest(Symbol(),0,MODE_HIGH,wavecount,j);
          posL=iLowest(Symbol(),0,MODE_LOW,wavecount,j);
          //--
          if(ups==true) // direction up (naik)
            {
              //--
              name_arr_ups          = "uparrow";
              name_dir_ups          = "updirec";
              double pos_price      = low[posL];
              datetime pos_dir_time = time[posL];
              naik[j]=low[posL];
              turun[j]=EMPTY_VALUE;
              ObjectDelete(Chart_Id,name_arr_dns);
              ObjectDelete(Chart_Id,name_dir_dwn);
              //--
              CreateDirection(Chart_Id,name_dir_ups,"  UP ","Bodoni MT Black",8,UpsColor,pos_dir_time,pos_price-5*Point(),ANCHOR_LEFT_UPPER);
              CreateDirection(Chart_Id,name_arr_ups,CharToString(217),"Wingdings",15,UpsColor,pos_dir_time,pos_price-5*Point(),ANCHOR_CENTER);
              //--
              curAlert=0;
              SendAlerts(curAlert,naik[j]);
              //--
            }
          //---
          if(dns==true) // direction down (turun)
            {
              //--
              name_arr_dns          = "dnarrow";
              name_dir_dwn          = "dndirec";
              double pos_price      = high[posH];
              datetime pos_dir_time = time[posH];
              turun[j]=high[posH];
              naik[j]=EMPTY_VALUE;
              ObjectDelete(Chart_Id,name_arr_ups);
              ObjectDelete(Chart_Id,name_dir_ups);
              //--
              CreateDirection(Chart_Id,name_dir_dwn,"  DOWN","Bodoni MT Black",9,DnsColor,pos_dir_time,pos_price+5*Point(),ANCHOR_LEFT_LOWER);
              CreateDirection(Chart_Id,name_arr_dns,CharToString(218),"Wingdings",15,DnsColor,pos_dir_time,pos_price+5*Point(),ANCHOR_CENTER);
              //--
              curAlert=1;
              SendAlerts(curAlert,turun[j]);
              //--
            }
         //--- end if(j)
         }
      //---
     }
   //--
   ChartRedraw(0);
   Sleep(500);
   //--- end for(j)
   //----      
//----- done
   return(rates_total);
  }
//---------//

void CreateDirection(long     chart_id,
                     string   obj_name, 
                     string   obj_text,
                     string   font_model,
                     int      font_size,
                     color    obj_color,
                     datetime text_time,
                     double   text_pos,
                     int      anchor)
  {
    //--
    if(ObjectFind(chart_id,obj_name)>0) ObjectDelete(chart_id,obj_name);
    //--
    ObjectCreate(chart_id,obj_name,OBJ_TEXT,0,text_time,text_pos);
    ObjectSetString(chart_id,obj_name,OBJPROP_FONT,font_model);
    ObjectSetInteger(chart_id,obj_name,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,obj_color);
    ObjectSetString(chart_id,obj_name,OBJPROP_TEXT,obj_text);
    ObjectSetInteger(chart_id,obj_name,OBJPROP_ANCHOR,anchor);
    ChartRedraw();
    //--
  }
//---------//

enum TimeReturn
  {
    year        = 0,   // Year 
    mon         = 1,   // Month 
    day         = 2,   // Day 
    hour        = 3,   // Hour 
    min         = 4,   // Minutes 
    sec         = 5,   // Seconds 
    day_of_week = 6,   // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
    day_of_year = 7    // Day number of the year (January 1st is assigned the number value of zero) 
  };
//---------//

int MqlReturnDateTime(datetime reqtime,
                      const int mode) 
  {
    MqlDateTime mqltm;
    TimeToStruct(reqtime,mqltm);
    int valdate=0;
    //--
    switch(mode)
      {
        case 0: valdate=mqltm.year; break;        // Return Year 
        case 1: valdate=mqltm.mon;  break;        // Return Month 
        case 2: valdate=mqltm.day;  break;        // Return Day 
        case 3: valdate=mqltm.hour; break;        // Return Hour 
        case 4: valdate=mqltm.min;  break;        // Return Minutes 
        case 5: valdate=mqltm.sec;  break;        // Return Seconds 
        case 6: valdate=mqltm.day_of_week; break; // Return Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
        case 7: valdate=mqltm.day_of_year; break; // Return Day number of the year (January 1st is assigned the number value of zero) 
      }
    return(valdate);
  }
//---------//

void DoSignalAlerts(string msgSignalText,string eMailSignalSub)
  {
     if (MsgSignalAlerts) Alert(msgSignalText);
     if (SoundAlertsSignal) PlaySound(FileSoundAlert);
     if (eMailSignalAlerts) SendMail(eMailSignalSub,msgSignalText);
  }
//---------//

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
       default: return("Unknown");
       //--
     }
  }  
//---------//

void SendAlerts(int alerts,double position)
   {
    //---
    mina=MqlReturnDateTime(TimeCurrent(),TimeReturn(min));
    if(mina!=minx)
      {
        if((alerts!=prvAlert)&&(alerts==0))
          {
            Sibase=ind_name+" "+_Symbol+", TF: "+strTF(_Period);
            SiSubj=Sibase+" Step to Up Above: "+DoubleToString(position,_Digits);
            SiMsg=SiSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoSignalAlerts(SiMsg,SiSubj);
            prvAlert=alerts;
            minx=mina;
          }
     //---
        if((alerts!=prvAlert)&&(alerts==1))
          {    
            Sibase=ind_name+" "+_Symbol+", TF: "+strTF(_Period);
            SiSubj=Sibase+" Step to Down Below: "+DoubleToString(position,_Digits);
            SiMsg=SiSubj+" @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
            DoSignalAlerts(SiMsg,SiSubj);
            prvAlert=alerts;
            minx=mina;
          }
       }
    //---
    return;
   //----
   } //-end SendAlerts()
//---------//
//+------------------------------------------------------------------+