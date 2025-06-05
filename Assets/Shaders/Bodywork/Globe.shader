Shader "Custom/Globe"
{
    Properties
    {
        _DayTex ("Day Texture", 2D) = "white" {}
        _NightTex ("Night Texture", 2D) = "black" {}
        _BlendSharpness ("Blend Sharpness", Range(0.1, 1)) = .5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Cull Back
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _DayTex;
        sampler2D _NightTex;
        float _BlendSharpness;

        struct Input
        {
            float2 uv_DayTex;
            float3 worldNormal;
            float3 worldPos;
            INTERNAL_DATA
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Get normalized light direction
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

            // Normalize the normal
            float3 normal = normalize(IN.worldNormal);

            // Dot product to determine if it's facing the light (day) or away (night)
            float NdotL = saturate(dot(normal, lightDir));

            // Use sharpness to control transition between day and night
            float blend = pow(NdotL, _BlendSharpness);

            // Sample both textures
            float4 dayCol = tex2D(_DayTex, IN.uv_DayTex);
            float4 nightCol = tex2D(_NightTex, IN.uv_DayTex);

            // Lerp between day and night based on blend
            float4 finalColor = lerp(nightCol, dayCol, blend);

            o.Albedo = finalColor.rgb;
        }
        ENDCG

        Cull Front
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        struct Input
        {
            float2 uv_DayTex;
        };

        float4 mainImage(float2 uv)
        {
            float t = _Time.y * 0.2;

            // Step 1: remap UV from [0,1] to [-1,1]
            float2 uvFinal = uv * 2.0 - 1.0;
        
            float polar = atan2(uvFinal.x, uvFinal.y);
            float d = length(uvFinal * 3.141592);
            float x = sin(_Time.y + d);
            
            float3 col = sin(t + polar - d + float3(0.0, 2.0, 4.0));
            col = smoothstep(-1.0, 1.0, col);
            
            col = frac(col * d * x);
            
            return float4(col, 1.0);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_DayTex;
            
            // Feed normalized coords into procedural effect
            float4 col = mainImage(uv);

            o.Albedo = col;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
