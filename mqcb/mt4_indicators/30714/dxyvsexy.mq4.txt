//+------------------------------------------------------------------+
//|                                                     DXYvsEXY.mq4 |
//|                           Copyright 2020, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Roberto Jacobs (3rjfx) ~ Date Create: 2020/08/17"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "2.00"
#property strict
#property description "Indicator DXYvsEXY is the USDX vs EURX with Awesome Oscillator Indicator for MT4."
#property description "Highly recommended for the EURUSD pair."
#property description "Can be used for all major currency pairs against USD and EUR."
#property description "For USD basket: AUDUSD, GBPUSD, NZDUSD, USDCHF, USDCAD, USDJPY."
#property description "For EUR basket: EURAUD, EURGBP, EURNZD, EURCHF, EURCAD, EURJPY."
#property description "version: 2.0 ~ Last update: 2020/09/10 @ 10:44 PM WIT (Western Indonesian Time)"
//---
/* Update_01: 2020/08/22:
   ~ Change signal position display template.
   ~ Speed up program execution by removing code and wordy programs. 
   
 * Update_02: 2020/09/10:
   ~ Added option to display or not the DXY histogram and EXY histogram.
   ~ Removes the strict calculation timeframes option.
*/
//---
#property indicator_separate_window
#property indicator_buffers 6
//---
//--
enum YN
 {
   No,
   Yes
 };
//--
enum corner
 {  
   topchart=0,     // On Top Chart
   bottomchart=1,  // On Bottom Chart
   NotShow=-1      // Not Show Arrow
 };
//--
enum atprc
 {
   prc_c=0, // CLOSE
   prc_o=1, // OPEN
   prc_h=2, // HIGH
   prc_l=3, // LOW
   prc_m=4, // MEDIAN (H+L)/2
   prc_t=5, // TYPICAL (H+L+C)/3
   prc_w=6, // WEIGHTED (H+L+C+C)/4
   prc_a=7  // ALL OHLC (O+H+L+C)/4
 };
//--
input YN                 DXYdisp = Yes;            // Display DXY HISTOGRAM (Yes) or (No)
input YN                 EXYdisp = Yes;            // Display EXY HISTOGRAM (Yes) or (No)
input atprc                  prc = prc_t;          // Calculation Price
input ENUM_MA_METHOD      mameth = MODE_EMA;       // MA Method for Oscillator
input corner                 cor = topchart;       // Arrow Trend Move Position on Chart
input YN                  alerts = Yes;            // Display Alerts / Messages (Yes) or (No)
input YN              EmailAlert = No;             // Email Alert (Yes) or (No)
input YN              sendnotify = No;             // Send Notification (Yes) or (No)
input color            textcolor = clrWhite;       // Text Color
input color              dxytemp = clrGreen;       // DXY Template Color
input color              exytemp = clrBlueViolet;  // EXY Template Color
input color                trnUp = clrBlue;        // Trend Up Color
input color                trnDn = clrRed;         // Trend Down Color
input color                dxyUp = clrGreen;       // DXY Move Up Color
input color                dxyDn = clrGreenYellow; // DXY Move Down Color
input color                exyUp = clrBlueViolet;  // EXY Move Up Color
input color                exyDn = clrViolet;      // EXY Move Down Color
input color              NTArrow = clrYellow;      // Arrow No Signal
//---
//---- indicator buffers
double usdidx[];
double usdxup[];
double usdxdn[];
double euridx[];
double eurxup[];
double eurxdn[];
//-- MA buffers
double FMADXY[];
double FMAEXY[];
double SMADXY[];
double SMAEXY[];
double AODXY[];
double AOEXY[];
//---
double usdx=50.14348112; // Do not change for DXY
double eurx=34.38805726; // Do not change for EXY
double dxycw[]={-0.576,0.136,-0.119,0.091,0.042,0.036}; // Do not change for DXY
double exycw[]={0.3155,0.3056,0.1891,0.1113,0.0785};    // Do not change for EXY
//--
string idx[]={"EXY","DXY"};
string trm[]={"Move","Trend","Move","Trend"};
string dxy[]={"EURUSD","USDJPY","GBPUSD","USDCAD","USDSEK","USDCHF"};
string exy[]={"EURUSD","EURGBP","EURJPY","EURCHF","EURSEK"};
string edx[]={"EURUSD","EURGBP","EURJPY","EURCHF","EURSEK","USDJPY","GBPUSD","USDCAD","USDSEK","USDCHF"}; // 10 pairs
int dxs=ArraySize(dxy);
int exs=ArraySize(exy);
int eds=ArraySize(edx);
int ida=ArraySize(idx);
int tra=ArraySize(trm);
int dxymv[];
int exymv[];
//--
int dxalc,
    dxalp;
