local bolt = require("bolt")
bolt.checkversion(1, 0)

local shaders = require("shaders").get(bolt)
local buffers = require("walls").get(bolt)

-- overworld region of the map (inclusive)
-- only chunks inside this region are considered locked or unlocked
local chunkminx = 31
local chunkminy = 40
local chunkmaxx = 59
local chunkmaxy = 62

local lockedchunkalpha = 0.7
shaders.screenprogram:setuniform4f(2, 0, 0, 0, lockedchunkalpha)

local squarebuffer = bolt.createshaderbuffer("\x00\x00\x01\x00\x01\x01\x00\x00\x01\x01\x00\x01")

local doupdatecam = true
local camx, camy, camz
local viewproj = nil

local chunksizeunits = 64 * 512
local ylimit = 256 * 256 * 4

local updatecam = function (event)
  if not doupdatecam then return end
  camx, camy, camz = event:cameraposition()
  viewproj = event:viewprojmatrix()
  doupdatecam = false
end
bolt.onrender3d(updatecam)
bolt.onrenderparticles(updatecam)
bolt.onrenderbillboard(updatecam)

local chunkstates = {}
for x = chunkminx, chunkmaxx do
  local xlist = {}
  for y = chunkminy, chunkmaxy do
    xlist[y] = false
  end
  chunkstates[x] = xlist
end
local chunkstatesize = 8
local chunkstateoffset = chunkstatesize / 2
local chunkstatesurface = bolt.createsurface(chunkstatesize, chunkstatesize)
shaders.surfaceprogram:setuniformsurface(10, chunkstatesurface)
shaders.surfaceprogram:setuniform4i(11, chunkstateoffset, chunkstateoffset, chunkstatesize, chunkstatesize)
shaders.pyramidprogram:setuniformsurface(10, chunkstatesurface)
shaders.pyramidprogram:setuniform4i(11, chunkstateoffset, chunkstateoffset, chunkstatesize, chunkstatesize)
local updatechunkstatesurface = function (camx, camy)
  local limit = chunkstatesize - 1
  for pixelx = 0, limit do
    for pixely = 0, limit do
      local chunkx = camx + pixelx - chunkstateoffset
      local chunky = camy + pixely - chunkstateoffset
      local unlocked = true
      if chunkx >= chunkminx and chunkx <= chunkmaxx and chunky >= chunkminy and chunky <= chunkmaxy then
        unlocked = chunkstates[chunkx][chunky]
      end
      local bytes = unlocked and "\xFF\xFF\xFF\xFF" or "\x00\x00\x00\xFF"
      chunkstatesurface:subimage(pixelx, pixely, 1, 1, bytes)
    end
  end
end

local smoothstep = function (min, max, x)
  if x <= min then return min end
  if x >= max then return max end
  local t = (x - min) / (max - min)
  return t * t * (3.0 - (2.0 * t))
end

-- hard-coded unlocked chunks for testing
chunkstates[37][48] = true
chunkstates[38][49] = true
chunkstates[36][48] = true

bolt.onswapbuffers(function (event)
  doupdatecam = true
  viewproj = nil
end)

local gvsurface = nil
local surfacewidth, surfaceheight
local lastchunkx, lastchunky

local pyramidscale = 1200

