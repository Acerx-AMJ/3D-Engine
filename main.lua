WIDTH = 200
HEIGHT = 200
CANVAS = nil
IMAGE = nil

require("colors")
require("geometry")

local rotation = Vec3(0, 0, 0)
local offset = Vec3(0, 0, 0)
local lastmousepos = Vec2(0, 0)
local geometry = {}
local timer = 0

function love.load()
   love.window.setTitle("3D Engine")
   love.window.setMode(800, 800)
   CANVAS = love.image.newImageData(WIDTH, HEIGHT)
   IMAGE = love.graphics.newImage(CANVAS)
   IMAGE:setFilter("nearest", "nearest")

   -- table.insert(geometry, NewCube(0.0, 0.0, 2.0, 1.0, 1.0, 1.0, math.pi / 4, 0.0, 0.0,{Red, Red, Green, Green, Blue, Blue, Cyan, Cyan, Magenta, Magenta, Yellow, Yellow}))
   -- table.insert(geometry, NewCube(2.0, 0.0, 2.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Cyan, Cyan, Magenta, Magenta, Yellow, Yellow}))
   -- table.insert(geometry, NewWedge(-2.0, 0.0, 2.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Yellow, Yellow}))

   -- table.insert(geometry, NewCube(2.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Cyan, Cyan, Magenta, Magenta, Yellow, Yellow}))
   -- table.insert(geometry, NewWedge(3.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, {Red, Red, Green, Green, Blue, Blue, Yellow, Yellow}))
   -- table.insert(geometry, NewFace(0, 0, 1, 1, 1, 0, 0, 0, {Red, Blue, Green, Yellow, Yellow, Yellow}))

   table.insert(geometry, NewFace(Vec3(-1, 0, 3), Vec3(1, 1, 0), Vec3(0, 0, 0), {love.image.newImageData('assets/industrial_wall10.png')}))
   table.insert(geometry, NewFace(Vec3(1, 0, 3), Vec3(1.5, 1, 0), Vec3(0, 0, 0), {Red}))
   -- table.insert(geometry, NewCube(Vec3(1, 0, 1), Vec3(1, 1, 1), Vec3(0, 0, 0), {Red, Green, Blue, Blue, Green, Red, Red, Green, Blue, Blue, Green, Red, Red, Green, Blue, Blue, Green, Red, Red, Green, Blue, Blue, Green, Red, Red, Green, Blue, Blue, Green, Red, Red, Green, Blue, Blue, Green, Red,}))
end

function love.update(dt)
   -- Update mouse
   if love.mouse.isDown(1) then
      rotation.x = rotation.x - (love.mouse.getY() - lastmousepos.y) * 0.01
      rotation.x = math.max(-math.pi / 2, math.min(math.pi / 2, rotation.x))
      rotation.y = rotation.y + (love.mouse.getX() - lastmousepos.x) * 0.01
   end
   lastmousepos = Vec2(love.mouse.getX(), love.mouse.getY())

   -- Update offset
   local toffset = Vec3(0, 0, 0)
   if love.keyboard.isDown("a") then
      toffset.x =  love.timer.getDelta()
   elseif love.keyboard.isDown("d") then
      toffset.x = -love.timer.getDelta()
   end

   if love.keyboard.isDown("w") then
      toffset.z = -love.timer.getDelta()
   elseif love.keyboard.isDown(("s")) then
      toffset.z =  love.timer.getDelta()
   end

   if love.keyboard.isDown("q") then
      toffset.y = -love.timer.getDelta()
   elseif love.keyboard.isDown(("e")) then
      toffset.y =  love.timer.getDelta()
   end

   if (toffset.x ~= 0 or toffset.y ~= 0 or toffset.z ~= 0) then
      local rotatedoffset = Rotate3D(toffset, Vec3(0, -rotation.y, -rotation.z))
      offset = Vec3Add(offset, rotatedoffset)
   end

   -- Update geometry
   timer = timer + love.timer.getDelta()
   -- MoveGeometry(geometry[2], Vec3(geometry[2].pos.x, math.sin(timer) * 0.25, geometry[2].pos.z))
   -- ScaleGeometry(geometry[2], Vec3(1 + math.cos(timer) * 0.5, 1 + math.sin(timer) * 0.5, 1 + math.sin(timer) * 0.5))
   -- RotateGeometry(geometry[2], Vec3(0, 0, timer))
end

function love.draw()
   love.graphics.clear(0, 0, 0, 1, true)

   -- Sort triangles
   local triangles = {}
   for j = 1, #geometry do
      local shape = geometry[j]
      local points = {}
      local z = 0

      for i = 1, #shape.points do
         local pos = shape.points[i]
         points[i] = Rotate3D(Vec3Add(pos, offset), rotation)
         z = z + points[i].z
      end

      for i = 1, #shape.triangles do
         local t = shape.triangles[i]
         local p1, p2, p3 = points[t.x], points[t.y], points[t.z]
         local depth = math.min(p1.z, p2.z, p3.z)
         table.insert(triangles, MakeTriangle(p1, p2, p3, shape.uv[t.x], shape.uv[t.y], shape.uv[t.z], shape.textures[t.w], depth, z / #points))
      end
   end

   table.sort(triangles, function(a, b)
      if (a.avgz ~= b.avgz) then
         return a.avgz > b.avgz
      end
      return a.depth > b.depth
   end)

   -- Draw triangles
   local function pfunc(x, y, r, g, b, a) return 0, 0, 0, 1 end
   CANVAS:mapPixel(pfunc, 0, 0, WIDTH, HEIGHT)

   for j = 1, #triangles do
      local t = triangles[j]

      if t.p1.z > 0 and t.p2.z > 0 and t.p3.z > 0 then
         local s1 = TranslateToScreen(t.p1)
         local s2 = TranslateToScreen(t.p2)
         local s3 = TranslateToScreen(t.p3)

         if TriangleNormalZ(s1, s2, s3) <= 0 then
            local uv1 = TriangleUVData(t.p1.z, t.uv1)
            local uv2 = TriangleUVData(t.p2.z, t.uv2)
            local uv3 = TriangleUVData(t.p3.z, t.uv3)

            if t.texture.r ~= nil and t.texture.g ~= nil and t.texture.b ~= nil then
               DrawTriangleColor(s1, s2, s3, t.texture)
            else
               DrawTriangleTexture(s1, s2, s3, uv1, uv2, uv3, t.texture)
            end
         end
      end
   end

   IMAGE:replacePixels(CANVAS)
   love.graphics.draw(IMAGE, 0, 0, 0, love.graphics.getWidth() / WIDTH, love.graphics.getHeight() / HEIGHT, 0, 0)
end
