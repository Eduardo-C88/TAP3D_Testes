Shader "Custom/MrClean"
{
    Properties
    {
        [Header(Main Settings)]
        _MainTex ("Main Texture", 2D) = "white" {}
        
        [Header(Dissolve Settings)]
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0
        _PatchSize ("Patch Size", Float) = 10
        
        [Header(Noise Appearance)]
        _NoiseColor ("Noise Color", Color) = (1,1,1,1)
        [Toggle]_ShowNoise ("Show Noise Color", Float) = 0
        _NoiseIntensity ("Noise Intensity", Range(0,1)) = 0.5
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
        fixed4 _NoiseColor;
        float _ShowNoise;
        float _NoiseIntensity;
        
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
            
            // Calculate edge glow (optional)
            float edgeGlow = saturate((noise - _DissolveAmount) * 5.0);
            
            // Combine effects
            if (_ShowNoise > 0.5)
            {
                // Blend between main color and noise color based on dissolve
                o.Albedo = lerp(mainColor.rgb * dissolve, 
                               _NoiseColor.rgb * _NoiseIntensity, 
                               (1 - dissolve) * _NoiseColor.a);
            }
            else
            {
                // Original dissolve effect only
                o.Albedo = mainColor.rgb * dissolve;
            }
            
            o.Alpha = mainColor.a * dissolve;
            
            // Optional: Add emission for glowing edges
            // o.Emission = _NoiseColor.rgb * edgeGlow * _NoiseIntensity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}