bolt.onrendergameview(function (event)
  -- don't try to render anything if we don't know camera view details right now
  if not viewproj then return end

  -- make sure our surface exists and is the same size as the game view
  local gvw, gvh = event:size()
  if not gvsurface or gvw ~= surfacewidth or gvh ~= surfaceheight then
    gvsurface = bolt.createsurface(gvw, gvh)
    surfacewidth = gvw
    surfaceheight = gvh
    shaders.screenprogram:setuniformsurface(0, gvsurface)
  end
  
  -- x and y, in chunk coordinates, of the chunk the camera is in
  local chunkx = math.floor(camx / chunksizeunits)
  local chunky = math.floor(camz / chunksizeunits)

  -- x and y, in units, of the camera relative to the chunk it's in
  local camchunkx = camx % chunksizeunits
  local camchunky = camz % chunksizeunits
  
  -- check if camera is in a different chunk than before
  if chunkx ~= lastchunkx or chunky ~= lastchunky then
    updatechunkstatesurface(chunkx, chunky)
    lastchunkx = chunkx
    lastchunky = chunky
  end

  -- determine if the chunk containing the camera is locked or unlocked
  local unlocked = true
  if chunkx >= chunkminx and chunkx <= chunkmaxx and chunky >= chunkminy and chunky <= chunkmaxy then
    unlocked = chunkstates[chunkx][chunky]
  end

  -- set shader uniforms
  local chunkxunits = chunkx * chunksizeunits
  local chunkyunits = chunky * chunksizeunits
  shaders.surfaceprogram:setuniform4f(0, chunkxunits, chunkyunits, chunksizeunits, ylimit)
  shaders.surfaceprogram:setuniformdepthbuffer(event, 1)
  shaders.surfaceprogram:setuniformmatrix4f(2, false, viewproj:get())
  shaders.pyramidprogram:setuniformdepthbuffer(event, 1)
  shaders.pyramidprogram:setuniformmatrix4f(2, false, viewproj:get())

  -- calculate pyramid locations (i.e. outward bumps in the first 4 walls, to mitigate most camera clipping issues)
  local northwalldist = chunksizeunits - camchunky
  local eastwalldist = chunksizeunits - camchunkx

  -- draw walls
  local clearrgb = unlocked and 1 or 0
  gvsurface:clear(clearrgb, clearrgb, clearrgb, 1)
  for _, buffer in ipairs(buffers) do
    if buffer.pyramid then
      -- north wall
      shaders.pyramidprogram:setuniform4f(0, 0, 1, 0, 1)
      shaders.pyramidprogram:setuniformmatrix4f(6, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, camx, camy, (chunky + 1) * chunksizeunits, 1) -- translate
      shaders.pyramidprogram:setuniformmatrix4f(12, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) -- rotate
      shaders.pyramidprogram:setuniform1f(16, pyramidscale)
      shaders.pyramidprogram:drawtosurface(gvsurface, buffer.buf, buffer.vertexcount)
      -- south wall
      shaders.pyramidprogram:setuniform4f(0, 0, -1, 0, -1)
      shaders.pyramidprogram:setuniformmatrix4f(6, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, camx, camy, chunky * chunksizeunits, 1) -- translate
      shaders.pyramidprogram:setuniformmatrix4f(12, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1) -- rotate
      shaders.pyramidprogram:setuniform1f(16, pyramidscale)
      shaders.pyramidprogram:drawtosurface(gvsurface, buffer.buf, buffer.vertexcount)
      -- east wall
      shaders.pyramidprogram:setuniform4f(0, 1, 0, 1, 0)
      shaders.pyramidprogram:setuniformmatrix4f(6, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, (chunkx + 1) * chunksizeunits, camy, camz, 1) -- translate
      shaders.pyramidprogram:setuniformmatrix4f(12, false, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1) -- rotate
      shaders.pyramidprogram:setuniform1f(16, pyramidscale)
      shaders.pyramidprogram:drawtosurface(gvsurface, buffer.buf, buffer.vertexcount)
      -- west wall
      shaders.pyramidprogram:setuniform4f(0, -1, 0, -1, 0)
      shaders.pyramidprogram:setuniformmatrix4f(6, false, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, chunkx * chunksizeunits, camy, camz, 1) -- translate
      shaders.pyramidprogram:setuniformmatrix4f(12, false, 0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1) -- rotate
      shaders.pyramidprogram:setuniform1f(16, pyramidscale)
      shaders.pyramidprogram:drawtosurface(gvsurface, buffer.buf, buffer.vertexcount)
    else
      shaders.surfaceprogram:drawtosurface(gvsurface, buffer.buf, buffer.vertexcount)
    end
  end

  -- draw gvsurface to game view
  shaders.screenprogram:setuniformdepthbuffer(event, 1)
  shaders.screenprogram:drawtogameview(event, squarebuffer, 6)
end)
