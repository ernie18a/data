//+------------------------------------------------------------------+
//|                                                        Nerve.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Kudryashov Denis."
#property link "https://www.mql5.com/ru/users/krauzz"
#property version   "1.10"
#property script_show_inputs
#property strict


input int Day_Pr=30;//Day
input bool Vzv=false;//WMA
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
 
int zz,zz1,max1,  dfg, dss,nn1=0,dday,day1=8,dz,dzz;
 
double PP,ds;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(Day_Pr>=5)dfg=Day_Pr/5*7;

   dss=(int)(24*60/_Period*dfg);
   //----------------------------
   

      for(int i=1;i<dss;i++)
        {
        
    
         

         if(i>=dss-1)
           {
 
             if(!Vzv) PP=(int)(zz/dfg);
            if(Vzv) PP= (int)(ds/dzz);
             
               Alert((int)PP," Pips - Day, PerMax-",nn1," DayMax-",max1);
                
               break;
              

           }

         double nn=int(MathAbs((iHigh(NULL,0,i)-iLow(NULL,0,i))/_Point));
         datetime tm2= iTime(NULL,0,i);
         MqlDateTime stm;
         TimeToStruct(tm2,stm); 
 
        
         dday=stm.day_of_week;
         
         if(nn>nn1)nn1=(int)nn;//max
         Print(dday);
         if(dday!=day1 && zz1>0&& Vzv) {dz++;dzz=dz+dzz;day1=dday;ds+=zz1*dz;zz1=0;}
         if(dday!=day1 && zz1>0&&!Vzv) {day1=dday;zz1=0; }

         zz1+=(int)nn;
         if(zz1>max1)max1=zz1;

         if(!Vzv)zz+=(int)nn;

        }

     

  }
//+------------------------------------------------------------------+
