


// TODOs
// • Culling with stencil buffer test
// • Add more properties to Grain
// • Create a Glitch effect
// • Add direction property to line






Shader "Hologram Shader" {
    Properties {
        
        [HDR] _Color ("Main Color", Color) = (0, 0.5, 0.5, 0.0)
        _Opacity("Opacity", Range(0, 1)) = 0.2
        [RenderBackfacesToggle] _RenderBackfaces ("Render Backfaces", Float) = 0

		[Foldout(Fresnel)]
		[FoldoutGroupToggle(Fresnel, UseFresnelColor)] _EnabledUseFresnelColor("Use Unique Color", Float) = 0
		[FoldoutGroup(Fresnel)] [HDR] _FresnelColor ("Color", Color) = (0, 0.5, 0.5, 0.0)
		[FoldoutGroup(Fresnel)] _FresnelPower("Power", Range(0, 6)) = 1
 
		[Foldout(Line1)]
        [FoldoutGroupTexture(Line1, Line1Texture)] _Line1Tex ("Line 1", 2D) = "" {}
		[FoldoutGroupToggle(Line1, UseLine1Color)] _EnabledUseLine1Color("Use Unique Color", Float) = 0
		[FoldoutGroup(Line1)] [HDR] _Line1Color ("Color", Color) = (0, 0.5, 0.5, 0.0)
		[FoldoutGroup(Line1)] _Line1Opacity("Opacity", Range(0, 1)) = 1
		[FoldoutGroup(Line1)] _Line1Speed("Speed", float) = 3
		[FoldoutGroup(Line1)] _Line1Frequency("Frequency", float) = 100
		[FoldoutGroup(Line1)] _Line1Thickness("Thickness", Range(-.9, .9)) = 0

		[Foldout(Line2)]
        [FoldoutGroupTexture(Line2, Line2Texture)] _Line2Tex ("Line 2", 2D) = "" {}
		[FoldoutGroupToggle(Line2, UseLine2Color)] _EnabledUseLine2Color("Use Unique Color", Float) = 0
		[FoldoutGroup(Line2)] [HDR] _Line2Color ("Color", Color) = (0, 0.5, 0.5, 0.0)
		[FoldoutGroup(Line2)] _Line2Opacity("Opacity", Range(0, 1)) = 1
		[FoldoutGroup(Line2)] _Line2Speed("Speed", float) = 1
		[FoldoutGroup(Line2)] _Line2Frequency("Frequency", float) = 1
		[FoldoutGroup(Line2)] _Line2Thickness("Thickness", Range(-.9, .9)) = 0

		[Foldout(Grain)]
		[FoldoutGroup(Grain)]
        _GrainAmount("Amount", Range(0, 1)) = 0.3

		[Foldout(IntersectionGlow)]
		[FoldoutGroup(IntersectionGlow)]
        _IntersectAmount("_Intersect Amount", Float) = 1

		[Foldout(Glitch)]
		[FoldoutGroup(Glitch)]
        _DisplacementAmount("Displacement Amount", Range(0, 1)) = .3
		[FoldoutGroup(Glitch)]
        _FlickeringAmount("Flickering Amount", Range(0, 1)) = .1

        // Needed for updating enables in edit mode
        // and setting default values
        [HideInInspector]
        _EnabledFresnel("Enabled", Float) = 1
        [HideInInspector]
        _EnabledLine1("Enabled", Float) = 1
        [HideInInspector]
        _EnabledLine2("Enabled", Float) = 1
        [HideInInspector]
        _EnabledGrain("Enabled", Float) = 0
        [HideInInspector]
        _EnabledIntersectionGlow("Enabled", Float) = 0
        [HideInInspector]
        _EnabledGlitch("Enabled", Float) = 0
        [HideInInspector]
        _Culling ("Culling", Float) = 0
        [HideInInspector]
        _ColorMask ("ColorMask", Float) = 0
    }
    SubShader {
        Tags { "Queue" = "Transparent" }
        Pass {
            ColorMask [_ColorMask]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "properties.cginc"

            struct vertexInput {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct vertexOutput {
                float4 pos : SV_POSITION;
            };

            float rand(float3 i) {
                return frac(sin(dot(i, float3(12.9898, 78.233, 10.1543))) * 43758.5453123);
            }

            float3 randDir(float3 i) {
                return frac(sin(cross(i, float3(12.9898, 78.233, 10.1543))) * 43758.5453123);
            }

            vertexOutput vert(vertexInput i) {
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;

                vertexOutput o;
                o.pos = UnityObjectToClipPos(i.pos);
                float3 worldPos = mul(modelMatrix, i.pos).xyz;
                float glitch = 0;
                if (_EnabledGlitch == 1) {
                    glitch = sin(worldPos.y*30+_Time.w);
                    glitch *= step(.95,frac(worldPos.y+_Time.w));
                    glitch *= step(1-_DisplacementAmount*.3, rand(worldPos*_Time.w));
                    o.pos.x += glitch * .1;
                }
                return o;
            }

            float4 frag(vertexOutput i) : COLOR {
                if(_ColorMask > 0) {
                    discard;
                }
                return (0,0,0,0);
            };
            ENDCG
        }
        Pass {
            Cull [_Culling]
            ZWrite Off
            // Blend SrcAlpha OneMinusSrcAlpha
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
            #include "properties.cginc"

            struct vertexInput {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct vertexOutput {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
				float3 viewPos : TEXCOORD3;
				float4 screenPos : TEXCOORD4;
            };

            float rand(float3 i) {
                return frac(sin(dot(i, float3(12.9898, 78.233, 10.1543))) * 43758.5453123);
            }
            
            float3 randDir(float3 i) {
                return frac(sin(cross(i, float3(12.9898, 78.233, 10.1543))) * 43758.5453123);
            }

            vertexOutput vert(vertexInput i) {
                vertexOutput o;
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;

                o.worldPos = mul(modelMatrix, i.pos).xyz;
                o.normal = normalize(mul(float4(i.normal, 0.0), modelMatrixInverse).xyz);
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(modelMatrix, i.pos).xyz);
                o.pos = UnityObjectToClipPos(i.pos);
				o.viewPos = UnityObjectToViewPos(i.pos);
				o.screenPos = ComputeScreenPos(o.pos);
                float glitch = 0;
                if (_EnabledGlitch == 1) {
                    glitch = sin(o.worldPos.y*30+_Time.w);
                    glitch *= step(.95,frac(o.worldPos.y+_Time.w));
                    glitch *= step(1-_DisplacementAmount*.3, rand(o.worldPos*_Time.w));
                    o.pos.x += glitch * .1;
                }
                return o;
            }

            float4 frag(vertexOutput i) : COLOR {

                // Calculate line 1
                float line1 = 0;
                if (_EnabledLine1 == 1) {
                    line1 = i.worldPos.y * _Line1Frequency - _Time.w * _Line1Speed;
                    line1 = tex2D(_Line1Tex, float2(0, line1).y); // Look up in line texture
                    line1 = saturate(line1 + _Line1Thickness); // Add "thickness"
                    line1 *= _Line1Opacity; // Attenuate
                }

                // Calculate line 2
                float line2 = 0;
                if (_EnabledLine2 == 1) {
                    line2 = i.worldPos.y * _Line2Frequency - _Time.w * _Line2Speed;
                    line2 = tex2D(_Line2Tex, float2(0, line2).y); // Look up in line texture
                    line2 = saturate(line2 + _Line2Thickness); // Add "thickness"
                    line2 = line2 * _Line2Opacity; // Attenuate
                }

                // Calculate fresnel
                float fresnel = 1;
                if (_EnabledFresnel == 1) {
                    fresnel = pow(abs(dot(i.viewDir, i.normal)), _FresnelPower);
                }

                if (_EnabledUseFresnelColor==1)
                    _Color.rgb = _Color.rgb*(fresnel) + _FresnelColor.rgb*(1-fresnel);
                if (_EnabledUseLine1Color == 1)
                    _Color.rgb = _Color.rgb*(1-line1) + _Line1Color.rgb*line1;
                if (_EnabledUseLine2Color == 1)
                    _Color.rgb = _Color.rgb*(1-line2) + _Line2Color.rgb*line2;

                float myline = tex2D(_Line1Tex, i.worldPos.xy*10).y;

                float intersect = 0;
                if (_EnabledIntersectionGlow==1) {
                    float sceneZ = -LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r); // Get the depth of pixel in the frame buffer
                    float fragZ = i.pos.z; // Actual distance to the camera
                    intersect = saturate(1 + (sceneZ - i.viewPos.z)/_IntersectAmount);
                }

                // Calculate Grain
                float grain = 0;
                if (_EnabledGrain == 1) {
                    grain = rand(i.worldPos*_Time.w);
                    float grainAmount = _GrainAmount * 3;
                    grain = 0.5 * grainAmount - grain * grainAmount;
                }

                if (_EnabledGlitch == 1) {
                    float flickering = .1*step(1-.5*_FlickeringAmount, rand((_FlickeringAmount,_FlickeringAmount,_FlickeringAmount)*_Time.w));
                    _Color.rgb *= 1-flickering;
                }

                return float4(_Color*(_Opacity+intersect+(1-fresnel)+line1+line2+grain))*(1-.5*_ColorMask);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
