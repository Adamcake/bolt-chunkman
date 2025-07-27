local surfacevertex =
"layout(location=0) in highp vec3 xyz;"..
"layout(location=1) in highp vec4 xyOpposite_chunkXY;"..
"out highp vec4 vScreenPos;"..
"noperspective out highp float vFragDepth;"..
"flat out vec2 vChunk;"..
"layout(location=0) uniform vec4 xyoffset_xzscale_yscale;"..
"layout(location=2) uniform highp mat4 mView;"..
"layout(location=6) uniform highp mat4 mProj;"..
"void main() {"..
  "highp float x = (xyz.x * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.s;"..
  "highp float y = (xyz.y * xyoffset_xzscale_yscale.q);"..
  "highp float z = (xyz.z * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.t;"..
  "highp vec4 vEyePos = mView * vec4(x, y, z, 1.0);"..
  "highp vec4 vPos = mProj * vEyePos;"..
  "bool isInFrontOfCamera = vEyePos.z >= 0.0;"..
  "vScreenPos = vPos;"..
  "vFragDepth = (vPos.p / vPos.q) * 0.5 + 0.5;"..
  "vChunk = xyOpposite_chunkXY.pq;"..
  "gl_Position = vec4(vPos.xy, isInFrontOfCamera ? (vPos.q * gl_DepthRange.far) : vPos.z, vPos.q);"..
"}"

local surfacefragment =
"in highp vec4 vScreenPos;"..
"noperspective in highp float vFragDepth;"..
"flat in vec2 vChunk;"..
"out highp vec4 col;"..
"layout(location=1) uniform sampler2D depthTex;"..
"layout(location=10) uniform sampler2D chunkTex;"..
"layout(location=11) uniform ivec4 vChunkTexOffset_Size;"..
"void main() {"..
  "highp float sceneDepth = texture(depthTex, ((vScreenPos.st / vScreenPos.q) + vec2(1.0, 1.0)) / 2.0).r;"..
  "if (vFragDepth > sceneDepth) { discard; }"..
  "bool unlocked = texture(chunkTex, (vChunk + vChunkTexOffset_Size.st) / vChunkTexOffset_Size.pq).r > 0.5;"..
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
"layout(location=1) uniform sampler2D depthTex;"..
"void main() {"..
  "highp float lockedAlpha = 0.7;"..
  "highp float sceneDepth = texture(depthTex, vXY).r;"..
  "highp vec4 texCol = texture(tex, vXY);"..
  "highp float depthModifier = 1.0 - smoothstep(0.998 * (gl_DepthRange.far - gl_DepthRange.near), gl_DepthRange.far, sceneDepth);"..
  "highp float a = step(texCol.r, 0.5) * lockedAlpha * depthModifier;"..
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
    surfaceprogram:setattribute(0, 1, true, false, 3, 0, 7)
    surfaceprogram:setattribute(1, 1, true, false, 4, 3, 7)

    local screenprogram = compileprogram(bolt, screenvertex, screenfragment)
    screenprogram:setattribute(0, 1, true, false, 2, 0, 2)

    return {
      surfaceprogram = surfaceprogram,
      screenprogram = screenprogram,
    }
  end,
}
