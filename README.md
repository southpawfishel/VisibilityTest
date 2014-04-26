VisibilityTest
==============

Implementation of concepts from http://ncase.me/sight-and-light/ using the Loom game engine

This demo will require you to build the following branch of Loom: https://github.com/southpawfishel/LoomSDK/tree/math2d

The reason for this was that I was unable to get to 60fps using script only. Implementing some math code natively allows this to run at 60fps on an iPhone 4S, although you need to turn off visibility polygons, which drop things down to 40fps. I'm still determining the best way to optimize this to get back to 60fps, although the solution probably lies back in native land...
