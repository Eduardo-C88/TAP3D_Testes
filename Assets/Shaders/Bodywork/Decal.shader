Shader "Custom/Decal"
{
 Properties {
        _MainTex ("Base Texture", 2D) = "white" {}
        _WindTex ("Wind Noise Texture", 2D) = "white" {}
        _WindSpeed ("Wind Speed", Range(0, 2)) = 0.5
        _WindIntensity ("Wind Intensity", Range(0, 1)) = 0.3
        _WindColor ("Wind Color", Color) = (0.8, 0.9, 1.0, 0.5)
        _WindDirection ("Wind Direction", Vector) = (1, 0.2, 0, 0)
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        
        sampler2D _MainTex;
        sampler2D _WindTex;
        float _WindSpeed;
        float _WindIntensity;
        float4 _WindColor;
        float4 _WindDirection;
        
        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Textura base
            fixed4 baseColor = tex2D(_MainTex, IN.uv_MainTex);
            
            // Coordenadas para o efeito de vento (baseado em posição mundial e normal)
            float2 windUV = IN.worldPos.xz * 0.1 + normalize(IN.worldNormal).xz * 0.3;
            windUV += _WindDirection.xy * _Time.y * _WindSpeed;
            
            // Amostra a textura de ruído para o vento
            float windNoise = tex2D(_WindTex, windUV).r;
            
            // Calcula a máscara do vento (mais forte em superfícies laterais)
            float windMask = saturate(abs(IN.worldNormal.y) - 0.7);
            windMask = 1.0 - windMask;
            
            // Combina o efeito
            float windEffect = windNoise * windMask * _WindIntensity;
            o.Albedo = baseColor.rgb + (windEffect * _WindColor.rgb);
            o.Alpha = baseColor.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}