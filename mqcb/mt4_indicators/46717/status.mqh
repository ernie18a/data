#property strict

struct SMovement{
   int      direction;
   int      size;
   double   price_base; 
};

bool GetLastMovement(SMovement & movement, int size) {
   // определяет направление текущего движения 
   movement.direction = -1;
   double start_point = Bid;
   for(int i=0;i<Bars;i++) {
      if(High[i] >= start_point + size*_Point) {
         movement.direction=1;
         break;
      }
      if(Low[i] <= start_point - size*_Point) {
         movement.direction=0;
         break;
      }
   }
   if(movement.direction<0)
      return(false);
   
   // определяем размер последнего движения исходя из размера
   double new_exrem_opposite = Bid;
   double new_extrem         = Bid;
   for(int i=0;i<Bars;i++) {
      if(movement.direction==0) {
         new_exrem_opposite = MathMax(new_exrem_opposite, High[i]);
         new_extrem         = MathMin(new_extrem, Low[i]);
         if(High[i] > new_extrem + size*_Point)
            break;
      }
      if(movement.direction==1) {
         new_exrem_opposite = MathMin(new_exrem_opposite, Low[i]);
         new_extrem         = MathMax(new_extrem, High[i]);
         if(Low[i] < new_extrem - size*_Point)
            break;
      }
   }
   movement.size = int(MathAbs(new_exrem_opposite - new_extrem)/_Point);
   movement.price_base = new_extrem;
   return(true);
}


