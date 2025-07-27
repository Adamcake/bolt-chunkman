local surfacevertex =
"layout(location=0) in highp vec4 xyz_chunk;"..
"out highp vec4 vScreenPos;"..
"noperspective out highp float vFragDepth;"..
"flat out float chunk;"..
"layout(location=0) uniform vec4 xyoffset_xzscale_yscale;"..
"layout(location=2) uniform highp mat4 mView;"..
"layout(location=6) uniform highp mat4 mProj;"..
"void main() {"..
  "highp float x = (xyz_chunk.s * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.s;"..
  "highp float y = (xyz_chunk.t * xyoffset_xzscale_yscale.q);"..
  "highp float z = (xyz_chunk.p * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.t;"..
  "highp vec4 vEyePos = mView * vec4(x, y, z, 1.0);"..
  "highp vec4 vPos = mProj * vEyePos;"..
  "bool isInFrontOfCamera = vEyePos.z >= 0.0;"..
  "vScreenPos = vPos;"..
  "vFragDepth = (vPos.p / vPos.q) * 0.5 + 0.5;"..
  "chunk = xyz_chunk.q;"..
  "gl_Position = vec4(vPos.xy, isInFrontOfCamera ? vPos.q : vPos.z, vPos.q);"..
"}"

local surfacefragment =
"in highp vec4 vScreenPos;"..
"noperspective in highp float vFragDepth;"..
"flat in float chunk;"..
"out highp vec4 col;"..
"layout(location=1) uniform sampler2D depthTex;"..
"layout(location=10) uniform sampler2D chunkTex;"..
"void main() {"..
  "highp float sceneDepth = texture(depthTex, ((vScreenPos.st / vScreenPos.q) + vec2(1.0, 1.0)) / 2.0).r;"..
  "bool isOuterWall = chunk < -0.5;"..
  "if (vFragDepth > sceneDepth && !isOuterWall) { discard; }"..
  "float chunkRelX = (int(chunk) % 5);"..
  "float chunkRelY = floor(chunk / 5.0);"..
  "bool unlocked = isOuterWall ? true : (texture(chunkTex, vec2(chunkRelX / 8.0, chunkRelY / 8.0)).r > 0.5);"..
  "float rgb = unlocked ? 1.0 : 0.0;"..
  "col = vec4(rgb, rgb, rgb, 1.0);"..
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
  "highp float a = texCol.r > 0.5 ? 0.0 : 0.7;"..
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