int exalc,
    exalp;
long CId;
//--- spacing
int scaleY=30,
    offsetY,
    offsetYt,
    br1=15,
    br2=25,
    txttf,
    tempdex; // coordinate
color darclr,
      earclr,
      dxyclr,
      exyclr;
ENUM_BASE_CORNER bscor;
int percalc;
string indname;
string nmtext="dex";
string sigpos,
       msgText;
#define MA_FAST 5
#define MA_SLOW 34
#define MIN_BAR 120
#define MAX_BAR 369
//---------//
//Calculation
//The U.S. Dollar Index is calculated with this formula: 
//DXY = 50.14348112 × EURUSD -0.576 × USDJPY 0.136 × GBPUSD -0.119 × USDCAD 0.091 × USDSEK 0.042 × USDCHF 0.036
//--
//The ECX was the geometrically weighted average compared to these currencies. 
//The formula for the calculation was 34.38805726 multiplied by the product of all components in the basket of currencies, 
//that have been raised to a high number of their percentage, weighting equal to:
//ECX = 34.38805726 x (EURUSD^(0.3155) x EURGBP^(0.3056) x EURJPY^(0.1891) x EURCHF^(0.1113) x EURSEK^(0.0785))
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    CId=ChartID();
    percalc=Period();
    ChartSetSymbolPeriod(CId,Symbol(),percalc);
//--- indicator buffers mapping
    //--
    SetIndexBuffer(0,usdidx);
    SetIndexBuffer(1,usdxup);
    SetIndexBuffer(2,usdxdn);
    SetIndexBuffer(3,euridx);
    SetIndexBuffer(4,eurxup);
    SetIndexBuffer(5,eurxdn);
    //--
    //--- drawing settings
    SetIndexStyle(0,DRAW_NONE);
    SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2,dxyUp);
    SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2,dxyDn);
    SetIndexStyle(3,DRAW_NONE);
    SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,exyUp);
    SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,2,exyDn);
    //--
    SetIndexDrawBegin(0,MAX_BAR);
    SetIndexDrawBegin(1,MAX_BAR);
    SetIndexDrawBegin(2,MAX_BAR);
    SetIndexDrawBegin(3,MAX_BAR);
    SetIndexDrawBegin(4,MAX_BAR);
    SetIndexDrawBegin(5,MAX_BAR);
    //-- name for Data Window
    SetIndexLabel(0,"DXY");
    SetIndexLabel(1,"DXY Rise");
    SetIndexLabel(2,"DXY Down");
    SetIndexLabel(3,"EXY");
    SetIndexLabel(4,"EXY Rise");
    SetIndexLabel(5,"EXY Down");
    //--
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
    SetIndexEmptyValue(2,0.0);
    SetIndexEmptyValue(3,0.0);
    SetIndexEmptyValue(4,0.0);
    SetIndexEmptyValue(5,0.0);
