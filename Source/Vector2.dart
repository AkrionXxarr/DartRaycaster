import 'dart:math';

/// 2 dimensional vector class with typical mathematical vector operations.
///
/// Contains some additional functions such as obtaining the square magnitude,
/// lerp, rotating the vector, and swizzling.
class Vector2
{
    double x, y;

    Vector2(this.x, this.y);

    double magnitude()
    {
        return sqrt(x * x + y * y);
    }

    double sqrMagnitude()
    {
        return x * x + y * y;
    }

    Vector2 normalized()
    {
        double m = magnitude();

        return new Vector2(x / m, y / m);
    }

    double dot(Vector2 o)
    {
        return (x * o.x) + (y * o.y);
    }

    double cross(Vector2 o)
    {
        return (x * o.y) - (y * o.x);
    }

    Vector2 rotateDeg(double deg)
    {
        double rad = deg * (PI / 180.0);

        return rotateRad(rad);
    }

    Vector2 rotateRad(double rad)
    {
        double cosine = cos(rad);
        double sine = sin(rad);

        return new Vector2((x * cosine - y * sine), (x * sine + y * cosine));
    }

    Vector2 lerp(Vector2 dest, double factor)
    {
        return ((dest - this) * factor) + this;
    }

    Vector2 operator +(Vector2 o) { return new Vector2(x + o.x, y + o.y); }
    Vector2 operator -(Vector2 o) { return new Vector2(x - o.x, y - o.y); }
    Vector2 operator *(double d) { return new Vector2(x * d, y * d); }
    Vector2 operator /(double d) { return new Vector2(x / d, y / d); }

    Vector2 yx() { return new Vector2(y, x); }

    Vector2 zero() { return new Vector2(0.0, 0.0); }
}