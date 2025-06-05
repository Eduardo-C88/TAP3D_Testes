Shader "Unlit/Breathing"
{
    Properties
    {
        _MainTex ("Textura Base (RGB)", 2D) = "white" {}
        _PulseSpeed ("Velocidade da Pulsação", Range(0.1, 5)) = 1.0
        _PulseMin ("Brilho Mínimo", Range(0, 1)) = 0.5
        _PulseMax ("Brilho Máximo", Range(1, 10)) = 2.0
        _EmissionColor ("Cor do Brilho", Color) = (1, 1, 1, 1)
        
        // Propriedades do Rim Lighting
        _RimColor ("Cor da Borda", Color) = (0.5, 0.8, 1, 1)
        _RimPower ("Intensidade da Borda", Range(0.1, 5)) = 2.0
        _RimStrength ("Força da Borda", Range(0, 5)) = 1.0
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
                float3 normal : NORMAL; // Adicionado para calcular o Rim
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2; // Direção da câmera para o vértice
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PulseSpeed;
            float _PulseMin;
            float _PulseMax;
            fixed4 _EmissionColor;
            
            // Variáveis do Rim
            fixed4 _RimColor;
            float _RimPower;
            float _RimStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // Calcula a normal no espaço do mundo
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                // Calcula a direção da câmera para o vértice (no espaço do mundo)
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Textura base
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                // Efeito de pulsação (Breathing)
                float pulseFactor = lerp(_PulseMin, _PulseMax, (sin(_Time.y * _PulseSpeed) * 0.5 + 0.5));
                
                // Rim Lighting: 
                // 1. Calcula o produto escalar entre a normal e a direção da câmera
                float rimDot = 1 - saturate(dot(i.normal, i.viewDir));
                // 2. Ajusta a intensidade com um power (para controle artístico)
                float rimIntensity = pow(rimDot, _RimPower) * _RimStrength;
                // 3. Combina com a cor do Rim
                fixed3 rimGlow = _RimColor.rgb * rimIntensity;
                
                // Combina tudo:
                // - Cor da textura com emissão pulsante
                // - Adiciona o Rim Lighting
                fixed3 finalColor = texColor.rgb * _EmissionColor.rgb * pulseFactor + rimGlow;
                
                return fixed4(finalColor, texColor.a);
            }
            ENDCG
        }
    }
}