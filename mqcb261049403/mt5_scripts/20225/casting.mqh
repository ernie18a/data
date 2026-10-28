#ifndef __TYPETOBYTES__

template <typename T>
class CASTING
{
public:
  template <typename T1>
  static const T Casting( const T1 &Value )
  {
    union CAST
    {
      T1 Value1;
      const T Value2;

      CAST( const T1 &Value)
      {
        this.Value1 = Value; // кастомный оператор может все испортить
      }
    };

    const CAST Union(Value);

    return(Union.Value2);
  }
};

#define _C(A, B) CASTING<A>::Casting(B)

#endif // __TYPETOBYTES__