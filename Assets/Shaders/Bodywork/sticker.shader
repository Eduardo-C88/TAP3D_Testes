Shader "Unlit/StickerOverlay"
{
    Properties
    {
        [Header(Base Texture)]
        _MainTex ("Main Texture", 2D) = "white" {}
        
        [Header(Sticker Settings)]
        [Space(10)]
        _StickerTex1 ("Sticker 1 Texture", 2D) = "white" {}
        _StickerColor1 ("Sticker 1 Color", Color) = (1,1,1,1)
        _StickerOpacity1 ("Opacity 1", Range(0, 1)) = 1.0
        _StickerUVCenter1 ("Center Position 1", Vector) = (0.5, 0.5, 0, 0)
        _StickerUVScale1 ("Scale 1", Float) = 1.0
        _StickerUVRotation1 ("Rotation 1 (Radians)", Float) = 0.0
        [Toggle]_ClampSticker1 ("Clamp Sticker 1", Float) = 1
        
        [Space(10)]
        _StickerTex2 ("Sticker 2 Texture", 2D) = "white" {}
        _StickerColor2 ("Sticker 2 Color", Color) = (1,1,1,1)
        _StickerOpacity2 ("Opacity 2", Range(0, 1)) = 1.0
        _StickerUVCenter2 ("Center Position 2", Vector) = (0.5, 0.5, 0, 0)
        _StickerUVScale2 ("Scale 2", Float) = 1.0
        _StickerUVRotation2 ("Rotation 2 (Radians)", Float) = 0.0
        [Toggle]_ClampSticker2 ("Clamp Sticker 2", Float) = 1
        
        [Space(10)]
        _StickerTex3 ("Sticker 3 Texture", 2D) = "white" {}
        _StickerColor3 ("Sticker 3 Color", Color) = (1,1,1,1)
        _StickerOpacity3 ("Opacity 3", Range(0, 1)) = 1.0
        _StickerUVCenter3 ("Center Position 3", Vector) = (0.5, 0.5, 0, 0)
        _StickerUVScale3 ("Scale 3", Float) = 1.0
        _StickerUVRotation3 ("Rotation 3 (Radians)", Float) = 0.0
        [Toggle]_ClampSticker3 ("Clamp Sticker 3", Float) = 1
        
        [Space(10)]
        _StickerTex4 ("Sticker 4 Texture", 2D) = "white" {}
        _StickerColor4 ("Sticker 4 Color", Color) = (1,1,1,1)
        _StickerOpacity4 ("Opacity 4", Range(0, 1)) = 1.0
        _StickerUVCenter4 ("Center Position 4", Vector) = (0.5, 0.5, 0, 0)
        _StickerUVScale4 ("Scale 4", Float) = 1.0
        _StickerUVRotation4 ("Rotation 4 (Radians)", Float) = 0.0
        [Toggle]_ClampSticker4 ("Clamp Sticker 4", Float) = 1
        
        [Header(Blending)]
        [Enum(Normal,0,Multiply,1,Additive,2)] _BlendMode ("Blend Mode", Int) = 0
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
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            // Sticker 1 properties
            sampler2D _StickerTex1;
            fixed4 _StickerColor1;
            float _StickerOpacity1;
            float2 _StickerUVCenter1;
            float _StickerUVScale1;
            float _StickerUVRotation1;
            float _ClampSticker1;
            
            // Sticker 2 properties
            sampler2D _StickerTex2;
            fixed4 _StickerColor2;
            float _StickerOpacity2;
            float2 _StickerUVCenter2;
            float _StickerUVScale2;
            float _StickerUVRotation2;
            float _ClampSticker2;
            
            // Sticker 3 properties
            sampler2D _StickerTex3;
            fixed4 _StickerColor3;
            float _StickerOpacity3;
            float2 _StickerUVCenter3;
            float _StickerUVScale3;
            float _StickerUVRotation3;
            float _ClampSticker3;
            
            // Sticker 4 properties
            sampler2D _StickerTex4;
            fixed4 _StickerColor4;
            float _StickerOpacity4;
            float2 _StickerUVCenter4;
            float _StickerUVScale4;
            float _StickerUVRotation4;
            float _ClampSticker4;

            int _BlendMode;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            // Function to apply a single sticker
            fixed4 ApplySticker(float2 uv, float2 center, float scale, float rotation, float clampSticker, sampler2D tex, fixed4 color, float opacity)
            {
                fixed4 stickerColor = fixed4(0,0,0,0);
                float2 centeredUV = uv - center;
                
                // Apply rotation
                float s = sin(rotation);
                float c = cos(rotation);
                float2x2 rotMatrix = float2x2(c, -s, s, c);
                centeredUV = mul(rotMatrix, centeredUV);
                
                // Apply scale and recenter
                float2 stickerUV = centeredUV / scale + 0.5;
                
                // Only apply sticker if UVs are in 0-1 range (when clamping is enabled)
                if (clampSticker > 0.5)
                {
                    if (stickerUV.x >= 0.0 && stickerUV.x <= 1.0 && 
                        stickerUV.y >= 0.0 && stickerUV.y <= 1.0)
                    {
                        stickerColor = tex2D(tex, stickerUV) * color;
                        stickerColor.a *= opacity;
                    }
                }
                else
                {
                    // Original behavior (may show duplicates)
                    stickerColor = tex2D(tex, stickerUV) * color;
                    stickerColor.a *= opacity;
                }
                
                return stickerColor;
            }

            // Function to blend colors based on the selected mode
            fixed4 BlendColors(fixed4 base, fixed4 overlay, int mode)
            {
                switch (mode)
                {
                    case 1: // Multiply
                        return lerp(base, base * overlay, overlay.a);
                    case 2: // Additive
                        return lerp(base, base + overlay, overlay.a);
                    default: // Normal
                        return lerp(base, overlay, overlay.a);
                }
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample main texture
                fixed4 finalColor = tex2D(_MainTex, i.uv);
                
                // Apply all stickers in order
                fixed4 sticker1 = ApplySticker(i.uv, _StickerUVCenter1, _StickerUVScale1, _StickerUVRotation1, 
                                             _ClampSticker1, _StickerTex1, _StickerColor1, _StickerOpacity1);
                finalColor = BlendColors(finalColor, sticker1, _BlendMode);
                
                fixed4 sticker2 = ApplySticker(i.uv, _StickerUVCenter2, _StickerUVScale2, _StickerUVRotation2, 
                                             _ClampSticker2, _StickerTex2, _StickerColor2, _StickerOpacity2);
                finalColor = BlendColors(finalColor, sticker2, _BlendMode);
                
                fixed4 sticker3 = ApplySticker(i.uv, _StickerUVCenter3, _StickerUVScale3, _StickerUVRotation3, 
                                             _ClampSticker3, _StickerTex3, _StickerColor3, _StickerOpacity3);
                finalColor = BlendColors(finalColor, sticker3, _BlendMode);
                
                fixed4 sticker4 = ApplySticker(i.uv, _StickerUVCenter4, _StickerUVScale4, _StickerUVRotation4, 
                                             _ClampSticker4, _StickerTex4, _StickerColor4, _StickerOpacity4);
                finalColor = BlendColors(finalColor, sticker4, _BlendMode);
                
                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}