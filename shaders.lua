local surfacevertex =
"layout(location=0) in highp vec3 xyz;"..
"layout(location=1) in highp vec2 chunkXY;"..
"out highp vec4 vScreenPos;"..
"flat out vec2 vChunk;"..
"layout(location=0) uniform vec4 xyoffset_xzscale_yscale;"..
"layout(location=2) uniform highp mat4 mViewProj;"..
"void main() {"..
  "highp float x = (xyz.x * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.s;"..
  "highp float y = (xyz.y * xyoffset_xzscale_yscale.q);"..
  "highp float z = (xyz.z * xyoffset_xzscale_yscale.p) + xyoffset_xzscale_yscale.t;"..
  "highp vec4 vPos = mViewProj * vec4(x, y, z, 1.0);"..
  "vScreenPos = vPos;"..
  "vChunk = chunkXY;"..
  "gl_Position = vPos;"..
"}"

local surfacefragment =
"in highp vec4 vScreenPos;"..
"flat in vec2 vChunk;"..
"out highp vec4 col;"..
"layout(location=1) uniform sampler2D depthTex;"..
"layout(location=10) uniform sampler2D chunkTex;"..
"layout(location=11) uniform ivec4 vChunkTexOffset_Size;"..
"void main() {"..
  "highp float sceneDepth = texture(depthTex, ((vScreenPos.st / vScreenPos.q) + vec2(1.0, 1.0)) / 2.0).r;"..
  "if (gl_FragCoord.z > sceneDepth) { discard; }"..
  "bool unlocked = texture(chunkTex, (vChunk + vChunkTexOffset_Size.st) / vChunkTexOffset_Size.pq).r > 0.5;"..
  "float rgb = unlocked ? 1.0 : 0.0;"..
  "col = vec4(rgb, rgb, rgb, 1.0);"..
"}"

local pyramidvertex =
"layout(location=0) in highp vec4 xyz_isRight;"..
"out highp vec4 vScreenPos;"..
"flat out vec2 vChunk;"..
"layout(location=0) uniform vec4 chunks;"..
"layout(location=2) uniform highp mat4 mViewProj;"..
"layout(location=6) uniform highp mat4 mModelTranslate;"..
"layout(location=12) uniform highp mat4 mModelRotate;"..
"layout(location=16) uniform highp float vScale;"..
"void main() {"..
  "highp vec4 vPos = mViewProj * mModelTranslate * mModelRotate * vec4(xyz_isRight.xyz * vScale, 1.0);"..
  "vScreenPos = vPos;"..
  "vChunk = mix(chunks.st, chunks.pq, xyz_isRight.q);"..
  "gl_Position = vPos;"..
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
"layout(location=2) uniform vec4 lockedCol;"..
"void main() {"..
  "highp float sceneDepth = texture(depthTex, vXY).r;"..
  "highp vec4 texCol = texture(tex, vXY);"..
  "highp float depthModifier = 1.0 - smoothstep(0.998 * (gl_DepthRange.far - gl_DepthRange.near), gl_DepthRange.far, sceneDepth);"..
  "col = vec4(lockedCol.stp, lockedCol.q * step(texCol.r, 0.5) * depthModifier);"..
"}"

return {
  get = function (bolt)
    local vsurface = bolt.createvertexshader(surfacevertex)
    local fsurface = bolt.createfragmentshader(surfacefragment)
    local vpyramid = bolt.createvertexshader(pyramidvertex)
    local vscreen = bolt.createvertexshader(screenvertex)
    local fscreen = bolt.createfragmentshader(screenfragment)

    local surfaceprogram = bolt.createshaderprogram(vsurface, fsurface)
    local pyramidprogram = bolt.createshaderprogram(vpyramid, fsurface)
    local screenprogram = bolt.createshaderprogram(vscreen, fscreen)

    surfaceprogram:setattribute(0, 1, true, false, 3, 0, 5)
    surfaceprogram:setattribute(1, 1, true, false, 2, 3, 5)
    pyramidprogram:setattribute(0, 1, true, false, 4, 0, 4)
    screenprogram:setattribute(0, 1, true, false, 2, 0, 2)

    return {
      surfaceprogram = surfaceprogram,
      pyramidprogram = pyramidprogram,
      screenprogram = screenprogram,
    }
  end,
}
