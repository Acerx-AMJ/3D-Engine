require("math3d")

-- Geometry creation functions

local function setupShapesOrigin(vertices)
   local origin = {
      ox = 0,
      oy = 0,
      oz = 0,
   }

   for i = 1, #vertices do
      local v = vertices[i]
      origin.ox = origin.ox + v[1]
      origin.oy = origin.oy + v[2]
      origin.oz = origin.oz + v[3]
   end

   return {
      ox = origin.ox / #vertices,
      oy = origin.oy / #vertices,
      oz = origin.oz / #vertices,
   }
end

local function setupShapesVerticesBasedOnRotation(vertices, points, ox, oy, oz, rx, ry, rz)
   for i = 1, #vertices do
      local v = vertices[i]
      if rx == 0 and ry == 0 and rz == 0 then
         points[i] = v
      else
         points[i] = Rotate3D(v[1] - ox, v[2] - oy, v[3] - oz, rx, ry, rz)
         points[i] = {points[i][1] + ox, points[i][2] + oy, points[i][3] + oz}
      end
   end
end

-- Geometry edit functions

function MoveGeometry(geometry, nx, ny, nz)
   for i = 1, #geometry.vertices do
      geometry.vertices[i][1] = geometry.vertices[i][1] - geometry.x + nx
      geometry.vertices[i][2] = geometry.vertices[i][2] - geometry.y + ny
      geometry.vertices[i][3] = geometry.vertices[i][3] - geometry.z + nz
   end

   geometry.x = nx
   geometry.y = ny
   geometry.z = nz

   local origin = setupShapesOrigin(geometry.vertices)
   geometry.ox = origin.ox
   geometry.oy = origin.oy
   geometry.oz = origin.oz

   setupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.ox, geometry.oy, geometry.oz, geometry.rx, geometry.ry, geometry.rz)
end

function ScaleGeometry(geometry, nw, nh, nd)
   local sx, sy, sz = nw / geometry.w, nh / geometry.h, nd / geometry.d

   for i = 1, #geometry.vertices do
      geometry.vertices[i][1] = geometry.x + (geometry.vertices[i][1] - geometry.x) * sx
      geometry.vertices[i][2] = geometry.y + (geometry.vertices[i][2] - geometry.y) * sy
      geometry.vertices[i][3] = geometry.z + (geometry.vertices[i][3] - geometry.z) * sz
   end

   geometry.w = nw
   geometry.h = nh
   geometry.d = nd

   local origin = setupShapesOrigin(geometry.vertices)
   geometry.ox = origin.ox
   geometry.oy = origin.oy
   geometry.oz = origin.oz

   setupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.ox, geometry.oy, geometry.oz, geometry.rx, geometry.ry, geometry.rz)
end

function RotateGeometry(geometry, nrx, nry, nrz)
   setupShapesVerticesBasedOnRotation(geometry.vertices, geometry.points, geometry.ox, geometry.oy, geometry.oz, nrx, nry, nrz)
end

-- New geometry

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

   local origin = setupShapesOrigin(vertices)
   local points = {}
   setupShapesVerticesBasedOnRotation(vertices, points, origin.ox, origin.oy, origin.oz, rx, ry, rz)

   return {
      x = x,
      y = y,
      z = z,
      w = w,
      h = h,
      d = d,
      ox = origin.ox,
      oy = origin.oy,
      oz = origin.oz,
      rx = rx,
      ry = ry,
      rz = rz,
      triangles = cubeTriangles,
      vertices = vertices,
      points = points,
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
   local vertices = {
      {x, y + h, z + d},
      {x + w, y + h, z + d},
      {x + w, y, z + d},
      {x, y, z + d},
      {x + w, y, z},
      {x, y, z},
   }

   local origin = setupShapesOrigin(vertices)
   local points = {}
   setupShapesVerticesBasedOnRotation(vertices, points, origin.ox, origin.oy, origin.oz, rx, ry, rz)

   return {
      x = x,
      y = y,
      z = z,
      w = w,
      h = h,
      d = d,
      ox = origin.ox,
      oy = origin.oy,
      oz = origin.oz,
      rx = rx,
      ry = ry,
      rz = rz,
      triangles = wedgeTriangles,
      vertices = vertices,
      points = points,
      colors = colors,
   }
end
