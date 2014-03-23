package Math2D
{
    import loom2d.math.Point;

    public struct LineSegment
    {
        public var x1:Number = 0.0;
        public var y1:Number = 0.0;
        public var x2:Number = 0.0;
        public var y2:Number = 0.0;
        public var dx:Number = 0.0;
        public var dy:Number = 0.0;

        public function LineSegment(newX1:Number=0, newY1:Number=0, newX2:Number=0, newY2:Number=0)
        {
            x1 = newX1;
            y1 = newY1;
            x2 = newX2;
            y2 = newY2;
            updateDirection();
        }

        public function updateDirection()
        {
            dx = x2 - x1;
            dy = y2 - y1;
        }

        public static operator function =(l1:LineSegment, l2:LineSegment):LineSegment
        {
            l1.x1 = l2.x1;
            l1.y1 = l2.y1;
            l1.x2 = l2.x2;
            l1.y2 = l2.y2;
            l1.dx = l2.dx;
            l1.dy = l2.dy;
            return l1;
        }

        public function setP1(x:Number, y:Number)
        {
            x1 = x;
            y1 = y;
            updateDirection();
        }

        public function setP2(x:Number, y:Number)
        {
            x2 = x;
            y2 = y;
            updateDirection();
        }

        public function toString():String
        {
            return "Segment [" + x1 + ", " + y1 + "] to [" + x2 + ", " + y2 + "]";
        }
    }

    public class Polygon
    {
        public var segments:Vector.<LineSegment> = new Vector.<LineSegment>();
        public var endpoints:Vector.<Point> = null;

        public function Polygon(points:Vector.<Point>)
        {
            endpoints = points;

            var nextIndex:int = 0;
            for (var i:int = 0; i < points.length; ++i)
            {
                nextIndex = (i + 1) % points.length;
                var newSegment = new LineSegment(points[i].x, points[i].y,
                                                 points[nextIndex].x, points[nextIndex].y);
                segments.pushSingle(newSegment);
            }
        }
    }

    public struct RaycastResult
    {
        public var hit:Boolean = false;
        public var hitIndex:int = 0;
        public var intersection:Point = Point.ZERO;

        public static operator function =(r1:RaycastResult, r2:RaycastResult):RaycastResult
        {
            r1.hit = r2.hit;
            r1.hitIndex = r2.hitIndex;
            r1.intersection = r2.intersection;
            return r1;
        }
    }

    public class Math2D
    {
        private static var tempRaycastResult:RaycastResult;
        private static var tempPoint:Point;

        public static function dotProduct(p1:Point, p2:Point):Number
        {
            return (p1.x * p2.x) + (p1.y * p2.y);
        }

        // Return: A value of t to plug into the formula:
        // intersectionX = rayOrigin.x + (rayDirection.x * t)
        // intersectionY = rayOrigin.y + (rayDirection.y * t)
        //
        // Returns -1 if there is no intersection
        public static function intersectRayWithSegment(ray:LineSegment, seg:LineSegment):Number
        {
            // t2: The t value of the intersection for the segment
            // (this will be between 0 and 1 if there's a hit)
            var t2 = (ray.dx * (seg.y1 - ray.y1) + ray.dy * (ray.x1 - seg.x1)) /
                 (seg.dx * ray.dy - seg.dy * ray.dx);
            // t1: The t value of the intersection for the ray
            // (this value will be greater than zero if there's a hit)
            var t1 = (seg.x1 + (seg.dx * t2) - ray.x1) / ray.dx;

            if (t1 >= 0 && t2 >= 0 && t2 <= 1)
            {
                return t1;
            }

            return -1;
        }

        // Determine the closest intersection between the given ray and the segments
        // that were passed in.
        //
        // The return struct will include
        // hit: whether or not the ray hit something
        // hitIndex: the index into the vector for the segment that was hit
        // intersection: the point where the ray hit the segment
        public static function raycastToSegments(ray:LineSegment,
                                                 segments:Vector.<LineSegment>):RaycastResult
        {
            var tempT:Number = -1;
            var bestT:Number = Number.MAX_VALUE;
            var currentSeg:int = 0;
            tempRaycastResult.hit = false;

            for each (var segment:LineSegment in segments)
            {
                tempT = Math2D.intersectRayWithSegment(ray, segment);
                if (tempT != -1 && tempT < bestT)
                {
                    tempRaycastResult.hit = true;
                    tempRaycastResult.hitIndex = currentSeg;
                    bestT = tempT;
                }
                ++currentSeg;
            }

            if (tempRaycastResult.hit)
            {
                tempRaycastResult.intersection.x = ray.x1 + ray.dx * bestT;
                tempRaycastResult.intersection.y = ray.y1 + ray.dy * bestT;
            }

            return tempRaycastResult;
        }
    }
}