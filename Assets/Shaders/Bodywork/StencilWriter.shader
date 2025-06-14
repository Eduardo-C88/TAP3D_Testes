Shader "Unlit/StencilWriter"
{
    Properties
    {
        _ReferenceValue ("Reference Value", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        // Write 1 to the stencil buffer
        Stencil
        {
            Ref [_ReferenceValue]
            Comp always
            Pass replace
        }

        // Don't render any color
        ColorMask 0
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return 0; // Nothing visible
            }
            ENDCG
        }
    }
}
