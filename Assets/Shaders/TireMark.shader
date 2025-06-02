Shader "Unlit/TireMark"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TireMarkTex ("Tire Mark Texture", 2D) = "white" {}
        //_MarkSize ("Mark Size", Range(0.001, 1.0)) = 0.1
        _MarkIntensity ("Mark Intensity", Range(0.0, 2.0)) = 1.0
        _MarkLength ("Mark Length", Range(0.001, 2.0)) = 0.5
        _MarkWidth ("Mark Width", Range(0.0001, 0.3)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
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
            };
           
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 localPos : TEXCOORD2;
            };
           
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TirePointArrayA[32];
            float4 _TirePointArrayB[32];
            sampler2D _TireMarkTex;
            float4 _TireMarkTex_ST;
            //float _MarkSize;
            float _MarkIntensity;
            float _MarkLength;
            float _MarkWidth;
            
            // Simple noise function for variation
            float noise(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            // Smooth noise for more natural variation
            float smoothNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f); // smooth interpolation
                
                float a = noise(i);
                float b = noise(i + float2(1.0, 0.0));
                float c = noise(i + float2(0.0, 1.0));
                float d = noise(i + float2(1.0, 1.0));
                
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }
            
            fixed4 ApplyTireMark(float3 localPos, float4 tirePointArray[32])
            {
                fixed4 tireMarkColor = fixed4(0, 0, 0, 0);
                
                for (int j = 0; j < 32; j++)
                {
                    if (tirePointArray[j].w <= 0.0)
                        continue;
                    
                    float3 tirePoint = tirePointArray[j].xyz;
                    float3 diff = localPos - tirePoint;
                    
                    // Get next point for direction calculation
                    float3 nextPoint = tirePoint;
                    if (j < 31 && tirePointArray[j + 1].w > 0.0)
                    {
                        nextPoint = tirePointArray[j + 1].xyz;
                    }
                    else if (j > 0 && tirePointArray[j - 1].w > 0.0)
                    {
                        nextPoint = tirePointArray[j - 1].xyz;
                    }
                    
                    // Calculate tire movement direction
                    float3 direction = normalize(nextPoint - tirePoint);
                    if (length(nextPoint - tirePoint) < 0.001)
                        direction = float3(1, 0, 0); // fallback direction
                    
                    // Create oriented elliptical mark
                    float3 right = normalize(cross(direction, float3(0, 1, 0)));
                    float3 forward = direction;
                    
                    // Project position onto tire mark coordinate system
                    float forwardDist = dot(diff, forward);
                    float rightDist = dot(diff, right);
                    
                    float normalizedForward = forwardDist / _MarkLength;
                    float normalizedRight = rightDist / _MarkWidth;

                    // Map to texture UV coordinates (0-1 range)
                    float uCoord = (forwardDist / _MarkLength) * 0.5 + 0.5;
                    float vCoord = (rightDist / _MarkWidth) * 0.5 + 0.5;

                    // Apply fade even outside ellipse for smoother transition
                    // Smooth fade from center to edge with extended falloff
                    //float fade = 1.0 - smoothstep(1.0, 1.2, ellipseDistance);
                    
                    if (uCoord >= 0.0 && uCoord <= 1.0 && vCoord >= 0.0 && vCoord <= 1.0){
                        
                        // Add directional streaking
                        // float streakFactor = 1.0 - abs(normalizedRight) * 0.5;
                        // fade *= streakFactor;
                        
                        // Add noise for natural variation
                        // float2 noiseCoord = (localPos.xz + tirePoint.xz) * 10.0;
                        // float noiseValue = smoothNoise(noiseCoord);
                        // fade *= lerp(1.0, noiseValue, _StreakNoise);
                        
                        // Age-based fading (using w component as age/intensity)
                        // float ageFade = tirePointArray[j].w;
                        // fade *= ageFade;
                        
                        // Sample tire mark texture with proper UV mapping
                        float2 markUV = float2(normalizedForward * 0.5 + 0.5, normalizedRight * 0.5 + 0.5);
                        fixed4 markSample = tex2D(_TireMarkTex, markUV);
                        
                        // Use the texture's alpha channel properly
                        float textureAlpha = markSample.a;
                        
                        // Apply all fade factors including texture alpha
                        markSample.rgb *= _MarkIntensity;
                        markSample.a *= textureAlpha;
                        
                        // More realistic blending - darken the surface
                        markSample.rgb = lerp(fixed3(1, 1, 1), markSample.rgb, markSample.a);
                        
                        // Blend with existing tire marks using maximum alpha
                        tireMarkColor.rgb = lerp(tireMarkColor.rgb, markSample.rgb, markSample.a * (1.0 - tireMarkColor.a));
                        tireMarkColor.a = max(tireMarkColor.a, markSample.a);
                    }
                }
                return tireMarkColor;
            }
           
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.localPos = v.vertex.xyz;
                return o;
            }
           
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                fixed4 tireMarkColorA = ApplyTireMark(i.localPos, _TirePointArrayA);
                fixed4 tireMarkColorB = ApplyTireMark(i.localPos, _TirePointArrayB);
                
                // More natural blending - multiply for darkening effect
                col.rgb *= lerp(fixed3(1, 1, 1), tireMarkColorA.rgb, tireMarkColorA.a);
                col.rgb *= lerp(fixed3(1, 1, 1), tireMarkColorB.rgb, tireMarkColorB.a);
               
                return col;
            }
            ENDCG
        }
    }
}
