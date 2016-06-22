import "Camera.dart";

/// Uses a basic state machine to move the camera.
///
/// The state of this motor changes after completing its current task.
/// The camera is moved a specified distance until the distance is reached,
/// at which point the state changes and the camera rotates until it turns
/// the specified amount.
class Motor
{
    Camera camera;
    double moveSpeed, turnSpeed;

    double distTraveled;
    double maxTravel;

    double amtRotated;
    double maxRotation;

    int state = 0;

    static const int MOVING = 1;
    static const int TURNING = 2;

    Motor(this.camera, this.moveSpeed, this.turnSpeed, this.maxTravel, this.maxRotation)
    {
        distTraveled = 0.0;
        amtRotated = 0.0;
    }

    void update(double deltaTime)
    {
        switch (state)
        {
            case MOVING:
                double t = moveSpeed * deltaTime;
                distTraveled += t;

                if (distTraveled >= maxTravel)
                {
                    t -= distTraveled - maxTravel;
                    distTraveled = 0.0;
                    state = TURNING;
                }

                camera.move(t);
                break;

            case TURNING:
                double t = turnSpeed * deltaTime;
                amtRotated += t;

                if (amtRotated >= maxRotation)
                {
                    t -= amtRotated - maxRotation;
                    amtRotated = 0.0;
                    state = MOVING;
                }

                camera.rotate(t);
                break;
        }
    }
}