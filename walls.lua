-- list of walls, to be transformed below
local list = {
  { chunk = 11, x1 = 0, y1 = 0, x2 = 0, y2 = 1 },
  { chunk = 7, x1 = 0, y1 = 0, x2 = 1, y2 = 0 },
  { chunk = 17, x1 = 0, y1 = 1, x2 = 1, y2 = 1 },
  { chunk = 13, x1 = 1, y1 = 0, x2 = 1, y2 = 1 },

  { chunk = 6, x1 = 0, y1 = 0, x2 = -1, y2 = 0 },
  { chunk = 10, x1 = -1, y1 = 0, x2 = -1, y2 = 1 },
  { chunk = 16, x1 = -1, y1 = 1, x2 = 0, y2 = 1 },
  { chunk = 16, x1 = 0, y1 = 1, x2 = 0, y2 = 2 },
  { chunk = 22, x1 = 0, y1 = 2, x2 = 1, y2 = 2 },
  { chunk = 23, x1 = 1, y1 = 2, x2 = 1, y2 = 1 },
  { chunk = 23, x1 = 1, y1 = 1, x2 = 2, y2 = 1 },
  { chunk = 14, x1 = 2, y1 = 1, x2 = 2, y2 = 0 },
  { chunk = 8, x1 = 2, y1 = 0, x2 = 1, y2 = 0 },
  { chunk = 8, x1 = 1, y1 = 0, x2 = 1, y2 = -1 },
  { chunk = 2, x1 = 1, y1 = -1, x2 = 0, y2 = -1 },
  { chunk = 6, x1 = 0, y1 = -1, x2 = 0, y2 = 0 },

  { chunk = 15, x1 = -2, y1 = 1, x2 = -1, y2 = 1 },
  { chunk = 15, x1 = -1, y1 = 1, x2 = -1, y2 = 2 },
  { chunk = 21, x1 = -1, y1 = 2, x2 = 0, y2 = 2 },
  { chunk = 21, x1 = 0, y1 = 2, x2 = 0, y2 = 3 },
  { chunk = 5, x1 = -2, y1 = 0, x2 = -1, y2 = 0 },
  { chunk = 5, x1 = -1, y1 = 0, x2 = -1, y2 = -1 },
  { chunk = 1, x1 = -1, y1 = -1, x2 = 0, y2 = -1 },
  { chunk = 1, x1 = 0, y1 = -1, x2 = 0, y2 = -2 },
  { chunk = 23, x1 = 1, y1 = 3, x2 = 1, y2 = 2 },
  { chunk = 23, x1 = 1, y1 = 2, x2 = 2, y2 = 2 },
  { chunk = 19, x1 = 2, y1 = 2, x2 = 2, y2 = 1 },
  { chunk = 19, x1 = 2, y1 = 1, x2 = 3, y2 = 1 },
  { chunk = 3, x1 = 1, y1 = -2, x2 = 1, y2 = -1 },
  { chunk = 3, x1 = 1, y1 = -1, x2 = 2, y2 = -1 },
  { chunk = 9, x1 = 2, y1 = -1, x2 = 2, y2 = 0 },
  { chunk = 9, x1 = 2, y1 = 0, x2 = 3, y2 = 0 },

  { chunk = 20, x1 = -2, y1 = 2, x2 = -1, y2 = 2 },
  { chunk = 20, x1 = -1, y1 = 2, x2 = -1, y2 = 3 },
  { chunk = 24, x1 = 2, y1 = 3, x2 = 2, y2 = 2 },
  { chunk = 24, x1 = 2, y1 = 2, x2 = 3, y2 = 2 },
  { chunk = 4, x1 = 3, y1 = -1, x2 = 2, y2 = -1 },
  { chunk = 4, x1 = 2, y1 = -1, x2 = 2, y2 = -1 },
  { chunk = 0, x1 = -1, y1 = -2, x2 = -1, y2 = -1 },
  { chunk = 0, x1 = -1, y1 = -1, x2 = -2, y2 = -1 },

  { chunk = -1, x1 = -2, y1 = 3, x2 = -1, y2 = 3 },
  { chunk = -1, x1 = -1, y1 = 3, x2 = 0, y2 = 3 },
  { chunk = -1, x1 = 0, y1 = 3, x2 = 1, y2 = 3 },
  { chunk = -1, x1 = 1, y1 = 3, x2 = 2, y2 = 3 },
  { chunk = -1, x1 = 2, y1 = 3, x2 = 3, y2 = 3 },
  { chunk = -1, x1 = 3, y1 = 3, x2 = 3, y2 = 2 },
  { chunk = -1, x1 = 3, y1 = 2, x2 = 3, y2 = 1 },
  { chunk = -1, x1 = 3, y1 = 1, x2 = 3, y2 = 0 },
  { chunk = -1, x1 = 3, y1 = 0, x2 = 3, y2 = -1 },
  { chunk = -1, x1 = 3, y1 = -1, x2 = 3, y2 = -2 },
  { chunk = -1, x1 = 3, y1 = -2, x2 = 2, y2 = -2 },
  { chunk = -1, x1 = 2, y1 = -2, x2 = 1, y2 = -2 },
  { chunk = -1, x1 = 1, y1 = -2, x2 = 0, y2 = -2 },
  { chunk = -1, x1 = 0, y1 = -2, x2 = -1, y2 = -2 },
  { chunk = -1, x1 = -1, y1 = -2, x2 = -2, y2 = -2 },
  { chunk = -1, x1 = -2, y1 = -2, x2 = -2, y2 = -1 },
  { chunk = -1, x1 = -2, y1 = -1, x2 = -2, y2 = 0 },
  { chunk = -1, x1 = -2, y1 = 0, x2 = -2, y2 = 1 },
  { chunk = -1, x1 = -2, y1 = 1, x2 = -2, y2 = 2 },
  { chunk = -1, x1 = -2, y1 = 2, x2 = -2, y2 = 3 },
}

-- builds a list of vertex coordinates, making walls in concentric circles relative to a central chunk.
-- all the x and z coordinate given will be between -2 and 3, inclusive,
-- and the y coordinates will be either 0 or 1.
-- the walls must be concentric so that no wall could ever be in front of a
-- previous wall from any viewpoint within the central chunk.
local makebuffer = function (bolt)
  local vertexcount = #list * 6
  local buffer = bolt.createbuffer(vertexcount * 4)
  local cursor = 0

  local set = function (val)
    buffer:setint8(cursor, val)
    cursor = cursor + 1
  end

  for _, wall in ipairs(list) do
    set(wall.x1)
    set(0)
    set(wall.y1)
    set(wall.chunk)
    set(wall.x2)
    set(0)
    set(wall.y2)
    set(wall.chunk)
    set(wall.x2)
    set(1)
    set(wall.y2)
    set(wall.chunk)
    set(wall.x1)
    set(0)
    set(wall.y1)
    set(wall.chunk)
    set(wall.x2)
    set(1)
    set(wall.y2)
    set(wall.chunk)
    set(wall.x1)
    set(1)
    set(wall.y1)
    set(wall.chunk)
  end

  return bolt.createshaderbuffer(buffer), vertexcount
end

return { get = makebuffer }
