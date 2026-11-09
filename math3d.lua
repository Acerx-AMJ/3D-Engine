function Vec2(x, y)
   return {x = x, y = y}
end

function Vec2Add(p1, p2)
   return {x = p1.x + p2.x, y = p1.y + p2.y}
end

function Vec2Sub(p1, p2)
   return {x = p1.x - p2.x, y = p1.y - p2.y}
end

function Vec2Mul(p1, f)
   return {x = p1.x * f, y = p1.y * f}
end

function Vec2Mul2(p1, p2)
   return {x = p1.x * p2.x, y = p1.y * p2.y}
end

function Vec2Div(p1, f)
   return {x = p1.x / f, y = p1.y / f}
end

function Vec2Div2(p1, p2)
   return {x = p1.x / p2.x, y = p1.y / p2.y}
end

function Vec3(x, y, z)
   return {x = x, y = y, z = z}
end

function Vec3Add(p1, p2)
   return {x = p1.x + p2.x, y = p1.y + p2.y, z = p1.z + p2.z}
end

function Vec3Sub(p1, p2)
   return {x = p1.x - p2.x, y = p1.y - p2.y, z = p1.z - p2.z}
end

function Vec3Mul(p1, f)
   return {x = p1.x * f, y = p1.y * f, z = p1.z * f}
end

function Vec3Mul3(p1, p2)
   return {x = p1.x * p2.x, y = p1.y * p2.y, z = p1.z * p2.z}
end

function Vec3Div(p1, f)
   return {x = p1.x / f, y = p1.y / f, z = p1.z / f}
end

function Vec3Div3(p1, p2)
   return {x = p1.x / p2.x, y = p1.y / p2.y, z = p1.z / p2.z}
end

function Vec3ZeroFix(p1)
   return {x = (p1.x == 0 and 1 or p1.x), y = (p1.y == 0 and 1 or p1.y), z = (p1.z == 0 and 1 or p1.z)}
end

function Vec4(x, y, z, w)
   return {x = x, y = y, z = z, w = w}
end

function Clamp(x, lo, hi)
   return x < lo and lo or (x > hi and hi or x)
end

function Rotate3D(pos, rotation)
   local result = Vec3(pos.x, pos.y, pos.z)

   local sx, cx = math.sin(rotation.x), math.cos(rotation.x)
   local sy, cy = math.sin(rotation.y), math.cos(rotation.y)
   local sz, cz = math.sin(rotation.z), math.cos(rotation.z)

   local x1 = result.x * cy - result.z * sy
   local z2 = result.x * sy + result.z * cy
   result.x = x1
   result.z = z2

   local y1 = result.y * cx - result.z * sx
   local z1 = result.y * sx + result.z * cx
   result.y = y1
   result.z = z1

   local x2 = result.x * cz - result.y * sz
   local y2 = result.x * sz + result.y * cz
   result.x = x2
   result.y = y2

   return result
end

function Rotate3DAroundOrigin(pos, origin, rotation)
   if rotation.x == 0 and rotation.y == 0 and rotation.z == 0 then return Vec3(pos.x, pos.y, pos.z) end
   return Vec3Add(Rotate3D(Vec3Sub(pos, origin), rotation), origin)
end

function TranslateToScreen(p)
   if (p.z <= 0) then
      return Vec2(0, 0)
   end

   local x2d = ((p.x / p.z + 1) / 2) * WIDTH
   local y2d = (1 - ((p.y / p.z + 1) / 2)) * HEIGHT
   return Vec2(x2d, y2d)
end

function TranslateTriangleToScreen(p1, p2, p3)
   local tp1 = TranslateToScreen(p1)
   local tp2 = TranslateToScreen(p2)
   local tp3 = TranslateToScreen(p3)
   return tp1, tp2, tp3
end

function TriangleNormalZ(p1, p2, p3)
   local ax, ay = p2.x - p1.x, p2.y - p1.y
   local bx, by = p3.x - p1.x, p3.y - p1.y
   return ax * by - ay * bx
end

function TriangleSign(p1x, p1y, p2x, p2y, p3x, p3y)
   return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
end

function TriangleEdgeValues(dx, dy, p1, p2, p3)
   local x = dx + 0.5
   local y = dy + 0.5
   local d1 = TriangleSign(x, y, p1.x, p1.y, p2.x, p2.y)
   local d2 = TriangleSign(x, y, p2.x, p2.y, p3.x, p3.y)
   local d3 = TriangleSign(x, y, p3.x, p3.y, p1.x, p1.y)
   return d1, d2, d3
end

function TriangleBoundingBox(p1, p2, p3)
   local xmin = Clamp(math.floor(math.min(p1.x, p2.x, p3.x)), 0, WIDTH - 1)
   local xmax = Clamp(math.ceil(math.max(p1.x, p2.x, p3.x)), 0, WIDTH - 1)
   local ymin = Clamp(math.floor(math.min(p1.y, p2.y, p3.y)), 0, HEIGHT - 1)
   local ymax = Clamp(math.ceil(math.max(p1.y, p2.y, p3.y)), 0, HEIGHT - 1)
   return xmin, xmax, ymin, ymax
end

