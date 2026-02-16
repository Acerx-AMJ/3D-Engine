require("cube")
require("math3d")

local rotation = {0, 0, 0}
local offset = {0, 0, 0}
local lastmousepos = {0, 0}

local canvas
local cubes = {}

function love.load()
   love.window.setTitle("3D Engine")
   love.window.setMode(800, 800)

   canvas = love.graphics.newCanvas(800, 800)
   love.graphics.setDepthMode("less", true)

   table.insert(cubes, NewCube())
   table.insert(cubes, NewCube())
   table.insert(cubes, NewCube())
   table.insert(cubes, NewCube())
end

function love.draw()
   love.graphics.setCanvas(canvas)
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

   -- Draw cubes
   for j = 1, #cubes do
      local cube = cubes[j]

      for i = 1, #CubeVertices do
         local p = CubeVertices[i]
         cube.points[i] = Rotate3D(p[1] + offset[1] + (j - 1) * 2, p[2] + offset[2], p[3] + offset[3], rotation[1], rotation[2], rotation[3])
      end

      for i = 1, #CubeTriangles do
         local t = CubeTriangles[i]
         local p1, p2, p3 = cube.points[t[1] + 1], cube.points[t[2] + 1], cube.points[t[3] + 1]

         if p1[3] > 0 and p2[3] > 0 and p3[3] > 0 then
            local s1 = TranslateToScreen(p1[1], p1[2], p1[3])
            local s2 = TranslateToScreen(p2[1], p2[2], p2[3])
            local s3 = TranslateToScreen(p3[1], p3[2], p3[3])

            if TriangleNormalZ(s1[1], s1[2], s2[1], s2[2], s3[1], s3[2]) <= 0 then
               love.graphics.setColor(t[4], t[5], t[6], 1)
               love.graphics.polygon("fill", s1[1], s1[2], s2[1], s2[2], s3[1], s3[2])
            end
         end
      end
      love.graphics.setColor(255, 255, 255, 1)
   end

   love.graphics.setCanvas()
   love.graphics.draw(canvas)
end
