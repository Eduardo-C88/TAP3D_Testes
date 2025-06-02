Shader "Unlit/Mossa"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0, 1)) = 0
        _Impact("Impact", Float) = 0
        _PontoEmbate("Ponto de Embate", Vector) = (0,0,0,0)
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _PontoEmbate;
            float4 _PontoEmbateArray[64];


            bool isPointInSphere(float3 ponto, float3 center, float radius)
            {
                float squaredDistance = dot(ponto - center, ponto - center);
                
                return squaredDistance <= radius * radius;
            }

            float _Radius;
            float _Impact;

            v2f vert (appdata v)
            {
                v2f o;

                for(int i = 0; i < 64; i++)
                {
                    if (isPointInSphere(v.vertex, _PontoEmbateArray[i], _Radius) && _PontoEmbateArray[i].w > 0)
                    {
                        // Apply the impact to the vertex position
                        v.vertex.xyz -= v.normal * _Impact;
                    }

                }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
