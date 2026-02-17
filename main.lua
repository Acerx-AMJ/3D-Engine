require("colors")
require("geometry")

local rotation = {0, 0, 0}
local offset = {0, 0, 0}
local lastmousepos = {0, 0}
local geometry = {}
local timer = 0

function love.load()
   love.window.setTitle("3D Engine")
   love.window.setMode(800, 800)

   table.insert(geometry, NewCube(0.0, 0.0, 2.0, 1.0, 1.0, 1.0, math.pi / 4, 0.0, 0.0,{Red, Red, Green, Green, Blue, Blue, Cyan, Cyan, Magenta, Magenta, Yellow, Yellow}))
   table.insert(geometry, NewCube(2.0, 0.0, 2.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Cyan, Cyan, Magenta, Magenta, Yellow, Yellow}))
   table.insert(geometry, NewWedge(-2.0, 0.0, 2.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Yellow, Yellow}))
end

function love.draw()
   love.graphics.clear(0, 0, 0, 1, true)

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
      local rotatedoffset = Rotate3D(toffset[1], toffset[2], toffset[3], 0, -rotation[2], -rotation[3])
      offset[1] = offset[1] + rotatedoffset[1]
      offset[2] = offset[2] + rotatedoffset[2]
      offset[3] = offset[3] + rotatedoffset[3]
   end

   -- Update geometry
   timer = timer + love.timer.getDelta()
   MoveGeometry(geometry[1], geometry[1].x, math.sin(timer), geometry[1].z)

   ScaleGeometry(geometry[2], 1.5 + math.sin(timer) * 0.5, 1.5 + math.sin(timer) * 0.5, 1.5 + math.sin(timer) * 0.5)
   RotateGeometry(geometry[2], 0, timer * 2, 0)

   ScaleGeometry(geometry[3], 1 + math.cos(timer) * 0.5, 1 + math.cos(timer) * 0.5, 1 + math.cos(timer) * 0.5)
   RotateGeometry(geometry[3], timer, 0, 0)

   -- Sort triangles
   local triangles = {}
   for j = 1, #geometry do
      local shape = geometry[j]
      local points = {}
      local z = 0

      for i = 1, #shape.points do
         local p = shape.points[i]
         points[i] = Rotate3D(p[1] + offset[1], p[2] + offset[2], p[3] + offset[3], rotation[1], rotation[2], rotation[3])
         z = z + points[i][3]
      end

      for i = 1, #shape.triangles do
         local t = shape.triangles[i]
         local p1, p2, p3 = points[t[1]], points[t[2]], points[t[3]]
         local depth = math.min(p1[3] + p2[3] + p3[3])
         local color = shape.colors[i]

         table.insert(triangles, {p1, p2, p3, color[1], color[2], color[3], depth, z / #points})
      end
   end

   table.sort(triangles, function(a, b)
      if (a[8] ~= b[8]) then
         return a[8] > b[8]
      end
      return a[7] > b[7]
   end)

   -- Draw triangles
   for j = 1, #triangles do
      local t = triangles[j]

      if t[1][3] > 0 and t[2][3] > 0 and t[3][3] > 0 then
         local s1 = TranslateToScreen(t[1][1], t[1][2], t[1][3])
         local s2 = TranslateToScreen(t[2][1], t[2][2], t[2][3])
         local s3 = TranslateToScreen(t[3][1], t[3][2], t[3][3])

         if TriangleNormalZ(s1[1], s1[2], s2[1], s2[2], s3[1], s3[2]) <= 0 then
            love.graphics.setColor(t[4], t[5], t[6], 1)
            love.graphics.polygon("fill", s1[1], s1[2], s2[1], s2[2], s3[1], s3[2])
         end
      end
      love.graphics.setColor(255, 255, 255, 1)
   end
end
