//+------------------------------------------------------------------+
//|                                                          SSA.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#property library

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define MaxCompCol 20
#define MaxCatLag  10  // 200
#define MaxLen     300 // 5000
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Equal(double &x1[][MaxCatLag],double &x2[][MaxCatLag],int t)
  {
//----
   int N=ArrayRange(x1,0);
   int M=ArrayRange(x1,1);

   for(int i=0; i<N; i++) for(int j=0; j<M; j++)
     {
      if(t) x1[i][j]=x2[j][i];
      else  x1[i][j]=x2[i][j];
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*Calculation of the Sn function, is needed for calculation of the eigen values
There the negative determinants are calculated*/
double gaussSn(double &A[][MaxCatLag],double l,int n)
  {
//----
   int count,cp,i1,i,j,k;
   double B[MaxCatLag][MaxCatLag]={0};
   double c;
   double w[];
   ArrayResize(w,n);
   double s1,s2;
//------
   Equal(B,A,0);
//------
   for(i=0; i<n; i++)
     {
      B[i][i]=B[i][i]-l;
     }
   cp=0;
   for(k=0;k<=n-2;k++)
     {
      for(i=k+1;i<=n-1;i++)
        {
         if(B[k][k]==0)
           {
            for(i1=0;i1<=n-1;i1++)
              {
               w[i1]=B[i1][k];
               B[i1][k]=B[i1][k+1];
               B[i1][k+1]=w[i1];
              }
            cp=cp+1;
           }
         c=B[i][k]/B[k][k];
         for(j=0;j<=n-1;j++)
           {
            B[i][j]=B[i][j]-B[k][j]*c;
           }
        }
     }
   count=0;
   s1=1;
   for(i=0;i<=n-1;i++)
     {
      s2=B[i][i];
      if(s2<0) count=count+1;
     }
//----
   ArrayFree(w);
   return(1.0*count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*Calculation of eigen values by bisection method}
  It is good as it will calculate as much eigen numbers, as needed,  
  greatly saves the resource */
double gaussbisectionl(double &A[][MaxCatLag],int k,int n)
  {
//----
   double e1,maxnorm,cn,a1,b1,c;
   int i,j;
   maxnorm=0;
   for(i=0;i<=n-1;i++)
     {
      cn=0;
      for(j=0;j<=n-1;j++) cn+=A[i][j];
      if(maxnorm<cn) maxnorm=cn;
     }
     
   a1=0;
   b1=10*maxnorm;
   e1=1.0*maxnorm/10000000;
   while(MathAbs(b1-a1)>e1)
     {
      c=1.0*(a1+b1)/2;
      if(gaussSn(A,c,n)<k)
         a1=c;
      else
         b1=c;
     }
//----
   return((a1+b1)/2.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*It calculates eigen vectors for already calculated eigen numbersl*/
void svector(double &A[][MaxCatLag],double l,int n,double &V[])
  {
//----
   int cp,i1,i,j,k;
   double B[MaxCatLag][MaxCatLag]={0};
   double c;
   double w[];
   ArrayResize(w,n);
   Equal(B,A,0);
   for(i=0;i<=n-1;i++) B[i][i]-=l;
   cp=0;
   for(k=0;k<=n-2;k++)for(i=k+1;i<=n-1;i++)
     {
      if(!B[k][k])
        {
         for(i1=0;i<=n-1;i++)
           {
            w[i1]=B[i1][k];
            B[i1][k]=B[i1][k+1];
            B[i1][k+1]=w[i1];
           }
         cp++;
        }
        
      c=1.0*B[i][k]/B[k][k];
      for(j=0;j<=n-1;j++) B[i][j]-=B[k][j]*c;
     }
     
   V[n-1]=1;
   c=1;
   for(i=n-2;i>=0;i--)
     {
      V[i]=0;
      for(j=i;j<=n-1;j++) V[i]-=B[i][j]*V[j];
      V[i]/=B[i][i];
      c+=V[i]*V[i];
     }
   for(i=0;i<=n-1;i++) V[i]/=MathSqrt(c);
//----
   ArrayFree(w);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*And here is the caterpillar itself}
{Х-vector of the source series
n-its length
l-lag length
s-number of the eigen components
(there the source series is divided into components and then restored, then you set how many components you will need)
Y - restored series (smoothed by the caterpillar) there I also added a comment where the separate
components of the series are located
*/
//---------------------------------------------------------------------------
void fastsingular(double &X[],int n,int l,int s,double &Y[])
  {
//----
   if(l>MaxCatLag) l=MaxCatLag;
   if(s>MaxCompCol) s=MaxCompCol;
   if(s>l) s=l;
   if(n>MaxLen) n=MaxLen;
   double A[MaxCatLag][MaxCatLag]={0};
   double B[MaxLen][MaxCatLag]={0};
   double Bn[MaxCatLag][MaxLen]={0};

   int kb,lb,m,k,i,j,i1;
   double V[MaxCatLag][MaxLen]={0};
   double Yn[MaxCatLag][MaxLen]={0};
   double ls[MaxCatLag]={0};
//---
   double Vtemp[MaxCatLag]={0};
//---
   j=0;
   k=n-l+1;
/*Form the A matrix (in the method that I downloaded from the developers web site it is the S matrix) */
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=l-1;j++)
        {
         A[i][j]=0;
         for(m=0;m<=k-1;m++)
           {
            A[i][j]+=X[i+m]*X[m+j];
            B[m][j]=X[m+j];
           }
        }
     }
/*Find the eigen numbers and the А matrix vectors*/
   for(i=0;i<=s-1;i++)
     {
      ls[i]=gaussbisectionl(A,l-i,l);
      svector(A,ls[i],l,Vtemp);
      for(j=0;j<=l-1; j++) V[i][j]=Vtemp[j];
     }
//------
/*The restored matrix is formed*/
   for(i1=0;i1<=s-1;i1++)
     {
      //------
      for(i=0;i<=k-1;i++)
        {
         Yn[i1][i]=0;
         for(j=0;j<=l-1;j++) Yn[i1][i]+=B[i][j]*V[i1][j];
        }
      //------
      for(i=0;i<=l-1;i++)for(j=0;j<=k-1;j++) Bn[i][j]=V[i1][i]*Yn[i1][j];
      //-------
      //Diagonal averaging (recovery series)
      kb=k;
      lb=l;
      for(i=0;i<=n-1;i++)
        {
         Yn[i1][i]=0;
         if(i<lb-1)
           {
            for(j=0;j<=i;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]/=(1.0*(i+1));
           }
         if((lb-1<=i) && (i<kb-1))
           {
            for(j=0;j<=lb-1;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]=Yn[i1][i]/(1.0*lb);
           }
         if(kb-1<=i)
           {
            for(j=i-kb+1;j<=n-kb;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]/=(1.0*(n-i));
           }
        }
     }
/* If you do not sum up here, then there will be separate components of dissection
	of the process by eigen functions */
   for(i=0;i<=n-1;i++)
     {
      Y[i]=0;
      for(i1=0;i1<=s-1;i1++) Y[i]+=Yn[i1][i];
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*{Х-vector of the source series
n-its length
l-lag length
s-number of the eigen components
(there the source series is divided into components and then restored, then you set how many components you will need)
Y - restored series (smoothed by the caterpillar) there I also added a comment where the separate
components of the series are located
*/
//---------------------------------------------------------------------------
void singularPCA(double &X[],int n,int l,int s,double &Y[])
  {
//----
   if(l>MaxCatLag) l=MaxCatLag;
   if(s>MaxCompCol) s=MaxCompCol;
   if(s>l) s=l;
   if(n>MaxLen) n=MaxLen;
   double A[MaxCatLag][MaxCatLag]={0};
   double B[MaxLen][MaxCatLag]={0};
   double Bn[MaxCatLag][MaxLen]={0};

   int kb,lb,m,k,i,j,i1;
   double V[MaxCatLag][MaxLen]={0};
   double Yn[MaxCatLag][MaxLen]={0};
   double ls[MaxCatLag]={0};
//---
   double Vtemp[MaxCatLag]={0};
//---
   j=0;
   k=n-l+1;
/*Form the A matrix (in the method that I downloaded from the developers web site it is the S matrix) */
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=l-1;j++)
        {
         A[i][j]=0;
         for(m=0;m<=k-1;m++)
           {
            A[i][j]+=X[i+m]*X[m+j];
            B[m][j]=X[m+j];
           }
        }
     }
/*Find the eigen numbers and the А matrix vectors*/
//for (i=0;i<=s-1;i++)
// {
   ls[s]=gaussbisectionl(A,l-s,l);
   svector(A,ls[s],l,Vtemp);
   for(j=0;j<=l-1; j++) V[s][j]=Vtemp[j];
// }
//------
/*The restored matrix is formed*/
   i1=s;
//------
   for(i=0;i<=k-1;i++)
     {
      Yn[i1][i]=0;
      for(j=0;j<=l-1;j++) Yn[i1][i]+=B[i][j]*V[i1][j];
     }
//------
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=k-1;j++) Bn[i][j]=V[i1][i]*Yn[i1][j];
     }
//-------
//Diagonal averaging (recovery series)
   kb=k;
   lb=l;
   for(i=0;i<=n-1;i++)
     {
      Yn[i1][i]=0;
      if(i<lb-1)
        {
         for(j=0;j<=i;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]=Yn[i1][i]/(1.0*(i+1));
        }
      if((lb-1<=i) && (i<kb-1))
        {
         for(j=0;j<=lb-1;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]=Yn[i1][i]/(1.0*lb);
        }
      if(kb-1<=i)
        {
         for(j=i-kb+1;j<=n-kb;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]/=(1.0*(n-i));
        }
     }
/* If you do not sum up here, then there will be separate components of dissection
	of the process by eigen functions */
   for(i=0;i<=n-1;i++)
     {
      Y[i]=0;
      Y[i]=Yn[s][i];
     }
//----
  }
//-----------------------------------------------------------------------------+
