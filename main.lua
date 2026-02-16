local vertices = {
   {-0.5,  0.5,  3.0},
   { 0.5,  0.5,  3.0},
   { 0.5, -0.5,  3.0},
   {-0.5, -0.5,  3.0},
   {-0.5,  0.5,  2.0},
   { 0.5,  0.5,  2.0},
   { 0.5, -0.5,  2.0},
   {-0.5, -0.5,  2.0},
}

local triangles = {
   -- x, y, z, r, g, b
   {7, 6, 5, 255, 0, 0},
   {5, 4, 7, 255, 0, 0},
   {3, 7, 4, 0, 255, 0},
   {4, 0, 3, 0, 255, 0},
   {2, 3, 0, 0, 0, 255},
   {0, 1, 2, 0, 0, 255},
   {6, 2, 1, 255, 255, 0},
   {1, 5, 6, 255, 255, 0},
   {4, 5, 1, 255, 0, 255},
   {1, 0, 4, 255, 0, 255},
   {3, 2, 6, 0, 255, 255},
   {6, 7, 3, 0, 255, 255},
}

local points = {}
local rotation = {0, 0, 0}
local offset = {0, 0, 0}
local lastmousepos = {0, 0}

function triangleNormalZ(p1x, p1y, p2x, p2y, p3x, p3y)
   local ax, ay = p2x - p1x, p2y - p1y
   local bx, by = p3x - p1x, p3y - p1y
   return ax * by - ay * bx
end

function rotate3D(x, y, z, ax, ay, az)
   local result = {x, y, z}

   local sx, cx = math.sin(ax), math.cos(ax)
   local sy, cy = math.sin(ay), math.cos(ay)
   local sz, cz = math.sin(az), math.cos(az)

   local x1 = result[1] * cy - result[3] * sy
   local z2 = result[1] * sy + result[3] * cy
   result[1] = x1
   result[3] = z2

   local y1 = result[2] * cx - result[3] * sx
   local z1 = result[2] * sx + result[3] * cx
   result[2] = y1
   result[3] = z1

   local x2 = result[1] * cz - result[2] * sz
   local y2 = result[1] * sz + result[2] * cz
   result[1] = x2
   result[2] = y2

   return result
end

function translateToScreen(x, y, z)
   if (z <= 0) then
      return {0, 0}
   end

   local coords = {x / z, y / z}
   return {
      ((coords[1] + 1) / 2) * love.graphics.getWidth(),
      (1 - ((coords[2] + 1) / 2)) * love.graphics.getHeight(),
   }   
end

function love.load()
   love.window.setTitle("3D Engine")
   love.window.setMode(800, 800);
end

function love.draw()
   -- Update mouse
   if love.mouse.isDown(1) then
      rotation[1] = rotation[1] - (love.mouse.getY() - lastmousepos[2]) * love.timer.getDelta()
      rotation[1] = math.max(-math.pi / 2, math.min(math.pi / 2, rotation[1]))
      
      rotation[2] = rotation[2] + (love.mouse.getX() - lastmousepos[1]) * love.timer.getDelta()
   end
   lastmousepos = {love.mouse.getX(), love.mouse.getY()}

   -- Update offset
   local toffset = {0, 0, 0}
   if love.keyboard.isDown("a") then
      toffset[1] =  love.timer.getDelta()
   elseif love.keyboard.isDown("d") then
      toffset[1] = -love.timer.getDelta()
   end

   if love.keyboard.isDown("w") then
      toffset[3] = -love.timer.getDelta()
   elseif love.keyboard.isDown(("s")) then
      toffset[3] =  love.timer.getDelta()
   end

   if love.keyboard.isDown("q") then
      toffset[2] = -love.timer.getDelta()
   elseif love.keyboard.isDown(("e")) then
      toffset[2] =  love.timer.getDelta()
   end

   if (toffset[1] ~= 0 or toffset[2] ~= 0 or toffset[3] ~= 0) then
      local rotatedoffset = rotate3D(toffset[1], toffset[2], toffset[3], 0, -rotation[2], -rotation[3])
      offset[1] = offset[1] + rotatedoffset[1]
      offset[2] = offset[2] + rotatedoffset[2]
      offset[3] = offset[3] + rotatedoffset[3]
   end

   -- Draw cube
   for i = 1, #vertices do
      local p = vertices[i]
      points[i] = rotate3D(p[1] + offset[1], p[2] + offset[2], p[3] + offset[3], rotation[1], rotation[2], rotation[3])
   end

   for i = 1, #triangles do
      local t = triangles[i]
      local p1, p2, p3 = points[t[1] + 1], points[t[2] + 1], points[t[3] + 1]

      if p1[3] > 0.1 and p2[3] > 0.1 and p3[3] > 0.1 then
         local s1 = translateToScreen(p1[1], p1[2], p1[3])
         local s2 = translateToScreen(p2[1], p2[2], p2[3])
         local s3 = translateToScreen(p3[1], p3[2], p3[3])

         if triangleNormalZ(s1[1], s1[2], s2[1], s2[2], s3[1], s3[2]) <= 0 then
            love.graphics.setColor(t[4], t[5], t[6], 1)
            love.graphics.polygon("fill", s1[1], s1[2], s2[1], s2[2], s3[1], s3[2])
         end
      end
   end
   love.graphics.setColor(255, 255, 255, 1)
end