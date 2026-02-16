function TriangleNormalZ(p1x, p1y, p2x, p2y, p3x, p3y)
   local ax, ay = p2x - p1x, p2y - p1y
   local bx, by = p3x - p1x, p3y - p1y
   return ax * by - ay * bx
end

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

   local coords = {x / z, y / z}
   return {
      ((coords[1] + 1) / 2) * love.graphics.getWidth(),
      (1 - ((coords[2] + 1) / 2)) * love.graphics.getHeight(),
   }
end
