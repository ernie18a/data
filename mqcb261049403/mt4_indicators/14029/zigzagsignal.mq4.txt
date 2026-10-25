//+------------------------------------------------------------------+
//|                                                ZigZag Signal.mq4 |
//|                                                         Greshnik |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Greshnik"
#property link      ""
#property version   "2.00"
#property strict

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

input int      zigzag_Depft=4;
input int      zigzag_Deviation=2;
input int      zigzag_Backstep=2;
input int      MinHeight=60;//Минимальная высота 1-го колена ZigZag(пункты)
input double   MinHeightM234=1.15;//Минимальное отношение 2-й вершины к 1-й и 3-й к 4-й.
input double   Bottom=0.1;//Максимальное отклонение 2-й вершины дна от 1-й по отношениию к высоте 1-го колена

double   mBuffer0[];
double   mBuffer1[];
double   mBuffer2[];
double   mBuffer3[];

datetime last_time;
double points[5][2];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,mBuffer0);
   SetIndexStyle(0,DRAW_ARROW,0,2);
   SetIndexArrow(0,233);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"BUY");

   SetIndexBuffer(1,mBuffer1);
   SetIndexStyle(1,DRAW_ARROW,0,2);
   SetIndexArrow(1,234);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"SELL");

   SetIndexBuffer(2,mBuffer2);
   SetIndexStyle(2,DRAW_ARROW,0,1);
   SetIndexArrow(2,174);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"zBuy");

   SetIndexBuffer(3,mBuffer3);
   SetIndexStyle(3,DRAW_ARROW,0,1);
   SetIndexArrow(3,174);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,"zSell");

   last_time=0;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   int bars;
   int i1,pos1;
   double d1,d2,d3;
   datetime t1;
   int filling;

   t1=Time[1];
   if(last_time>=t1)
     {
      return rates_total;
     }
   last_time=t1;

   bars=rates_total-prev_calculated;

   filling=5;
   for(pos1=0;((pos1<bars) || (filling>0)) && (pos1<rates_total);pos1++)
     {
      d1=iCustom(Symbol(),Period(),"Zigzag",zigzag_Depft,zigzag_Deviation,zigzag_Backstep,0,pos1);
      d2=iCustom(Symbol(),Period(),"Zigzag",zigzag_Depft,zigzag_Deviation,zigzag_Backstep,1,pos1);
      d3=iCustom(Symbol(),Period(),"Zigzag",zigzag_Depft,zigzag_Deviation,zigzag_Backstep,2,pos1);

      if(d1>0.0001)
        {
         filling--;
         for(i1=3;i1>=0;i1--)
           {
            points[i1+1][0]=points[i1][0];
            points[i1+1][1]=points[i1][1];
           }
         points[0][0]=pos1;
         points[0][1]=d1;

         if(filling<=0)
           {
            if(MathAbs(points[0][1]-points[1][1])<0.00000001)
              {
               filling=5;
               continue;
              }
            if(
               ((points[2][1]-points[1][1])/(points[0][1]-points[1][1])>=MinHeightM234)&&
               ((points[4][1]-points[3][1])/(points[2][1]-points[1][1])>=MinHeightM234)&&
               (MathAbs(points[3][1]-points[1][1])/MathAbs(points[0][1]-points[1][1])<=Bottom)
               )
              {
               if((points[0][1]-points[1][1])/Point>=MinHeight)
                 {
                  mBuffer1[(int)points[4][0]]=points[4][1]+MinHeight*Point/2;
                  for(i1=0;i1<4;i1++)
                    {
                     mBuffer3[(int)points[i1][0]]=points[i1][1];
                    }
                 }
               else
               if((points[0][1]-points[1][1])/Point<=-MinHeight)
                 {
                  mBuffer0[(int)points[4][0]]=points[4][1]-MinHeight*Point/2;
                  for(i1=0;i1<4;i1++)
                    {
                     mBuffer2[(int)points[i1][0]]=points[i1][1];
                    }
                 }
              }
            filling=0;
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
