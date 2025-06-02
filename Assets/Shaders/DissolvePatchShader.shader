Shader "Custom/DissolvePatchShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0
        _PatchSize ("Patch Size", Float) = 10

    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM
        #pragma surface surf Standard
        
        sampler2D _MainTex;
        sampler2D _NoiseTex;
        float _DissolveAmount;
        float _PatchSize;
        
        struct Input
        {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Sample main texture
            half4 mainColor = tex2D(_MainTex, IN.uv_MainTex);
            
            // Sample noise texture (scaled for patch size)
            half noise = tex2D(_NoiseTex, IN.uv_MainTex * _PatchSize).r;
            
            // Create dissolve effect
            float dissolve = step(_DissolveAmount, noise);
            
            
            // Combine effects
            o.Albedo = mainColor.rgb * dissolve;
            o.Alpha = mainColor.a * dissolve;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
