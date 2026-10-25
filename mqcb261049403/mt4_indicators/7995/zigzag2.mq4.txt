//+------------------------------------------------------------------+
//|                                                       ZigZag.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
//---- indicator buffers
double ExtMapBuffer[];
double ExtLowBuffer[];
double ExtHighBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtLowBuffer);
   SetIndexBuffer(2,ExtHighBuffer);
   SetIndexEmptyValue(0,0.0);
//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos,index;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
//----
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      index=Lowest(NULL,0,MODE_LOW,ExtDepth,shift);
      val=Low[index];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtLowBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtLowBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtLowBuffer[shift]=0.0;
      if(val!=0.0) ExtLowBuffer[index]=val;
      //--- high
      index=Highest(NULL,0,MODE_HIGH,ExtDepth,shift);
      val=High[index];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtHighBuffer[shift+back];
               if((res!=0)&&(res<val)) ExtHighBuffer[shift+back]=0.0; 
              } 
           }
        }
      ExtHighBuffer[shift]=0.0;
      if(val!=0.0) ExtHighBuffer[index]=val;
     }
//---- final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   //..................................................................
   //....... Это вcтавленный код для визуального тестирования индикатора 
   /**/  int start,start_j;
   /**/start_j=ObjectGet("start",OBJPROP_TIME1);     
   /**/if(GetLastError()==0) start=iBarShift(NULL,0,start_j,False); else start=0;
   //................конец кода 
   //.....................................................................
   
   
 //  for(shift=Bars-ExtDepth; shift>=0; shift--)
   for(shift=Bars-ExtDepth; shift>=start; shift--)
     {
      curlow=ExtLowBuffer[shift];
      curhigh=ExtHighBuffer[shift];
      if(curlow==0 && curhigh==0) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtHighBuffer[lasthighpos]=0;
            else ExtHighBuffer[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtLowBuffer[lastlowpos]=0;
            else ExtLowBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
//---- merge 2 buffers
   lasthighpos=-1;
   lastlowpos=-1;
  // for(shift=Bars-1; shift>=0; shift--)
      for(shift=Bars-1; shift>=start; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         curlow=ExtLowBuffer[shift];
         curhigh=ExtHighBuffer[shift];
         //----
         res=0;
         if(curlow!=0)
           {
            if(lastlowpos==-1)
              {
               res=curlow;
               lastlowpos=shift;
              }
            else
              {
               if(lasthighpos!=-1 && lastlowpos>lasthighpos)
                 {
                  res=curlow;
                  lastlowpos=shift;
                 }
              }
           }
         if(curhigh!=0)
           {
            if(lasthighpos==-1)
              {
               res=curhigh;
               lasthighpos=shift;
              }
            else
              {
               if(lastlowpos!=-1 && lasthighpos>lastlowpos)
                 {
                  res=curhigh;
                  lasthighpos=shift;
                 }
              }
           }
         //----
         ExtMapBuffer[shift]=res;
        }
     }
  }
//+------------------------------------------------------------------+