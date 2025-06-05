Shader "Hidden/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity ("Intensidade do Bloom", Range(0, 5)) = 1
        _Threshold ("Limiar do Bloom", Range(0, 1)) = 0.7
        _BlurSize ("Tamanho do Blur", Range(0, 10)) = 1
        _BloomColor ("Cor do Bloom", Color) = (1, 0.9, 0.7, 1) // Amarelo claro/quente
        _ColorIntensity ("Intensidade da Cor", Range(0, 2)) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        // Pass 0: Extrair áreas brilhantes e aplicar cor amarelada
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragExtractBright

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Threshold;
            float3 _BloomColor;
            float _ColorIntensity;

            fixed4 fragExtractBright (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // Calcular luminosidade
                float brightness = dot(col.rgb, float3(0.2126, 0.7152, 0.0722));
                // Extrair áreas acima do threshold
                float bloom = max(0, brightness - _Threshold);
                // Aplicar cor amarelada
                float3 bloomColor = bloom * _BloomColor * _ColorIntensity;
                return fixed4(bloomColor, 1);
            }
            ENDCG
        }

        // Pass 1: Borrar horizontalmente
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlurHorizontal

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurSize;

            fixed4 fragBlurHorizontal (v2f i) : SV_Target
            {
                float2 texelSize = _MainTex_TexelSize.xy * _BlurSize;
                
                // Kernel de borrado gaussiano simples (9 taps)
                float3 col = tex2D(_MainTex, i.uv).rgb * 0.227027;
                
                col += tex2D(_MainTex, i.uv + float2(texelSize.x * 1.0, 0.0)).rgb * 0.1945946;
                col += tex2D(_MainTex, i.uv - float2(texelSize.x * 1.0, 0.0)).rgb * 0.1945946;
                
                col += tex2D(_MainTex, i.uv + float2(texelSize.x * 2.0, 0.0)).rgb * 0.1216216;
                col += tex2D(_MainTex, i.uv - float2(texelSize.x * 2.0, 0.0)).rgb * 0.1216216;
                
                col += tex2D(_MainTex, i.uv + float2(texelSize.x * 3.0, 0.0)).rgb * 0.054054;
                col += tex2D(_MainTex, i.uv - float2(texelSize.x * 3.0, 0.0)).rgb * 0.054054;
                
                col += tex2D(_MainTex, i.uv + float2(texelSize.x * 4.0, 0.0)).rgb * 0.016216;
                col += tex2D(_MainTex, i.uv - float2(texelSize.x * 4.0, 0.0)).rgb * 0.016216;
                
                return fixed4(col, 1);
            }
            ENDCG
        }

        // Pass 2: Borrar verticalmente
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlurVertical

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurSize;

            fixed4 fragBlurVertical (v2f i) : SV_Target
            {
                float2 texelSize = _MainTex_TexelSize.xy * _BlurSize;
                
                // Kernel de borrado gaussiano simples (9 taps)
                float3 col = tex2D(_MainTex, i.uv).rgb * 0.227027;
                
                col += tex2D(_MainTex, i.uv + float2(0.0, texelSize.y * 1.0)).rgb * 0.1945946;
                col += tex2D(_MainTex, i.uv - float2(0.0, texelSize.y * 1.0)).rgb * 0.1945946;
                
                col += tex2D(_MainTex, i.uv + float2(0.0, texelSize.y * 2.0)).rgb * 0.1216216;
                col += tex2D(_MainTex, i.uv - float2(0.0, texelSize.y * 2.0)).rgb * 0.1216216;
                
                col += tex2D(_MainTex, i.uv + float2(0.0, texelSize.y * 3.0)).rgb * 0.054054;
                col += tex2D(_MainTex, i.uv - float2(0.0, texelSize.y * 3.0)).rgb * 0.054054;
                
                col += tex2D(_MainTex, i.uv + float2(0.0, texelSize.y * 4.0)).rgb * 0.016216;
                col += tex2D(_MainTex, i.uv - float2(0.0, texelSize.y * 4.0)).rgb * 0.016216;
                
                return fixed4(col, 1);
            }
            ENDCG
        }

        // Pass 3: Combinar com a imagem original
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragCombine

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _BloomTex;
            float _Intensity;

            fixed4 fragCombine (v2f i) : SV_Target
            {
                fixed4 original = tex2D(_MainTex, i.uv);
                fixed4 bloom = tex2D(_BloomTex, i.uv);
                
                // Combinar aditivamente com a cor original
                return original + bloom * _Intensity;
            }
            ENDCG
        }
    }
}