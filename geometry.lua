require("math3d")

-- Geometry creation functions

function SetupShapesOrigin(vertices)
   local origin = Vec3(0.0, 0.0, 0.0)
   for i = 1, #vertices do
      local pos = vertices[i]
      origin = Vec3Add(origin, pos)
   end
   return Vec3Div(origin, #vertices)
end

function SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)
   for i = 1, #vertices do
      local pos = vertices[i]
      points[i] = Rotate3DAroundOrigin(pos, origin, rotation)
   end
end

function MakeGeometry(pos, size, origin, rotation, triangles, vertices, points, colors)
   return {
      pos = pos,
      size = size,
      origin = origin,
      rotation = rotation,
      triangles = triangles,
      vertices = vertices,
      points = points,
      colors = colors,
   }
end

function MakeTriangle(p1, p2, p3, c1, c2, c3, depth, avgz)
   return {
      p1 = p1,
      p2 = p2,
      p3 = p3,
      c1 = c1,
      c2 = c2,
      c3 = c3,
      depth = depth,
      avgz = avgz,
   }
end

-- Geometry edit functions

function MoveGeometry(geometry, offset)
   for i = 1, #geometry.vertices do
      geometry.vertices[i] = Vec3Add(Vec3Sub(geometry.vertices[i], geometry.pos), offset)
   end
   geometry.pos = offset;
   geometry.origin = SetupShapesOrigin(geometry.vertices)
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, geometry.rotation)
end

function ScaleGeometry(geometry, scale)
   local factor = Vec3Div3(scale, Vec3ZeroFix(geometry.size))
   for i = 1, #geometry.vertices do
      geometry.vertices[i] = Vec3Add(Vec3Mul3(Vec3Sub(geometry.vertices[i], geometry.pos), factor), geometry.pos)
   end

   geometry.size = scale;
   geometry.origin = SetupShapesOrigin(geometry.vertices)
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, geometry.rotation)
end

function RotateGeometry(geometry, rotation)
   geometry.rotation = rotation
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, rotation)
end

-- New geometry

function NewFace(pos, size, rotation, colors)
   local faceTriangles = {
      Vec3(1, 2, 4),
      Vec3(2, 3, 4),
   }

   local vertices = {
      Vec3(pos.x, pos.y, pos.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z),
      Vec3(pos.x, pos.y + size.y, pos.z),
   }

   local origin = SetupShapesOrigin(vertices)
   local points = {}
   SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)
   return MakeGeometry(pos, size, origin, rotation, faceTriangles, vertices, points, colors)
end

function NewCube(pos, size, rotation, colors)
   local cubeTriangles = {
      Vec3(8, 7, 6),
      Vec3(6, 5, 8),
      Vec3(4, 8, 5),
      Vec3(5, 1, 4),
      Vec3(3, 4, 1),
      Vec3(1, 2, 3),
      Vec3(7, 3, 2),
      Vec3(2, 6, 7),
      Vec3(5, 6, 2),
      Vec3(2, 1, 5),
      Vec3(4, 3, 7),
      Vec3(7, 8, 4),
   }

   local vertices = {
      Vec3(pos.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z + size.z),
      Vec3(pos.x, pos.y, pos.z + size.z),
      Vec3(pos.x, pos.y + size.y, pos.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
      Vec3(pos.x, pos.y, pos.z),
   }

   local origin = SetupShapesOrigin(vertices)
   local points = {}
   SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)
   return MakeGeometry(pos, size, origin, rotation, cubeTriangles, vertices, points, colors)
end

function NewWedge(pos, size, rotation, colors)
   local wedgeTriangles = {
      Vec3(1, 2, 3),
      Vec3(3, 4, 1),
      Vec3(4, 3, 5),
      Vec3(5, 6, 4),
      Vec3(1, 4, 6),
      Vec3(5, 3, 2),
      Vec3(5, 2, 1),
      Vec3(1, 6, 5),
   }

   local vertices = {
      Vec3(pos.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z + size.z),
      Vec3(pos.x, pos.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
      Vec3(pos.x, pos.y, pos.z),
   }

   local origin = SetupShapesOrigin(vertices)
   local points = {}
   SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)
   return MakeGeometry(pos, size, origin, rotation, wedgeTriangles, vertices, points, colors)
end
