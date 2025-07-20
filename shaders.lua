local surfacevertex =
"layout(location=0) in highp vec4 xyz_chunk;"..
"out highp vec4 vScreenPos;"..
"out float chunk;"..
"layout(location=0) uniform vec4 xyoffset_xzscale_yscale;"..
"layout(location=2) uniform highp mat4 viewproj;"..
"void main() {"..
  "highp float x = (xyz_chunk.s * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.s;"..
  "highp float y = (xyz_chunk.t * xyoffset_xzscale_yscale.q);"..
  "highp float z = (xyz_chunk.p * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.t;"..
  "highp vec4 vPos = viewproj * vec4(x, y, z, 1.0);"..
  "vScreenPos = vPos;"..
  "chunk = xyz_chunk.q;"..
  "gl_Position = vPos;"..
"}"

local surfacefragment =
"in highp vec4 vScreenPos;"..
"in float chunk;"..
"out highp vec4 col;"..
"layout(location=1) uniform sampler2D depthTex;"..
"void main() {"..
  "highp float sceneDepth = texture(depthTex, ((vScreenPos.st / vScreenPos.q) + vec2(1.0, 1.0)) / 2.0).r;"..
  "float a = gl_FragCoord.p > sceneDepth ? 0.0 : 1.0;"..
  "float rgb = 0.0;".. -- todo: should be 0 if `chunk` is locked, 1 if it's unlocked
  "col = vec4(rgb, rgb, rgb, a);"..
"}"

local screenvertex =
"layout(location=0) in highp vec2 xy;"..
"out highp vec2 vXY;"..
"void main() {"..
  "vXY = xy;"..
  "gl_Position = vec4(((xy * vec2(2.0, 2.0)) - vec2(1.0, 1.0)) * vec2(1.0, -1.0), 0.0, 1.0);"..
"}"

local screenfragment =
"in highp vec2 vXY;"..
"out highp vec4 col;"..
"layout(location=0) uniform sampler2D tex;"..
"void main() {"..
  "highp vec4 texCol = texture(tex, vXY);"..
  "highp float a = texCol.r > 0.5 ? 0.0 : 0.825;"..
  "col = vec4(0.0, 0.0, 0.0, a);"..
"}"

local compileprogram = function (bolt, vertex, fragment)
  local vs = bolt.createvertexshader(vertex)
  local fs = bolt.createfragmentshader(fragment)
  return bolt.createshaderprogram(vs, fs)
end

return {
  get = function (bolt)
    local surfaceprogram = compileprogram(bolt, surfacevertex, surfacefragment)
    surfaceprogram:setattribute(0, 1, true, false, 4, 0, 4)

    local screenprogram = compileprogram(bolt, screenvertex, screenfragment)
    screenprogram:setattribute(0, 1, true, false, 2, 0, 2)

    return {
      surfaceprogram = surfaceprogram,
      screenprogram = screenprogram,
    }
  end,
}