//---- indicator short name
    IndicatorDigits(3);
    indname=WindowExpertName()+"("+TF2Str(percalc)+")";
    IndicatorShortName(indname);
    //--
    //--
    for(int s=0; s<eds; s++)
      SymbolSelect(edx[s],true);
    //--
    if(cor>=0)
      {
        if(cor==topchart) {bscor=CORNER_RIGHT_UPPER; offsetYt=0; offsetY=3; txttf=63; tempdex=30;} 
        if(cor==bottomchart) {bscor=CORNER_RIGHT_UPPER; offsetYt=173; offsetY=48; txttf=63; tempdex=248;} 
      }
    else
     {
       string name;
       for(int i=ObjectsTotal()-1; i>=0; i--)
         {
           name=ObjectName(i);
           if(StringFind(name,nmtext,0)>-1) ObjectDelete(CId,name);
         }
     }
   //---
   return(INIT_SUCCEEDED);
//---
  } //-end OnInit()
//---------//
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
   //--
   PrintFormat("%s: Deinitialization reason code=%d",__FUNCTION__,reason);
   Print(getUninitReasonText(reason));
   string name;
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
       name=ObjectName(i);
       if(StringFind(name,nmtext,0)>-1) ObjectDelete(0,name);
     }
   //--
   return;
//---
  } //-end deinit()
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
//--- Set Last error value to Zero
   ResetLastError();
   RefreshRates();
//---
   int limit=0,barc;
