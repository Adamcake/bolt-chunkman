local bolt = require("bolt")
bolt.checkversion(1, 0)

local shaders = require("shaders").get(bolt)
local wallbuffer, wallvertexcount = require("walls").get(bolt)

local squarebuffer = bolt.createshaderbuffer("\x00\x00\x01\x00\x01\x01\x00\x00\x01\x01\x00\x01")

local doupdatecam = true
local camx, camz
local viewproj = nil

local chunksizeunits = 64 * 512
local ylimit = 256 * 256 * 4

local updatecam = function (event)
  if not doupdatecam then return end
  camx, _, camz = event:cameraposition()
  viewproj = event:viewprojmatrix()
  doupdatecam = false
end
bolt.onrender3d(updatecam)
bolt.onrenderparticles(updatecam)
bolt.onrenderbillboard(updatecam)

bolt.onswapbuffers(function (event)
  doupdatecam = true
  viewproj = nil
end)

local gvsurface = nil
local surfacewidth, surfaceheight

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
  
  -- camera's x and y, in units, relative to the chunk it's currently in
  --local camerachunkx = camx % chunksizeunits
  --local camerachunky = camz % chunksizeunits

  -- x and y, in chunk coordinates, of the chunk the camera is in
  local chunkx = math.floor(camx / chunksizeunits)
  local chunky = math.floor(camz / chunksizeunits)

  -- draw walls
  gvsurface:clear(1, 1, 1, 1) -- todo: make this opaque black if the chunk with the camera in it is locked, opaque white if it's unlocked
  shaders.surfaceprogram:setuniform4f(0, chunkx * chunksizeunits, chunky * chunksizeunits, chunksizeunits, ylimit)
  shaders.surfaceprogram:setuniformdepthbuffer(event, 1)
  shaders.surfaceprogram:setuniformmatrix4f(2, false, viewproj:get())
  shaders.surfaceprogram:drawtosurface(gvsurface, wallbuffer, wallvertexcount)

  -- draw gvsurface to game view
  shaders.screenprogram:setuniformsurface(0, gvsurface)
  shaders.screenprogram:drawtogameview(event, squarebuffer, 6)
end)
