package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Image;
    import loom2d.textures.Texture;
    import loom2d.ui.SimpleLabel;
    import loom2d.events.Touch;
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.display.DisplayObject;
    import loom2d.display.QuadBatch;
    import loom2d.display.Quad;
    import loom2d.display.Sprite;
    import loom2d.math.Point;
    import math2d.Math2D;
    import math2d.Polygon;
    import math2d.LineSegment;
    import math2d.RaycastResult;
    import DebugDraw.LineSprite;
    import DebugDraw.TriangleSprite;
    import DebugDraw.DebugDraw;

    // Simple application inspired by http://ncase.github.io/sight-and-light/
    // to experiment with some 2D math and also to use as a testing ground for
    // some simple debug drawing classes for getting some shapes onscreen easily.
    public class VisibilityTest extends Application
    {
        var worldPolygons:Vector.<Polygon> = null;
        var worldSegments:Vector.<LineSegment> = null;
        var worldEndpoints:Vector.<Point> = null;
        var intersectionSegments:Vector.<LineSegment> = null;

        var lineSprite:LineSprite = null;
        var lineSprites:Vector.<LineSprite> = null;
        var polySprites:Vector.<QuadBatch> = null;
        var visibilitySprites:Vector.<TriangleSprite> = null;
        var lineLayer:Sprite = null;
        var visibilityLayer:Sprite = null;
        var polyLayer:Sprite = null;

        var raycastResult:RaycastResult = new RaycastResult();
        var ray:LineSegment = new LineSegment();
        var angles:Vector.<Number> = [0, 0.0003, -0.0006];

        override public function run():void
        {
            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;
            stage.color = 0xffffff;

            lineSprite = new LineSprite(0, 0, 0, 0, 0xff0000);
            stage.addChild(lineSprite);

            createWorldPolys();

            stage.addEventListener(TouchEvent.TOUCH, onTouch);
            // stage.reportFps = true;
        }

        protected function onTouch(e:TouchEvent)
        {
            var touch:Touch;

            // Start
            if (e.getTouch(e.target as DisplayObject, TouchPhase.BEGAN) != null)
            {
                touch = e.getTouch(e.target as DisplayObject, TouchPhase.BEGAN);
                castRaysTowardEndpoints(touch.globalX, touch.globalY);
            }
            // Move
            else if (e.getTouch(e.target as DisplayObject, TouchPhase.MOVED) != null)
            {
                touch = e.getTouch(e.target as DisplayObject, TouchPhase.MOVED);
                castRaysTowardEndpoints(touch.globalX, touch.globalY);
            }
            // Release
            else if (e.getTouch(e.target as DisplayObject, TouchPhase.ENDED) != null)
            {
                //lineSprite.setPoints(0, 0, 0, 0);
                for each (var line in lineSprites)
                {
                    line.setPoints(0, 0, 0, 0);
                }

                for each (var triangle in visibilitySprites)
                {
                    triangle.setPoints(0, 0, 0, 0, 0, 0);
                }
            }
        }

        protected function castRayToPosition(x:int, y:int)
        {
            ray.setP1(stage.stageWidth/2, stage.stageHeight/2);
            ray.setP2(x, y);
            Math2D.raycastToSegments(ray, raycastResult, worldSegments);
            if (raycastResult.hit)
            {
                lineSprite.setPoints(ray.x1, ray.y1, raycastResult.hitX, raycastResult.hitY);
            }
            else
            {
                lineSprite.setPoints(0, 0, 0, 0);
            }
        }

        protected function castRaysTowardEndpoints(x:int, y:int)
        {
            var i = 0;
            ray.setP1(x, y);

            for each (var endpoint in worldEndpoints)
            {
                ray.setP2(endpoint.x, endpoint.y);

                // For each endpoint, we cast a ray at it, and also one 0.00001
                // radians rotated either way in case the endpoint is at the edge
                // of a polygon, and we want to cast past it to hit whats beyond it.
                // To rotate -0.00001, we'll use -0.00002 to undo the previous rotation.
                for each (var angle:Number in angles)
                {
                    ray.rotateBy(angle);
                    Math2D.raycastToSegments(ray, raycastResult, worldSegments);
                    if (raycastResult.hit)
                    {
                        intersectionSegments[i].setP1(x, y);
                        intersectionSegments[i].setP2(raycastResult.hitX, raycastResult.hitY);
                    }
                    else
                    {
                        intersectionSegments[i].setP1(0, 0);
                        intersectionSegments[i].setP2(0, 0);
                    }
                    ++i;
                }
            }

            sortIntersectionSegments();
            renderRaysToIntersections();
            renderVisibilityPolygons();
        }

        protected function renderRaysToIntersections()
        {
            var i = 0;
            for each (var hitSeg in intersectionSegments)
            {
                lineSprites[i].setPoints(hitSeg.x1, hitSeg.y1, hitSeg.x2, hitSeg.y2);
                ++i;
            }
        }

        protected function sortIntersectionSegments()
        {
            intersectionSegments.sort(function(a:LineSegment, b:LineSegment):Number
            {
                if (a.angle < b.angle)
                {
                    return -1;
                }
                else if (a.angle > b.angle)
                {
                    return 1;
                }
                return 0;
            });
        }

        protected function renderVisibilityPolygons()
        {
            var next:int = 0;
            for (var i = 0; i < intersectionSegments.length; ++i)
            {
                next = (i + 1) % intersectionSegments.length;
                visibilitySprites[i].setPoints(intersectionSegments[i].x1, intersectionSegments[i].y1,
                                               intersectionSegments[i].x2, intersectionSegments[i].y2,
                                               intersectionSegments[next].x2, intersectionSegments[next].y2);
            }
        }

        protected function createWorldPolys()
        {
            // Initialize storage
            worldPolygons = new Vector.<Polygon>();
            worldSegments = new Vector.<LineSegment>();
            worldEndpoints = new Vector.<Point>();
            polySprites = new Vector.<QuadBatch>();
            lineSprites = new Vector.<LineSprite>();
            visibilitySprites = new Vector.<TriangleSprite>();
            intersectionSegments = new Vector.<LineSegment>();

            visibilityLayer = new Sprite();
            stage.addChild(visibilityLayer);
            lineLayer = new Sprite();
            stage.addChild(lineLayer);
            polyLayer = new Sprite();
            stage.addChild(polyLayer);

            // Create the actual polygons
            var tempPolygon:Polygon;
            tempPolygon = new Polygon([new Point(0, 0),
                                  new Point(stage.stageWidth, 0),
                                  new Point(stage.stageWidth, stage.stageHeight), 
                                  new Point(0, stage.stageHeight)]);
            worldPolygons.pushSingle(tempPolygon);

            tempPolygon = new Polygon([new Point(50, 200),
                                 new Point(75, 250),
                                 new Point(150, 225)]);
            worldPolygons.pushSingle(tempPolygon);

            tempPolygon = new Polygon([new Point(200, 50),
                                 new Point(225, 25),
                                 new Point(215, 60)]);
            worldPolygons.pushSingle(tempPolygon);

            tempPolygon = new Polygon([new Point(50, 50),
                                 new Point(60, 150),
                                 new Point(90, 170),
                                 new Point(150, 80)]);
            worldPolygons.pushSingle(tempPolygon);

            tempPolygon = new Polygon([new Point(350, 50),
                                 new Point(300, 100),
                                 new Point(350, 160),
                                 new Point(400, 80)]);
            worldPolygons.pushSingle(tempPolygon);

            tempPolygon = new Polygon([new Point(320, 300),
                                 new Point(200, 200),
                                 new Point(300, 250),
                                 new Point(325, 180)]);
            worldPolygons.pushSingle(tempPolygon);

            // Generate endpoint, segment, and sprite lists
            var tempSprite:QuadBatch = null;
            var tempLine:LineSprite = null;
            var tempTriangle:TriangleSprite = null;
            for each (var poly in worldPolygons)
            {
                // Add segments from poly to global list
                for each (var seg:LineSegment in poly.segments)
                {
                    worldSegments.pushSingle(seg);
                }

                // Add endpoints of polys to global list
                // Also create a raycast line for each endpoint
                for each (var endpoint:Point in poly.endpoints)
                {
                    worldEndpoints.pushSingle(endpoint);
                    for (var i = 0; i < 3; ++i)
                    {
                        // Create some temporary intersection points
                        intersectionSegments.pushSingle(new LineSegment());

                        tempLine = new LineSprite(0, 0, 0, 0, 0xff0000);
                        lineLayer.addChild(tempLine);
                        lineSprites.pushSingle(tempLine);

                        tempTriangle = new TriangleSprite(0, 0, 0, 0, 0, 0, 0x550000);
                        visibilityLayer.addChild(tempTriangle);
                        visibilitySprites.pushSingle(tempTriangle);
                    }
                }

                // Create a polygon sprite for each poly
                tempSprite = DebugDraw.newPolygonOutline(poly.endpoints, 0x000000);
                polySprites.pushSingle(tempSprite);
                polyLayer.addChild(tempSprite);
            }
        }
    }
}