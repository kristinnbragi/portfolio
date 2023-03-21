// define shader property for shaders
uniform float4 _Color;
uniform float _ColorMask;
// Fresnel
uniform float _EnabledFresnel;
uniform float _EnabledUseFresnelColor;
uniform float4 _FresnelColor;
uniform float _Opacity;
uniform float _FresnelPower;
// Line 1
uniform float _EnabledLine1;
uniform float _EnabledUseLine1Color;
uniform float4 _Line1Color;
uniform sampler2D _Line1Tex;
uniform float _Line1Opacity;
uniform float _Line1Speed;
uniform float _Line1Frequency;
uniform float _Line1Thickness;
// Line 2
uniform float _EnabledLine2;
uniform float _EnabledUseLine2Color;
uniform float4 _Line2Color;
uniform sampler2D _Line2Tex;
uniform float _Line2Opacity;
uniform float _Line2Speed;
uniform float _Line2Frequency;
uniform float _Line2Thickness;
// Grain
uniform float _EnabledGrain;
uniform float _GrainAmount;
// Intersection Glow
uniform float _EnabledIntersectionGlow;
uniform float _IntersectAmount;
// Glitch
uniform float _EnabledGlitch;
uniform float _FlickeringAmount;
uniform float _DisplacementAmount;

sampler2D _CameraDepthTexture; // automatically set up by Unity. Contains the scene's depth buffer