//--- check for rates total
   if(rates_total<MIN_BAR) limit=MIN_BAR;
   if(rates_total>MAX_BAR) limit=MAX_BAR;
   barc=limit-1;
   //--
   ArrayResize(usdidx,limit);
   ArrayResize(usdxup,limit);
   ArrayResize(usdxdn,limit);
   ArrayResize(euridx,limit);
   ArrayResize(eurxup,limit);
   ArrayResize(eurxdn,limit);
   ArrayResize(dxymv,limit);
   ArrayResize(exymv,limit);
   ArrayResize(FMADXY,limit);
   ArrayResize(SMADXY,limit);
   ArrayResize(FMAEXY,limit);
   ArrayResize(SMAEXY,limit);
   ArrayResize(AODXY,limit);
   ArrayResize(AOEXY,limit);
   ArraySetAsSeries(usdidx,true);
   ArraySetAsSeries(usdxup,true);
   ArraySetAsSeries(usdxdn,true);
   ArraySetAsSeries(euridx,true);
   ArraySetAsSeries(eurxup,true);
   ArraySetAsSeries(eurxdn,true);
   ArraySetAsSeries(dxymv,true);
   ArraySetAsSeries(exymv,true);
   ArraySetAsSeries(FMADXY,true);
   ArraySetAsSeries(FMAEXY,true);
   ArraySetAsSeries(SMADXY,true);
   ArraySetAsSeries(SMAEXY,true);
   ArraySetAsSeries(AODXY,true);
   ArraySetAsSeries(AOEXY,true);
   //--
   for(int s=0; s<dxs; s++)
      RefreshPrice(dxy[s],percalc,limit);
   //--
   for(int i=barc; i>=0; i--)
     {
       usdidx[i]=usdx;
       for(int x=0; x<dxs; x++)
         {
           usdidx[i] *= pow(FillPrice(dxy[x],i),dxycw[x]);
         }
     }
   //--
   for(int s=0; s<exs; s++)
      RefreshPrice(exy[s],percalc,limit);
   //--
   for(int i=barc; i>=0; i--)
     {
       euridx[i]=eurx;
       for(int y=0; y<exs; y++)
         {
           euridx[i] *= pow(FillPrice(exy[y],i),exycw[y]);
         }
     }
   //--
   for(int i=barc; i>=0; i--)
     {
       FMADXY[i]=iMAOnBuffers(usdidx,barc,MA_FAST,0,mameth,i);
       SMADXY[i]=iMAOnBuffers(usdidx,barc,MA_SLOW,0,mameth,i);
       FMAEXY[i]=iMAOnBuffers(euridx,barc,MA_FAST,0,mameth,i);
       SMAEXY[i]=iMAOnBuffers(euridx,barc,MA_SLOW,0,mameth,i);
     }
   //--
   //--
   if(DXYdisp==Yes)
     {
       for(int i=barc-1; i>=0; i--) // AO for DXY
         {
           AODXY[i]=FMADXY[i]-SMADXY[i];
           if(AODXY[i]>AODXY[i+1]) {usdxup[i]=AODXY[i]; usdxdn[i]=0.0; dxymv[i]=1;}
           else                    {usdxup[i]=0.0; usdxdn[i]=AODXY[i]; dxymv[i]=-1;}
         }
     }
   //--
   if(EXYdisp==Yes)
     {
       for(int i=barc-1; i>=0; i--) // AO for EXY
         {
           AOEXY[i]=FMAEXY[i]-SMAEXY[i];
           if(AOEXY[i]>AOEXY[i+1]) {eurxup[i]=AOEXY[i]; eurxdn[i]=0.0; exymv[i]=1;}
           else                    {eurxup[i]=0.0; eurxdn[i]=AOEXY[i]; exymv[i]=-1;}
         }
     }
   //--
   darclr=NTArrow;
   earclr=NTArrow;
   dxyclr=NTArrow;
   exyclr=NTArrow;
   //--
   if(cor>=0)
     { 
       CreateSignalTemplate(CId,nmtext+"_TempDXY",90,50,STYLE_SOLID,5,BORDER_RAISED,clrNONE,dxytemp,clrWhite,bscor,187,tempdex,true);
       CreateSignalTemplate(CId,nmtext+"_TempEXY",90,50,STYLE_SOLID,5,BORDER_RAISED,clrNONE,exytemp,clrWhite,bscor,95,tempdex,true);
       for(int x=0; x<ida; x++)
         {             
           CreateArrowLabel(CId,nmtext+"_dexy_name_"+string(x),idx[x],"Bodoni MT Black",8,textcolor,bscor,
                            txttf+x*92,scaleY+offsetY+offsetYt,true); //"Georgia" "Bodoni MT Black" "Verdana" "Arial Black"
         }
       for(int x=0; x<tra; x++)
         {       
           CreateArrowLabel(CId,nmtext+"_dexy_trm_"+string(x),trm[x],"Bodoni MT Black",7,textcolor,bscor,
                            txttf-23+x*46,scaleY+offsetY+br1+offsetYt,true); //"Georgia" "Bodoni MT Black" "Verdana" "Arial Black"  
         }
       //--
       if(AODXY[1]<=0.0 && AODXY[0]>0.0) dxalc=1;
       if(AODXY[1]>=0.0 && AODXY[0]<0.0) dxalc=-1;
       if(AOEXY[1]<=0.0 && AOEXY[0]>0.0) exalc=1;
       if(AOEXY[1]>=0.0 && AOEXY[0]<0.0) exalc=-1;
       if(AODXY[0]>0)  dxyclr=trnUp;
       if(AODXY[0]<0)  dxyclr=trnDn;
       if(AOEXY[0]>0)  exyclr=trnUp;
       if(AOEXY[0]<0)  exyclr=trnDn;
       if(dxymv[0]>0)  darclr=trnUp;
       if(dxymv[0]<0)  darclr=trnDn;
       if(exymv[0]>0)  earclr=trnUp;
       if(exymv[0]<0)  earclr=trnDn;
       //--
       CreateArrowLabel(CId,nmtext+"_exy_arrow_"+string(1),CharToString(108),"Wingdings",16,earclr,bscor,
                        txttf-28+0*48,scaleY+offsetY+br2+offsetYt,true);  // EYX Trend
       CreateArrowLabel(CId,nmtext+"_exy_arrow_"+string(0),CharToString(108),"Wingdings",16,exyclr,bscor,
                        txttf-31+1*48,scaleY+offsetY+br2+offsetYt,true);  // EYX Move
       CreateArrowLabel(CId,nmtext+"_dxy_arrow_"+string(3),CharToString(108),"Wingdings",15,darclr,bscor,
                        txttf-32+2*48,scaleY+offsetY+br2+offsetYt,true);  // DYX Move           
       CreateArrowLabel(CId,nmtext+"_dxy_arrow_"+string(2),CharToString(108),"Wingdings",15,dxyclr,bscor,
                        txttf-37+3*48,scaleY+offsetY+br2+offsetYt,true);  // DYX Trend
      }
   //--
   if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(dxalc,exalc);
   //--
   ChartRedraw();
