//+------------------------------------------------------------------+
//|                                                          bts.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart(){

   long bsum=0;
   long tsum=0;
   
   long bres=0;
   long tres=0;   

   Alert("=== начало ===");

   for(int f=0;f<30;f++){

      Alert("===> "+IntegerToString(f+1)+"/30");
      
      int Size=10000000;
      
      long start;
      int r;
      int a[];
      
      ArrayResize(a,Size);

         for(int i=1;i<Size;i++){
            a[i]=a[i-1]+MathRand()%10+1;
         }
      
      int v=a[MathRand()%Size];

      start=GetTickCount();
         for(int c=0;c<1000000;c++){
            r=bsearch(v,a);
         }
      bres=GetTickCount()-start;
      Alert("b: "+IntegerToString(bres));
   
      start=GetTickCount();   
         for(int c=0;c<1000000;c++){
            r=tsearch(v,a);
         }
      tres=GetTickCount()-start;    
      Alert("t: "+IntegerToString(tres));
      
      bsum+=bres;
      tsum+=tres;   
      
      if(ArrayBsearch(a,v)!=tsearch(v,a) || ArrayBsearch(a,v)!=tsearch(v,a)){
         Alert("Error!");
         return;
      }
   }
   
   Alert("bsum="+IntegerToString(bsum)+" tsum="+IntegerToString(tsum));   
   
   if(bsum<tsum){
      Alert("The binary searching is faster the ternary searching in "+DoubleToString(((double)tsum)/bsum,4)+" times");
   }
   else if(tsum<bsum){
      Alert("The ternary searching is faster the binary searching in "+DoubleToString(((double)bsum)/tsum,4)+" times");
   }
   else{
      Alert("Searching speed is equal");   
   }
   
   Alert("=== The End ===");

}

//+------------------------------------------------------------------+
// Ternary searching. s - sought value, a - array                    |
//+------------------------------------------------------------------+
int tsearch(int s,int & a[]){
   int n=ArraySize(a);
   if(n==0)return(-1);
   if(s<a[0])return(0);
   int r=n-1;  
   if(s>a[r])return(r);   
   int m[2];
   int mp[2]={-1,-1};   
   int l=0;   
   int t=(r-l)/3;
   m[0]=l+t;
   m[1]=r-t;
      while(m[0]!=mp[0] || m[1]!=mp[1]){
            if(s<a[m[0]]){
               r=m[0];
            }
            else if(s>a[m[1]]){
               l=m[1];      
            }
            else{
               l=m[0];               
               r=m[1];
            }
         mp[0]=m[0];
         mp[1]=m[1];
         t=(r-l)/3;
         m[0]=l+t;
         m[1]=r-t;
      } 
   int rv=-2;     
      for(int i=m[1];i>=m[0];i--){
         if(s>=a[i]){
            rv=i;
            break;
         }
      }
      for(int i=rv-1;i>=0;i--){
            if(a[i]!=a[rv]){
               break;
            }
         rv=i;
      }
   return(rv);
}

//+------------------------------------------------------------------+
// Binary searching. s - sought value, a - array                     |
//+------------------------------------------------------------------+
int bsearch(int s,int & a[]){
   int n=ArraySize(a);
   if(n==0)return(-1);
   if(s<a[0])return(0);
   int r=n-1;
   if(s>a[r])return(r);
   int l=0;
   int m;
   int pm=-1;
   m=(l+r)/2;
      while(m!=pm){         
            if(s<a[m]){
               r=m;
            }
            else if(s>a[m]){
               l=m;
            }
         pm=m;
         m=(l+r)/2;
      }
   int rv=-2;      
      for(int i=r;i>=l;i--){
         if(s>=a[i]){
            rv=i;
            break;
         }
      }
      for(int i=rv-1;i>=0;i--){
            if(a[i]!=a[rv]){
               break;
            }
         rv=i;
      }
   return(rv);
}
