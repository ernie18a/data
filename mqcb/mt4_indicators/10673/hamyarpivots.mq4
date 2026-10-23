//+------------------------------------------------------------------+
//|                                                 Hamyar Zones.mq4 |
//|                               Copyright © 2010,Farshad Saremifar |
//|                                                   www.4xline.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,Farshad Saremifar"
#property link      "www.4xline.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  PowderBlue
#property indicator_style1 STYLE_DASHDOTDOT

#property indicator_width1 1
#property indicator_color2  Red
#property indicator_style2 STYLE_DASHDOTDOT

#property indicator_color3  Red
#property indicator_style3 STYLE_DASHDOTDOT


#property indicator_color4  Red
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_color5  LawnGreen
#property indicator_style5 STYLE_DASHDOTDOT

#property indicator_color6  LawnGreen
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_color7  LawnGreen
#property indicator_style7 STYLE_DASHDOTDOT

//---- input parameters

extern string    Copyright="Copyright © 2010,Farshad Saremifar,www.4xline.com";
extern string    Help="!!!Attach HamyarZone Indicator Before Attaching this to chart!!!";
extern string    Help_Option1="1=Standard Pivots,2=MidPivots";
extern string    Help_Option2="3=Fibo Pivots,4=Camarilla";
extern int Pivot_Type=1;
extern string    Help_Option3="1=(H+L+C)/3,2=(H+L+C*2)/4";
extern int Pivot_Formula=1;

int NumberOfDays=5;
int ATR_Period=25;
int StartHour=9;

int StartMinute=0;
int MasterTF=60;
double R1[],Pivot[],S1[];
double R2[],R3[],S2[],S3[];

double PDayHigh[],PDayLow[];
double Range[];
datetime PivotDayStartTime;
int multiply;
int MyPoint;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
//---- indicators
   IndicatorDigits(Digits);
   SetIndexBuffer(0,Pivot);
   SetIndexBuffer(1,R1);
   SetIndexBuffer(2,R2);
   SetIndexBuffer(3,R3);
   SetIndexBuffer(4,S1);
   SetIndexBuffer(5,S2);
   SetIndexBuffer(6,S3);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);

   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   switch(Pivot_Type)
     {
      case 1:
         SetIndexLabel(0,"Pivot");
         SetIndexLabel(1,"R1");
         SetIndexLabel(2,"R2");
         SetIndexLabel(3,"R3");
         SetIndexLabel(4,"S1");
         SetIndexLabel(5,"S2");
         SetIndexLabel(6,"S3");
         break;
      case 2:
         SetIndexLabel(0,"Pivot");
         SetIndexLabel(1,"M5");
         SetIndexLabel(2,"M4");
         SetIndexLabel(3,"M3");
         SetIndexLabel(4,"M2");
         SetIndexLabel(5,"M1");
         SetIndexLabel(6,"M0");
         break;
      case 3:
         SetIndexLabel(0,"Pivot");
         SetIndexLabel(1,"R1-Fibo");
         SetIndexLabel(2,"R2-Fibo");
         SetIndexLabel(3,"R3-Fibo");
         SetIndexLabel(4,"S1-Fibo");
         SetIndexLabel(5,"S2-Fibo");
         SetIndexLabel(6,"S3-Fibo");
         break;
      case 4:
         SetIndexLabel(0,"Pivot");
         SetIndexLabel(1,"H5");
         SetIndexLabel(2,"H4");
         SetIndexLabel(3,"H3");
         SetIndexLabel(4,"L3");
         SetIndexLabel(5,"L4");
         SetIndexLabel(6,"L5");
         break;
      default:
         SetIndexLabel(0,"Pivot");
         SetIndexLabel(1,"R1");
         SetIndexLabel(2,"R2");
         SetIndexLabel(3,"R3");
         SetIndexLabel(4,"S1");
         SetIndexLabel(5,"S2");
         SetIndexLabel(6,"S3");
         break;

     }

   PivotDayStartTime=0;
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   StartHour=GlobalVariableGet("StartHour"+WindowHandle(Symbol(),Period())+Symbol()+Period());
   StartMinute=GlobalVariableGet("StartMinute"+WindowHandle(Symbol(),Period())+Symbol()+Period());
   ATR_Period=GlobalVariableGet("ATR_Period"+WindowHandle(Symbol(),Period())+Symbol()+Period());
   NumberOfDays=GlobalVariableGet("NumberOfDays"+WindowHandle(Symbol(),Period())+Symbol()+Period());
   int Tehranshift=GlobalVariableGet("Tehranshift"+WindowHandle(Symbol(),Period())+Symbol()+Period());

   int i,Count;

