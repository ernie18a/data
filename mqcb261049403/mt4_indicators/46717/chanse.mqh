#property strict

class CMovement{
   public:
      int      movement[];
      int      movement_size;
      CMovement(int new_size) {
         movement_size = new_size;
      }
      void     SetMovementSize(int new_size) {
         movement_size = new_size;
         CalcMovements();
      }
      int      GetMovementsCount() { return(ArraySize(movement)); }
      void     CalcMovements();
      double   GetPercentBySize(int size);
      int      GetSizeByPercent(double percent);
};

void CMovement::CalcMovements(void) {
   // пересчитываем имеющиеся движения
   int      movements = 0;
   ArrayResize(movement,100000);
   
   int      bars_total     = iBars(NULL,PERIOD_CURRENT);
   
   int      mov_direction  = -1;
   double   mov_price[2];
   mov_price[0]   = Open[bars_total-1];
   mov_price[1]   = Open[bars_total-1];
   
   for(int b=bars_total-1;b>=0;b--) {
      // define direction
      if(mov_direction==-1) {
         // first movement up
         if(High[b] >= mov_price[1] + movement_size*_Point) {
            mov_direction = 0;
            mov_price[0] = High[b];
            continue;
         }
         // first movement down
         if(Low[b] <= mov_price[1] - movement_size*_Point) {
            mov_direction = 1;
            mov_price[0] = Low[b];
            continue;
         }
      }
      // last direction is up
      if(mov_direction==0) {
         // update up price
         mov_price[0] = MathMax(High[b], mov_price[0]);
         // break movement
         if(Low[b] <= mov_price[0] - movement_size*_Point) {
            movements++;
            if(movements>ArraySize(movement)) 
               ArrayResize(movement,ArraySize(movement)+10000,0);
            movement[movements-1] = int(MathAbs(mov_price[1] - mov_price[0]) / _Point);
            mov_direction  = 1;
            mov_price[1]   = mov_price[0];
            mov_price[0]   = Low[b];
         }
      }
      // last direction is down
      if(mov_direction==1) {
         // update down price
         mov_price[0] = MathMin(Low[b], mov_price[0]);
         // break movement
         if(High[b] >= mov_price[0] + movement_size*_Point) {
            movements++;
            if(movements>ArraySize(movement)) 
               ArrayResize(movement,ArraySize(movement)+10000,0);
            movement[movements-1] = int(MathAbs(mov_price[1] - mov_price[0]) / _Point);
            mov_direction  = 0;
            mov_price[1]   = mov_price[0];
            mov_price[0]   = High[b];
         }
      }
   }
   ArrayResize(movement,movements);
   ArraySort(movement);
   //Print("total movements: ",ArraySize(movement)," | ",movement[0]," - ",movement[ArraySize(movement)-1]);
}

//---
double CMovement::GetPercentBySize(int size) {
   // рассчитываем процент исходя из размера движения
   return((ArrayBsearch(movement,size) / (double)ArraySize(movement))* 100.0);
}

//---
int CMovement::GetSizeByPercent(double percent) {
   // рассчитываем размер движения исходя из процента
   int index = int((percent/100) * ArraySize(movement)) - 1;
   if(index<0) index = 0;
   return(movement[index]);
}