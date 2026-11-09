WIDTH = 200
HEIGHT = 200
NEAR_CLIP = 0.01
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

   -- insert geometry here
   table.insert(geometry, NewFace(Vec3(-1, 0, 3), Vec3(1, 1, 0), Vec3(0, 0, 0), {love.image.newImageData('assets/industrial_floor9.png')}))
   table.insert(geometry, NewFace(Vec3(1, 0, 3), Vec3(1.5, 1, 0), Vec3(0, 0, 0), {Red}))
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

   -- update geometry here
   timer = timer + love.timer.getDelta()
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

   for i = 1, #triangles do
      local output = NearPlaneClipping(triangles[i])
      for j = 1, #output do
         local t = output[j]
         local s1, s2, s3 = TranslateTriangleToScreen(t.p1, t.p2, t.p3)
         if TriangleNormalZ(s1, s2, s3) <= 0 then
            if t.texture.r ~= nil and t.texture.g ~= nil and t.texture.b ~= nil then
               DrawTriangleColor(s1, s2, s3, t.texture)
            else
               local uv1, uv2, uv3 = TriangleFullUVData(t.p1.z, t.uv1, t.p2.z, t.uv2, t.p3.z, t.uv3)
               DrawTriangleTexture(s1, s2, s3, uv1, uv2, uv3, t.texture)
            end
         end
      end
   end

   IMAGE:replacePixels(CANVAS)
   love.graphics.draw(IMAGE, 0, 0, 0, love.graphics.getWidth() / WIDTH, love.graphics.getHeight() / HEIGHT, 0, 0)
end
