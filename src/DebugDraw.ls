package DebugDraw
{
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Quad;
    import loom2d.display.QuadBatch;
    import loom2d.display.Sprite;
    import loom2d.math.Point;
    import loom.gameframework.IAnimated;
    import Math2D.LineSegment;

    public class LineSprite extends Quad
    {
        public function LineSprite(x1:int, y1:int, x2:int, y2:int, color:int=0xffffff)
        {
            super(1, 1, color);
            setPoints(x1, y1, x2, y2);
        }

        public function setPoints(x1:int, y1:int, x2:int, y2:int)
        {
            // Horizontal case
            if (y1 == y2)
            {
                setVertexPosition(0, x1, y1-1);
                setVertexPosition(1, x2, y1-1);
                setVertexPosition(2, x1, y2+1);
                setVertexPosition(3, x2, y2+1);
            }
            // Vertical
            else if (x1 == x2)
            {
                setVertexPosition(0, x1-1, y1);
                setVertexPosition(1, x2+1, y1);
                setVertexPosition(2, x1-1, y2);
                setVertexPosition(3, x2+1, y2);
            }
            // Up and to the right
            else if (x1 < x2 && y1 < y2 || x1 > x2 && y1 > y2)
            {
                setVertexPosition(0, x1+1, y1);
                setVertexPosition(1, x1, y1+1);
                setVertexPosition(2, x2+1, y2);
                setVertexPosition(3, x2, y2+1);
            }
            // Down and to the right
            else
            {
                setVertexPosition(0, x1, y1);
                setVertexPosition(1, x1+1, y1+1);
                setVertexPosition(2, x2, y2);
                setVertexPosition(3, x2+1, y2+1);
            }
        }
    }

    public class PolygonSprite extends Sprite
    {
        public function PolygonSprite(segments:Vector.<LineSegment>, color:int=0xffffff):void
        {
            for (var i = 0; i < segments.length; ++i)
            {
                var segment = segments[i];
                var newLine = new LineSprite(segment.x1, segment.y1, segment.x2, segment.y2, color);
                addChild(newLine);
            }
        }
    }
}