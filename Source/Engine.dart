import 'dart:html';
import 'dart:math';

import "DisplayDevice.dart";

import "Vector2.dart";
import "Color.dart";
import "MapDef.dart";

import "Camera.dart";
import "World.dart";
import "Motor.dart";
import "MapGenerator.dart";

/// Manages the main loop and handles other core functions.
///
/// Initializes all the key systems and starts the main loop which
/// calculates the delta time between frames before calling the
/// update and render functions.
class Engine
{
    bool running = false;
    DisplayDevice device;

    Camera camera;
    World world;
    Motor motor;
    MapGenerator mapGenerator;

    DateTime lastUpdate = new DateTime.now();

    /// Initializes all the systems and starts the main loop via window.requestAnimationFrame().
    void start()
    {
        /// The device that interfaces with the HTML canvas.
        device = new DisplayDevice(querySelector("#raycaster"));

        /// Handles the actual raycasting as well as position and orientation.
        camera = new Camera(new Vector2(MapDef.width / 2, 4.5), new Vector2(0.0, 1.0), 1.33, 1000);

        /// Sets up a table of colors keyed by ints that get used in the map.
        Map<int, Color> colors = new Map<int, Color>();

        colors.putIfAbsent(1, () => new Color(0x12, 0xDA, 0x00, 255));
        colors.putIfAbsent(2, () => new Color(0xC3, 0xC0, 0x00, 255));
        colors.putIfAbsent(3, () => new Color(0xB3, 0x5C, 0x00, 255));
        colors.putIfAbsent(4, () => new Color(0x00, 0xC3, 0xD1, 255));
        colors.putIfAbsent(5, () => new Color(0xA5, 0x00, 0x00, 255));

        /// Holds all the relevant map data, including the color table.
        world = new World(MapDef.width, MapDef.height, MapDef.get(), new Color(30, 30, 30, 255), new Color(50, 50, 50, 255), colors);

        /// Uses a simple state machine to move the camera back and forth.
        motor = new Motor(camera, 5.0, 5.0, 92.0, PI);
        motor.state = Motor.MOVING;

        /// Randomly generates a defined area of the map when the camera is in specific positions.
        mapGenerator = new MapGenerator(world, camera, 16, 85, 1, MapDef.width - 2, MapDef.width ~/ 2);

        running = true;
        window.requestAnimationFrame(tick);
    }

    /// The callback function given to window.requestAnimationFrame() to act as the main loop.
    ///
    /// Calculates the delta time between frames before calling the update and render functions.
    /// Gives its self as the animation frame callback to maintain the loop.
    void tick([_])
    {
        DateTime now = new DateTime.now();
        Duration deltaTime = now.difference(lastUpdate);

        update(deltaTime.inMilliseconds / 1000.0);
        render();

        lastUpdate = now;

        if (running)
            window.requestAnimationFrame(tick);
    }

    void update(double deltaTime)
    {
        motor.update(deltaTime);
        mapGenerator.update();
    }

    void render()
    {
        camera.draw(device, world);
        device.render();
    }
}