//--- return value of prev_calculated for next call
   return(rates_total);
  } //-end OnCalculate()  
//---------//

void RefreshPrice(string symbx,int xtf,int barx)
  {
//---
    MqlRates parray[]; 
    ArraySetAsSeries(parray,true); 
    int copied=CopyRates(symbx,xtf,0,barx,parray);
    //--
    return;
//---
  } //-end RefreshPrice()
//---------//

double FillPrice(string symx,int shift)
  {
//---
    double inprc=0;
    //--
    switch(prc)
      {
        case 0: inprc=iClose(symx,percalc,shift); break;
        case 1: inprc=iOpen(symx,percalc,shift);  break;
        case 2: inprc=iHigh(symx,percalc,shift);  break;
        case 3: inprc=iLow(symx,percalc,shift);   break;
        case 4: inprc=(iHigh(symx,percalc,shift)+iLow(symx,percalc,shift))/2;  break;
        case 5: inprc=(iHigh(symx,percalc,shift)+iLow(symx,percalc,shift)+iClose(symx,percalc,shift))/3;  break;
        case 6: inprc=(iHigh(symx,percalc,shift)+iLow(symx,percalc,shift)+iClose(symx,percalc,shift)+iClose(symx,percalc,shift))/4;  break;
        case 7: inprc=(iOpen(symx,percalc,shift)+iHigh(symx,percalc,shift)+iLow(symx,percalc,shift)+iClose(symx,percalc,shift))/4;   break;
      }
    //--
    return(inprc);
//---
  } //- End FillPrice()
//---------//

double iMAOnBuffers(double &array[], // Array
                    int total,       // Total buffers
                    int period,      // MA Period
                    int ma_shift,    // MA Shift
                    ENUM_MA_METHOD ma_method, // MA Method
                    int shift)       // Buffers shift
   {
//----
     //--
     double buf[],arry[];
     if(total==0) total=ArraySize(array);
     if(total>0 && total<=period) return(0);
     if(shift>total-period-ma_shift) return(0);
     switch(ma_method)
       {
         case MODE_SMA :
           {
             total=ArrayCopy(arry,array,0,shift+ma_shift,period);
             if(ArrayResize(buf,total)<0) return(0);
             double sum=0;
             int i,pos=total-1;
             for(i=1;i<period;i++,pos--)
               sum+=arry[pos];
             while(pos>=0)
               {
                 sum+=arry[pos];
                 buf[pos]=sum/period;
                 sum-=arry[pos+period-1];
                 pos--;
               }
             return(buf[0]);
           }
         case MODE_EMA :
           {
             if(ArrayResize(buf,total)<0) return(0);
             double pr=2.0/(period+1);
             int pos=total-2;
             while(pos>=0)
               {
                 if(pos==total-2) buf[pos+1]=array[pos+1];
                 buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
                 pos--;
               }
             return(buf[shift+ma_shift]);
           }
         case MODE_SMMA :
           {
             if(ArrayResize(buf,total)<0) return(0);
             double sum=0;
             int i,k,pos;
             pos=total-period;
             while(pos>=0)
               {
                 if(pos==total-period)
                   {
                     for(i=0,k=pos;i<period;i++,k++)
                       {
                         sum+=array[k];
                         buf[k]=0;
                       }
                   }
                 else sum=buf[pos+1]*(period-1)+array[pos];
                 buf[pos]=sum/period;
                 pos--;
               }
             return(buf[shift+ma_shift]);
           }
         case MODE_LWMA :
           {
             if(ArrayResize(buf,total)<0) return(0);
             double sum=0.0,lsum=0.0;
             double price;
             int i,weight=0,pos=total-1;
             for(i=1;i<=period;i++,pos--)
               {
                 price=array[pos];
                 sum+=price*i;
                 lsum+=price;
                 weight+=i;
               }
             pos++;
             i=pos+period;
             while(pos>=0)
               {
                 buf[pos]=sum/weight;
                 if(pos==0) break;
                 pos--;
                 i--;
                 price=array[pos];
                 sum=sum-lsum+price*period;
                 lsum-=array[i];
                 lsum+=price;
               }
             return(buf[shift+ma_shift]);
           }
         default: return(0);
       }
     //--
     return(0);
//----
   } //-end iMAOnBuffers()
