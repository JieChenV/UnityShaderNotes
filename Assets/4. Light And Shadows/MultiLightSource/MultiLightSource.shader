// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Multiple Light Source Forward Rendering


Shader "ShaderNotes/LightMode/MultiLightSource"
{
   Properties
    {
       _Diffuse ("Diffuse", Color) = (1,1,1,1)
       _Specular ("Specular", Color) = (1,1,1,1)
       _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "LightingMode"="ForwardBase" }

        // Base Pass, culculate the ambient only once and only in Base Pass
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Transform the normal from object space to world space 
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                // Transform the vertex from object space to world space
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // normalize the world normal 
                fixed3 worldNormal = normalize(i.worldNormal);
                // Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed atten = 1.0;
                float3 color = ambient + diffuse + specular;

                return fixed4(color * atten, 1.0);
            }


            ENDCG
         }

        Pass
        {
            Tags { "LightMode"="ForwardAdd" }

            // without blending, this pass will overwrite the base pass
            Blend One One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Transform the normal from object space to world space 
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                // Transform the vertex from object space to world space
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // normalize the world normal 
                fixed3 worldNormal = normalize(i.worldNormal);
                // Get the light direction in world space
            #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
            #else
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
            #endif

                // compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

            #ifdef USING_DIRECTIONOAL_LIGHT
                fixed atten = 1.0;
            #else
                #if defined (POINT)
                float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1) ).xyz;
                fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #else
                fixed atten = 1.0;
                #endif
            #endif

                float3 color = diffuse + specular;

                return fixed4(color * atten, 1.0);
            }


            ENDCG
        }
    }
            Fallback "Specular"

}
