local bolt = require("bolt")
bolt.checkversion(1, 0)

local shaders = require("shaders").get(bolt)
local wallbuffer, wallvertexcount = require("walls").get(bolt)

-- overworld region of the map (inclusive)
-- only chunks inside this region are considered locked or unlocked
local chunkminx = 31
local chunkminy = 40
local chunkmaxx = 59
local chunkmaxy = 62

local squarebuffer = bolt.createshaderbuffer("\x00\x00\x01\x00\x01\x01\x00\x00\x01\x01\x00\x01")

local doupdatecam = true
local camx, camz
local viewmat = nil
local projmat = nil

local chunksizeunits = 64 * 512
local ylimit = 256 * 256 * 4

local updatecam = function (event)
  if not doupdatecam then return end
  camx, _, camz = event:cameraposition()
  viewmat = event:viewmatrix()
  projmat = event:projmatrix()
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
local chunkstatesurface = bolt.createsurface(8, 8) -- only actually use 5x5, but power of two eliminates GLSL sampling errors
local updatechunkstatesurface = function (camx, camy)
  for x = camx - 2, camx + 2 do
    for y = camy - 2, camy + 2 do
      local unlocked = true
      if x >= chunkminx and x <= chunkmaxx and y >= chunkminy and y <= chunkmaxy then
        unlocked = chunkstates[x][y]
      end
      local bytes = unlocked and "\xFF\xFF\xFF\xFF" or "\x00\x00\x00\xFF"
      chunkstatesurface:subimage(x + 2 - camx, y + 2 - camy, 1, 1, bytes)
    end
  end
end

-- hard-coded unlocked chunks for testing
chunkstates[37][48] = true
chunkstates[38][49] = true
chunkstates[36][48] = true

bolt.onswapbuffers(function (event)
  doupdatecam = true
  viewmat = nil
  projmat = nil
end)

local gvsurface = nil
local surfacewidth, surfaceheight
local lastchunkx, lastchunky

bolt.onrendergameview(function (event)
  -- don't try to render anything if we don't know camera view details right now
  if not viewmat or not projmat then return end

  -- make sure our surface exists and is the same size as the game view
  local gvw, gvh = event:size()
  if not gvsurface or gvw ~= surfacewidth or gvh ~= surfaceheight then
    gvsurface = bolt.createsurface(gvw, gvh)
    surfacewidth = gvw
    surfaceheight = gvh
    shaders.screenprogram:setuniformsurface(0, gvsurface)
  end
  
  -- camera's x and y, in units, relative to the chunk it's currently in
  --local camerachunkx = camx % chunksizeunits
  --local camerachunky = camz % chunksizeunits

  -- x and y, in chunk coordinates, of the chunk the camera is in
  local chunkx = math.floor(camx / chunksizeunits)
  local chunky = math.floor(camz / chunksizeunits)
  
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

  -- draw walls
  local clearrgb = unlocked and 1 or 0
  gvsurface:clear(clearrgb, clearrgb, clearrgb, 1)
  shaders.surfaceprogram:setuniform4f(0, chunkx * chunksizeunits, chunky * chunksizeunits, chunksizeunits, ylimit)
  shaders.surfaceprogram:setuniformdepthbuffer(event, 1)
  shaders.surfaceprogram:setuniformmatrix4f(2, false, viewmat:get())
  shaders.surfaceprogram:setuniformmatrix4f(6, false, projmat:get())
  shaders.surfaceprogram:setuniformsurface(10, chunkstatesurface)
  shaders.surfaceprogram:drawtosurface(gvsurface, wallbuffer, wallvertexcount)

  -- draw gvsurface to game view
  shaders.screenprogram:setuniformsurface(0, gvsurface)
  shaders.screenprogram:drawtogameview(event, squarebuffer, 6)
end)