//---------//

string TF2Str(int period)
  {
//---
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
   //--
   return(string(period));
//---
  } //-end TF2Str()  
//---------//

void CreateSignalTemplate(long   chartid,
                          string obj_name,
                          int    x_size,
                          int    y_size,
                          int    style,
                          int    width,
                          int    border,
                          color  bordcolor,
                          color  bgcolor,
                          color  objcolor,
                          int    tcorner,
                          int    x_dist,
                          int    y_dist,
                          bool   hidden)
  {
//---
    ObjectCreate(chartid,obj_name,OBJ_RECTANGLE_LABEL,0,0,0); // create Rectangle Label
    ObjectSetInteger(chartid,obj_name,OBJPROP_XSIZE,x_size); 
    ObjectSetInteger(chartid,obj_name,OBJPROP_YSIZE,y_size);
    ObjectSetInteger(chartid,obj_name,OBJPROP_STYLE,style);
    ObjectSetInteger(chartid,obj_name,OBJPROP_WIDTH,width);
    ObjectSetInteger(chartid,obj_name,OBJPROP_BORDER_TYPE,border);
    ObjectSetInteger(chartid,obj_name,OBJPROP_BORDER_COLOR,bordcolor);
    ObjectSetInteger(chartid,obj_name,OBJPROP_BGCOLOR,bgcolor); 
    ObjectSetInteger(chartid,obj_name,OBJPROP_COLOR,objcolor);
    ObjectSetInteger(chartid,obj_name,OBJPROP_CORNER,tcorner); 
    ObjectSetInteger(chartid,obj_name,OBJPROP_XDISTANCE,WS(x_dist));
    ObjectSetInteger(chartid,obj_name,OBJPROP_YDISTANCE,y_dist);
    ObjectSetInteger(chartid,obj_name,OBJPROP_HIDDEN,hidden);
    ChartRedraw();
    //--
    return;
//---
   } //-end CreateSignalTemplate()
//---------//

bool CreateArrowLabel(long   chart_id, 
                      string lable_name, 
                      string label_text,
                      string font_model,
                      int    font_size,
                      color  label_color,
                      int    chart_corner,
                      int    x_cor, 
                      int    y_cor,
                      bool   price_hidden)
  { 
//--- 
    //--
    ObjectDelete(chart_id,lable_name);
    //--
    if(!ObjectCreate(chart_id,lable_name,OBJ_LABEL,0,0,0,0,0)) 
      { 
        Print(__FUNCTION__, 
            ": failed to create \"Arrow Label\" sign! Error code = ",GetLastError());
        return(false); 
      } 
    //--
    ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
    ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
    ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,WS(x_cor));
    ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
    ObjectSetInteger(chart_id,lable_name,OBJPROP_HIDDEN,price_hidden);
    //--- successful execution 
    return(true);
