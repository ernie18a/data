//+------------------------------------------------------------------+
//|                                         Pivot Lines TimeZone.mq5 |
//|                                          Copyright 2012, Integer |
//|                            https://www.mql5.com/ru/users/integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link "https://www.mql5.com/ru/users/integer"
#property description ""
#property version   "1.00"

#property description "Expert rewritten from MQL4, the author: Alejandro Galindo, published on mql4.com by Scriptor (http://www.mql4.com/ru/users/Scriptor), link - http://codebase.mql4.com/ru/1395"

#property indicator_chart_window
#property indicator_buffers 19
#property indicator_plots   17
//--- plot Pivot
#property indicator_label1  "Pivot"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot S1
#property indicator_label2  "S1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot R1
#property indicator_label3  "R1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot S2
#property indicator_label4  "S2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot R2
#property indicator_label5  "R2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDeepSkyBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot S3
#property indicator_label6  "S3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot R3
#property indicator_label7  "R3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDeepSkyBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1

//--- plot M0
#property indicator_label8  "M0"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot M1
#property indicator_label9  "M1"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot M2
#property indicator_label10  "M2"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrBlue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot M3
#property indicator_label11  "M3"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrBlue
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot M4
#property indicator_label12  "M4"
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrBlue
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot M5
#property indicator_label13  "M5"
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrBlue
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
//--- plot L3
#property indicator_label14  "L3"
#property indicator_type14   DRAW_LINE
#property indicator_color14  clrYellow
#property indicator_style14  STYLE_SOLID
#property indicator_width14  1
//--- plot H3
#property indicator_label15  "H3"
#property indicator_type15   DRAW_LINE
#property indicator_color15  clrYellow
#property indicator_style15  STYLE_SOLID
#property indicator_width15  1
//--- plot L4
#property indicator_label16  "L4"
#property indicator_type16   DRAW_LINE
#property indicator_color16  clrYellow
#property indicator_style16  STYLE_SOLID
#property indicator_width16  1
//--- plot H4
#property indicator_label17  "H4"
#property indicator_type17   DRAW_LINE
#property indicator_color17  clrYellow
#property indicator_style17  STYLE_SOLID
#property indicator_width17  1

//--- input parameters

input int      DayStartHour      =  0;                /*DayStartHour*/        // Hour of day start
input int      DayStartMinute    =  0;                /*DayStartMinute*/      // Minute of day start
input bool     PivotsBufers      =  false;            /*PivotsBufers*/        // Show the Pivot levels as the indicator bufers
input bool     MidpivotsBuffers  =  false;            /*MidpivotsBuffers*/    // Show the intermediate Pivot levels as the indicator bufers
input bool     CamarillaBuffers  =  false;            /*CamarillaBuffers*/    // Show the Camarilla levels as the indicator bufers
input bool     PivotsLines       =  true;             /*PivotsLines*/         // Show the current lines of Pivot as the horizontal lines
input bool     MidpivotsLines    =  false;            /*MidpivotsLines*/      // Show the current intermediate lines of Pivot as the horizontal lines
input bool     CamarillaLines    =  false;            /*CamarillaLines*/      // Show the current lines of Camarilla as the horizontal lines
 
input color    ClrPivot          =  clrOrange;        /*ClrPivot*/            // Color of the horizontal Pivot line
input color    ClrS              =  clrRed;           /*ClrS*/                // Color of the horizontal lines - S1, S2, S3
input color    ClrR              =  clrDeepSkyBlue;   /*ClrR*/                // Color of the horizontal lines - R1, R2, R3
input color    ClrM              =  clrBlue;          /*ClrM*/                // Color of the horizontal lines - M0, M1, M2, M3, M4, M5
input color    ClrCamarilla      =  clrYellow;        /*ClrCamarilla*/        // Color of the horizontal lines - Camarilla
input color    ClrTxt            =  clrWhite;         /*ClrTxt*/              // Color of labels with names of horizontal lines
input bool     AttachSundToMond  =  true;             /*AttachSundToMond*/    // Attach the sunday bars to monday

//--- indicator buffers
double         PivotBuffer[];
double         S1Buffer[];
double         R1Buffer[];
double         S2Buffer[];
double         R2Buffer[];
double         S3Buffer[];
double         R3Buffer[];

double         M0Buffer[];
double         M1Buffer[];
double         M2Buffer[];
double         M3Buffer[];
double         M4Buffer[];
double         M5Buffer[];

