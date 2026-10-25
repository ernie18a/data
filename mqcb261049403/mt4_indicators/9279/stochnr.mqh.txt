/*
int Kperiod // %K
int Slowing // замедление
int PriceFild // тип цены: 0-High/Low; 1-Close/Close
double sens // чувствительность в щенах
int i // сдвиг
*/

double Stoch(int Kperiod, int Slowing, int PriceFild, double sens, int i) {  
   // экстремумы цены
   double max,min,c;
   for(int j=i; j<i+Slowing; j++) {
      if(PriceFild==1) { // по Close
         max+=Close[ArrayMaximum(Close,Kperiod,j)];
         min+=Close[ArrayMinimum(Close,Kperiod,j)];
        }
      else { // по High/Low
         max+=High[ArrayMaximum(High,Kperiod,j)];
         min+=Low[ArrayMinimum(Low,Kperiod,j)];
        }
      c+=Close[j];
     }
   
   double delta=max-min;
   if(delta<sens) {
      double sens2=sens/2;
      max+=sens2; min-=sens2;
     }
   delta=max-min;
   if(delta==0) double s0=1;
   else s0=(c-min)/delta;

   return(100*s0);
  }

