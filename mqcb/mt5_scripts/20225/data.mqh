#include "Array.mqh"

#define _CS(A) ((!::IsStopped()) && (A))

template <typename T>
class DATA
{
protected:
  T Data[];
  int Reserve;

public:
  DATA( void ) : Reserve(0)
  {
  }

  uint Add( const T &Value )
  {
    return(ARRAY::AddElement(this.Data, Value, this.Reserve));
  }

  uint Add( const T &Value[] )
  {
    const int Size = this.SetReserve(::ArraySize(Value));

    for (int i = 0; _CS(i < Size); i++)
      this.Add(Value[i]);

    return(this.GetAmount());
  }

  uint GetAmount( void ) const
  {
    return(::ArraySize(this.Data));
  }

  void Clear( void )
  {
    ::ArrayFree(this.Data);

    return;
  }

  int SetReserve( const int inReserve = 0 )
  {
    return((inReserve > this.Reserve) ? this.Reserve = inReserve : inReserve); // https://www.mql5.com/ru/forum/1111/page1648#comment_2755753
  }

  int GetIndex( const T &Value ) const
  {
    return(ARRAY::GetIndex(this.Data, Value));
  }

  bool IsExist( const T &Value ) const
  {
    return(this.GetIndex(Value) != -1);
  }

  T operator []( const int Pos ) const
  {
    return(this.Data[Pos]);
  }
};