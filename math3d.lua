function Rotate3D(x, y, z, ax, ay, az)
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

function TranslateToScreen(x, y, z)
   if (z <= 0) then
      return {0, 0}
   end

   local x2d = ((x / z + 1) / 2) * WIDTH
   local y2d = (1 - ((y / z + 1) / 2)) * HEIGHT
   return {x2d, y2d}
end

function Clamp(x, lo, hi)
   return x < lo and lo or (x > hi and hi or x)
end

function TriangleNormalZ(p1x, p1y, p2x, p2y, p3x, p3y)
   local ax, ay = p2x - p1x, p2y - p1y
   local bx, by = p3x - p1x, p3y - p1y
   return ax * by - ay * bx
end

function TriangleSign(p1x, p1y, p2x, p2y, p3x, p3y)
   return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
end

function TriangleBoundingBox(p1x, p1y, p2x, p2y, p3x, p3y)
   local xmin = Clamp(math.floor(math.min(p1x, p2x, p3x)), 0, WIDTH - 1)
   local xmax = Clamp(math.ceil(math.max(p1x, p2x, p3x)), 0, WIDTH - 1)
   local ymin = Clamp(math.floor(math.min(p1y, p2y, p3y)), 0, HEIGHT - 1)
   local ymax = Clamp(math.ceil(math.max(p1y, p2y, p3y)), 0, HEIGHT - 1)
   return xmin, xmax, ymin, ymax
end

function TriangleArea(p1x, p1y, p2x, p2y, p3x, p3y)
   return 1.0 * (p1x * (p2y - p3y) + p2x * (p3y - p1y) + p3x * (p1y - p2y))
end

function Triangle(p1x, p1y, p2x, p2y, p3x, p3y, r, g, b)
   local xmin, xmax, ymin, ymax = TriangleBoundingBox(p1x, p1y, p2x, p2y, p3x, p3y)
   local area = TriangleArea(p1x, p1y, p2x, p2y, p3x, p3y)
   if (area == 0.0) then return end

   for dy = ymin, ymax do
      for dx = xmin, xmax do
         local x = dx + 0.5
         local y = dy + 0.5
         local d1 = TriangleSign(x, y, p1x, p1y, p2x, p2y)
         local d2 = TriangleSign(x, y, p2x, p2y, p3x, p3y)
         local d3 = TriangleSign(x, y, p3x, p3y, p1x, p1y)
         if (d1 < 0 and d2 < 0 and d3 < 0) or (d1 > 0 and d2 > 0 and d3 > 0) then
            local w3, w1, w2 = d1 / area, d2 / area, d3 / area
            CANVAS:setPixel(dx, dy, w1, w2, w3, 1.0)
         end
      end
   end
end
