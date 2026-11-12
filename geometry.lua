local ffi = require("ffi")
require("math3d")

-- Geometry creation functions

function SetupShapesOrigin(pos, size)
   return Vec3Add(pos, Vec3Mul(size, 0.5))

   -- local origin = Vec3(0.0, 0.0, 0.0)
   -- for i = 1, #vertices do
   --    local pos = vertices[i]
   --    origin = Vec3Add(origin, pos)
   -- end
   -- return Vec3Div(origin, #vertices)
end

function SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)
   for i = 1, #vertices do
      local pos = vertices[i]
      points[i] = Rotate3DAroundOrigin(pos, origin, rotation)
   end
end

function MakeGeometry(pos, size, rotation, triangles, vertices, uv, textures)
   local origin = SetupShapesOrigin(pos, size)
   local points = {}
   SetupShapesVerticesBasedOnRotation(vertices, points, origin, rotation)

   return {
      pos = pos,
      size = size,
      origin = origin,
      rotation = rotation,
      triangles = triangles,
      vertices = vertices,
      points = points,
      uv = uv,
      textures = textures,
   }
end

function MakeTriangle(p1, p2, p3, uv1, uv2, uv3, normal, texture)
   return {
      p1 = p1,
      p2 = p2,
      p3 = p3,
      uv1 = uv1,
      uv2 = uv2,
      uv3 = uv3,
      normal = normal,
      texture = texture,
   }
end

-- Geometry edit functions

function MoveGeometry(geometry, offset)
   for i = 1, #geometry.vertices do
      geometry.vertices[i] = Vec3Add(Vec3Sub(geometry.vertices[i], geometry.pos), offset)
   end
   geometry.pos = offset;
   geometry.origin = SetupShapesOrigin(geometry.pos, geometry.size)
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, geometry.rotation)
end

function ScaleGeometry(geometry, scale)
   local factor = Vec3Div3(scale, Vec3ZeroFix(geometry.size))
   for i = 1, #geometry.vertices do
      geometry.vertices[i] = Vec3Add(Vec3Mul3(Vec3Sub(geometry.vertices[i], geometry.pos), factor), geometry.pos)
   end

   geometry.size = scale;
   geometry.origin = SetupShapesOrigin(geometry.pos, geometry.size)
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, geometry.rotation)
end

function RotateGeometry(geometry, rotation)
   geometry.rotation = rotation
   SetupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.origin, rotation)
end

-- New geometry

function NewTexture(src)
   local texture = love.image.newImageData(src)
   local width = texture:getWidth()
   local height = texture:getHeight()
   local ffiptr = ffi.cast("uint8_t*", texture:getFFIPointer())
   return {texture = texture, ffi = ffiptr, width = width, height = height}
end

function Tr6(x, y, z, uv1, uv2, uv3, texture)
   return {x = x, y = y, z = z, uv1 = uv1, uv2 = uv2, uv3 = uv3, texture = texture}
end

-- triangles - x, y, z, uv1, uv2, uv3, texture index
-- uvs - u, v
-- vertices - x, y, z

function NewFace(pos, size, rotation, textures)
   local triangles = {
      Tr6(1, 2, 4, 1, 2, 4, 1),
      Tr6(2, 3, 4, 2, 3, 4, 1),
   }

   local uv = {
      Vec2(0, 0),
      Vec2(1, 0),
      Vec2(1, 1),
      Vec2(0, 1),
   }

   local vertices = {
      Vec3(pos.x, pos.y, pos.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z),
      Vec3(pos.x, pos.y + size.y, pos.z),
   }
   return MakeGeometry(pos, size, rotation, triangles, vertices, uv, textures)
end

function NewCube(pos, size, rotation, textures)
   local triangles = {
      Tr6(8, 7, 6, 1, 2, 3, 1),
      Tr6(6, 5, 8, 3, 4, 1, 1),
      Tr6(4, 8, 5, 1, 2, 3, 2),
      Tr6(5, 1, 4, 3, 4, 1, 2),
      Tr6(3, 4, 1, 1, 2, 3, 3),
      Tr6(1, 2, 3, 3, 4, 1, 3),
      Tr6(7, 3, 2, 1, 2, 3, 4),
      Tr6(2, 6, 7, 3, 4, 1, 4),
      Tr6(5, 6, 2, 1, 2, 3, 5),
      Tr6(2, 1, 5, 3, 4, 1, 5),
      Tr6(4, 3, 7, 1, 2, 3, 6),
      Tr6(7, 8, 4, 3, 4, 1, 6),
   }

   local uv = {
      Vec2(0, 0),
      Vec2(1, 0),
      Vec2(1, 1),
      Vec2(0, 1),
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
   return MakeGeometry(pos, size, rotation, triangles, vertices, uv, textures)
end

function NewWedge(pos, size, rotation, textures)
   local triangles = {
      Tr6(1, 2, 3, 3, 4, 1, 1),
      Tr6(3, 4, 1, 1, 2, 3, 1),
      Tr6(4, 3, 5, 1, 2, 3, 2),
      Tr6(5, 6, 4, 3, 4, 1, 2),
      Tr6(1, 4, 6, 4, 1, 2, 3),
      Tr6(5, 3, 2, 1, 2, 3, 4),
      Tr6(5, 2, 1, 2, 3, 4, 5),
      Tr6(1, 6, 5, 4, 1, 2, 5),
   }

   local uv = {
      Vec2(0, 0),
      Vec2(1, 0),
      Vec2(1, 1),
      Vec2(0, 1),
   }

   local vertices = {
      Vec3(pos.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y + size.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z + size.z),
      Vec3(pos.x, pos.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
      Vec3(pos.x, pos.y, pos.z),
   }
   return MakeGeometry(pos, size, rotation, triangles, vertices, uv, textures)
end

function NewPyramid(pos, size, rotation, textures)
   local triangles = {
      Tr6(1, 3, 2, 5, 1, 4, 1),
      Tr6(1, 4, 3, 5, 1, 4, 2),
      Tr6(1, 5, 4, 5, 1, 4, 3),
      Tr6(1, 2, 5, 5, 1, 4, 4),
      Tr6(2, 3, 4, 1, 2, 3, 5),
      Tr6(4, 5, 2, 3, 4, 1, 5),
   }

   local uv = {
      Vec2(0, 0),
      Vec2(1, 0),
      Vec2(1, 1),
      Vec2(0, 1),
      Vec2(1, 0.5)
   }

   local vertices = {
      Vec3(pos.x + size.x / 2.0, pos.y + size.y, pos.z + size.z / 2.0),
      Vec3(pos.x, pos.y, pos.z),
      Vec3(pos.x, pos.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z + size.z),
      Vec3(pos.x + size.x, pos.y, pos.z),
   }
   return MakeGeometry(pos, size, rotation, triangles, vertices, uv, textures)
end