double         H3Buffer[];
double         L3Buffer[];
double         H4Buffer[];
double         L4Buffer[];

double         BufHigh[];
double         BufLow[];

datetime TimeShift;

double P;
double R1;
double S1;
double R2;
double S2;
double R3;
double S3;
double Q;
double H4;
double H3;
double L3;
double L4;
double M5;
double M4;
double M3;
double M2;
double M1;
double M0;

bool Redr;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   if(PivotsLines){
      fObjHLine("Pivot",0,"Pivot",0,ClrPivot,1,STYLE_DOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("S1",0,"S1",0,ClrS,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("R1",0,"R1",0,ClrR,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("S2",0,"S2",0,ClrS,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("R2",0,"R2",0,ClrR,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("S3",0,"S3",0,ClrS,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("R3",0,"R3",0,ClrR,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      
      fObjText("TxtPivot",0,0,"P",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtS1",0,0,"S1",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtR1",0,0,"R1",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtS2",0,0,"S2",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtR2",0,0,"R2",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtS3",0,0,"S3",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtR3",0,0,"R3",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      
   }
   if(MidpivotsLines){
      fObjHLine("M0",0,"M0",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("M1",0,"M1",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("M2",0,"M2",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("M3",0,"M3",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("M4",0,"M4",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("M5",0,"M5",0,ClrM,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      
      fObjText("TxtM0",0,0,"M0",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtM1",0,0,"M1",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtM2",0,0,"M2",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtM3",0,0,"M3",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtM4",0,0,"M4",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtM5",0,0,"M5",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
   }   
   
   if(CamarillaLines){
      fObjHLine("L3",0,"L3",0,ClrCamarilla,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("H3",0,"H3",0,ClrCamarilla,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("L4",0,"L4",0,ClrCamarilla,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      fObjHLine("H4",0,"H4",0,ClrCamarilla,1,STYLE_DASHDOTDOT,0,true,false,false,OBJ_ALL_PERIODS);
      
      fObjText("TxtL3",0,0,"L3",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtH3",0,0,"H3",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtL4",0,0,"L4",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
      fObjText("TxtH4",0,0,"H4",0,ANCHOR_LEFT_UPPER,ClrTxt,8,"Arial",0,false,0,false,false,OBJ_ALL_PERIODS);
   }  
   
   Redr=(PivotsLines || MidpivotsLines || CamarillaLines);   

   TimeShift=DayStartHour*3600+DayStartMinute*60;

//--- indicator buffers mapping
   SetIndexBuffer(0,PivotBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,S1Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,R1Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,S2Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,R2Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,S3Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,R3Buffer,INDICATOR_DATA);
   
   SetIndexBuffer(7,M0Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,M1Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,M2Buffer,INDICATOR_DATA);
   SetIndexBuffer(10,M3Buffer,INDICATOR_DATA);
   SetIndexBuffer(11,M4Buffer,INDICATOR_DATA);   
   SetIndexBuffer(12,M5Buffer,INDICATOR_DATA);
   
   SetIndexBuffer(13,L3Buffer,INDICATOR_DATA);
   SetIndexBuffer(14,H3Buffer,INDICATOR_DATA);
   SetIndexBuffer(15,L4Buffer,INDICATOR_DATA);
   SetIndexBuffer(16,H4Buffer,INDICATOR_DATA);   
   
   SetIndexBuffer(17,BufHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,BufLow,INDICATOR_CALCULATIONS);   
   
//---
   return(0);
  }

void OnDeinit(const int Rason){
   if(PivotsLines){
      ObjectDelete(0,"Pivot");
      ObjectDelete(0,"S1");
      ObjectDelete(0,"R1");
      ObjectDelete(0,"S2");
      ObjectDelete(0,"R2");
      ObjectDelete(0,"S3");
      ObjectDelete(0,"R3");
      ObjectDelete(0,"TxtPivot");
      ObjectDelete(0,"TxtS1");
      ObjectDelete(0,"TxtR1");
      ObjectDelete(0,"TxtS2");
      ObjectDelete(0,"TxtR2");
      ObjectDelete(0,"TxtS3");
      ObjectDelete(0,"TxtR3");      
   }
   if(MidpivotsLines){
      ObjectDelete(0,"M0");
      ObjectDelete(0,"M1");
      ObjectDelete(0,"M2");
      ObjectDelete(0,"M3");
      ObjectDelete(0,"M4");
      ObjectDelete(0,"M5");
      ObjectDelete(0,"TxtM0");
      ObjectDelete(0,"TxtM1");
      ObjectDelete(0,"TxtM2");
      ObjectDelete(0,"TxtM3");
      ObjectDelete(0,"TxtM4");
      ObjectDelete(0,"TxtM5");      
   }   
   
   if(CamarillaLines){
      ObjectDelete(0,"L3");
      ObjectDelete(0,"H3");
      ObjectDelete(0,"L4");
      ObjectDelete(0,"H4");
      ObjectDelete(0,"TxtL3");
      ObjectDelete(0,"TxtH3");
      ObjectDelete(0,"TxtL4");
      ObjectDelete(0,"TxtH4");      
   }  
   
   if(Redr)ChartRedraw();
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime & time[],
                 const double & open[],
                 const double & high[],
                 const double & low[],
                 const double & close[],
                 const long & tick_volume[],
                 const long & volume[],
                 const int & spread[]
               ){
   static bool error=true;
   int start;
      if(prev_calculated==0){
         error=true;
      }
      if(error){
         start=1;
         error=false;
      }
      else{
         start=prev_calculated-1;
      }
      for(int i=start;i<rates_total;i++){
         BufHigh[i]=BufHigh[i-1];
         BufLow[i]=BufLow[i-1];
         
         PivotBuffer[i]=PivotBuffer[i-1];
         S1Buffer[i]=S1Buffer[i-1];
         R1Buffer[i]=R1Buffer[i-1];
         S2Buffer[i]=S2Buffer[i-1];
         R2Buffer[i]=R2Buffer[i-1];
         S3Buffer[i]=S3Buffer[i-1];
         R3Buffer[i]=R3Buffer[i-1];
         
         M0Buffer[i]=M0Buffer[i-1];
         M1Buffer[i]=M1Buffer[i-1];
         M2Buffer[i]=M2Buffer[i-1];
         M3Buffer[i]=M3Buffer[i-1];
         M4Buffer[i]=M4Buffer[i-1];
         M5Buffer[i]=M5Buffer[i-1];         
         
         L3Buffer[i]=L3Buffer[i-1];
         H3Buffer[i]=H3Buffer[i-1];
         L4Buffer[i]=L4Buffer[i-1];
         H4Buffer[i]=H4Buffer[i-1];         
         
         datetime NowTime=time[i]-TimeShift;
         datetime PreTime=time[i-1]-TimeShift;
         
            if(NewDay(NowTime,PreTime)){
                  if(BufHigh[i]!=0){
                     P=(BufHigh[i]+BufLow[i]+close[i-1])/3;
                     R1=(2.0*P)-BufLow[i];
                     S1=(2.0*P)-BufHigh[i];
                     R2=P+(BufHigh[i]-BufLow[i]);
                     S2=P-(BufHigh[i]-BufLow[i]);      
                     R3=2.0*P+(BufHigh[i]-2.0*BufLow[i]);
                     S3=2.0*P-(2.0*BufHigh[i]-BufLow[i]);

                        if(PivotsBufers){
                           PivotBuffer[i]=P;
                           S1Buffer[i]=S1;
                           R1Buffer[i]=R1;
                           S2Buffer[i]=S2;
                           R2Buffer[i]=R2;
                           S3Buffer[i]=S3;
                           R3Buffer[i]=R3;                          
                        }
                        
                     Q=(BufHigh[i]-BufLow[i]);                     
                     H4=(Q*0.55)+close[i-1];
                     H3=(Q*0.27)+close[i-1];
                     L3=close[i-1]-(Q*0.27);
                     L4=close[i-1]-(Q*0.55);  
                     
                        if(CamarillaBuffers){
                           L3Buffer[i]=L3;
                           H3Buffer[i]=H3;
                           L4Buffer[i]=L4;
                           H4Buffer[i]=H4;  
                        }                     
                     
                     M5=(R2+R3)/2;
                     M4=(R1+R2)/2;
                     M3=(P+R1)/2;
                     M2=(P+S1)/2;
                     M1=(S1+S2)/2;
                     M0=(S2+S3)/2;

                        if(MidpivotsBuffers){
                           M0Buffer[i]=M0;
                           M1Buffer[i]=M1;
                           M2Buffer[i]=M2;
                           M3Buffer[i]=M3;
                           M4Buffer[i]=M4;
                           M5Buffer[i]=M5;
                        }                           
                                          

                  }
               BufHigh[i]=high[i];
               BufLow[i]=low[i];
            }
            else{
               BufHigh[i]=MathMax(BufHigh[i],high[i]);
               BufLow[i]=MathMin(BufLow[i],low[i]);
            }
      }
      
   datetime tm=time[rates_total-20];      
      
   if(PivotsLines){
      fObjMove("Pivot",P,tm);
      fObjMove("S1",S1,tm);
      fObjMove("R1",R1,tm);
      fObjMove("S2",S2,tm);
      fObjMove("R2",R2,tm);
      fObjMove("S3",S3,tm);
      fObjMove("R3",R3,tm);
      
   }
   if(MidpivotsLines){
      fObjMove("M0",M0,tm);
      fObjMove("M1",M1,tm);
      fObjMove("M2",M2,tm);
      fObjMove("M3",M3,tm);
      fObjMove("M4",M4,tm);
      fObjMove("M5",M5,tm);
   }   
   
   if(CamarillaLines){
      fObjMove("L3",L3,tm);
      fObjMove("H3",H3,tm);
      fObjMove("L4",L4,tm);
      fObjMove("H4",H4,tm);
   } 
   
   if(Redr)ChartRedraw();
      
   return(rates_total);               
}

void fObjMove( string   aObjName,
               double   aPrice,
               datetime aTime                     
                  ){
                  
   ObjectMove(0,aObjName,0,0,aPrice);                  
   ObjectMove(0,"Txt"+aObjName,0,aTime,aPrice);
}

void fObjHLine(   string   aObjName,
                  double   aPrice,
                  string   aText       =  "HLine",
                  int      aWindow     =  0,
                  color    aColor      =  Red,
                  color    aWidth      =  1,
                  color    aStyle      =  0,
                  int      aChartID    =  0,
                  bool     aBack       =  true,
                  bool     aSelectable =  true,
                  bool     aSelected   =  false,
                  long     aTimeFrames =  OBJ_ALL_PERIODS
               ){
   ObjectCreate(aChartID,aObjName,OBJ_HLINE,aWindow,0,aPrice);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_BACK,aBack);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_COLOR,aColor);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTABLE,aSelectable);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTED,aSelected);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_TIMEFRAMES,aTimeFrames);
   ObjectSetString(aChartID,aObjName,OBJPROP_TEXT,aText);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_WIDTH,aWidth);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_STYLE,aStyle);
   ObjectMove(aChartID,aObjName,0,0,aPrice);
}

void fObjText(   
                  string   aObjName,
                  datetime aTime,
                  double   aPrice,
                  string   aText       =  "ObjText",
                  int      aWindow     =  0,
                  int      aAnchor     =  ANCHOR_LEFT_UPPER,  
                  color    aColor      =  Red,
                  int      aFontSize   =  8,                  
                  string   aFont       =  "Arial", 
                  int      aChartID    =  0,
                  bool     aBack       =  false,
                  double   aAngle      =  0,
                  bool     aSelectable =  true,
                  bool     aSelected   =  false,
                  long     aTimeFrames =  OBJ_ALL_PERIODS
                  ){
   ObjectDelete(aChartID,aObjName);
   ObjectCreate(aChartID,aObjName,OBJ_TEXT,aWindow,aTime,aPrice);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_ANCHOR,aAnchor);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_BACK,aBack);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_COLOR,aColor);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_FONTSIZE,aFontSize);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTABLE,aSelectable);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTED,aSelected);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_TIMEFRAMES,aTimeFrames);
   ObjectSetString(aChartID,aObjName,OBJPROP_TEXT,aText);
   ObjectSetString(aChartID,aObjName,OBJPROP_FONT,aFont);
   ObjectSetDouble(aChartID,aObjName,OBJPROP_ANGLE,aAngle);   
   ObjectMove(aChartID,aObjName,0,aTime,aPrice);
}

bool NewDay(datetime aNowTime,datetime aPreTime){
   long NowDay=aNowTime/86400;
   long PreDay=aPreTime/86400;
      if(AttachSundToMond){
         if(NowDay!=PreDay){
            MqlDateTime nts,pts;
            TimeToStruct(aNowTime,nts);
            TimeToStruct(aPreTime,pts);
               if(nts.day_of_week==1 && pts.day_of_week==0){
                  return(false);
               }
            return(true);               
         }
      }
      else{
         return(NowDay!=PreDay);
      }
   return(false);   
}     