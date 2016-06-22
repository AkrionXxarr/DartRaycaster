import 'dart:math';

import "Vector2.dart";
import "DisplayDevice.dart";
import "World.dart";
import "Color.dart";

/// Represents everything needed for a basic camera.
///
/// Position, forward, left, and screen distance. This class also
/// handles the raycasting and drawing.
class Camera
{
    /// General camera data
    Vector2 pos, forward, left;

    /// Distance the "screen" is from the camera
    double screenDistance;

    /// Maximum distance to cast a ray before giving up.
    int maxCast;

    Camera(this.pos, this.forward, this.screenDistance, this.maxCast)
    {
        forward = forward.normalized();
        left = forward.rotateDeg(-90.0);
    }

    void rotate(double rad)
    {
        forward = forward.rotateRad(rad);
        left = left.rotateRad(rad);
    }

    void translate(Vector2 dir)
    {
        pos = pos + dir;
    }

    void move(double factor)
    {
        pos = pos + (forward * factor);
    }

    /// Executes the raycast and draws accordingly.
    void draw(DisplayDevice device, World world)
    {
        int sWidth = device.getWidth();
        int sHeight = device.getHeight();
        int sSize = sWidth * sHeight;
        var buffer = device.getBuffer();

        /// Helper inline function to draw a pixel to an rgba byte buffer
        drawPixel(int x, int y, int r, int g, int b)
        {
            if (x < 0 || y < 0 || x >= sWidth || y >= sHeight)
                return;

            int index = (y * sWidth + x) * 4;
            buffer[index] = r;
            buffer[index + 1] = g;
            buffer[index + 2] = b;
            buffer[index + 3] = 255;
        }

        /// Helper inline function to get a ray cast at the specified x coordinate
        Vector2 getRay(int x)
        {
            double t = 1 - ((x / sWidth) * 2); // Make range 1 to -1
            Vector2 offset = this.left * t;
            Vector2 ray = ((this.forward * this.screenDistance) + offset);
            return ray;
        }

        // Draw the floor and ceiling
        for (int i = 0; i < sSize; i++)
        {
            int index = i * 4;
            Color color;

            if (i < sSize / 2)
                color = world.ceiling;
            else
                color = world.floor;

            buffer[index] = color.r;
            buffer[index + 1] = color.g;
            buffer[index + 2] = color.b;
            buffer[index + 3] = color.a;
        }

        // Begin raycasting
        for (int x = 0; x < sWidth; x++)
        {
            int xMap = pos.x.toInt();
            int yMap = pos.y.toInt();

            Vector2 ray = getRay(x);

            double dx = sqrt(1 + (ray.y * ray.y) / (ray.x * ray.x));
            double dy = sqrt(1 + (ray.x * ray.x) / (ray.y * ray.y));
            double wallDist = 0.0;

            double xDist, yDist;
            double xStep, yStep;

            int hit = 0;
            int side;

            if (ray.x < 0)
            {
                xStep = -1.0;
                xDist = (pos.x - xMap) * dx;
            }
            else
            {
                xStep = 1.0;
                xDist = (xMap + 1.0 - pos.x) * dx;
            }

            if (ray.y < 0)
            {
                yStep = -1.0;
                yDist = (pos.y - yMap) * dy;
            }
            else
            {
                yStep = 1.0;
                yDist = (yMap + 1.0 - pos.y) * dy;
            }

            /// Makes sure we don't cast a ray forever.
            int count = 0;
            while (hit == 0 && count < maxCast)
            {
                if (xDist < yDist)
                {
                    xDist += dx;
                    xMap += xStep;
                    side = 0;
                }
                else
                {
                    yDist += dy;
                    yMap += yStep;
                    side = 1;
                }

                count++;
                hit = world.map[yMap * world.width + xMap];
            }

            if (hit == 0)
                continue;

            if (side == 0)
                wallDist = (xMap - pos.x + (1.0 - xStep) / 2.0) / ray.x;
            else
                wallDist = (yMap - pos.y + (1.0 - yStep) / 2.0) / ray.y;

            int lineHeight = ((sHeight / 2) ~/ wallDist);

            Color color = world.colorTable[hit];

            for (int y = (sHeight ~/ 2) - (lineHeight ~/ 2); y < (sHeight ~/ 2) + (lineHeight ~/ 2); y++)
            {
                if (side == 1)
                    drawPixel(x, y, color.r, color.g, color.b);
                else
                    drawPixel(x, y, color.r ~/ 2, color.g ~/ 2, color.b ~/ 2);
            }
        }
    }
}