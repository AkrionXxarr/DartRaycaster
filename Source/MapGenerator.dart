import 'dart:math';

import "World.dart";
import "Camera.dart";

/// Randomly generates a pre-defined section of the map when the right conditions occur.
///
/// The conditions for generating require that the camera has moved either above or below
/// the top or bottom boundaries of the random generation when it hadn't been there prior.
/// (e.g. The camera was on top, but has now passed the lower boundary)
class MapGenerator
{
    Random rand;
    World world;
    Camera camera;

    /// Defines the rectangle that map generation can happen within.
    int top, bottom, left, right;

    /// Defines the vertical column the camera will be traveling along.
    int pathCol;

    bool canUpdate = true;
    bool onTop = true;

    static const int ROOM_HALL = 0;
    static const int ROOM_SMALL = 1;
    static const int ROOM_LARGE = 2;
    static const int RANDOM = 3;

    MapGenerator(this.world, this.camera, this.top, this.bottom, this.left, this.right, this.pathCol)
    {
        rand = new Random();
    }

    /// Verifies whether the appropriate conditions have occurred for map generation and generates if so.
    void update()
    {
        // Have the conditions to generate the map been fulfilled?
        if (camera.pos.y < top && !onTop)
        {
            canUpdate = true;
            onTop = true;
        }
        else if (camera.pos.y > bottom && onTop)
        {
            canUpdate = true;
            onTop = false;
        }

        // Generate the map if conditions have been fulfilled.
        if (canUpdate)
        {
            canUpdate = false;

            for (int row = top; row < bottom; row++)
            {
                for (int col = left; col < right; col++)
                {
                    world.map[row * world.width + col] = 0;
                }
            }

            /// The top most row that a room can begin from
            int rowStart = top;

            /// The maximum number of rows the room can expand to
            int maxRows = bottom - top;

            /// How many rooms are drawn in the same color before generating a new color.
            int roomsPerColor = rand.nextInt(3) + 2;
            /// Randomly generated color to draw the rooms in.
            int color = rand.nextInt(world.colorTable.length) + 1;

            int colorCounter = 0;

            while (maxRows > 0)
            {
                /// How many rows were used by the room generation
                int rowsUsed = 0;
                switch (rand.nextInt(4))
                {
                    case ROOM_HALL:
                        rowsUsed = hall(maxRows, rowStart, color);
                        break;

                    case ROOM_SMALL:
                        rowsUsed = smallRoom(maxRows, rowStart, color);
                        break;

                    case ROOM_LARGE:
                        rowsUsed = largeRoom(maxRows, rowStart, color);
                        break;

                    case RANDOM:
                        if (rand.nextInt(4) == 0)
                            rowsUsed = randomRoom(maxRows, rowStart, color);
                        break;
                }

                maxRows -= rowsUsed;
                rowStart += rowsUsed;

                colorCounter++;

                if (colorCounter >= roomsPerColor)
                {
                    // Get a new random color
                    colorCounter = 0;
                    roomsPerColor = rand.nextInt(3) + 2;
                    color = rand.nextInt(world.colorTable.length) + 1;
                }
            }

            cutPath();
        }
    }

    /// Generates an empty hallway.
    int hall(int maxRows, int rowStart, int color)
    {
        int width = (rand.nextInt(3) + 1) + 2; // Random from 1 to 3, +2 for walls
        int height = rand.nextInt(min(6, maxRows)) + 1;
        int offset = rand.nextInt(width - 2);

        List<int> room = basicRoom(width, height, color);

        int colStart = (pathCol - 1) - offset;
        for (int row = rowStart; row < height + rowStart; row++)
        {
            for (int col = colStart; col < colStart + width; col++)
            {
                world.map[row * world.width + col] = room[(row - rowStart) * width + (col - colStart)];
            }
        }

        return height;
    }

    /// Generates a small empty room.
    int smallRoom(int maxRows, int rowStart, int color)
    {
        int width = (rand.nextInt(4) + 3) + 2; // Random from 4 to 7, +2 for walls
        int height = rand.nextInt(min(6, maxRows)) + 1;
        int offset = rand.nextInt(width - 2);

        List<int> room = basicRoom(width, height, color);

        int colStart = (pathCol - 1) - offset;
        for (int row = rowStart; row < height + rowStart; row++)
        {
            for (int col = colStart; col < colStart + width; col++)
            {
                world.map[row * world.width + col] = room[(row - rowStart) * width + (col - colStart)];
            }
        }

        return height;
    }

    /// Generates a large empty room.
    int largeRoom(int maxRows, int rowStart, int color)
    {
        int width = (rand.nextInt(8) + 8) + 2; // Random from 8 to 16, +2 for walls
        int height = rand.nextInt(min(16, maxRows)) + 1;
        //int offset = rand.nextInt(width - 2);

        List<int> room = basicRoom(width, height, color);

        int colStart = (pathCol - (width ~/ 2));
        for (int row = rowStart; row < height + rowStart; row++)
        {
            for (int col = colStart; col < colStart + width; col++)
            {
                world.map[row * world.width + col] = room[(row - rowStart) * width + (col - colStart)];
            }
        }

        return height;
    }

    /// Generates a large area that's just random walls.
    int randomRoom(int maxRows, int rowStart, int color)
    {
        int width = (rand.nextInt(10) + 10) + 2; // Random from 10 to 20, +2 for walls
        int height = rand.nextInt(min(20, maxRows)) + 1;

        List<int> room = new List<int>(width * height);

        for (int row = 0; row < height; row++)
        {
            for (int col = 0; col < width; col++)
            {
                int t = rand.nextInt(10);

                if (t == 0)
                {
                    room[row * width + col] = rand.nextInt(world.colorTable.length);
                }
                else
                {
                    room[row * width + col] = 0;
                }
            }
        }

        int colStart = (pathCol - (width ~/ 2));
        for (int row = rowStart; row < height + rowStart; row++)
        {
            for (int col = colStart; col < colStart + width; col++)
            {
                world.map[row * world.width + col] = room[(row - rowStart) * width + (col - colStart)];
            }
        }

        return height;
    }

    /// Helper function that makes a basic room parimeter.
    List<int> basicRoom(int width, int height, int color)
    {
        List<int> room = new List<int>(width * height);

        for (int row = 0; row < height; row++)
        {
            for (int col = 0; col < width; col++)
            {
                room[row * width + col] = color;
            }
        }

        for (int row = 1; row < height - 1; row++)
        {
            for (int col = 1; col < width - 1; col++)
            {
                room[row * width + col] = 0;
            }
        }

        return room;
    }

    /// Ensures that the path the camera travels along is clear.
    void cutPath()
    {
        for (int row = top; row < bottom; row++)
        {
            world.map[row * world.width + pathCol] = 0;
        }
    }
}