//---
  } //-end CreateArrowLabel()
//---------//

int WS(int width) // Width Scaling factor wide screen
  {
//---
    int reswidth=0;
    //--- Calculating the scaling factor wide button on a screen
    int scale_factor=(TerminalInfoInteger(TERMINAL_SCREEN_DPI));
    // The basic width in the screen points for standard monitors with DPI=96 
    //--- Use of the scaling factor 
    reswidth=(width * scale_factor) / 96;
    //--
    return(reswidth);
//---
  } //-end Widthscaling()
//---------//WS

void Do_Alerts(int dxal,int exal)
  {
//---
    if(dxal!=dxalp || exal!=exalp)
      {
        //--
        if(dxal!=dxalp && dxal==1)
          {
            msgText="DXY or USDX Start to Rice - Bullish";
            sigpos="Open BUY Order for USD";
            dxalp=dxal;
            EXAlerts(msgText,sigpos);
          }
        if(dxal!=dxalp && dxal==-1)
          {
            msgText="DXY or USDX Start to Down - Bearish";
            sigpos="Open SELL Order for USD";
            dxalp=dxal;
            EXAlerts(msgText,sigpos);
          }
        //--
        if(exal!=exalp && exal==1)
          {
            msgText="EXY or EURX Start to Rice - Bullish";
            sigpos="Open BUY Order for EUR";
            exalp=exal;
            EXAlerts(msgText,sigpos);
          }
        if(exal!=exalp && exal==-1)
          {
            msgText="EXY or EURX Start to Down - Bearish";
            sigpos="Open SELL Order for EUR";
            exalp=exal;
            EXAlerts(msgText,sigpos);
          }
        //--
      }
    //--
    return;
//---
  } //-end Do_Alerts()
//---------//

void EXAlerts(string text1,string text2)
  {
//---
    //--         
    Print(indname,"--- "+Symbol()+" - Calculation on "+TF2Str(percalc)+": "+text1+
          "\n --- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+text2);
    //--
    if(alerts==Yes)
      Alert(indname,"--- "+Symbol()+" - Calculation on "+TF2Str(percalc)+": "+text1+
            " --- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+text2);
    //--
    if(EmailAlert==Yes) 
      SendMail(indname,"--- "+Symbol()+" - Calculation on "+TF2Str(percalc)+": "+text1+
                       "\n --- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+text2);
    //--
    if(sendnotify==Yes) 
      SendNotification(indname+"--- "+Symbol()+" - Calculation on "+TF2Str(percalc)+": "+text1+
                       "\n --- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+text2);
    //--
    return;
//---
  } //-end EXAlerts()
//---------//

string getUninitReasonText(int reasonCode) 
  { 
//---
   string text=""; 
   //--- 
   switch(reasonCode) 
     { 
       case REASON_PROGRAM:
            text="The EA has stopped working calling by remove function."; break;
       case REASON_REMOVE: 
            text="Program "+__FILE__+" was removed from chart"; break;
       case REASON_RECOMPILE:
            text="Program recompiled."; break;    
       case REASON_CHARTCHANGE: 
            text="Symbol or timeframe was changed"; break;
       case REASON_CHARTCLOSE: 
            text="Chart was closed"; break; 
       case REASON_PARAMETERS: 
            text="Input-parameter was changed"; break;            
       case REASON_ACCOUNT: 
            text="Account was changed"; break; 
       case REASON_TEMPLATE: 
            text="New template was applied to chart"; break; 
       case REASON_INITFAILED:
            text="The OnInit() handler returned a non-zero value."; break;
       case REASON_CLOSE: 
            text="Terminal closed."; break;
       default: text="Another reason"; break;
     } 
   //--
   return text;
//---
  } //-end getUninitReasonText()
//---------//
//+------------------------------------------------------------------+