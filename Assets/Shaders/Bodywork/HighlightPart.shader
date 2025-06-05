Shader "Unlit/HighlightPart"
{
    Properties
    {
        _ReferenceValue ("Reference Value", Int) = 1
        _HighlightColor ("Highlight Color", Color) = (1, 0.5, 0, 1)
        _GlowIntensity ("Glow Intensity", Float) = 1.5
        _PulseSpeed ("Pulse Speed", Float) = 3.0
    }
    SubShader
    {
        Tags { "Queue"="Overlay" "RenderType"="Transparent" }

        // Only render where stencil == 1 (i.e., tagged car part)
        Stencil
        {
            Ref [_ReferenceValue]
            Comp equal
            Pass keep
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha One   // Additive blending for glow

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _HighlightColor;
            float _GlowIntensity;
            float _PulseSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Pulsing based on time
                float pulse = sin(_Time.y * _PulseSpeed) * 0.5 + 0.5;

                // Combine base color with pulsating alpha
                float glow = pulse * _GlowIntensity;
                fixed4 color = _HighlightColor;
                color.a *= glow;

                return color;
            }
            ENDCG
        }
    }
}
