import "Color.dart";

/// Maintains relevant map data as well as a table of colors that can be used.
class World
{
    final int width, height;
    final List<int> map;
    final Map<int, Color> colorTable;

    Color ceiling, floor;

    World(this.width, this.height, this.map, this.ceiling, this.floor, this.colorTable);
}