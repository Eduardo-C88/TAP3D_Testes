Shader "Hidden/PostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurAmount ("Blur Amount", Range(0, 10)) = 0.5
        _BlurCenter ("Blur Center", Vector) = (0.5, 0.5, 0, 0)
        _BlurSamples ("Blur Samples", Range(4, 64)) = 16
        _BlurRadius ("Blur Radius", Range(0, 5)) = 1.0
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurAmount;
            float2 _BlurCenter;
            int _BlurSamples;
            float _BlurRadius;

            fixed4 frag (v2f i) : SV_Target
            {
                // Calcula a direção do blur radial
                float2 dir = i.uv - _BlurCenter;
                float dist = length(dir);
                
                // Normaliza a direção
                dir = normalize(dir);
                
                // Calcula a intensidade do blur baseada na distância do centro
                float blurIntensity = saturate(dist * _BlurRadius) * _BlurAmount;
                
                // Acumula as cores das amostras
                fixed4 color = tex2D(_MainTex, i.uv);
                fixed4 blurColor = color;
                
                // Aplica o blur radial por amostragem
                for(int j = 1; j <= _BlurSamples; j++)
                {
                    float factor = (float)j / (float)_BlurSamples;
                    float2 offset = dir * factor * blurIntensity * 0.02; // Controla a força do blur
                    
                    blurColor += tex2D(_MainTex, i.uv + offset);
                }
                
                // Média das amostras
                blurColor /= (_BlurSamples + 1);
                
                // Mistura baseada na distância do centro para criar transição suave
                float centerFade = saturate(1.0 - (dist * 2.0));
                
                // Combina a cor original com o blur
                fixed4 finalColor = lerp(blurColor, color, centerFade * 0.3);
                
                // Adiciona um leve vinhette para dar mais profundidade
                float vignette = 1.0 - smoothstep(0.3, 1.5, dist);
                finalColor.rgb *= lerp(1.0, vignette, 0.2);
                
                return finalColor;
            }
            ENDCG
        }
    }
}