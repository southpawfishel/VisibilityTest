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
    import loom2d.math.Point;
    import Math2D.Math2D;
    import Math2D.Polygon;
    import Math2D.LineSegment;
    import Math2D.RaycastResult;
    import DebugDraw.LineSprite;
    import DebugDraw.PolygonSprite;

    // Simple application inspired by http://ncase.github.io/sight-and-light/
    // to experiment with some 2D math and also to use as a testing ground for
    // some simple debug drawing classes for getting some shapes onscreen easily.
    public class DebugDrawTest extends Application
    {
        var worldPolygons:Vector.<Polygon> = null;
        var worldSegments:Vector.<LineSegment> = null;
        var worldEndpoints:Vector.<Point> = null;

        var polySprites:Vector.<PolygonSprite> = null;
        var lineSprite:LineSprite = null;
        var lineSprites:Vector.<LineSprite> = null;

        override public function run():void
        {
            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;
            stage.color = 0xffffff;

            lineSprite = new LineSprite(0, 0, 0, 0, 0xff0000);
            stage.addChild(lineSprite);

            createWorldPolys();

            stage.addEventListener(TouchEvent.TOUCH, onTouch);
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
            }
        }

        protected function castRayToPosition(x:int, y:int)
        {
            var ray:LineSegment = new LineSegment(stage.stageWidth/2, stage.stageHeight/2, x, y);
            var result:RaycastResult = Math2D.raycastToSegments(ray, worldSegments);
            if (result.hit)
            {
                lineSprite.setPoints(ray.x1, ray.y1, result.intersection.x, result.intersection.y);
            }
            else
            {
                lineSprite.setPoints(0, 0, 0, 0);
            }
        }

        protected function castRaysTowardEndpoints(x:int, y:int)
        {
            var ray:LineSegment = new LineSegment(x, y, 0, 0);
            var result:RaycastResult = new RaycastResult();
            var i = 0;
            var tempLine:LineSprite = null;
            var angles:Vector.<Number> = [0, 0.00001, -0.00002];

            for each (var endpoint in worldEndpoints)
            {
                ray.setP2(endpoint.x, endpoint.y);

                // For each endpoint, we cast a ray at it, and also one 0.00001
                // radians rotated either way in case the endpoint is at the edge
                // of a polygon, and we want to cast past it to hit whats beyond it.
                // To rotate -0.00001, we'll use -0.00002 to undo the previous rotation.
                for each (var angle:Number in angles)
                {
                    tempLine = lineSprites[i];
                    ray.rotateBy(angle);
                    result = Math2D.raycastToSegments(ray, worldSegments);
                    if (result.hit)
                    {
                        tempLine.setPoints(ray.x1, ray.y1, result.intersection.x, result.intersection.y);
                    }
                    else
                    {
                        tempLine.setPoints(0, 0, 0, 0);
                    }
                    ++i;
                }
            }
        }

        protected function createWorldPolys()
        {
            // Initialize storage
            worldPolygons = new Vector.<Polygon>();
            worldSegments = new Vector.<LineSegment>();
            worldEndpoints = new Vector.<Point>();
            polySprites = new Vector.<PolygonSprite>();
            lineSprites = new Vector.<LineSprite>();

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
            var tempSprite:PolygonSprite = null;
            var tempLine:LineSprite = null;
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
                        tempLine = new LineSprite(0, 0, 0, 0, 0xff0000);
                        stage.addChild(tempLine);
                        lineSprites.pushSingle(tempLine);
                    }
                }

                // Create a polygon sprite for each poly
                tempSprite = new PolygonSprite(poly.segments, 0x000000);
                polySprites.pushSingle(tempSprite);
                stage.addChild(tempSprite);
            }
        }
    }
}