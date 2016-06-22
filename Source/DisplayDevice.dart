import 'dart:html';

/// Handles drawing an image buffer to a canvas.
class DisplayDevice
{
    CanvasElement _canvas;
    CanvasRenderingContext2D _context;
    ImageData _imageData;

    DisplayDevice(this._canvas)
    {
        _context = _canvas.getContext("2d");
        _imageData = _context.createImageData(_canvas.width, _canvas.height);
    }

    void render()
    {
        _context.putImageData(_imageData, 0, 0);
    }

    int getWidth()
    {
        return _canvas.width;
    }

    int getHeight()
    {
        return _canvas.height;
    }

    void clearBuffer(int r, int g, int b)
    {
        var data = _imageData.data;

        for (int i = 0; i < data.length; i += 4)
        {
            data[i] = r;
            data[i + 1] = g;
            data[i + 2] = b;
            data[i + 3] = 255;
        }
    }

    List<int> getBuffer() { return _imageData.data; }
    CanvasRenderingContext2D getContext() { return _context; }
}