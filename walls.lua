-- list of walls in concentric circles relative to a central chunk.
-- all the x and z coordinate given will be between -2 and 3, inclusive,
-- and the y coordinates will be either 0 or 1.
-- the walls must be concentric so that no wall could ever be in front of a previous wall from any viewpoint
-- within the central chunk. so, the first four walls surround the central chunk, then the next set is a
-- plus-shape surrounding all the chunks cardinally-adjacent to that, then the next set surround all the chunks
-- cardinally-adjacent to those, and so on.
-- "cx" and "cy" define which chunk is immediately behind this wall from the point of view of the central chunk,
-- and is used to determine whether this wall should be drawn as a "locked" or "unlocked" chunk.
local list = {
  { cx = -1, cy = 0, x1 = 0, y1 = 0, x2 = 0, y2 = 1 },
  { cx = 0, cy = -1, x1 = 0, y1 = 0, x2 = 1, y2 = 0 },
  { cx = 0, cy = 1,  x1 = 0, y1 = 1, x2 = 1, y2 = 1 },
  { cx = 1, cy = 0,  x1 = 1, y1 = 0, x2 = 1, y2 = 1 },

  { cx = -1, cy = -1, x1 = 0, y1 = 0,  x2 = -1, y2 = 0 },
  { cx = -2, cy = 0,  x1 = -1, y1 = 0, x2 = -1, y2 = 1 },
  { cx = -1, cy = 1,  x1 = -1, y1 = 1, x2 = 0, y2 = 1 },
  { cx = -1, cy = 1,  x1 = 0, y1 = 1,  x2 = 0, y2 = 2 },
  { cx = 0, cy = 2,   x1 = 0, y1 = 2,  x2 = 1, y2 = 2 },
  { cx = 1, cy = 1,   x1 = 1, y1 = 2,  x2 = 1, y2 = 1 },
  { cx = 1, cy = 1,   x1 = 1, y1 = 1,  x2 = 2, y2 = 1 },
  { cx = 2, cy = 0,   x1 = 2, y1 = 1,  x2 = 2, y2 = 0 },
  { cx = 1, cy = -1,  x1 = 2, y1 = 0,  x2 = 1, y2 = 0 },
  { cx = 1, cy = -1,  x1 = 1, y1 = 0,  x2 = 1, y2 = -1 },
  { cx = 0, cy = -2,  x1 = 1, y1 = -1, x2 = 0, y2 = -1 },
  { cx = -1, cy = -1, x1 = 0, y1 = -1, x2 = 0, y2 = 0 },

  { cx = -2, cy = 1, x1 = -2, y1 = 1, x2 = -1, y2 = 1 },
  { cx = -2, cy = 1, x1 = -1, y1 = 1, x2 = -1, y2 = 2 },
  { cx = -1, cy = 2, x1 = -1, y1 = 2, x2 = 0, y2 = 2 },
  { cx = -1, cy = 2, x1 = 0, y1 = 2,  x2 = 0, y2 = 3 },
  { cx = 0, cy = 3,  x1 = 0, y1 = 3,  x2 = 1, y2 = 3 },
  { cx = 1, cy = 2,  x1 = 1, y1 = 3,  x2 = 1, y2 = 2 },
  { cx = 1, cy = 2,  x1 = 1, y1 = 2,  x2 = 2, y2 = 2 },
  { cx = 2, cy = 1,  x1 = 2, y1 = 2,  x2 = 2, y2 = 1 },
  { cx = 2, cy = 1,  x1 = 2, y1 = 1,  x2 = 3, y2 = 1 },
  { cx = 3, cy = 0,  x1 = 3, y1 = 1,  x2 = 3, y2 = 0 },
  { cx = 2, cy = -1, x1 = 3, y1 = 0,  x2 = 2, y2 = 0 },
  { cx = 2, cy = -1, x1 = 2, y1 = 0,  x2 = 2, y2 = -1 },
  { cx = 1, cy = -2, x1 = 2, y1 = -1, x2 = 1, y2 = -1 },
  { cx = 1, cy = -2, x1 = 1, y1 = -1, x2 = 1, y2 = -2 },
  { cx = 0, cy = -3, x1 = 1, y1 = -2, x2 = 0, y2 = -2 },

  { cx = 1, cy = 3,   x1 = 1, y1 = 4, x2 = 1, y2 = 3 },
  { cx = 1, cy = 3,   x1 = 1, y1 = 3, x2 = 2, y2 = 3 },
  { cx = 2, cy = 2,   x1 = 2, y1 = 3, x2 = 2, y2 = 2 },
  { cx = 2, cy = 2,   x1 = 2, y1 = 2, x2 = 3, y2 = 2 },
  { cx = 3, cy = 1,   x1 = 3, y1 = 2, x2 = 3, y2 = 1 },
  { cx = 3, cy = 1,   x1 = 3, y1 = 1, x2 = 4, y2 = 1 },
  { cx = 4, cy = 0,   x1 = 4, y1 = 1, x2 = 4, y2 = 0 },
  { cx = 3, cy = -1,  x1 = 4, y1 = 0, x2 = 3, y2 = 0 },
  { cx = 3, cy = -1,  x1 = 3, y1 = 0, x2 = 3, y2 = -1 },
  { cx = 2, cy = -2,  x1 = 3, y1 = -1, x2 = 2, y2 = -1 },
  { cx = 2, cy = -2,  x1 = 2, y1 = -1, x2 = 2, y2 = -2 },
  { cx = 1, cy = -3,  x1 = 2, y1 = -2, x2 = 1, y2 = -2 },
  { cx = 1, cy = -3,  x1 = 1, y1 = -2, x2 = 1, y2 = -3 },
  { cx = 0, cy = -4,  x1 = 1, y1 = -3, x2 = 0, y2 = -3 },
  { cx = -1, cy = -3, x1 = 0,  y1 = -3, x2 = 0, y2 = -2 },
  { cx = -1, cy = -3, x1 = 0,  y1 = -2, x2 = -1, y2 = -2 },
  { cx = -2, cy = -2, x1 = -1, y1 = -2, x2 = -1, y2 = -1 },
  { cx = -2, cy = -2, x1 = -1, y1 = -1, x2 = -2, y2 = -1 },
  { cx = -3, cy = -1, x1 = -2, y1 = -1, x2 = -2, y2 = 0 },
  { cx = -3, cy = -1, x1 = -2, y1 = 0,  x2 = -3, y2 = 0 },
  { cx = -4, cy = 0,  x1 = -3, y1 = 0,  x2 = -3, y2 = 1 },
  { cx = -3, cy = 1, x1 = -3, y1 = 1, x2 = -2, y2 = 1 },
  { cx = -3, cy = 1, x1 = -2, y1 = 1, x2 = -2, y2 = 2 },
  { cx = -2, cy = 2, x1 = -2, y1 = 2, x2 = -1, y2 = 2 },
  { cx = -2, cy = 2, x1 = -1, y1 = 2, x2 = -1, y2 = 3 },
  { cx = -1, cy = 3, x1 = -1, y1 = 3, x2 = 0, y2 = 3 },
  { cx = -1, cy = 3, x1 = 0, y1 = 3,  x2 = 0, y2 = 4 },
  { cx = 0, cy = 4,  x1 = 0, y1 = 4,  x2 = 1, y2 = 4 },

  { cx = 1, cy = 4,   x1 = 1, y1 = 4,   x2 = 2, y2 = 4 },
  { cx = 2, cy = 3,   x1 = 2, y1 = 4,   x2 = 2, y2 = 3 },
  { cx = 2, cy = 3,   x1 = 2, y1 = 3,   x2 = 3, y2 = 3 },
  { cx = 3, cy = 2,   x1 = 3, y1 = 3,   x2 = 3, y2 = 2 },
  { cx = 3, cy = 2,   x1 = 3, y1 = 2,   x2 = 4, y2 = 2 },
  { cx = 4, cy = 1,   x1 = 4, y1 = 2,   x2 = 4, y2 = 1 },
  { cx = 4, cy = -1,  x1 = 4, y1 = 0,   x2 = 4, y2 = -1 },
  { cx = 3, cy = -2,  x1 = 4, y1 = -1,  x2 = 3, y2 = -1 },
  { cx = 3, cy = -2,  x1 = 3, y1 = -1,  x2 = 3, y2 = -2 },
  { cx = 2, cy = -3,  x1 = 3, y1 = -2,  x2 = 2, y2 = -2 },
  { cx = 2, cy = -3,  x1 = 2, y1 = -2,  x2 = 2, y2 = -3 },
  { cx = 1, cy = -4,  x1 = 2, y1 = -3,  x2 = 1, y2 = -4 },
  { cx = -1, cy = -4, x1 = 0, y1 = -3,  x2 = -1, y2 = -3 },
  { cx = -2, cy = -3, x1 = -1, y1 = -3, x2 = -1, y2 = -2 },
  { cx = -2, cy = -3, x1 = -1, y1 = -2, x2 = -2, y2 = -2 },
  { cx = -3, cy = -2, x1 = -2, y1 = -2, x2 = -2, y2 = -1 },
  { cx = -3, cy = -2, x1 = -2, y1 = -1, x2 = -3, y2 = -1 },
  { cx = -4, cy = -1, x1 = -3, y1 = -1, x2 = -3, y2 = 0 },
  { cx = -4, cy = 1, x1 = -3, y1 = 1, x2 = -3, y2 = 2 },
  { cx = -3, cy = 2, x1 = -3, y1 = 2, x2 = -2, y2 = 2 },
  { cx = -3, cy = 2, x1 = -2, y1 = 2, x2 = -2, y2 = 3 },
  { cx = -2, cy = 3, x1 = -2, y1 = 3, x2 = -1, y2 = 3 },
  { cx = -2, cy = 3, x1 = -1, y1 = 3, x2 = -1, y2 = 4 },
  { cx = -1, cy = 4, x1 = -1, y1 = 4, x2 = 0, y2 = 4 },

  { cx = -4, cy = 2, x1 = -3, y1 = 2, x2 = -3, y2 = 3 },
  { cx = -3, cy = 3, x1 = -3, y1 = 3, x2 = -2, y2 = 3 },
  { cx = -3, cy = 3, x1 = -2, y1 = 3, x2 = -2, y2 = 4 },
  { cx = -2, cy = 4, x1 = -2, y1 = 4, x2 = -1, y2 = 4 },
  { cx = 2, cy = 4, x1 = 2, y1 = 4, x2 = 3, y2 = 4 },
  { cx = 3, cy = 3, x1 = 3, y1 = 4, x2 = 3, y2 = 3 },
  { cx = 3, cy = 3, x1 = 3, y1 = 3, x2 = 4, y2 = 3 },
  { cx = 4, cy = 2, x1 = 4, y1 = 3, x2 = 4, y2 = 2 },
  { cx = 4, cy = -2, x1 = 4, y1 = -1, x2 = 4, y2 = -2 },
  { cx = 3, cy = -3, x1 = 4, y1 = -2, x2 = 3, y2 = -2 },
  { cx = 3, cy = -3, x1 = 3, y1 = -2, x2 = 3, y2 = -3 },
  { cx = 2, cy = -4, x1 = 3, y1 = -3, x2 = 2, y2 = -3 },
  { cx = -2, cy = -4, x1 = -1, y1 = -3, x2 = -2, y2 = -3 },
  { cx = -3, cy = -3, x1 = -2, y1 = -3, x2 = -2, y2 = -2 },
  { cx = -3, cy = -3, x1 = -2, y1 = -2, x2 = -3, y2 = -2 },
  { cx = -4, cy = -2, x1 = -3, y1 = -2, x2 = -3, y2 = -1 },
}

-- builds a list of vertex coordinates from the list of walls above
local makebuffer = function (bolt)
  local vertexcount = #list * 6
  local buffer = bolt.createbuffer(vertexcount * 5)
  local cursor = 0

  local set = function (val)
    buffer:setint8(cursor, val)
    cursor = cursor + 1
  end

  for _, wall in ipairs(list) do
    set(wall.x1)
    set(0)
    set(wall.y1)
    set(wall.cx)
    set(wall.cy)

    set(wall.x2)
    set(0)
    set(wall.y2)
    set(wall.cx)
    set(wall.cy)

    set(wall.x2)
    set(1)
    set(wall.y2)
    set(wall.cx)
    set(wall.cy)

    set(wall.x1)
    set(0)
    set(wall.y1)
    set(wall.cx)
    set(wall.cy)

    set(wall.x2)
    set(1)
    set(wall.y2)
    set(wall.cx)
    set(wall.cy)

    set(wall.x1)
    set(1)
    set(wall.y1)
    set(wall.cx)
    set(wall.cy)
  end

  return bolt.createshaderbuffer(buffer), vertexcount
end

return { get = makebuffer }