//   i=((NumberOfDays*1440)/Period())+((1440)/Period());
//----
//   if (Bars<i) return;

   int size=ArraySize(R1);
   ArrayResize(Range,size);
   ArrayResize(PDayHigh,size);
   ArrayResize(PDayLow,size);

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2;

   i=limit;
   while(i>=0)
     {
      if(PivotDay(Time[i+1]+Tehranshift-StartHour*60*60-StartMinute*60)!=PivotDay(Time[i]+Tehranshift-StartHour*60*60-StartMinute*60))
        {
         Count=iBarShift(Symbol(),0,PivotDayStartTime)-i;
         PDayHigh[i]= High[ iHighest(Symbol(),0,MODE_HIGH,Count,i+1) ];
         PDayLow[i] = Low[ iLowest(Symbol(),0,MODE_LOW,Count,i+1) ];
         Range[i]=PDayHigh[i]-PDayLow[i];
         switch(Pivot_Formula)
           {
            case 1:
               Pivot[i]=(PDayHigh[i]+PDayLow[i]+Close[i+1])/3;
               break;
            case 2:
               Pivot[i]=(PDayHigh[i]+PDayLow[i]+Close[i+1]*2)/4;
               break;
            default:
               Pivot[i]=(PDayHigh[i]+PDayLow[i]+Close[i+1])/3;
               break;
           }
         PivotDayStartTime=Time[i]+Tehranshift-StartHour*60*60-StartMinute*60;
         switch(Pivot_Type)
           {
            case 1:
               R1[i] = 2*Pivot[i] - PDayLow[i];
               R2[i] = Pivot[i] + Range[i];
               R3[i] = R1[i] + Range[i];
               S1[i] = 2*Pivot[i] - PDayHigh[i];
               S2[i] =  Pivot[i] - Range[i];
               S3[i] = S1[i] - Range[i];
               break;

            case 2:
               double r1 = 2*Pivot[i] - PDayLow[i];
               double r2 = Pivot[i] + Range[i];
               double r3 = r1 + Range[i];
               double s1 = 2*Pivot[i] - PDayHigh[i];
               double s2 =  Pivot[i] - Range[i];
               double s3 = s1 - Range[i];

               R1[i] = (r2+r3)/2;
               R2[i] = (r1+r2)/2;
               R3[i] =(Pivot[i]+r1)/2;
               S1[i] = (Pivot[i]+s1)/2;
               S2[i] = (s1+s2)/2;
               S3[i] =(s2+s3)/2;

               break;

            case 3:
               R1[i] = Pivot[i] + 0.382 *  Range[i];
               R2[i] = Pivot[i] + 0.618 *  Range[i];
               R3[i] = Pivot[i] + 1.000 *  Range[i];
               S1[i] = Pivot[i] - 0.382 *  Range[i];
               S2[i] = Pivot[i] - 0.618 *  Range[i];
               S3[i] = Pivot[i] - 1.000 *  Range[i];
               break;

            case 4:
               double D1=0.091667;
               double D2=0.183333;
               double D3=0.2750;
               double D4=0.55;
               R1[i] = (PDayHigh[i] / PDayLow[i])* Close[i+1];
               R2[i] = ((PDayHigh[i] - PDayLow[i])*D4)+ Close[i+1];
               R3[i] = ((PDayHigh[i] - PDayLow[i])*D3)+ Close[i+1];
               S1[i] = Close[i+1]-((PDayHigh[i] - PDayLow[i])*D3);
               S2[i] = Close[i+1]-((PDayHigh[i] - PDayLow[i])*D4);
               S3[i] = Close[i+1]-(R1[i]-Close[i+1]);
               break;

            default:
               R1[i] = 2*Pivot[i] - PDayLow[i];
               R2[i] = Pivot[i] + Range[i];
               R3[i] = R1[i] + Range[i];
               S1[i] = 2*Pivot[i] - PDayHigh[i];
               S2[i] =  Pivot[i] - Range[i];
               S3[i] = S1[i] - Range[i];
               break;
           }

         //--------------------------------------------------
         R1[i+1] =EMPTY_VALUE;
         R2[i+1] =EMPTY_VALUE;
         R3[i+1] =EMPTY_VALUE;
         S1[i+1] = EMPTY_VALUE;
         S2[i+1] = EMPTY_VALUE;
         S3[i+1] =EMPTY_VALUE;
         Pivot[i+1]=EMPTY_VALUE;

         R1[i+2] =EMPTY_VALUE;
         R2[i+2] =EMPTY_VALUE;
         R3[i+2] =EMPTY_VALUE;
         S1[i+2] =EMPTY_VALUE;
         S2[i+2] = EMPTY_VALUE;
         S3[i+2] =EMPTY_VALUE;
         Pivot[i+2]=EMPTY_VALUE;

         //-----------------------------------------

        }
      else
        {
         //========================================      
         R1[i] = R1[i+1];
         R2[i] = R2[i+1];
         R3[i] = R3[i+1];
         S1[i] = S1[i+1];
         S2[i] = S2[i+1];
         S3[i] = S3[i+1];
         Range[i]=Range[i+1];
         Pivot[i]= Pivot[i+1];

         //========================================    
        }
      i--;

     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

//--------------------
int PivotDay(datetime BarTime)
  {
   int PDay=TimeDayOfWeek(BarTime);

   if( PDay == 0 ) PDay = 5;
   if( PDay == 6 ) PDay = 5;

   return( PDay );
  }
//+------------------------------------------------------------------+
