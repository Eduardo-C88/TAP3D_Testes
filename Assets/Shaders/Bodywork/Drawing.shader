Shader "Unlit/TexturePerColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline Thickness", Range(0, 0.1)) = 0.01
        
        [Header(Paper Settings)]
        _PaperTex ("Paper Texture", 2D) = "white" {}
        _PaperColor ("Paper Color", Color) = (0.9, 0.85, 0.8, 1) 
        _PaperContrast ("Paper Contrast", Range(0, 5)) = 1.0
        
        [Header(Noise Settings)]
        _NoiseScale ("Noise Scale", Range(0, 10)) = 5.0
        _PencilRoughness ("Pencil Roughness", Range(0, 1)) = 0.3
        _ColorThreshold ("Color Protection Threshold", Range(-0.1, 1.1)) = 0.2
        [Toggle]_InvertThreshold ("Protect Dark Areas", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _PaperTex;
            float4 _MainTex_ST, _OutlineColor, _PaperColor;
            float _OutlineThickness, _NoiseScale, _PencilRoughness, _ColorThreshold, _PaperContrast;
            bool _InvertThreshold;

            // Optimized noise function
            float rand(float2 co)
            {
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Improved saturation check with invert option
            float isColorful(fixed3 c)
            {
                float mn = min(c.r, min(c.g, c.b));
                float mx = max(c.r, max(c.g, c.b));
                float saturation = mx - mn;
                
                if (_InvertThreshold) {
                    // Protect dark areas instead of colorful ones
                    return step(_ColorThreshold, -saturation);
                } else {
                    // Original behavior (protect colorful areas)
                    return step(_ColorThreshold, saturation);
                }
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample textures
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 paper = tex2D(_PaperTex, i.uv * _NoiseScale);
                
                // Apply paper color and contrast
                paper.rgb = (paper.rgb * _PaperContrast) * _PaperColor.rgb;

                // Edge detection (optimized 3x3 Sobel)
                float2 pixelSize = _OutlineThickness / _ScreenParams.xy;
                float edge = 0;
                UNITY_UNROLL
                for (int x = -1; x <= 1; x++) {
                    UNITY_UNROLL
                    for (int y = -1; y <= 1; y++) {
                        float2 offset = float2(x, y) * pixelSize;
                        edge += length(tex2D(_MainTex, i.uv + offset).rgb - col.rgb);
                    }
                }
                edge = saturate(edge * 10);

                // Apply noise only to non-protected areas
                float noise = rand(i.uv * _NoiseScale) * _PencilRoughness;
                noise *= (1 - isColorful(col.rgb)); // Mask out protected regions
                
                // Blend with paper texture
                col.rgb = lerp(col.rgb, col.rgb * paper.rgb, noise);

                // Apply outline
                col.rgb = lerp(col.rgb, _OutlineColor.rgb, edge);

                return col;
            }
            ENDCG
        }
    }
}