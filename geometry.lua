require("math3d")

local function setupShapesOriginAndRotation(vertices, ox, oy, oz, rx, ry, rz)
   for i = 1, #vertices do
      local v = vertices[i]
      ox = ox + v[1]
      oy = oy + v[2]
      oz = oz + v[3]
   end
   ox = ox / #vertices
   oy = oy / #vertices
   oz = oz / #vertices

   if rx ~= 0 or ry ~= 0 or rz ~= 0 then
      for i = 1, #vertices do
         local v = vertices[i]
         v = Rotate3D(v[1] - ox, v[2] - oy, v[3] - oz, rx, ry, rz)
         vertices[i] = {v[1] + ox, v[2] + oy, v[3] + oz}
      end
   end
end

local cubeTriangles = {
   {8, 7, 6},
   {6, 5, 8},
   {4, 8, 5},
   {5, 1, 4},
   {3, 4, 1},
   {1, 2, 3},
   {7, 3, 2},
   {2, 6, 7},
   {5, 6, 2},
   {2, 1, 5},
   {4, 3, 7},
   {7, 8, 4},
}

function NewCube(x, y, z, w, h, d, rx, ry, rz, colors)
   -- make sure the cube is centered
   x = x - w / 2
   y = y - h / 2
   z = z - d / 2

   local vertices = {
      {x, y + h, z + d},
      {x + w, y + h, z + d},
      {x + w, y, z + d},
      {x, y, z + d},

      {x, y + h, z},
      {x + w, y + h, z},
      {x + w, y, z},
      {x, y, z},
   }

   local ox, oy, oz = 0, 0, 0
   setupShapesOriginAndRotation(vertices, ox, oy, oz, rx, ry, rz)

   return {
      x = x,
      y = y,
      z = z,
      w = w,
      h = h,
      d = d,
      ox = ox,
      oy = oy,
      oz = oz,
      rx = rx,
      ry = ry,
      rz = rz,
      triangles = cubeTriangles,
      points = vertices,
      colors = colors,
   }
end

local wedgeTriangles = {
   {1, 2, 3},
   {3, 4, 1},
   {4, 3, 5},
   {5, 6, 4},
   {1, 4, 6},
   {5, 3, 2},
   {5, 2, 1},
   {1, 6, 5}
}

function NewWedge(x, y, z, w, h, d, rx, ry, rz, colors)
   -- make sure the wedge is centered
   x = x - w / 2
   y = y - h / 2
   z = z - d / 2

   local vertices = {
      {x, y + h, z + d},
      {x + w, y + h, z + d},
      {x + w, y, z + d},
      {x, y, z + d},
      {x + w, y, z},
      {x, y, z},
   }

   local ox, oy, oz = 0, 0, 0
   setupShapesOriginAndRotation(vertices, ox, oy, oz, rx, ry, rz)

   return {
      x = x,
      y = y,
      z = z,
      w = w,
      h = h,
      d = d,
      ox = ox,
      oy = oy,
      oz = oz,
      rx = rx,
      ry = ry,
      rz = rz,
      triangles = wedgeTriangles,
      points = vertices,
      colors = colors,
   }
end