function TriangleArea(p1, p2, p3)
   return 1.0 * (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y))
end

function TriangleColorWeight(w1, w2, w3, c1, c2, c3)
   local r = w1 * c1.r + w2 * c2.r + w3 * c3.r
   local g = w1 * c1.g + w2 * c2.g + w3 * c3.g
   local b = w1 * c1.b + w2 * c2.b + w3 * c3.b
   return r, g, b
end

function TriangleUVData(z, uv)
   return Vec3(1 / z, uv.x / z, uv.y / z)
end

function TriangleFullUVData(z1, uv1, z2, uv2, z3, uv3)
   local uvd1 = TriangleUVData(z1, uv1)
   local uvd2 = TriangleUVData(z2, uv2)
   local uvd3 = TriangleUVData(z3, uv3)
   return uvd1, uvd2, uvd3
end

function TriangleUV(w1, w2, w3, uv1, uv2, uv3)
   local k = w1 * uv1.x + w2 * uv2.x + w3 * uv3.x
   local r = w1 * uv1.y + w2 * uv2.y + w3 * uv3.y
   local g = w1 * uv1.z + w2 * uv2.z + w3 * uv3.z
   return r / k, g / k
end

function TriangleUVTextureCoords(u, v, twidth, theight)
   local tx = Clamp(u * twidth, 0, twidth - 1)
   local ty = Clamp(theight - (v * theight), 0, theight - 1)
   return tx, ty
end

function TriangleCrossingPoint(n, p1, p2)
   return Vec3Add(p1, Vec3Mul(Vec3Sub(p2, p1), n))
end

function NearPlaneClipping(t)
   local p1front = (t.p1.z >= NEAR_CLIP)
   local p2front = (t.p2.z >= NEAR_CLIP)
   local p3front = (t.p3.z >= NEAR_CLIP)

   if not p1front and not p2front and not p3front then
      return {}
   end

   local newVertices = {}
   local function HandleEdge(p1, p2, uv1, uv2, f1, f2)
      if f1 then
         table.insert(newVertices, {p = p1, uv = uv1})
      end

      if f1 ~= f2 then
         local t = (NEAR_CLIP - p1.z) / (p2.z - p1.z)
         local p3 = Vec3Add(p1, Vec3Mul(Vec3Sub(p2, p1), t))
         local uv3 = Vec2Add(uv1, Vec2Mul(Vec2Sub(uv2, uv1), t))
         table.insert(newVertices, {p = p3, uv = uv3})
      end
   end

   HandleEdge(t.p1, t.p2, t.uv1, t.uv2, p1front, p2front)
   HandleEdge(t.p2, t.p3, t.uv2, t.uv3, p2front, p3front)
   HandleEdge(t.p3, t.p1, t.uv3, t.uv1, p3front, p1front)

   if #newVertices == 3 then
      local triangle = MakeTriangle(newVertices[1].p, newVertices[2].p, newVertices[3].p, newVertices[1].uv, newVertices[2].uv, newVertices[3].uv, t.texture)
      return {triangle}
   else
      local triangle1 = MakeTriangle(newVertices[1].p, newVertices[2].p, newVertices[3].p, newVertices[1].uv, newVertices[2].uv, newVertices[3].uv, t.texture)
      local triangle2 = MakeTriangle(newVertices[1].p, newVertices[3].p, newVertices[4].p, newVertices[1].uv, newVertices[3].uv, newVertices[4].uv, t.texture)
      return {triangle1, triangle2}
   end
end

function DrawTriangleColor(p1, p2, p3, color)
   local xmin, xmax, ymin, ymax = TriangleBoundingBox(p1, p2, p3)
   local area = TriangleArea(p1, p2, p3)
   if (area == 0.0) then return end

   for dy = ymin, ymax do
      for dx = xmin, xmax do
         local d1, d2, d3 = TriangleEdgeValues(dx, dy, p1, p2, p3)
         if (d1 <= 0 and d2 <= 0 and d3 <= 0) or (d1 >= 0 and d2 >= 0 and d3 >= 0) then
            CANVAS:setPixel(dx, dy, color.r, color.g, color.b, 1.0)
         end
      end
   end
end

function DrawTriangleTexture(p1, p2, p3, uv1, uv2, uv3, texture)
   local xmin, xmax, ymin, ymax = TriangleBoundingBox(p1, p2, p3)
   local area = TriangleArea(p1, p2, p3)
   if (area == 0.0) then return end
   local twidth = texture:getWidth()
   local theight = texture:getHeight()

   for dy = ymin, ymax do
      for dx = xmin, xmax do
         local d1, d2, d3 = TriangleEdgeValues(dx, dy, p1, p2, p3)
         if (d1 <= 0 and d2 <= 0 and d3 <= 0) or (d1 >= 0 and d2 >= 0 and d3 >= 0) then
            local w3, w1, w2 = d1 / area, d2 / area, d3 / area
            local u, v = TriangleUV(w1, w2, w3, uv1, uv2, uv3)
            local tx, ty = TriangleUVTextureCoords(u, v, twidth, theight)
            local r, g, b, a = texture:getPixel(tx, ty)
            CANVAS:setPixel(dx, dy, r, g, b, a)
         end
      end
   end
end
